@echo off
setlocal

rem === SET VERSION HERE ===
set VERSION=1.0
set OUTPUT_NAME=BlenderSplit_v%VERSION%
set SCRIPT_PATH=src\main.py
set DIST_DIR=build

echo Building version %VERSION%...

rem Cleanup previous version with same name (optional)
if exist %DIST_DIR%\%OUTPUT_NAME%.exe (
    del %DIST_DIR%\%OUTPUT_NAME%.exe
)

rem Run pyinstaller
python -m PyInstaller --noconsole --onefile --name %OUTPUT_NAME% --distpath %DIST_DIR% %SCRIPT_PATH%

if %errorlevel% neq 0 (
    echo Failed to create executable.
    pause
    exit /b 1
)

echo.
echo ✅ EXE created: %DIST_DIR%\%OUTPUT_NAME%.exe
pause
