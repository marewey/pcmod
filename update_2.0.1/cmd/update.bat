@echo off
::Set variables
set version=%1
set base_update=2.0.0
if "%version%"=="" set version=2.0.0
set ftppass=cnff
set arg1=%1
title PCMod Update
color 1a
::Set windows size
mode con cols=55 lines=25
::Get network info to determine what url to use
call :network.info
call :net.check
call :update.check
ping localhost -n 3 >nul
exit
:network.info
for /f "tokens=2-3 delims=:" %%f in ('ipconfig^|find "IPv4 Address"') do set ip=%%f
for /f "tokens=2 delims=:" %%f in ('NETSH WLAN SHOW INTERFACES ^| findstr /r "^....SSID"') do set ssid=%%f
set ip=%ip:~1%&set ssid=%ssid:~1%
if "%ssid%"=="~1" set ip=Wired&set ip=Ethernet
if "%ip%"=="~1ssid:~1" set ip=127.0.0.1&set ssid=Localhost
set mac=--:--:--:--:--:--
for /f "tokens=1-4 delims=," %%a in ('getmac /fo csv /v') do if not %%d=="Hardware not present" if not %%d=="Media disconnected" set mac=%%c
set mac=%mac:"=%
set mac=%mac:-=:%
set url=markspi.ddns.me
if "%ssid%"=="Connjohn Mkbread" set url=192.168.0.27
goto :eof
:net.check
ping %url% -n 1 >nul
if "%errorlevel%"=="1" set connection=0
if "%errorlevel%"=="0" set connection=1
copy nul data\indexes\signature >nul
if "%connection%"=="1" bin\wget -q http://%url%/pcmod2/updates/sig -O data\indexes\signature
title PCMod
for /f %%z in ('type data\indexes\signature') do set sig=%%z
if "%sig%"=="PCMod" echo.[200] ONLINE&set connection=1
if not "%sig%"=="PCMod" echo.[404] OFFLINE&set connection=0
if not "%sig%"=="PCMod" if "%1"=="popup" bin\nircmd.exe infobox "Unable to connect to MarksPi Server. Internet/Server Error" "PCMod Error"
goto :eof
:update.check
echo.Current Version: %version%
echo.Checking for Updates...&set PCMod_update=
if "%connection%"=="1" bin\wget -q http://%url%/pcmod2/version -O data\indexes\version.tmp&title PCMod Update
if "%connection%"=="0" echo.*** Offline ***
for /f %%a in ('type data\indexes\version.tmp') do if not "%%a"=="%version%" set PCMod_update=%%a&echo.Update Found.
if "%arg1%"=="-f" set PCMod_update=%version%
if not "%PCMod_update%"=="" call :update.double.check&goto :eof
if "%PCMod_update%"=="" echo.No Updates Found.
if "%PCMod_update%"=="" choice /m "Force Update? C=Custom R=Resync mods" /c:"ynrcv" /t 5 /d n
if "%PCMod_update%"=="" if "%errorlevel%"=="1" set PCMod_update=%version%&call :update&goto :eof
if "%PCMod_update%"=="" if "%errorlevel%"=="3" del data\.minecraft\mods\*.*&call :update.verify&goto :eof
if "%PCMod_update%"=="" if "%errorlevel%"=="4" set /p PCMod_update=VERSION:&call :update&goto :eof
if "%PCMod_update%"=="" if "%errorlevel%"=="5" set PCMod_update=%base_update%&call :update&goto :eof
goto :eof
:update.double.check
echo.AUTO UPDATE...
echo.You have 10 seconds to cancel with N.
if not "%PCMod_update%"=="" choice /m "Update? C=Custom R=Resync Mods" /c:"ynrc" /t 10 /d y
if not "%PCMod_update%"=="" if "%errorlevel%"=="1" call :update&goto :eof
if not "%PCMod_update%"=="" if "%errorlevel%"=="3" del data\.minecraft\mods\*.*&call :update.verify&goto :eof
if not "%PCMod_update%"=="" if "%errorlevel%"=="4" set /p PCMod_update=VERSION:&call :update&goto :eof
echo.Cancelling...
ping localhost -n 2 >nul
goto :eof
:update
del data\update.log 2>nul
for /f "tokens=1-2 delims==" %%a in ('type settings.txt') do set %%a=%%b
set count=
set count_=
ping localhost -n 2 >nul
::Get the username logged in
::for /f delims^=^"^ tokens^=1-4 %%a in ('type data\.minecraft\launcher_profiles.json') do if "%%b"=="username" set user=%%d
::for /f "tokens=1-2 delims==" %%a in ('type data\.tlauncher\tlauncher-2.0.properties') do if "%%a"=="login.account" set user=%%b
for /f %%a in ('type data\indexes\user') do set user=%%a
if "%user%"=="" set user=null
ping localhost -n 2 >nul
if "%connection%"=="0" echo.*** Offline ***&pause >nul&exit
color 1a
cls
echo.--- UPDATE %PCMod_update% ---
md data\update 2>nul
call :update.verify
if "%log-logins%"=="1" call :log-logins
call :update.download
color 1a
echo.&echo.Update Downloaded.
call :update.extract
call :update.backup
ping localhost -n 2 >nul
call :update.install
ping localhost -n 2 >nul
call :update.mods.clean
ping localhost -n 3 >nul
call :bug.fix
ping localhost -n 2 >nul
call :update.verify
ping localhost -n 2 >nul
echo.Updating Modlist...
call cmd\settings.bat modlist
ping localhost -n 2 >nul
echo.Cleaning Update...
echo.a | rd /s /q data\update\
echo.Finalizing Update...
if "%lite%"=="1" call cmd\settings.bat lite 1
del %temp%\pcmodsysinfo 2>>data\backup\error.log
echo.Restarting PCMod...&ping localhost -n 2 >nul
bin\nircmd.exe win close title "PCMod Launcher"
ping localhost -n 2 >nul
del bin\.cancelLaunch 2>nul
start "" "PCMod.hta"
exit /b
goto :eof
exit
::=============================PROCEDURES============================::
:log-logins
set state=update
for /f %%a in ('type data\indexes\user') do set user=%%a
for /f %%a in ('type data\indexes\uuid') do set uuid=%%a
for /f %%a in ('type data\indexes\mem') do set memory=%%a
bin\wget.exe -q -O data\indexes\xip ifconfig.co
for /f %%a in ('type data\indexes\xip') do set xip=%%a
for /f %%a in ('type data\indexes\modcount') do set modcnt=%%a
bin\wget -q --spider "http://%url%/pcmod2/login.php?user=%user%&uuid=%uuid%&state=%state%&version=%version%&netinfo=%username%/%computername%/%mac%/%ip%/%ssid%/%xip%&modcount=%modcnt%&memory=%memory%"
goto :eof
:update.download
color 1e
::Download the size file
set /p "=Getting Update Size... " <nul
bin\wget.exe -q http://%url%/pcmod2/updates/%PCMod_update%.size -O data\update\size&title PCMod Update
::Get Sizes of the file and the listed size
FOR /F "usebackq" %%A IN ('data\update\PCMod_update_%PCMod_update%.zip') DO set size=%%~zA
for /f %%a in ('type data\update\size') do set size_=%%a
echo.%size_:~0,-6%.%size_:~-6,-5% MB
::If Zip file already exists (and has correct size) skip the download
::echo.SIZE: %size_:~0,-6%.%size_:~-6,-5% MB
if exist "data\update\PCMod_update_%PCMod_update%.zip" if "%size%"=="%size_%" echo.Using offline zip file.&goto :eof
if exist "data\update\PCMod_update_%PCMod_update%.zip" if not "%size%"=="%size_%" echo.Size does not match. (%size:~0,-6%.%size:~-6,-5% MB ~= %size_:~0,-6%.%size_:~-6,-5% MB)&echo.Redownloading...&del data\update\update_%PCMod_update%.zip 2>data\update\error.log
echo.Downloading Update... (PCMod_update_%PCMod_update%.zip)
start /min bin\wget.exe http://%url%/pcmod2/updates/PCMod_update_%PCMod_update%.zip -O data\update\PCMod_update_%PCMod_update%.zip
set size=0000000
call :update.download.progress
FOR /F "usebackq" %%A IN ('data\update\PCMod_update_%PCMod_update%.zip') DO set size=%%~zA
::If Zip file has correct size go to next step
if "%size%"=="%size_%" goto :eof
color 1c
if not "%size%"=="%size_%" echo.Size does not match. (%size% ~= %size_%)
set /a retrys=%retrys%+1
echo.Failed to Download Update...
echo.Retrying (%retrys%/5)...
ping localhost -n 11 >nul
if "%retrys%"=="5" echo.Update Failed. Please contact Mark at markrewey@gmail.com&pause >nul&exit /b
del data\update\PCMod_update_%PCMod_update%.zip
goto :update.download
:update.download.progress
set /p "=" <nul
set /p "=DOWNLOADED/TOTAL SIZE: %size:~0,-6%.%size:~-6,-5% MB / %size_:~0,-6%.%size_:~-6,-5% MB (%percent%%%) " <nul
set /a percent=( %size:~0,-6% * 100 ) / %size_:~0,-6%
if "%size%"=="%size_%" goto :eof
tasklist /fi "imagename eq wget.exe" | findstr "wget.exe" >nul
if "%errorlevel%"=="1" goto :eof
ping localhost -n 2 >nul
FOR /F "usebackq" %%A IN ('data\update\PCMod_update_%PCMod_update%.zip') DO set size=%%~zA
if %size% leq 1000000 set size=0000000
goto :update.download.progress
:update.extract
echo.Extracting... PCMod_update_%PCMod_update%.zip
mkdir data\update\%PCMod_update% 2>>data\update\error.log
bin\7za.exe x -tzip data\update\PCMod_update_%PCMod_update%.zip -odata\update\%PCMod_update% -aoa >>data\update\update.log
goto :eof
:update.backup
echo.Backing Up...
for /f "usebackq" %%a in (`echo.%ftppass% ^| bin\tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'`) do set ftppass_=%%a
>bin\backup.ftp echo.cd logins
>>bin\backup.ftp echo.cd "%user%"
>>bin\backup.ftp echo.prompt
>>bin\backup.ftp echo.lcd data\.minecraft\
echo.- Options (Local)
if "%lite%"=="1" (
	copy data\.minecraft\optionsof.txt data\backup\optionsof_lite.txt >nul
	copy data\.minecraft\options.txt data\backup\options_lite.txt >nul
)
if "%lite%"=="0" (
	copy data\.minecraft\optionsof.txt data\backup\optionsof_default.txt >nul
	copy data\.minecraft\options.txt data\backup\options_default.txt >nul
)
echo.- Options (Upload)
>>bin\backup.ftp echo.put options.txt
>>bin\backup.ftp echo.put optionsof.txt
echo.- Crash Reports (Upload)
>>bin\backup.ftp echo.mkdir crash-reports
>>bin\backup.ftp echo.cd crash-reports
>>bin\backup.ftp echo.pwd
>>bin\backup.ftp echo.lcd crash-reports
if exist "data\.minecraft\crash-reports" >>bin\backup.ftp echo.mput *.txt
>>bin\backup.ftp echo.lcd ..
>>bin\backup.ftp echo.cd ..
echo.- Screenshots (Upload)
>>bin\backup.ftp echo.mkdir screenshots
>>bin\backup.ftp echo.cd screenshots
>>bin\backup.ftp echo.lcd screenshots
if exist "data\.minecraft\screenshots" >>bin\backup.ftp echo.mput *.png
>>bin\backup.ftp echo.lcd ..
>>bin\backup.ftp echo.cd ..
echo.- Waypoints (Upload)
>>bin\backup.ftp echo.mkdir waypoints
>>bin\backup.ftp echo.cd waypoints
>>bin\backup.ftp echo.lcd local
>>bin\backup.ftp echo.lcd ftbchunks
>>bin\backup.ftp echo.lcd data
::FILL THIS IN -----------\/
>>bin\backup.ftp echo.lcd PC
>>bin\backup.ftp echo.lcd minecraft_overworld
>>bin\backup.ftp echo.put waypoints.json
>>bin\backup.ftp echo.bye
if exist "data\indexes\uuid" copy data\.tlauncher\tlauncher-2.0.properties data\.tlauncher\tlauncher-2.0.properties.tmp >nul
bin\ftps.exe -a -user:pcmod -password:%ftppass_% -s:bin\backup.ftp %url% 21 >data\update.log 2>&1
del bin\backup.ftp 2>nul
del data\.minecraft\crash-reports\*.txt 2>nul
mkdir data\backup\screenshots\ 2>nul
move data\.minecraft\screenshots\*.* data\backup\screenshots\ 2>nul >nul
goto :eof
:bug.fix
if not exist "bin\bug.fix" goto :eof
if exist "bin\bug.fix" move bin\bug.fix bin\bugfix.bat >nul&echo.Fixing bugs...
if exist "bin\bugfix.bat" ping localhost -n 2 >nul
if exist "bin\bugfix.bat" start /min /wait "" "bin\bugfix.bat"
if exist "bin\bugfix.bat" ping localhost -n 4 >nul
if exist "bin\bugfix.bat" del bin\bugfix.bat
if not exist "bin\bugfix.bat" echo.Bug Fixes Complete.
if exist "bin\bugfix.bat" echo.Bug Fix Failed.&pause >nul
if exist "data\indexes\uuid" if exist "data\.tlauncher\tlauncher-2.0.properties.tmp" move data\.tlauncher\tlauncher-2.0.properties.tmp data\.tlauncher\tlauncher-2.0.properties >nul
goto :eof
:update.verify
del data\indexes\missingmods.txt 2>nul
del data\indexes\extramods.txt 2>nul
SetLocal EnableDelayedExpansion Enableextensions
set count=0
set count_=0
set /p "=Verifying Modcount..." <nul
::Count the files in the mods folder
for /f "tokens=* delims=*" %%a in ('dir /b /a:-d data\.minecraft\mods\ 2^>nul') do set /a count_=!count_!+1
::Count the files listed in the index .pak file
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="U" set /a count=!count!+1&if not exist "data\.minecraft\mods\%%b" >>data\indexes\missingmods.txt echo.%%b
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="B" set /a count=!count!+1&if not exist "data\.minecraft\mods\%%b" >>data\indexes\missingmods.txt echo.%%b
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="C" set /a count=!count!+1&if not exist "data\.minecraft\mods\%%b" >>data\indexes\missingmods.txt echo.%%b
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="D" if exist "data\.minecraft\mods\%%b" >>data\indexes\extramods.txt echo.%%b
if "%count%"=="%count_%" echo. OK&echo.%count%/%count_% total mods found.&goto :eof
if not "%count%"=="%count_%" echo.Found %count_% total Mods. %count% Mods requested.&ping localhost -n 9 >nul
if %count_% gtr %count% call :update.mods.clean
if %count% gtr %count_% call :update.mods.download
Endlocal
goto :eof
:update.mods.clean
if exist "data\indexes\extramods.txt" echo.Extra Mods found...&type data\indexes\extramods.txt
echo.Cleaning Mods...
if exist "bin\update\%PCMod_update%\data\indexes\PCMod.pak" for /f "tokens=1-5 delims=;" %%a in ('type bin\update\%PCMod_update%\data\indexes\PCMod.pak') do if "%%a"=="D" if exist "data\.minecraft\mods\%%b" echo.y|del "data\.minecraft\mods\%%b" 2>nul&echo.y|del "data\disablesclimods\%%b" 2>nul&echo.Deleting %%d...
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="D" if exist "data\.minecraft\mods\%%b" echo.y|del "data\.minecraft\mods\%%b" 2>nul&echo.y|del "data\disablesclimods\%%b" 2>nul&echo.Deleting %%d...
if not "%server%"=="1" for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="S" if exist "data\.minecraft\mods\%%b" echo.y|del "data\.minecraft\mods\%%b" 2>nul&echo.y|del "data\disablesclimods\%%b" 2>nul&echo.Deleting %%d...
goto :eof
:update.mods.download
if exist "data\indexes\missingmods.txt" echo.Missing Mods found...&type data\indexes\missingmods.txt
echo.Downloading Missing Mods...
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do (
	if "%%a"=="C" if not exist "data\.minecraft\mods\%%b" echo.- Downloading %%d...&bin\wget.exe -q http://%url%/pcmod2/mods/%%b -O "data\.minecraft\mods\%%b"
	if "%%a"=="U" if not exist "data\.minecraft\mods\%%b" echo.- Downloading %%d...&bin\wget.exe -q http://%url%/pcmod2/mods/%%b -O "data\.minecraft\mods\%%b"
	if "%%a"=="B" if not exist "data\.minecraft\mods\%%b" echo.- Downloading %%d...&bin\wget.exe -q http://%url%/pcmod2/mods/%%b -O "data\.minecraft\mods\%%b"
)
goto :eof
:update.install
echo.Installing Updates...
echo.- PCMod.hta
copy /v data\update\%PCMod_update%\PCMod.hta PCMod.hta >>data\update\update.log
echo.- data\
echo a | xcopy /e /v data\update\%PCMod_update%\data\* data\ >>data\update\update.log
echo.- bin\
echo a | xcopy /e /v data\update\%PCMod_update%\bin\* bin\ >>data\update\update.log
echo.- cmd\
set version=%PCMod_update%
echo a | xcopy /e /v data\update\%PCMod_update%\cmd\* cmd\ >>data\update\update.log
::::::::::::
::::::::::::
::::::::::::
::::::::::::
::::::::::::
::::::::::::
:: UPDATE ::
:: BUFFER ::
::::::::::::
::::::::::::
::::::::::::
::::::::::::
::::::::::::
::::::::::::
ping localhost -n 2 >nul
ping localhost -n 2 >nul
ping localhost -n 2 >nul
goto :eof
goto :update.check
::˜ Copy Right Mark Rewey © (2018)
:: Designed for Plattecraft Server.
:: http://www.markspi.tk/pcmod