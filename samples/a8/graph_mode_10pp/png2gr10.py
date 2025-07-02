#/usr/bin/python
import math
import sys
from PIL import Image

if len(sys.argv) != 5:
    print "Usage details: png2go10.py <in_file> <out_file> <back_color_x> <back_color_y>"
    sys.exit()

img = Image.open(sys.argv[1])
px = img.load() 
blackPos = [int(sys.argv[3]) , int(sys.argv[4])]
black = px[blackPos[0],blackPos[1]]
out = []

[width, height] = img.size

def getColorVal(x, y):
    pc = px[x, y]
    return (pc - black) % 9

print 'height:', height
print 'width:', width
bytewidth = int(math.ceil(width / 2.0));
print 'byte width:', bytewidth

if (width % 2) != 0:
    print 'width is odd, so it gets extended to', width+1

for y in range(height):
    for x in range(bytewidth):
        xp = x * 2
        lb = getColorVal(xp, y)
        hb = 0
        if (xp+1) < width: 
            hb = getColorVal(xp+1, y)
        out.append(lb*16 + hb)
        
        
outData = bytearray(out)
newfile=open(sys.argv[2],'wb') 
newfile.write(outData)

    
