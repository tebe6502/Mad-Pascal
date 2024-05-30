cd ..\..

sp test\visage\koala.pas
sp test\visage\loadgif.pas
sp test\visage\mic.pas

cd test\visage

mads koala.a65 -x -i:..\..\base\
mads loadgif.a65 -x -i:..\..\base\
mads mic.a65 -x -i:..\..\base\

pause
