# Kintsugi ledger: LibreMLOps-Claude-Code

Kintsugi mends broken pottery with gold, so the repair is the part you see. Here it means every crack we found in LibreMLOps is written down with its evidence and the seal that closed it, so you can check the gold yourself.

A row is `hallmarked` when its seal shipped in a release that was verified by installing from GitHub into a clean config. Grades: `hairline` is copy or cosmetic, `fracture` is wrong behavior with a workaround, `break` means it did not work or broke a safety promise. IDs are never reused.

| ID | Crack | Evidence | Grade | Tracker | Seal | State |
|----|-------|----------|-------|---------|------|-------|
| K-01 | Nothing installed: the repo had no marketplace or plugin manifests, and the old `setup.sh` copied folders into `~/.claude/plugins`, where Claude Code does not load plugins from. | [PR #2][pr2], [CHANGELOG 1.0.0 L5][a5], [L8][a8], [L20][a20] | break | filed #1 | `marketplace.json` plus a `plugin.json` per plugin; `setup.sh` installs through `claude plugin`; large | hallmarked |
| K-02 | Agents and commands lived in `agents/<name>/AGENT.md` and `commands/<name>/COMMAND.md`, and the RAG skill was a loose `.md` file: layouts Claude Code does not load. | [PR #2][pr2], [CHANGELOG 1.0.0 L17][a17] | break | filed #1 | Moved with `git mv` to `agents/<name>.md`, `commands/<name>.md`, and `skills/rag-architecture/SKILL.md`, content kept; medium | hallmarked |
| K-03 | 62 of the 63 agent, command, and skill files had no frontmatter, so Claude Code could not route to them. | [PR #2][pr2], [CHANGELOG 1.0.0 L9][a9]; count taken from `main` before the release (`20b1576`) | break | filed #1 | A routing description on every file, and an `argument-hint` listing the actions on every command; large | hallmarked |
| K-04 | rag-architecture carried two copies of each component: `rag-architect` next to `rag-engineer`, two `/rag` commands, and `rag-patterns` next to `rag-architecture`. | [PR #2][pr2], [CHANGELOG 1.0.0 L18][a18] | fracture | filed #1 | The unique material of the older copies merged into the newer files, then the older copies removed; medium | hallmarked |
| K-05 | `rag-engineer` was pinned to Sonnet instead of the session's model. | [PR #2][pr2], [CHANGELOG 1.0.0 L19][a19] | fracture | filed #1 | `model: inherit`; small | hallmarked |
| K-06 | The hook scripts read command-line arguments, but Claude Code sends hook input as JSON on stdin, so they never received anything. | [PR #2][pr2], `hooks/pre-tool-use.sh:5` (the original, kept for reference), [CHANGELOG 1.0.0 L24][a24] | break | filed #1 | The `libre-mlops-hooks` scripts read the JSON with `jq` and answer in the format Claude Code expects; medium | hallmarked |
| K-07 | The old `setup.sh` never registered the hook scripts, so they never ran. | [PR #2][pr2], [CHANGELOG 1.0.0 L24][a24] | break | filed #1 | The `libre-mlops-hooks` plugin wires them through `hooks/hooks.json` and `${CLAUDE_PLUGIN_ROOT}`; medium | hallmarked |
| K-08 | The hook scripts wrote log files next to themselves. | [PR #2][pr2], `hooks/session-start.sh:5`, `hooks/post-tool-use.sh:9`, [CHANGELOG 1.0.0 L24][a24] | fracture | filed #1 | The plugin scripts write nothing to disk; small | hallmarked |
| K-09 | QUICK_START and TROUBLESHOOTING described the old install and used command names that do not exist. | [PR #2][pr2], [CHANGELOG 1.0.0 L21][a21] | hairline | filed #1 | Both cover the plugin install and use the real names (`/monitor-model`, `/deploy-model`, `/fine-tune`); small | hallmarked |
| K-10 | The README lists JAX under Compatibility, but no plugin covers JAX. | `README.md:143` ("JAX (light)"); no file under `plugins/` mentions JAX; [pantry queue][queue] atom 5 | hairline | Menu atom `jax-patterns` | A `jax-patterns` plugin covering `jit`, `vmap`, sharding, and one Flax or Equinox model with a runnable example; medium | open |
| K-11 | The `libre-mlops-hooks` plugin has not run inside a live Grok Build session, so its runtime behavior there is unverified. | `grok plugin validate plugins/libre-mlops-hooks` passes and lists hooks (grok 1.0.44). *Inferred*: Grok's hooks guide shows a camelCase stdin envelope (`toolName`, `toolInput`, Grok tool names); fed that envelope for a `.env` edit, `pre-tool-use.sh` prints nothing, while the Claude Code envelope gets `ask`. | hairline | new | Read both envelopes (`.tool_name // .toolName`, `.tool_input // .toolInput`) and Grok tool names, then record each hook's output in a live Grok session; small | open |

[pr2]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/pull/2
[a5]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L5
[a8]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L8
[a9]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L9
[a17]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L17
[a18]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L18
[a19]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L19
[a20]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L20
[a21]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L21
[a24]: https://github.com/HermeticOrmus/LibreMLOps-Claude-Code/blob/d129beed47bbb52bd166a5c1589ee17031478617/CHANGELOG.md?plain=1#L24
[queue]: pantry/2026-09-30-pantry-queue.md

<p align="center"><img src="https://brand.ormus.solutions/assets/marks/kintsugi-mark.svg" alt="Kintsugi mark" width="48" /></p>
