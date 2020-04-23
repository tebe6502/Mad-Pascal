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
/* -----------------------------------------------------------------------

@AllocMem
@FreeMem

*/

// IORESULT = 106	Invalid numeric format

; wiersz obrazu dla mapy kolorow VBXE = 256 bajtow (40*4 + ...)
; szerokosc linii obrazu dla OVERLAY = 320

FX_VIDEO_CONTROL equ    0x40
FX_VC		equ    FX_VIDEO_CONTROL
VC_XDL_ENABLED	equ     1
VC_XCOLOR	equ     2
VC_NTR		equ     4
VC_NO_TRANS	equ     VC_NTR
VC_TRANS15	equ     8

; Palette registers
FX_CSEL         equ     0x44
FX_PSEL         equ     0x45
FX_CR           equ     0x46
FX_CG           equ     0x47
FX_CB           equ     0x48

; Raster collision detection
FX_COLMASK      equ     0x49
FX_COLCLR       equ     0x4a
FX_COLDETECT    equ     0x4a

; XDL Address
FX_XDL_ADR0     equ     0x41
FX_XDL_ADR1     equ     0x42
FX_XDL_ADR2     equ     0x43
VBXE_MINOR	equ	0x41

; MEMAC-A / MEMAC-B registers
FX_MEMAC_B_CONTROL equ	0x5d
FX_MEMB            equ	FX_MEMAC_B_CONTROL
FX_MEMAC_CONTROL   equ	0x5e
FX_MEMC            equ	FX_MEMAC_CONTROL
FX_MEMAC_BANK_SEL  equ	0x5f
FX_MEMS            equ	FX_MEMAC_BANK_SEL

; Blitter registers
FX_BL_ADR0	equ	0x50
FX_BL_ADR1	equ	0x51
FX_BL_ADR2	equ	0x52
FX_BLITTER_START equ	0x53
FX_BLT_COL_CODE	equ	0x50
FX_BLT_COLLISION_CODE equ FX_BLT_COL_CODE
FX_BLITTER_BUSY	equ	0x53

; Blitter IRQ
FX_IRQ_CONTROL   equ	0x54
FX_IRQ_STATUS    equ	0x54

; Info registers (read only)
FX_CORE_VERSION   equ	0x40
FX_MINOR_REVISION equ	0x41

; Priority registers
FX_P0		 equ	0x55
FX_P1		 equ	0x56
FX_P2		 equ	0x57
FX_P3		 equ	0x58

FX_CORE_RESET   equ	0xD080

; XDLC bits
XDLC_TMON	equ     1
XDLC_GMON	equ     2
XDLC_OVOFF	equ     4
XDLC_MAPON	equ     8
XDLC_MAPOFF	equ     0x10
XDLC_RPTL	equ     0x20
XDLC_OVADR	equ     0x40
XDLC_OVSCRL	equ     0x80
XDLC_CHBASE	equ     0x100
XDLC_MAPADR	equ     0x200
XDLC_MAPPAR	equ     0x400
XDLC_OVATT	equ     0x800
XDLC_ATT	equ     0x800
XDLC_HR		equ     0x1000
XDLC_LR		equ     0x2000
XDLC_END	equ     0x8000

MAXSIZE = 4
EOL	= $9B
@buf	= $0400		; lo addr = 0 !!!

fracpart = eax

; -----------------------------------------------------------------------

.enum	e@xdl
	ovroff, lr, ovron, hr, mapon, mapoff
.ende

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

.struct	s@xdl
.word	XDLC_		; puste linie
.byte	RPTL_
.word	XDLC
.byte	RPTL
.long	OVADR
.word	OVSTEP
.long	MAPADR
.word	MAPSTEP
.byte	HSCROL
.byte	VSCROL
.byte	WIDTH
.byte	HEIGHT
.byte	OVWIDTH
.byte	OVPRIOR
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

; store value in fx register (via accumulator)
fxs     .macro

        lda     :2
        ldy     #:1
        sta     (fxptr),y

        .endm

; store accumulator in fx register
fxsa    .macro

        ldy     #:1
        sta     (fxptr),y

        .endm

; load fx register value to accumulator
fxla    .macro

        ldy     #:1
        lda     (fxptr),y

        .endm


m@call	.macro (os_proc)

	jsr %%os_proc

	.endm


; -----------------------------------------------------------------------

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

; -----------------------------------------------------------------------


.proc	@AllocMem	;(.word ztmp .byte ztmp+2) .var

	sta ztmp+1
	sty ztmp+2

loop	lda (psptr),y
	sta ztmp+3

	lda (ztmp),y
	sta (psptr),y

	lda ztmp+3
	sta (ztmp),y

	dey
	bpl loop

	lda psptr
	sec
	adc ztmp+2
	sta psptr
	scc
	inc psptr+1

	rts
.endp


.proc	@FreeMem	;(.word ztmp .byte ztmp+2) .var

	sta ztmp+1

	tya
	eor #$ff
	clc
	adc psptr
	sta psptr
	scs
	dec psptr+1

loop	lda (psptr),y
	sta ztmp+3

	lda (ztmp),y
	sta (psptr),y

	lda ztmp+3
	sta (ztmp),y

	dey
	bpl loop

	rts
.endp


; -----------------------------------------------------------------------

	opt l+
