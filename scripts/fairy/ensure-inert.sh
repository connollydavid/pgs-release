#!/bin/bash
# Establish the inert-comms posture on the fairylocal podman host:
# an --internal network (no NAT gateway -> containers have no route out)
# that fairies adopts because it already exists (podman_host.py only
# creates the network when missing, and its plain create would NAT).
# Then verify isolation empirically: a container on the network must not
# reach anything.
set -eu
NET=fairy-isolated

if ! ssh -o BatchMode=yes fairylocal "podman network exists $NET"; then
  ssh -o BatchMode=yes fairylocal "podman network create --internal $NET"
  echo "created --internal network $NET"
else
  echo "network $NET already exists"
fi

echo "=== network inspect (internal must be true) ==="
ssh -o BatchMode=yes fairylocal "podman network inspect $NET --format 'internal={{.Internal}} driver={{.Driver}}'"

echo "=== empirical isolation test: container must NOT reach the internet ==="
ssh -o BatchMode=yes fairylocal "podman run --rm --network $NET quay.io/libpod/alpine:latest \
  sh -c 'wget -q -T 5 -O /dev/null https://ollama.com && echo LEAK || echo NO-EGRESS'" 2>&1 | tail -1
