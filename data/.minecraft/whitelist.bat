@echo off
mode con cols=35 lines=7
title PCMod - Whitelister
cd ..\..
echo.- Connecting to Server...
call cmd\settings.bat whitelist >>data\init.log
title PCMod - Whitelister
echo.- Results:
type data\indexes\cmdreturn
ping localhost -n 5 >nul
exit