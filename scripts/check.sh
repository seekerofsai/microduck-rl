#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
use_isaaclab
run uname -m
run nvidia-smi
run uv run python -c 'import torch; print("Torch:", torch.__version__); print("CUDA:", torch.version.cuda); assert torch.cuda.is_available(), "CUDA unavailable"; print(torch.cuda.get_device_name(0)); print(torch.ones(1, device="cuda") + 1)'
run uv run isaaclab list_envs --keyword MicroDuck --show_presets
