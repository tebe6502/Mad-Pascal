import cv2


def extract_mic(src, dst):
    src_bytes_per_line = 40
    dst_bytes_per_line = 32
    margin = (src_bytes_per_line - dst_bytes_per_line) // 2
    dst_lines = 160
    skip_lines = 16

    with open(src, 'rb') as fin:
        with open(dst, 'wb') as fout:
            # skip lines
            fin.read(skip_lines * src_bytes_per_line)

            # lines to copy
            for i in range(dst_lines):
                fin.read(margin)
                fout.write(fin.read(dst_bytes_per_line))
                fin.read(margin)


def convert_gr8(src, dst):
    image = cv2.imread(src, 0)
    height, width = image.shape
    bits = 8
    step = width // bits

    with open(dst, 'wb') as fout:
        for y in range(height):
            line = [0] * step
            for x in range(step):
                val = 0
                for b in range(bits):
                    if image[y, x * bits + b] > 0:
                        val += 2 ** (bits - b - 1)
                line[x] = val
            fout.write(bytearray(line))


extract_mic('faraon.mic', 'faraon.gr15')
convert_gr8('splash.png', 'splash.gr8')
