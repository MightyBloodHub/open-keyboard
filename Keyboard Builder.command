#!/bin/bash
# Open Keyboard (Keyboard Builder) launcher — double-click on macOS.
# Serves the app on a FIXED localhost port (so your saved keys/recordings,
# which the browser stores per address, are found again next time) and opens it.
cd "$(dirname "$0")/app" || exit 1
PORT=8765
URL="http://localhost:$PORT/"
PY=$(command -v python3 || command -v python)
if [ -z "$PY" ]; then
  osascript -e 'display alert "Keyboard Builder needs Python 3" message "Run: xcode-select --install   (in Terminal), then try again."' 2>/dev/null
  echo "python3 not found. Install with: xcode-select --install"; read -r -p "Press Enter to close"; exit 1
fi
# Already running (e.g. another window)? Just open it.
if curl -s --max-time 1 "$URL" 2>/dev/null | grep -qE "Open Keyboard|Keyboard Builder"; then
  open "$URL"; echo "Keyboard Builder is already running at $URL"; exit 0
fi
if lsof -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT is used by another program. Close it and try again."; read -r -p "Press Enter to close"; exit 1
fi
"$PY" -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT INT TERM HUP
for i in $(seq 1 30); do curl -s --max-time 1 "$URL" >/dev/null 2>&1 && break; sleep 0.2; done
open "$URL"
echo "Keyboard Builder is running at $URL"
echo "Keep this window open while you play. Close it (or press Ctrl+C) to quit."
wait $SERVER
