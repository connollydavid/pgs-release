#!/bin/bash
# Fairies-on-Ollama smoke test: verifies the endpoint capabilities the
# openai: reviewer path depends on, before any review run.
#
# Usage: smoke.sh   (reads OPENAI_API_KEY + OPENAI_BASE_URL from env/.env)
set -u
cd "$(dirname "$0")/../.." || exit 9
[ -f .env ] && set -a && . ./.env && set +a
PY="${FAIRIES_PYTHON:-$HOME/.venvs/fairies/bin/python}"
: "${OPENAI_API_KEY:?set OPENAI_API_KEY (the Ollama key)}"
: "${OPENAI_BASE_URL:?set OPENAI_BASE_URL (https://api.ollama.com/v1)}"
MODEL="${MODEL:-openai:deepseek-v4-flash}"
M="${MODEL#openai:}"

"$PY" - "$M" <<'EOF'
import os, sys, json
model = sys.argv[1]
base = os.environ["OPENAI_BASE_URL"].rstrip("/")
key = os.environ["OPENAI_API_KEY"]

def check(name, fn):
    try:
        out = fn()
        print(f"PASS {name}: {out}")
        return True
    except Exception as e:
        print(f"FAIL {name}: {type(e).__name__}: {str(e)[:200]}")
        return False

from openai import OpenAI
client = OpenAI(base_url=base, api_key=key)

def auth():
    models = [m.id for m in client.models.list()]
    have = [m for m in models if model in m or m.startswith(model)]
    if not have:
        raise SystemExit(f"model {model!r} not in catalog: {models[:8]}...")
    return f"auth ok, {len(models)} models, {have[0]} present"

def text_round():
    r = client.responses.create(model=model, input="Reply with exactly: OK")
    return (r.output_text or "").strip()[:40]

def tool_round():
    tools = [{"type": "function", "name": "grep_repo",
              "description": "search the repo",
              "parameters": {"type": "object",
                             "properties": {"pattern": {"type": "string"}},
                             "required": ["pattern"]}}]
    r = client.responses.create(
        model=model, tools=tools,
        input="Use the grep_repo tool with pattern 'pgssub'. Reply with the tool call only.")
    for item in r.output:
        if getattr(item, "type", "") == "function_call":
            return f"function_call issued: {item.name}"
    return "no tool call (model declined; try again or pick another model)"

def files_api():
    f = client.files.create(file=("t.txt", b"hello"), purpose="assistants")
    return f"files API EXISTS (id {f.id}) - inline fallback not needed"

ok = True
ok &= check("auth+catalog", auth)
ok &= check("responses text", text_round)
ok &= check("responses tool-call", tool_round)
# informational: expected to fail on Ollama (no files API) - that is the
# seam pr_review_wrapper.py:1491 needs the inline fallback for.
check("files upload (informational)", files_api)
sys.exit(0 if ok else 1)
EOF
