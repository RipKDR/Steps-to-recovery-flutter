@echo off
REM Flutter PATH Fix Script for Windows
REM Adds Flutter SDK and Android SDK to user PATH permanently

setlocal EnableDelayedExpansion

echo ============================================
echo Flutter PATH Configuration Fix
echo ============================================
echo.

REM Get Flutter SDK path from android/local.properties or use default
set FLUTTER_SDK=
if exist "android\local.properties" (
    for /f "tokens=2 delims==" %%a in ('findstr /b "flutter.sdk=" android\local.properties') do set FLUTTER_SDK=%%a
)

if "%FLUTTER_SDK%"=="" (
    if defined FLUTTER_ROOT (
        set FLUTTER_SDK=%FLUTTER_ROOT%
    )
)

if "%FLUTTER_SDK%"=="" (
    set FLUTTER_SDK=C:\src\flutter
)

REM Remove trailing backslashes
:trim_flutter
if "%FLUTTER_SDK:~-1%"=="\" set FLUTTER_SDK=%FLUTTER_SDK:~0,-1%
goto trim_flutter 2>nul

REM Android SDK path
set ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk
if defined ANDROID_HOME set ANDROID_SDK=%ANDROID_HOME%
if defined ANDROID_SDK_ROOT set ANDROID_SDK=%ANDROID_SDK_ROOT%

echo Using Flutter SDK: %FLUTTER_SDK%
echo Using Android SDK: %ANDROID_SDK%
echo.

REM Paths to add
set PATHS_TO_ADD=%FLUTTER_SDK%\bin;%ANDROID_SDK%\platform-tools;%ANDROID_SDK%\cmdline-tools\latest\bin

echo Adding to PATH:
echo   - %FLUTTER_SDK%\bin
echo   - %ANDROID_SDK%\platform-tools
echo   - %ANDROID_SDK%\cmdline-tools\latest\bin
echo.

REM Get current user PATH from registry
for /F "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set CURRENT_USER_PATH=%%B

REM Check if paths already exist
set NEEDS_UPDATE=0
echo "%CURRENT_USER_PATH%" | find /i "%FLUTTER_SDK%\bin" >nul
if errorlevel 1 set NEEDS_UPDATE=1

echo "%CURRENT_USER_PATH%" | find /i "%ANDROID_SDK%\platform-tools" >nul
if errorlevel 1 set NEEDS_UPDATE=1

if %NEEDS_UPDATE% equ 0 (
    echo [OK] Flutter and Android SDK paths already in PATH
    echo.
    goto :verify
)

REM Add paths to user PATH
setx PATH "%CURRENT_USER_PATH%;%PATHS_TO_ADD%"
if errorlevel 1 (
    echo [ERROR] Failed to update PATH
    echo Please run this script as administrator or manually add the paths
    goto :eof
)

echo [OK] PATH updated successfully
echo.
echo NOTE: Close and reopen your terminal for changes to take effect.
echo.

:verify
echo ============================================
echo Verification
echo ============================================
echo.

REM Verify Flutter
where flutter >nul 2>&1
if errorlevel 1 (
    echo [WARN] Flutter not found in PATH yet. Restart terminal and try again.
) else (
    for /f "delims=" %%i in ('where flutter') do echo [OK] Flutter found: %%i
)

REM Verify ADB
where adb >nul 2>&1
if errorlevel 1 (
    echo [WARN] Android platform-tools not found in PATH yet. Restart terminal and try again.
) else (
    for /f "delims=" %%i in ('where adb') do echo [OK] ADB found: %%i
)

echo.
echo Done!
endlocal
