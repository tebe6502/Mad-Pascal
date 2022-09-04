echo off

@setlocal
@set MP_PATH=D:\Ulubione\Atari\mp_164_20210311\
@set FILE_NAME=SortViz
@set PATH=%PATH%;%MP_PATH%;D:\Ulubione\Atari\Altirra-3.90\

@set PAS_NAME=source\%FILE_NAME%.pas
@set A65_NAME=source\%FILE_NAME%.a65
@set XEX_NAME=%FILE_NAME%.xex

del %A65_NAME%
del %XEX_NAME%

mp.exe %PAS_NAME% -o -ipath:source
if not exist %A65_NAME% goto :exit

mads.exe %A65_NAME% -x -i:%MP_PATH%base -o:%XEX_NAME%
if not exist %XEX_NAME% goto :exit

Altirra64.exe %XEX_NAME%

:exit