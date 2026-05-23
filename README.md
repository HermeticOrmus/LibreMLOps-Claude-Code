<p align="center">
  <img src="https://ormus.solutions/mascot/chain_braces_to_swan.gif" alt="LibreMLOps Claude Code" width="128" style="image-rendering: pixelated;" />
</p>

<h1 align="center">LibreMLOps Claude Code</h1>

<p align="center">
  <em>ML engineering + AI operations with Claude Code — 20 plugins covering training, deployment, monitoring, RAG, LLMOps, and the gritty operational reality of running models in production</em>
</p>

<p align="center">
  <a href="https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/stargazers"><img src="https://img.shields.io/github/stars/HermeticOrmus/LibreMLOps-Claude-Code?style=flat-square&color=aa8142" alt="Stars" /></a>
  <a href="https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/main/LICENSE"><img src="https://img.shields.io/github/license/HermeticOrmus/LibreMLOps-Claude-Code?style=flat-square&color=aa8142" alt="License" /></a>
  <img src="https://img.shields.io/badge/MLOps-aa8142?style=flat-square&logo=pytorch&logoColor=white" alt="MLOps" />
  <img src="https://img.shields.io/badge/Claude_Code-aa8142?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

---

> **Skills, agents, commands, and workflows for ML engineering and AI operations with Claude Code.**

ML in production is engineering, not science. The model is the easy part. The hard parts: data versioning, pipeline orchestration, model registry, deployment patterns, drift monitoring, evaluation, observability. Generic AI coding misses the operational layer that turns a notebook into a service. **LibreMLOps gives Claude Code the ML-engineering expertise that production demands.**

Twenty plugins covering the full ML lifecycle plus the LLMOps layer the 2024-2026 wave brought.

---

## The 20 plugins

### Data layer

| Plugin | Domain |
|---|---|
| data-pipelines | Airflow, Dagster, Prefect, Argo Workflows |
| data-versioning | DVC, LakeFS, data contracts |
| data-labeling | Label Studio, Prodigy, weak supervision |
| feature-engineering | Feast, Tecton, feature store patterns |

### Training

| Plugin | Domain |
|---|---|
| model-training | PyTorch + TF training loops, lightning, accelerate |
| distributed-training | DDP, FSDP, DeepSpeed, multi-GPU + multi-node |
| gpu-optimization | Memory profiling, mixed precision, FlashAttention, model parallelism |
| experiment-tracking | MLflow, W&B, Neptune, Comet |
| llm-fine-tuning | LoRA, QLoRA, full fine-tuning, RLHF, DPO |

### Registry + deployment

| Plugin | Domain |
|---|---|
| model-registry | MLflow Registry, model versioning, lineage |
| model-deployment | KServe, BentoML, Triton, SageMaker, Vertex AI |
| **rag-architecture** ⭐ | Retrieval-augmented generation systems, chunking, embedding, reranking, eval |
| pytorch-patterns | Idiomatic PyTorch for production |
| tensorflow-patterns | TF Keras for production, TFX |
| vector-databases | Pinecone, Weaviate, Qdrant, pgvector, Milvus |

### Operations + monitoring

| Plugin | Domain |
|---|---|
| model-monitoring | Drift detection (data drift + concept drift), latency, quality SLOs |
| model-evaluation | Offline eval, online eval, A/B testing, evaluation harnesses |
| ml-testing | Unit tests for ML, integration tests, regression suites |
| mlflow-integration | MLflow end-to-end |
| prompt-engineering | Structured prompting, few-shot, chain-of-thought, eval-driven prompting |

⭐ = depth-complete plugin. Remaining 19 shell-improved.

---

## Quick start

```bash
git clone https://github.com/HermeticOrmus/LibreMLOps-Claude-Code.git ~/projects/LibreMLOps-Claude-Code
cd ~/projects/LibreMLOps-Claude-Code
./setup.sh
```

```
/rag design a RAG system for a customer support knowledge base. ~10k documents, mostly long-form articles, multiple languages. Customer queries in natural language. Need eval harness from Day 1.
```

See [QUICK_START.md](QUICK_START.md).

---

## Learning paths

- **[Beginner](learning-paths/beginner.md)** — ML mindset, your first deployed model
- **[Intermediate](learning-paths/intermediate.md)** — pipelines, registry, drift monitoring
- **[Advanced](learning-paths/advanced.md)** — distributed training, RLHF, multi-tenant inference

## Compatibility

PyTorch, TensorFlow/Keras, JAX (light), HuggingFace, MLflow, all three major clouds, on-prem GPU clusters.

## Disclaimer

Building ML systems for regulated domains (healthcare, finance, hiring, criminal justice) requires compliance work this kit doesn't replace. Bias, fairness, explainability — these are domain + regulatory concerns.

## Contributing

PRs welcome for plugin depth, ML framework patterns, specific cloud ML platforms, fine-tuning recipes. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.
