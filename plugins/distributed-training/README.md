# distributed-training

Multi-GPU and multi-node training with PyTorch DDP, FSDP, DeepSpeed ZeRO, and Megatron-LM.

## What This Plugin Does

Covers the full distributed training stack: data parallel training (DDP), memory-efficient sharded training (FSDP, DeepSpeed ZeRO), model parallelism (Megatron-LM), NCCL communication backends, mixed precision (BF16/FP16), and gradient checkpointing. Provides launch configurations for torchrun and SLURM.

## When to Use

- Scaling training from 1 GPU to multi-GPU (DDP setup)
- Training models too large for a single GPU (FSDP, DeepSpeed ZeRO-3)
- Configuring mixed precision (BF16 on A100/H100, FP16 + GradScaler on Volta)
- Writing launch scripts for torchrun (single-node) or SLURM (multi-node)
- Debugging OOM errors, NCCL timeouts, and training instability
- Understanding memory math: params × dtype × ZeRO stage savings
- Applying gradient checkpointing to reduce activation memory

## Components

| Component | Description |
|-----------|-------------|
| `agents/distributed-training-engineer` | Expert in DDP, FSDP, DeepSpeed, NCCL, Megatron-LM |
| `skills/distributed-training-patterns` | Code patterns: DDP loop, FSDP wrap policy, ZeRO-3 config, AMP, grad checkpointing |
| `commands/dist-train` | `/dist-train configure\|launch\|monitor\|debug` workflows |

## Key Concepts

**Strategy Selection**
- Model fits on one GPU → DDP (simplest, scales linearly)
- Model too large for one GPU → FSDP or DeepSpeed ZeRO-3
- 100B+ parameters → 3D parallelism (TP × PP × DP) via Megatron-LM

**Memory Math**
A 7B parameter model in BF16: 7×10^9 × 2 bytes = 14 GB for parameters alone. Adam optimizer states add 8 bytes/param (2 float32 states). ZeRO-3 with 8 GPUs: 14 GB / 8 = 1.75 GB params per GPU.

**BF16 vs FP16**
BF16 has the same 8-bit exponent as FP32 (handles large/small values without loss scaling). FP16 has 5-bit exponent and requires `GradScaler`. Use BF16 on A100/H100, FP16 on older GPUs.

**Gradient Checkpointing**
Recomputes activations during backward pass instead of storing them. Saves ~80% activation memory at cost of ~33% extra compute. Essential for long-context transformer training.

## Quick Start

```bash
# Install requirements
pip install torch torchvision deepspeed

# Single-node 4-GPU DDP run
torchrun --nproc_per_node=4 train.py

# Check GPU memory
nvidia-smi --query-gpu=memory.used,memory.total --format=csv
```
