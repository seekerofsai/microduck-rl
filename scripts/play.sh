#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
use_isaaclab
# --extra belongs to uv, before the isaaclab command.
uv_args=(run)
viz_args=()
case "$VIEWER" in
  viser) uv_args+=(--extra viser); viz_args=(--viz viser) ;;
  newton_gl) viz_args=(--viz newton_gl) ;;
  none) ;;
  *) die "VIEWER must be viser, newton_gl, or none (received $VIEWER)" ;;
esac
run uv "${uv_args[@]}" isaaclab play --rl_library rsl_rl \
  --task "$TASK" --checkpoint "$CHECKPOINT" --num_envs "$PLAY_NUM_ENVS" \
  ${viz_args[@]+"${viz_args[@]}"} "presets=$PRESET" "$@"
