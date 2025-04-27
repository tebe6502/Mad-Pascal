@echo off
REM project name is the first argument - check if it is set
if "%~1"=="" (
    echo No argument supplied
    echo Usage: mpinit.bat project_name [nos]
    exit /b 1
)
set PROJECT_NAME=%~1
REM if second argument is 'nos' then select non OS template
REM default is OS template
if "%~2"=="nos" (
    set INFILE=start_nos.pas
) else (
    set INFILE=start_os.pas
)
REM clone MadStrap git repository into project folder
git clone https://gitlab.com/bocianu/madstrap %PROJECT_NAME%
REM enter project folder
cd %PROJECT_NAME%
REM remove old MadStrap .git folder
rmdir /s /q .git
REM copy the selected template to project main *.pas 
copy %INFILE% %PROJECT_NAME%.pas
REM update build.bat accordingly
powershell -Command "(Get-Content build.bat) -replace 'NAME=start_os', 'NAME=%PROJECT_NAME%' -replace 'ADDINTRO=1', 'ADDINTRO=0' | Set-Content build.bat"
REM replace MadStrap program name with a new project name
powershell -Command "(Get-Content %PROJECT_NAME%.pas) -replace 'program madStrap;', 'program %PROJECT_NAME%;' | Set-Content %PROJECT_NAME%.pas"
REM remove the template files
del start_*.pas