#!/usr/bin/env bash
# Open Keyboard launcher for macOS / Linux.
# Serves app/ on a FIXED localhost port (saved keyboards live in the browser's storage for
# that exact address) and opens the default browser. Ctrl+C to stop.
cd "$(dirname "$0")/app" || exit 1
PORT="${PORT:-8765}"
URL="http://localhost:$PORT/"
PY="$(command -v python3 || command -v python)"
[ -z "$PY" ] && { echo "Python 3 is required (https://www.python.org/downloads/)."; exit 1; }
open_url(){ if command -v open >/dev/null; then open "$1"; elif command -v xdg-open >/dev/null; then xdg-open "$1" >/dev/null 2>&1; else echo "Open $1 in your browser"; fi; }
if curl -s --max-time 1 "$URL" 2>/dev/null | grep -qE "Open Keyboard|Keyboard Builder"; then
  echo "Already running at $URL"; open_url "$URL"; exit 0
fi
"$PY" -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT INT TERM HUP
for _ in $(seq 1 30); do curl -s --max-time 1 "$URL" >/dev/null 2>&1 && break; sleep 0.2; done
if ! kill -0 $SERVER 2>/dev/null; then echo "Could not start the server — is port $PORT in use? Try: PORT=8766 ./start.sh (note: each port has its own saved data)"; exit 1; fi
echo "Open Keyboard is running at $URL — press Ctrl+C to stop."
open_url "$URL"
wait $SERVER
