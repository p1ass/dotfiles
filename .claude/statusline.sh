#!/bin/bash
# Claude Code Enhanced Status Line
# Model | Context | In/Out

CLAUDE_DIR="$HOME/.claude"

input=$(cat)

# Extract data
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

current_used=$(awk "BEGIN {printf \"%.0f\", ($used_pct * $context_size) / 100}")

# Format number with k/M suffix
fmt() {
  local n=$1
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fM\", $n/1000000}"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fk\", $n/1000}"
  else
    echo "${n:-0}"
  fi
}

# Build progress bar
pct_int=$(awk "BEGIN {printf \"%.0f\", ${used_pct:-0}}" 2>/dev/null || echo "0")
filled=$((pct_int / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# Performance zone indicator
if [ "$pct_int" -ge 90 ]; then
  perf="🔴 Critical"
elif [ "$pct_int" -ge 70 ]; then
  perf="🟠 Warning"
elif [ "$pct_int" -ge 50 ]; then
  perf="🟡 Caution"
else
  perf="🟢 Good"
fi

# Output (1 line)
# Session context status
if [ -n "$git_branch" ]; then
  printf "%s │ %s │ %s/%s %s %d%% %s │ ⬇%s ⬆%s" \
    "$git_branch" \
    "$model" \
    "$(fmt $current_used)" \
    "$(fmt $context_size)" \
    "$bar" \
    "$pct_int" \
    "$perf" \
    "$(fmt $total_input)" \
    "$(fmt $total_output)"
else
  printf "🤖 %s │ 📊 %s/%s %s %d%% %s │ ⬇%s ⬆%s" \
    "$model" \
    "$(fmt $current_used)" \
    "$(fmt $context_size)" \
    "$bar" \
    "$pct_int" \
    "$perf" \
    "$(fmt $total_input)" \
    "$(fmt $total_output)"
fi

