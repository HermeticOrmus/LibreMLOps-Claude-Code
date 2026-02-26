# gpu-optimization

CUDA memory management, torch.compile, Nsight profiling, Flash Attention, and model quantization (GPTQ, AWQ, bitsandbytes).

## What This Plugin Does

Covers the systematic process of GPU optimization: profiling with torch.profiler and NVIDIA Nsight to find bottlenecks, applying torch.compile for kernel fusion, using mixed precision (BF16/FP16), computing GPU memory budgets, implementing gradient checkpointing, and quantizing models with bitsandbytes/GPTQ/AWQ for inference or QLoRA training.

## When to Use

- Diagnosing why training is slower than expected (compute vs memory bandwidth vs I/O bound)
- Reducing VRAM usage for a model that doesn't fit on available GPUs
- Applying torch.compile to a training or inference workload
- Loading a large LLM in 4-bit for inference on consumer hardware
- Profiling per-kernel GPU activity with Nsight Systems or Nsight Compute
- Computing Model FLOP Utilization (MFU) to assess training efficiency
- Choosing between BF16 and FP16 for a given GPU architecture

## Components

| Component | Description |
|-----------|-------------|
| `agents/gpu-optimizer` | Expert in CUDA memory, torch.compile, Nsight, Triton, Flash Attention, quantization |
| `skills/gpu-optimization-patterns` | Code patterns: memory budgeting, torch.compile, AMP, 4-bit quant, DataLoader tuning |
| `commands/gpu-optimize` | `/gpu-optimize profile\|quantize\|compile\|benchmark` workflows |

## Key Concepts

**Memory Math**
1B params × 2 bytes (BF16) = 2 GB. Adam adds 8 bytes/param. A 7B model needs ~84 GB GPU RAM to train from scratch in full precision. ZeRO-3 or FSDP distributes this across GPUs.

**torch.compile**
`torch.compile(model)` traces the forward pass and generates optimized CUDA kernels via TorchInductor. Typical speedup: 1.5–3x for transformers. Use `mode="max-autotune"` for inference throughput.

**BF16 vs FP16**
BF16 has the same dynamic range as FP32 (8 exponent bits). No loss scaling needed. Native hardware support on A100/H100. Use BF16 on Ampere+ always. Use FP16 + GradScaler on Volta/Turing.

**MFU (Model FLOP Utilization)**
`(actual TFLOPs) / (GPU peak TFLOPs)`. A100 FP16 peak = 312 TFLOP/s. Good LLM training runs at 35–50% MFU. Below 20% suggests data loading, communication, or kernel efficiency issues.

**Quantization**
4-bit NF4 (bitsandbytes): 7B model fits in ~3.5 GB vs 14 GB in FP16. Near-lossless for inference. Required for QLoRA fine-tuning on consumer GPUs.

## Quick Start

```bash
pip install torch bitsandbytes flash-attn transformers
```

```python
import torch
print(torch.cuda.memory_allocated() / 1e9, "GB")
model = torch.compile(model, mode="default")
```
