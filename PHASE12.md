# Phase 12: FATE CI + Website Test Visibility

## Status: Complete

## Goal

1. GitHub Actions workflow that builds FFmpeg (non-static, system libs) and runs
   FATE on every push/PR. Validates patches stay functional. No published assets.
2. Website section showing what we test, linking to CI results.

## 12a: FFmpeg FATE CI Workflow — DONE

- Single job on `ubuntu-24.04`
- System packages: `libass-dev`, `libtesseract-dev`, `tesseract-ocr-eng`, `nasm`
- Configure mirrors release workflow flags with system shared libs
- Runs 10 self-contained FATE tests (API tests + gifenc-rgba)
- `sub-pgs-overlap` and `sub-ocr-roundtrip` excluded from CI — they produce
  framecrc/transcode output dependent on exact libass/tesseract versions.
  System packages differ from our pinned libs. Validated locally with pinned
  libraries instead.

## 12b: Website Test Visibility — DONE

- Development page: tests grouped by area (encoder, animation, quantization,
  OCR), CI badge, known upstream failures noted, anchor `#tests`
- Main page: CI badge + "13 FATE tests, CI on every push" above download grid,
  links to `development.html#tests`
- OCR languages linked rather than duplicated

## Known Pre-existing Failures

- `sws-unscaled` — fails on clean FFmpeg 8.1 (not our patches)
