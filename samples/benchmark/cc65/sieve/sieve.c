/* Eratosthenes Sieve benchmark */

#include <peekpoke.h>
#include <stdio.h>
#include <string.h>

#define true 1
#define false 0
#define size 8190
#define sizepl 8192
#define tick 0x14
#define tack 0x13

unsigned char flags[sizepl];

void wait(void)
{
 unsigned char a=PEEK(tick);
 while (PEEK(tick)==a) { ; }
}

int main()
{
	register unsigned int i, prime, k, count, iter;
	
	wait();

	printf("10 iterations\n");

	asm(" lda #0");
	asm(" sta $13");
	asm(" sta $14");

        for (iter = 10 ; iter > 0; --iter)
        {
                count = 0;
		memset(flags, true, sizeof(flags));
                for (i=0;i<=size;++i)
                {
			if (flags[i]) {
				prime = i*2 + 3;
				k = i + prime;
				while (k <= size) {
					flags[k] = false;
					k += prime;
				}
				++count;
			}
		}
        }
	i=PEEK(0x14)+PEEK(0x13)*256;
	printf("%d primes\n", count);
	printf("%d ticks\n", i);
	
//        asm(" lda $13");
//        asm(" sta $600");
//        asm(" lda $14");
//        asm(" sta $601");

//      	asm(" lda #$80");
//      	asm(" sta 712");

        asm(" jmp *");			
	return 0;
}
