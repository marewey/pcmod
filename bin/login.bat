@echo off
:a
title
call :login.register
title
echo.Now try logging in...
call :login
call :login.check
pause
goto :a

:login
set user=marewey
set validation=0
if exist "data\indexes\auth" call :login.input.decode
if "%validation%"=="1" goto :eof
if not exist "data\indexes\auth" call :login.input
title
goto :eof

:login.register
echo.Create a password:
set user=marewey
set /p pass=:
>%temp%\au.th echo.%pass%
for /f "tokens=1 delims= " %%a in ('bin\md5sum.exe %temp%\au.th') do >%temp%\auth.md5 echo.%%a
type %temp%\auth.md5
goto :eof

:login.input
set /p pass=:
>%temp%\au.th echo.%pass%
for /f "tokens=1 delims= " %%a in ('bin\md5sum.exe %temp%\au.th') do >data\indexes\auth echo.%%a
del %temp%\au.th 2>nul
:login.input.decode
echo.%user%|bin\xcode.exe data\indexes\auth >nul
for /f "tokens=1 delims= " %%a in ('bin\md5sum.exe data\indexes\auth') do set token=%%a&echo.*-%%a
echo.%user%|bin\xcode.exe data\indexes\auth >nul
:login.file
::get
:login.file.decode
echo.%user%|bin\xcode.exe %temp%\auth.md5 >nul
for /f "tokens=1 delims= " %%a in ('bin\md5sum.exe %temp%\auth.md5') do >%temp%\auth.xmd5 echo.%%a
for /f %%a in ('type %temp%\auth.xmd5') do echo.#-%%a&if "%%a"=="%token%" set validation=1
del %temp%\auth.md5 2>nul
goto :eof

:login.check
if "%validation%"=="1" echo.PASSWORD CORRECT!
if "%validation%"=="0" echo.PASSWORD INCORRECT!
goto :eof