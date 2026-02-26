# pytorch-patterns

Custom Dataset/DataLoader with weighted sampling, nn.Module design with proper initialization, model surgery for fine-tuning, custom autograd functions, and torch.profiler bottleneck analysis.

## What This Plugin Does

Covers production PyTorch: custom Dataset classes with albumentations transforms, efficient DataLoader configuration (pin_memory, persistent_workers, prefetch_factor), WeightedRandomSampler for class imbalance, nn.Module with proper weight initialization and buffer registration, ResNet/ViT model surgery for fine-tuning (freeze backbone, replace head, progressive unfreeze), custom torch.autograd.Function with correct backward passes, and torch.profiler for identifying whether bottlenecks are in data loading, forward pass, or backward pass.

## When to Use

- Writing a custom Dataset for image/tabular/text data with augmentation pipeline
- Configuring DataLoader workers, pin_memory, and prefetch for maximum GPU utilization
- Replacing a pretrained model's classifier head for fine-tuning on a new task
- Progressively unfreezing backbone layers as training stabilizes
- Implementing a custom backward pass with torch.autograd.Function
- Profiling a training step to find where GPU time is actually spent
- Diagnosing low GPU utilization (usually a DataLoader bottleneck)

## Components

| Component | Description |
|-----------|-------------|
| `agents/pytorch-engineer` | Expert in Dataset, DataLoader, nn.Module, model surgery, autograd, profiling |
| `skills/pytorch-patterns` | Custom Dataset, weighted sampler, nn.Module init, model surgery, autograd Function, profiler |
| `commands/pytorch` | `/pytorch dataset\|model\|train\|profile` workflows |

## Key Concepts

**pin_memory + non_blocking**
`DataLoader(pin_memory=True)` allocates pinned (page-locked) host memory for batches. `.to(device, non_blocking=True)` then initiates async DMA transfer — the CPU continues while the GPU receives data. Together, these eliminate the H→D copy sync point in the training loop.

**Model Surgery**
Fine-tuning = load pretrained weights → freeze backbone → replace head → train head only → optionally unfreeze backbone layers progressively. Always compute trainable parameter count before starting. For ResNet50: total 25M params, head ~2M. Training only 2M is 10x faster per epoch.

**Custom Autograd Functions**
Use when: (1) you need a non-differentiable operation made differentiable with a custom approximation, (2) PyTorch's autograd computes an inefficient gradient, (3) you're integrating a Triton or CUDA kernel. Always run `torch.autograd.gradcheck` to verify correctness.

**DataLoader Bottleneck Diagnosis**
GPU utilization < 80% with default DataLoader settings: set `num_workers=8`, `pin_memory=True`, `persistent_workers=True`. Still low: profile with torch.profiler; if "DataLoader" appears in top CPU ops, reduce transform complexity or use a faster image library (libjpeg-turbo, NVJPEG).

## Quick Start

```bash
pip install torch torchvision albumentations
```

```python
from torch.utils.data import DataLoader
loader = DataLoader(dataset, batch_size=64, num_workers=8,
                    pin_memory=True, persistent_workers=True)
```
