<p align="center">
  <h1 align="center">LibreMLOps-Claude-Code</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/plugins-20-d33682?style=for-the-badge" alt="Plugins">
  <img src="https://img.shields.io/badge/license-MIT-d33682?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/claude--code-plugins-d33682?style=for-the-badge" alt="Claude Code">
  <img src="https://img.shields.io/badge/ML-operations-d33682?style=for-the-badge" alt="MLOps">
</p>

<p align="center">
  A curated collection of Claude Code plugins for ML engineering and AI operations. From experiment tracking to model deployment, feature engineering to LLM fine-tuning.
</p>

---

## Plugin Collection

| # | Plugin | Command | Description |
|---|--------|---------|-------------|
| 1 | [data-labeling](plugins/data-labeling/) | `/label-data` | Labeling strategies, annotation tools, quality assurance |
| 2 | [data-pipelines](plugins/data-pipelines/) | `/ml-pipeline` | ETL for ML, data preprocessing, Apache Beam/Spark |
| 3 | [data-versioning](plugins/data-versioning/) | `/data-version` | DVC, dataset versioning, data lineage tracking |
| 4 | [distributed-training](plugins/distributed-training/) | `/dist-train` | Multi-GPU, distributed data parallel, model parallel |
| 5 | [experiment-tracking](plugins/experiment-tracking/) | `/track-experiment` | MLflow, W&B, experiment organization, hyperparameter logging |
| 6 | [feature-engineering](plugins/feature-engineering/) | `/features` | Feature stores, feature extraction, transformation pipelines |
| 7 | [gpu-optimization](plugins/gpu-optimization/) | `/gpu-optimize` | CUDA optimization, mixed precision, memory management |
| 8 | [llm-fine-tuning](plugins/llm-fine-tuning/) | `/fine-tune` | LoRA, QLoRA, RLHF, instruction tuning, dataset preparation |
| 9 | [mlflow-integration](plugins/mlflow-integration/) | `/mlflow` | MLflow setup, tracking server, model registry, deployments |
| 10 | [ml-testing](plugins/ml-testing/) | `/ml-test` | Model testing, data testing, behavioral testing, A/B testing |
| 11 | [model-deployment](plugins/model-deployment/) | `/deploy-model` | Serving (TorchServe, TF Serving, Triton), containers, edge |
| 12 | [model-evaluation](plugins/model-evaluation/) | `/evaluate-model` | Metrics, evaluation frameworks, bias detection, fairness |
| 13 | [model-monitoring](plugins/model-monitoring/) | `/monitor-model` | Drift detection, performance monitoring, alerting |
| 14 | [model-registry](plugins/model-registry/) | `/model-registry` | Model versioning, staging, promotion workflows |
| 15 | [model-training](plugins/model-training/) | `/train-model` | Training loops, callbacks, checkpointing, early stopping |
| 16 | [prompt-engineering](plugins/prompt-engineering/) | `/prompt-eng` | Prompt design, chain-of-thought, few-shot, evaluation |
| 17 | [pytorch-patterns](plugins/pytorch-patterns/) | `/pytorch` | PyTorch modules, datasets, DataLoaders, Lightning |
| 18 | [rag-architecture](plugins/rag-architecture/) | `/rag` | Retrieval-augmented generation, chunking, embeddings, indexing |
| 19 | [tensorflow-patterns](plugins/tensorflow-patterns/) | `/tensorflow` | TF/Keras models, tf.data, SavedModel, TFLite |
| 20 | [vector-databases](plugins/vector-databases/) | `/vectordb` | Pinecone, Weaviate, Chroma, FAISS, embedding management |

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/HermeticOrmus/LibreMLOps-Claude-Code.git
cd LibreMLOps-Claude-Code
```

### 2. Install a plugin

Copy the desired plugin contents into your project's `.claude/` directory:

```bash
# Example: install the experiment-tracking plugin
cp -r plugins/experiment-tracking/agents/* your-project/.claude/agents/
cp -r plugins/experiment-tracking/commands/* your-project/.claude/commands/
cp -r plugins/experiment-tracking/skills/* your-project/.claude/skills/
```

### 3. Install hooks (optional)

```bash
cp hooks/session-start.sh your-project/.claude/hooks/
cp hooks/pre-tool-use.sh your-project/.claude/hooks/
cp hooks/post-tool-use.sh your-project/.claude/hooks/
```

### 4. Use a command

In Claude Code, type the plugin command:

```
/track-experiment --name "baseline-v1" --framework mlflow
```

## Architecture

```
LibreMLOps-Claude-Code/
├── plugins/                    # 20 ML/AI operation plugins
│   └── {plugin-name}/
│       ├── README.md           # Plugin documentation
│       ├── agents/             # Agent definitions (AGENT.md)
│       ├── commands/           # Slash commands (COMMAND.md)
│       └── skills/             # Knowledge patterns (SKILL.md)
├── hooks/                      # Session lifecycle hooks
│   ├── session-start.sh        # ML framework detection, GPU check
│   ├── pre-tool-use.sh         # Data validation, experiment reminders
│   └── post-tool-use.sh        # Artifact verification, metrics logging
├── learning-paths/             # Structured learning progressions
│   ├── beginner.md             # ML fundamentals, first model
│   ├── intermediate.md         # Feature engineering, experiment tracking
│   └── advanced.md             # Distributed training, LLM fine-tuning
├── templates/                  # Project templates
│   └── CLAUDE.md               # ML project CLAUDE.md template
└── resources/                  # Additional resources
```

### Plugin Anatomy

Each plugin contains three components:

- **Agent** (`AGENT.md`): Defines a specialized persona with domain expertise, behavioral guidelines, and output formatting standards. Agents act as senior ML engineers in their domain.

- **Command** (`COMMAND.md`): Defines a slash command trigger with input parameters, processing steps, and expected outputs. Commands are the primary interface for users.

- **Skill** (`SKILL.md`): Encodes domain knowledge as patterns, anti-patterns, and reference material. Skills provide the knowledge base that agents draw from.

### Hook Lifecycle

```
Session Start → session-start.sh (detect frameworks, check GPU)
       ↓
  Tool Use → pre-tool-use.sh (validate data, remind tracking)
       ↓
  Tool Done → post-tool-use.sh (verify artifacts, log metrics)
```

## Learning Paths

| Path | Level | Focus |
|------|-------|-------|
| [Beginner](learning-paths/beginner.md) | Getting started | ML fundamentals, first model training, basic evaluation |
| [Intermediate](learning-paths/intermediate.md) | Building skills | Feature engineering, experiment tracking, model versioning |
| [Advanced](learning-paths/advanced.md) | Production ML | Distributed training, LLM fine-tuning, production systems |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. This project follows the [Contributor Covenant v2.1](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) - Copyright (c) 2025-2026 Hermetic Ormus
