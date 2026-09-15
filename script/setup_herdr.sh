#! /usr/bin/env bash

set -euo pipefail

if ! command -v herdr >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/herdr" ]]; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi

HERDR="$(command -v herdr || echo "$HOME/.local/bin/herdr")"

# Claude Code 上でエージェントの状態を検出するための hook を入れる
"$HERDR" integration install claude

# Claude Code から Herdr のペインやエージェントを操作するための skill
mkdir -p "$HOME/.claude/skills/herdr"
"$HERDR" --skill > "$HOME/.claude/skills/herdr/SKILL.md"
