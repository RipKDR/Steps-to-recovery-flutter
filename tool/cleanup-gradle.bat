@echo off
REM Gradle Daemon Cleanup Script
REM Kills conflicting Java/Gradle processes and cleans Gradle cache

setlocal

echo ============================================
echo Gradle Daemon Cleanup
echo ============================================
echo.

echo Stopping Gradle daemons...
cd /d "%~dp0..\android" 2>nul
if errorlevel 1 (
    echo [WARN] Could not find android directory
    goto :kill_java
)

if exist "gradlew" (
    call gradlew --stop
) else if exist "gradlew.bat" (
    call gradlew.bat --stop
) else (
    echo [INFO] No gradlew found, proceeding with process cleanup
)

:kill_java
echo.
echo Killing Java processes that may be locking Gradle...
echo.

REM List Java processes
tasklist | findstr java.exe >nul
if errorlevel 1 (
    echo [INFO] No Java processes running
    goto :clean_cache
)

echo Found Java processes:
tasklist | findstr java.exe
echo.

REM Kill Java processes
taskkill /F /IM java.exe >nul 2>&1
if errorlevel 1 (
    echo [WARN] Could not kill all Java processes (may require admin)
) else (
    echo [OK] Java processes terminated
)

:clean_cache
echo.
echo Cleaning Gradle cache...
echo.

set GRADLE_CACHE=%USERPROFILE%\.gradle\caches

if exist "%GRADLE_CACHE%" (
    REM Delete build intermediates only (safer than full cache clear)
    if exist "%GRADLE_CACHE%\build-cache-1" (
        rd /s /q "%GRADLE_CACHE%\build-cache-1" 2>nul
        echo [OK] Build cache cleaned
    )
    if exist "%GRADLE_CACHE%\transforms-3" (
        rd /s /q "%GRADLE_CACHE%\transforms-3" 2>nul
        echo [OK] Transforms cache cleaned
    )
) else (
    echo [INFO] Gradle cache not found
)

REM Clean Android build intermediates
set ANDROID_BUILD=%~dp0..\android\build
if exist "%ANDROID_BUILD%" (
    if exist "%ANDROID_BUILD%\tmp" (
        rd /s /q "%ANDROID_BUILD%\tmp"
        echo [OK] Android build tmp cleaned
    )
)

set APP_BUILD=%~dp0..\android\app\build
if exist "%APP_BUILD%" (
    rd /s /q "%APP_BUILD%"
    echo [OK] App build cleaned
)

echo.
echo ============================================
echo Cleanup Complete
echo ============================================
echo.
echo You can now run: flutter clean && flutter pub get
echo.

endlocal
