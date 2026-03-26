@echo off
REM Flutter Debug Build Script for Windows
REM Runs flutter build apk --debug and reports compilation errors

setlocal

REM Get Flutter SDK path from android/local.properties or environment
if exist "android\local.properties" (
    for /f "tokens=2 delims==" %%a in ('findstr /b "flutter.sdk=" android\local.properties') do set FLUTTER_SDK=%%a
)

if "%FLUTTER_SDK%"=="" (
    if defined FLUTTER_ROOT (
        set FLUTTER_SDK=%FLUTTER_ROOT%
    )
)

if "%FLUTTER_SDK%"=="" (
    where flutter >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "delims=" %%i in ('where flutter') do set FLUTTER_SDK=%%~dpi..
    )
)

if "%FLUTTER_SDK%"=="" (
    echo ERROR: Flutter SDK not found. Set flutter.sdk in android\local.properties, set FLUTTER_ROOT, or add flutter to PATH.
    exit /b 1
)

REM Remove trailing backslashes
set FLUTTER_SDK=%FLUTTER_SDK:~,-1%
set FLUTTER_SDK=%FLUTTER_SDK:~,-1%

echo Using Flutter SDK: %FLUTTER_SDK%
echo.

REM Run flutter build
"%FLUTTER_SDK%\bin\flutter.bat" build apk --debug

exit /b %errorlevel%
