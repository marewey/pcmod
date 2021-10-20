@echo off
title PCMod
if not "%1"=="launcher" cd ..
set mcversion=Forge 1.16.5
>cmd\launching.vbs echo.CreateObject("WScript.Shell").Popup "	Preparing to launch PCMod..." ^& vbcrlf ^& "	Getting things ready for launch..." ^& vbcrlf ^& "	Please Wait...", 10, "PCMod - Launcher"
start cmd\launching.vbs
echo.Running in '%cd%'
call :network.info
call :net.check
call :vars
call :uuid
if "%connection%"=="1" call :skinget
call :confignet
if "%direct%"=="1" call :auth
if exist "data\indexes\.instance" echo.PCMod already running&bin\nircmd.exe infobox "PCMod is already running. If this is an error, try again." "PCMod Error"&exit
if "%direct%"=="1" call :direct&exit
call :updateconf
if "%connection%"=="1" if "%log-logins%"=="1" call :log-logins
call :launch
ping localhost -n 6 >nul
"%cd%\bin\nircmd.exe" win close title "PCMod - Modlist"
"%cd%\bin\nircmd.exe" win close title "PCMod Launcher"
exit
:net.check
for /f %%z in ('type data\indexes\signature') do set sig=%%z
if "%sig%"=="PCMod" echo.[200] ONLINE&set connection=1
if not "%sig%"=="PCMod" echo.[400] OFFLINE&set connection=0
goto :eof
:launch
if exist "bin\.cancelLaunch" del bin\.cancelLaunch 2>nul&echo.Canceling Launch&exit
set APPDATA=%cd%\data%pack%
start "" "%cd%\bin\TLauncher.exe"
goto :eof
:vars
echo.Reading Variables from File...
for /f "tokens=1-2 delims==" %%a in ('type settings.txt') do set %%a=%%b
for /f %%a in ('type data\indexes\user') do if not "%%a"=="" set user=%%a
for /f %%a in ('type data\indexes\mem') do if not "%%a"=="" set memory=%%a
for /f %%a in ('type data\indexes\modcount') do set modcnt=%%a
for /f %%a in ('type data\indexes\mcuuid') do if not "%%a"=="" set mcuuid=%%a
for /f %%a in ('type data\indexes\uuid') do set uuid=%%a
for /f %%a in ('type data\indexes\version') do if not "%%a"=="" set version=%%a
for /f "tokens=1-2 delims=;" %%a in ('type data\indexes\os') do if not "%%a"=="" set os_=%%a&set os_v=%%b
goto :eof
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
:direct
echo.AUTH RETURN: %token% --- %returnAuth%
del cmd\401.vbs 2>nul
del cmd\408.vbs 2>nul
del cmd\pass.vbs 2>nul
if "%returnAuth%"=="401.auth" >cmd\401.vbs echo.CreateObject("WScript.Shell").Popup "	Password was incorrect. Try again." ^& vbcrlf ^& "	To reset password, Go to pcmod.ddns.me/logins/auth.html", 15, "PCMod - Error"
if "%returnAuth%"=="408.auth" >cmd\408.vbs echo.CreateObject("WScript.Shell").Popup "	Unable to verify identity with server.", 5, "PCMod - Error"
if "%returnAuth%"=="401.auth" start cmd\401.vbs&echo.*** PCMod Error: %user% does not have the correct password. Please try again.&exit
if "%returnAuth%"=="404.auth" echo.*** PCMod Warn: %user% does not have a password.
if "%returnAuth%"=="408.auth" echo.*** PCMod Error: Unable to verify identity with server.&start cmd\408.vbs
echo.Using Direct Launch...
if "%memory%"=="" set memory=4096
if "%os_%"=="" set os_=Windows 10
if "%os_v%"=="" set os_v=%os_:~-2,3%.0
if exist "data\indexes\mcuuid" for /f %%a in ('type data\indexes\mcuuid') do set mcuuid=%%a
if "%mcuuid%"=="" set mcuuid=00000000-0000-0000-0000-000000000000
if "%user%"=="" bin\nircmd.exe infobox "No username supplied. Please enter one." "PCMod Error"&echo.*** PCMod Error: No username supplied. Please enter one.&exit
>cmd\launching.vbs echo.CreateObject("WScript.Shell").Popup "Launching PCMod...			" ^& vbcrlf ^& "	* Username: %user%" ^& vbcrlf ^& "	* MC-UUID: %mcuuid%" ^& vbcrlf ^& "	* PCMod Version: %version%" ^& vbcrlf ^& "	* Memory Used: %memory%Mb" ^& vbcrlf ^& "	* OS: %os_% (%os_v%)", 10, "PCMod - Launcher"
if "%connection%"=="1" if "%log-logins%"=="1" call :log-logins
set cnt=0
set cd_=%cd%
echo.STARTING...
if exist "data\.minecraft\crash-reports\*.*" for /f %%A in ('dir /a-d-s-h /b data\.minecraft\crash-reports\*.* ^| find /v /c ""') do set cnt=%%A
echo.Starting Crashreport Catcher... %cnt%
title PCMod - Launcher
"%cd%\bin\nircmd.exe" win close title "PCMod - Modlist"
"%cd%\bin\nircmd.exe" win close title "PCMod Launcher"
if exist "bin\.cancelLaunch" del bin\.cancelLaunch 2>nul&echo.Canceling Launch&start "" "PCMod.hta"&exit
start cmd\launching.vbs
>data\indexes\.instance echo.%user%;%mcuuid%;%version%;%memory%;%os_%;%os_v%;%time:~0,-3%-%date:~4%;%uuid%;%url%
cd data\.minecraft
"%cd_%\bin\jre_x64\bin\javaw.exe" -Djava.net.preferIPv4Stack=true "-Dos.name=%os_%" -Dos.version=%os_v% -Xmn128M -Xmx%memory%M -XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump -Xss1M "-Djava.library.path=%cd_%\data\.minecraft\versions\Forge 1.16.5\natives" -Dminecraft.launcher.brand=minecraft-launcher -Dminecraft.launcher.version=2.0.1003 -cp "%cd_%\data\.minecraft\libraries\net\minecraftforge\forge\1.16.5-36.1.13\forge-1.16.5-36.1.13.jar;%cd_%\data\.minecraft\libraries\org\ow2\asm\asm\9.0\asm-9.0.jar;%cd_%\data\.minecraft\libraries\org\ow2\asm\asm-commons\9.0\asm-commons-9.0.jar;%cd_%\data\.minecraft\libraries\org\ow2\asm\asm-tree\9.0\asm-tree-9.0.jar;%cd_%\data\.minecraft\libraries\org\ow2\asm\asm-util\9.0\asm-util-9.0.jar;%cd_%\data\.minecraft\libraries\org\ow2\asm\asm-analysis\9.0\asm-analysis-9.0.jar;%cd_%\data\.minecraft\libraries\cpw\mods\modlauncher\8.0.9\modlauncher-8.0.9.jar;%cd_%\data\.minecraft\libraries\cpw\mods\grossjava9hacks\1.3.3\grossjava9hacks-1.3.3.jar;%cd_%\data\.minecraft\libraries\net\minecraftforge\accesstransformers\3.0.1\accesstransformers-3.0.1.jar;%cd_%\data\.minecraft\libraries\org\antlr\antlr4-runtime\4.9.1\antlr4-runtime-4.9.1.jar;%cd_%\data\.minecraft\libraries\net\minecraftforge\eventbus\4.0.0\eventbus-4.0.0.jar;%cd_%\data\.minecraft\libraries\net\minecraftforge\forgespi\3.2.0\forgespi-3.2.0.jar;%cd_%\data\.minecraft\libraries\net\minecraftforge\coremods\4.0.6\coremods-4.0.6.jar;%cd_%\data\.minecraft\libraries\net\minecraftforge\unsafe\0.2.0\unsafe-0.2.0.jar;%cd_%\data\.minecraft\libraries\com\electronwill\night-config\core\3.6.3\core-3.6.3.jar;%cd_%\data\.minecraft\libraries\com\electronwill\night-config\toml\3.6.3\toml-3.6.3.jar;%cd_%\data\.minecraft\libraries\org\jline\jline\3.12.1\jline-3.12.1.jar;%cd_%\data\.minecraft\libraries\org\apache\maven\maven-artifact\3.6.3\maven-artifact-3.6.3.jar;%cd_%\data\.minecraft\libraries\net\jodah\typetools\0.8.3\typetools-0.8.3.jar;%cd_%\data\.minecraft\libraries\org\apache\logging\log4j\log4j-api\2.11.2\log4j-api-2.11.2.jar;%cd_%\data\.minecraft\libraries\org\apache\logging\log4j\log4j-core\2.11.2\log4j-core-2.11.2.jar;%cd_%\data\.minecraft\libraries\net\minecrell\terminalconsoleappender\1.2.0\terminalconsoleappender-1.2.0.jar;%cd_%\data\.minecraft\libraries\net\sf\jopt-simple\jopt-simple\5.0.4\jopt-simple-5.0.4.jar;%cd_%\data\.minecraft\libraries\org\spongepowered\mixin\0.8.2\mixin-0.8.2.jar;%cd_%\data\.minecraft\libraries\net\minecraftforge\nashorn-core-compat\15.1.1.1\nashorn-core-compat-15.1.1.1.jar;%cd_%\data\.minecraft\libraries\org\tlauncher\patchy\1.1\patchy-1.1.jar;%cd_%\data\.minecraft\libraries\oshi-project\oshi-core\1.1\oshi-core-1.1.jar;%cd_%\data\.minecraft\libraries\net\java\dev\jna\jna\4.4.0\jna-4.4.0.jar;%cd_%\data\.minecraft\libraries\net\java\dev\jna\platform\3.4.0\platform-3.4.0.jar;%cd_%\data\.minecraft\libraries\com\ibm\icu\icu4j\66.1\icu4j-66.1.jar;%cd_%\data\.minecraft\libraries\com\mojang\javabridge\1.0.22\javabridge-1.0.22.jar;%cd_%\data\.minecraft\libraries\net\sf\jopt-simple\jopt-simple\5.0.3\jopt-simple-5.0.3.jar;%cd_%\data\.minecraft\libraries\io\netty\netty-all\4.1.25.Final\netty-all-4.1.25.Final.jar;%cd_%\data\.minecraft\libraries\com\google\guava\guava\21.0\guava-21.0.jar;%cd_%\data\.minecraft\libraries\org\apache\commons\commons-lang3\3.5\commons-lang3-3.5.jar;%cd_%\data\.minecraft\libraries\commons-io\commons-io\2.5\commons-io-2.5.jar;%cd_%\data\.minecraft\libraries\commons-codec\commons-codec\1.10\commons-codec-1.10.jar;%cd_%\data\.minecraft\libraries\net\java\jinput\jinput\2.0.5\jinput-2.0.5.jar;%cd_%\data\.minecraft\libraries\net\java\jutils\jutils\1.0.0\jutils-1.0.0.jar;%cd_%\data\.minecraft\libraries\com\mojang\brigadier\1.0.17\brigadier-1.0.17.jar;%cd_%\data\.minecraft\libraries\com\mojang\datafixerupper\4.0.26\datafixerupper-4.0.26.jar;%cd_%\data\.minecraft\libraries\com\google\code\gson\gson\2.8.0\gson-2.8.0.jar;%cd_%\data\.minecraft\libraries\com\mojang\authlib\2.1.28\authlib-2.1.28.jar;%cd_%\data\.minecraft\libraries\org\apache\commons\commons-compress\1.8.1\commons-compress-1.8.1.jar;%cd_%\data\.minecraft\libraries\org\apache\httpcomponents\httpclient\4.3.3\httpclient-4.3.3.jar;%cd_%\data\.minecraft\libraries\commons-logging\commons-logging\1.1.3\commons-logging-1.1.3.jar;%cd_%\data\.minecraft\libraries\org\apache\httpcomponents\httpcore\4.3.2\httpcore-4.3.2.jar;%cd_%\data\.minecraft\libraries\it\unimi\dsi\fastutil\8.2.1\fastutil-8.2.1.jar;%cd_%\data\.minecraft\libraries\org\apache\logging\log4j\log4j-api\2.8.1\log4j-api-2.8.1.jar;%cd_%\data\.minecraft\libraries\org\apache\logging\log4j\log4j-core\2.8.1\log4j-core-2.8.1.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl\3.2.2\lwjgl-3.2.2.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl-jemalloc\3.2.2\lwjgl-jemalloc-3.2.2.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl-openal\3.2.2\lwjgl-openal-3.2.2.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl-opengl\3.2.2\lwjgl-opengl-3.2.2.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl-glfw\3.2.2\lwjgl-glfw-3.2.2.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl-stb\3.2.2\lwjgl-stb-3.2.2.jar;%cd_%\data\.minecraft\libraries\org\lwjgl\lwjgl-tinyfd\3.2.2\lwjgl-tinyfd-3.2.2.jar;%cd_%\data\.minecraft\libraries\com\mojang\text2speech\1.11.3\text2speech-1.11.3.jar;%cd_%\data\.minecraft\versions\Forge 1.16.5\Forge 1.16.5.jar" -Dminecraft.applet.TargetDirectory=%cd_%\data\.minecraft -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true cpw.mods.modlauncher.Launcher --username %user% --version "Forge 1.16.5" --gameDir %cd_%\data\.minecraft --assetsDir %cd_%\data\.minecraft\assets --assetIndex 1.16 --uuid %mcuuid% --accessToken null --userType legacy --versionType modified --width 925 --height 530 --launchTarget fmlclient --fml.forgeVersion 36.1.13 --fml.mcVersion 1.16.5 --fml.forgeGroup net.minecraftforge --fml.mcpVersion 20210115.111550
cd ..\..
echo.EXITING...
set ccnt=0
if exist "data\.minecraft\crash-reports\*.*" for /f %%A in ('dir /a-d-s-h /b data\.minecraft\crash-reports\*.* ^| find /v /c ""') do set ccnt=%%A
if "%connection%"=="1" if not "%ccnt%"=="%cnt%" call :crash
move data\indexes\.instance data\indexes\last.instance >nul
start "" "PCMod.hta"
ping localhost -n 2 >nul
set time-=%time:~0,-9%-%time:~3,-6%-%time:~6,-3%
set date-=%date:~4,-8%-%date:~7,-5%-%date:~10%
set timee=%date-%_%time:~0,-3%
del cmd\launching.vbs 2>nul
del cmd\skins.vbs 2>nul
del cmd\crash.vbs 2>nul
copy data\launch.log data\.minecraft\logs\launch-%timee%.log >nul
goto :eof
:confignet
if "%url%"=="markspi.ddns.me" (
	echo.Setting mode: Remote
	copy data\.minecraft\config\offlineskins-remote.json data\.minecraft\config\offlineskins.json >nul
	copy data\.minecraft\config\fancymenu\customization\.disabled\testextra-remote.txt data\.minecraft\config\fancymenu\customization\testextra.txt >nul
	copy data\.minecraft\config\fancymenu\customization\.disabled\MainMenuScreen-remote.txt data\.minecraft\config\fancymenu\customization\MainMenuScreen.txt >nul
)
if "%url%"=="192.168.0.27" (
	echo.Setting mode: Local
	copy data\.minecraft\config\offlineskins-local.json data\.minecraft\config\offlineskins.json >nul
	copy data\.minecraft\config\fancymenu\customization\.disabled\testextra-local.txt data\.minecraft\config\fancymenu\customization\testextra.txt >nul
	copy data\.minecraft\config\fancymenu\customization\.disabled\MainMenuScreen-local.txt data\.minecraft\config\fancymenu\customization\MainMenuScreen.txt >nul
)
goto :eof
:crash
echo.Found new Crashreport (%ccount% to %cccount%). Uploading...
>bin\crashup.ftp echo.cd logins
>>bin\crashup.ftp echo.cd "%user%"
>>bin\crashup.ftp echo.prompt
>>bin\crashup.ftp echo.lcd data\.minecraft\
>>bin\crashup.ftp echo.mkdir crash-reports
>>bin\crashup.ftp echo.cd crash-reports
>>bin\crashup.ftp echo.lcd crash-reports
if exist "data\.minecraft\crash-reports\*.*" for /f %%a in ('dir /b /o:d data\.minecraft\crash-reports') do set tmpfile=%%a
>>bin\crashup.ftp echo.mput %tmpfile%
>>bin\crashup.ftp echo.bye
set ftppass=cnff
if exist "bin\tr.exe" for /f "usebackq" %%a in (`echo.%ftppass% ^| bin\tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'`) do set ftppass_=%%a
>cmd\crash.vbs echo.CreateObject("WScript.Shell").Popup "Minecraft has crashed. The crashreport was sent to the server for examination.", 15, "PCMod - Error"
start cmd\crash.vbs
start data\.minecraft\crash-reports\
call :log-logins crash
echo.Sending Message to PC [%user% launched the game.]...&bin\wget -q --spider "http://%url%/pcmod2/climsg.php?user=%user%&state=crashed
bin\ftps.exe -a -user:pcmod -password:%ftppass_% -s:bin\crashup.ftp %url% 21 >data\crashup.log 2>&1
del bin\crashup.ftp
goto :eof
:uuid
echo.Converting Username to UUID...
if exist "bin\uuid-tool-1.0.jar" for /f "tokens=1-2 delims= " %%a in ('echo.%user%^|bin\jre_x64\bin\java.exe -jar bin\uuid-tool-1.0.jar -o') do (
	if "%user%"=="%%a" set mcuuid=%%b&echo.Set UUID: %%b
)
>data\indexes\mcuuid echo.%mcuuid%
set mcuuid=%mcuuid:-=%
goto :eof
:log-logins
if exist "data\indexes\last.instance" del data\indexes\last.instance&set state=out
set state=%1
if "%state%"=="" set state=in
if "%connection%"=="0" goto :eof
bin\wget.exe -q -O data\indexes\xip ifconfig.co
if exist "data\indexes\xip" for /f %%a in ('type data\indexes\xip') do set xip=%%a
if "%xip%"=="" set xip=xxx.xxx.xxx.xxx
echo.Sending login to server... (state: %state%)
echo.%uuid% - %state%: [%user% @ %version%],[%username%/%computername%/%mac%/%ip%/%ssid%/%xip%],[%modcnt% mods/%memory% MB]
bin\wget -q --spider "http://%url%/pcmod2/login.php?user=%user%&uuid=%uuid%&state=%state%&version=%version%&netinfo=%username%/%computername%/%mac%/%ip%/%ssid%/%xip%&modcount=%modcnt%&memory=%memory%"
echo.Sending Message to PC [%user% launched the game.]...&bin\wget -q --spider "http://%url%/pcmod2/climsg.php?user=%user%&state=launched
goto :eof
:updateconf
if not "%packid%"=="1" set pack=%packid%
for /f "tokens=1-2 delims==" %%a in ('type data%pack%\.tlauncher\tlauncher-2.0.properties') do (
	if "%%a"=="minecraft.gamedir" set gamedir=%%b
	if "%%a"=="minecraft.javadir" set javadir=%%b
::	if "%%a"=="login.account" set user=%%b
	if "%%a"=="minecraft.memory.ram2" set memory=%%b
	if "%%a"=="client" set client=%%b
	if "%%a"=="process" set process=%%b
	if "%%a"=="gpu" set gpu=%%b
	if "%%a"=="login.version.game" set mcversion=%%b
	if "%%a"=="minecraft.onlaunch" set onlaunch=%%b
)
echo.^> Setting custom settings for TLauncher...
set gamedir=%cd:\=\\%\\data\\.minecraft
echo.^> --Set Gamedir: %cd%\data\.minecraft
set javadir=%cd:\=\\%\\bin\\jre_x64\\bin\\javaw.exe
echo.^> --Set Javadir: %cd%\bin\jre_x64\bin\javaw.exe
echo.^> --Set User: %user%
echo.^> --Set MCVersion: %mcversion%
if "%lite%"=="1" set onlaunch=exit
if "%lite%"=="0" set onlaunch=hide
echo.^> --Set OnLaunch: %onlaunch%
set client=
set process=
set gpu=
set user_=%user%
for /f "usebackq" %%a in (`echo.%user_% ^| bin\tr -dc '[:alnum:]\n\r'`) do set user=%%a
if not "%user%"=="%user_%" echo.Username invalid (%user_%), Correcting username (%user%)
if "%user%"=="" bin\nircmd.exe infobox "No username supplied. Please enter one." "PCMod Error"&echo.*** PCMod Error: No username supplied. Please enter one.&exit
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
echo.connection=normal
echo.minecraft.size=925;530
echo.login.account=%user%
echo.login.version.game=%mcversion%
echo.minecraft.fullscreen=false
echo.minecraft.javadir=%javadir%
echo.gui.statistics.checkbox=false )>data%pack%\indexes\tlauncher-2.0.properties.tmp
move data%pack%\indexes\tlauncher-2.0.properties.tmp data\.tlauncher\tlauncher-2.0.properties >nul
goto :eof
:auth
echo.Authorizing User...
call :login.input.decode
if "%connection%"=="0" set returnAuth=408.auth&goto :eof
bin\wget -O%temp%\au.th --post-data "x=%token%&u=%user%&z=auth" "http://%url%/pcmod2/logins/authp.php" 2>nul >nul
for /f %%a in ('type %temp%\au.th') do set returnAuth=%%a
del %temp%\au.th 2>nul
goto :eof
:login.input.decode
echo.%user%|bin\xcode.exe data\indexes\auth >nul
for /f "tokens=1 delims= " %%a in ('type data\indexes\auth') do set token=%%a
echo.%user%|bin\xcode.exe data\indexes\auth >nul
goto :eof
:skinget
ping localhost -n 1 >nul
set url=markspi.ddns.me
if "%ssid%"=="Connjohn Mkbread" set url=192.168.0.27
SetLocal EnableDelayedExpansion Enableextensions
echo.##### SKIN DOWNLOADER #####
::Get Skin Version
for /f "tokens=1-2 delims= " %%a in ('type data\indexes\skindex') do set %%a_v=%%b
::Get the skindex
set /p "=Getting skindex..." <NUL&bin\wget -O data\indexes\skindex http://%url%/pcmod2/skins/index 2>nul&echo. DONE
::If Skin does not exist, download it
set skount=0
for /f "tokens=1-2 delims= " %%a in ('type data\indexes\skindex') do if not exist "data\.minecraft\cachedImages\skins\%%a.png" set /a skount=%skount%+1
if not "%skount%"=="0" >cmd\skins.vbs echo.CreateObject("WScript.Shell").Popup "Downloading Skins...", 20, "PCMod - Launcher"&start cmd\skins.vbs
for /f "tokens=1-2 delims= " %%a in ('type data\indexes\skindex') do if not exist "data\.minecraft\cachedImages\skins\%%a.png" bin\wget -O "data\.minecraft\cachedImages\skins\%%a.png" "http://%url%/pcmod2/skins/%%a" 2>nul&echo.Getting skin for "%%a" ...
::If Skin version changed, download it
set skount=0
for /f "tokens=1-2 delims= " %%a in ('type data\indexes\skindex') do if not "%%b"=="!%%a_v!" set /a skount=%skount%+1
if not "%skount%"=="0">cmd\skins.vbs echo.CreateObject("WScript.Shell").Popup "Updating Skins...", 15, "PCMod - Launcher"&start cmd\skins.vbs
for /f "tokens=1-2 delims= " %%a in ('type data\indexes\skindex') do if not "%%b"=="!%%a_v!" bin\wget -O "data\.minecraft\cachedImages\skins\%%a.png" "http://%url%/pcmod2/skins/%%a" 2>nul&echo.Updating skin for "%%a" ... (!%%a_v! to %%b)
echo.#####  DONE  #####
Endlocal
copy "data\.minecraft\cachedImages\skins\%user%.png" "data\.minecraft\cachedImages\skins\uuid\%mcuuid%.png" >nul
ping localhost -n 1 >nul
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
ping %url% -n 1 >nul
if "%errorlevel%"=="1" set connection=0
if "%errorlevel%"=="0" set connection=1
goto :eof
