@setlocal
@SET PATH=%PATH%;D:\atari\MadPascal;D:\atari\mads;D:\neo6502
@SET ORG=7000

@SET CURPWD=%cd%
@SET CURPWD=%CURPWD: =:%
@SET CURPWD=%CURPWD:\= %
@call :getparentdir %CURPWD%
@SET NAME=%CURPWD::=_%

mp.exe %NAME%.pas -target:neo -code:%ORG%
@if %ERRORLEVEL% == 0 mads %NAME%.a65 -x -i:D:\atari\MadPascal\base -o:%NAME%.neo
@if %ERRORLEVEL% == 0 neo.exe %NAME%.neo@%ORG% run@%ORG%

:getparentdir
@if "%~1" EQU "" goto :EOF
@Set CURPWD=%~1
@shift
@goto :getparentdir