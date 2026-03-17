#!/bin/bash
# resolve-version-conflicts.sh — resolve FFmpeg version bump conflicts during cherry-pick/rebase
#
# When cherry-picking patches across branches (e.g. master → release), library
# version bumps in */version.h and doc/APIchanges conflict because the minor
# version diverges between branches. This script resolves those conflicts
# automatically by incrementing from the HEAD (target branch) value.
#
# Usage:
#   Run from the ffmpeg/ submodule directory during a conflicted cherry-pick:
#     ../scripts/resolve-version-conflicts.sh
#     git cherry-pick --continue --no-edit
#
# What it does:
#   - */version.h: takes HEAD minor version + 1
#   - doc/APIchanges: takes the new API entry from theirs, adjusts the library
#     version number to match the incremented minor version
#   - Any other conflicted file: exits with an error (manual resolution needed)
#
# Limitations:
#   - Assumes one conflict block per file
#   - Assumes standard FFmpeg version.h format (#define LIBxxx_VERSION_MINOR  N)

set -euo pipefail

conflicts=$(git diff --name-only --diff-filter=U)

if [ -z "$conflicts" ]; then
    echo "No conflicted files."
    exit 0
fi

for f in $conflicts; do
    case "$f" in
        */version.h)
            # Extract the HEAD (ours) minor version from the conflict block
            head_minor=$(sed -n '/^<<<<<<</,/^=======/{ /VERSION_MINOR/{s/.*MINOR  *//p;}}' "$f")
            if [ -z "$head_minor" ]; then
                echo "ERROR: could not parse HEAD minor version from $f"
                exit 1
            fi
            new_minor=$((head_minor + 1))
            # Resolve: replace conflict block with incremented version
            python3 -c "
import re
content = open('$f').read()
content = re.sub(
    r'<<<<<<< HEAD\n#define (\w+VERSION_MINOR)\s+\d+\n=======\n#define \1\s+\d+\n>>>>>>> [^\n]+',
    f'#define \\\\1  $new_minor',
    content
)
open('$f', 'w').write(content)
"
            # Verify no conflict markers remain
            if grep -q '<<<<<<< HEAD' "$f"; then
                echo "ERROR: unresolved conflict markers remain in $f"
                exit 1
            fi
            git add "$f"
            echo "  $f: MINOR $head_minor → $new_minor"
            ;;

        doc/APIchanges)
            # Detect which library the conflict is about (lavu, lavc, lavf, etc.)
            lib_tag=$(sed -n '/^=======/,/^>>>>>>>/{ /[0-9]\+\.[0-9]\+\.100/{ s/.*- \(la[a-z]*\) .*/\1/p; }}' "$f" | head -1)
            if [ -z "$lib_tag" ]; then
                # Fallback: try from HEAD side
                lib_tag=$(sed -n '/^<<<<<<</,/^=======/{ /[0-9]\+\.[0-9]\+\.100/{ s/.*- \(la[a-z]*\) .*/\1/p; }}' "$f" | head -1)
            fi
            if [ -z "$lib_tag" ]; then
                echo "ERROR: could not detect library tag from APIchanges conflict"
                exit 1
            fi

            # Get HEAD minor version for this library from the conflict
            head_ver=$(sed -n "/^<<<<<<</,/^=======/{ /$lib_tag [0-9]/{ s/.*$lib_tag //; s/ .*//; p; }}" "$f" | head -1)
            if [ -n "$head_ver" ]; then
                head_minor=$(echo "$head_ver" | cut -d. -f2)
            else
                # HEAD side might not have a version line for this lib — use 0
                head_minor=0
            fi
            new_minor=$((head_minor + 1))
            major=$(echo "$head_ver" | cut -d. -f1)
            if [ -z "$major" ]; then
                # Get major from theirs side
                major=$(sed -n "/^=======/,/^>>>>>>>/{ /$lib_tag [0-9]/{ s/.*$lib_tag //; s/\..*//; p; }}" "$f" | head -1)
            fi

            python3 -c "
import re
content = open('$f').read()
m = re.search(r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> [^\n]+', content, re.DOTALL)
if m:
    ours = m.group(1)
    theirs = m.group(2)
    # Fix the first version reference for $lib_tag in theirs
    lines = theirs.split('\n')
    fixed_lines = []
    first_ver_fixed = False
    for line in lines:
        if not first_ver_fixed and re.search(r'$lib_tag $major\.\d+\.100', line):
            line = re.sub(r'$lib_tag $major\.\d+\.100', '$lib_tag $major.$new_minor.100', line)
            first_ver_fixed = True
        fixed_lines.append(line)
    replacement = '\n'.join(fixed_lines)
    content = content[:m.start()] + replacement + content[m.end():]
    open('$f', 'w').write(content)
"
            if grep -q '<<<<<<< HEAD' "$f"; then
                echo "ERROR: unresolved conflict markers remain in $f"
                exit 1
            fi
            git add "$f"
            echo "  $f: $lib_tag $major.$head_minor → $major.$new_minor"
            ;;

        *)
            echo "ERROR: unexpected conflict in $f — manual resolution needed"
            exit 1
            ;;
    esac
done

echo "All version conflicts resolved."
