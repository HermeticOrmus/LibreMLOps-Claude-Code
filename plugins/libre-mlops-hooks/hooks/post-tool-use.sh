#!/usr/bin/env bash
# libre-mlops-hooks: PostToolUse
#
# After Claude writes or edits a file:
#   - if the file ended up empty, tell Claude, since an empty write is almost
#     always a mistake
#   - if the file is source code with a matching test file (tests/test_x.py,
#     x_test.py, x.test.ts, and similar), name that test file so Claude runs it
# Silent otherwise. Writes no files.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"

tool="$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)"
case "$tool" in Write|Edit|MultiEdit) ;; *) exit 0 ;; esac

file="$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)"
[[ -n "$file" && -f "$file" ]] || exit 0
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[[ -n "$cwd" && -d "$cwd" ]] || cwd="$(dirname "$file")"

say() {
  jq -n --arg ctx "LibreMLOps: $1" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
  exit 0
}

[[ -s "$file" ]] || say "$(basename "$file") is empty after this $tool. Check that the content was written."

name="$(basename "$file")"
ext="${name##*.}"
stem="${name%.*}"
case "$ext" in py|js|ts|go|rs|java|rb) ;; *) exit 0 ;; esac
case "$stem" in test_*|*_test|*.test|*.spec) exit 0 ;; esac

candidates=("test_$stem.$ext" "${stem}_test.$ext" "$stem.test.$ext" "$stem.spec.$ext")
found=""
for c in "${candidates[@]}"; do
  hit="$(find "$cwd" -maxdepth 6 -name "$c" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.venv/*' -print -quit 2>/dev/null)"
  [[ -n "$hit" ]] && { found="${hit#"$cwd"/}"; break; }
done
[[ -n "$found" ]] && say "$found covers $name. Run it before calling this change done."
exit 0
