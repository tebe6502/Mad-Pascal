echo off

@setlocal
@set MP_PATH=D:\Ulubione\Atari\mp_166_20220529\
@set PATH=%PATH%;%MP_PATH%;D:\Ulubione\Atari\Altirra-4.00\

del src\*.a65
del bin\*.xex

mp.exe src\stubwin.pas -ipath:src
mp.exe src\stubapp.pas -ipath:src
mp.exe src\appdemo.pas -ipath:src

if not exist src\stubwin.a65 goto :exit
if not exist src\stubapp.a65 goto :exit
if not exist src\appdemo.a65 goto :exit

mads.exe src\stubwin.a65 -x -i:%MP_PATH%base -o:bin\stubwin.xex
mads.exe src\stubapp.a65 -x -i:%MP_PATH%base -o:bin\stubapp.xex
mads.exe src\appdemo.a65 -x -i:%MP_PATH%base -o:bin\appdemo.xex

if not exist bin\stubwin.xex goto :exit
if not exist bin\stubapp.xex goto :exit
if not exist bin\appdemo.xex goto :exit

Altirra64.exe bin\stubwin.xex
Altirra64.exe bin\stubapp.xex
Altirra64.exe bin\appdemo.xex

:exit