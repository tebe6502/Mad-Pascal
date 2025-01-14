  opt l-

/* -----------------------------------------------------------------------
/*                        CPU 6502 runtime library - RAW
/* 19.04.2018 ; 04.12.2021 ; 28.02.2024
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

; -----------------------------------------------------------------------

  icl 'runtime\macros.asm'

; -----------------------------------------------------------------------

  icl 'rtl_default.asm'
  
; -----------------------------------------------------------------------

  icl 'raw\raw.hea'
  icl 'raw\putchar.asm'	    ; @putchar
	
; -----------------------------------------------------------------------

  opt l+
