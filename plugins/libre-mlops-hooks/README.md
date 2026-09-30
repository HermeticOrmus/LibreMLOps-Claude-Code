# libre-mlops-hooks

> Optional hooks for LibreMLOps: an ML project summary when a session starts, a confirmation prompt before Claude touches secrets files or runs commands that destroy data, models, or run history, and post-edit checks for empty writes and matching tests.

This plugin is separate from the other 20 so you choose whether hooks run in your sessions. Install it with:

```
/plugin install libre-mlops-hooks@libre-mlops
```

or from a terminal: `claude plugin install libre-mlops-hooks@libre-mlops`, or `./setup.sh --only libre-mlops-hooks` from a clone.

## What each hook does

| Event | Script | Behavior |
|---|---|---|
| SessionStart | `hooks/session-start.sh` | Reads `requirements*.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`, `environment.yml`, and `Pipfile`, and looks for `MLproject`, `dvc.yaml` or `.dvc/`, `mlruns/`, and a Feast `feature_store.yaml`. When it finds ML markers (PyTorch, TensorFlow, Hugging Face, DeepSpeed, LangChain or LlamaIndex, vector store clients, MLflow, W&B, DVC, Feast, Evidently, Great Expectations, serving libraries, Beam or Spark, labeling tools, scikit-learn and boosting libraries), it prints one line naming them and the LibreMLOps plugins that fit. Other projects get no output. |
| PreToolUse (Read, Edit, Write, MultiEdit, Bash) | `hooks/pre-tool-use.sh` | Asks you to confirm when Claude targets a `.env` file (not `.env.example`, `.env.sample`, `.env.template`, `.env.dist`), a `.pem` or `.key` file, or a non-source file whose path names credentials or secrets. For Bash it asks before `dvc gc`, `dvc remove`, `dvc destroy`, `mlflow gc`, a recursive `rm` of data, model, checkpoint, `mlruns`, `wandb`, or artifact folders, `aws s3 rm`, `gsutil rm`, SQL `DROP` or `TRUNCATE`, and forced `git push`. Everything else passes silently. |
| PostToolUse (Write, Edit, MultiEdit) | `hooks/post-tool-use.sh` | Tells Claude when a file is empty after a write. When the edited source file has a matching test file (`test_<name>.py`, `<name>_test.py`, `<name>.test.ts`, `<name>.spec.ts`, and so on), it names that file so Claude runs it. Silent otherwise. |

## Requirements

- `bash` and `jq` on the PATH. Without `jq` the hooks exit quietly and do nothing.

## Privacy

The hooks read the JSON Claude Code sends on stdin and the files in your project. They write nothing to disk and send nothing over the network.

## Origin

These scripts are ports of the original `hooks/*.sh` files at the root of this repository, which are kept for reference. The originals expected the tool name and target as command-line arguments, but Claude Code sends hook input as JSON on stdin, and the old `setup.sh` never registered them, so they never ran. They also wrote log files next to themselves. These versions read the JSON with `jq`, keep the same checks (sensitive files, destructive operations, empty writes, a nudge to run tests), and keep no logs.
