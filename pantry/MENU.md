# Menu: LibreMLOps-Claude-Code

Queue: 2026-09-30-pantry-queue.md
Counts: open 7, in flight 0, shipped 0, parked 0, dropped 0, needs fixing 0

## Steer

- none

## Up next

**llm-serving**: Add an `llm-serving` plugin for vLLM, SGLang and llama.cpp (queue #1, high, repo, since 2026-09-30)

- Done when: `claude plugin validate plugins/llm-serving` passes, `.claude-plugin/marketplace.json` lists `llm-serving`, and after a clean-config install `claude plugin details llm-serving@libre-mlops` lists an agent and its skills; the skill gives a runnable server launch command for vLLM, SGLang and llama.cpp and says when to pick each
- Verify on: repo
- Evidence: Map: AI-Research-SKILLs (Inference: vLLM, TensorRT-LLM, llama.cpp, SGLang), huggingface/skills (`huggingface-local-models`); matrix row "LLM inference engines (vLLM, SGLang, TGI, llama.cpp)" (Us N)
- Issue: none yet (promote after merge)
- Order: llm-serving, notebook-workflow, jax-patterns, llm-tracing, tracker-mcp, routing-evals, cross-agent-install
- Tie: llm-serving over notebook-workflow, by key order (jev off)

## Atoms

| Key | Title | State | Confidence | Class | Since | Queue # | Issue | Because |
|-----|-------|-------|------------|-------|-------|---------|-------|---------|
| cross-agent-install | Document a `cross-agent-install` path for Codex and Gemini CLI | open | low | repo | 2026-09-30 | 7 | - | - |
| jax-patterns | Add a `jax-patterns` plugin to back the README's JAX claim | open | medium | repo | 2026-09-30 | 5 | - | - |
| llm-serving | Add an `llm-serving` plugin for vLLM, SGLang and llama.cpp | open | high | repo | 2026-09-30 | 1 | - | - |
| llm-tracing | Add an `llm-tracing` plugin for LLM app traces and feedback | open | medium | repo | 2026-09-30 | 3 | - | - |
| notebook-workflow | Add a `notebook-workflow` skill for Jupyter, jupytext and marimo | open | high | repo | 2026-09-30 | 2 | - | - |
| routing-evals | Add `routing-evals` for the rag-architecture plugin | open | medium | eval | 2026-09-30 | 6 | - | - |
| tracker-mcp | Document `tracker-mcp` setup for the W&B and MLflow MCP servers | open | medium | repo | 2026-09-30 | 4 | - | - |

## Retired

| Key | Title | State | Since | Issue | Because |
|-----|-------|-------|-------|-------|---------|
| none | | | | | |

## Notes

- none
