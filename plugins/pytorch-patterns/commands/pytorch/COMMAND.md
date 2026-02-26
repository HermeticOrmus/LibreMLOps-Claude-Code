# /pytorch

Build custom datasets, design nn.Modules, perform model surgery for fine-tuning, and profile training pipelines.

## Trigger

`/pytorch [action] [options]`

## Actions

- `dataset` - Build custom Dataset and DataLoader with transforms and sampling
- `model` - Design nn.Module with proper initialization and buffer registration
- `train` - Complete training loop with gradient clipping, logging, and eval toggle
- `profile` - Find bottlenecks in data pipeline or model forward/backward

## Examples

### dataset — Custom Dataset with efficient DataLoader

```python
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import torch

class TabularDataset(Dataset):
    def __init__(self, df: pd.DataFrame, feature_cols: list, label_col: str):
        self.X = torch.tensor(df[feature_cols].values, dtype=torch.float32)
        self.y = torch.tensor(df[label_col].values, dtype=torch.long)

    def __len__(self) -> int:
        return len(self.X)

    def __getitem__(self, idx: int):
        return self.X[idx], self.y[idx]

dataset = TabularDataset(df, feature_cols=FEATURES, label_col="label")
loader = DataLoader(
    dataset,
    batch_size=512,
    shuffle=True,
    num_workers=4,
    pin_memory=True,
    persistent_workers=True,
)
```

### model — ResNet fine-tuning with frozen backbone

```python
import torchvision.models as models
import torch.nn as nn

model = models.resnet50(weights=models.ResNet50_Weights.IMAGENET1K_V2)

# Freeze backbone
for param in model.parameters():
    param.requires_grad = False

# Replace classifier head (unfrozen)
model.fc = nn.Sequential(
    nn.Dropout(0.3),
    nn.Linear(model.fc.in_features, num_classes),
)

# Optimizer: only head params
optimizer = torch.optim.AdamW(
    [p for p in model.parameters() if p.requires_grad],
    lr=1e-3, weight_decay=1e-4,
)

# Count trainable
trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
total = sum(p.numel() for p in model.parameters())
print(f"Trainable: {trainable:,}/{total:,} ({trainable/total:.1%})")
```

### train — Complete training loop

```python
import torch
import torch.nn as nn

def train_epoch(model, loader, optimizer, scheduler, device, grad_clip=1.0):
    model.train()
    total_loss = 0.0
    criterion = nn.CrossEntropyLoss()

    for batch_idx, (x, y) in enumerate(loader):
        x = x.to(device, non_blocking=True)
        y = y.to(device, non_blocking=True)

        optimizer.zero_grad(set_to_none=True)  # faster than zero_grad()
        logits = model(x)
        loss = criterion(logits, y)
        loss.backward()

        # Gradient clipping
        nn.utils.clip_grad_norm_(model.parameters(), max_norm=grad_clip)

        optimizer.step()
        scheduler.step()

        total_loss += loss.item()  # .item() only once per batch

    return total_loss / len(loader)

@torch.no_grad()
def eval_epoch(model, loader, device):
    model.eval()
    correct = total = 0
    for x, y in loader:
        x, y = x.to(device), y.to(device)
        pred = model(x).argmax(dim=1)
        correct += (pred == y).sum().item()
        total += len(y)
    return correct / total
```

### profile — torch.profiler to find bottlenecks

```python
from torch.profiler import profile, ProfilerActivity, schedule, tensorboard_trace_handler

with profile(
    activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
    schedule=schedule(wait=1, warmup=2, active=5),
    on_trace_ready=tensorboard_trace_handler("./profiler_logs"),
    record_shapes=True,
    profile_memory=True,
) as prof:
    for step, (x, y) in enumerate(train_loader):
        x = x.cuda(non_blocking=True)
        y = y.cuda(non_blocking=True)
        optimizer.zero_grad()
        loss = model(x, y)
        loss.backward()
        optimizer.step()
        prof.step()
        if step >= 10:
            break

# Print top CUDA ops
print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=10))

# TensorBoard: tensorboard --logdir ./profiler_logs
# If CUDA idle > 30%: data loading is the bottleneck → increase num_workers
```

## Options

- `--batch-size <n>` - DataLoader batch size (default: 64)
- `--num-workers <n>` - DataLoader worker processes (default: 4)
- `--pin-memory` - Enable pin_memory for async H→D transfer (default: true with GPU)
- `--freeze-backbone` - Freeze pretrained backbone layers (model action)
- `--grad-clip <float>` - Gradient clipping max norm (default: 1.0)
- `--device <str>` - Training device: cuda, cpu, mps (default: auto-detect)
- `--profile-steps <n>` - Number of steps to profile (default: 10)
- `--compile` - Apply torch.compile after model definition
