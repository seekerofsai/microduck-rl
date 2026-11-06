#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
use_isaaclab
run uv run isaaclab train --rl_library rsl_rl \
  --task "$TASK" --num_envs "$NUM_ENVS" \
  --max_iterations "$MAX_ITERATIONS" "presets=$PRESET" "$@"
