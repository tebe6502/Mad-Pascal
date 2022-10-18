
;######################################################################################################################################
;
;
;	   ##	 ##   #	  ####	  ###		 #     # #####	 #     # ######
;	  #  #	 # #  #	 #    #	   #		 #     #  #   #	  #   #	  #   #
;	 #    #	 #  # #	 #	   #		 #     #  #   #	   # #	  # #
;	 #    #	 #   ##	  ####	   #	 ######	 #     #  ####	    #	  ###
;	 ######	 #    #	      #	   #		  #   #	  #   #	   # #	  # #
;	 #    #	 #    #	 #    #	   #		   # #	  #   #	  #   #	  #   #
;	 #    #	 #    #	  ####	  ###		    #	 #####	 #     # ######
;
;	 ####### ######	 #####	 ##   ##  ###	 ##   #	   ##	 ###
;	 #  #  #  #   #	  #   #	 # # # #   #	 # #  #	  #  #	  #
;	    #	  # #	  #   #	 #  #  #   #	 #  # #	 #    #	  #
;	    #	  ###	  ####	 #     #   #	 #   ##	 #    #	  #
;	    #	  # #	  # #	 #     #   #	 #    #	 ######	  #
;	    #	  #   #	  #  #	 #     #   #	 #    #	 #    #	  #   #
;	   ###	 ######	 ###  #	 #     #  ###	 #    #	 #    #	 ######
;
;	Written by: Joseph Zatarski, Tomasz Biela
;
;	terminal emulator that supports ANSI/ECMA-48 control sequences and a 256 character font
;
;	https://en.wikipedia.org/wiki/ANSI_escape_code
;
;	https://forums.atariage.com/topic/225063-full-color-ansi-vbxe-terminal-in-the-works/
;
;######################################################################################################################################
;
; TODO:	add recieve buffer so that I don't call CIOV to do one character at a time. (done)
;	label scroll contains some unnecesary math (refer to comments near it) (done)
;	add stuff beyond just the C0 (ASCII) and C1 control character/sequence sets (this means finally starting on the cool stuff)
;		SGR - set graphics rendition (color, high intensity, etc.) - done unless I want to improve support for 'default colors'
;		add J code - ED - erase in page
;		add A code
;		add C code
;		add D code
;
		icl	'atarios.equ'		; atari OS equates,
		icl	'atarihardware.equ'	; general atari hardware equates,
		icl	'VBXE.equ'		; and VBXE equates

;###################################################################################################################

; Display Handler Equates (among others)

row_slide_out	= @buf

cursor_address	= oldadr			; points to the address where the text cursor points

row		= rowcrs			; cursor row
column		= colcrs			; cursor column

temp_char	= atachr			; holds a character temporarily for the recieve processing routines
text_color	= fildat			; current text color to be put on the screen.


;###################################################################################################################

start		txa:pha

		lda	#$80
		ldy	#memac_bank_sel
		sta	(fxptr),y

; load the xdl and blitter lists

		lda	#<xdl			; setup source pointer
		sta	mem_move.src_ptr
		lda	#>xdl
		sta	mem_move.src_ptr+1

		lda	#<(vbxe_mem_base+$0800)	; destination pointer
		sta	mem_move.dst_ptr
		lda	#>(vbxe_mem_base+$0800)
		sta	mem_move.dst_ptr+1

		lda	#<(bcb_end - xdl - 1)	; and byte count - 1
		sta	counter
		lda	#>(bcb_end - xdl)
		sta	counter+1

		jsr	mem_move

; load the xdl address

		lda	#$00
		ldy	#xdl_adr
		sta	(fxptr),y
		iny
		iny
		sta	(fxptr),y
		dey
		lda	#$08
		sta	(fxptr),y

; enable xdl and disable transparent colors

		lda	#$05
		ldy	#video_control
		sta	(fxptr),y

; set the memac window to the display ram (the top of VBXE memory)

		lda	#$FF
		ldy	#memac_bank_sel
		sta	(fxptr),y

; done initializing the VBXE
;###################################################################################################################
; now we start initializing the variables for the terminal state
; initialize the cursor address to be at the home position

		lda	#<vbxe_screen_top
		sta	cursor_address
		lda	#>vbxe_screen_top
		sta	cursor_address + 1

; initialize the text color

		lda	#$87			; $87 is white on black
		sta	text_color

; initialize the cursor position
		lda	#$00
		sta	row
		sta	column

; the flags for escape and CSI
		sta	ctrl_seq_flg

; the flag for the cursor
		sta	cursor_flg		; cursor is not on yet.

; turn the cursor on
; normally, the screen windows starts in a state of all 0.
; that is fine for the characters
; but for the colors, this means the overlay bit is not set
; so all the colors are transparent and the cursor doesn't show up right
; so we clear the page first, which fills the page with null and the default color

		jsr	scroll_page
		jsr	cursor_on

		lda	#0
		ldy	#memac_bank_sel
		sta	(fxptr),y
		
		pla:tax
		
		rts

/*
lp		lda ans_adr: data
		sta temp_char


		jsr 	process_char		; process the character


		inw ans_adr

		cpw ans_adr #data_end
		bne lp

;		jsr scroll_1d



		lda	#0
		ldy	#memac_bank_sel
		sta	(fxptr),y

		jmp *
*/

process_char	.local
		bit	ctrl_seq_flg
		bvs	is_ctrl_seq		; if overflow set, it's a control sequence
		bpl	not_C1			; if escape flag not set, it's not a C1 character
		lda	#0			; if it is, we clear the escape flag for the next character.
		sta	ctrl_seq_flg
		lda	temp_char
		and	#%11100000		; AND mask for C1 set
		cmp	#$40			; if it's $40 after ANDing,
		beq	is_C1			; it's part of the C1 set
		rts				; otherwise, it's some other character preceded by escape, which we do nothing with (don't even print it)

is_ctrl_seq	.local
		lda	temp_char
		cmp	#$20
		bcc	bad_ctrl_seq		; control sequence is bad if character isn't greater than or equal to #$20
		cmp	#$7F			; control sequence is bad if character is greater than or equal to #$7F
		bcs	bad_ctrl_seq		; this is all in the ECMA 48 spec.
		ldx	ctrl_seq_index		; get index
		sta	ctrl_seq_buf,x		; store byte in the buffer
		inx
		stx	ctrl_seq_index
		cmp	#$40			; if control sequence byte is greater than or equal to #$40, then it's the final byte.
		bcs	is_final_byte
		rts

bad_ctrl_seq	lda	#0
		sta	ctrl_seq_flg
		rts

is_final_byte	sta	final_byte
		lda	#0
		sta	ctrl_seq_flg
		jmp	do_ctrl_seq
		.endl


not_C1		lda	temp_char
		cmp	#32
		bcc	is_C0			; if the character is less than 32, it's a part of the C0 control set

		jmp	put_byte		; if it's not part of the C0 set, just print it.


is_C0		asl				; multiply by two to get an offset into the C0 handler table
		tax				; transfer to X to be used as an index
		lda	C0_handler_table, x	; transfer the address of the proper handler
		sta	jump_C0 + 1
		lda	C0_handler_table + 1, x
		sta	jump_C0 + 2
jump_C0		jmp	$0000			; into the operand of this JSR

is_C1
		lda	temp_char
		asl
		tax
		lda	C1_handler_table-$80,x	; transfer the address of the proper handler
		sta	jump_C1 + 1
		lda	C1_handler_table-$7F,x
		sta	jump_C1 + 2
jump_C1		jmp	$0000
		.endl

do_ctrl_seq	.local
		ldx	ctrl_seq_index
		dex
		dex
		lda	ctrl_seq_buf,x
		cmp	#$30
		bcs	no_inter_byte		; if this byte is less than #$30, it's an intermediate byte.
		sta	inter_byte
		jmp	find_entry
no_inter_byte	lda	#0
		sta	inter_byte

find_entry	ldx	#0
next_entry	lda	ctrl_seq_table,x	; get final byte from table
		beq	last_entry		; if the last entry is reached, jump
		cmp	final_byte		; compare to actual final byte
		bne	wrong_f_byte		; jump if they don't match
		inx
		lda	ctrl_seq_table,x	; get intermediate byte
		cmp	inter_byte		; compare to actual intermediate byte
		bne	wrong_i_byte		; jump if they don't match
		inx				; point at low address of handler
		lda	ctrl_seq_table,x
		sta	ctrl_seq_jmp+1
		lda	ctrl_seq_table+1,x
		sta	ctrl_seq_jmp+2		; set up the jump

ctrl_seq_jmp	jmp	$0000			; jump to control sequence handler (the address here will be changed)

wrong_f_byte	inx				; points to intermediate byte after this
wrong_i_byte	inx				; points to low address byte after this
		inx				; points to high address byte after this
		inx				; points to next final byte after this
		jmp	next_entry

last_entry	rts				; if we searched the whole list and didn't find it, do nothing.
		.endl


put_byte	.local				; put the byte on the screen
		jsr	cursor_off
		ldx	#$00

		lda	temp_char
		sta	(cursor_address, x)

		inc	cursor_address

		lda	text_color		; get the current text color
		sta	(cursor_address, x)

		inc	cursor_address
		bne	no_carry		; if the increment resulted in 0, then we rolled over and need to carry
		inc	cursor_address + 1	; carry means high address needs to be incremented

no_carry	inc	column			; move the cursor forward
		lda	#79
		cmp	column
		bcs	no_new_line		; if 79 >= col, no new line is needed
		lda	row
		cmp	#23			; if row is 23, then we need to scroll a line
		beq	scroll
		inc	row			; otherwise (when col > 79) go to the next line
		lda	#00
		sta	column			; set column back to 0
no_new_line	jmp	cursor_on

scroll		lda	#<(vbxe_mem_base + $1000 - 160)
		sta	cursor_address
		lda	#>(vbxe_mem_base + $1000 - 160)
		sta	cursor_address + 1
		/*
		lda	cursor_address		; what do I do this for? this is really unnecesary, all this math
		sec				; I know that the only time I jump here is when I am pointing off the bottom of the
		sbc	#160			; screen, just past the end of the VBXE window. so this math always results in the same
		sta	cursor_address		; thing.
		bcs	no_carry_1		; if carry clear (borrow)
		dec	cursor_address+1	; decrement the high byte
		*/
no_carry_1	lda	#0			; otherwise, don't
		sta	column			; set column to 0. row stays 23
		jsr	scroll_1d		; run the blitter routine to scroll one line down.
		jmp	cursor_on
		.endl

;###################################################################################################################
; control sequence handlers
SOH_adr						; Start of Header prints a character
STX_adr						; Start of Text prints a character
ETX_adr						; End of Text prints a character
EOT_adr						; End of Transmission prints a character
ACK_adr						; Acknowledge prints a character
SO_adr						; Shift Out prints a character
SI_adr						; Shift In prints a character
DLE_adr						; Data Link Escape prints a character
DC1_adr						; Device Control 1-4 print a character
DC2_adr
DC3_adr
DC4_adr
NAK_adr						; Non-Acknowledge prints a character
SYN_adr						; Synchronous Idle prints a character
ETB_adr						; End of Transmission Block prints a character
CAN_adr						; Cancel prints a character
EM_adr						; End of Medium prints a character
SUB_adr						; Substitute prints a character
IS1_adr						; Information Separator 1-4 print characters
IS2_adr
IS3_adr
IS4_adr
		jmp 	put_byte		; the put_byte routine will return for us
ESC_adr						; Escape sets the escape flag
		lda	#$80
		sta	ctrl_seq_flg
		rts
CSI_adr						; Control Sequence Introducer sets the CSI flag which causes interpretation of a control sequence to begin
		lda	#0
		sta	ctrl_seq_index
		lda	#$40
		sta	ctrl_seq_flg
		rts
VT_adr						; Vertical Tab. for now, same as LF
IND_adr						; Index is same as LF
LF_adr		.local				; Line Feed moves the cursor down one line BUT only if we're not on the last line
						; down one line is forward 80 columns, or 160 bytes
		jsr	cursor_off
		lda	row
		cmp	#23			; if row is at 24,
		beq	scroll			; we scroll
		lda	#160			; otherwise, we add 160.
		clc				; clear the carry in prep for the addition.
		adc	cursor_address		; add 160 to the low part of the cursor address.
		sta	cursor_address
		bcc	no_carry		; if there's a carry,
		inc	cursor_address + 1	; increment the high half of the address.
no_carry	inc	row			; Line Feed increments row
		jmp	cursor_on
scroll		jsr	scroll_1d		; scroll one line down. we don't need to touch the cursor address, the row, or column.
		jmp	cursor_on
		.endl

CR_adr		.local				; Carriage Return puts the cursor at the home position of the current line
                                                ; (AKA, cursor gets column number * 2 bytes/char subtracted from it)
		jsr	cursor_off
		lda	cursor_address		; get cursor
		sec				; set carry for subtraction
		sbc	column			; do the subtraction
		bcs	no_borrow1		; carry will be clear if no borrow
		dec	cursor_address + 1	; otherwise it borrowed, so decrement cursor_address high byte
no_borrow1	sec				; prepare for another subtraction
		sbc	column			; do it
		bcs	no_borrow2		; borrow thing again...
		dec	cursor_address + 1
no_borrow2	sta	cursor_address		; store the result
		lda 	#00
		sta	column			; set column to 0
		jmp	cursor_on
		.endl

BEL_adr		.local				; Bell is supposed to play a tone, flash the screen, something.
						; this routine is copied out of the atari OS. it is what Atari used to do a bell character.
						; it's slightly modified. the original routine called the keyclick routine 32 (#$20) times.
						; I use a nested loop.
						; perhaps later, I will separate the keyclick routine for my own purposes.
		ldy	#$20
repeat		ldx	#$7E
spk		stx	CONSOL
		lda	VCOUNT
wait		cmp	VCOUNT
		beq	wait
		dex
		dex
		bpl	spk
		dey
		bpl	repeat
		rts
		.endl

FF_adr						; Form Feed clears the screen and sets cursor to the home position.
		jsr	cursor_off
		lda	#0			; home the cursor
		sta	row
		sta	column
		lda	#<vbxe_screen_top
		sta	cursor_address
		lda	#>vbxe_screen_top
		sta	cursor_address + 1
		jsr	scroll_page		; clear the screen
		jmp	cursor_on

BS_adr		.local				; Back Space moves the cursor left by one character (2 bytes).
		jsr	cursor_off
		lda	column
		bne	not_left		; if we're not at the left side yet, keep going
		rts				; but if we ARE at the left side, do nothing
not_left	dec	column			; if column isn't 0, we just decrement it
		lda	cursor_address
		bne	no_borrow		; if the cursor address low half isn't 0, we don't borrow
		dec	cursor_address + 1	; otherwise, borrow
no_borrow	dec	cursor_address		; if it weren't for the fact that cursor_address should always be even,
		dec 	cursor_address		; we would have to look for a borrow here too.
		jmp	cursor_on
		.endl
NUL_adr						; null does nothing
ENQ_adr						; Enquiry is probably supposed to return an ACK, but for now, it does nothing
HT_adr						; Horizontal Tab normally causes the cursor to move to the next tab stop. for now, nothing
HTS_adr						; no tab stuff just yet
HTJ_adr
VTS_adr
BPH_adr						; BPH doesn't apply in this case.
NBH_adr						; nor do any of the following
SSA_adr
ESA_adr
PLD_adr
PLU_adr
RI_adr
SS2_adr
SS3_adr
DCS_adr
PU1_adr
PU2_adr
STS_adr
CCH_adr
MW_adr
SPA_adr
EPA_adr
SOS_adr
SCI_adr
ST_adr
OSC_adr
PM_adr
APC_adr

		rts
NEL_adr						; Next Line is combination of CR and LF
		jsr	CR_adr
		jmp	LF_adr


;###################################################################################################################

.local	get_param

		lda	#0
		sta	param_idx+1

		ldx	#$FF
next_parm	lda	#0
		sta	parameter_val		; zero parameter value, this is the default value for this control sequence also
next_byte	inx				; increment index
		lda	ctrl_seq_buf,x		; get byte of control sequence
		tay				; save original value
		and	#$F0
		cmp	#$30			; if it's #$3x, then it's a parameter value
		bne	is_last_parm		; otherwise, it has to be the final byte.
		tya				; get value back
		cmp	#$3A
		bcc	add_digit		; if it's less than #$3A, then append the digit to parameter_val
		beq	next_byte		; if it's #$3A, then ignore it
		cmp	#$3B
		beq	parse_parm		; if it's #$3B, then it's the end of a parameter substring
		jmp	next_byte		; otherwise, at this point, it must be a bad value (#$3C through #$3F)

add_digit	and	#$0F			; we just want the last 4 bits
		tay				; save this
		lda	parameter_val		; append the digit to parameter_val

		ASL @		;multiply by 2
		STA TEMP+1	;temp store in TEMP
		ASL @		;again multiply by 2 (*4)
		ASL @		;again multiply by 2 (*8)
		CLC
TEMP		ADC #0		;as result, A = x*8 + x*2

		sta	parameter_val
		tya
		add	parameter_val
		sta	parameter_val
		jmp	next_byte

parse_parm
		jsr	is_last_parm
		jmp	next_parm

is_last_parm

param_idx	ldy	#0
		cpy	#3
		bcs	_rts

		lda	parameter_val

		sta	parameters,y

		inc	param_idx+1

_rts		rts

.endl


;###################################################################################################################

ED_adr		.local				; Erase in Display

		lda ctrl_seq_buf

		cmp #'2'			; clear entire screen (and moves cursor to upper left corner)
		beq clr

		rts

clr		jmp scroll_page

		.endl

;###################################################################################################################

SCP_adr		.local				; Save Current Cursor Position

		lda row
		sta oldrow

		lda column
		sta oldcol

		rts

		.endl

;###################################################################################################################

RCP_adr		.local				; Restore Saved Cursor Position

		lda oldrow
		sta row

		lda oldcol
		sta column

		jmp cursor_set

		.endl

;###################################################################################################################

CUF_adr		.local				; Cursor Forward

		jsr get_param

		lda parameters
		sne
		lda #1

		add column
		sta column

		jmp cursor_set

		.endl

;###################################################################################################################

CUU_adr		.local				; Cursor Up

		jsr get_param
		
		lda parameters
		sne
		lda #1
		sta parameters

		lda row
		beq skp

		sub parameters
		sta row

skp		jmp cursor_set

		.endl

;###################################################################################################################

CUB_adr		.local				; Cursor Back

		jsr get_param
		
		lda parameters
		sne
		lda #1
		sta parameters
		
		lda column
		beq skp

		sub parameters
		sta column

skp		jmp cursor_set

		.endl

;###################################################################################################################

CUD_adr		.local				; Cursor Down

		jsr get_param

		lda parameters
		sne
		lda #1
		sta parameters
		
		lda row
		cmp #23
		bcs skp
		
		add parameters
		sta row

skp		jmp cursor_set

		.endl

;###################################################################################################################

CUP_adr		.local				; Cursor Position
						; Moves the cursor to row n, column m. The values are 1-based, and default to 1 (top left corner) if omitted		
		jsr get_param

		lda parameters+1
		sub #1
		sta column

		lda parameters
		sub #1
		sta row

		jmp cursor_set

		.endl


cursor_set	.local

		jsr cursor_off
		
		lda row
srow		cmp #24
		bcc ok
		
		sub #24
		jmp srow

ok		sta row
		tay

		lda column
		asl @
		
		add lmul,y
		sta cursor_address

		lda #0
		adc hmul,y
		sta cursor_address+1

		jmp cursor_on
		
lmul		:24 dta l(vbxe_screen_top+#*160)
hmul		:24 dta h(vbxe_screen_top+#*160)

		.endl

;###################################################################################################################

SGR_adr		.local				; set graphics rendition control sequence
		ldx	#$FF
next_parm	lda	#0
		sta	parameter_val		; zero parameter value, this is the default value for this control sequence also
next_byte	inx				; increment index
		lda	ctrl_seq_buf,x		; get byte of control sequence
		tay				; save original value
		and	#$F0
		cmp	#$30			; if it's #$3x, then it's a parameter value
		bne	is_last_parm		; otherwise, it has to be the final byte.
		tya				; get value back
		cmp	#$3A
		bcc	add_digit		; if it's less than #$3A, then append the digit to parameter_val
		beq	next_byte		; if it's #$3A, then ignore it
		cmp	#$3B
		beq	parse_parm		; if it's #$3B, then it's the end of a parameter substring
		jmp	next_byte		; otherwise, at this point, it must be a bad value (#$3C through #$3F)

add_digit	and	#$0F			; we just want the last 4 bits
		tay				; save this
		lda	parameter_val		; append the digit to parameter_val
		asl
		asl
		asl
		asl
		sta	parameter_val
		tya
		ora	parameter_val
		sta	parameter_val
		jmp	next_byte

parse_parm
		jsr	is_last_parm
		jmp	next_parm

is_last_parm	.local
		lda	parameter_val
		and	#$F0
		beq	simple_attrib		; if it's zero, it's a simple attribute (bold, inverse, etc.)
		cmp	#$30
		beq	forecolor_attr		; foreground (text) color change
		cmp	#$40
		beq	backcolor_attr		; background color change
		rts				; otherwise it's not supported

simple_attrib	.local
		lda	parameter_val
		and	#$0F
		beq	default
		cmp	#$1
		beq	bold
		cmp	#$2
		beq	unbold
		cmp	#$7
		beq	inverse
		rts

default		lda	#$87
		sta	text_color
		rts

bold		lda	text_color
		ora	#%00001000
		sta	text_color
		rts

unbold		lda	text_color
		and	#%11110111
		sta	text_color
		rts

inverse		lda	text_color
		eor	#%01110111
		sta	text_color
		rts
		.endl

forecolor_attr	.local
		lda	parameter_val
		cmp	#$38
		bcs	ignore
		and	#$0F
		sta	parameter_val
		lda	text_color
		and	#$F8
		ora	parameter_val
		sta	text_color
ignore		rts
		.endl

backcolor_attr	.local
		lda	parameter_val
		cmp	#$48
		bcs	ignore
		and	#$0F
		asl
		asl
		asl
		asl
		sta	parameter_val
		lda	text_color
		and	#$8F
		ora	parameter_val
		sta	text_color
ignore		rts
		.endl

		.endl

		.endl

mem_move	.local				; memory move routine.
; copies number of bytes in counter + 1 from address in src_ptr to address in dst_ptr

		ldy	#0			; we don't want an offset actually, but the 6502 uses one anyway
loop		lda	src_ptr: $1000,y	; move a byte
		sta	dst_ptr: $1000,y

		inw	src_ptr			; increment the pointer
		inw	dst_ptr			; increment the other pointer

		lda	counter			; check to see if count is 0
		bne	no_borrow		; if it's not, we don't borrow
		lda	counter+1		; check to see if count's high byte is 0 also
		beq	done			; in which case we're done
		dec	counter+1		; but if we're not, we borrow
no_borrow	dec	counter
		jmp	loop
done		rts
		.endl

scroll_1d	.local				; scroll one down routine.

; copy row #0 to buffer

		lda row_slide_status
		bne skip

		ldy #79
cpRow		lda vbxe_screen_top,y
		sta row_slide_out,y
		lda vbxe_screen_top+80,y
		sta row_slide_out+80,y
		dey
		bpl cpRow

skip

; uses the blitter to move everything up just one line.

		ldy	#memac_bank_sel		; get the old bank number (should be the last bank, but we can't assume)
		lda	(fxptr),y
		pha

		lda	#$80			; bank 0, so we can put the color byte as the fill byte
		sta	(fxptr),y

		lda	text_color		; put the color in the fill pattern location.
		sta	scroll_1d_color-xdl+$0800+vbxe_mem_base

		lda	#<(bcb_one_down - xdl + $800)
		ldy	#blt_adr
		sta	(fxptr),y
		lda	#>(bcb_one_down - xdl + $800)
		iny
		sta	(fxptr),y
		lda	#^(bcb_one_down - xdl + $800)
		iny
		sta	(fxptr),y

		lda	#1
		
		sta	row_slide_status
		
		ldy	#blt_start
		sta	(fxptr),y

loop		lda	(fxptr),y
		bne	loop

		pla
		ldy	#memac_bank_sel
		sta	(fxptr),y
		rts
		.endl

scroll_page	.local				; scroll one page
; used for FF and also to initialize the screen so the color is not all $00

		ldy	#memac_bank_sel		; get the old bank number (should be the last bank, but we can't assume)
		lda	(fxptr),y
		pha

		lda	#$80			; bank 0, so we can put the color byte as the fill byte
		sta	(fxptr),y

		lda	text_color		; put the color in the fill pattern location.
		sta	clr_scr_color-xdl+$0800+vbxe_mem_base

		lda	#<(bcb_clr_scr - xdl + $800)
		ldy	#blt_adr
		sta	(fxptr),y
		lda	#>(bcb_clr_scr - xdl + $800)
		iny
		sta	(fxptr),y
		lda	#^(bcb_clr_scr - xdl + $800)
		iny
		sta	(fxptr),y

		lda	#1
		ldy	#blt_start
		sta	(fxptr),y

loop		lda	(fxptr),y
		bne	loop

		pla
		ldy	#memac_bank_sel
		sta	(fxptr),y
		rts
		.endl

cursor_on	.local				; turn on the cursor
; but ONLY if the cursor isn't already on
		bit	cursor_flg
		bpl	cursor_toggle
skip		rts
		.endl

cursor_off	.local				; turn off the cursor
; but ONLY if the cursor isn't already off
		bit	cursor_flg
		bmi	cursor_toggle
skip		rts
		.endl

cursor_toggle					; inverts the color of the current character to show the cursor
		ldy	#1
		lda	(cursor_address),y
		eor	#$77			; invert the color, but not bit 7 (transparency bit) or bit 3 (foreground intensity)
		sta	(cursor_address),y
		lda	cursor_flg
		eor	#$80			; flip the cursor flag
		sta	cursor_flg
		rts


;###################################################################################################################

xdl		; start of xdl

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

; displays 24 scanlines of no overlay (ANTIC display list should be displaying blank
; lines of GTIA background color)

		.byte	%00110100		; OVOFF, MAPOFF, RPTL - overlay off, color map off, repeat scanlines
		.byte	%00001000		; ATT - display size and overlay priority
		.byte	24-1			; 24 scanlines
		.byte	%00010001		; pallette #1, ANTIC normal mode
		.byte	%11111111		; overlay is priority over everything

; now on to the 80x24 text portion

		.byte	%01100001		; RPTL, OVADR
		.byte	%10001001		; CHBASE, OVATT, XDL_END
		.byte	192-1			; 192 scanlines of text (24 rows)

; overlay address starts at top of memory - 3840. this means the last line is at the top of memory
;8
		.long	VBXE_ANSIADR		; overlay address starts at the top of VBXE memory - bytes per screen
		.word	80 + 80			; each line of text is 80 characters and 80 colors (80 + 80 bytes)
		.byte	$00			; font is at the beginning of memory (far from text window)

		.byte	%00010001		; pallette #1, ANTIC normal mode
		.byte	%11111111		; overlay is priority over everything

xdl_end

bcb_start	; start of blitter lists

bcb_one_down	; blitter to scroll one line down
		.long	$07B5A0			; top of VBXE ram is $80000. this address is 5 pages back, plus one line. (src)
                .word	80*2			; one line is 160 bytes wide, and we're working our way down, so positive
                .byte	1			; x step is 1 (we want forwards and to not skip stuff)
                .long	$07B500			; top of VBXE ram is $80000. this address is 5 pages back. (dst)
                .word	80*2			; x and y step is the same as the source ones
                .byte	1
                .word	[80*2]-1		; width same as y step less one
		.byte	[5*24]-2		; 5 pages less one line, then minus one because that's what the doc says
		.byte	$FF			; AND mask. don't modify the data
		.byte	$00			; XOR mask. don't modify the data
		.byte	$00			; no collisions
		.byte	$00			; 1:1 zoom
		.byte	$00			; no pattern
		.byte	%00001000		; NOT last entry, copy mode

		.long	0			; doesn't matter
		.word	0			; doesn't matter
		.byte	0			; doesn't matter
		.long	$7FF60			; one line before the end of the screen
		.word	80*2			; y step really doesn't matter, since we're only doing one line, but it's 80 characters
		.byte	2			; x step is 2, we only want the character bytes, not color (for now)
		.word	80-1			; width is 80 bytes
		.byte	1-1			; just the last line
		.byte	0			; filling with a pattern
		.byte	0			; fill value is 0
		.byte	0			; no collisions
		.byte	0			; 1:1 zoom
		.byte	0			; no pattern
		.byte	%00001000	        ; NOT last entry, copy mode.

		.long	0			; doesn't matter
		.word	0			; doesn't matter
		.byte	0			; doesn't matter
		.long	$7FF61			; one line before the end of the screen, and one more so we fill the color bytes.
		.word	80*2			; y step really doesn't matter, since we're only doing one line, but it's 80 characters
		.byte	2			; x step is 2, we only want the color bytes, not character
		.word	80-1			; width is 80 bytes
		.byte	1-1			; just the last line
		.byte	0			; filling with a pattern
scroll_1d_color	.byte	0			; fill value will be changed by whatever uses this blitter list
		.byte	0			; no collisions
		.byte	0			; 1:1 zoom
		.byte	0			; no pattern
		.byte	0			; last entry, copy mode.

bcb_clr_scr	; blitter to scroll a whole page up
		.long	$07C400			; top of VBXE ram is $80000. this address is 4 pages back. (src)
                .word	80*2			; one line is 160 bytes wide, and we're working our way down, so positive
                .byte	1			; x step is 1 (we want forwards and to not skip stuff)
                .long	$07B500			; top of VBXE ram is $80000. this address is 5 pages back. (dst)
                .word	80*2			; x and y step is the same as the source ones
                .byte	1
                .word	[80*2]-1		; width same as y step less one
		.byte	[4*24]-1		; number of lines to move less one
		.byte	$FF			; AND mask. don't modify the data
		.byte	$00			; XOR mask. don't modify the data
		.byte	$00			; no collisions
		.byte	$00			; 1:1 zoom
		.byte	$00			; no pattern
		.byte	%00001000		; NOT last entry, copy mode

		.long	0			; doesn't matter
		.word	0			; doesn't matter
		.byte	0			; doesn't matter
		.long	$7F100			; one page before the end of the screen
		.word	80*2			; y step is 80 characters
		.byte	2			; x step is 2, we only want the character bytes, not color
		.word	80-1			; width is 80 bytes
		.byte	24-1			; 24 lines
		.byte	0			; filling with a pattern
		.byte	0			; fill value is 0
		.byte	0			; no collisions
		.byte	0			; 1:1 zoom
		.byte	0			; no pattern
		.byte	%00001000		; NOT last entry, copy mode.

		.long	0			; doesn't matter
		.word	0			; doesn't matter
		.byte	0			; doesn't matter
		.long	$7F101			; one page before the end of the screen, and one more so we fill the color bytes.
		.word	80*2			; y step really doesn't matter, since we're only doing one line, but it's 80 characters
		.byte	2			; x step is 2, we only want the color bytes, not characters
		.word	80-1			; width is 80 bytes
		.byte	24-1			; 24 lines
		.byte	0			; filling with a pattern
clr_scr_color	.byte	0			; fill value will be changed by whatever uses this blitter list
		.byte	0			; no collisions
		.byte	0			; 1:1 zoom
		.byte	0			; no pattern
		.byte	0			; last entry, copy mode.

bcb_end

;###################################################################################################################
; table of addresses for control function handlers
C0_handler_table
		.word	NUL_adr
		.word	SOH_adr
		.word	STX_adr
		.word	ETX_adr
		.word	EOT_adr
		.word	ENQ_adr
		.word	ACK_adr
		.word	BEL_adr
		.word	BS_adr
		.word	HT_adr
		.word	LF_adr
		.word	VT_adr
		.word	FF_adr
		.word	CR_adr
		.word	SO_adr
		.word	SI_adr
		.word	DLE_adr
		.word	DC1_adr
		.word	DC2_adr
		.word	DC3_adr
		.word	DC4_adr
		.word	NAK_adr
		.word	SYN_adr
		.word	ETB_adr
		.word	CAN_adr
		.word	EM_adr
		.word	SUB_adr
		.word	ESC_adr
		.word	IS4_adr
		.word	IS3_adr
		.word	IS2_adr
		.word	IS1_adr

C1_handler_table
		.word	NUL_adr			; this one is unused
		.word	NUL_adr			; so is this one
		.word	BPH_adr
		.word	NBH_adr
		.word	IND_adr
		.word	NEL_adr
		.word	SSA_adr
		.word	ESA_adr
		.word	HTS_adr
		.word	HTJ_adr
		.word	VTS_adr
		.word	PLD_adr
		.word	PLU_adr
		.word	RI_adr
		.word	SS2_adr
		.word	SS3_adr
		.word	DCS_adr
		.word	PU1_adr
		.word	PU2_adr
		.word	STS_adr
		.word	CCH_adr
		.word	MW_adr
		.word	SPA_adr
		.word	EPA_adr
		.word	SOS_adr
		.word	NUL_adr			; unused
		.word	SCI_adr
		.word	CSI_adr
		.word	ST_adr
		.word	OSC_adr
		.word	PM_adr
		.word	APC_adr

;###################################################################################################################
; table of addresses for control sequences
; entry format is this: final byte, intermediate byte, low address, high address
; last entry has 0 for final byte
; if there is no intermediate byte, then it is 0 in the entry.
; I can either implement a sorted list here and do a binary search in the future, or I can implement a list sorted so that more common
; control sequences come first. I don't know which I'll choose for the final design yet, but I'll choose at some point.

ctrl_seq_table
		.byte	'm', 0
		.word	SGR_adr			; set graphics rendition

		.byte 'J',0			; Erase in Display
		.word ED_adr

		.byte 'H',0			; Cursor Position
		.word CUP_adr

		.byte 'C',0			; Cursor Forward
		.word CUF_adr

		.byte 's',0			; Save Current Cursor Position
		.word SCP_adr

		.byte 'u',0			; Restore Saved Cursor Position
		.word RCP_adr

		.byte 'A',0			; Cursor Up
		.word CUU_adr

		.byte 'B',0			; Cursor Down
		.word CUD_adr

		.byte 'D',0			; Cursor Back
		.word CUB_adr

		.byte	0			; this shows the end of the list.


;###################################################################################################################

ctrl_seq_flg	.ds 1				; bit 7 indicates escape received, bit 6 indicates CSI received.

cursor_flg	.ds 1				; bit 7 indicates whether or not the cursor is currently visible
						; that is, if it's a 1, then the color of the current character
						; has been inverted to show the cursor.

ctrl_seq_index	.ds 1				; points to the current position in the control sequence buffer.

final_byte	.ds 1				; holds the control sequence final byte
inter_byte	.ds 1				; holds the control sequence intermediate byte
parameter_val	.ds 1				; holds a single parameter value

counter		.ds 2				; byte counter for MEM_MOVE

parameters	.ds 4

;###################################################################################################################

ctrl_seq_buf	.ds 256				; a buffer for the control sequence. I'll have to mess around with various sizes for
						; this. 256 bytes seems way overkill, so I probably only need 16 or so. For now, it's
						; 256 though.
