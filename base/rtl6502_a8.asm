	opt l-

/* -----------------------------------------------------------------------
/*                   CPU 6502 Run Time Library - Atari XE/XL
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

	icl 'runtime\macros.asm'

; -----------------------------------------------------------------------

	icl 'rtl_default.asm'

; -----------------------------------------------------------------------

	icl 'atari\vbxe.hea'
	icl 'atari\atari.hea'

	icl 'atari\sio.asm'		; I/O SIO: @sio
	icl 'atari\cio.asm'		; I/O CIO: @openfile, @closefile, @readfile, @ReadDirFileName, @DirFileName

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
	icl 'atari\vbxeansi.asm'	; @ansi
	icl 'atari\vbxeclrscr.asm'	; @vbxe_clrscr
	icl 'atari\vbxecrs.asm'		; @vbxe_cursor
	icl 'atari\vbxesetcrs.asm'	; @vbxe_setcursor
	icl 'atari\vbxeputbyte.asm'	; @vbxe_putbyte
	icl 'atari\vbxescroll.asm'	; @vbxe_scroll

	icl 'atari\xmsbank.asm'		; @xmsBank
	icl 'atari\xmspos.asm'		; @xmsAddPosition, @xmsUpdatePosition
	icl 'atari\xmsread.asm'		; @xmsReadBuf
	icl 'atari\xmswrite.asm'	; @xmsWriteBuf

; -----------------------------------------------------------------------

	opt l+
