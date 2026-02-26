# /train-model

Configure training loops, run experiments, resume from checkpoints, and profile bottlenecks.

## Trigger

`/train-model [action] [options]`

## Actions

- `configure` - Set up LightningModule or HuggingFace TrainingArguments with callbacks
- `run` - Launch training with logging, checkpointing, and early stopping
- `resume` - Resume interrupted training from last checkpoint
- `profile` - Find training bottlenecks (data loading, forward pass, backward pass)

## Examples

### configure — LightningModule with callbacks

```python
from pytorch_lightning.callbacks import ModelCheckpoint, EarlyStopping, LearningRateMonitor
import pytorch_lightning as pl

callbacks = [
    ModelCheckpoint(
        monitor="val_auroc",
        mode="max",
        save_top_k=3,
        save_last=True,
        dirpath="checkpoints/",
        filename="{epoch:02d}-{val_auroc:.4f}",
    ),
    EarlyStopping(
        monitor="val_auroc",
        mode="max",
        patience=10,
        min_delta=1e-4,
    ),
    LearningRateMonitor(logging_interval="step"),
]

trainer = pl.Trainer(
    max_epochs=100,
    gradient_clip_val=1.0,
    accumulate_grad_batches=4,  # effective batch = batch_size × 4
    precision="bf16-mixed",
    callbacks=callbacks,
    logger=pl.loggers.WandbLogger(project="my-model"),
    devices=1,
    accelerator="gpu",
)
```

### run — HuggingFace Trainer with warmup

```python
from transformers import TrainingArguments, Trainer, EarlyStoppingCallback

args = TrainingArguments(
    output_dir="outputs/",
    num_train_epochs=20,
    per_device_train_batch_size=32,
    gradient_accumulation_steps=2,
    learning_rate=3e-4,
    warmup_ratio=0.06,
    lr_scheduler_type="cosine",
    weight_decay=0.01,
    evaluation_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
    metric_for_best_model="f1",
    greater_is_better=True,
    bf16=True,
    report_to=["wandb"],
)

trainer = Trainer(
    model=model,
    args=args,
    train_dataset=train_dataset,
    eval_dataset=val_dataset,
    compute_metrics=compute_metrics,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=5)],
)
trainer.train()
```

### resume — Resume from last checkpoint

```python
# HuggingFace Trainer
from transformers import TrainerState
import os

checkpoint_dirs = [
    os.path.join("outputs", d) for d in os.listdir("outputs")
    if d.startswith("checkpoint-")
]
last_checkpoint = max(checkpoint_dirs, key=os.path.getmtime) if checkpoint_dirs else None

if last_checkpoint:
    print(f"Resuming from {last_checkpoint}")
    trainer.train(resume_from_checkpoint=last_checkpoint)
else:
    trainer.train()

# PyTorch Lightning auto-resume
trainer = pl.Trainer(...)
ckpt_path = "checkpoints/last.ckpt"
trainer.fit(model, datamodule=dm,
            ckpt_path=ckpt_path if os.path.exists(ckpt_path) else None)
```

### profile — Find bottlenecks

```python
import torch
from torch.profiler import profile, record_function, ProfilerActivity, schedule

with profile(
    activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
    schedule=schedule(wait=1, warmup=1, active=5, repeat=2),
    on_trace_ready=torch.profiler.tensorboard_trace_handler("./profiler_logs"),
    record_shapes=True,
    profile_memory=True,
    with_stack=True,
) as prof:
    for step, batch in enumerate(train_loader):
        with record_function("data_to_gpu"):
            x, y = batch[0].cuda(non_blocking=True), batch[1].cuda(non_blocking=True)
        with record_function("forward"):
            loss = model(x, y)
        with record_function("backward"):
            loss.backward()
        optimizer.step()
        optimizer.zero_grad()
        prof.step()
        if step >= 20:
            break

# Summarize top CUDA operations
print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=15))

# Launch TensorBoard: tensorboard --logdir ./profiler_logs
```

## Options

- `--max-epochs <n>` - Maximum training epochs (default: 100)
- `--lr <float>` - Peak learning rate (default: 1e-3)
- `--warmup-ratio <float>` - Warmup proportion of total steps (default: 0.06)
- `--batch-size <n>` - Per-device batch size
- `--grad-accum <n>` - Gradient accumulation steps
- `--grad-clip <float>` - Gradient clipping max norm (default: 1.0)
- `--precision <str>` - Training precision: 32, 16, bf16-mixed (default: bf16-mixed)
- `--patience <n>` - Early stopping patience in epochs (default: 10)
- `--checkpoint-dir <path>` - Directory for checkpoint files
- `--resume-from <path>` - Checkpoint path to resume from
