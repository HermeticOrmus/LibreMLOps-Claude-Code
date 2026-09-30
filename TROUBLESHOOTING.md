# Troubleshooting

## Plugins not loaded
```bash
claude plugin list | grep -c '@libre-mlops'
```
Should print 21 after a full `./setup.sh` (20 plugins plus `libre-mlops-hooks`). Restart Claude Code after installing; plugins load at startup. `claude plugin details rag-architecture@libre-mlops` shows what one plugin contains, and `claude plugin enable <plugin>@libre-mlops` turns a disabled one back on.

## Installed with an older setup.sh

Versions before 1.0.0 copied plugin folders into `~/.claude/plugins/libre-mlops-*`. Claude Code does not load plugins from there, so those copies never ran. Remove them (`rm -rf ~/.claude/plugins/libre-mlops-*`) and install again with `./setup.sh` or `/plugin install`.

## Common scenarios

- "RAG hallucinates" → `/rag` walks failure modes (faithfulness, retrieval relevance, refusal); `/rag optimize` maps low RAGAS scores to fixes
- "Model drift in production" → `/monitor-model drift`
- "Deployment latency too high" → `/deploy-model scale` for batching and resources
- "Fine-tuning is too expensive" → `/fine-tune` for LoRA/QLoRA recipes

## The hooks do nothing

`libre-mlops-hooks` needs `jq` on the PATH. Without it the hooks exit quietly. The session-start line only appears in projects with ML markers (framework dependencies, `MLproject`, `dvc.yaml`, `mlruns/`, or a Feast repo).
