# Advanced — distributed training + RLHF + multi-tenant inference

## Distributed training

- DDP (Data Distributed Parallel): replicate model, split data
- FSDP (Fully Sharded): shard model, split data; for models bigger than single-GPU memory
- DeepSpeed: ZeRO stages + offloading; for very large models
- Pipeline parallelism: split model across GPUs in sequence; for very large models

## RLHF / DPO / ORPO

- RLHF: reward model + PPO; complex, expensive, high quality
- DPO (Direct Preference Optimization): simpler than RLHF, comparable results in many cases
- ORPO: even simpler, fewer hyperparameters

For most fine-tuning needs in 2026, DPO + LoRA hits 80% of RLHF quality at 10% cost.

## Multi-tenant inference

- vLLM: high-throughput batching, prefix caching
- Triton: multi-model serving, GPU sharing
- KServe: K8s-native serving, autoscaling
- BentoML: Python-first, easy deployment

Cost optimization:
- Speculative decoding (draft model + verify with main)
- Continuous batching (vLLM's PagedAttention)
- Quantization (INT4/INT8 for 2-4× throughput at small quality cost)
- GPU MIG (NVIDIA H100) — partition GPU into smaller units

## What's still hard

- Multi-modal at scale (text + image + audio + video together)
- Continual learning without catastrophic forgetting
- Long-context (1M+ tokens) at production cost
- Truly reliable agents (multi-step planning with self-correction)
