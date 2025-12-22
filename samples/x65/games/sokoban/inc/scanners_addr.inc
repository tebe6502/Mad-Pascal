SCR_OFFSET  = $600;
CHR_OFFSET  = $800;

LMS         = $D000; // Memory address for character data (first text row)
LFS         = LMS + SCR_OFFSET; // Memory address for character color data (first text row)
LBS         = LFS + SCR_OFFSET; // Memory address for background color data (first text row)
LCG         = LBS + SCR_OFFSET; // Character generator memory address (8x8 font)

CHARS_COUNT     = 124;
CHARSET_SIZE    = LCG + (CHARS_COUNT * 8) - 1;