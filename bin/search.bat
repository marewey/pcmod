@echo off
copy nul search.txt
for /f "tokens=1-5 delims=;" %%a in ('type ..\PCMod.pak') do (
	if "%%a"=="U" >>search.txt echo.%%d
	if "%%a"=="B" >>search.txt echo.%%d
	if "%%a"=="C" >>search.txt echo.%%d
)
echo.Mods:
type search.txt
pause
echo.Press any key to go to next search...
for /f "tokens=1-5 delims=;" %%a in ('type ..\PCMod.pak') do (
	if not "%%a"=="D" (
		start "" "https://www.curseforge.com/minecraft/mc-mods/search?search=%%d"
		echo.SEARCH: %%d - %%b
		pause >nul
	)
)
