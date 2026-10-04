# Install from Claude Code

A user adds LibreMLOps-Claude-Code as a plugin marketplace in Claude Code and installs plugins from it by name. Each installed plugin shows as enabled under the `libre-mlops` marketplace and its components are available after a restart.

## Sub-features

- `claude-marketplace-add` registers the repo as the `libre-mlops` marketplace.
- `claude-install-one` installs one plugin as `<plugin>@libre-mlops`.
- `claude-install-all` installs every plugin in the pack (21 in total).
- `claude-list` shows each installed plugin as enabled.

## How to get to it (user POV)

- Inside Claude Code: `/plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code`, then `/plugin install rag-architecture@libre-mlops`.
- From a terminal: `claude plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code`, then `claude plugin install rag-architecture@libre-mlops`.
- `/plugin` inside Claude Code opens the plugin manager to browse the rest of the pack.

## Driving it with control-libre-mlops

Preconditions:

- `.grok/skills/verify-libre-mlops/bin/control-libre-mlops doctor` reports `worth_driving: true`.

- **Add the marketplace and install one plugin.** Run `.grok/skills/verify-libre-mlops/bin/control-libre-mlops install --claude --only rag-architecture`. `evidence/claude-marketplace-add.log` and `evidence/claude-install-rag-architecture.log` end in `exit 0`.
- **Confirm it is enabled.** The same command prints `result.json`: `claude.enabled` is 1, `claude.missing` and `claude.load_errors` are empty. `evidence/claude-list.json` has `rag-architecture@libre-mlops` with `"enabled": true`.
- **Install the whole pack.** Run `.grok/skills/verify-libre-mlops/bin/control-libre-mlops run`. `result.json` has `claude.wanted` equal to `claude.enabled` (21) and `ok: true`.
- **Proof.** Keep `evidence/claude-list.json` and `evidence/result.json` from the run.

## Gotchas

- The marketplace name is `libre-mlops` (from `.claude-plugin/marketplace.json`), not the repo name. `<plugin>@LibreMLOps-Claude-Code` fails in Claude Code.
- Installing from `HermeticOrmus/LibreMLOps-Claude-Code` installs what is on GitHub's default branch. To prove a change, install from the tree under test, which is what the helper does.
- Claude Code loads new plugins at the next session start. The proof is the list and details read back, not a live session.
