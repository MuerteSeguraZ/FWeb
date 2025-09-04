@echo off

git add --all

set "MSG=%~1"
if "%MSG%"=="" set "MSG=Implement WebSocket ping/pong frame handling"
"

git status

git commit -m "%MSG%"

git push origin main

pause
