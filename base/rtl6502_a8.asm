	opt l-

/* -----------------------------------------------------------------------
/*                        CPU 6502 Run Time Library
/*			        19.04.2018
/* -----------------------------------------------------------------------
/* 16.03.2019	poprawka dla @printPCHAR, @printSTRING gdy [YA] = 0
/* 29.02.2020	optymalizacja @printREAL, pozbycie sie
/*		'jsr mov_BYTE_DX', 'jsr mov_WORD_DX', 'jsr mov_CARD_DX'
/* 07.04.2020	negSHORT, @TRUNC_SHORT, @ROUND_SHORT, @FRAC_SHORT, @INT_SHORT
/* 19.04.2020	nowe podkatalogi base\atari, base\common, base\runtime
/* 12.09.2020	c64 ?
/* -----------------------------------------------------------------------

@AllocMem
@FreeMem

*/

MAXSIZE = 4
@buf	= $0400		; lo addr = 0 !!!
EOL	= $9B
fracpart = eax

; -----------------------------------------------------------------------

.enum	e@file
	eof = 1, open, assign
.ende

.struct	s@file
pfname	.word		; pointer to string with filename
record	.word		; record size
chanel	.byte		; channel *$10
status	.byte		; status bit 0..7
buffer	.word		; load/write buffer
nrecord	.word		; number of records for load/write
numread	.word		; pointer to variable, length of loaded data
.ends

; -----------------------------------------------------------------------

.macro	m@add
	lda %%1
	clc
	adc %%2
	sta %%3
.endm

.macro	m@adc
	lda %%1
	adc %%2
	sta %%3
.endm

.macro	m@sub
	lda %%1
	sec
	sbc %%2
	sta %%3
.endm

.macro	m@sbc
	lda %%1
	sbc %%2
	sta %%3
.endm


.macro	m@index2 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm

.macro	m@index4 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm


m@call	.macro (os_proc)

	.ifdef MAIN.@DEFINES.ROMOFF

		inc portb

		jsr %%os_proc

		dec portb

	.else

		jsr %%os_proc

	.endif

	.endm

; -----------------------------------------------------------------------

	icl 'atari\vbxe.hea'
	icl 'atari\atari.hea'

	icl 'atari\sio.asm'		; I/O SIO
	icl 'atari\cio.asm'		; I/O CIO

	icl 'atari\cmdline.asm'		; @CmdLine

	icl 'atari\ata2int.asm'		; @ata2int
	icl 'atari\clrscr.asm'		; @ClrScr
	icl 'atari\getkey.asm'		; @GetKey
	icl 'atari\getline.asm'		; @GetLine
	icl 'atari\putchar.asm'		; @putchar
	icl 'atari\graphics.asm'	; @GRAPHICS, @COMMAND, @SCREENSIZE

	icl 'atari\vbxedetect.asm'	; @vbxe_detect
	icl 'atari\vbxeinit.asm'	; @vbxe_init
	icl 'atari\vbxexdl.asm'		; @set_xdl
	icl 'atari\vbxeput.asm'		; @vbxe_put

	icl 'atari\xmsbank.asm'		; @xmsBank
	icl 'atari\xmspos.asm'		; @xmsAddPosition, @xmsUpdatePosition
	icl 'atari\xmsread.asm'		; @xmsReadBuf
	icl 'atari\xmswrite.asm'	; @xmsWriteBuf

; -----------------------------------------------------------------------

	icl 'runtime\trunc.asm'		; @TRUNC, @TRUNC_SHORT
	icl 'runtime\round.asm'		; @ROUND, @ROUND_SHORT
	icl 'runtime\frac.asm'		; @FRAC, @FRAC_SHORT
	icl 'runtime\int.asm'		; @INT, @INT_SHORT

	icl 'runtime\icmp.asm'		; cmpSHORTINT, cmpSMALLINT, cmpINT
	icl 'runtime\lcmp.asm'		; cmpEAX_ECX

	icl 'runtime\add.asm'		; addAL_CL, addAX_CX, addEAX_ECX
	icl 'runtime\sub.asm'		; subAL_CL, subAX_CX, subEAX_ECX

	icl 'runtime\shl.asm'		; shlEAX_CL.BYTE, shlEAX_CL.WORD, shlEAX_CL.CARD
	icl 'runtime\shr.asm'		; shrAL_CL, shrAX_CL, shrEAX_CL

	icl 'runtime\not.asm'		; notaBX, notBOOLEAN
	icl 'runtime\neg.asm'		; negBYTE, negWORD, negCARD, negBYTE1, negWORD1, negCARD1
					; negEDX, negSHORT

	icl 'runtime\or.asm'		; orAL_CL, orAX_CX, or_EAX_ECX
	icl 'runtime\xor.asm'		; xorAL_CL, xorAX_CX, xor_EAX_ECX
	icl 'runtime\and.asm'		; andAL_CL, andAX_CX, and_EAX_ECX

	icl 'runtime\expand.asm'	; @xpandSHORT2SMALL, @expandSHORT2SMALL1
					; @expandToCARD.SHORT, @expandToCARD.SMALL, @expandToCARD.BYTE, @expandToCARD.WORD
					; @expandToCARD1.SHORT, @expandToCARD1.SMALL, @expandToCARD1.BYTE, @expandToCARD1.WORD

	icl 'runtime\ini.asm'		; iniEAX_ECX_WORD, iniEAX_ECX_CARD
	icl 'runtime\mov.asm'		; movBX_EAX, movZTMP_aBX

	icl 'runtime\hi.asm'		; hiBYTE, hiWORD, hiCARD

; -----------------------------------------------------------------------

	icl 'common\cmpstr.asm'		; cmpSTRING2CHAR, cmpCHAR2STRING, cmpSTRING

	icl 'common\memmove.asm'	; @move, @moveu
	icl 'common\memset.asm'		; @fill
	icl 'common\strmove.asm'	; @moveSTRING, @moveSTRING_1
	icl 'common\strcat.asm'		; @addString

	icl 'common\shortint.asm'	; mul / div -> SHORTINT
	icl 'common\smallint.asm'	; mul / div -> SMALLINT
	icl 'common\integer.asm'	; mul / div -> INTEGER

	icl 'common\byte.asm'		; mul / div -> BYTE
	icl 'common\word.asm'		; mul / div -> WORD
	icl 'common\cardinal.asm'	; mul / div -> CARDINAL

	icl 'common\shortreal.asm'	; mul / div -> SHORTREAL	Q8.8
	icl 'common\real.asm'		; mul / div -> REAL		Q24.8
	icl 'common\single.asm'		; mul / div -> SINGLE		IEEE-754

	icl 'common\mul40.asm'		; @mul40
	icl 'common\mul320.asm'		; @mul320

	icl 'common\int2hex.asm'	; @hexStr
	icl 'common\int2str.asm'	; @ValueToStr
	icl 'common\str2int.asm'	; @StrToInt, fmul10

	icl 'common\printchr.asm'	; @printCHAR, @printEOL, @print, @printPCHAR
	icl 'common\printstr.asm'	; @printSTRING
	icl 'common\printbool.asm'	; @printBOOLEAN

	icl 'common\printint.asm'	; @printMINUS, @printVALUE
					; @printBYTE, @printWORD, @printCARD
					; @printSHORTINT, @printSMALLINT, @printINT

	icl 'common\printsingle.asm'	; @FTOA
	icl 'common\printfloat.asm'	; @printSHORTREAL, @printREAL, @float

	icl 'common\allocmem.asm'	; @AllocMem, @FreeMem

; -----------------------------------------------------------------------

	opt l+
