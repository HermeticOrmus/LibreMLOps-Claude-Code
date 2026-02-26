# llm-fine-tuning

LoRA, QLoRA, instruction tuning, DPO alignment, and LLM evaluation with PEFT, trl, and lm-evaluation-harness.

## What This Plugin Does

Covers the complete LLM fine-tuning workflow: LoRA rank/alpha selection, QLoRA 4-bit setup with bitsandbytes, instruction dataset formatting (Alpaca, ChatML, ShareGPT), correct label masking for causal LM training, DPO vs PPO alignment tradeoffs, trl SFTTrainer configuration, adapter merging for deployment, and evaluation with lm-evaluation-harness benchmarks.

## When to Use

- Fine-tuning a 7B–70B LLM on a single GPU (QLoRA + bitsandbytes)
- Preparing instruction datasets in ChatML or Alpaca format
- Choosing LoRA rank, alpha, and target modules for a task
- Implementing DPO for preference alignment without a reward model
- Running MMLU, HellaSwag, TruthfulQA benchmarks on fine-tuned models
- Merging LoRA adapters into base model for zero-overhead deployment
- Debugging catastrophic forgetting or poor instruction following

## Components

| Component | Description |
|-----------|-------------|
| `agents/llm-tuner` | Expert in LoRA/QLoRA, PEFT, DPO, trl, instruction formats, evaluation |
| `skills/llm-tuning-patterns` | Code patterns: QLoRA setup, LoRA config, dataset masking, DPO, adapter merging, evaluation |
| `commands/fine-tune` | `/fine-tune prepare\|train\|evaluate\|merge` workflows |

## Key Concepts

**LoRA Memory Savings**
LoRA adds rank-r matrices to attention projections. For r=16 on LLaMA-7B: ~42M trainable params (0.6%) vs 7B. QLoRA (4-bit base + FP16 adapters) fits 7B training in 12–18 GB VRAM.

**Label Masking**
Only train on assistant tokens. Set `labels = -100` for all user/system tokens. Without this, you're training the model to predict user inputs, which degrades instruction following.

**DPO Over PPO**
DPO (Direct Preference Optimization) achieves similar alignment to PPO without a reward model. Loss is computed directly from (prompt, chosen, rejected) triples. Simpler setup, more stable training. Use for style/safety alignment. Use PPO when reward is well-defined (e.g., code execution correctness).

**Adapter Merging**
After QLoRA training, merge adapters into FP16 base for clean deployment: `model.merge_and_unload()`. Cannot merge from a 4-bit base — load base in FP16 first, then merge.

## Quick Start

```bash
pip install transformers peft trl bitsandbytes datasets lm-eval
```

```python
from peft import LoraConfig, get_peft_model
lora_cfg = LoraConfig(r=16, lora_alpha=32,
                       target_modules=["q_proj", "v_proj"],
                       task_type="CAUSAL_LM")
model = get_peft_model(base_model, lora_cfg)
model.print_trainable_parameters()
```
