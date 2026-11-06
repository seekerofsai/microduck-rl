#!/usr/bin/env bash
# Copy only; policy activation is an explicit robotctl action on the robot.
source "$(dirname "$0")/common.sh"
[[ $# -eq 1 ]] || die 'Usage: scripts/copy-policy.sh /absolute/path/to/exported/policy.onnx'
[[ -f "$1" ]] || die "Policy file not found: $1"
[[ -n "${ROBOT_HOST:-}" ]] || die 'Set ROBOT_HOST to the robot hostname or IP.'
need scp
run scp "$1" "$ROBOT_USER@$ROBOT_HOST:/home/$ROBOT_USER/my_walking.onnx"
