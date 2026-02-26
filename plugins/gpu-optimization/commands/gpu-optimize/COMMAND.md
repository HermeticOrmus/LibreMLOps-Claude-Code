# /gpu-optimize

Profile, quantize, compile, and benchmark GPU workloads for maximum throughput and minimum memory.

## Trigger

`/gpu-optimize [action] [options]`

## Actions

- `profile` - Generate profiling code and interpret bottlenecks
- `quantize` - Apply bitsandbytes/GPTQ/AWQ quantization to reduce memory
- `compile` - Apply torch.compile with appropriate mode
- `benchmark` - Measure throughput before and after optimizations

## Examples

### profile — Torch profiler setup

```python
import torch
from torch.profiler import profile, ProfilerActivity, record_function

model = model.cuda().train()
optimizer = torch.optim.AdamW(model.parameters())

with profile(
    activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
    schedule=torch.profiler.schedule(wait=2, warmup=2, active=5),
    on_trace_ready=torch.profiler.tensorboard_trace_handler('./runs/profile'),
    record_shapes=True,
    profile_memory=True,
) as prof:
    for step, (x, y) in enumerate(loader):
        if step >= 9: break
        x, y = x.cuda(), y.cuda()
        loss = criterion(model(x), y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        prof.step()

# View in TensorBoard
# tensorboard --logdir ./runs/profile
# Key metrics: cuda_time_total, memory_usage, top self_cuda_time kernels
print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=10))
```

```bash
# NVIDIA Nsight Systems (timeline profiling)
nsys profile \
  --trace cuda,nvtx,osrt,cudnn \
  --output profile_output \
  python train.py

nsys-ui profile_output.nsys-rep  # open in GUI

# NVIDIA Nsight Compute (per-kernel metrics)
ncu \
  --target-processes all \
  --metrics "sm__throughput.avg.pct_of_peak_sustained_elapsed,dram__throughput.avg.pct_of_peak_sustained_elapsed" \
  --launch-count 5 \
  python train.py
```

### quantize — 4-bit model loading

```python
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
import torch

# NF4 double quantization (best quality at 4-bit)
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,
)

model = AutoModelForCausalLM.from_pretrained(
    "model_id",
    quantization_config=bnb_config,
    device_map="auto",
)

# Memory comparison:
# 7B FP16: ~14 GB  →  7B NF4: ~3.5 GB
# 13B FP16: ~26 GB  →  13B NF4: ~6.5 GB
# 70B FP16: ~140 GB  →  70B NF4: ~35 GB (fits 2× A100 80GB)
```

```bash
# GPTQ quantization (offline, requires calibration data)
pip install auto-gptq
python -c "
from auto_gptq import AutoGPTQForCausalLM, BaseQuantizeConfig
from transformers import AutoTokenizer
import torch

quantize_config = BaseQuantizeConfig(bits=4, group_size=128, desc_act=False)
model = AutoGPTQForCausalLM.from_pretrained('model_id', quantize_config=quantize_config)
tokenizer = AutoTokenizer.from_pretrained('model_id')

# Calibration data (128 random samples from C4 or wikitext)
examples = [tokenizer(text, return_tensors='pt') for text in calibration_texts[:128]]
model.quantize(examples)
model.save_quantized('model_gptq_4bit')
"
```

### compile — Apply and benchmark

```python
import torch
import time

def benchmark(model, input_tensor, n_iters=50, warmup=10):
    """Benchmark throughput with CUDA synchronization."""
    with torch.no_grad():
        for _ in range(warmup):
            _ = model(input_tensor)
        torch.cuda.synchronize()

        start = time.perf_counter()
        for _ in range(n_iters):
            _ = model(input_tensor)
        torch.cuda.synchronize()

    return (time.perf_counter() - start) / n_iters * 1000  # ms

model = MyModel().cuda().eval()
x = torch.randn(32, 512, device='cuda')

# Baseline
eager_ms = benchmark(model, x)

# Compiled
compiled = torch.compile(model, mode="max-autotune")
compiled_ms = benchmark(compiled, x)  # first call compiles

print(f"Eager:    {eager_ms:.2f} ms/iter")
print(f"Compiled: {compiled_ms:.2f} ms/iter")
print(f"Speedup:  {eager_ms/compiled_ms:.2f}x")
```

### benchmark — Memory and throughput report

```python
import torch

def full_memory_report():
    """Print current and peak GPU memory stats."""
    allocated = torch.cuda.memory_allocated() / 1e9
    reserved  = torch.cuda.memory_reserved() / 1e9
    peak_alloc = torch.cuda.max_memory_allocated() / 1e9
    total = torch.cuda.get_device_properties(0).total_memory / 1e9

    print(f"GPU Memory Report:")
    print(f"  Allocated: {allocated:.2f} GB")
    print(f"  Reserved:  {reserved:.2f} GB")
    print(f"  Peak:      {peak_alloc:.2f} GB")
    print(f"  Total:     {total:.2f} GB")
    print(f"  Util:      {peak_alloc/total*100:.1f}%")

def compute_mfu(model_flops_per_token: float, tokens_per_sec: float,
                 gpu_peak_flops: float = 312e12) -> float:
    """Model FLOP Utilization. A100 FP16 peak = 312 TFLOPs."""
    return model_flops_per_token * tokens_per_sec / gpu_peak_flops

# Llama-7B: ~14 TFLOPs/token (6 × num_params)
# 1000 tokens/sec on 1× A100:
mfu = compute_mfu(14e12, 1000, 312e12)
print(f"MFU: {mfu:.1%}")  # aim for 35-50% for LLM training
```

## Options

- `--model-path <path>` - Path to model for quantization or compilation
- `--dtype <bf16|fp16|fp32|int8|int4>` - Target precision
- `--compile-mode <default|reduce-overhead|max-autotune>` - torch.compile mode
- `--batch-size <n>` - Batch size for benchmarking
- `--profile-steps <n>` - Number of steps to profile (default: 5)
- `--quant-method <bnb|gptq|awq>` - Quantization method
