#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
need ssh
printf 'TensorBoard: http://localhost:%s\nViser: http://localhost:%s\n' "$TENSORBOARD_PORT" "$VIEWER_PORT"
run ssh -N -o ExitOnForwardFailure=yes \
  -L "$TENSORBOARD_PORT:localhost:$TENSORBOARD_PORT" \
  -L "$VIEWER_PORT:localhost:$VIEWER_PORT" "$SPARK_HOST" "$@"
