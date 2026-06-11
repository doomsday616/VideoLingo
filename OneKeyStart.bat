@echo off
cd /D "%~dp0"

:: Log file with timestamp (kept under logs\ to avoid polluting project root)
if not exist "logs" mkdir "logs"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set dt=%%I
set LOGFILE=logs\videolingo_%dt:~0,8%_%dt:~8,6%.log

echo [%date% %time%] VideoLingo starting... > "%LOGFILE%"
echo Log file: %LOGFILE%

:: Prefer the local uv-managed virtualenv (.venv) when present.
if exist ".venv\Scripts\streamlit.exe" (
    echo Detected .venv [uv install], starting with .venv\Scripts\streamlit ...
    .venv\Scripts\streamlit run st.py 2>&1 | powershell -Command "$input | Tee-Object -FilePath '%LOGFILE%' -Append"
    goto end
)

if exist ".venv\Scripts\python.exe" (
    echo Detected .venv [uv install], starting with .venv python -m streamlit ...
    .venv\Scripts\python -m streamlit run st.py 2>&1 | powershell -Command "$input | Tee-Object -FilePath '%LOGFILE%' -Append"
    goto end
)

:: Fall back to legacy Conda environment (older install path).
where conda >nul 2>nul
if %errorlevel%==0 (
    echo No .venv found, falling back to conda env "videolingo" ...
    call conda activate videolingo
    python -m streamlit run st.py 2>&1 | powershell -Command "$input | Tee-Object -FilePath '%LOGFILE%' -Append"
    goto end
)

echo ERROR: Neither .venv nor conda is available.
echo Please run setup first:
echo   python setup_env.py
echo or install Anaconda and create env "videolingo".

:end
pause
