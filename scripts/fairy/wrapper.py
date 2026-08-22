#!/usr/bin/env python
# Runtime shim: run pr_review_wrapper with the patch inlined instead of
# uploaded. The Ollama cloud endpoint implements the OpenAI Responses API
# but has no files API, and the wrapper uploads the patch as a file
# whenever an openai: reviewer is requested (pr_review_wrapper.py, the
# patch_file_id block). The patch text already travels inline in
# ReviewContext.patch_text for every provider, so skipping the upload
# loses nothing. Upstream fix proposed separately; this shim keeps the
# Fairies checkout tree untouched.
import sys
from pathlib import Path

FAIRIES = Path(__file__).resolve().parents[2] / "tools" / "fairies"
sys.path.insert(0, str(FAIRIES))

import openai_common  # noqa: E402


def _no_upload(*args, **kwargs):
    # Must be None, not "": the reviewer checks `is not None` before
    # appending an input_file block, and an empty file_id is rejected by
    # endpoints without a files API all the same.
    return None


def _no_delete(client, file_id, **kwargs):
    if not file_id:
        return


openai_common.upload_text_file = _no_upload
openai_common.delete_uploaded_file = _no_delete

import pr_review_wrapper  # noqa: E402

pr_review_wrapper.upload_text_file = _no_upload
pr_review_wrapper.delete_uploaded_file = _no_delete

# The reviewer appends an input_file block for the source bundle
# unconditionally once one exists (openai_reviewer source-bundle block),
# so a None upload is not enough on endpoints without a files API:
# suppress the bundle itself. The model still reads sources through its
# container shell.
def _no_source_bundle(*args, **kwargs):
    return (None, [], [])


pr_review_wrapper.build_source_bundle = _no_source_bundle

if __name__ == "__main__":
    sys.exit(pr_review_wrapper.main())
