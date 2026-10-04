# Plugin components load

Each installed plugin brings its skills, commands, agents and hooks into the CLI. A plugin that installs but fails to load a component is broken for the user even when its install exits 0.

## Sub-features

- `components-claude` lists a plugin's skills, agents, hooks and MCP servers in Claude Code.
- `components-grok` lists a plugin's skill, command and agent folders in Grok Build.
- `load-errors` reports any plugin that Claude Code could not load.

## How to get to it (user POV)

- Inside Claude Code, `/plugin` shows each installed plugin and its components; from a terminal, `claude plugin details rag-architecture@libre-mlops`.
- From a terminal, `grok plugin details rag-architecture`.

## Driving it with control-libre-mlops

Preconditions:

- `.grok/skills/verify-libre-mlops/bin/control-libre-mlops doctor` reports `worth_driving: true`.

- **Install and inventory.** Run `.grok/skills/verify-libre-mlops/bin/control-libre-mlops run --only rag-architecture`. `evidence/details-claude-rag-architecture.txt` has a `Component inventory` block and `evidence/details-grok-rag-architecture.txt` has a `components:` line.
- **No load errors.** In the printed `result.json`, `claude.load_errors` is empty and `ok` is true.
- **A changed component.** For a change that adds or renames a skill, command or agent, run `.grok/skills/verify-libre-mlops/bin/control-libre-mlops install --only <plugin>` and then `.grok/skills/verify-libre-mlops/bin/control-libre-mlops details <plugin>`. The new name appears in the Claude Code inventory, and the Grok counts match the folders in the plugin.
- **Proof.** Keep the two details files and `result.json`, then run `.grok/skills/verify-libre-mlops/bin/control-libre-mlops cleanup` after an `install`.

## Gotchas

- Claude Code lists a plugin's commands with its skills in `details`; there is no separate commands line.
- Grok's `details` counts component folders, not individual skills.
- An install that exits 0 can still carry load errors. Read `load_errors`, not only the install log.
