#!/usr/bin/env bash

set -uo pipefail

[[ "${HERDR_ENV:-}" == "1" && -n "${HERDR_PANE_ID:-}" ]] || exit 0

HERDR="${HERDR_BIN_PATH:-herdr}"
pane="$HERDR_PANE_ID"

cwd="$PWD"
if command -v jq >/dev/null 2>&1; then
  input_cwd="$(jq -r '.cwd // empty' 2>/dev/null || true)"
  [[ -n "$input_cwd" ]] && cwd="$input_cwd"
fi

branch="$(git -C "$cwd" branch --show-current 2>/dev/null || true)"
[[ -z "$branch" ]] && branch="$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)"
[[ -z "$branch" ]] && branch="$(basename "$cwd")"

"$HERDR" pane rename "$pane" "$branch" >/dev/null 2>&1 || true

base="$(printf '%s' "$branch" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/^[^a-z]+//; s/-+$//' | cut -c1-29)"
[[ -z "$base" ]] && exit 0

# SessionStart の時点ではまだエージェントとして検出されていないことがあるため、バックグラウンドで待ってから名前を付ける
(
  for _ in $(seq 1 15); do
    current="$("$HERDR" agent get "$pane" 2>/dev/null)" || { sleep 1; continue; }
    if [[ "$current" == *"\"name\":\"$base\""* || "$current" =~ \"name\":\"$base-[0-9]+\" ]]; then
      exit 0
    fi
    for i in "" -2 -3 -4 -5 -6 -7 -8 -9; do
      "$HERDR" agent rename "$pane" "$base$i" >/dev/null 2>&1 && exit 0
    done
    exit 0
  done
) </dev/null >/dev/null 2>&1 &
disown

exit 0
