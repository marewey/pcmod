@echo off
@SetLocal EnableDelayedExpansion Enableextensions
set /a count=0
for /f "tokens=1-5 delims=;" %%b in ('type PCMod.index') do (
	set check=%%b
	if "!check:~0,2!"=="--" set check=!check:~2!
	if not "!check!"=="Remove" if not exist "..\MODLIB\PCMod\%%c" echo.%%e *** File not found *** [%%c]&set /a count=!count!+1
)
del final.pak 2>nul
del modlib.index 2>nul
dir /a:-d /b ..\MODLIB\PCMod\ >>modlib.index
for /f "tokens=* delims=*" %%a in ('type modlib.index') do (
	for /f "tokens=1-5 delims=;" %%b in ('type PCMod.index') do (
		set check=%%b
		if "!check:~0,2!"=="--" set check=!check:~2!
		if "%%a"=="%%c" if "!check!"=="Add" >>final.pak echo.U;%%c;%%d;%%e;%%f&echo.[%%d]  + %%e %%f [%%c]
		if "%%a"=="%%c" if "!check!"=="CoreAdd" >>final.pak echo.B;%%c;%%d;%%e;%%f&echo.[%%d] *+ %%e %%f [%%c]
		if "%%a"=="%%c" if "!check!"=="ClientAdd" >>final.pak echo.C;%%c;%%d;%%e;%%f&echo.[%%d] C+ %%e %%f [%%c]
		if "%%a"=="%%c" if "!check!"=="ServerAdd" >>final.pak echo.S;%%c;%%d;%%e;%%f&echo.[%%d] S+ %%e %%f [%%c]
		if "%%a"=="%%c" if "!check!"=="Remove" >>final.pak echo.D;%%c;%%d;%%e;%%f&echo.[%%d]  - %%e %%f [%%c]
	)
)
if not "%count%"=="0" echo.%count% files missing!&pause >nul
copy final.pak ..\PCMod.pak
exit /b