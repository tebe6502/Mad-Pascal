#include <stdio.h>
#include <atari.h>

void draw_board()
{
	register unsigned char* p = OS.savmsc;
	register unsigned char i, j, k;
	for (i = 8; i > 0; --i)
	{
		for (j = 24; j > 0; --j)
		{
			for (k = 4; k > 0; --k)
			{
				p[0] = 255;
				p[1] = 255;
				p[2] = 255;
				p += 6;
			}
			p += 16;
		}
		p += i & 1 ? -3 : 3;
	}
}

void main(void)
{
	unsigned char stop;
	unsigned char I=0;

	_graphics(8 + 16);
	OS.color1 = 1;
	OS.color2 = 11;
	OS.color4 = 12;
	OS.rtclok[2] = 0;
	while (OS.rtclok[2] < 150)
	{
		draw_board();
		++I;
	}
	stop = OS.rtclok[2];
	_graphics(0);
	printf("%u", I);
	infinite:
		goto infinite;
}