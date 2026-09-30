<p align="center">
  <img src="https://ormus.solutions/mascot/pixellab_liquid_to_eye.gif" alt="LibreMLOps Claude Code" width="128" style="image-rendering: pixelated;" />
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

| Plugin | Domain | Command |
|---|---|---|
| data-pipelines | Airflow, Dagster, Prefect, Argo Workflows | `/ml-pipeline` |
| data-versioning | DVC, LakeFS, data contracts | `/data-version` |
| data-labeling | Label Studio, Prodigy, weak supervision | `/label-data` |
| feature-engineering | Feast, Tecton, feature store patterns | `/features` |

### Training

| Plugin | Domain | Command |
|---|---|---|
| model-training | PyTorch + TF training loops, lightning, accelerate | `/train-model` |
| distributed-training | DDP, FSDP, DeepSpeed, multi-GPU + multi-node | `/dist-train` |
| gpu-optimization | Memory profiling, mixed precision, FlashAttention, model parallelism | `/gpu-optimize` |
| experiment-tracking | MLflow, W&B, Neptune, Comet | `/track-experiment` |
| llm-fine-tuning | LoRA, QLoRA, full fine-tuning, RLHF, DPO | `/fine-tune` |

### Registry + deployment

| Plugin | Domain | Command |
|---|---|---|
| model-registry | MLflow Registry, model versioning, lineage | `/model-registry` |
| model-deployment | KServe, BentoML, Triton, SageMaker, Vertex AI | `/deploy-model` |
| **rag-architecture** ⭐ | Retrieval-augmented generation systems, chunking, embedding, reranking, eval | `/rag` |
| pytorch-patterns | Idiomatic PyTorch for production | `/pytorch` |
| tensorflow-patterns | TF Keras for production, TFX | `/tensorflow` |
| vector-databases | Pinecone, Weaviate, Qdrant, pgvector, Milvus | `/vectordb` |

### Operations + monitoring

| Plugin | Domain | Command |
|---|---|---|
| model-monitoring | Drift detection (data drift + concept drift), latency, quality SLOs | `/monitor-model` |
| model-evaluation | Offline eval, online eval, A/B testing, evaluation harnesses | `/evaluate-model` |
| ml-testing | Unit tests for ML, integration tests, regression suites | `/ml-test` |
| mlflow-integration | MLflow end-to-end | `/mlflow` |
| prompt-engineering | Structured prompting, few-shot, chain-of-thought, eval-driven prompting | `/prompt-eng` |

⭐ = depth-complete plugin. Remaining 19 shell-improved.

Every plugin ships one agent, one slash command, and one skill: 20 agents, 20 commands, and 20 skills in all. A 21st plugin, `libre-mlops-hooks`, is optional and adds hooks instead (see below).

---

## Quick start

### Install from Claude Code

```
/plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code
/plugin install rag-architecture@libre-mlops
```

The same from a terminal:

```bash
claude plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code
claude plugin install rag-architecture@libre-mlops
```

Install as many plugins as you need, then restart Claude Code to load them. `/plugin` inside Claude Code opens the plugin manager, where you can browse the rest of the pack.

### Install from a clone

```bash
git clone https://github.com/HermeticOrmus/LibreMLOps-Claude-Code.git ~/projects/LibreMLOps-Claude-Code
cd ~/projects/LibreMLOps-Claude-Code
./setup.sh
```

`./setup.sh` registers the clone as the `libre-mlops` marketplace and installs all 21 plugins through the Claude Code CLI. `./setup.sh --list` shows them, `./setup.sh --only rag-architecture,model-deployment` installs a subset, and `./setup.sh --uninstall` removes them.

### Optional hooks

`libre-mlops-hooks` prints a one-line summary of the ML stack when a session starts, asks before Claude reads or edits `.env`, key, or secrets files or runs commands that destroy data, models, or run history (`dvc gc`, `mlflow gc`, `aws s3 rm`, recursive deletes of data or checkpoint folders), and after an edit points Claude at the matching test file. Add it with `/plugin install libre-mlops-hooks@libre-mlops`. Details: [plugins/libre-mlops-hooks](plugins/libre-mlops-hooks/README.md).

### First prompt

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

## Feedback

Starred this? Tell us what worked and what is missing: [open a feedback issue](https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/issues/new?template=feedback.yml). Every piece of feedback gets an answer, and changes that come from it are credited in the release notes.

## Contribute

- Pick up work from the [Menu](pantry/MENU.md): every item has a Done-when anyone can check, and one is marked up next.
- New here? Start with the [good first issues](https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/contribute).
- Use the forms: [feedback](https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/issues/new?template=feedback.yml), [routing miss](https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/issues/new?template=routing-miss.yml) when Claude picks the wrong agent or skill, and [plugin proposal](https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/issues/new?template=plugin-proposal.yml) for something new.
- Discussions are not switched on. [CONTRIBUTING.md](CONTRIBUTING.md#ways-to-contribute) says where to share what you built and how to test a change locally.

## Contributing

PRs welcome for plugin depth, ML framework patterns, specific cloud ML platforms, fine-tuning recipes. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.

---

## Part of the Libre Open-Source Stack for Claude Code

This repository is part of a growing family of open-source toolkits for Claude Code.

### Libre suite — comprehensive plugin bundles

- [LibreUIUX-Claude-Code](https://github.com/HermeticOrmus/LibreUIUX-Claude-Code) — UI/UX development (152 agents, 70 plugins, 76 commands, 74 skills)
- [LibreArch-Claude-Code](https://github.com/HermeticOrmus/LibreArch-Claude-Code) — Software architecture and system design
- [LibreCopy-Claude-Code](https://github.com/HermeticOrmus/LibreCopy-Claude-Code) — Technical writing and documentation engineering
- [LibreDevOps-Claude-Code](https://github.com/HermeticOrmus/LibreDevOps-Claude-Code) — DevOps engineering and infrastructure automation
- [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code) — Embedded systems, firmware, and IoT development
- [LibreFinTech-Claude-Code](https://github.com/HermeticOrmus/LibreFinTech-Claude-Code) — Financial technology development
- [LibreGEO-Claude-Code](https://github.com/HermeticOrmus/LibreGEO-Claude-Code) — AI-search optimization (ChatGPT, Perplexity, Gemini, Google AI Overviews)
- [LibreGameDev-Claude-Code](https://github.com/HermeticOrmus/LibreGameDev-Claude-Code) — Game development across Godot, Unity, Unreal
- [LibreMobileDev-Claude-Code](https://github.com/HermeticOrmus/LibreMobileDev-Claude-Code) — Mobile app development (Flutter, React Native, native iOS, native Android)
- [LibreSecOps-Claude-Code](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code) — Security operations
- [LibreSessionFlow-Claude-Code](https://github.com/HermeticOrmus/LibreSessionFlow-Claude-Code) — Session lifecycle: handoff, pickup, absorb, explore, close

### Skills mini-repos — single CLAUDE.md drop-ins

- [vibe-engineer-skills](https://github.com/HermeticOrmus/vibe-engineer-skills) — Direct AI codegen well: hypothesis before help, scoped prompts, validate before accepting
- [markdown-discipline-skills](https://github.com/HermeticOrmus/markdown-discipline-skills) — Strip AI-slop from markdown (no em dashes, no marketing fluff)
- [shell-safety-skills](https://github.com/HermeticOrmus/shell-safety-skills) — `set -euo pipefail` discipline plus 15 failure-mode examples
- [commit-standard-skills](https://github.com/HermeticOrmus/commit-standard-skills) — Ormus Commit Standard v1.0 plus commit-msg hook and commitlint
- [unwoke-skills](https://github.com/HermeticOrmus/unwoke-skills) — Strip AI theater (ten sins to eliminate, symmetric engagement)
- [python-conventions-skills](https://github.com/HermeticOrmus/python-conventions-skills) — Modern Python 3.11+ (types, pathlib, async, ruff, mypy, uv)
- [typescript-conventions-skills](https://github.com/HermeticOrmus/typescript-conventions-skills) — TypeScript strict mode, discriminated unions, Result types
- [hermetic-laws-skills](https://github.com/HermeticOrmus/hermetic-laws-skills) — Seven Hermetic Principles applied to engineering
- [riper-workflow-skills](https://github.com/HermeticOrmus/riper-workflow-skills) — Research / Innovate / Plan / Execute / Review systematic dev
- [six-day-cycle-skills](https://github.com/HermeticOrmus/six-day-cycle-skills) — Sustainable shipping cadence with mandatory rest
- [token-optimization-skills](https://github.com/HermeticOrmus/token-optimization-skills) — Claude Code token and context optimization
- [osint-skills](https://github.com/HermeticOrmus/osint-skills) — OSINT research methodology (multi-wave investigative spiral)
- [calcinate-skills](https://github.com/HermeticOrmus/calcinate-skills) — Stage 1 of the Magnum Opus (burn project bloat)
- [claude-md-overhaul-skills](https://github.com/HermeticOrmus/claude-md-overhaul-skills) — Audit CLAUDE.md and MEMORY.md against caps
- [session-handoff-skills](https://github.com/HermeticOrmus/session-handoff-skills) — Session handoff and pickup discipline
- [naming-skills](https://github.com/HermeticOrmus/naming-skills) — Product naming methodology (mine the brand's vocabulary)
- [magnum-opus-skills](https://github.com/HermeticOrmus/magnum-opus-skills) — Seven-stage alchemy applied to project transformation
- [mem-search-skills](https://github.com/HermeticOrmus/mem-search-skills) — Search claude-mem cross-session memory: search, filter, fetch
- [hypothesis-debugging-skills](https://github.com/HermeticOrmus/hypothesis-debugging-skills) — Hypothesis-driven debugging: reproduce, isolate, test, fix
- [vibe-proof-skills](https://github.com/HermeticOrmus/vibe-proof-skills) — Security hardening for vibe-coded full-stack apps
- [tdd-skills](https://github.com/HermeticOrmus/tdd-skills) — Test-driven development (Red-Green-Refactor) for JS/TS and Python
- [mars-skills](https://github.com/HermeticOrmus/mars-skills) — Production-readiness audit: the five mortal sins of vibe-coded MVPs
- [git-workflow-skills](https://github.com/HermeticOrmus/git-workflow-skills) — Clean git workflow: branch, atomic commits, reviewable PRs
- [code-review-skills](https://github.com/HermeticOrmus/code-review-skills) — Domain-aware code review: classify the code, then focus
- [code-comprehension-skills](https://github.com/HermeticOrmus/code-comprehension-skills) — Understand an unfamiliar codebase fast
- [dx-audit-skills](https://github.com/HermeticOrmus/dx-audit-skills) — Audit developer experience: docs, onboarding, tooling friction
- [setup-env-skills](https://github.com/HermeticOrmus/setup-env-skills) — Set up a project's development environment
- [automate-skills](https://github.com/HermeticOrmus/automate-skills) — Turn repetitive tasks into reliable automation scripts
- [quick-fix-skills](https://github.com/HermeticOrmus/quick-fix-skills) — Fast troubleshooting for common issues
- [prime-context-skills](https://github.com/HermeticOrmus/prime-context-skills) — Prime project context at the start of a session
- [auto-docs-skills](https://github.com/HermeticOrmus/auto-docs-skills) — Generate and maintain project documentation
- [learning-skills](https://github.com/HermeticOrmus/learning-skills) — Learn any technology: roadmaps, explanations, practice, cheatsheets, comparisons
- [linux-sysadmin-skills](https://github.com/HermeticOrmus/linux-sysadmin-skills) — Linux system administration: security, performance, diagnostics, monitoring, maintenance

### Template source

- [andrej-karpathy-skills](https://github.com/HermeticOrmus/andrej-karpathy-skills) — the canonical single-file CLAUDE.md pattern (fork of jiayuan_jy's original)

Star the family, not just one — that's how the suite stays coherent.
