#!/bin/bash
# The only sanctioned entry point for a local-only fairy review.
#
# Comms posture (operator ruling 2026-08-22: nothing may reach real
# FFmpeg infrastructure):
#   - the review containers run on an --internal podman network: no NAT
#     gateway, no route out, by construction (created by ensure-inert.sh);
#   - this process's HTTP(S) egress is forced through the allowlist proxy
#     (scripts/fairy/allowlist-proxy.py), which permits ollama.com only;
#   - ssh targets 127.0.0.1:2222 only (the fairylocal alias);
#   - gcli must NOT be installed (refuses to start otherwise);
#   - the posting daemons (agent.py / worker.py / fairy.py) are never
#     invoked; only pr_review_wrapper runs, via the inline-patch shim;
#   - --web-search off (also the default) is forced.
#
# Usage: run-local.sh <ticket.json> [extra pr_review_wrapper args]
set -eu
cd "$(dirname "$0")/../.."

PY="$HOME/.venvs/fairies/bin/python"
command -v gcli >/dev/null 2>&1 && { echo "REFUSING: gcli is installed"; exit 1; }

set -a; . ./.env; set +a
: "${OPENAI_BASE_URL:?}" ; : "${OPENAI_API_KEY:?}"
: "${MODEL:=openai:glm-5.2}"
: "${PODMAN_SSH:=fairylocal}"

if ! ss -tln 2>/dev/null | grep -q 15313; then
  echo ">> starting allowlist proxy"
  "$PY" scripts/fairy/allowlist-proxy.py & PROXY_PID=$!
  trap '[ -n "${PROXY_PID:-}" ] && kill "$PROXY_PID" 2>/dev/null || true' EXIT
  sleep 0.5
fi

export HTTP_PROXY=http://127.0.0.1:15313
export HTTPS_PROXY=http://127.0.0.1:15313
export ALL_PROXY=http://127.0.0.1:15313
export NO_PROXY=localhost,127.0.0.1
export GIT_TERMINAL_PROMPT=0

echo ">> local-only fairy review"
echo ">>   model:      $MODEL"
echo ">>   endpoint:   $OPENAI_BASE_URL (sole allowed egress)"
echo ">>   containers: --internal podman network fairy-isolated"
echo ">>   ssh:        $PODMAN_SSH (127.0.0.1:2222)"

TICKET="${1:?usage: run-local.sh <ticket.json> [wrapper args...]}"
shift

exec "$PY" scripts/fairy/wrapper.py \
  --task pr \
  --model "$MODEL" \
  --web-search off \
  --podman \
  --shell-host "$PODMAN_SSH" \
  --podman-network fairy-isolated \
  --repo-root software/ffmpeg/pgs9-9.0.1 \
  < "$TICKET" "$@"
