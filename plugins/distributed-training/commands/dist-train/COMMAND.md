# /dist-train

Configure, launch, monitor, and debug distributed training jobs across multiple GPUs and nodes.

## Trigger

`/dist-train [action] [options]`

## Actions

- `configure` - Generate DDP/FSDP/DeepSpeed configuration for a given model and hardware setup
- `launch` - Generate torchrun/SLURM launch commands for a training job
- `monitor` - Interpret GPU utilization, loss curves, and communication metrics
- `debug` - Diagnose OOM errors, NCCL timeouts, and training instability

## Examples

### configure — DDP for single-node multi-GPU

```python
# Minimal DDP setup for classification model
import os
import torch
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP

def ddp_setup():
    dist.init_process_group(backend="nccl")
    torch.cuda.set_device(int(os.environ["LOCAL_RANK"]))

def ddp_cleanup():
    dist.destroy_process_group()

class Trainer:
    def __init__(self, model, train_loader, optimizer):
        self.rank = int(os.environ["LOCAL_RANK"])
        self.model = DDP(model.to(self.rank), device_ids=[self.rank])
        self.loader = train_loader
        self.optimizer = optimizer

    def train_epoch(self, epoch: int):
        self.loader.sampler.set_epoch(epoch)
        self.model.train()
        for x, y in self.loader:
            x, y = x.to(self.rank), y.to(self.rank)
            self.optimizer.zero_grad()
            loss = criterion(self.model(x), y)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), 1.0)
            self.optimizer.step()

    def save(self, path: str):
        if self.rank == 0:
            torch.save(self.model.module.state_dict(), path)
```

### configure — FSDP for large transformer

```python
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP, MixedPrecision
from torch.distributed.fsdp.wrap import transformer_auto_wrap_policy
import functools

# Replace MyTransformerBlock with your model's block class
wrap_policy = functools.partial(
    transformer_auto_wrap_policy,
    transformer_layer_cls={MyTransformerBlock}
)

model = FSDP(
    MyLargeModel(),
    auto_wrap_policy=wrap_policy,
    mixed_precision=MixedPrecision(
        param_dtype=torch.bfloat16,
        reduce_dtype=torch.float32,
    ),
    device_id=int(os.environ["LOCAL_RANK"]),
    use_orig_params=True,
)
```

### launch — torchrun commands

```bash
# Single node, 1 GPU (debugging)
torchrun --nproc_per_node=1 train.py

# Single node, all GPUs
torchrun --nproc_per_node=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l) train.py

# Single node, 8 GPUs, with fault tolerance
torchrun \
  --nproc_per_node=8 \
  --max_restarts=3 \
  --rdzv_backend=c10d \
  --rdzv_endpoint=localhost:29500 \
  train.py --batch_size 32

# Multi-node: 2 nodes, 8 GPUs each
# Run on node 0:
torchrun \
  --nproc_per_node=8 \
  --nnodes=2 \
  --node_rank=0 \
  --master_addr="10.0.0.1" \
  --master_port=29500 \
  train.py

# Run on node 1 (same command, node_rank=1):
torchrun \
  --nproc_per_node=8 \
  --nnodes=2 \
  --node_rank=1 \
  --master_addr="10.0.0.1" \
  --master_port=29500 \
  train.py
```

```bash
# SLURM multi-node launch
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --gres=gpu:8
#SBATCH --time=24:00:00

srun torchrun \
  --nproc_per_node=$SLURM_NTASKS_PER_NODE \
  --nnodes=$SLURM_NNODES \
  --node_rank=$SLURM_NODEID \
  --master_addr=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n1) \
  --master_port=29500 \
  train.py
```

### monitor — GPU and training metrics

```bash
# Watch GPU utilization across all GPUs
watch -n 1 nvidia-smi

# DCGM metrics for distributed training (NCCL throughput, PCIe usage)
dcgmi dmon -e 1001,1002,1003,1004

# Check NCCL communication stats
NCCL_DEBUG=INFO NCCL_DEBUG_SUBSYS=COLL torchrun --nproc_per_node=4 train.py 2>&1 | grep "NCCL"

# Profile with torch.profiler
import torch.profiler
with torch.profiler.profile(
    activities=[torch.profiler.ProfilerActivity.CPU, torch.profiler.ProfilerActivity.CUDA],
    schedule=torch.profiler.schedule(wait=1, warmup=1, active=3),
    on_trace_ready=torch.profiler.tensorboard_trace_handler('./profiler'),
    record_shapes=True,
    with_stack=True,
) as prof:
    for step, batch in enumerate(loader):
        train_step(batch)
        prof.step()
```

### debug — Common failure modes

```bash
# OOM: check memory math
# 7B model: 7e9 × 2 bytes (BF16) = 14 GB params alone
# + optimizer states (Adam): × 3 for ZeRO-0 = 42 GB per GPU
# Solution: Use FSDP/ZeRO-3, gradient checkpointing, smaller batch

# NCCL timeout
export NCCL_TIMEOUT=1800  # 30 min instead of default 10 min
export NCCL_ASYNC_ERROR_HANDLING=1

# Debug NCCL connectivity between nodes
python -c "
import torch.distributed as dist
import os
dist.init_process_group('nccl')
print(f'Rank {dist.get_rank()} of {dist.get_world_size()}: OK')
dist.destroy_process_group()
"

# Check if all ranks are alive
dist.barrier()  # all ranks must reach this; hangs if any rank is dead
```

## Options

- `--nproc_per_node <n>` - GPUs per node
- `--nnodes <n>` - Number of nodes
- `--strategy <ddp|fsdp|deepspeed>` - Parallelism strategy
- `--precision <bf16|fp16|fp32>` - Training precision
- `--zero-stage <0|1|2|3>` - DeepSpeed ZeRO stage
