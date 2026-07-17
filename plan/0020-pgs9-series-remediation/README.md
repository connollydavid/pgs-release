# pgs9 series remediation

- Status: accepted
- Date: 2026-07-17

## Context

A Claude-driven adversarial review (2026-07-17) checked our recorded
understanding of FFmpeg's commit rules against the live upstream
documentation, and audited the 29 commits on `pgs8-wip` against those rules.
It found one blocking defect (cross-library `ff_` symbols that break
`--enable-shared` builds), several missed collateral items, regressions of
rules our own earlier reviews had already prescribed (plan/0007, plan/0011,
plan/0012), and stale process assumptions (Forgejo pull requests became a
first-class submission path 2026-02-26; review happens on the list or
code.ffmpeg.org since 2026-07-13; no adopted AI-contribution policy exists,
only hostile-review norms). Per the branch discipline, remediation happens on
a new `pgs9` branch; `pgs8-wip` freezes under a history tag.

Goal, verified: a `pgs9` branch on current upstream master where every commit
compiles and passes FATE in both static and shared configurations, all
collateral is present, messages and trailers are uniform, and the plan room
states the submission process as it actually is today.

## Finding map

| Review finding | Task |
|---|---|
| Cross-library `ff_sub_*` from libavutil (blocking) | [#relocate-sub-util](#relocate-sub-util) |
| lavfi calls lavu `ff_` symbols at intermediate commits | [#close-palette-window](#close-palette-window) |
| Missing lavu minor bump on the ELBG avpriv move | [#move-version-bumps](#move-version-bumps) |
| APIchanges placeholder dates and stale minor numbers | [#apichanges-truth](#apichanges-truth) |
| New fftools CLI options undocumented | [#cli-docs](#cli-docs) |
| general_contents.texi PGS encoding column, MAINTAINERS | [#codec-table-maintainers](#codec-table-maintainers) |
| Signed-off-by on 4 of 29 commits only | [#signoff-and-trailers](#signoff-and-trailers) |
| Co-Authored-By trailer carries a noisy variant descriptor | [#trailer-decision](#trailer-decision), [#signoff-and-trailers](#signoff-and-trailers) |
| Non-ASCII in two messages and four of our comments | [#ascii-pass](#ascii-pass) |
| patcheck advisories (braces, doxygen param, av_cold) | [#patcheck-triage](#patcheck-triage) |
| Per-patch compile never checked with shared libs | [#per-patch-builds](#per-patch-builds) |
| Changelog silent on user-visible fftools features | [#changelog-features](#changelog-features) |
| Plans assume mailing-list-only submission | [#venue-decision](#venue-decision), [#correct-plan-docs](#correct-plan-docs) |
| plan/0019 cites an AI "policy" that does not exist | [#correct-plan-docs](#correct-plan-docs) |
| Recorded tests-in-same-patch claim contradicts the series | [#correct-plan-docs](#correct-plan-docs) |

As Elias, I want every commit to build in both link modes at every point in
the series, so that a future bisect never lands on a commit that only links
statically.

## Build sequence

### Decisions {#decisions}

- band

### Record the submission venue decision {#venue-decision}

Record a call/ decision (allocate with `host-lifecycle next call/`): submit
via the ffmpeg-devel mailing list, via a Forgejo pull request on
code.ffmpeg.org, or list-first with Forgejo as fallback. Both are official;
review happens in either place; GitHub PRs are ignored. The decision sets the
mechanics tasks in plan/0019 and the wording fixes here.

- verify: attested operator

### Record the attribution trailer decision {#trailer-decision}

Record a call/ decision: keep a normalized `Co-Authored-By: Claude
<noreply@anthropic.com>` trailer on every commit, or drop the trailer and
disclose assistance in the cover letter and RFC prose only. Either way the
noisy variant descriptor is removed. Upstream has no rule either way and no
precedent for an AI trailer; disclosure itself stays, per our honest
attribution rule.

- verify: attested operator

### Branch cut {#branch-cut}

- band

### Freeze v8 under its history tag {#freeze-v8}

Tag `history/pgs-v8` at the `pgs8-wip` tip and push the tag. `pgs8-wip` is
frozen from that point per the branch discipline.

- verify: git -C software/ffmpeg/pgs8-wip rev-parse --verify history/pgs-v8

### Cut pgs9 and rebase onto upstream master {#cut-pgs9}

- depends: #freeze-v8

Branch `pgs9` from the frozen tip, fetch current upstream master, and rebase
the 29-commit series onto it with `scripts/resolve-version-conflicts.sh` in
exec mode. Version-number conflicts in APIchanges and version.h are expected;
resolve them provisionally here and finish them in
[#apichanges-truth](#apichanges-truth).

- verify: attested operator

### Series rewrite {#series-rewrite}

- band

### Relocate sub_util into fftools {#relocate-sub-util}

- depends: #cut-pgs9

`ff_sub_find_gap` and `ff_sub_scale_alpha` are consumed only by
`fftools/ffmpeg_enc_sub.c` and the three `tests/api/api-pgs-*` programs; no
library uses them, so they do not belong in libavutil at all. Rewrite the
series so the helpers live in fftools from the start, the api tests reach
them by direct `.c` inclusion (one already does), and no commit adds
`libavutil/sub_util.*`. This removes the shared-link breakage and shrinks the
lavu surface the reviewers must accept.

- verify: bash -c 'cd software/ffmpeg/pgs9 && test -z "$(git ls-files libavutil | grep sub_util)" && ! git grep -q "libavutil/sub_util" -- fftools tests'

### Close the palette move window {#close-palette-window}

Rewrite the palette move so no commit leaves libavfilter calling a `ff_`
symbol that lives in libavutil: fold the consumer switch into the move
commit, or reorder so the public `av_` API lands first. Check every commit,
not the tip.

- verify: bash -c 'cd software/ffmpeg/pgs9 && for c in $(git rev-list $(git merge-base pgs9 upstream/master)..pgs9); do git grep -q "ff_srgb_u8_to_oklab_int\|ff_oklab" $c -- libavfilter 2>/dev/null && exit 1; done; exit 0'

### Version bumps on the library moves {#move-version-bumps}

The ELBG move exports `avpriv_elbg_*` from libavutil: bump the lavu minor
version in that commit and state the cross-library ABI rationale in its
message, since moving exported avpriv symbols mid-major draws review
scrutiny. Confirm the palette move stays lavu-internal after
[#close-palette-window](#close-palette-window) and therefore needs no bump.

- verify: bash -c 'cd software/ffmpeg/pgs9 && c=$(git log --format=%H --diff-filter=A $(git merge-base pgs9 upstream/master)..pgs9 -- libavutil/elbg.c) && git show $c --stat | grep -q libavutil/version.h'

### Uniform sign-off and trailers {#signoff-and-trailers}

- depends: #trailer-decision, #cut-pgs9

Every commit carries `Signed-off-by: David Connolly <david@connol.ly>`, with
the attribution trailer applied per the recorded decision, ordered after the
sign-off, and the variant descriptor removed.

- verify: bash -c 'cd software/ffmpeg/pgs9 && b=$(git merge-base pgs9 upstream/master) && test "$(git rev-list --count $b..pgs9)" = "$(git rev-list --count --grep="Signed-off-by: David Connolly <david@connol.ly>" $b..pgs9)" && ! git log $b..pgs9 | grep -q "1M context"'

### ASCII pass over messages and our comments {#ascii-pass}

Rewrite into plain ASCII the two commit messages that carry arrows and an
em-dash (the acquisition-interval timing diagram and the lookahead message)
and the four comment lines we added with em-dashes or arrows. Moved
copyright author names stay verbatim; they are the upstream authors'
identities, not our prose.

- verify: bash -c 'cd software/ffmpeg/pgs9 && b=$(git merge-base pgs9 upstream/master) && ! git log --format=%B $b..pgs9 | grep -qP "[^\x00-\x7F]" && test "$(git diff $b..pgs9 -- "*.c" "*.h" | grep -P "^\+.*[^\x00-\x7F]" | grep -cv "Bœsch\|Lesiński")" = 0'

### patcheck triage {#patcheck-triage}

Regenerate the series patches and run `tools/patcheck` over each: fix the
brace placements, the mismatched doxygen parameter, and add `av_cold` where
the hint is right; the fprintf hits in standalone FATE api programs and the
main() prefix hits are noise and stand.

- verify: attested operator

### Collateral {#collateral}

- band

### APIchanges entries carry real dates and current minors {#apichanges-truth}

Re-derive the lavu minor numbers against current master, set real dates,
keep hashes as placeholders until push (upstream practice), and keep the
entries chronologically ordered.

- verify: bash -c 'cd software/ffmpeg/pgs9 && ! git grep -q "2026-03-xx" -- doc/APIchanges'

### Document the new fftools CLI options {#cli-docs}

Every new OptionDef the series adds (sub_ocr_lang, sub_ocr_datapath,
sub_ocr_pageseg_mode, sub_ocr_min_duration, forced_subs_filter, and the
rest of the enumerated additions) gets a doc/ffmpeg.texi entry in the commit
that introduces it.

- verify: bash -c 'cd software/ffmpeg/pgs9 && for o in sub_ocr_lang sub_ocr_datapath sub_ocr_pageseg_mode sub_ocr_min_duration forced_subs_filter; do git grep -q "$o" -- doc/ffmpeg.texi || exit 1; done'

### Codec table and MAINTAINERS {#codec-table-maintainers}

The PGS row in doc/general_contents.texi gains its encoding mark in the
encoder commit; MAINTAINERS gains entries for the PGS encoder, the lavu
quantize and palette modules, and the fftools subtitle conversion, in the
commits that introduce them.

- verify: bash -c 'cd software/ffmpeg/pgs9 && git grep -q "pgssubenc" -- MAINTAINERS && grep -A1 -m1 "@item PGS " doc/general_contents.texi | head -1 | grep -q "X @tab X"'

### Changelog entries for user-visible features {#changelog-features}

Beside the existing encoder entry, the text-to-bitmap conversion and the OCR
bitmap-to-text conversion get Changelog lines in the commits that ship them;
encoder options need none.

- verify: bash -c 'cd software/ffmpeg/pgs9 && git grep -qi "ocr" -- Changelog'

### Verification {#verification}

- band

### Per-patch builds in both link modes {#per-patch-builds}

Script the walk: for every commit in the series, build with the default
static configuration and with --enable-shared, and fail on the first commit
that does not compile and link. Run it where a build is fast (CI or a native
filesystem; the WSL /mnt/c mount is too slow for 29 iterations). This is the
check that would have caught the sub_util defect mechanically, so it becomes
part of the pre-push rule from here on.

- verify: attested operator

### FATE green at every commit that touches refs {#fate-tip}

- depends: #per-patch-builds

`make fate` passes at the series tip in both link modes, and at each commit
that adds or changes a FATE reference the affected tests pass, so a bisect
never lands on a red test.

- verify: attested operator

### Re-cut the submission series {#recut-series}

- depends: #patcheck-triage, #changelog-features, #fate-tip

Re-derive the submission cut (the five independent series of plan/0018) on
the rewritten pgs9 commits and record the new manifests in this milestone;
plan/0018 stays a frozen record of the v7 cut.

- verify: attested operator

### Recorded rules {#recorded-rules}

- band

### Correct the plan room's process claims {#correct-plan-docs}

- depends: #venue-decision

plan/0000: record the Forgejo option beside the mailing list, replace the
tests-in-same-patch claim with what the series actually does (dedicated test
commits are accepted upstream practice), and add the send mechanics we never
recorded (format-patch/send-email, one patch per mail, subscribers-only
list, push-wait windows, samples over 100k by URL, patcheck as a checklist
step). plan/0019: reword the RFC task so disclosure is our strategy, not
compliance with a list policy that does not exist.

- verify: bash -c '! grep -rq "per the list.s policy" plan/0019-ffmpeg-devel-submission/ && grep -q "Forgejo" plan/0000-ffmpeg-subtitle-upstreaming.md'

### Amend the project verification rule {#amend-project-rules}

The patch-series discipline in CLAUDE.md gains the shared-link leg: the
per-patch compile check runs the default configuration and --enable-shared.

- verify: bash -c 'grep -q "enable-shared" CLAUDE.md'

### Switch the Where room to pgs9 {#where-room-switch}

- depends: #recut-series, #amend-project-rules

Push pgs9, update the ffmpeg stanza in .host-software (branch and pin) per
the commit-upstream-first rule, materialize software/ffmpeg/pgs9, and run
the gate.

- verify: host-lifecycle software --check .

## Out of scope

Sending the RFC and the submissions themselves stay in plan/0019, which
resumes once this milestone closes; its rebase task is subsumed by
[#cut-pgs9](#cut-pgs9). Editing plan/0018's recorded v7 manifests is
forbidden; the pgs9 cut is recorded here.
