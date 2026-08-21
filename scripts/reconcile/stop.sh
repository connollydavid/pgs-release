#!/bin/bash
# Rebase-stop resolver for typed files (the host-reconcile workaround).
#
# Usage: stop.sh <old-base-sha>     (run inside the rebasing ffmpeg worktree)
#
# Resolves the recurring trio the pgs series meets at a rebase stop:
#   - libav*/version.h: keep the new base's majors, apply the commit's
#     PARENT-RELATIVE minor delta, reset micro to 100 (an API bump).
#   - doc/APIchanges: keep the base side, insert this commit's entry with
#     the version re-derived onto the new lineage, above the newest
#     series entry (series order: later commits list higher).
#   - makefiles: union-merge both sides (registration lists append).
#
# Limitations kept deliberately: a commit whose version delta contradicts
# its own APIchanges entry (the ELBG double-bump) needs a human call —
# this script applies the version.h delta faithfully and prints what it
# derived so the discrepancy is visible at the stop, not after.
set -u
BASE="${1:?usage: stop.sh <old-base-sha>}"
cd "$(git rev-parse --show-toplevel)" || exit 9

python3 - "$BASE" <<'EOF'
import re, subprocess, sys, os
BASE = sys.argv[1]

def sh(*args):
    return subprocess.run(args, capture_output=True, text=True).stdout

def orig_sha():
    for f in ('libavutil/version.h', 'libavcodec/version.h', 'doc/APIchanges'):
        if os.path.exists(f):
            m = re.search(r'>>>>>>> ([0-9a-f]{9})', open(f).read())
            if m: return m.group(1)
    raise SystemExit("no conflict marker with a sha found")

ORIG = orig_sha()
print("orig commit:", ORIG)

def nums(block):
    d = {}
    for suf, kind, val in re.findall(r'#define LIBAV(\w+)_VERSION_(MAJOR|MINOR|MICRO)\s+(\d+)', block):
        d[(suf, kind)] = int(val)
    return d

versions = {}
for p in ('libavutil/version.h', 'libavcodec/version.h', 'libavformat/version.h'):
    if not (os.path.exists(p) and '<<<<<<<' in open(p).read()):
        continue
    s = open(p).read()
    m = re.search(r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> [0-9a-f]{9}[^\n]*\n', s, re.S)
    if not m:
        print(f"{p}: conflict shape not recognised, resolve by hand"); continue
    head, ours = m.group(1), m.group(2)
    h, o = nums(head), nums(ours)
    b = nums(sh('git', 'show', f'{ORIG}^:{p}'))
    new = {}
    for suf in {k[0] for k in h}:
        if not all((suf, 'MINOR') in d for d in (h, o, b)):
            print(f"{p}: {suf} minor not present on all sides, resolve by hand"); continue
        # parent-relative delta: what THIS commit bumped on the old lineage
        new[suf] = (h[(suf, 'MAJOR')], h[(suf, 'MINOR')] + (o[(suf, 'MINOR')] - b[(suf, 'MINOR')]), 100)
    out = head
    for suf, (nm, nn, _) in new.items():
        out = re.sub(rf'#define LIBAV{suf}_VERSION_MINOR\s+\d+',
                     f'#define LIBAV{suf}_VERSION_MINOR  {nn:2d}', out)
    s = s[:m.start()] + out + '\n' + s[m.end():]
    for suf in new:  # MICRO may sit outside the conflict block
        s = re.sub(rf'#define LIBAV{suf}_VERSION_MICRO\s+\d+',
                   f'#define LIBAV{suf}_VERSION_MICRO 100', s)
    open(p, 'w').write(s)
    alias = {'UTIL': 'lavu', 'CODEC': 'lavc', 'FORMAT': 'lavf'}
    for suf, v in new.items():
        versions[alias.get(suf, suf.lower())] = v
    print(f"{p}: -> {new}")

p = 'doc/APIchanges'
s = open(p).read()
if '<<<<<<<' in s:
    start = s.index('<<<<<<< HEAD\n'); mid = s.index('=======\n', start)
    end = s.index('>>>>>>> ', mid); eol = s.index('\n', end) + 1
    s = s[:start] + s[start + len('<<<<<<< HEAD\n'):mid] + s[eol:]
    lines = [l[1:] for l in sh('git', 'diff', f'{ORIG}^', ORIG, '--', p).splitlines()
             if l.startswith('+') and not l.startswith('+++')]
    entry = '\n'.join(lines).rstrip() + '\n\n'
    def repl(m):
        key = {'lavu': 'lavu', 'lavc': 'lavc', 'lavf': 'lavf'}[m.group(1)]
        if key in versions:
            nm, nn, _ = versions[key]
            return f"{m.group(1)} {nm}.{nn}.100"
        return m.group(0)
    entry = re.sub(r'\b(lav[ucf]) \d+\.\d+\.\d+', repl, entry, count=1)
    anchor = next((l for l in s.splitlines() if re.match(r'\d{4}-\d\d-xx - x{10}', l)), None)
    if anchor:
        s = s.replace(anchor, entry + anchor, 1)
    else:
        i = s.index('API changes, most recent first:') + len('API changes, most recent first:') + 2
        s = s[:i] + entry + s[i:]
    open(p, 'w').write(s)
    print("APIchanges entry inserted:", entry.splitlines()[0])

import glob
for p in set(glob.glob('tests/**/*.mak', recursive=True) + glob.glob('tests/api/Makefile')
             + glob.glob('libav*/Makefile') + glob.glob('fftools/Makefile')):
    if '<<<<<<<' not in open(p).read(): continue
    out, mode = [], 0
    for line in open(p).read().splitlines(keepends=True):
        if line.startswith('<<<<<<<'): mode = 1; continue
        if line.startswith('=======') and mode == 1: mode = 2; continue
        if line.startswith('>>>>>>>') and mode == 2: mode = 0; continue
        out.append(line)
    open(p, 'w').write(''.join(out))
    print(f"{p}: union-merged (review the result)")
EOF

echo "=== remaining conflicts (resolve by hand) ==="
git diff --name-only --diff-filter=U
