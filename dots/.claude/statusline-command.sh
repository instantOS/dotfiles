#!/usr/bin/env bash
# Claude Code status line: shows context window token usage and percentage.
input=$(cat)

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Sum input + output tokens, format as Xk
total=$((total_in + total_out))
if [ "$total" -ge 1000 ]; then
  tokens="$(printf '%.1fk' "$(echo "scale=1; $total / 1000" | bc)")"
else
  tokens="${total}t"
fi

parts=""
if [ -n "$tokens" ]; then
  parts="$tokens"
fi
if [ -n "$used_pct" ]; then
  parts="$parts (${used_pct}%)"
fi

echo "$parts"
