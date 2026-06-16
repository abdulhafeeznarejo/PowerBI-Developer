@echo off
setlocal enabledelayedexpansion
title PBI-CLI — Power BI Developer Tool

set ROOT=%USERPROFILE%\PowerBI-Developer
set PROJECTS=%ROOT%\projects
set SHARED=%ROOT%\shared
set TOOLS=%ROOT%\tools

:: ── Router ────────────────────────────────────────────────
set CMD=%1
if "%CMD%"=="" goto :help
if "%CMD%"=="help"         goto :help
if "%CMD%"=="new-project"  goto :new_project
if "%CMD%"=="list"         goto :list_projects
if "%CMD%"=="open"         goto :open_project
if "%CMD%"=="dax"          goto :dax_search
if "%CMD%"=="csv-to-json"  goto :csv_to_json
if "%CMD%"=="export-dax"   goto :export_dax
if "%CMD%"=="theme"        goto :open_theme
if "%CMD%"=="status"       goto :status
if "%CMD%"=="serve"        goto :serve
echo   Unknown command: %CMD%
goto :help

:: ── HELP ──────────────────────────────────────────────────
:help
echo.
echo  ==========================================
echo   PBI-CLI — Power BI Developer Toolkit
echo  ==========================================
echo.
echo  COMMANDS:
echo.
echo   new-project [name]     Create new PBI project folder
echo   list                   List all projects
echo   open [name]            Open project folder in Explorer
echo   dax [keyword]          Search DAX library by keyword
echo   csv-to-json [file]     Convert CSV to JSON
echo   export-dax [project]   Copy DAX measures from project
echo   theme                  Open shared themes folder
echo   serve [project]        Start local HTTP server for project
echo   status                 Show workspace summary
echo   help                   Show this menu
echo.
echo  USAGE EXAMPLE:
echo   pbi-cli new-project FinanceDashboard
echo   pbi-cli dax revenue
echo   pbi-cli csv-to-json Sales_Data.csv
echo.
goto :end

:: ── NEW PROJECT ───────────────────────────────────────────
:new_project
set PNAME=%2
if "%PNAME%"=="" (
    echo   ERROR: Provide project name.
    echo   Usage: pbi-cli new-project MyProject
    goto :end
)
set PPATH=%PROJECTS%\%PNAME%
if exist "%PPATH%" (
    echo   Project '%PNAME%' already exists at %PPATH%
    goto :end
)
echo   Creating project: %PNAME%
xcopy "%PROJECTS%\_template" "%PPATH%" /E /I /Q >nul 2>&1

:: Create project.json
echo { > "%PPATH%\project.json"
echo   "project": "%PNAME%", >> "%PPATH%\project.json"
echo   "created": "%DATE%", >> "%PPATH%\project.json"
echo   "analyst": "Abdul Hafeez", >> "%PPATH%\project.json"
echo   "status": "In Progress", >> "%PPATH%\project.json"
echo   "version": "1.0" >> "%PPATH%\project.json"
echo } >> "%PPATH%\project.json"

:: Create README
echo # %PNAME% > "%PPATH%\docs\README.md"
echo. >> "%PPATH%\docs\README.md"
echo **Analyst:** Abdul Hafeez >> "%PPATH%\docs\README.md"
echo **Created:** %DATE% >> "%PPATH%\docs\README.md"
echo **Status:** In Progress >> "%PPATH%\docs\README.md"
echo. >> "%PPATH%\docs\README.md"
echo ## Folders >> "%PPATH%\docs\README.md"
echo - reports/   → .pbix files >> "%PPATH%\docs\README.md"
echo - datasets/  → source data >> "%PPATH%\docs\README.md"
echo - dax/       → DAX measures >> "%PPATH%\docs\README.md"
echo - exports/   → PDF/PNG outputs >> "%PPATH%\docs\README.md"
echo - data/raw   → raw CSV files >> "%PPATH%\docs\README.md"

echo   OK Project created: %PPATH%
echo   Opening folder...
explorer "%PPATH%"
goto :end

:: ── LIST PROJECTS ─────────────────────────────────────────
:list_projects
echo.
echo  Projects in %PROJECTS%:
echo  ─────────────────────────────────────────
for /d %%D in ("%PROJECTS%\*") do (
    set "DNAME=%%~nxD"
    if not "!DNAME!"=="_template" (
        echo   📁 !DNAME!
    )
)
echo.
goto :end

:: ── OPEN PROJECT ──────────────────────────────────────────
:open_project
set PNAME=%2
if "%PNAME%"=="" (
    echo   Usage: pbi-cli open ProjectName
    goto :end
)
if not exist "%PROJECTS%\%PNAME%" (
    echo   Project not found: %PNAME%
    goto :end
)
explorer "%PROJECTS%\%PNAME%"
echo   Opened: %PROJECTS%\%PNAME%
goto :end

:: ── DAX SEARCH ────────────────────────────────────────────
:dax_search
set KEYWORD=%2
if "%KEYWORD%"=="" (
    echo   Usage: pbi-cli dax [keyword]
    echo   Example: pbi-cli dax revenue
    goto :end
)
echo.
echo  Searching DAX library for: %KEYWORD%
echo  ─────────────────────────────────────────
findstr /i "%KEYWORD%" "%SHARED%\dax-library\master_measures.dax"
echo.
goto :end

:: ── CSV TO JSON ───────────────────────────────────────────
:csv_to_json
set CSVFILE=%2
if "%CSVFILE%"=="" (
    echo   Usage: pbi-cli csv-to-json filename.csv
    goto :end
)
if not exist "%CSVFILE%" (
    echo   File not found: %CSVFILE%
    goto :end
)
set OUTFILE=%CSVFILE:.csv=.json%
csvtojson "%CSVFILE%" > "%OUTFILE%"
echo   OK Converted: %OUTFILE%
goto :end

:: ── EXPORT DAX ────────────────────────────────────────────
:export_dax
set PNAME=%2
if "%PNAME%"=="" (
    echo   Usage: pbi-cli export-dax ProjectName
    goto :end
)
set SRC=%PROJECTS%\%PNAME%\dax
set DST=%SHARED%\dax-library\%PNAME%_measures.dax
if not exist "%SRC%" (
    echo   No dax folder found in project: %PNAME%
    goto :end
)
copy "%SRC%\*.dax" "%DST%" >nul 2>&1
echo   OK DAX exported to shared library: %DST%
goto :end

:: ── OPEN THEMES ───────────────────────────────────────────
:theme
explorer "%SHARED%\themes"
echo   Opened themes folder.
goto :end

:: ── SERVE ─────────────────────────────────────────────────
:serve
set PNAME=%2
if "%PNAME%"=="" (
    echo   Usage: pbi-cli serve ProjectName
    goto :end
)
set PPATH=%PROJECTS%\%PNAME%\exports
echo   Starting local server at http://localhost:8080
echo   Serving: %PPATH%
echo   Press Ctrl+C to stop.
http-server "%PPATH%" -p 8080 -o
goto :end

:: ── STATUS ────────────────────────────────────────────────
:status
echo.
echo  ==========================================
echo   WORKSPACE STATUS
echo  ==========================================
echo   Root : %ROOT%
echo.
echo   Tools installed:
node --version >nul 2>&1 && echo   OK Node.js && node --version || echo   X  Node.js missing
npm --version >nul 2>&1 && echo   OK npm && npm --version || echo   X  npm missing
git --version >nul 2>&1 && echo   OK Git && git --version || echo   X  Git missing
pbiviz --version >nul 2>&1 && echo   OK pbiviz && pbiviz --version || echo   X  pbiviz missing
echo.
echo   Projects:
for /d %%D in ("%PROJECTS%\*") do (
    set "DNAME=%%~nxD"
    if not "!DNAME!"=="_template" echo     📁 !DNAME!
)
echo.
goto :end

:end
endlocal
