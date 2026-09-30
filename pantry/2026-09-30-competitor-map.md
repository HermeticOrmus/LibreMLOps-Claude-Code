# Competitor map: LibreMLOps-Claude-Code

## How this fills

1. Name the product and its surfaces (plugins, agents, skills, commands, install paths).
2. WebSearch / WebFetch public competitor docs, READMEs and homepages: other Claude Code plugin packs and marketplaces in this domain, Cursor rules and plugins, Codex or Gemini CLI extensions, and standalone tools people use for the same job.
3. One row per competitor; blank unknowns; cite a URL per row.
4. Fill the capabilities matrix (Y / N / P / ?) with the capabilities that matter in this domain, and a source per claimed cell.
5. Save as `YYYY-MM-DD-competitor-map.md` (keep this template).

## Product

- Name: LibreMLOps-Claude-Code, Claude Code plugin marketplace `libre-mlops`, version 1.0.0 (`.claude-plugin/marketplace.json`).
- Flagship: `rag-architecture`, the one plugin the README marks depth-complete.
- Our surfaces: 21 plugins (20 ML-engineering plugins plus the optional `libre-mlops-hooks`), 20 agents, 20 slash commands, 20 skills, 3 hook scripts. Install with `/plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code` or `./setup.sh`. CI validates the marketplace and every plugin, then installs all of them into a clean config. Counts are from the files on `main`, read on 2026-09-30.

Star counts below come from the GitHub API (`gh api repos/<owner>/<repo>`), read on 2026-09-30.

## Map

| Competitor | What it is | Overlap with us | Watch / differentiator | Source URL |
|------------|------------|-----------------|------------------------|------------|
| huggingface/skills | Hugging Face's official Agent Skills: Hub CLI, datasets, LLM and vision trainers on Hugging Face Jobs, community evals with inspect-ai and lighteval, Trackio, local models with llama.cpp and GGUF, SageMaker deployment. 11,117 stars. | llm-fine-tuning, model-evaluation, experiment-tracking, model-deployment. | Runs real jobs on cloud GPUs and pushes models to the Hub. Installs in Claude Code, Codex, Gemini CLI (`gemini-extension.json`) and Cursor (`.cursor-plugin/`, `.mcp.json`). | https://github.com/huggingface/skills |
| Orchestra-Research/AI-Research-SKILLs | Library of 98 AI research and engineering skills in 23 categories, including fine-tuning, post-training, distributed training, inference, evaluation, RAG, MLOps and observability. 13,153 stars. | Nearly every plugin we ship, on the LLM side. | Covers LLM serving (vLLM, TensorRT-LLM, llama.cpp, SGLang) and LLM observability (LangSmith, Phoenix), which we do not. Installs through a Claude Code marketplace or an npx installer that detects several agents. | https://github.com/Orchestra-Research/AI-Research-SKILLs |
| wshobson/agents | Multi-harness plugin marketplace for Claude Code, Codex, Cursor, OpenCode, GitHub Copilot, Antigravity and Pi. 40,112 stars. | Its `machine-learning-ops` (data-scientist, ml-engineer, mlops-engineer), `llm-finetuning` (eval-gated LoRA and QLoRA SFT, DPO, GRPO, quantized export) and `llm-application-dev` (RAG, vector index tuning, LLM evaluation) plugins. | "no eval harness means no fine-tune" is built into its fine-tuning plugin; installs outside Claude Code; ships a `plugin-eval` plugin. | https://github.com/wshobson/agents/tree/main/plugins/machine-learning-ops |
| W&B MCP server | Official Weights & Biases MCP server for querying runs, experiments and Weave traces in natural language. 70 stars. | experiment-tracking, model-evaluation. | Gives the agent live experiment data; read-only mode; eval badges in its README. Works with Claude, Cursor, Gemini CLI, OpenAI, LeChat and VS Code. | https://github.com/wandb/wandb-mcp-server |
| MLflow MCP server | MCP server built into MLflow (3.5.1 or newer) that lets coding assistants search and analyze MLflow traces, log feedback and manage trace tags. mlflow/mlflow has 28,198 stars. | mlflow-integration, experiment-tracking, model-evaluation. | Trace-first: aimed at LLM apps, not classic runs. | https://mlflow.org/docs/latest/genai/mcp/ |
| MLOps-Courses/mlops-coding-skills | Seven Agent Skills that follow the chapters of the MLOps Coding Course: initialization, prototyping in Jupyter, packaging, validation, automation with MLflow, collaboration, observability. 22 stars. | ml-testing, experiment-tracking, model-monitoring. | Covers notebook hygiene and project setup, which we do not; installs by symlink into each agent's skills folder. | https://github.com/MLOps-Courses/mlops-coding-skills |
| awesome-cursorrules ML rules | Community Cursor rules, including `pytorch-scikit-learn`, `python-llm-ml-workflow`, `tensorflow-deep-learning` and `automl-hyperparameter-optimization`. Repo 40,862 stars. | pytorch-patterns, tensorflow-patterns, model-training. | Rules files for Cursor, not installable agents or commands. | https://github.com/PatrickJS/awesome-cursorrules/tree/main/rules |

## Capabilities matrix

Mark Y / N / P (partial) / ? and cite. Rows are the capabilities that matter for this domain.

| Capability | Us | huggingface/skills | AI-Research-SKILLs | wshobson/agents | W&B MCP | MLflow MCP | mlops-coding-skills | Source notes |
|------------|----|--------------------|--------------------|-----------------|---------|------------|---------------------|--------------|
| Classic ML lifecycle (pipelines, data versioning, feature stores, registry, drift monitoring) | Y | P | P | Y | N | N | P | Us: `data-pipelines`, `data-versioning`, `feature-engineering`, `model-registry`, `model-monitoring`. HF: datasets, Trackio and SageMaker skills, no feature store or drift skill in its table. AI-Research-SKILLs: MLOps category is W&B, MLflow, TensorBoard. wshobson: `mlops-engineer` ("ML pipelines, experiment tracking, and model registries with MLflow, Kubeflow"). mlops-coding-skills: automation and observability chapters. The MCP servers expose data, not guidance. |
| LLM fine-tuning (LoRA, QLoRA, preference tuning) | Y | Y | Y | Y | N | N | N | Us: `llm-fine-tuning` (LoRA and QLoRA, DPO and PPO). HF: `huggingface-llm-trainer`, `trl-training`. AI-Research-SKILLs: fine-tuning (Axolotl, LLaMA-Factory, PEFT, Unsloth) and post-training. wshobson: `llm-finetuning`. |
| Launches training jobs on cloud GPUs | N | Y | ? | ? | N | N | N | Us: guidance and code only. HF: `huggingface-llm-trainer` trains "with Hugging Face Jobs infrastructure". |
| LLM inference engines (vLLM, SGLang, TGI, llama.cpp) | N | P | Y | ? | N | N | N | Us: no file under `plugins/` names vLLM, SGLang, TGI or llama.cpp. HF: `huggingface-local-models` (llama.cpp and GGUF) and SageMaker serving images. AI-Research-SKILLs: Inference (vLLM, TensorRT-LLM, llama.cpp, SGLang). |
| Classic model serving (Triton, TorchServe, BentoML, ONNX) | Y | P | ? | Y | N | N | ? | Us: `model-deployment` (ONNX export, BentoML, TorchServe, Triton, FastAPI). HF: SageMaker endpoint skills. wshobson: `ml-engineer` "Implements model serving". |
| Reads live experiment data through MCP | N | P | ? | ? | Y | P | N | Us: no MCP config anywhere in the repo. HF: Trackio skill, and a `.mcp.json` for the Hugging Face MCP server in its Cursor manifest. W&B: "Query and analyze your Weights & Biases data". MLflow: trace-centric operations. mlops-coding-skills: skills only. |
| LLM app tracing and observability | N | ? | Y | ? | Y | Y | ? | Us: no tracing workflow; LangSmith appears once, as a prompt-registry option in `prompt-engineer`. AI-Research-SKILLs: Observability (LangSmith, Phoenix). W&B: "Debug Traces" use case. MLflow: "all MLflow trace management operations". |
| RAG and vector databases | Y | P | Y | Y | N | N | N | Us: `rag-architecture`, `vector-databases`. HF: `train-sentence-transformers` (embedding and reranker training). AI-Research-SKILLs: RAG (5 skills). wshobson: `llm-application-dev` (rag-implementation, vector-index-tuning, hybrid-search-implementation). |
| Model and LLM evaluation harness | Y | Y | Y | Y | ? | P | ? | Us: `model-evaluation`, RAGAS in `rag-architecture`, lm-evaluation-harness in `llm-tuner`. HF: `huggingface-community-evals` (inspect-ai, lighteval). AI-Research-SKILLs: Evaluation (lm-eval-harness, BigCode, NeMo Evaluator). wshobson: skills `llm-evaluation`, `eval-harness-first`. MLflow: log feedback and assessments on traces. |
| Jupyter and notebook workflow | N | ? | ? | ? | N | N | Y | Us: only the hooks' session summary notices a `notebooks/` folder. mlops-coding-skills: `mlops-prototyping` ("Write clean, reproducible Jupyter notebooks and prevent data leakage"). |
| JAX | N | ? | ? | ? | N | N | ? | Us: README Compatibility lists "JAX (light)", but no file under `plugins/` mentions JAX. |
| Installs from a Claude Code plugin marketplace | Y | Y | Y | Y | N | N | N | Us: `.claude-plugin/marketplace.json`. HF: `/plugin marketplace add huggingface/skills`. AI-Research-SKILLs: `/plugin marketplace add orchestra-research/AI-research-SKILLs`. wshobson: `/plugin marketplace add wshobson/agents`. W&B and MLflow install as MCP servers. mlops-coding-skills: symlink into `.claude/skills/`. |
| Runs outside Claude Code | N | Y | Y | Y | Y | Y | Y | Us: README documents Claude Code installs only. HF: Codex, Gemini CLI, Cursor. AI-Research-SKILLs: installer detects Cursor, Gemini CLI, OpenCode and others. wshobson: Codex, Cursor, OpenCode, Copilot, Antigravity, Pi. W&B: Cursor, Gemini CLI, OpenAI, LeChat, VS Code. MLflow: any MCP client. mlops-coding-skills: Antigravity, Gemini CLI, Copilot. |
| Guard hooks for destructive data and model commands | Y | ? | ? | ? | P | ? | ? | Us: `libre-mlops-hooks` asks before `dvc gc`, `mlflow gc`, `aws s3 rm`, `gsutil rm` and recursive deletes of data, model or checkpoint folders. W&B: read-only mode. |
| Published proof that it works (evals) | N | ? | ? | P | Y | ? | ? | Us: no `evals/` folder; CI validates and installs only. W&B: SDK and MCP eval badges at the top of its README. wshobson: plugin `plugin-eval` ("Static lint for Claude Code plugins and skills, with experimental LLM scoring for skills"). |
