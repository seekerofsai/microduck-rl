# Microduck RL on DGX Spark

Shell scripts for the Isaac Lab / Newton / RSL-RL Microduck workflow used in this chat.
Training runs on the Spark; the Mac can forward TensorBoard and Viser ports.
These wrappers use the task implementations in your existing Isaac Lab checkout.
They do not vendor or replace `flat_env_cfg.py`, modify rewards, or move existing logs.

## Configure

```bash
cd ~/repos/microduck-rl
cp .env.example .env
# Edit .env if your paths or hosts differ.
```

Defaults: Isaac Lab at `~/robotics/IsaacLab`, rough terrain, backlash preset,
4096 training environments, 50,000 iterations, and one duck in Viser playback.
Shell environment variables override defaults; values explicitly set in `.env`
override shell environment variables. To use per-command overrides, leave those
keys unset/commented in `.env`, or edit `.env` directly. Use an absolute path for
`ISAACLAB_DIR` or use `$HOME` inside double quotes; a quoted `~` is not expanded.

To copy this local repo from your Mac to the Spark (before configuring it there):

```bash
ssh user@spark 'mkdir -p ~/repos'
scp -r ~/repos/microduck-rl user@spark:~/repos/
```

## Setup and training — run on the Spark

If Isaac Lab is already installed and your previous run works, skip `setup.sh`.
It installs system prerequisites, installs uv if needed, and syncs dependencies.
It uses an existing checkout without pulling updates or changing its revision.
For a fresh checkout it clones `ISAACLAB_REF` (default `main`); set a known branch
or tag to reproduce a particular installation. The installed checkout's commit
is recorded under `artifacts/isaaclab-commit.txt` after setup.

```bash
./scripts/setup.sh
./scripts/check.sh
./scripts/smoke.sh
tmux new -s microduck
./scripts/train.sh
```

Detach tmux with Ctrl+B, then D. Reattach with `tmux attach -t microduck`.
Initial Warp compilation can take time. The smoke run checks the pipeline;
50 iterations do not train a finished policy. Training is headless by default.
If memory or throughput is a problem, try 2048 or 1024 environments. Fewer
environments collect fewer samples per iteration, so budgets are not equivalent.

`train.sh` accepts additional Isaac Lab arguments. To resume a chosen checkpoint:

```bash
./scripts/train.sh --checkpoint /absolute/path/to/model_25000.pt
```

The runner uses the configured iteration count for the resumed learning call;
do not assume `MAX_ITERATIONS` is a stop-at-total counter. Choose the additional
budget you intend and inspect the runner's startup output. Absolute checkpoint
paths avoid accidentally selecting a different run with `latest`.

## Monitor — run on the Spark

```bash
./scripts/tensorboard.sh
```

Logs and checkpoints remain under `~/robotics/IsaacLab/logs/rsl_rl/` by default.
Useful tags: `Train/mean_reward`, `Train/mean_episode_length`,
`Curriculum/terrain_levels/mean`, `Episode_Termination/fell_over`,
`Episode_Termination/nan_state`, and `Metrics/base_velocity/*`.
Reward and logged success metrics are not a hardware-readiness test.

## Playback and ONNX export — run on the Spark

```bash
./scripts/play.sh
./scripts/list-exports.sh
```

Playback uses `uv run --extra viser isaaclab play ...`. The position of
`--extra viser` matters: it is a uv option and must precede `isaaclab`.
RSL-RL playback automatically exports `policy.onnx` and `policy.pt` to the
selected checkpoint's `exported/` directory. Stop playback with Ctrl+C before
running the second command, or use another terminal. Set `CHECKPOINT` in `.env`
to an absolute checkpoint path for a specific run. Relative paths are resolved
from the Isaac Lab checkout. `latest` selects the latest compatible run.

Set `VIEWER=newton_gl` for the Spark desktop, `VIEWER=none` for headless playback,
or increase `PLAY_NUM_ENVS` for multiple ducks. In Viser, scroll over the 3D
scene to zoom and drag empty space with the left mouse button to orbit.

## View remotely — run on your Mac

Start TensorBoard/playback on the Spark, then leave this Mac command running:

```bash
./scripts/tunnel.sh
```

Open [TensorBoard](http://localhost:6006/) and [Viser](http://localhost:8080/).
`SPARK_HOST` defaults to `spark`. The tunnel forwards both ports;
each service still needs to be started on the Spark. `VIEWER_PORT` sets the
tunnel destination, not Viser's server configuration; Viser defaults to 8080.
If the tunnel says a local port is occupied, use your existing tunnel or stop it
before starting a replacement.

## Copy a validated policy to the physical robot

Set `ROBOT_HOST` in `.env`, then run on the machine holding the ONNX file:

```bash
./scripts/copy-policy.sh /absolute/path/to/exported/policy.onnx
```

The script only copies the file. Check the policy's 61-observation / 14-action
interface, joint order, normalization, and action scaling against the robot's
runtime. Support the robot on its stand before the first load. On the robot:

```bash
robotctl policy list
sudo robotctl policy load walk /home/microduck/my_walking.onnx
robotctl monitor
# Restore the default policy if needed:
sudo robotctl policy reset walk
```

Loading while the robot is walking can resume motion after the home pose.

## Preview commands without running training

```bash
DRY_RUN=1 ./scripts/train.sh
DRY_RUN=1 ./scripts/play.sh
```

The previews work on macOS without Isaac Lab or a GPU. Do not run setup or
GPU training on the Mac. Local wrapper checks do not validate Spark packages,
CUDA execution, policy quality, or robot behavior.

## References

- [Original NVIDIA / Hugging Face Microduck tutorial](https://huggingface.co/blog/nvidia/microduck-isaac-lab-sim-to-real)
- [Isaac Lab installation and DGX Spark requirements](https://isaac-sim.github.io/IsaacLab/main/source/isaaclab/installation.html)
- [Microduck flat environment configuration](https://github.com/isaac-sim/IsaacLab/blob/main/source/isaaclab_tasks/isaaclab_tasks/contrib/microduck/flat_env_cfg.py)
- [Microduck PPO configuration](https://github.com/isaac-sim/IsaacLab/blob/main/source/isaaclab_tasks/isaaclab_tasks/contrib/microduck/agents/rsl_rl_ppo_cfg.py)
- [RSL-RL playback and export](https://github.com/isaac-sim/IsaacLab/blob/main/source/isaaclab_rl/isaaclab_rl/entrypoints/backends/play_rsl_rl.py)
- [Microduck robot controls and policy loading](https://github.com/pollen-robotics/microduck/blob/main/docs/robot/cheatsheet.md)

Training uses the upstream CUDA 13 PyTorch / Newton installation for Linux ARM64.
The repository contains launch scripts, not an Isaac Lab installation or trained
weights. Dependencies follow the Isaac Lab checkout and its lockfile.
