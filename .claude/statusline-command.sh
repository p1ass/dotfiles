#!/bin/bash
# Claude Code status line
# 表示項目: モデル表示名 / コンテキスト残量メーター / Claude.ai レート制限メーター (5h・7d) / git ブランチ
# メーター描画と色分けは以下を参考にした:
# https://dev.classmethod.jp/articles/claude-code-statusline/
# 生成: statusline-setup agent

input=$(cat)

C_GREEN=$'\033[32m'
C_YELLOW=$'\033[33m'
C_RED=$'\033[31m'
C_DIM=$'\033[2m'
C_RESET=$'\033[0m'

round() {
  printf '%.0f' "$1"
}

# 使用率（0-100 の整数）に応じてメーターを描く。width は塗りマスの総数
make_bar() {
  local pct=$1 width=${2:-10}
  local filled=$((pct * width / 100))
  [ "$filled" -gt "$width" ] && filled="$width"
  [ "$filled" -lt 0 ] && filled=0
  local empty=$((width - filled))
  local out=""
  for ((i = 0; i < filled; i++)); do out="${out}▓"; done
  for ((i = 0; i < empty; i++)); do out="${out}░"; done
  printf '%s' "$out"
}

# 残量（0-100 の整数）に応じて色を選ぶ。50%以上は緑、25%以上は黄、それ未満は赤
color_for_remaining() {
  local pct=$1
  if [ "$pct" -ge 50 ]; then
    echo "$C_GREEN"
  elif [ "$pct" -ge 25 ]; then
    echo "$C_YELLOW"
  else
    echo "$C_RED"
  fi
}

model=$(echo "$input" | jq -r '.model.display_name // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
five_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

parts=()

[ -n "$model" ] && parts+=("${C_DIM}${model}${C_RESET}")

# コンテキスト: バーの塗りとラベルは使用率、色は残量で判定する（低いほど赤）
if [ -n "$ctx_used" ]; then
  used_i=$(round "$ctx_used")
  if [ -n "$ctx_remaining" ]; then
    remaining_i=$(round "$ctx_remaining")
  else
    remaining_i=$((100 - used_i))
  fi
  bar=$(make_bar "$used_i" 6)
  color=$(color_for_remaining "$remaining_i")
  parts+=("${color}Ctx ${bar} ${used_i}%${C_RESET}")
fi

# レート制限は used_percentage しか来ないので、色判定用に remaining = 100 - used を計算する
# バー幅はコンテキストより狭くして 1 行に収める
if [ -n "$five_used" ]; then
  five_i=$(round "$five_used")
  five_remaining_i=$((100 - five_i))
  bar5=$(make_bar "$five_i" 6)
  color5=$(color_for_remaining "$five_remaining_i")
  parts+=("${color5}5h ${bar5} ${five_i}%${C_RESET}")
fi

if [ -n "$week_used" ]; then
  week_i=$(round "$week_used")
  week_remaining_i=$((100 - week_i))
  bar7=$(make_bar "$week_i" 6)
  color7=$(color_for_remaining "$week_remaining_i")
  parts+=("${color7}7d ${bar7} ${week_i}%${C_RESET}")
fi

[ -n "$branch" ] && parts+=("${C_DIM}${branch}${C_RESET}")

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then
    out="$p"
  else
    out="${out}${C_DIM} | ${C_RESET}${p}"
  fi
done

printf '%s' "$out"
