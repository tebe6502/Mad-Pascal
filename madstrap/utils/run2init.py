#!/usr/bin/env python3
import sys
import os

f1 = sys.argv[1]
filedata = []
modified = False

if not f1:
    print("Usage: python run2init.py <xexfile>")
    sys.exit(1)

with open(f1, 'rb') as in_file:
    filedata = bytearray(in_file.read())  # Convert to bytearray for mutability
    #select byte at end -4 bytes
    if (filedata[-6] == 0xE0) and (filedata[-4] == 0xE1): 
        filedata[-6]  = 0xE2
        filedata[-4] = 0xE3
        modified = True

if modified:
    with open(f1, 'wb') as out_file:
        out_file.write(filedata)
    print(f"XEX file {f1} modified successfully.")
else:
    print(f"Run Block in XEX file not found.")