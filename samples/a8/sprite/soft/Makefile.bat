@echo off
rem Assemble the ASM libraries using MADS
rem
call :make_lib 8x16
call :make_lib 12x8
call :make_lib 12x16
call :make_lib 12x21
pause
goto :eof

:make_lib
echo Creating shape_%1.obj.
cd soft_%1
mads -o:shape_%1.obj shape_%1.asm
cd ..
goto :eof
