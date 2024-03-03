from PIL import Image
import os

indir = 'images'
outdir = 'storage'
fnum = 0

directory = os.fsencode(indir)
for file in os.listdir(directory):
    fname = os.fsdecode(file)
    print(f'*** procesing file {fname}')
    img = Image.open(f'{indir}/{fname}')
    w, h = img.size
    if (w>320) or (h>240):
        print(f'*** scaling down to 320x240')
        img.thumbnail((320,240), resample=Image.BICUBIC)
    w, h = img.size        
    if (w<320) or (h<240):
        print(f'*** adding margins')
        back = Image.new('RGB', (320,240), (0, 0, 0)) 
        back.paste(img,((320-w)//2,(240-h)//2))
        img = back
    if img.mode != 'P':
        print(f'*** changing color depth')
        img = img.convert("P", palette=Image.ADAPTIVE, colors=256)        

    pixels = bytearray(img.getdata())
    palette = bytearray(img.getpalette())
    if len(pixels)>0:
        with open(f'{outdir}/slide{fnum}.img', 'wb') as out_file:
            print(f'*** writing {fname}')
            out_file.write(pixels)
    with open(f'{outdir}/slide{fnum}.pal', 'wb') as out_file:
        print(f'*** saving palette for {fname}')
        out_file.write(palette)
    fnum += 1
    print(f'*** DONE\n')