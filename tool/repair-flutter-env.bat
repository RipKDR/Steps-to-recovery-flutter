@echo off
REM Complete Flutter Environment Repair Script
REM Combines all fix strategies with retry logic

setlocal EnableDelayedExpansion

echo ============================================
echo Flutter Environment Repair
echo ============================================
echo.

set RETRY_COUNT=0
set MAX_RETRIES=3

:retry_flutter_doctor
set /a RETRY_COUNT+=1
echo Attempt %RETRY_COUNT% of %MAX_RETRIES%...
echo.

REM Step 1: Clean Flutter
echo [Step 1/5] Cleaning Flutter...
flutter clean
if errorlevel 1 (
    echo [WARN] flutter clean failed, continuing...
)

REM Step 2: Get dependencies
echo.
echo [Step 2/5] Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo [ERROR] flutter pub get failed
    if !RETRY_COUNT! lss !MAX_RETRIES! (
        echo Retrying in 5 seconds...
        timeout /t 5 /nobreak >nul
        goto :retry_flutter_doctor
    )
    goto :failed
)

REM Step 3: Check Android licenses
echo.
echo [Step 3/5] Checking Android licenses...
flutter doctor --android-licenses >nul 2>&1
if errorlevel 1 (
    echo [WARN] License check failed, may need manual acceptance
)

REM Step 4: Run doctor
echo.
echo [Step 4/5] Running flutter doctor...
flutter doctor
if errorlevel 1 (
    echo [WARN] Doctor found issues
)

REM Step 5: Test build
echo.
echo [Step 5/5] Running test build...
flutter build apk --debug
if errorlevel 1 (
    echo [ERROR] Build failed
    if !RETRY_COUNT! lss !MAX_RETRIES! (
        echo.
        echo Running Gradle cleanup and retry...
        call "%~dp0cleanup-gradle.bat"
        echo.
        goto :retry_flutter_doctor
    )
    goto :failed
)

echo.
echo ============================================
echo [SUCCESS] Environment repair complete!
echo ============================================
goto :eof

:failed
echo.
echo ============================================
echo [FAILED] Environment repair incomplete
echo ============================================
echo.
echo Manual intervention required:
echo   1. Run: flutter doctor -v
echo   2. Review error messages above
echo   3. Try: tool\accept-android-licenses.bat
echo   4. Try: tool\cleanup-gradle.bat
echo.

endlocal
exit /b 1
