#include <stdio.h>
#include <atari.h>

void main(void)
{
        register unsigned int i=0;
        register unsigned int a=0;
        register unsigned int b=0;
	register unsigned char n=0;

	n = OS.rtclok[2];
	while (OS.rtclok[2] == n) { ; }
	OS.rtclok[2] = 0;

	while (OS.rtclok[2] < 100)
	{
              ++a;
              b=a;
              ++b;
              a=b;
              ++i;
	}
	printf("%u", i);
	infinite:
		goto infinite;
}