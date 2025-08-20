//przerwania


dli0			sta dli_A
			stx dli_X

licznik			ldx #0

			lda charsets-2,x
			sta wsync
			sta chbase

			lda tcolor-2,x
creg			sta $d01e

			lda blok_x01,x			;player 0 i 1
			beq @+
			sta hposp1
			sta hposp0
			lsr
			beq @+				;=0 poza ekranem, nie zmieniaj kolorów
			lda blok_c0,x
			sta colpm0
			lda blok_c1,x
			sta colpm1

@			lda blok_x23,x			;player 2 i 3
			beq @+
			sta hposp3
			sta hposp2
			lsr
			beq @+
			lda blok_c2,x
			sta colpm2
			lda blok_c3,x
			sta colpm3

@			lda #0				;wyczysc pozycję
			sta blok_x01,x
			sta blok_x23,x
			sta blok_status,x

			inc licznik+1

			lda dli_A
			ldx dli_X
			rti



/*
?adr = *

	.rept 26,#,#+2,#+1
dli%%1			sta dli_A

dli%%1.chrs		lda #0
			sta wsync
			sta chbase

dli%%1.col0		lda #0
dli%%1.reg0		sta $d01e
dli%%1.col1		lda #0
dli%%1.reg1		sta $d01e

			lda blok_x01+%%2		;player 0 i 1
			beq @+
			sta hposp1
			sta hposp0
			lsr
			beq @+				;=0 poza ekranem, nie zmieniaj kolorów
			lda blok_c0+%%2
			sta colpm0
			lda blok_c1+%%2
			sta colpm1

@			lda blok_x23+%%2		;player 2 i 3
			beq @+
			sta hposp3
			sta hposp2
			lsr
			beq @+
			lda blok_c2+%%2
			sta colpm2
			lda blok_c3+%%2
			sta colpm3

@			lda #0				;wyczysc pozycję
			sta blok_x01+%%2
			sta blok_x23+%%2
			sta blok_status+%%2

		ift %%3 < 26
			mva <dli%%3 vdli+1

			ift .hi(dli%%3) <> .hi(?adr)
			mva >dli%%3 vdli+2
			eif
		eif

			lda dli_A
			rti
?adr = *

	.endr
*/

.local		nmi

			bit nmist
			bpl vbl

			jmp vdli: dli0

vbl			phr
			sta nmist

			inc tim

			mva #2 licznik+1

			mwa SDLSTL dlptr
			mva sdmctl dmactl

			mwa #dli0 vdli

vbl_user		jmp $0100

.endl