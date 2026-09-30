#!/usr/bin/env bash
# libre-mlops-hooks: PreToolUse
#
# Claude Code sends the tool call as JSON on stdin. Asks the user first when:
#   - a Read, Edit, Write, or MultiEdit targets a file that usually holds
#     secrets (.env files, .pem or .key files, credentials or secrets files)
#   - a Bash command would destroy ML data or artifacts: dvc gc, dvc remove,
#     dvc destroy, mlflow gc, rm -r on data, model, checkpoint, or run folders,
#     aws s3 rm, gsutil rm, SQL DROP or TRUNCATE, or a forced git push
# Every other call passes through silently.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"

ask() {
  jq -n --arg reason "LibreMLOps: $1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
  exit 0
}

tool="$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"

case "$tool" in
  Read|Edit|Write|MultiEdit)
    path="$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)"
    [[ -n "$path" ]] || exit 0
    rel="$path"
    [[ -n "$cwd" ]] && rel="${path#"$cwd"/}"
    base="$(basename "$path")"
    lbase="$(tr '[:upper:]' '[:lower:]' <<<"$base")"
    lower="$(tr '[:upper:]' '[:lower:]' <<<"$rel")"
    case "$lbase" in
      .env.example|.env.sample|.env.template|.env.dist) exit 0 ;;
      .env|.env.*) ask "$base looks like an environment file. Confirm before Claude reads or changes it." ;;
      *.pem|*.key) ask "$base looks like a private key or certificate file. Confirm before Claude reads or changes it." ;;
      *.py|*.ipynb|*.ts|*.js|*.go|*.java|*.scala|*.rs|*.md) exit 0 ;;
    esac
    grep -qE '(^|/)[^/]*(credential|secret)[^/]*(/|$)' <<<"$lower" \
      && ask "$base looks like a credentials or secrets file. Confirm before Claude reads or changes it."
    ;;
  Bash)
    cmd="$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)"
    [[ -n "$cmd" ]] || exit 0
    lc="$(tr '[:upper:]' '[:lower:]' <<<"$cmd")"
    if grep -qE '(^|[;&| ])dvc +(gc|remove|destroy)( |$)' <<<"$lc"; then
      ask "this runs a DVC command that deletes tracked data or cache. Confirm first."
    elif grep -qE '(^|[;&| ])mlflow +gc( |$)' <<<"$lc"; then
      ask "mlflow gc permanently deletes runs marked as deleted, with their artifacts. Confirm first."
    elif grep -qE '(^|[;&| ])rm +-[a-z]*r[a-z]* .*(data|dataset|datasets|models?|checkpoints?|mlruns|wandb|artifacts|\.dvc)(/|\b)' <<<"$lc"; then
      ask "this recursively deletes what looks like data, models, checkpoints, or run history. Confirm first."
    elif grep -qE '(^|[;&| ])(aws +s3 +rm|gsutil +(-m +)?rm)( |$)' <<<"$lc"; then
      ask "this deletes objects from cloud storage. Confirm first."
    elif grep -qE '(drop +(table|database|schema)|truncate +table)' <<<"$lc"; then
      ask "this runs a SQL statement that drops or empties data. Confirm first."
    elif grep -qE '(^|[;&| ])git +push .*(--force|-f( |$))' <<<"$lc"; then
      ask "this force-pushes, which can overwrite history others depend on. Confirm first."
    fi
    ;;
esac
exit 0
