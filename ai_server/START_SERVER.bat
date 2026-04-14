@echo off
REM NutriCare AI Server Startup Script
REM This script starts the AI server in different modes

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════╗
echo ║      NutriCare AI Server Launcher          ║
echo ╚════════════════════════════════════════════╝
echo.

REM Check if user provided mode argument
if "%1"=="" (
    echo Available modes:
    echo   1. fallback - Professional databases (recommended for production)
    echo   2. local    - Fine-tuned local model (privacy-first)
    echo   3. hf       - HuggingFace API (requires HF_TOKEN)
    echo.
    set /p MODE="Enter mode (1-3, default=1): "
    if "!MODE!"=="" set MODE=1
) else (
    set MODE=%1
)

REM Convert choice to mode name
if "!MODE!"=="1" set AI_MODE=fallback
if "!MODE!"=="2" set AI_MODE=local
if "!MODE!"=="3" set AI_MODE=hf

if "!AI_MODE!"=="" (
    if "!MODE!"=="fallback" set AI_MODE=fallback
    if "!MODE!"=="local" set AI_MODE=local
    if "!MODE!"=="hf" set AI_MODE=hf
)

if "!AI_MODE!"=="" (
    echo ERROR: Invalid mode. Use: fallback, local, or hf
    exit /b 1
)

echo.
echo ✓ Starting AI Server in [!AI_MODE!] mode...
echo.

REM Change to ai_server directory
cd /d %~dp0..
cd ai_server

REM Install dependencies if node_modules doesn't exist
if not exist node_modules (
    echo Installing Node.js dependencies...
    call npm install
    if !errorlevel! neq 0 (
        echo ERROR: npm install failed
        exit /b 1
    )
)

REM Check for local model server if using local mode
if "!AI_MODE!"=="local" (
    echo.
    echo NOTE: Local mode requires the model server to be running!
    echo Please start in another terminal:
    echo   python training\inference_api.py --model-path training\checkpoints\nutricare-merged --port 8000
    echo.
    pause
)

REM Set environment variables and start server
echo.
echo ╭────────────────────────────────────────────╮
echo │ Server Configuration                       │
echo ├────────────────────────────────────────────┤
echo │ Mode:           !AI_MODE!
echo │ Port:           5000
echo │ URL:            http://localhost:5000/ai
echo ╰────────────────────────────────────────────╯
echo.
echo Waiting for connections... (Press Ctrl+C to stop)
echo.

set AI_MODE=!AI_MODE!
if "!AI_MODE!"=="hf" (
    if "!HF_TOKEN!"=="" (
        REM Try to read HF_TOKEN from environment or .env
        if exist .env (
            for /f "tokens=2 delims==" %%a in ('findstr /i "HF_TOKEN" .env') do set HF_TOKEN=%%a
        )
        if "!HF_TOKEN!"=="" (
            echo.
            echo ⚠  WARNING: HF_TOKEN not set!
            echo    HuggingFace mode requires an API token.
            echo    Get one at: https://huggingface.co/settings/tokens
            echo.
            set /p HF_TOKEN="Enter your HF_TOKEN: "
        )
    )
    set HF_TOKEN=!HF_TOKEN!
)

call node server.js

endlocal
pause
