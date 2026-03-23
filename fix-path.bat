@echo off
echo ================================================
echo Flutter and Git PATH Fix Script
echo ================================================
echo.

REM Ensure Windows system directories are in PATH
set "PATH=C:\Windows\System32;C:\Windows;C:\Program Files\Git\cmd;C:\src\flutter\bin;C:\src\flutter\bin\cache\dart-sdk\bin;%PATH%"

echo Checking required tools...
echo.

REM Check Windows system tools
where where >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows 'where' command not found!
    echo Your Windows System32 path is broken.
    echo.
    echo CRITICAL FIX NEEDED:
    echo Make sure these are in your PATH:
    echo   - C:\Windows\System32
    echo   - C:\Windows
    echo   - C:\Windows\System32\Wbem
    goto :manual_fix
) else (
    echo Windows system tools: OK
)

REM Check Git
where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git not found in PATH
    goto :manual_fix
) else (
    echo Git: OK
)

REM Check Flutter
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found in PATH
    goto :manual_fix
) else (
    echo Flutter: OK
)

echo.
echo All tools found! Running flutter doctor...
echo.
flutter doctor -v

echo.
echo ================================================
echo SUCCESS: Flutter is working in this session!
echo ================================================
echo.
echo To make this PERMANENT:
echo.
echo 1. Press Win + R, type: sysdm.cpl
echo 2. Click "Advanced" tab
echo 3. Click "Environment Variables"
echo 4. Under "User variables", select "Path" and click "Edit"
echo 5. Ensure these entries exist and move them to TOP:
echo    - C:\Windows\System32
echo    - C:\Windows
echo    - C:\Windows\System32\Wbem
echo    - C:\Program Files\Git\cmd
echo    - C:\src\flutter\bin
echo    - C:\src\flutter\bin\cache\dart-sdk\bin
echo 6. Click OK on all dialogs
echo 7. RESTART your terminal/IDE
echo.
pause
exit /b 0

:manual_fix
echo.
echo ================================================
echo MANUAL FIX REQUIRED
echo ================================================
echo.
echo Follow these steps to fix your PATH permanently:
echo.
echo 1. Press Win + R, type: sysdm.cpl
echo 2. Click "Advanced" tab  
echo 3. Click "Environment Variables"
echo 4. Under "User variables", select "Path" and click "Edit"
echo 5. Click "New" and add (in this order):
echo    - C:\Windows\System32
echo    - C:\Windows
echo    - C:\Windows\System32\Wbem
echo    - C:\Program Files\Git\cmd
echo    - C:\src\flutter\bin
echo    - C:\src\flutter\bin\cache\dart-sdk\bin
echo 6. Use "Move Up" to put them at the TOP
echo 7. Remove any corrupted/duplicate entries
echo 8. Click OK on all dialogs
echo 9. RESTART your computer or at least all terminals
echo.
pause
