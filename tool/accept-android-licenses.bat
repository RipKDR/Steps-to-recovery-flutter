@echo off
REM Android License Acceptance Script
REM Automatically accepts all Android SDK licenses

setlocal

echo ============================================
echo Android License Acceptance
echo ============================================
echo.

REM Get Android SDK path
set ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk
if defined ANDROID_HOME set ANDROID_SDK=%ANDROID_HOME%
if defined ANDROID_SDK_ROOT set ANDROID_SDK=%ANDROID_SDK_ROOT%

if not exist "%ANDROID_SDK%" (
    echo [ERROR] Android SDK not found at %ANDROID_SDK%
    echo Please install Android SDK first
    goto :eof
)

set LICENSES_DIR=%ANDROID_SDK%\licenses

if not exist "%LICENSES_DIR%" (
    echo [ERROR] Licenses directory not found
    echo Please run sdkmanager --licenses first
    goto :eof
)

echo Accepting Android licenses...
echo.

cd /d "%ANDROID_SDK%\cmdline-tools\latest\bin" 2>nul
if errorlevel 1 (
    echo [WARN] cmdline-tools not found, trying alternative path
    cd /d "%ANDROID_SDK%\tools\bin" 2>nul
    if errorlevel 1 (
        echo [ERROR] Could not find sdkmanager
        goto :eof
    )
)

REM Accept all licenses
echo y | sdkmanager --licenses

if errorlevel 1 (
    echo [ERROR] Failed to accept licenses
    goto :eof
)

echo.
echo [OK] All Android licenses accepted
echo.

REM Verify
flutter doctor --android-licenses 2>nul
if errorlevel 1 (
    echo Licenses may need verification via: flutter doctor --android-licenses
) else (
    echo [OK] Licenses verified
)

echo.
echo Done!
endlocal
