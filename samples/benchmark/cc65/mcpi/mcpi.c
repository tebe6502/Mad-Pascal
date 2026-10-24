#include <stdio.h>

#define p 10000
#define r 16129

#define RTCLOK1 (*(volatile unsigned char*)0x13)
#define RTCLOK2 (*(volatile unsigned char*)0x14)
#define RANDOM  (*(volatile unsigned char*)0xd20a)

void main(void)
{
  register unsigned int stop, i, x, y;
  register unsigned int b = 0;
  register unsigned char n;

  n = RTCLOK2;
  while (RTCLOK2 == n) { ; }

  printf("\nMonte-Carlo PI cc65 V2.18\n");

  RTCLOK1 = 0; RTCLOK2 = 0;
  for (i = 0 ; i < p; ++i)
  {
    n = (RANDOM | 128) ^ 128;
    x = n * n;
    n = (RANDOM | 128) ^ 128;
    y = n * n;
    if ((x + y) <= r)
      ++b;
  }
  b *= 4;
  stop = RTCLOK2 + 256 * RTCLOK1;

  printf("%u\x1e\x1e\x1e\x1e\xff.\n%u ticks\n", b, stop);

  for (;;);
}