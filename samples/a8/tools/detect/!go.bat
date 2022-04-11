cd ..\..\..

sp test\tools\detect\detect.pas
sp test\tools\detect\sio2sd_detect.pas

cd test\tools\detect\

mads detect.a65 -x -i:..\..\..\base
mads sio2sd_detect.a65 -x -i:..\..\..\base

pause

