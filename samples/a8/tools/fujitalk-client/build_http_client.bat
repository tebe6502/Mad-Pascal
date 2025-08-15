rem
rem
rem set PATH=%WUDSN_TOOLS_FOLDER%\asm\MADS\bin\windows_x86_64;%PATH%
mads.exe http_client.asm -o:http_client.obj | grep "= \$" > http_client.inc
