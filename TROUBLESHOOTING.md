# Troubleshooting

## Plugins not loaded
```bash
ls ~/.claude/plugins/ | grep -c '^libre-mlops-'
```
Should print 20. Re-run `./setup.sh` + restart Claude Code.

## Common scenarios

- "RAG hallucinates" → `/rag` walks failure modes (faithfulness, retrieval relevance, refusal)
- "Model drift in production" → `/model-monitoring` (v0.3)
- "Deployment latency too high" → `/model-deployment` (v0.3)
- "Fine-tuning is too expensive" → `/llm-fine-tuning` for LoRA/QLoRA recipes (v0.3)
