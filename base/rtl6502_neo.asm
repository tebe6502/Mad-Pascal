  opt l-

/* -----------------------------------------------------------------------
/*                        CPU 6502 Run Time Library - Neo 6502

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

  icl 'rtl_default.asm'
  
; -----------------------------------------------------------------------

  icl 'neo\neo.asm'
  icl 'neo\putchar.asm'	    ; @putchar
  icl 'neo\clrscr.asm'	    ; @clrscr
  icl 'neo\getkey.asm'	    ; @clrscr
  icl 'neo\getline.asm'	    ; @clrscr
	
; -----------------------------------------------------------------------


  opt l+
