#!/usr/bin/env bash
# Notification/Stop フック用の通知メッセージ生成スクリプト
# - Notification: notification_typeをタイトル、message + ユーザーメッセージを本文として表示
# - Stop: last_assistant_messageを本文として表示

set -euo pipefail

if ! command -v jq &> /dev/null; then
  echo "[ERROR] jq command is required but not installed. Please install it via 'brew install jq'" >&2
  exit 1
fi

show_notification() {
  local message="$1"
  local title="${2:-Claude Code}"

  local escaped_message="${message//\\/\\\\}"
  escaped_message="${escaped_message//\"/\\\"}"

  local escaped_title="${title//\\/\\\\}"
  escaped_title="${escaped_title//\"/\\\"}"

  osascript -e "display notification \"$escaped_message\" with title \"$escaped_title\" sound name \"Crystal\""
}

INPUT=$(cat)

HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')
LAST_ASSISTANT_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')

if [[ -z "$HOOK_EVENT" ]]; then
  echo "[ERROR] hook_event_name is required" >&2
  exit 1
fi

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  case "$HOOK_EVENT" in
    Notification)
      show_notification "$MESSAGE"
      ;;
    Stop)
      show_notification "✓ タスク完了"
      ;;
    *)
      echo "[ERROR] Unsupported hook event: $HOOK_EVENT" >&2
      exit 1
      ;;
  esac
  exit 0
fi

LATEST_USER_MSG=$(tail -r "$TRANSCRIPT_PATH" | \
  jq -r 'select(.type == "user") |
    .message.content |
    if type == "string" then .
    elif type == "array" then
      (map(select(.type == "text")) | .[0].text // empty)
    else empty
    end' 2>/dev/null | \
  head -n 1 || true)

if [[ -z "$LAST_ASSISTANT_MSG" ]]; then
  ASSISTANT_MSG_SHORT=""
elif [[ ${#LAST_ASSISTANT_MSG} -gt 100 ]]; then
  ASSISTANT_MSG_SHORT=$(echo "$LAST_ASSISTANT_MSG" | cut -c1-97)
  ASSISTANT_MSG_SHORT="${ASSISTANT_MSG_SHORT}..."
else
  ASSISTANT_MSG_SHORT="$LAST_ASSISTANT_MSG"
fi

if [[ -z "$LATEST_USER_MSG" ]]; then
  LATEST_USER_MSG="(no user message found)"
fi

if [[ ${#LATEST_USER_MSG} -gt 100 ]]; then
  USER_MSG_SHORT=$(echo "$LATEST_USER_MSG" | cut -c1-97)
  USER_MSG_SHORT="${USER_MSG_SHORT}..."
else
  USER_MSG_SHORT="$LATEST_USER_MSG"
fi

case "$HOOK_EVENT" in
  Notification)
    NOTIF_TITLE="${NOTIFICATION_TYPE:-Claude Code}"
    if [[ -n "$MESSAGE" ]]; then
      show_notification "🤖${MESSAGE}
👤${USER_MSG_SHORT}" "$NOTIF_TITLE [Notification]"
    else
      show_notification "$USER_MSG_SHORT" "$NOTIF_TITLE [Notification]"
    fi
    ;;
  Stop)
    if [[ -n "$ASSISTANT_MSG_SHORT" ]]; then
      show_notification "✅$ASSISTANT_MSG_SHORT" "Claude Code [Stop]"
    else
      show_notification "✅ タスク完了" "Claude Code [Stop]"
    fi
    ;;
  *)
    echo "[ERROR] Unsupported hook event: $HOOK_EVENT" >&2
    exit 1
    ;;
esac
