#!/usr/bin/env bash

cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/openai-codex/usage.json"

if ! usage=$(jq -er '.codex.usage | select(.windows | length > 0)' "$cache_file" 2>/dev/null); then
  jq -cn '{text: "AI unavailable", tooltip: "OpenAI Codex usage has not been cached by Pi yet.", class: "unavailable"}'
  exit
fi

percent=$(jq -r '.windows[0].usedPercent // 0' <<<"$usage")
reset_at=$(jq -r '.windows[0].resetAt // empty' <<<"$usage")
reset=$(date --date="$reset_at" '+%b %-d %H:%M' 2>/dev/null || printf 'unknown')
usage_lines=$(jq -r '.windows[] | "\(.label // "limit"): \(.usedPercent // 0)% (resets \(.resetAt // "unknown"))"' <<<"$usage")
plan=$(jq -r '.displayName // "Codex"' <<<"$usage")
fetched_at=$(jq -r '.codex.fetchedAt // empty' "$cache_file")
if [[ $fetched_at =~ ^[0-9]+$ ]]; then
  fetched=$(date --date="@$((fetched_at / 1000))" '+%Y-%m-%d %H:%M' 2>/dev/null || printf 'unknown')
else
  fetched=unknown
fi

if (( percent >= 90 )); then
  class=critical
elif (( percent >= 70 )); then
  class=warning
else
  class=normal
fi

jq -cn \
  --arg text "AI ${percent}% -> ${reset}" \
  --arg tooltip "${plan}\n${usage_lines}\nUpdated: ${fetched}" \
  --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
