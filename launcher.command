#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/pm-desktop-assistant.log"
mkdir -p "$LOG_DIR"

cd "$SCRIPT_DIR"

if [ ! -f "README.md" ]; then
  osascript -e 'display alert "PM Desktop Assistant" message "README.md not found. Please reinstall the app package." as critical'
  exit 1
fi

open -a TextEdit "$SCRIPT_DIR/README.md"

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Launcher opened README in TextEdit" >> "$LOG_FILE"

osascript <<'APPLESCRIPT'
display notification "PM Desktop Assistant is ready. Follow the setup steps in README." with title "PM Desktop Assistant"
APPLESCRIPT
