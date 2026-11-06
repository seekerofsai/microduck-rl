#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
use_isaaclab
run uv run python -m tensorboard.main --logdir logs/rsl_rl \
  --host 127.0.0.1 --port "$TENSORBOARD_PORT" "$@"
