@echo off
setlocal enabledelayedexpansion
:: chcp 65001

:: Set the name of the Python script
set "PYNAME=sq_Interface.py"

:: Initialize PID list
set "PID_LIST="

:: Find previous Python processes
for /f "skip=1 tokens=2 delims==" %%a in (
    'wmic process where "CommandLine like '%%%PYNAME%%%' and not CommandLine like '%%wmic%%'" get ProcessId /format:value'
) do (
    if not "%%a"=="" (
        echo Detected possible new process PID: %%a
        set "PID_LIST=!PID_LIST! %%a"
    )
)

:: Remove leading space from PID list
if not "!PID_LIST!"=="" (
    set "PID_LIST=!PID_LIST:~1!"
)
:: Execute taskkill command
if not "!PID_LIST!"=="" (
    echo Terminating the following processes: !PID_LIST!
    for %%p in (!PID_LIST!) do (
        taskkill /f /pid %%p
    )
) else (
    echo No processes to terminate detected.
)

:: Run the new Python program
echo Starting Python script...
:: start "" cmd /k python !PYNAME!
start "sq_server" python !PYNAME!
:: python !PYNAME!

if "!PID_LIST!"=="" (
    exit /b
) else (
    timeout /t 4 /nobreak
)

endlocal