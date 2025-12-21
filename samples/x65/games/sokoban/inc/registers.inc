var

CGIA_RASTER               : byte absolute $FF10; // Raster Counter
CGIA_INT_STATUS           : byte absolute $FF1B; // RST Interrupt status
CGIA_INT_ENABLE           : byte absolute $FF1A; // RST Interrupt enabled
CGIA_PLANES               : byte absolute $FF30;
CGIA_OFFSET0              : word absolute $FF38;
CGIA_PLANE0               : byte absolute $FF40;
CGIA_PLANE0_FLAGS         : byte absolute $FF40;
CGIA_PLANE0_ROW_HEIGHT    : byte absolute $FF42;
CGIA_PLANE0_STRIDE        : byte absolute $FF43;
CGIA_PLANE0_SHARED_COLOR1 : byte absolute $FF48;
CGIA_PLANE0_SHARED_COLOR2 : byte absolute $FF49;

GPIO_IN0                  : byte absolute $FF80;