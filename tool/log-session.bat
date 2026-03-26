@echo off
REM log-session.bat — Capture session learnings to .remember memory system
REM Usage: tool\log-session.bat [topic]

setlocal enabledelayedexpansion

REM Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set DATE=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%

REM Topic from argument or prompt
if "%1"=="" (
    set /p TOPIC="Enter session topic (e.g., 'Gradle Build Fixes'): "
) else (
    set TOPIC=%1
)

REM File paths
set MEMORY_DIR=.remember\memory
set DAILY_NOTE=%MEMORY_DIR%\%DATE%.md
set PROJECT_STATE=%MEMORY_DIR%\project-state.md

REM Check if daily note exists
if not exist "%DAILY_NOTE%" (
    echo Creating daily note: %DAILY_NOTE%
    (
        echo # %DATE% — Session Notes
        echo.
        echo ## Session Start
        echo - **Date:** %DATE%
        echo - **Timezone:** Australia/Sydney (GMT+11)
        echo - **Context:** %TOPIC%
        echo.
        echo ## Key Actions
        echo - [Action 1]
        echo - [Action 2]
        echo.
        echo ## Project Context
        echo [Brief status update]
        echo.
        echo ## Recent Changes
        echo [What changed today]
        echo.
        echo ## Next Steps
        echo Awaiting user direction.
        echo.
    ) > "%DAILY_NOTE%"
    echo Daily note created. Edit it to add your learnings.
) else (
    echo Daily note already exists: %DAILY_NOTE%
)

REM Prompt for learning to capture
echo.
echo What did you learn this session?
echo (This will be appended to the daily note)
set /p LEARNING="Enter learning: "

if not "!LEARNING!"=="" (
    echo.
    echo ## Learnings
    echo - !LEARNING!
    echo.
) >> "%DAILY_NOTE%"

echo.
echo Session logged to: %DAILY_NOTE%
echo.
echo Next steps:
echo 1. Edit %DAILY_NOTE% to add more details
echo 2. Update %PROJECT_STATE% if project state changed
echo 3. Commit changes with message: "docs: log session %DATE%"

endlocal
