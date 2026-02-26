# /fine-tune

Prepare datasets, configure LoRA/QLoRA, run instruction tuning or DPO, and evaluate fine-tuned LLMs.

## Trigger

`/fine-tune [action] [options]`

## Actions

- `prepare` - Format dataset into instruction tuning format (Alpaca, ChatML, ShareGPT)
- `train` - Generate QLoRA/SFT training script with appropriate configuration
- `evaluate` - Run lm-evaluation-harness benchmarks on fine-tuned model
- `merge` - Merge LoRA adapter into base model for inference

## Examples

### prepare — Format instruction dataset

```python
import json
from datasets import Dataset

# Input: list of {instruction, input, output} dicts
# Output: ChatML-formatted JSONL file

def to_chatml(item: dict, system_prompt: str = "You are a helpful assistant.") -> str:
    user_content = item['instruction']
    if item.get('input'):
        user_content += f"\n\n{item['input']}"

    return (
        f"<|im_start|>system\n{system_prompt}<|im_end|>\n"
        f"<|im_start|>user\n{user_content}<|im_end|>\n"
        f"<|im_start|>assistant\n{item['output']}<|im_end|>"
    )

raw_data = json.load(open("raw_data.json"))
formatted = [{"text": to_chatml(item)} for item in raw_data]

# Validate token lengths
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")
lengths = [len(tokenizer.encode(x["text"])) for x in formatted]
print(f"Examples: {len(formatted)}")
print(f"Token length: mean={sum(lengths)/len(lengths):.0f}, p95={sorted(lengths)[int(len(lengths)*0.95)]}")
print(f"Truncation at 2048: {sum(1 for l in lengths if l > 2048)} examples ({sum(1 for l in lengths if l > 2048)/len(lengths)*100:.1f}%)")

# Save
with open("train.jsonl", "w") as f:
    for ex in formatted:
        f.write(json.dumps(ex) + "\n")
```

### train — QLoRA with SFTTrainer

```python
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, TrainingArguments
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from trl import SFTTrainer
from datasets import load_dataset
import torch

# 4-bit NF4 config
bnb = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True
)

model = AutoModelForCausalLM.from_pretrained("mistralai/Mistral-7B-v0.1",
                                               quantization_config=bnb, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")
tokenizer.pad_token = tokenizer.eos_token

model = prepare_model_for_kbit_training(model)

lora_cfg = LoraConfig(
    r=16, lora_alpha=32,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    lora_dropout=0.05, bias="none", task_type="CAUSAL_LM"
)
model = get_peft_model(model, lora_cfg)
model.print_trainable_parameters()

dataset = load_dataset("json", data_files="train.jsonl")["train"]

training_args = TrainingArguments(
    output_dir="./ft-mistral-7b",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    bf16=True,
    gradient_checkpointing=True,
    optim="paged_adamw_32bit",
    lr_scheduler_type="cosine",
    warmup_ratio=0.03,
    logging_steps=10,
    save_steps=200,
    save_total_limit=2,
    report_to="mlflow",
)

trainer = SFTTrainer(
    model=model, tokenizer=tokenizer, args=training_args,
    train_dataset=dataset, dataset_text_field="text",
    max_seq_length=2048, packing=True
)
trainer.train()
trainer.save_model()
```

### evaluate — Benchmarks

```bash
pip install lm-eval

# Standard benchmarks
lm_eval \
  --model hf \
  --model_args pretrained=./ft-mistral-7b,dtype=float16 \
  --tasks mmlu,hellaswag,arc_challenge,truthfulqa_mc1 \
  --batch_size 8 \
  --device cuda \
  --output_path ./results.json

# Quick perplexity check on domain data
python -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
model = AutoModelForCausalLM.from_pretrained('./ft-mistral-7b', torch_dtype=torch.float16).cuda()
tokenizer = AutoTokenizer.from_pretrained('./ft-mistral-7b')
text = open('domain_val.txt').read()[:10000]
tokens = tokenizer(text, return_tensors='pt').input_ids.cuda()
with torch.no_grad():
    ppl = torch.exp(model(tokens, labels=tokens).loss)
print(f'Domain perplexity: {ppl.item():.2f}')
"
```

### merge — Fold adapter into base model

```python
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# Load base in FP16 (cannot merge from 4-bit)
base = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-v0.1",
    torch_dtype=torch.float16,
    device_map="auto"
)
model = PeftModel.from_pretrained(base, "./ft-mistral-7b")
merged = model.merge_and_unload()

merged.save_pretrained("./merged-mistral-7b-ft", safe_serialization=True)
AutoTokenizer.from_pretrained("./ft-mistral-7b").save_pretrained("./merged-mistral-7b-ft")
print("Merged model saved. Ready for deployment.")
```

## Options

- `--base-model <hf_id>` - HuggingFace model ID or local path
- `--lora-r <n>` - LoRA rank (default: 16)
- `--lora-alpha <n>` - LoRA alpha (default: 2×r)
- `--epochs <n>` - Training epochs (default: 3)
- `--lr <float>` - Learning rate (default: 2e-4)
- `--format <alpaca|chatml|sharegpt>` - Dataset format for prepare action
- `--max-seq-len <n>` - Maximum sequence length (default: 2048)
- `--tasks <list>` - Comma-separated lm-eval tasks for evaluate action
