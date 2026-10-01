# Changelog

## [1.1.0] - 2026-09-30

### Added
- A public pantry (`pantry/`): a competitor map, an X mine and a people mine, each row cited, plus a pantry queue of Goal atoms with a Done-when anyone can check.
- The Menu (`pantry/MENU.md`), generated from the pantry queue, which names one atom as up next.
- Two issue forms: routing miss (Claude picked the wrong agent or skill) and plugin proposal (a new plugin, agent, skill or command), with the `routing-miss` and `plugin-proposal` labels.
- A Ways to contribute section in CONTRIBUTING.md (Menu items, routing misses, new plugins, translations, sharing what you built) with the local test loop, and a Contribute section in the README.
- Grok Build support: `.grok-plugin/marketplace.json`, generated from the Claude Code manifest by `scripts/sync-grok-manifest.py`, so `grok plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code` lists all 21 plugins. CI fails when the file drifts, validates every plugin with `grok plugin validate`, and installs them all into a clean Grok home. README and QUICK_START show the Grok Build install.
- `setup.sh --grok` installs through the Grok Build CLI instead of Claude Code, with the same `--only`, `--list`, and `--uninstall`.
- `LEDGER.md`, the kintsugi ledger: every crack the 1.0.0 release found and sealed, with evidence, and the cracks still open.

## [1.0.0] - 2026-09-30

The pack is now a Claude Code plugin marketplace. Before this release, `setup.sh` copied folders into `~/.claude/plugins`, where Claude Code does not load plugins from, so none of the agents, commands, or skills were reachable. From 1.0.0 every plugin installs and loads.

### Added
- Plugin marketplace `libre-mlops` (`.claude-plugin/marketplace.json`) and a `plugin.json` for every plugin. Install with `/plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code`, then `/plugin install <plugin>@libre-mlops`.
- Frontmatter with routing descriptions on all 20 agents, 20 commands, and 20 skills, so Claude Code knows when to use each one. Every command carries an `argument-hint` listing its actions.
- `libre-mlops-hooks`, an optional 21st plugin with three working hooks: a one-line summary of the project's ML stack at session start, a confirmation prompt before Claude reads or edits `.env`, key, or secrets files or runs commands that destroy data, models, or run history, and post-edit checks for empty writes and for a matching test file to run.
- `/rag` gains four actions (`build`, `query`, `evaluate`, `optimize`) with working LangChain, cross-encoder, and RAGAS code and a list of options, merged in from the older nested command.
- CI (`.github/workflows/validate.yml`) validates the marketplace and every plugin, then installs all of them into a clean config, on pushes to `main` and on pull requests.
- A feedback issue form and a Feedback section in the README.
- A Command column in the README plugin tables.

### Changed
- Layout: agents moved from `agents/<name>/AGENT.md` to `agents/<name>.md`, commands from `commands/<name>/COMMAND.md` to `commands/<name>.md`, and the loose RAG skill to `skills/rag-architecture/SKILL.md`. File contents moved with them.
- rag-architecture: the older `rag-architect` agent, nested `/rag` command, and `rag-patterns` skill covered the same ground as the newer `rag-engineer` agent, `/rag` command, and `rag-architecture` skill. Their unique material (component reference for chunking, embeddings, vector stores, hybrid search, re-ranking, and RAGAS, the workflow and tools stack, the four `/rag` actions, and five implementation patterns with anti-patterns) now lives in the newer files, and the older copies are gone. If you called `rag-architect` or the `rag-patterns` skill by name, use `rag-engineer` and `rag-architecture`.
- `rag-engineer` runs on the session's model (`model: inherit`) instead of pinning Sonnet.
- `setup.sh` installs through the Claude Code CLI (`claude plugin marketplace add`, `claude plugin install`). New flags: `--list`, `--scope`, `--uninstall`. `--plugins-dir` is still accepted and ignored with a note.
- QUICK_START and TROUBLESHOOTING cover the new install and use the real command names (`/monitor-model`, `/deploy-model`, `/fine-tune`).

### Fixed
- The repository hook scripts expected command-line arguments, but Claude Code sends hook input as JSON on stdin, and the old `setup.sh` never registered them, so they never ran. They also wrote log files next to themselves. The `libre-mlops-hooks` versions read the JSON with `jq`, answer in the format Claude Code expects, and write nothing to disk. The originals stay in `hooks/` for reference.

### Upgrading from 0.2.0
- Remove the old copies, which never loaded: `rm -rf ~/.claude/plugins/libre-mlops-*`
- Install again with `./setup.sh` or `/plugin install <plugin>@libre-mlops`, then restart Claude Code.

## [0.2.0] — 2026-05-23

- LibreUIUX doc chrome applied
- **rag-architecture** plugin promoted to depth-complete
- 3-tier learning paths added
- 20 plugins total: 1 depth-complete, 19 shell-improved

### v0.3-v0.5 priorities
- v0.3: model-deployment, model-monitoring, llm-fine-tuning
- v0.4: data-pipelines, vector-databases, prompt-engineering
- v0.5: distributed-training, gpu-optimization, experiment-tracking

## [0.1.0]
20 plugin shells. Initial release.
