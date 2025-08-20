
.proc	@ansi

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

; ANTIC equates
VCOUNT		equ	$D40B			; line count / 2
; GTIA equates
CONSOL		equ	$D01F			; console key register
; POKEY equates
KBCODE		equ	$D209			; keyboard code register


; VBXE equates
vbxe_mem_base	equ	MAIN.SYSTEM.VBXE_WINDOW	; If I put it here, it should be OK and it won't conflict with the extended RAM.

vbxe_screen_top	equ	vbxe_mem_base		; points to where the first character of the screen would be


; VBXE equates
core_version	equ	$40			; tells us whether FX or GTIA-emu core
minor_revision	equ	$41			; tells us minor revision number (like 26 in 1.26)

; memory window B control register
; bit 0 - 4 - bank number (banks are all 16K)
; bit 6 - MBAE - ANTIC access enable
; bit 7 - MBCE - CPU access enable

memac_b_control	equ	$5D

; memory window A control register
; bit 0 and 1 - window size - 00 for 4K, 01 for 8K, 10 for 16K, 11 for 32K
; bit 2 - MAE - when set, antic can see VBXE RAM
; bit 3 - MCE - when set, CPU can see VBXE RAM

memac_control	equ	$5E

memac_bank_sel	equ	$5F			; controls bank number of movable window (MEMAC A). bit 7 is an enable bit
csel		equ	$44			; selects current color number for write
psel		equ	$45			; selects the pallette number to load into
cr		equ	$46			; red component value
cg		equ	$47			; green component value
cb		equ	$48			; blue component value
xdl_adr		equ	$41			; xdl address registers (3 consecutive)

; video control register
; bit 0 - xdl_enabled - set to enable XDL
; bit 1 - xcolor - set to enable 16 luminances and separate ANTIC hi-res foreground and background hues
; bit 2 - no_trans - clear means color 0 is transparent
; bit 3	- trans15 - allows additional transparent colors. only works when no_trans is 0

video_control	equ	$40

colmask		equ	$49			; AND mask for collisions with GTIA/ANTIC and VBXE stuff
colclr		equ	$4A			; clears coldetect (any value written here)
coldetect	equ	$4A			; collisions detected.
blt_adr		equ	$50			; blitter list address (3 bytes, consecutive)
blt_collision	equ	$50			; collision codes that blitter has set
blt_start	equ	$53			; bit 0 set to start blitter
blt_busy	equ	$53			; bit 1 for busy, bit 0 for BCB load. register will read 0 when blitter is stopped.
irq_control	equ	$54			; set bit 0 to enable blitter IRQ
irq_status	equ	$54			; bit 0 set means blitter threw an IRQ
P0		equ	$55			; priority select registers when attribute map is enabled.
P1		equ	$56
P2		equ	$57
P3		equ	$58



;###################################################################################################################

; Display Handler Equates (among others)

ctrl_seq_flg	= oldchr			; bit 7 indicates escape received, bit 6 indicates CSI received.

cursor_address	= savadr			; points to the address where the text cursor points

row		= rowcrs			; cursor row
column		= colcrs			; cursor column

temp_char	= atachr			; holds a character temporarily for the recieve processing routines
text_color	= fildat			; current text color to be put on the screen.


;###################################################################################################################

/*
start
		fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

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

		jsr	@vbxe_scroll.page
		jsr	@vbxe_cursor.on

		fxs FX_MEMS #$00

		rts
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

		jmp	@vbxe_PutByte		; if it's not part of the C0 set, just print it.


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
		jmp 	@vbxe_PutByte		; the put_byte routine will return for us
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
		jsr	@vbxe_cursor.off
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
		jmp	@vbxe_cursor.on
scroll		jsr	@vbxe_scroll.one	; scroll one line down. we don't need to touch the cursor address, the row, or column.
		jmp	@vbxe_cursor.on
		.endl

CR_adr		.local				; Carriage Return puts the cursor at the home position of the current line
                                                ; (AKA, cursor gets column number * 2 bytes/char subtracted from it)
		jsr	@vbxe_cursor.off
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
		jmp	@vbxe_cursor.on
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

FF_adr		jmp @FF_adr			; @vbxe_clrscr

BS_adr		.local				; Back Space moves the cursor left by one character (2 bytes).
		jsr	@vbxe_cursor.off
		lda	column
		bne	not_left		; if we're not at the left side yet, keep going
		rts				; but if we ARE at the left side, do nothing
not_left	dec	column			; if column isn't 0, we just decrement it
		lda	cursor_address
		bne	no_borrow		; if the cursor address low half isn't 0, we don't borrow
		dec	cursor_address + 1	; otherwise, borrow
no_borrow	dec	cursor_address		; if it weren't for the fact that cursor_address should always be even,
		dec 	cursor_address		; we would have to look for a borrow here too.
		jmp	@vbxe_cursor.on
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

		jmp @vbxe_PutByte

		;rts
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
		cpy	#4
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

clr		jmp @FF_adr

		.endl

;###################################################################################################################

SCP_adr		.local				; Save Current Cursor Position

		lda row
		sta RCP_adr.oldrow

		lda column
		sta RCP_adr.oldcol

		rts

		.endl

;###################################################################################################################

RCP_adr		.local				; Restore Saved Cursor Position

		lda oldrow: #0
		sta row

		lda oldcol: #0
		sta column

		jmp @vbxe_SetCursor

		.endl

;###################################################################################################################

CUF_adr		.local				; Cursor Forward

		jsr get_param

		lda parameters
		sne
		lda #1

		add column
		sta column

		jmp @vbxe_SetCursor

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

skp		jmp @vbxe_SetCursor

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

skp		jmp @vbxe_SetCursor

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

skp		jmp @vbxe_SetCursor

		.endl

;###################################################################################################################

CUP_adr		.local				; Cursor Position
						; Moves the cursor to row n, column m. The values are 1-based, and default to 1 (top left corner) if omitted
		jsr get_param


		lda parameters+1
		sne
		lda #1

		sub #1
		sta column


		lda parameters
		sne
		lda #1

		sub #1

srow		cmp #24
		bcc ok
	
		sbc #24
		jmp srow
ok
		sta row

		jmp @vbxe_SetCursor

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
		.word	FF_adr			; @vbxe_clrscr
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

		.byte	'J',0			; Erase in Display
		.word	ED_adr

		.byte	'H',0			; Cursor Position
		.word	CUP_adr

		.byte	'C',0			; Cursor Forward
		.word	CUF_adr

		.byte	's',0			; Save Current Cursor Position
		.word	SCP_adr

		.byte	'u',0			; Restore Saved Cursor Position
		.word	RCP_adr

		.byte	'A',0			; Cursor Up
		.word	CUU_adr

		.byte	'B',0			; Cursor Down
		.word	CUD_adr

		.byte	'D',0			; Cursor Back
		.word	CUB_adr

		.byte	0			; this shows the end of the list.


;###################################################################################################################

ctrl_seq_index	brk				; points to the current position in the control sequence buffer.

final_byte	brk				; holds the control sequence final byte
inter_byte	brk				; holds the control sequence intermediate byte
parameter_val	brk				; holds a single parameter value

parameters	dta 0,0,0,0

;###################################################################################################################

ctrl_seq_buf	dta 0,0,0,0,0,0,0,0		; a buffer for the control sequence. I'll have to mess around with various sizes for
		dta 0,0,0,0,0,0,0,0		; this. 256 bytes seems way overkill, so I probably only need 16 or so. For now, it's
						; 256 though.

.endp
