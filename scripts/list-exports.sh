#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
use_isaaclab
run find logs/rsl_rl -path '*/exported/policy.onnx' -print
