# Pantry queue: LibreMLOps-Claude-Code

## How this fills

1. Read the latest competitor map, X mine and people mine.
2. Propose 5 to 8 Goal atoms that answer their themes. The Menu needs at least 3.
3. Each atom needs a Done predicate someone else can check on this repo, a surface, the evidence rows it answers, and a confidence (high, medium or low).
4. Save as `YYYY-MM-DD-pantry-queue.md`; the Menu reads the newest one.
5. Retire an atom only with a bullet under "Explicitly not stocked" of the form `<Title>: shipped, PR #N` or `<Title>: parked, <reason>`.

Sources for this run: [competitor map](2026-09-30-competitor-map.md), [X mine](2026-09-30-x-mine.md), [people mine](2026-09-30-people-mine.md) (no outside voices yet, so no atom cites it).

## Atoms

| # | Title | Done predicate | Surface | Evidence | Confidence |
|---|-------|----------------|---------|----------|------------|
| 1 | Add an `llm-serving` plugin for vLLM, SGLang and llama.cpp | `claude plugin validate plugins/llm-serving` passes, `.claude-plugin/marketplace.json` lists `llm-serving`, and after a clean-config install `claude plugin details llm-serving@libre-mlops` lists an agent and its skills; the skill gives a runnable server launch command for vLLM, SGLang and llama.cpp and says when to pick each | repo | Map: AI-Research-SKILLs (Inference: vLLM, TensorRT-LLM, llama.cpp, SGLang), huggingface/skills (`huggingface-local-models`); matrix row "LLM inference engines (vLLM, SGLang, TGI, llama.cpp)" (Us N) | high |
| 2 | Add a `notebook-workflow` skill for Jupyter, jupytext and marimo | `claude plugin validate plugins/model-training` passes and `claude plugin details model-training@libre-mlops` lists skill `notebook-workflow`; the skill shows how to run a notebook top to bottom from the command line (for example `jupyter nbconvert --to notebook --execute`) and when to keep it in a text format such as jupytext or marimo | repo | Map: mlops-coding-skills (`mlops-prototyping`); matrix row "Jupyter and notebook workflow" (Us N). X: helloiamleonie, kmeanskaran, JFPuget (complaints); eugeneyan (praise); den_volkhonskiy (question) | high |
| 3 | Add an `llm-tracing` plugin for LLM app traces and feedback | `claude plugin validate plugins/llm-tracing` passes, `.claude-plugin/marketplace.json` lists `llm-tracing`, and `claude plugin details llm-tracing@libre-mlops` lists an agent and its skills; the skill instruments one LLM call with MLflow Tracing and one with an OpenTelemetry-based tracer such as Langfuse or Phoenix, each with a runnable snippet | repo | Map: MLflow MCP, W&B MCP, AI-Research-SKILLs (Observability: LangSmith, Phoenix); matrix row "LLM app tracing and observability" (Us N). X: MLflow (vendor post) | medium |
| 4 | Document `tracker-mcp` setup for the W&B and MLflow MCP servers | `plugins/experiment-tracking/README.md` gains a section with the `claude mcp add` command for the W&B MCP server and a `.mcp.json` entry for the MLflow MCP server, each taken from that project's docs with a link, plus one prompt that uses them; `claude plugin validate plugins/experiment-tracking` passes | repo | Map: W&B MCP, MLflow MCP; matrix row "Reads live experiment data through MCP" (Us N). X: wandb, MLflow (vendor posts) | medium |
| 5 | Add a `jax-patterns` plugin to back the README's JAX claim | `claude plugin validate plugins/jax-patterns` passes, `.claude-plugin/marketplace.json` lists `jax-patterns`, and `claude plugin details jax-patterns@libre-mlops` lists an agent and its skills; the skill covers `jit`, `vmap`, sharding across devices, and one Flax or Equinox model with a runnable example | repo | Map: matrix row "JAX" (Us N, although the README Compatibility section lists "JAX (light)") | medium |
| 6 | Add `routing-evals` for the rag-architecture plugin | `plugins/rag-architecture/evals/` holds cases that ask to design a RAG system and to debug one that hallucinates, each grader checks that `rag-engineer` or `/rag` fired and that the answer sets up an evaluation set before tuning, and `claude plugin eval plugins/rag-architecture` passes every case | repo | Map: matrix row "Published proof that it works (evals)" (Us N, W&B MCP Y, wshobson/agents P). X: JFPuget (a notebook skill made the agent worse, which only a test would catch) | medium |
| 7 | Document a `cross-agent-install` path for Codex and Gemini CLI | README gains a section that shows how to load this pack's skills in Codex or Gemini CLI with a command someone ran against this repo, and names what stays Claude Code only (agents, slash commands, hooks) | repo | Map: matrix row "Runs outside Claude Code" (Us N, every other column Y). X: Hesamation, replicate | low |

## Explicitly not stocked (and why)

- Launching training jobs on cloud GPUs, as huggingface/skills does on Hugging Face Jobs: not stocked, it needs a paid compute account to verify.
- A hosted MCP server of our own for experiment data: not stocked, it needs infrastructure. Pointing at the W&B and MLflow servers (atom 4) covers the gap.
