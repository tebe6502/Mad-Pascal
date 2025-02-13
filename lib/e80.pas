unit e80;
(*
 @type: unit
 @author: Simon Trew, Tomasz Biela (Tebe)
 @name: 80: device
 @version: 1.2

   Version 1.2:
	- information about CIO, XIO command

 @description:
 80: device by SIMON TREW, 1989
*)

(*

CIO COMMANDS

The following CIO commands are supported:

OPEN #chan,mode,0,"80:"

Opens channel chan for the 80-column screen, sets colours and right margin.
The value after mode is shown as 0 but can be any value or variable in the range 0..255.
The mode can be any integer in the range 12..14. If it falls outside this range, 12 is assumed.

The modes supported are as follows:

12: Standard as for E: device. Input is buffered until Return is pressed and then the whole line is returned.
    The cursor can be moved freely around the screen and the Break, Ctrl-1 and Ctrl-3 keys act as normal.

13: "Return-Key" mode, as for the E: device. Whenever input is requested, say by the BASIC editor, no key input
    is taken but instead the handler generates its own "Return". This is sometimes used by programs to modify
    themselves (see "Notes on the Return-Key Mode", below).

14: All keyboard input is passed directly to the user as for the K: device, and not buffered like the E: device.
    This is useful if you have your own, more program-dependant key input routines.


XIO COMMANDS

The general format of an XIO command is:

XIO cmd,#chan,x,y,"80:"

This sends the command (cmd) that is specified to the channel (chan) that is specified, with x and y as parameters if necessary,
using the device name supplied. The device name is included for this reason: If the channel is not open, and the command is greater than 12,
signifying a SPECIAL function, or a STATUS command, then the channel is automatically opened, the command performed, and the channel closed.

In any case, the XIO command is used mainly for operations that are device-specific, such as disk RENAME, DELETE and FORMAT,
screen DRAWTO and so on.

The 80: device supports the following XIO commands:

XIO 17,#chan,x,y,"80:"

This is the XIO equivalent of a DRAWTO, and enables you to use channels other than 6 for graphics.

--------------------------------

XIO 18,#chan,x,y,"80:"

This is the much-maligned FILLTO command. Its operation is so empirical that I shall refer you to the Atari OS Users Manual,
Computer Animation Primer or any good Atari beginner's guide.

--------------------------------

XIO 38,#chan,0,0,"80:"

This is the equivalent of the NOTE x,y command. The x value can be found in ICAX3 and ICAX4 of the IOCB, or PEEK(852+chan*16) and PEEK(853+chan*16),
and the y command at ICAX5 or PEEK(854+chan*16). This method is not recommended from Basic.

--------------------------------

XIO 39,#chan,x,y,"80:"

Moves the whole of line x to line y, very quickly. This does not affect the cursor position.
This command moves the line byte-by-byte, and so any graphics will be moved as well.
This command uses the same subroutine to move a line as the scrolling / shift-insert / shift-delete routines.
If you want to fill a whole area with one character, use this command, it is a lot faster than a PRINT.

--------------------------------

XIO 40,#chan,x,0,"80:"

This command clears line x very quickly. It does not affect the cursor position.

--------------------------------

XIO 41,#chan,x,0,"80:"

This command scrolls line x and all lines below it up one line, and clears the bottom line.
This is similar to Shift-Delete, but doesn't affect the cursor position.

--------------------------------

XIO 42,#chan,x,0,"80:"

XIO 42 is the counterpart to the above command. It scrolls down all lines from x onwards, and clears line x.
It does not affect the cursor position.


The above 4 XIO commands are not inhibited by Ctrl-1 or Break, therefore they are slightly different to equivalent control codes.

XIO 43,#chan,0,0,"80:"

This command changes which mode the screen is in. Whenever the mode is changed, the cursor values are swapped with internal values,
so that it is possible to switch at will between graphics and text modes and still retain cursor positions for both of them.
To find the current mode, use STATUS.

--------------------------------

XIO 44,#chan,x,y,"80:"

This command inverts the character at x,y. The "character" can actually be any graphics data.
This is therefore a good way of creating your own cursor or inverting an area of the screen.
It is also a lot quicker than LOCATE and PUT since LOCATE needs to do quite an extensive search for characters through the character set,
as well as double the overhead of CIO time.

If you really like to be awkward, you can get a printable Return key by printing an escape character and inverting it.
Note that any line input on the line will be terminated at that "Return", though, and then another line containing the remaining characters will be returned.

--------------------------------

XIO 45,#chan,mode,0,"80:"

This is used to change the input mode from that specified in an OPEN command, and is most notably used to toggle on/off Return-Key mode.
You can use POKE, but since any XIO corrupts this value, this method is recommended as the value is updated after each XIO.
The value of Mode is as for the Return statement.

Note that if you do opt for the POKE, the address to poke is not 842 (which handles channel 0, the screen editor) but 842+16*chan,
where chan is the channel of the 80: device. See the notes on the Return-Key mode, below.

*)


{


}


interface



implementation

uses graph;


procedure inite80; assembler;

asm

TEMP1  = $F5
TEMP2  = $F7
TEMP3  = $F9

;
; CIO HANDLER 8:
;
HATABS = $31A   ;Handler table
IOCB   = $340   ;IOCB variables
ICCOM  = $342
ICAX1  = $34A
ICAX2  = $34B
ICAX3  = $34C
ICAX4  = $34D
ICAX5  = $34E
ROWCRS = $54    ;Cursor row (y)
COLCRS = $55    ;Cursor column (x)
LMARGN = $52    ;Left margin
RMARGN = $53    ;Right margin
CSRINH = $2F0   ;Cursor inhibit.

CIOV   = $E456  ;CIO Vector

CR     = $9B    ;Carriage Return
SPACE  = $20    ;ASCII Space.

GRMODE = $57	;Display mode
;

	JMP CIOHND

CHSET
	.he 06 A6 E6 E7 E7 46 46 06 16 16 16 1E 1E 10 10 10 60 60 60 EE EE 66 66 66 18 18 24 24 42 42 81 81
	.he 10 10 30 30 73 73 F3 F3 83 83 C3 C3 E0 E0 F0 F0 CF CF C0 C0 00 00 00 00 00 00 00 00 0C 0C FC FC
	.he 00 40 40 E7 A7 46 E6 06 06 06 06 FF FF 06 06 06 00 00 60 F0 FF FF 6F 0F 80 80 80 8F 8F 86 86 86
	.he 6C 6C 6C FC FC 0C 0C 0C 6C 68 6C 78 7E 04 06 00 00 44 E4 E4 4E 4E 44 00 00 24 66 FF 66 24 00 00
	.he 04 04 04 04 04 00 04 00 AA AA AE 0A 0E 0A 0A 00 40 6A 82 44 24 C8 4A 00 44 A4 A4 40 B0 A0 50 00
	.he 28 44 44 44 44 44 28 00 00 A4 44 EE 44 A4 00 00 00 00 00 0E 00 40 40 80 00 02 02 04 04 48 48 00
	.he 44 AC A4 E4 A4 A4 4E 00 4C A2 22 44 82 82 EC 00 8E A8 A8 EC 22 22 2C 00 4E 82 C2 A4 A8 A8 48 00
	.he 44 AA AA 4A A6 A2 44 00 00 00 44 44 00 44 44 08 00 20 4E 80 40 2E 00 00 04 8A 4A 22 44 80 04 00
	.he 44 AA AA AE 8A 8A 6A 00 C4 AA A8 C8 A8 AA C4 00 CE A8 A8 AC A8 A8 CE 00 E4 8A 88 CA 8A 8A 86 00
	.he AE A4 A4 E4 A4 A4 AE 00 2A 2A 2A 2C 2A 2A CA 00 8A 8E 8E 8E 8A 8A EA 00 C4 AA AA AA AA AA A4 00
	.he C4 AA AA AA CA 84 82 00 C6 A8 A8 C4 A2 A2 AC 00 EA 4A 4A 4A 4A 4A 4E 00 AA AA AA AE AE 4E 4A 00
	.he AA AA AA 44 A4 A4 A4 00 EE 28 28 48 88 88 EE 00 0E 82 82 42 42 22 2E 00 00 40 40 A0 A0 00 0E 00
	.he 00 40 4C E2 E6 4A 4E 00 80 80 C6 A8 A8 A8 C6 00 20 20 64 AA AE A8 66 00 60 80 86 CA 8A 86 82 0C
	.he 84 80 CC A4 A4 A4 AE 00 28 08 6A 2A 2C 2A AA 40 C0 40 44 4E 4E 4A EA 00 00 00 C4 AA AA AA A4 00
	.he 00 00 C6 AA AA C6 82 82 00 00 46 A8 84 82 8C 00 80 80 EA 8A 8A AA 4E 00 00 00 AA AA AE 4E 4A 00
	.he 00 00 AA AA 4A A6 A2 0C 00 04 E4 2E 4E 84 EE 00 60 6E 6C 6A 6A 62 62 60 00 28 6C EE 6C 28 00 00

; ***************************
; *       80: BASICS        *
; * ----------------------- *
; *   BY SIMON TREW, 1989.  *
; * ----------------------- *
; *                         *
; * These routines are the  *
; * backbone of the fast 80:*
; * driver and include basic*
; * screen read, write and  *
; * manipulate. They do not *
; * provide any CIO inter-  *
; * face, handled by 80CIO. *
; *                         *
; ***************************
;
BUFP    dta c'XXXXXXXX'
;
; MULTIPLY TEMP1 BY TWO
;
MULT
	CLC
	ASL TEMP1
	ROL TEMP1+1
	RTS
;
; MAKE TEMP1=TEMP1+TEMP2
;
ADD
	PHA
	CLC
	LDA TEMP1
	ADC TEMP2
	STA TEMP1
	LDA TEMP1+1
	ADC TEMP2+1
	STA TEMP1+1
	PLA
	RTS
;
; STORE CHAR HELD IN ACC.
;
;ODDFLG .BYTE 0
;TEMPAS .BYTE 0

STORE	.LOCAL
	STA TEMPAS   ;A=char to store
	PHA          ;Store accumulator
	TYA          ;and index regs.
	PHA
	TXA
	PHA
	LDA TEMPAS: #$00   ;Reload A after PUSHs
	TAX          ;X holds real value
	AND #$01     ;all the time.
	BEQ EVEN
	LDA #$FF
EVEN
	STA ODDFLG   ;Store FF=odd, 0=even
	CLC
	TXA          ;in ODDFLG
	AND #$7E     ;Get rid of inverse
	STA TEMP1    ;and round down odds
	LDA #0       ;Temp1 holds the
	STA TEMP1+1  ;offset into chset.
	JSR MULT     ;Multiplied by 2
	JSR MULT     ;Multiplied by 4
	CLC
	LDA <CHSET   ;Get the offset
	STA TEMP2    ;into the charset
	LDA >CHSET   ;and then add to
	STA TEMP2+1  ;the beginning of
	JSR ADD      ;the Charset
	LDY #7       ;Get 8 bytes
LOOP1
	LDA (TEMP1),Y  ;Get byte to store
	CMP ODDFLG     ;Odd flag set?
	BCS EVENZ
	AND #$0F       ;yes, strip top 4
	JMP CHECKINV
EVENZ
	LSR @          ;Even, rotate into
	LSR @          ;low 4 bits (thus
	LSR @          ;setting top 4 to
	LSR @          ;zero)
CHECKINV
	CPX #$80       ;If char to get is
	BCC NOTINV     ;more than 127 then
	EOR #$0F       ;invert character.
NOTINV
	STA BUFP,Y     ;and store in buf
	DEY            ;next byte
	BPL LOOP1
	PLA            ;Get back Accum.
	TAX            ;and index regs.
	PLA
	TAY
	PLA
	RTS
	.ENDL
;
; SET UP GRAPHICS 8
;
ZIOCB=$20
GRAVEC=$E410

GR8SET
	PHA
	TXA
	PHA          ;Save regs.

;	CLC          ;Get (address-1) of
;	LDA GRAVEC   ;CIO's screen setting
;	ADC #1       ;Up routine, and add
;	STA GOCIO+1  ;1 to it for a JSR
;	LDA GRAVEC+1 ;through the S: OPEN
;	ADC #0       ;vector.
;	STA GOCIO+2

	LDA #$0C     ;Screen Read/Write
	STA ZIOCB+10
	LDA #$08     ;Screen mode (8)
	STA ZIOCB+11

GOCIO	JSR $FFFF    ;(Changed!)

	PLA
	TAX          ;Restore regs.
	PLA          ;(not Y which holds
	RTS          ;the error code).

;
; CALC. START BYTE OF POSN. AT
; X,Y AND STORE IN TEMP1
;
SCRADR =$58
CALCXY
	PHA
	TYA
	PHA
	TXA
	PHA
	TYA
	STA TEMP1
	LDA #0
	STA TEMP1+1
	JSR MULT    ;Multiply Y by 2
	LDA TEMP1
	STA TEMP2
	LDA TEMP1+1 ;Store x2 to add to x8
	STA TEMP2+1 ;to get x10
	JSR MULT    ;Multiply Y by 4
	JSR MULT    ;Multiply Y by 8
	CLC
	JSR ADD     ;Add Yx2 to Yx8 =Y*10
	LDY #$5     ;Multiply Y*10 By 2^5
LOOP2
	JSR MULT    ;Total= Y*320
	DEY
	BNE LOOP2
	TXA
	LSR @
	STA TEMP2   ;Add on X
	LDA #0
	STA TEMP2+1
	JSR ADD
	LDA SCRADR   ;Add to address of
	STA TEMP2    ;first byte of screen
	LDA SCRADR+1
	STA TEMP2+1
	JSR ADD
	PLA
	TAX
	PLA
	TAY
	PLA          ;Thats it!
	RTS
;
;  PUT CHR IN A AT POSN. X,Y
;
PUTCHR
	JSR STORE     ;Get character
STORE8
	PHA
	TYA
	PHA           ;Store regs.
	TXA
	PHA
	JSR CALCXY    ;Get posn.
	TXA           ;Find out if X is
	LSR @         ;odd or even
	BCS ODDX
	LDX #$0       ;Put 8 bytes
	LDY #$0       ;Dummy for indexing
	LDA #40       ;Next line=40 bytes
	STA TEMP2     ;away
	LDA #0
	STA TEMP2+1
LOOP3
	LDA BUFP,X
	ASL @
	ASL @
	ASL @
	ASL @
	STA BUFP,X
	LDA (TEMP1),Y
	AND #$0F
	ORA BUFP,X
	STA (TEMP1),Y
	JSR ADD       ;Next line=40 bytes
	INX           ;away
	CPX #$8
	BNE LOOP3
FINCHR
	PLA
	TAX
	PLA
	TAY
	PLA
	RTS
ODDX
	LDX #$0       ;Put 8 bytes
	LDY #$0       ;Dummy for indexing
	LDA #40       ;Next line=40 bytes
	STA TEMP2     ;away
	LDA #0
	STA TEMP2+1
LOOP4
	LDA (TEMP1),Y
	AND #$F0
	ORA BUFP,X
	STA (TEMP1),Y
	JSR ADD       ;Next line=40 bytes
	INX           ;away
	CPX #$8
	BNE LOOP4
	BEQ FINCHR
;
;  MOVE LINE Y TO LINE X
;
MOVEYX
	PHA
	TYA
	PHA
	TXA
	PHA
	LDX #$00   ;X=0 to get address of
	JSR CALCXY ;first byte on line Y
	TAY        ;Y=orig. value of X so
	LDA TEMP1  ;can CALCXY again for
	STA TEMP3  ;the X line address
	LDA TEMP1+1 ;(after we store the
	STA TEMP3+1 ;result of the first)
	JSR CALCXY
	LDY #0      ;First 256 bytes
LOOP5A
	LDA (TEMP3),Y
	STA (TEMP1),Y
	INY
	BNE LOOP5A
	INC TEMP3+1	;Move up one page to
	INC TEMP1+1	;move the next lot of
LOOP5B
	LDA (TEMP3),Y	;(320-256) bytes
	STA (TEMP1),Y
	INY
	CPY #320-256	;Done all of that?
	BNE LOOP5B
	PLA		;Finished!
	TAX
	PLA
	TAY
	PLA
	RTS
;
;  CLEAR LINE Y
;
CLEARY
	PHA
	TXA
	PHA
	TYA
	PHA
	LDX #$0
	JSR CALCXY   ;Get first byte to
	TXA          ;clear, and make A&Y
	TAY          ;both equal to 0
LOOP6A
	STA (TEMP1),Y  ;Clear first page
	INY
	BNE LOOP6A
	INC TEMP1+1    ;Next page
LOOP6B
	STA (TEMP1),Y  ;Clear bytes 256 to
	INY            ;319 then done
	CPY #320-256
	BNE LOOP6B
	PLA            ;Finished!
	TAY
	PLA
	TAX
	PLA
	RTS
;
;  SCROLL UP FROM LINE Y
;
SCROLU
	PHA
	TXA
	PHA
	TYA
	PHA
	TAX            ;Store Y in X and
	INY            ;add 1 so move line
LOOP7
	JSR MOVEYX
	INY
	INX
	CPX #23        ;X=Last line?
	BCC LOOP7
	LDY #23        ;Clear last line
	JSR CLEARY
	PLA            ;Finished!
	TAY
	PLA
	TAX
	PLA
	RTS
;
;  SCROLL DOWN FROM LINE Y
;
;YVAL .BYTE 0

SCROLD
	PHA
	TXA
	PHA
	STY YVAL
	LDY #23
	LDX #24
LOOP8
	CPY YVAL: #$00
	BEQ BLANKD
	DEY
	DEX
	JSR MOVEYX
	JMP LOOP8
BLANKD
	JSR CLEARY
	PLA
	TAX
	PLA
	RTS
;
;  STORE CHAR AT X,Y IN BUFP
;
;VALGET .BYTE 0

GETCHR
	JSR CALCXY
	PHA
	TYA
	PHA
	TXA
	PHA
	AND #1
	TAX           ;x=1 odd, 0 even
	LDA #0        ;Zero the number
	STA VALGET    ;of bytes put.
LOOPG
	LDY #0        ;Used for indirect
	LDA (TEMP1),Y ;Get byte
	CPX #1        ;Odd half or even?
	BNE EVENG
	AND #$0F      ;Odd=mask even part
	JMP STORVAL
EVENG
	LSR @         ;Even=shift odd part
	LSR @
	LSR @
	LSR @
STORVAL
	LDY VALGET: #$00    ;Which byte?
	STA BUFP,Y
	CLC           ;Next byte=40 away
	LDA #40       ;So add 40 on
	ADC TEMP1
	STA TEMP1
	LDA #0        ;(with carry)
	ADC TEMP1+1
	STA TEMP1+1
	INY           ;Increment number
	STY VALGET    ;of bytes done
	CPY #8        ;8=finished
	BNE LOOPG
	PLA           ;Restore regs
	TAX
	PLA
	TAY
	PLA
	RTS
;
;  DELETE CHAR & MOVE LINE UP
;
DELETE
	PHA         ;Save X and A (Y is
	TXA         ;unchanged)
	PHA
LOOPDT
	CPX #79     ;End of line yet?
	BEQ EXITDT
	INX         ;Get the character
	JSR GETCHR  ;next up the line and
	DEX         ;move it one col left
	JSR STORE8
	INX         ;Then prepare for next
	JMP LOOPDT  ;char.
EXITDT
	LDA #32     ;Store SPACE at 79,y
	JSR PUTCHR
	PLA
	TAX
	PLA
	RTS
;
;  INSERT CHR. A AT X,Y
;
;XINS .BYTE 0

INSERT
	PHA	;Save A and X
	STX XINS
	CPX #79
	BEQ FININS
	LDX #79
LOOPIN
	DEX         ;Move each character
	JSR GETCHR  ;one character to the
	INX         ;right, then prepare
	JSR STORE8  ;for the next char
	DEX
	CPX XINS: #$00
	BNE LOOPIN
FININS
	PLA         ;Store character
	LDX XINS
	JSR PUTCHR
	RTS
;
; LOCATE CHAR AT X,Y INTO A
; AND CLEAR CARRY IF VALID
;
EVNBUF dta c'XXXXXXXX'
ODDBUF dta c'XXXXXXXX'
;ALLBLK .BYTE 0	;Totally blank?
INVFLG .BYTE 0	;Testing inverse?
;

LOCATE
	JSR GETCHR    ;Get the bit image
	TXA           ;Save X and Y
	PHA           ;on the stack (the
	TYA           ;accum is the char
	PHA           ;on return).
	LDX #0        ;Character number
	STX ALLBLK    ;also reset inverse
	STX INVFLG    ;and blank and Odd
	STX ODDFLG    ;flags.
	STX TEMP2+1   ;Get the TEMP regs
	LDA <CHSET    ;ready for indexing
	STA TEMP1     ;the character set.
	LDA >CHSET
	STA TEMP1+1
	LDA #8        ;Each character is
	STA TEMP2     ;8 bytes high.
	LDY #7        ;Transfer the bitmap
LOCLOOP
	LDA BUFP,Y    ;to ODDBUF, with the
	STA ODDBUF,Y  ;low nybble set, and
	ASL @         ;to EVNBUF, with the
	ASL @         ;high nybble set.
	ASL @         ;This avoids slow
	ASL @         ;shifts each time.
	STA EVNBUF,Y  ;Check also that the
	ORA ALLBLK: #$00    ;character is all
	STA ALLBLK    ;blanks (a space).
	DEY
	BPL LOCLOOP
	LDA ALLBLK    ;If it is all blanks
	BNE MNLOOP    ;then assume a
	LDA #32       ;space character.
	BNE XITOK
MNLOOP
	LDY #7
EACHCH
	LDA ODDFLG: #$00    ;If it is an odd
	BNE ODDLOC    ;character, compare
	LDA (TEMP1),Y ;the low order
	AND #$F0      ;nybbles, otherwise
	CMP EVNBUF,Y  ;the high nybbles.
	BNE NOTOK     ;If not the same,
	BEQ CMPOK     ;do the next char.
ODDLOC
	LDA (TEMP1),Y ;Do the same as
	AND #$F       ;above, for the odd
	CMP ODDBUF,Y  ;This separation
	BNE NOTOK     ;makes it quicker.
CMPOK
	DEY           ;Compared OK - check
	BPL EACHCH    ;next byte. If all
	TXA           ;OK, a=character.
XITOK
	STA ODDBUF    ;regs (storing A in
	PLA           ;a temporary locn.)
	TAY           ;and then reset the
	PLA           ;carry flag to
	TAX           ;indicate success.
	LDA ODDBUF
	CLC
	RTS
NOTOK
	INX           ;Failed to compare
	TXA           ;Try next character
	AND #1        ;and increase index.
	BNE NOADD     ;if necessary to get
	JSR ADD       ;next 2 chars. Set
NOADD
	STA ODDFLG    ;flags as nec.
	CPX #0        ;If done all chars
	BEQ FAILED    ;then not valid.
	CPX #$80      ;Otherwise if trying
	BNE MNLOOP    ;inverse then invert
	LDY #$7       ;the compare buffers
LOOPIV
	LDA ODDBUF,Y  ;so that can compare
	EOR #$F       ;each character with
	STA ODDBUF,Y  ;-out having to
	LDA EVNBUF,Y  ;invert each buffer
	EOR #$F0      ;every time.
	STA EVNBUF,Y
	DEY
	BPL LOOPIV
	LDA <CHSET     ;Get the indexes
	STA TEMP1      ;prepared again
	LDA >CHSET
	STA TEMP1+1
	SEC           ;Set INVFLG to $80
	ROR INVFLG
	BCC MNLOOP    ;(Unconditional)
FAILED
	PLA           ;Restore registers,
	TAY           ;it doesn't matter
	PLA           ;what A is since
	TAX           ;carry is set to
	SEC           ;indicate failure
	RTS
;
;  INVERT CHAR AT X,Y
;
INVERT
	JSR GETCHR    ;Get char to invert
	PHA           ;Save registers
	TYA
	PHA
	LDY #7        ;Invert 8 bytes
LOOPINV
	LDA BUFP,Y    ;Get each byte
	EOR #$F       ;invert it
	STA BUFP,Y
	DEY           ;Next byte
	BPL LOOPINV
	PLA           ;Restore regs
	TAY
	PLA
	JMP STORE8    ;Place char on scn.


; ***************************
; *        80: XIOS         *
; * ----------------------- *
; *   BY SIMON TREW, 1989.  *
; * ----------------------- *
; *                         *
; * These routines provide  *
; * all the special XIOS,   *
; * the OPEN, CLOSE and STA *
; * -TUS, and the Graphics  *
; * 8 checking. They handle *
; * all calls to the S: rom *
; * handler device.         *
; *                         *
; ***************************
;
;  ADDRESS AREAS IN 80BASICS
;
MODE	 .BYTE 0	;Open screen mode
TEXTFLAG .BYTE 0	;Text/Graphics
BUFLEN	 .BYTE 0	;Input buffer length
;
;  CIO NON-VARIABLES ROUTINE
;
OPEN
	LDA ICAX1,X   ;First save the OPEN
	JSR SETINP    ;mode, then attempt
	JSR OPEN8     ;to open the screen.
	LDY #1        ;Success!
;NOTOK
	RTS
;
;  CHECK MODE 8 IS BEING USING
;
CHECK8
	PHA
	TYA
	PHA
	LDA GRMODE    ;Make sure we're
	CMP #8        ;using mode 8
	BEQ OKMOD8    ;Otherwise attempt
OPEN8
	JSR GR8SET    ;to open.
	CPY #128
	BCC OPENOK    ;Can't open, do not
	PLA           ;return to parent,
	PLA           ;return to grand-
	PLA           ;parent instead.
	PLA           ;This avoids more
	RTS           ;checking by parent.
OPENOK
	LDA #79       ;If OK, set defaults
	STA RMARGN    ;The user can change
;	LDA #0        ;these on config so
;	STA FOREG     ;they each have a
;	LDA #12       ;separate LDA even
;	STA BACKG     ;though they may be
;	LDA #12       ;the same.
;	STA BORDER
	LDA #0        ;Set left margin
	STA COLCRS+1  ;(as graphics may
	STA BUFLEN    ;set it to 0) and
	STA TEXTFLAG  ;place in TEXT mode,
	LDA LMARGN    ;input mode 12.
	STA COLCRS
OKMOD8
	PLA           ;Then restore regs
	TAY           ;and return control
	PLA           ;to parent.
	RTS
;
;  GET STATUS OF TEXTFLAG
;
GETSTAT
	LDY TEXTFLAG  ;Status of TEXTFLAG
	STY $23       ;exactly as XIOd.
	RTS           ;and store in IOCB.
;
;  SPECIAL OPERATIONS
;
SPECIAL
	JSR CHECK8    ;Check using mode 8
	TXA           ;Store X for later
	PHA
	JSR DOSPEC    ;Do special oper.
	PLA           ;Get back X reg.
	TAX           ;and use to reset
	LDA MODE      ;Input Mode back to
	STA ICAX1,X   ;its last value, in
	STA $2A       ;ZIOCB also.
	RTS
DOSPEC
	LDA ICCOM,X   ;Standard OS drawto
	CMP #$11      ;or Fill command?
	BEQ DRAWLN
	CMP #$12
	BNE NOTDRW    ;No, skip over
;
;  GRAPHICS COMS (USE S: DEVICE)
;
;OLDLM .BYTE 0
;OLDRM .BYTE 0
;BPUT .BYTE 0
DRAWV = $E410

DRAWLN
	PHA
	LDA TEXTFLAG  ;Check OK screen
	BEQ BADMODE   ;(not textmode)
	LDA 83        ;Save margins as
	STA OLDRM     ;as the graphics
	LDA 82        ;routines may
	STA OLDLM     ;change them.
	LDA ICCOM,X   ;If doing a SPECIAL
	CMP #$11      ;then use the SPEC.
	BCS NOTPLT    ;vector. If doing
	AND #4        ;a GET then use the
	BNE GETCMD    ;GET vector else
	LDY #6        ;use the PUT vector.
	BNE SKIPPL    ;This is so that the
GETCMD
	LDY #4        ;PLOT and LOCATE
	BNE SKIPPL    ;graphics command
NOTPLT
	LDY #$A       ;handlers can use
SKIPPL
	CLC           ;this routine for
	LDA DRAWV,Y   ;their graphics,
	ADC #1        ;as well as the
	STA GODRAW+1  ;SPECIAL handler for
	LDA DRAWV+1,Y ;the DRAW and FILL.
	ADC #0
	STA GODRAW+2
	PLA

GODRAW	JSR $FFFF

	CPY #128      ;If an error occ-
	BCC NOTDER    ;urred then set the
	STY TEMP1     ;TEXT mode, to allow
	JSR SWAPTT    ;Basic etc. to print
	LDY TEMP1     ;the error.
NOTDER
	PHA
	LDA OLDRM: #$00	;Reset the margins
	STA RMARGN	;as they may have
	LDA OLDLM: #$00	;been changed by
	STA LMARGN	;the S: device.
	PLA
	RTS
BADMODE
	LDY #145      ;Bad screen mode
	PLA
	RTS
;
;  NOTE (GET CURSOR POSN)
;
NOTDRW
	CMP #$26      ;NOTE command?
	BNE NOTNOTE
	LDA ROWCRS    ;Put coords in the
	STA ICAX5,X   ;params of NOTE.
	LDA COLCRS    ;This avoids the
	STA ICAX3,X   ;need for PEEKS to
	LDA COLCRS+1  ;adresses which look
	STA ICAX4,X   ;cryptic and defy
	LDY #1        ;the point of CIO.
	RTS
;
;  MOVE LINE
;
NOTNOTE
	CMP #$27      ;MOVE LINE command?
	BNE NOTMOVE
	LDA TEXTFLAG  ;Check text mode is
	BNE BADMODE   ;not graphics
	LDY ICAX1,X   ;Load lines to move
	CPY #24       ;Out of range?
	BCS ERR141
	LDA ICAX2,X   ;have to use A and
	TAX           ;transfer since cant
	CPX #24       ;LDX indexed X !
	BCS ERR141
	JSR MOVEYX    ;Do Move Line
	LDY #1
	BNE POPREGS
ERR141
	LDY #141      ;Cursor out of range
POPREGS
	RTS
;
;  CLEAR LINE
;
NOTMOVE
	CMP #$28      ;Clear line ICAX1
	BNE NOTCLR
	LDA TEXTFLAG  ;Check text mode is
	BNE BADMODE   ;not graphics
	LDY ICAX1,X   ;Cursor out of
	CPY #24       ;range?
	BCS ERR141B
	JSR CLEARY    ;No, do CLEARY
	LDY #1
	RTS
ERR141B
	LDY #141      ;Cursor out of range
	RTS
;
;  SCROLL UP
;
NOTCLR
	CMP #$29
	BNE NOTSCRU
	LDA TEXTFLAG  ;Check text mode is
	BNE BADMODE   ;not graphics
	LDY ICAX1,X   ;is the line out of
	CPY #24       ;range?
	BCS ERR141B
	JSR SCROLU    ;No, do SCROLU
CLOSE
	LDY #1        ;This operation will
	RTS           ;do nice for CLOSE.
;
;  SCROLL DOWN
;
NOTSCRU
	CMP #$2A      ;Scroll down ICAX1?
	BNE CHGTEXT
	LDA TEXTFLAG  ;Check text mode is
	BNE BADMODE   ;not graphics
	LDY ICAX1,X   ;Cursor out of
	CPY #24       ;range?
	BCS ERR141B
	JSR SCROLD    ;No, do SCROLD
	LDY #1
	RTS
;
;  CHANGE VALUE IN TEXTFLAG
;
OLDROW .BYTE 0
OLDCOL .WORD 0

CHGTEXT
	CMP #$2B        ;Change value
	BNE NOTTEXT
SWAPTT
	LDA TEXTFLAG    ;Toggle Textflag
	EOR #1
	STA TEXTFLAG
	LDX #2
SWLOOP
	LDA ROWCRS,X    ;Switch the two
	LDY OLDROW,X    ;cursors, so that
	STY ROWCRS,X    ;switching between
	STA OLDROW,X    ;text and graphics
	DEX             ;does not require
	BPL SWLOOP      ;setting position.
	LDY #1
	RTS
;
;  INVERT 1 CHAR ON SCREEN
;
NOTTEXT	.LOCAL
	CMP #$2C      ;Invert?
	BNE NOTINV
	LDA TEXTFLAG  ;Check text mode is
	BEQ GOODMDE   ;not graphics
	JMP BADMODE
GOODMDE
	LDY ICAX2,X   ;Load char To invert
	CPY #24       ;Out of range?
	BCS ERR141D
	LDA ICAX1,X   ;have to use A and
	TAX           ;transfer since cant
	CPX #80       ;load X indexed X!
	BCS ERR141D
	JSR INVERT    ;Do Invert Char
	LDY #1
	RTS
ERR141D
	JMP ERR141
	.ENDL
;
;  CHANGE INPUT MODE
;
NOTINV
	CMP #$2D     ;Input change?
	BNE NOTIMPL  ;If so, set Y=1 now,
	LDY #1       ;as OPEN may call the
	LDA ICAX1,X  ;below routine when
SETINP
	CMP #12      ;Y<>1, an invalid
	BCC NOTOKI   ;Open. Check mode
	CMP #15      ;is either 12,13,14
	BCS NOTOKI   ;else set it to 12.
OKINP
	STA ICAX1,X  ;Store in IOCB and
	STA $2A      ;in ZIOCB locn, as
	STA MODE     ;well as MODE of
	RTS          ;course!
NOTOKI
	LDA #12      ;If out of range,
	JMP OKINP    ;set to 12.
;
;  NOT IMPLEMENTED
;
NOTIMPL
	LDY #146      ;Function not imple-
	RTS           ;mented.


; ***************************
; *         80: CIO         *
; * ----------------------- *
; *   BY SIMON TREW, 1989.  *
; * ----------------------- *
; *                         *
; * These routines handle   *
; * the CIO functions for   *
; * PUT and GET, the CIO    *
; * tables, reset processes *
; * and transient DOS code. *
; *                         *
; ***************************

NEWTAB
	.WORD OPEN-1    ;new table
	.WORD CLOSE-1
	.WORD GETBYTE-1
	.WORD PUTBYTE-1 ;The JMP below is
	.WORD GETSTAT-1 ;reserved by OS to
	.WORD SPECIAL-1 ;initialise but is
	JMP NOTED       ;currently unused
;
; PUT OR PLOT A BYTE
;
;SAVEX    .BYTE 0
ESCFLG   = $2A2
DSPFLG   = $2FE
;PLOTVEC  = $E416
;
PUTBYTE
	JSR CHECK8    ;Mode 8 on screen?
	LDY TEXTFLAG  ;Use text?
	BEQ TEXTPUT   ;Yes.
	PHA
	LDA #9        ;Make sure ICCOM is
	STA ICCOM,X   ;PUT command, in
	PLA           ;case of non-CIO put
	JMP DRAWLN    ;put (eg Basic put).
;
TEXTPUT
CTRL1
	LDY 17        ;Wait if Ctrl-1
	BEQ BREAK     ;pressed, and break
	LDY 767       ;not pressed.
	BNE CTRL1
	BEQ DOCHR
BREAK
	STY 767       ;Untoggle Ctrl-1.
	LDY #128      ;"Break" error.
	JMP EXITPUT
DOCHR
	STX SAVEX+1   ;Save X register
	LDX COLCRS+1  ;Check X coord
	BNE ERR141C   ;Out of range
	LDX COLCRS
	CPX #80       ;is nonzero or the
	BCS ERR141C   ;low byte >= 80
	LDY ROWCRS    ;Check Y coord is in
	CPY #24       ;the range 0..79
	BCS ERR141C
	PHA           ;Check ESCFLG and
	CMP #CR       ;DISPFLG (or Return
	BEQ SPEKEY    ;key regardless) for
	LDA ESCFLG    ;the "Special" cont-
	ORA DSPFLG    ;rol codes functions
	BEQ SPEKEY
	PLA
NOTSPEK
	JSR PUTCHR    ;Put the character
	INX           ;Move cursor &
	CPX RMARGN    ;scroll if nec.
	BEQ NOTCR
	BCC NOTCR
	LDX LMARGN    ;Have to wrap cursor
	INY
	CPY #24       ;Scroll screen?
	BNE NOTCR
	LDY #0
	JSR SCROLU
	LDY #23
NOTCR
	STX COLCRS    ;Save cursor posn.
	STY ROWCRS
	ASL ESCFLG    ;Set ESCFLG to 0
SUCCESS
	LDY 11        ;Success, If Break
EXITPUT
SAVEX	LDX #$00      ;Restore X register
	RTS
ERR141C
	JSR CSHOME    ;Home (cursor out of
	LDY #141      ;range so place in
NOTED
	RTS           ;range next time).
;
; CONTROL CODES PRINTING
;
SPEKEY
	PLA           ;Get code value
	CMP #27       ;Escape?
	BNE NOTESC
	LDA #$80
	STA ESCFLG
	JMP SUCCESS
NOTESC
	CMP #28       ;Cursor up?
	BNE NOTUP
	LDY ROWCRS    ;Get row
	DEY           ;Move cursor up
	BPL WRAPUP    ;Less than 0?
	LDY #23
WRAPUP
	STY ROWCRS
	JMP SUCCESS
NOTUP
	CMP #29       ;Down?
	BNE NOTDWN
	LDY ROWCRS
	INY           ;Move cursor down
	CPY #24       ;If more than 23
	BNE WRAPDN    ;then set it to 0
	LDY #0
WRAPDN
	STY ROWCRS    ;than 23
	JMP SUCCESS
NOTDWN
	CMP #30       ;Left?
	BNE NOTLFT
	LDY COLCRS
	DEY
	BMI PASTLT    ;Wrap cursor special
	CPY LMARGN    ;case if X=255 (-1)
	BCS WRAPLT    ;Wrap cursor around
PASTLT
	LDY RMARGN
WRAPLT
	STY COLCRS
	JMP SUCCESS
NOTLFT
	CMP #31       ;Right?
	BNE NOTRGT
	LDY COLCRS
	INY
	CPY RMARGN    ;Wrap cursor around
	BCC WRAPRT
	BEQ WRAPRT
	LDY LMARGN
WRAPRT
	STY COLCRS
	JMP SUCCESS
NOTRGT
	CMP #125      ;Clear screen?
	BNE NOTCLR2
	LDY #23       ;Clear every line
LOOPCLR
	JSR CLEARY    ;from 23 down to
	DEY           ;zero, then set up
	BPL LOOPCLR   ;the cursor.
CSHOME
	LDY #0
	STY ROWCRS
	STY COLCRS+1
	LDY LMARGN
	STY COLCRS
	JMP SUCCESS
NOTCLR2
	CMP #126      ;Backspace
	BNE NOTBSP
	LDY COLCRS    ;If column 0, then
	CPY LMARGN
	BEQ DONEBS    ;do nothing.
	TXA
	PHA
	LDA #SPACE    ;Move the cursor
	LDX COLCRS    ;back one space and
	DEX           ;then place a space
	STX COLCRS    ;in that position.
	LDY ROWCRS
	JSR PUTCHR
	PLA           ;Get X register back
	TAX
DONEBS
	JMP SUCCESS
NOTBSP
	CMP #127      ;Tab?
	BNE NOTTAB
	CLC
	LDA COLCRS    ;Shift maximum of
	ADC #10       ;10 characters over
	CMP RMARGN
	BCC TBEXIT
	LDA RMARGN    ;Have hit right mrgn
TBEXIT
	STA COLCRS
	JMP SUCCESS
NOTTAB
	CMP #CR
	BNE NOTRET
	LDA LMARGN    ;Set COLCRS to left
	STA COLCRS    ;margin
	LDY ROWCRS
	INY           ;bottom of screen?
	CPY #24
	BNE NOSCRL
	LDY #0        ;Yes, scroll up
	JSR SCROLU
	LDY #23
NOSCRL
	STY ROWCRS    ;Store new cursor Y
	ASL ESCFLG    ;Make ESCFLG=0
	JMP SUCCESS
NOTRET
	CMP #156      ;Shift-Delete?
	BNE NOTSDL
	LDY ROWCRS
	JSR SCROLU    ;scroll up.
SETMGN
	LDY LMARGN    ;Set column to left
	STY COLCRS    ;margin
	JMP SUCCESS
NOTSDL
	CMP #157      ;Shift-Insert?
	BNE NOTSIN
	LDY ROWCRS    ;insert a line
	JSR SCROLD    ;at Y and scroll dn.
	JMP SETMGN    ;Set cursor to left.
NOTSIN
	CMP #158      ;Control-Tab?
	BNE NOTCTB
	LDY LMARGN    ;Set cursor to left
	STY COLCRS    ;margin
	JMP SUCCESS
NOTCTB
	CMP #159      ;Shift-Tab?
	BNE NOTSTB
	SEC           ;Shift maximum of
	LDA COLCRS    ;10 characters over
	SBC #10
	BMI MARGSET   ;Make sure have not
	CMP LMARGN    ;gone past left
	BCS TBEXIT2   ;margin.
MARGSET
	LDA LMARGN    ;Have hit left marg.
TBEXIT2
	STA COLCRS
	JMP SUCCESS
NOTSTB
	CMP #253      ;Buzzer?
	BNE NOTBUZ
	JSR BUZZLN
	JMP SUCCESS
BUZZLN
	PHA           ;BUZZLN emulates the
	TYA           ;editor's buzzer
	PHA           ;routine which is
	TXA           ;at no fixed abode
	PHA           ;in the OS ROM. It
	LDY #$20      ;interferes with
BELL1
	JSR CLICK     ;the WSYNC timer.
	DEY           ;Note that the
	BPL BELL1     ;keyboard click is
	PLA           ;generated using
	TAX           ;just 1 cycle of
	PLA           ;this routine
	TAY           ;rather than 20.
	PLA
	RTS
;
WSYNC = $D40A
CONSOL = $D01F

CLICK
	LDX #$7F      ;This is the replica
CLICK1
	STX CONSOL    ;of the OS routine
	STX WSYNC     ;to click the key-
	DEX           ;board and, looping,
	BPL CLICK1    ;to sound the buzzer
	RTS
NOTBUZ
	CMP #254      ;Control-Delete?
	BNE NOTCDL
	TXA
	LDX COLCRS    ;Delete char at X,Y
	LDY ROWCRS
	JSR DELETE
	TAX
	JMP SUCCESS
NOTCDL
	CMP #255      ;Ctrl-Insert?
	BEQ CTRLIN    ;If not, process as
	JMP NOTSPEK   ;a normal key.
CTRLIN
	TXA
	PHA
	LDA #SPACE
	LDX COLCRS    ;Insert a space at
	LDY ROWCRS    ;X,Y
	JSR INSERT
	PLA
	TAX
	JMP SUCCESS
;
; GETBYTE ROUTINES
;
GETSAVX .BYTE 0
DSTAT  = $4C		;Keyboard Status
;GETVEC = $E414

GETBYTE
	JSR CHECK8    ;Mode 8 on screen?
	LDY TEXTFLAG  ;Use text?
	BEQ TEXTGET   ;Yes.
	JMP DRAWLN
TEXTGET
	LDA COLCRS+1  ;Check ranges of X
	BNE ERR141D   ;and Y and Return.
	LDA COLCRS
	CMP RMARGN
	BCC RMAROK
	BNE ERR141D
RMAROK
	LDA ROWCRS
	CMP #24
	BCS ERR141D
	LDA ICAX1,X  ;If using mode 14, or
	AND #2       ;getting more than
	ORA IOCB+9,X ;one byte, then do
	BNE RECALN   ;key input, else do
	LDA IOCB+8,X ;locate (get char.
	CMP #2       ;at cursor).
	BCS RECALN
;
; SINGLE BYTE: LOCATE
;
	STX GETSAVX
	LDX COLCRS   ;Get character at
	LDY ROWCRS   ;ROWCRS, COLCRS
	JSR LOCATE
	BCC VALID    ;Was character OK?
ERR144
	LDY #144     ;no, device done err
	BNE NVALID
VALID
	LDY #1       ;Character is valid
NVALID
	LDX GETSAVX
	RTS
ERR141D
	JSR CSHOME   ;Cursor was out of
	LDY #141     ;range, place in
	BNE NVALID   ;range for next time.
;
; MANY BYTES OR MODE 14: INPUT
;
;LASTCH .BYTE 0
;KEYGET .WORD 0
KEYVEC = $E424
;
RECALN
	LDA BUFLEN   ;Is buffer empty?
	BEQ NEWBUF   ;Yes, get new line.
	LDY LASTCH: #$00   ;Get next character
	LDA BUFFER,Y ;and decrement number
	DEC BUFLEN   ;left in buffer
	INC LASTCH   ;Next character.
	LDY #1       ;Success!
	RTS

;
;STARTX .BYTE 0	;Starting X and Y
;STARTY .BYTE 0	;coords (used for
		;margins, etc.)
NEWBUF
	STX GETSAVX  ;Store index to IOCB
	LDY #1       ;Reset DSTAT and
	STY DSTAT    ;Break Key flag
	STY $11      ;before keyboard inp
	LDA ROWCRS   ;Store starting
	STA STARTY   ;cursor position, so
	LDA COLCRS   ;we can read just
	STA STARTX   ;parts of lines.
	LDA ICAX1,X  ;Get input mode
	CMP #13      ;Return-key mode?
	BEQ LOOPGT

;	CLC          ;Get a character
;	LDA KEYVEC   ;from the keyboard
;	ADC #1       ;GETCH routine
;	STA GOKEY+1
;	LDA KEYVEC+1
;	ADC #0
;	STA GOKEY+2

	LDA ICAX1,X  ;Get 1 key without
	CMP #14      ;printing it, or if
	BEQ NOCURS   ;CSRINH is non-zero,
AGAIN
	LDA CSRINH   ;then don't print the
	BNE NOCURS   ;cursor.
	LDX COLCRS
	LDY ROWCRS   ;Otherwise do INVERT
	JSR INVERT   ;to turn cursor on.
NOCURS

GOKEY	JSR $FFFF    ;Keyboard Get Subr.

	CPY #$80     ;Is "error" < 128?
	BCC KEYOK    ;Yes, Key is OK
	JMP OOPS     ;otherwise return.
KEYOK
	LDY ICAX1,X  ;Just get 1 key?
	CPY #14      ;Yes, so get the
	BNE MOREKY   ;value and exit.
	RTS
MOREKY
	LDX COLCRS   ;(X and Y are changed
	LDY ROWCRS   ;by KEYGET subr.)
	PHA          ;Save the char. value
	LDA CSRINH   ;If we turned cursor
	BNE NOCRON   ;on, then we'd better
	JSR INVERT   ;turn cursor off.
NOCRON
	PLA          ;Get the char value
	CMP #CR      ;If it is Return,
	BEQ RETKEY   ;don't print it yet.
	JSR TEXTPUT  ;Put char on screen
	LDX COLCRS   ;Check cursor and
	CPX #72      ;buzz for Near-EOL if
	BNE NOBUZZ   ;necessary, regard-
	JSR BUZZLN   ;less of RMARGN
NOBUZZ
	JMP AGAIN    ;Get another key.
RETKEY
	LDY ROWCRS   ;Return pressed on
	CPY STARTY   ;the line we started
	BEQ LOOPGT   ;on? If not, start
	LDX LMARGN   ;INPUT at the left
	STX STARTX   ;margin, otherwise
	STY STARTY   ;at the start column.
LOOPGT
	LDX STARTX: #$00   ;Get each character
	CPX #RMARGN  ;making sure it is as
	BCC GETOK    ;within the margins
	BEQ GETOK    ;otherwise exit the
	JMP ENDGT    ;loop - all done.
GETOK
	LDY STARTY: #$00   ;use the LOCATE
	JSR LOCATE   ;80basic routine.
	BCS ENDGT    ;Stop if not char
	LDX BUFLEN   ;Store char in buf
	STA BUFFER,X ;And increment buf
	INC BUFLEN   ;length and next
	INC STARTX   ;character posn.
	JMP LOOPGT
ENDGT
	LDX BUFLEN	;Remove trailing
	BEQ ADDCR	;blanks from line
	LDA BUFFER-1,X	;by decreasing the
	CMP #SPACE	;buffer length by 1
	BNE ADDCR	;and trying again
	DEC BUFLEN
	BNE ENDGT
ADDCR
	LDA #CR      ;Store Return key
	LDX BUFLEN   ;into the end of the
	STA BUFFER,X ;buffer, incrementing
	INC BUFLEN   ;buffer length by 1.
	LDX #0       ;No chars got from
	STX LASTCH   ;buffer yet.
	JSR TEXTPUT  ;Print CR.
	LDX GETSAVX  ;Get back X register
	JMP RECALN   ;and get first char
;
; BREAK OR EOF: FORCE NEW LINE
;
OOPS
	LDA #0
	STA BUFLEN    ;Clear keyboard
	STA LASTCH    ;buffer
	STA 767       ;Clear CTRL-1
	TYA           ;Save the error ie
	PHA           ;128 or 136.
	LDX COLCRS    ;Unless the cursor
	LDY ROWCRS    ;is "off", or the
	LDA ICAX1,X   ;error occured doing
	AND #2        ;a single-byte GET
	ORA CSRINH    ;from the device,
	BNE NOTCSR    ;remove the cursor
	JSR INVERT    ;from the screen.
NOTCSR
	LDA #CR
	JSR TEXTPUT   ;Force new line
	LDA #0
	STA CSRINH    ;Set cursor on
	PLA           ;Get registers back
	TAY
	LDX GETSAVX
	RTS
;
; Devnam is the device name. This
; may be changed to any device.
;
DEVNAM	dta c'E:',CR
;
BUFFER	;.ds 81
;

CIOHND	.LOCAL

	.ifdef MAIN.@DEFINES.ROMOFF
		inc portb
	.endif

	TXA:PHA

	CLC          ;Get a character
	LDA KEYVEC   ;from the keyboard
	ADC #1       ;GETCH routine
	STA GOKEY+1
	LDA KEYVEC+1
	ADC #0
	STA GOKEY+2

	CLC          ;Get (address-1) of
	LDA GRAVEC   ;CIO's screen setting
	ADC #1       ;Up routine, and add
	STA GOCIO+1  ;1 to it for a JSR
	LDA GRAVEC+1 ;through the S: OPEN
	ADC #0       ;vector.
	STA GOCIO+2

	LDX #$0        ;vector first.
CIOLOOP
	LDA HATABS,X   ;Insert the device
	BEQ INS8       ;device at the end
	CMP DEVNAM     ;or at an entry
	BEQ INS8       ;with the same name
	INX            ;as this device
	INX
	INX
	JMP CIOLOOP
INS8
	LDA DEVNAM     ;driver name
	STA HATABS,X
	LDA <NEWTAB
	STA HATABS+1,X
	LDA >NEWTAB
	STA HATABS+2,X
	LDX #0          ;and re-open it
	LDA #$C         ;to the new E:.
	STA ICCOM,X
	JSR CIOV

	LDA <DEVNAM     ;Open E:
	STA IOCB+4,X
	LDA >DEVNAM
	STA IOCB+5,X
	LDA #12         ;Open for mode 12
	STA ICAX1,X
	STA ICAX2,X
	LDA #3          ;OPEN command
	STA ICCOM,X
	JSR CIOV

	PLA:TAX

	.ifdef MAIN.@DEFINES.ROMOFF
		dec portb
	.endif

	RTS
			; minimum 81 bytes -> BUFFER
	.ENDL
end;


initialization

 InitGraph(8+16);
 initE80;

end.
