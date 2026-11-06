#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
use_isaaclab
run uv run isaaclab train --rl_library rsl_rl \
  --task IsaacContrib-Velocity-Flat-MicroDuck \
  --num_envs 64 --max_iterations 50 "presets=$PRESET" "$@"
