#!/usr/bin/env bash
# Shared by entrypoints; all paths and arguments remain separate shell words.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$REPO_DIR/.env" ]]; then
  source "$REPO_DIR/.env"
fi
: "${ISAACLAB_DIR:=$HOME/robotics/IsaacLab}"
: "${ISAACLAB_REF:=main}"
: "${TASK:=IsaacContrib-Velocity-Rough-MicroDuck}"
: "${PRESET:=backlash}"
: "${NUM_ENVS:=4096}"
: "${MAX_ITERATIONS:=50000}"
: "${CHECKPOINT:=latest}"
: "${PLAY_NUM_ENVS:=1}"
: "${VIEWER:=viser}"
: "${TENSORBOARD_PORT:=6006}"
: "${VIEWER_PORT:=8080}"
: "${SPARK_HOST:=saiseeker@spark-c64c}"
: "${ROBOT_USER:=microduck}"
: "${DRY_RUN:=0}"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }
run() {
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}
use_isaaclab() {
  if [[ "$DRY_RUN" == 1 ]]; then
    printf 'Working directory: %s\n' "$ISAACLAB_DIR"
    return
  fi
  need uv
  [[ -f "$ISAACLAB_DIR/pyproject.toml" ]] || die "Isaac Lab checkout missing at $ISAACLAB_DIR; run scripts/setup.sh on the Spark."
  cd "$ISAACLAB_DIR"
}
