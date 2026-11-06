#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
if [[ "$DRY_RUN" != 1 && "$(uname -s)" != Linux ]]; then
  die 'Run setup on the Linux DGX Spark. On your Mac, use scripts/tunnel.sh.'
fi
run sudo apt update
run sudo apt install -y git curl build-essential tmux python3.12-dev \
  libgl1-mesa-dev libx11-dev libxcursor-dev libxi-dev libxinerama-dev libxrandr-dev
if ! command -v uv >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == 1 ]]; then
    printf 'Install uv from https://docs.astral.sh/uv/getting-started/installation/\n'
  else
    need curl
    uv_installer="$(mktemp)"
    trap 'rm -f "$uv_installer"' EXIT
    curl --fail --location --silent --show-error https://astral.sh/uv/install.sh -o "$uv_installer"
    sh "$uv_installer"
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi
if [[ ! -e "$ISAACLAB_DIR" ]]; then
  run mkdir -p "$(dirname "$ISAACLAB_DIR")"
  run git clone --branch "$ISAACLAB_REF" https://github.com/isaac-sim/IsaacLab.git "$ISAACLAB_DIR"
else
  printf 'Using existing checkout: %s (no pull or checkout performed)\n' "$ISAACLAB_DIR"
fi
use_isaaclab
run uv sync
if [[ "$DRY_RUN" != 1 ]]; then
  mkdir -p "$REPO_DIR/artifacts"
  git rev-parse HEAD > "$REPO_DIR/artifacts/isaaclab-commit.txt"
fi
printf 'Next: scripts/check.sh, then scripts/smoke.sh\n'
