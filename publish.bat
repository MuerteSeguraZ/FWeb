@echo off

git add --all

set "MSG=%~1"
if "%MSG%"=="" set "MSG=feat(ws_client): add WebSocket close frame support and opcode-aware receiving"

git status

git commit -m "%MSG%"

git push origin main

pause
