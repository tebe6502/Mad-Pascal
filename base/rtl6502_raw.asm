  opt l-

/* -----------------------------------------------------------------------
/*                        CPU 6502 Run Time Library - RAW
/*              19.04.2018 ; 04.12.2021
/* -----------------------------------------------------------------------
/* 16.03.2019 poprawka dla @printPCHAR, @printSTRING gdy [YA] = 0
/* 29.02.2020 optymalizacja @printREAL, pozbycie sie
/*    'jsr mov_BYTE_DX', 'jsr mov_WORD_DX', 'jsr mov_CARD_DX'
/* 07.04.2020 negSHORT, @TRUNC_SHORT, @ROUND_SHORT, @FRAC_SHORT, @INT_SHORT
/* 19.04.2020 nowe podkatalogi base\atari, base\common, base\runtime
/* 10.01.2021 c4plus
/* -----------------------------------------------------------------------

@AllocMem
@FreeMem

*/

MAXSIZE = 4
EOL = $0D
@buf  = $0200   ; lo addr = 0 !!!

fracpart = eax

; -----------------------------------------------------------------------

.enum e@file
  eof = 1, open, assign
.ende

.struct s@file
pfname  .word               ; pointer to string with filename
record  .word               ; record size
chanel  .byte               ; channel *$10
status  .byte               ; status bit 0..7
buffer  .word               ; load/write buffer
nrecord .word               ; number of records for load/write
numread .word               ; pointer to variable, length of loaded data
.ends

; -----------------------------------------------------------------------

  icl 'runtime\macros.asm'
  
; -----------------------------------------------------------------------

  icl 'raw\raw.hea'
  icl 'raw\putchar.asm'	    ; @putchar

; -----------------------------------------------------------------------

  icl 'rtl_default.asm'
	
; -----------------------------------------------------------------------

  opt l+
