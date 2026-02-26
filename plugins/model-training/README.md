# model-training

PyTorch Lightning LightningModule, HuggingFace Trainer, LR scheduling (cosine warmup), gradient clipping, checkpoint resume, early stopping, and profiling.

## What This Plugin Does

Covers the full training engineering lifecycle: structured LightningModule with torchmetrics integration, HuggingFace Trainer with custom compute_metrics, cosine warmup LR scheduling, LR finder for optimal initial rate selection, gradient norm monitoring and clipping, atomic checkpoint writes with full optimizer state, early stopping with min_delta to avoid noise-driven stops, and torch.profiler integration to find CPU/GPU bottlenecks.

## When to Use

- Structuring a PyTorch model as a LightningModule with validation metrics and optimizer config
- Setting up HuggingFace Trainer with warmup schedule and early stopping callback
- Using LR finder to pick the optimal learning rate before a long run
- Monitoring gradient norms per step to catch instability or vanishing gradients
- Writing atomic checkpoint saves and reliable resume logic for long-running jobs
- Profiling training to determine whether the bottleneck is data loading, forward pass, or backward pass

## Components

| Component | Description |
|-----------|-------------|
| `agents/training-engineer` | Expert in Lightning, HF Trainer, LR schedules, gradient health, checkpointing |
| `skills/training-patterns` | LightningModule, HF Trainer, LR finder, grad monitoring, checkpoint resume |
| `commands/train-model` | `/train-model configure\|run\|resume\|profile` workflows |

## Key Concepts

**Single-Batch Overfit Test**
Before launching any training run, verify the model can overfit a single batch to 0 loss. Takes 30 seconds. Catches loss function bugs, model architecture errors, and data pipeline issues before they waste GPU hours.

**Gradient Clipping**
Clip by global norm (`max_norm=1.0`), not by value. Value clipping distorts gradient directions. Norm clipping preserves direction while bounding magnitude. Essential for transformers, RNNs, and any network prone to gradient explosion.

**Checkpoint Atomicity**
Write checkpoint to `.tmp` file, then `os.rename()`. Rename is atomic on POSIX — a crash during write never corrupts the checkpoint. A corrupt checkpoint from a crash during direct write is unrecoverable.

**Warmup + Cosine Schedule**
Transformers trained with constant LR are consistently worse than with cosine warmup. Warmup (5-10% of steps) lets the optimizer build stable gradient statistics before the LR reaches its peak. Cosine decay provides smooth annealing without abrupt LR drops.

## Quick Start

```bash
pip install pytorch-lightning transformers torchmetrics wandb
```

```python
import pytorch_lightning as pl
trainer = pl.Trainer(max_epochs=50, gradient_clip_val=1.0, precision="bf16-mixed")
trainer.fit(model, datamodule=dm)
```
