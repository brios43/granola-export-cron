#!/bin/zsh
# Weekly Granola -> local folder + Google Drive backup.
# Driven by launchd (com.granola-export) or run manually.

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

BACKUP_DIR="$HOME/Granola-Backup"
PROMPT_FILE="$HOME/.claude/granola-export-prompt.md"
LOG_FILE="$BACKUP_DIR/.export.log"
CLAUDE_BIN="$HOME/.local/bin/claude"

mkdir -p "$BACKUP_DIR"

{
  echo "===================================================="
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Granola export"
} >> "$LOG_FILE" 2>&1

"$CLAUDE_BIN" -p "$(cat "$PROMPT_FILE")" \
  --allowedTools "mcp__claude_ai_Granola__list_meetings,mcp__claude_ai_Granola__get_meetings,mcp__claude_ai_Granola__get_meeting_transcript,mcp__claude_ai_Google_Drive__search_files,mcp__claude_ai_Google_Drive__create_file,Read,Write,Bash" \
  --permission-mode acceptEdits \
  >> "$LOG_FILE" 2>&1

STATUS=$?

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Finished (exit $STATUS)"
} >> "$LOG_FILE" 2>&1

exit $STATUS
