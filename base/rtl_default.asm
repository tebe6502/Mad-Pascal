
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

	icl 'runtime\expand.asm'	; @xpandSHORT2SMALL, @expandSHORT2SMALL1
					; @expandToCARD.SHORT, @expandToCARD.SMALL, @expandToCARD.BYTE, @expandToCARD.WORD
					; @expandToCARD1.SHORT, @expandToCARD1.SMALL, @expandToCARD1.BYTE, @expandToCARD1.WORD

	icl 'runtime\ini.asm'		; iniEAX_ECX_WORD, iniEAX_ECX_CARD
	icl 'runtime\mov.asm'		; movBX_EAX, movZTMP_aBX

	icl 'runtime\hi.asm'		; hiBYTE, hiWORD, hiCARD

; -----------------------------------------------------------------------

	icl 'common\screensize.asm'	; @SCREENSIZE

	icl 'common\cmpstr.asm'		; cmpSTRING2CHAR, cmpCHAR2STRING, cmpSTRING

	icl 'common\memmove.asm'	; @move, @moveu
	icl 'common\memset.asm'		; @fill
	icl 'common\strmove.asm'	; @moveSTRING, @moveSTRING_1, @buf2str
	icl 'common\recmove.asm'	; @moveRECORD
	icl 'common\strcat.asm'		; @addString

	icl 'common\shortint.asm'	; mul / div -> SHORTINT
	icl 'common\smallint.asm'	; mul / div -> SMALLINT
	icl 'common\integer.asm'	; mul / div -> INTEGER

	icl 'common\byte.asm'		; mul / div -> BYTE
	icl 'common\word.asm'		; mul / div -> WORD
	icl 'common\cardinal.asm'	; mul / div -> CARDINAL

	icl 'common\shortreal.asm'	; mul / div -> SHORTREAL	Q8.8
	icl 'common\shortreal_trunc.asm'; @SHORTREAL_TRUNC
	icl 'common\shortreal_round.asm'; @SHORTREAL_ROUND
	icl 'common\shortreal_frac.asm'	; @SHORTREAL_FRAC

	icl 'common\real.asm'		; mul / div -> REAL		Q24.8
	icl 'common\real_trunc.asm'	; @REAL_TRUNC
	icl 'common\real_round.asm'	; @REAL_ROUND
	icl 'common\real_frac.asm'	; @REAL_FRAC
	
	icl 'common\single.asm'		; mul / div -> SINGLE		IEEE-754 32bit
	icl 'common\float16_add_sub.asm'; add / sub -> HALFSINGLE	IEEE-754 16bit
	icl 'common\float16_mul.asm'	; mul -> HALFSINGLE		IEEE-754 16bit
	icl 'common\float16_div.asm'	; div -> HALFSINGLE		IEEE-754 16bit
	icl 'common\float16_int.asm'	; int -> HALFSINGLE		IEEE-754 16bit
	icl 'common\float16_round.asm'	; round -> HALFSINGLE		IEEE-754 16bit
	icl 'common\float16_frac.asm'	; frac -> HALFSINGLE		IEEE-754 16bit
	icl 'common\float16_cmp.asm'	; cmp -> HALFSINGLE		IEEE-754 16bit
	icl 'common\float16_i2f.asm'	; cmp -> HALFSINGLE		IEEE-754 16bit

	icl 'common\mul40.asm'		; @mul40
	icl 'common\mul64.asm'		; @mul64
	icl 'common\mul96.asm'		; @mul96
	icl 'common\mul320.asm'		; @mul320

	icl 'common\int2hex.asm'	; @hexStr
	icl 'common\int2str.asm'	; @ValueToStr, @ValueToRec
	icl 'common\str2int.asm'	; @StrToInt, fmul10

	icl 'common\printchr.asm'	; @printCHAR, @printEOL, @print, @printPCHAR
	icl 'common\printstr.asm'	; @printSTRING
	icl 'common\printbool.asm'	; @printBOOLEAN

	icl 'common\printint.asm'	; @printMINUS, @printVALUE
					; @printBYTE, @printWORD, @printCARD
					; @printSHORTINT, @printSMALLINT, @printINT

	icl 'common\printsingle.asm'	; @FTOA
	icl 'common\printfloat.asm'	; @printSHORTREAL, @printREAL, @float
	icl 'common\printfloat16.asm'	; @F16_F2A
	
	icl 'common\allocmem.asm'	; @AllocMem, @FreeMem
