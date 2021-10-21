::[Bat To Exe Converter]
::
::fBE1pAF6MU+EWHreyHcjLQlHcAmDLmCoOpET6/326uSTsXE5UfE0bIDL5pmHLuUQ+ETiYaod9VdVnPQZHB9Zahe5Ug09p1JruHeRNsuQth3dHVKIqE4oHgU=
::fBE1pAF6MU+EWHreyHcjLQlHcAmDLmCoOpET6/326uSTsXE5UfE0bIDL5pmHLuUQ+ETiYaod9VdVnPQZHB9Zahe5Ug09p1JruHeRNsuQth3dXU+M8gU1A2AU
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFBZVXg+QAE+1BaAR7ebv/Najp14WQO0vRKLS1LGNMuEV/nnUVrsi0kVPiM8NGB5KQhCiYDMdp31Wt2iJMtWgugzuRAaA5URQ
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBZVXg+QAE+1BaAR7ebv/Najp14WQO0vRKLS1LGNMuEV/nnUVrsi0kVPiM8NGB5KQhCiYDMdp31Wt2iJMtWgmgHyXkmF6nsTNmpwyWbIiUs=
::YB416Ek+Zm8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
@SetLocal EnableDelayedExpansion Enableextensions
call :network.info
set install=
call :ifexists
call :download
call :extract
call :clean
call :launch
exit /b

:download
echo.Downloading PCMod2...
if not "%ssid%"=="Rewey Hub" wget http://pcmod.ddns.me/downloads/PCMod2.zip -O PCMod2.zip
if "%ssid%"=="Rewey Hub" wget http://192.168.0.27/pcmod2/downloads/PCMod2.zip -O PCMod2.zip
goto :eof
:ifexists
echo.Checking if it exists already...
if exist "%userprofile%\PCMod2-%install%" echo.Would you like to overwrite old PCMod? [%userprofile%\PCMod2-%install%]&choice /c:"yn" /d n /t 10
if exist "%userprofile%\PCMod2-%install%" if "%errorlevel%"=="1" rmdir /s %userprofile%\PCMod2-%install%&goto :eof
if exist "%userprofile%\PCMod2-%install%" set /a install=%install%+1&echo.EXISTS: Changing install to PCMod!install!&goto :ifexists
goto :eof
:extract
echo.Extracting and Installing PCMod2...
mkdir %userprofile%\PCMod2-%install% 2>nul
7za.exe x -tzip PCMod.zip -o%userprofile%\PCMod2-%install%
goto :eof
:clean
echo.Cleaning the Zipfile...
del PCMod2.zip 2>nul
goto :eof
:launch
echo.Launching...
cd %userprofile%\PCMod2-%install%\
start %userprofile%\PCMod2-%install%\PCMod.hta
goto :eof
:network.info
for /f "tokens=2-3 delims=:" %%f in ('ipconfig^|find "IPv4 Address"') do set ip=%%f
for /f "tokens=2 delims=:" %%f in ('NETSH WLAN SHOW INTERFACES ^| findstr /r "^....SSID"') do set ssid=%%f
for /f "tokens=2 delims=:" %%f in ('ipconfig /all^|find "Physical Address"') do set mac=%%f
set ip=%ip:~1%&set ssid=%ssid:~1%&set mac=%mac:~1%
if "%ssid%"=="~1" set ip=Wired&set ip=Ethernet
if "%ip%"=="~1ssid:~1" set ip=127.0.0.1&set ssid=Localhost
goto :eof