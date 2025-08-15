import argparse
from PIL import Image
import os

# Set up argument parser
parser = argparse.ArgumentParser(description='Convert image to custom format.')
parser.add_argument('input_file', type=str, help='Input image file name')
parser.add_argument('output_file', type=str, help='Output file name')
parser.add_argument('color_map', type=str, help='Color map string (2 or 4 digits)')
args = parser.parse_args()

fname = args.input_file
outfile = args.output_file
color_map = args.color_map

if len(color_map) not in [2, 4]:
    raise ValueError("Color map must be 2 or 4 digits long")

print(f'*** processing file {fname}')
img = Image.open(f'{fname}')
w, h = img.size
if img.mode != 'P':
    print(f'*** changing color depth to {len(color_map)}')
    img = img.convert("P", palette=Image.Palette.ADAPTIVE, colors=len(color_map))        

pixels = bytearray(img.getdata())
palette = bytearray(img.getpalette())
outdata = bytearray()   

# Apply color map
mapped_pixels = bytearray(len(pixels))
for i, p in enumerate(pixels):
    mapped_pixels[i] = int(color_map[p])

def save_2bpp(mapped_pixels, outfile):
    outdata = bytearray()
    if len(mapped_pixels) > 0:
        with open(f'{outfile}', 'wb') as out_file:
            print(f'*** writing {outfile}')
            cbyte = 0
            shift = 6
            for p in mapped_pixels:
                cbyte |= (p << shift)
                if shift == 0:
                    outdata.append(cbyte)
                    cbyte = 0  # Reset cbyte after appending to outdata
                    shift = 6
                else:
                    shift -= 2   
            if shift != 6:
                outdata.append(cbyte)

            out_file.write(outdata)

def save_1bpp(mapped_pixels, outfile):
    outdata = bytearray()
    if len(mapped_pixels) > 0:
        with open(f'{outfile}', 'wb') as out_file:
            print(f'*** writing {outfile}')
            cbyte = 0
            shift = 7
            for p in mapped_pixels:
                cbyte |= (p << shift)
                if shift == 0:
                    outdata.append(cbyte)
                    cbyte = 0  # Reset cbyte after appending to outdata
                    shift = 7
                else:
                    shift -= 1   
            if shift != 7:
                outdata.append(cbyte)

            out_file.write(outdata)

if len(color_map) == 2:
    save_1bpp(mapped_pixels, outfile)
if len(color_map) == 4:
    save_2bpp(mapped_pixels, outfile)

print(f'*** DONE\n')