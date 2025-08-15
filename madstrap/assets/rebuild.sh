#!/bin/bash
MEMFILE=memory_pak.inc
RCFILE=resources_pak.rc
#PAKCMD="../utils/zx5.exe -f"
PAKCMD="../utils/apultra.exe"

#convert individual images
python ../utils/convert.py mad_pascal_logo.png mplogo.gfx 01
$PAKCMD mplogo.gfx mplogo.pak



