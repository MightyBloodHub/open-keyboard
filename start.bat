@echo off
rem Open Keyboard launcher for Windows. Serves app\ on http://localhost:8765 and opens the browser.
cd /d "%~dp0app"
set PORT=8765
where py >nul 2>nul && (set PY=py -3) || (set PY=python)
start "" "http://localhost:%PORT%/"
echo Open Keyboard is running at http://localhost:%PORT%/  - close this window to stop.
%PY% -m http.server %PORT% --bind 127.0.0.1
if errorlevel 1 (
  echo.
  echo Could not start. Install Python 3 from https://www.python.org/downloads/ and try again.
  pause
)
