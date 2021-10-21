@echo off
@SetLocal EnableDelayedExpansion Enableextensions
set arg1=%1
set line=###########################################################################
set mcversion=1.16.5
set url=192.168.0.27
set user=www
set pass=2716mc
set server=147.135.5.212
set hostuser=markrewey@gmail.com.412185
set hostpass=27Blue16.
:network.info
for /f "tokens=2 delims=:" %%f in ('NETSH WLAN SHOW INTERFACES ^| findstr /r "^....SSID"') do set ssid=%%f
set ssid=%ssid:~1%
if "%ssid%"=="~1" set ip=Wired&set ip=Ethernet
set url=markspi.ddns.net
if "%ssid%"=="Connjohn Mkbread" set url=192.168.0.27
if "%ssid%"=="Connjohn Mkbread the 5th" set url=192.168.0.27
if "%ssid%"=="Connjohn Mkbread the 2nd" set url=192.168.0.27
echo.Set URL: %url%
:a
echo.y|del *.zip 2>nul
title PCMod Update - INDEXing
echo.Creating an INDEX...
cd indexing
start /wait /min cmd /c conv.bat
cd ..
cls
title PCMod Update (Requesting Version)
set /p version=Version: 
echo.
echo.Update should include:
for /f "tokens=1-5 delims=;" %%a in ('type PCMod.pak') do if "%%c"=="%version%" (
	if "%%a"=="D" set char= -
	if "%%a"=="C" set char=C+
	if "%%a"=="S" set char=S+
	if "%%a"=="U" set char= +
	if "%%a"=="B" set char=*+
	if not "%%e"=="#" echo.!char! %%d [%%e]
	if "%%e"=="#" echo.!char! %%d
)
echo.[%cd%]
echo.
set /p isbeta=BETA: (y/n)
if not "%isbeta%"=="y" if not "%isbeta%"=="n" echo.BETA has to be a Y or N&pause >nul&goto :a
>DONE\version echo.%version%
title PCMod Update - %version%
call :make
call :compress
call :upload
if "%isbeta%"=="n" call :serverinstall
if "%isbeta%"=="n" call :upload.pack
echo.%version% Update has completed!&echo.%line%
pause >nul
exit

:serverinstall
echo.Press any key to install to hosting server...
title PCMod Update - %version% (...)
if not "%arg1%"=="nopause" pause >nul
echo.Are you sure?
pause >nul
title PCMod Update - %version% (Update Host)
bin\WinSCP.com /ini=nul /log=DONE\upload.log  /command ^
    "open ftp://%hostuser%:%hostpass%@%server%/" ^
    "rm /mods/*" ^
    "put %cd%\SRC\mods\* /mods/" ^
    "put %cd%\SRC\servermods\* /mods/" ^
    "put %cd%\SRC\minecraft\scripts\Shiv.zs /scripts/Shiv.zs" ^
    "exit"
echo.%line%
goto :eof
:upload
echo.Press any key to upload to download server...
title PCMod Update - %version% (Update Downloads)
bin\WinSCP.com /ini=nul /log=DONE\supload.log /command ^
    "open ftp://%user%:%pass%@%url%/" ^
	"put %cd%\DONE\%version%.size /pcmod2/updates/%version%.size" ^
	"put %cd%\SRC\cmd\update.bat /pcmod2/updates/cmd/update.bat" ^
	"put %cd%\SRC\cmd\settings.bat /pcmod2/updates/cmd/settings.bat" ^
	"put %cd%\SRC\cmd\launch.bat /pcmod2/updates/cmd/launch.bat" ^
	"put %cd%\SRC\root\PCMod.hta /pcmod2/updates/root/PCMod.hta" ^
	"put %cd%\SRC\minecraft\scripts\Shiv.zs /pcmod2/updates/scripts/Shiv.zs" ^
	"put %cd%\DONE\PCMod_update_%version%.zip /pcmod2/updates/PCMod_update_%version%.zip" ^
	"put %cd%\SRC\updatemods\* /pcmod2/mods/" ^
	"put %cd%\PCMod.pak /pcmod2/updates/PCMod.pak" ^
    "exit"
echo.%line%
goto :eof
:upload.pack
echo.Press any key to start the Package Upload...
if not "%arg1%"=="nopause" pause >nul
echo.Starting the Package Upload...
ping localhost -n 6 >nul
bin\WinSCP.com /ini=nul /log=DONE\supload.log /command ^
    "open ftp://%user%:%pass%@%url%/" ^
	"put %cd%\DONE\version /pcmod2/version" ^
    "put %cd%\DONE\PCMod2.zip /pcmod2/downloads/PCMod2.zip" ^
    "put %cd%\DONE\ModPack.zip /pcmod2/downloads/ModPack.zip" ^
    "exit"
echo.%line%
goto :eof

:compress
title PCMod Update - %version% (Compress Update)
bin\7za.exe a PCMod_update_%version%.zip .\SKELE\update_%version%\*
title PCMod Update - %version% (Compress PCMod)
if "%isbeta%"=="n" bin\7za.exe a PCMod2.zip .\SKELE\PCMod\*
title PCMod Update - %version% (Compress Modpack)
if "%isbeta%"=="n" bin\7za.exe a ModPack.zip .\SKELE\modpack\*
move *.zip DONE\
FOR /F "usebackq" %%A IN ('DONE\PCMod_update_%version%.zip') DO set size=%%~zA
>DONE\%version%.size echo.%size%
echo.%line%
goto :eof

:make
bin\wget -O SRC\data\pages\news.html http://%url%/pcmod2/updates/news.html
copy .\DONE\version .\SRC\data\indexes\
call :make.mods
call :skins
call :make.update
if not "%isbeta%"=="y" call :make.pcmod
if not "%isbeta%"=="y" call :make.modpack
call :verify
echo.%line%
goto :eof
:make.mods
title PCMod Update - %version% (Make Mods)
echo.Cleaning mods folders...
echo.y|del SRC\clientmods\* >nul
echo.y|del SRC\mods\*
echo.y|del SRC\updatemods\*
echo.y|del SRC\servermods\*
echo.y|del "SKELE\PCMod\data\.minecraft\mods\*"
echo.y|del "SKELE\update_%version%\data\.minecraft\mods\*"
echo.y|del "SKELE\Modpack\mods\*"
echo.y|del /s "SKELE\PCMod\data\.minecraft\config\*"
echo.y|del /s "SKELE\update_%version%\data\.minecraft\config\*"
echo.y|del /s "SKELE\Modpack\data\.minecraft\config\*"
echo.Creating updatemod folder with index: PCMod.pak, %version%
for /f "tokens=1-5 delims=;" %%a in ('type PCMod.pak') do (
	if "%%a"=="U" if "%%c"=="%version%" copy "MODLIB\PCMod\%%b" "SRC\updatemods\" >nul&echo.%%d
	if "%%a"=="B" if "%%c"=="%version%" copy "MODLIB\PCMod\%%b" "SRC\updatemods\" >nul&echo.%%d
	if "%%a"=="C" if "%%c"=="%version%" copy "MODLIB\PCMod\%%b" "SRC\updatemods\" >nul&echo.%%d
)
set ucount=0&set ccount=0&set scount=0&set bcount=0
echo.Creating mod folder with index: PCMod.pak
for /f "tokens=1-5 delims=;" %%a in ('type PCMod.pak') do (
	if "%%a"=="U" copy "MODLIB\PCMod\%%b" "SRC\mods\" >nul&echo.UNIMOD : %%d&set /a ucount=!ucount!+1
	if "%%a"=="B" copy "MODLIB\PCMod\%%b" "SRC\mods\" >nul&echo.COREMOD: %%d&set /a bcount=!bcount!+1
	if "%%a"=="S" copy "MODLIB\PCMod\%%b" "SRC\servermods\" >nul&echo.SERVER : %%d&set /a scount=!scount!+1
	if "%%a"=="C" copy "MODLIB\PCMod\%%b" "SRC\clientmods\" >nul&echo.CLIENT : %%d&set /a ccount=!ccount!+1
)
mkdir SKELE\Modpack\mods\ 2>nul
mkdir SKELE\PCMod\data\.minecraft\mods\ 2>nul
mkdir SKELE\update_%version%\data\.minecraft\mods\ 2>nul
goto :eof
:make.update
rd /s /q SKELE\update_%version%
echo.Creating SKELE\update_%version%
title PCMod Update - %version% (Make Update)
mkdir SKELE\update_%version% 2>nul
mkdir SKELE\update_%version%\bin 2>nul
mkdir SKELE\update_%version%\data\backup 2>nul
mkdir SKELE\update_%version%\data\icons 2>nul
mkdir SKELE\update_%version%\data\indexes 2>nul
mkdir SKELE\update_%version%\data\pages 2>nul
mkdir SKELE\update_%version%\data\.minecraft\mods\ 2>nul
mkdir SKELE\update_%version%\data\.minecraft\config 2>nul
mkdir SKELE\update_%version%\data\.minecraft\scripts 2>nul
mkdir SKELE\update_%version%\cmd 2>nul
echo.Making SKELE\update_%version%
echo.a|xcopy /e "SRC\root\*" "SKELE\update_%version%\"
echo.a|xcopy /e "SRC\bin\*" "SKELE\update_%version%\bin\"
echo.y|del /s "SKELE\update_%version%\bin\jre_x64"
echo.y|rd /s "SKELE\update_%version%\bin\jre_x64"
echo.a|xcopy /e "SRC\data\*" "SKELE\update_%version%\data\"
copy "PCMod.pak" "SKELE\update_%version%\data\indexes\"
echo.a|xcopy /e "SRC\cmd\*" "SKELE\update_%version%\cmd\"
echo.a|xcopy /e "SRC\updatemods\*" "SKELE\update_%version%\data\.minecraft\mods\"
echo.a|xcopy /e "SRC\config\*" "SKELE\update_%version%\data\.minecraft\config\"
echo.a|xcopy /e "SRC\minecraft_update\*" "SKELE\update_%version%\data\.minecraft\"
echo.a|xcopy /e "SRC\minecraft_update\*" "SRC\minecraft\"
copy "SRC\skins\*.png" "SKELE\update_%version%\cachedImages\skins\"
echo.y|del SKELE\update_%version%\data\.minecraft\options.txt
goto :eof
:make.pcmod
echo.Making SKELE\PCMod\
title PCMod Update - %version% (Make PCMod)
echo.a|xcopy /e "SRC\root\*" "SKELE\PCMod\"
echo.a|xcopy /e "SRC\bin\*" "SKELE\PCMod\bin\"
echo.a|xcopy /e "SRC\data\*" "SKELE\PCMod\data\"
copy "PCMod.pak" "SKELE\PCMod\data\indexes\"
copy "LICENSE.txt" "SKELE\PCMod\data\"
echo.a|xcopy /e "SRC\cmd\*" "SKELE\PCMod\cmd\"
echo.a|xcopy /e "SRC\mods\*" "SKELE\PCMod\data\.minecraft\mods\"
echo.a|xcopy /e "SRC\clientmods\*" "SKELE\PCMod\data\.minecraft\mods\"
echo.a|xcopy /e "SRC\config_base\*" "SKELE\PCMod\data\.minecraft\config\"
echo.a|xcopy /e "SRC\minecraft\*" "SKELE\PCMod\data\.minecraft\"
copy "SRC\skins\*.png" "SKELE\PCMod\data\.minecraft\cachedImages\skins\"
goto :eof
:make.modpack
echo.Making SKELE\Modpack
title PCMod Update - %version% (Make Modpack)
echo.a|xcopy /e "SRC\mods\*" "SKELE\Modpack\mods\"
echo.a|xcopy /e "SRC\clientmods\*" "SKELE\Modpack\mods\"
echo.a|xcopy /e "SRC\clientmods\*" "SKELE\Modpack\mods\"
echo.a|xcopy /e "SRC\config_base\*" "SKELE\Modpack\config\"
echo.a|xcopy /e "SRC\minecraft\*" "SKELE\Modpack\"
copy "LICENSE.txt" "SKELE\Modpack\"
copy "SRC\bin\Minecraft.jar" "SKELE\Modpack\bin\Minecraft.jar"
copy "PCMod.pak" "SKELE\Modpack\bin\"
copy "SRC\bash\*.sh" "SKELE\Modpack\bin\"
copy "SRC\skins\*.png" "SKELE\Modpack\cachedImages\skins\"
goto :eof
:skins
echo.Downloading offline skins...
bin\wget -O bin\skindex http://%url%/pcmod2/skins/index 2>nul&echo.Getting userlist...
for /f "tokens=1-2 delims= " %%a in ('type bin\skindex') do bin\wget -O "SRC\skins\%%a.png" "http://%url%/pcmod2/skins/%%a" 2>nul&echo.Getting skin for "%%a" ...
goto :eof
:verify
echo.Verifying all Mods are present...
set ucount_=0&set ccount_=0&set scount_=0
for /f %%a in ('dir /b /a:-d SRC\mods 2^>nul') do set /a ucount_=!ucount_!+1
for /f %%a in ('dir /b /a:-d SRC\clientmods 2^>nul') do set /a ccount_=!ccount_!+1
for /f %%a in ('dir /b /a:-d SRC\servermods 2^>nul') do set /a scount_=!scount_!+1
set /a totalmods_=%ucount_%+%ccount_%+%scount%
set /a totalmods=%ucount%+%ccount%+%bcount%+%scount%
set /a ucount_=%ucount_%-%bcount%
set /a bcount_=%bcount%
echo. Universal mods listed: %ucount%
echo. Universal mods found: %ucount_%
echo. Core mods listed: %bcount%
echo. Core mods found: %bcount_%
echo. Client-side mods listed: %ccount%
echo. Client-side mods found: %ccount_%
echo. Server-side mods listed: %scount%
echo. Server-side mods found: %scount_%
echo. Total mods listed: %totalmods%
echo. Total mods found: %totalmods_%
if not "%ucount%"=="%ucount_%" echo.Found %ucount_% Universal Mods. %ucount% Mods requested.&set pause=1&echo.(Check Coremods as well)
if not "%ccount%"=="%ccount_%" echo.Found %ccount_% Client Mods. %ccount% Mods requested.&set pause=1
if not "%scount%"=="%scount_%" echo.Found %scount_% Server Mods. %scount% Mods requested.&set pause=1
ping localhost -n 3 >nul
if "%pause%"=="1" pause >nul
goto :eof