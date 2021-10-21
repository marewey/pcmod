@echo off
wmic process where caption="javaw.exe" get commandline
pause >nul