@echo off
setlocal
rem planning-with-files: Windows hook launcher for Codex (issue #201).
rem Codex runs each hook's commandWindows; on Windows that routes here as:
rem   cmd /c .codex\hooks\pwf-hook.cmd <script.py> [args...]
rem A .cmd is the one form that runs identically whether Codex spawns the hook
rem via cmd.exe, PowerShell, or direct CreateProcess, and it lets us fall back
rem from the py launcher to python.exe. The Microsoft Store python3.exe alias is
rem deliberately never selected. Always exits 0 so an advisory hook cannot
rem report "hook exited with code 1".
rem Codex starts hooks in the (untrusted) project folder. cmd.exe and where.exe
rem search the current directory before PATH, so a repository could plant
rem py.bat or python.exe at its root. Disable that lookup, only resolve
rem interpreters to absolute .exe paths, and skip anything in the project folder.
set "NoDefaultCurrentDirectoryInExePath=1"
for %%C in ("%CD%\.") do set "PWF_CWD=%%~fC"
if not "%PWF_CWD:~-1%"=="\" set "PWF_CWD=%PWF_CWD%\"
set "PWF_WHERE=%SystemRoot%\System32\where.exe"
set "PY_EXE="
set "PY_ARGS="
if defined PYTHON_BIN for %%I in ("%PYTHON_BIN%") do if /i not "%%~dpI"=="%PWF_CWD%" if /i "%%~xI"==".exe" if exist "%%~fI" set "PY_EXE=%%~fI"
if not defined PY_EXE for /f "delims=" %%P in ('""%PWF_WHERE%" $PATH:py.exe 2>nul"') do if not defined PY_EXE if /i not "%%~dpP"=="%PWF_CWD%" set "PY_EXE=%%~fP"
if defined PY_EXE if not defined PY_ARGS if /i "%PY_EXE:~-6%"=="\py.exe" set "PY_ARGS=-3"
if not defined PY_EXE for /f "delims=" %%P in ('""%PWF_WHERE%" $PATH:python.exe 2>nul"') do if not defined PY_EXE if /i not "%%~dpP"=="%PWF_CWD%" set "PY_EXE=%%~fP"
rem Codex can start hooks with a reduced PATH. Probe the normal uv and CPython
rem install locations so a valid user installation still works in that case.
if not defined PY_EXE for /d %%D in ("%APPDATA%\uv\python\*") do if exist "%%~fD\python.exe" if not defined PY_EXE set "PY_EXE=%%~fD\python.exe"
if not defined PY_EXE for /d %%D in ("%LOCALAPPDATA%\uv\python\*") do if exist "%%~fD\python.exe" if not defined PY_EXE set "PY_EXE=%%~fD\python.exe"
if not defined PY_EXE for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do if exist "%%~fD\python.exe" if not defined PY_EXE set "PY_EXE=%%~fD\python.exe"
if not defined PY_EXE exit /b 0
"%PY_EXE%" %PY_ARGS% "%~dp0%~1" %2 %3 %4 %5
exit /b 0
