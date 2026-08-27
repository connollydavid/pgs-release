#!/usr/bin/env python
# Runtime shim: run pr_review_wrapper against endpoints that lack OpenAI
# server-side conveniences. Two independent concerns, both originating
# from the Ollama cloud endpoint (https://ollama.com/v1):
#
# 1. No files API: uploads of the patch/source bundle are skipped; the
#    patch travels inline in ReviewContext.patch_text and sources are
#    read through the review container shell.
# 2. Non-stateful Responses API only: tool follow-ups that arrive with
#    previous_response_id are converted to full-history stateless
#    requests (original input + prior function_call items + new outputs)
#    by a create() wrapper. Upstream fix proposed separately; this keeps
#    the Fairies checkout tree untouched.
import sys
from pathlib import Path

FAIRIES = Path(__file__).resolve().parents[2] / "tools" / "fairies"
sys.path.insert(0, str(FAIRIES))

import openai_common  # noqa: E402


def _no_upload(*args, **kwargs):
    # Must be None, not "": the reviewer checks  before
    # appending an input_file block.
    return None


def _no_delete(client, file_id, **kwargs):
    if not file_id:
        return


openai_common.upload_text_file = _no_upload
openai_common.delete_uploaded_file = _no_delete

import pr_review_wrapper  # noqa: E402

pr_review_wrapper.upload_text_file = _no_upload
pr_review_wrapper.delete_uploaded_file = _no_delete


def _no_source_bundle(*args, **kwargs):
    # The reviewer appends an input_file block for the source bundle
    # unconditionally once one exists; suppress it here. The model reads
    # sources through its container shell.
    return (None, [], [])


pr_review_wrapper.build_source_bundle = _no_source_bundle

try:
    from openai.resources.responses import Responses as _Responses
except ImportError:  # older SDK layouts
    from openai.resources.responses.responses import Responses as _Responses

_STATE = {}
_orig_create = _Responses.create


def _plain_items(items):
    out = []
    for it in items or []:
        if isinstance(it, str):
            # Ollama requires item objects; normalize bare prompt strings
            out.append({"role": "user", "content": it})
        elif isinstance(it, dict):
            out.append(it)
        else:
            try:
                out.append(it.model_dump(exclude_none=True))
            except Exception:
                out.append(it)
    return out


def _stateless_create(self, *, input=None, previous_response_id=None, **kw):
    if previous_response_id is not None:
        cached = _STATE.get(previous_response_id)
        if cached is not None:
            base_input, out_items = cached
            input = [*base_input, *out_items, *_plain_items(input)]
    resp = _orig_create(self, input=input, **kw)
    try:
        rid = getattr(resp, "id", None)
        if isinstance(rid, str) and rid:
            calls = [
                it.model_dump(exclude_none=True)
                for it in (resp.output or [])
                if getattr(it, "type", "") == "function_call"
            ]
            _STATE[rid] = (_plain_items(input), calls)
    except Exception:
        pass
    return resp


_Responses.create = _stateless_create

if __name__ == "__main__":
    sys.exit(pr_review_wrapper.main())
