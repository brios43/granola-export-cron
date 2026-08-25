#!/bin/zsh
# Installs the Granola weekly backup cron on this Mac.
# Run from inside the cloned repo: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_LABEL="com.granola-export"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

echo "Installing to $HOME ..."

mkdir -p "$HOME/.local/bin" "$HOME/.claude" "$HOME/Granola-Backup"

cp "$SCRIPT_DIR/granola-export.sh" "$HOME/.local/bin/granola-export.sh"
chmod +x "$HOME/.local/bin/granola-export.sh"

cp "$SCRIPT_DIR/granola-export-prompt.md" "$HOME/.claude/granola-export-prompt.md"

sed "s|{{HOME}}|$HOME|g" "$SCRIPT_DIR/com.granola-export.plist.template" > "$PLIST_DEST"

launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo "Done. Installed:"
echo "  - $HOME/.local/bin/granola-export.sh"
echo "  - $HOME/.claude/granola-export-prompt.md"
echo "  - $PLIST_DEST (runs Mondays 10:00)"
echo ""
echo "Before it can work, make sure:"
echo "  1. The 'claude' CLI is installed and on PATH as \$HOME/.local/bin/claude (or edit CLAUDE_BIN in granola-export.sh)"
echo "  2. In Claude, the Granola and Google Drive connectors (claude.ai MCP) are connected under YOUR account"
echo ""
echo "Test it now with:"
echo "  ~/.local/bin/granola-export.sh && cat ~/Granola-Backup/.export.log"
