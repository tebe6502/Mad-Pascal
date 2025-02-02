; Mad Pascal version -> resource RMTPLAY2
;
; rmt_play vector at first
;
; RMTGLOBALVOLUMEFADE, RMTSFXVOLUME automodification code
;

;*
;* Raster Music Tracker, RMT Atari routine version 1.20090108
;* (c) Radek Sterba, Raster/C.P.U., 2002 - 2009
;* http://raster.atari.org
;
;* Modifications:
;* (c) Jerzy Kut, Mono/Tristss, 2011-2025
;* 2011/08/15: player can be placed on any address in memory
;* 2011/08/16: RMT4 plays the same on both channels
;* 2015/12/16: RMTPATCH variable introduced to configure: 0-standard RMT 1.28, 1-Miker's 0A patch
;* 2025/01/26: self-modify code removed; on-the-fly addresses recalculation; optimizations

;*
;* Warnings:
;*
;* 1. RMT player routine needs 19+6 itself reserved bytes in zero page (no accessed
;*    from any other routines) as well as cca 1KB of memory for functionary variables.
;*
;* 2. RMT player routine do not need to be compiled from the begin of the memory page.
;*    i.e. "PLAYER" address can be $..00 only!
;*
;* 3. Because of RMTplayer provides a lot of effects, it spent a lot of CPU time.
;*
;* STEREOMODE	equ 0..3			;0 => compile RMTplayer for 4 tracks mono
;*									;1 => compile RMTplayer for 8 tracks stereo
;*									;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;*									;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4
;*
;* Recommended usage example in own code:
;*
;* STEREOMODE = 1
;* 	icl "rmt_feat.a65"
;* FEAT_RECALCADDR = 1
;* FEAT_PATCH = 1
;*
;* 	icl "rmt_constants.icl"
;*
;*	org $80
;*
;*	icl "rmt_zeropage.icl"
;*
;*	org $400
;*
;*	icl "rmt_variables.icl"
;*
;*	org $A000
;*
;* start:
;*	IFT FEAT_PATCH
;*	lda #RMT_STANDARD
;*	sta RMTPATCH
;*	EIF
;*	IFT FEAT_RECALCADDR
;*	ldx #<original_module_address
;*	ldy #>original_module_address
;*	stx RMTORIGINALADDR
;*	sty RMTORIGINALADDR+1
;*	EIF
;*
;*	lda #$00
;*	sta RMTGLOBALVOLUMEFADE
;*	lda #$F0
;*	sta RMTSFXVOLUME
;*
;*	ldx #<music
;*	ldy #>music
;*	lda #0
;*	jsr RASTERMUSICTRACKER		;init
;*
;* ?loop
;*	jsr waitvblk
;*	jsr RASTERMUSICTRACKER+3	;play
;*	jsr keyprssed
;*	bne ?loop
;*
;*	jmp RASTERMUSICTRACKER+9	;silence
;*
;* music
;*	ins "music.rmt",6
;*

;*
;* Set of RMT main vectors:
;*


// ---------------------------------------------------

	IFT STEREOMODE==1
TRACKS		equ 8
	ELS
TRACKS		equ 4
	EIF
INSTRPAR	equ 12

FEAT_EFFECTS equ FEAT_EFFECTVIBRATO||FEAT_EFFECTFSHIFT

FEAT_RECALCADDR = 0
FEAT_PATCH = 0

RMT_STANDARD = 0	;standard RMT 1.28
RMT_PATCH0A = 1		;16-bit bass 0a patch

// ---------------------------------------------------

p_tis = .ZPVAR

.ZPVAR .word p_instrstable, p_trackslbstable, p_trackshbstable, p_song, ns, nr, nt
.ZPVAR .byte reg1, reg2, reg3, tmp

	IFT FEAT_COMMAND2
	.ZPVAR .byte frqaddcmd2
	EIF

	IFT FEAT_PATCH
	.ZPVAR .word rmtdistad, rmtfrqload, rmtfrqhiad
	EIF

// ---------------------------------------------------

	jmp rmt_play			; rmt_play at first

	jmp rmt_init
	jmp rmt_p3
	jmp rmt_silence
	jmp SetPokey

	IFT FEAT_SFX
	jmp rmt_sfx			;* A=note(0,..,60),X=channel(0,..,3 or 0,..,7),Y=instrument*2(0,2,4,..,126)
	EIF
rmt_init
	stx ns
	sty ns+1
	IFT FEAT_NOSTARTINGSONGLINE==0
	pha
	EIF
	IFT track_endvariables-track_variables>255
	ldy #0
	tya
ri0	sta track_variables,y
	sta track_endvariables-$100,y
	iny
	bne ri0
	ELS
	ldy #track_endvariables-track_variables
	lda #0
ri0	sta track_variables-1,y
	dey
	bne ri0
	EIF

	IFT FEAT_PATCH
	lda RMTPATCH
	asl
	tay
	lda basslotabad,y
	sta rmtfrqload
	lda basslotabad+1,y
	sta rmtfrqload+1
	lda basshitabad,y
	sta rmtfrqhiad
	lda basshitabad+1,y
	sta rmtfrqhiad+1
	lda tabdistortabad,y
	sta rmtdistad
	lda tabdistortabad+1,y
	sta rmtdistad+1
	EIF

	ldy #3
	lda (ns),y	;RMTx
	and #%00001111
	sta v_channel_number
	sta v_channel_number_less1
	dec v_channel_number_less1

	iny
	lda (ns),y
	sta v_maxtracklen
	iny
	IFT FEAT_CONSTANTSPEED==0
	lda (ns),y
	sta v_speed
	EIF
	IFT FEAT_INSTRSPEED==0
	iny
	lda (ns),y
	sta v_instrspeed
	sta v_ainstrspeed
	ELI FEAT_INSTRSPEED>1
	lda #FEAT_INSTRSPEED
	sta v_ainstrspeed
	EIF

	IFT FEAT_RECALCADDR
	lda ns
	sec
	sbc RMTORIGINALADDR
	sta v_addr_delta
	lda ns+1
	sbc RMTORIGINALADDR+1
	sta v_addr_delta+1
	EIF
	ldy #8
ri1	lda (ns),y
	IFT FEAT_RECALCADDR
	clc
	adc v_addr_delta
	sta p_tis-8,y
	iny
	lda (ns),y
	adc v_addr_delta+1
	EIF
	sta p_tis-8,y
	iny
	cpy #8+8
	bne ri1

	IFT FEAT_NOSTARTINGSONGLINE==0
	lda #0
	sta tmp
	lda v_channel_number
	cmp #8
	pla
	bcc ?x4
	asl @
	rol tmp
?x4	asl @
	rol tmp
	asl @
	rol tmp
;	clc
	adc p_song
	sta p_song
	lda tmp
	adc p_song+1
	sta p_song+1
	EIF
	jsr GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
rmt_silence
	IFT STEREOMODE>0
	lda #0
	sta $d218
	sta $d208
	ldy #3
	sty $d21f
	sty $d20f
	ldy #8
si1	sta $d210,y
	sta $d200,y
	dey
	bpl si1
	ELS
	lda #0
	sta $d208
	ldy #3
	sty $d20f
	ldy #8
si1	sta $d200,y
	dey
	bpl si1
	EIF
	IFT FEAT_INSTRSPEED==0
	lda v_instrspeed
	ELS
	lda #FEAT_INSTRSPEED
	EIF
	rts
GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
GetSongLine
	ldx #0
	stx v_abeat
nn0
nn1	txa
	tay
	lda (p_song),y
	cmp #$fe
	bcs nn2
	tay
	lda (p_trackslbstable),y
	IFT FEAT_RECALCADDR
;	clc
	adc v_addr_delta
	EIF
	sta trackn_db,x
	lda (p_trackshbstable),y
	IFT FEAT_RECALCADDR
	adc v_addr_delta+1
	EIF
nn1a sta trackn_hb,x
	lda #0
	sta trackn_idx,x
	lda #1
nn1a2 sta trackn_pause,x
	lda #$80
	sta trackn_instrx2,x
	inx
xtracks01
	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	cpx v_channel_number
	ELS
	cpx #TRACKS
	EIF
	bne nn1
	lda p_song
	clc
xtracks02	adc v_channel_number	;#TRACKS
	sta p_song
	bcc GetTrackLine
	inc p_song+1
nn1b
	jmp GetTrackLine
nn2
	beq nn3
nn2a
	lda #0
	beq nn1a2
nn3
	ldy #2
	lda (p_song),y
	IFT FEAT_RECALCADDR
	clc
	adc v_addr_delta
	EIF
	tax
	iny
	lda (p_song),y
	IFT FEAT_RECALCADDR
	adc v_addr_delta+1
	EIF
	sta p_song+1
	stx p_song
	ldx #0
	beq nn0
GetTrackLine
oo0
oo0a
	IFT FEAT_CONSTANTSPEED==0
	lda v_speed
	sta v_bspeed
	EIF
	ldx #-1
oo1
	inx
	dec trackn_pause,x
	bne oo1x
oo1b
	lda trackn_db,x
	sta ns
	lda trackn_hb,x
	sta ns+1
oo1i
	ldy trackn_idx,x
	inc trackn_idx,x
	lda (ns),y
	sta reg1
	and #$3f
	cmp #61
	beq oo1a
	bcs oo2
	sta trackn_note,x
	IFT FEAT_BASS16
	sta trackn_outnote,x
	EIF
	iny
	lda (ns),y
	lsr @
	and #$3f*2
	sta trackn_instrx2,x
oo1a
	lda #1
	sta trackn_pause,x
	ldy trackn_idx,x
	inc trackn_idx,x
	lda (ns),y
	lsr @
	ror reg1
	lsr @
	ror reg1
	lda reg1
	IFT FEAT_GLOBALVOLUMEFADE
	sec
	sbc RMTGLOBALVOLUMEFADE:: #$00
	bcs voig
	lda #0
voig
	EIF
	and #$f0
	sta trackn_volume,x
oo1x
xtracks03sub1
	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	cpx v_channel_number_less1
	ELS
	cpx #TRACKS-1
	EIF
	bne oo1
	IFT FEAT_CONSTANTSPEED==0
	lda v_bspeed
	sta v_speed
	ELS
	lda #FEAT_CONSTANTSPEED
	EIF
	sta v_aspeed
	jmp InitOfNewSetInstrumentsOnly
oo2
	cmp #63
	beq oo63
	lda reg1
	and #$c0
	beq oo62_b
	asl @
	rol @
	rol @
	sta trackn_pause,x
	jmp oo1x
oo62_b
	iny
	lda (ns),y
	sta trackn_pause,x
	inc trackn_idx,x
	jmp oo1x
oo63
	lda reg1
	IFT FEAT_CONSTANTSPEED==0
	bmi oo63_1X
	iny
	lda (ns),y
	sta v_bspeed
	inc trackn_idx,x
	jmp oo1i
oo63_1X
	EIF
	cmp #255
	beq oo63_11
	iny
	lda (ns),y
	sta trackn_idx,x
	jmp oo1i
oo63_11
	jmp GetSongLine
p2xrmtp3	jmp rmt_p3
p2x0 dex
	 bmi p2xrmtp3
InitOfNewSetInstrumentsOnly
p2x1 ldy trackn_instrx2,x
	bmi p2x0
	IFT FEAT_SFX
	jsr SetUpInstrumentY2
	jmp p2x0
rmt_sfx
	sta trackn_note,x
	IFT FEAT_BASS16
	sta trackn_outnote,x
	EIF
	lda RMTSFXVOLUME:: #$00
;	lda #$f0			;* sfx note volume*16
;RMTSFXVOLUME equ *-1			;* label for sfx note volume parameter overwriting
	sta trackn_volume,x
	EIF
SetUpInstrumentY2
	lda (p_instrstable),y
	IFT FEAT_RECALCADDR
	clc
	adc v_addr_delta
	EIF
	sta trackn_instrdb,x
	sta nt
	iny
	lda (p_instrstable),y
	IFT FEAT_RECALCADDR
	adc v_addr_delta+1
	EIF
	sta trackn_instrhb,x
	sta nt+1
	IFT FEAT_FILTER
	lda #1
	sta trackn_filter,x
	EIF
	IFT FEAT_TABLEGO
	IFT FEAT_FILTER
	tay
	ELS
	ldy #1
	EIF
	lda (nt),y
	sta trackn_tablelop,x
	iny
	ELS
	ldy #2
	EIF
	lda (nt),y
	sta trackn_instrlen,x
	iny
	lda (nt),y
	sta trackn_instrlop,x
	iny
	lda (nt),y
	sta trackn_tabletypespeed,x
	IFT FEAT_TABLETYPE||FEAT_TABLEMODE
	and #$3f
	EIF
	sta trackn_tablespeeda,x
	IFT FEAT_TABLEMODE
	lda (nt),y
	and #$40
	sta trackn_tablemode,x
	EIF
	IFT FEAT_AUDCTLMANUALSET
	iny
	lda (nt),y
	sta trackn_audctl,x
	iny
	ELS
	ldy #6
	EIF
	lda (nt),y
	sta trackn_volumeslidedepth,x
	IFT FEAT_VOLUMEMIN
	iny
	lda (nt),y
	sta trackn_volumemin,x
	IFT FEAT_EFFECTS
	iny
	EIF
	ELS
	IFT FEAT_EFFECTS
	ldy #8
	EIF
	EIF
	IFT FEAT_EFFECTS
	lda (nt),y
	sta trackn_effdelay,x
	IFT FEAT_EFFECTVIBRATO
	iny
	lda (nt),y
	tay
	lda vibtabbeg,y
	sta trackn_effvibratoa,x
	EIF
	IFT FEAT_EFFECTFSHIFT
	ldy #10
	lda (nt),y
	sta trackn_effshift,x
	EIF
	EIF
	lda #128
	sta trackn_volumeslidevalue,x
	sta trackn_instrx2,x
	asl @
	sta trackn_instrreachend,x
	sta trackn_shiftfrq,x
	tay
	lda (nt),y
	sta trackn_tableend,x
	adc #0
	sta trackn_instridx,x
	lda #INSTRPAR
	sta trackn_tablea,x
	tay
	lda (nt),y
	sta trackn_tablenote,x
xata_rtshere
	IFT FEAT_SFX
	rts
	ELS
	jmp p2x0
	EIF
rmt_play
rmt_p0
	jsr SetPokey
rmt_p1
	IFT FEAT_INSTRSPEED==0||FEAT_INSTRSPEED>1
	dec v_ainstrspeed
	bne rmt_p3
	EIF
	IFT FEAT_INSTRSPEED==0
	lda v_instrspeed
	sta v_ainstrspeed
	ELI FEAT_INSTRSPEED>1
	lda #FEAT_INSTRSPEED
	sta v_ainstrspeed
	EIF
rmt_p2
	dec v_aspeed
	bne rmt_p3
	inc v_abeat
	lda v_abeat
	cmp v_maxtracklen
	beq p2o3
	jmp GetTrackLine
p2o3
	jmp GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
go_ppnext	jmp ppnext
rmt_p3
; moved below
;	lda #>frqtab
;	sta nr+1
xtracks05sub1
	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	ldx v_channel_number_less1
	ELS
	ldx #TRACKS-1
	EIF
pp1
	lda trackn_instrhb,x
	beq go_ppnext
	sta ns+1
	lda trackn_instrdb,x
	sta ns
	ldy trackn_instridx,x
	lda (ns),y
	sta reg1
	iny
	lda (ns),y
	sta reg2
	iny
	lda (ns),y
	sta reg3
	iny
	tya
	cmp trackn_instrlen,x
	bcc pp2
	beq pp2
	lda #$80
	sta trackn_instrreachend,x
pp1b
	lda trackn_instrlop,x
pp2	sta trackn_instridx,x
	lda reg1

	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	ldy v_channel_number
	cpy #8
	bcc pp2s

;	IFT TRACKS>4
	cpx #4
	bcc pp2s
	lsr @
	lsr @
	lsr @
	lsr @
pp2s
;	EIF
	EIF

	and #$0f
	ora trackn_volume,x
	tay
	lda volumetab,y
	sta tmp
	lda reg2
	and #$0e
	tay
	lda tabbegad,y		;lda tabbeganddistor,y
	sta nr
	lda tabbegad+1,y
	sta nr+1
	lda tmp
	IFT FEAT_PATCH
	ora (rmtdistad),y	;tabbeganddistor+1,y
	ELS
	ora tabdistor,y
	EIF
	sta trackn_audc,x
InstrumentsEffects
	IFT FEAT_EFFECTS
	lda trackn_effdelay,x
	beq ei2
	cmp #1
	bne ei1
	lda trackn_shiftfrq,x
	IFT FEAT_EFFECTFSHIFT
	clc
	adc trackn_effshift,x
	EIF
	IFT FEAT_EFFECTVIBRATO
	clc
	ldy trackn_effvibratoa,x
	adc vib0,y
	EIF
	sta trackn_shiftfrq,x
	IFT FEAT_EFFECTVIBRATO
	lda vibtabnext,y
	sta trackn_effvibratoa,x
	EIF
	jmp ei2
ei1
	dec trackn_effdelay,x
ei2
	EIF
	ldy trackn_tableend,x
	cpy #INSTRPAR+1
	bcc ei3
	lda trackn_tablespeeda,x
	bpl ei2f
ei2c
	tya
	cmp trackn_tablea,x
	bne ei2c2
	IFT FEAT_TABLEGO
	lda trackn_tablelop,x
	ELS
	lda #INSTRPAR
	EIF
	sta trackn_tablea,x
	bne ei2a
ei2c2
	inc trackn_tablea,x
ei2a
	lda trackn_instrdb,x
	sta nt
	lda trackn_instrhb,x
	sta nt+1
	ldy trackn_tablea,x
	lda (nt),y
	IFT FEAT_TABLEMODE
	ldy trackn_tablemode,x
	beq ei2e
	clc
	adc trackn_tablenote,x
ei2e
	EIF
	sta trackn_tablenote,x
	lda trackn_tabletypespeed,x
	IFT FEAT_TABLETYPE||FEAT_TABLEMODE
	and #$3f
	EIF
ei2f
	sec
	sbc #1
	sta trackn_tablespeeda,x
ei3
	lda trackn_instrreachend,x
	bpl ei4
	lda trackn_volume,x
	beq ei4
	IFT FEAT_VOLUMEMIN
	cmp trackn_volumemin,x
	beq ei4
	bcc ei4
	EIF
	tay
	lda trackn_volumeslidevalue,x
	clc
	adc trackn_volumeslidedepth,x
	sta trackn_volumeslidevalue,x
	bcc ei4
	tya
	sbc #16
	sta trackn_volume,x
ei4
	IFT FEAT_COMMAND2
	lda #0
	sta frqaddcmd2
	EIF
	IFT FEAT_COMMAND1||FEAT_COMMAND2||FEAT_COMMAND3||FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	lda reg2
	IFT FEAT_FILTER||FEAT_BASS16
	sta trackn_command,x
	EIF
	and #$70
	IFT 1==[FEAT_COMMAND1+FEAT_COMMAND2+FEAT_COMMAND3+FEAT_COMMAND4+FEAT_COMMAND5+FEAT_COMMAND6+[FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY]]
	beq cmd0
	ELS
	jeq cmd0
	IFT FEAT_COMMAND1
	cmp #$10
	jeq cmd1
	EIF
	IFT FEAT_COMMAND2
	cmp #$20
	jeq cmd2
	EIF
	IFT FEAT_COMMAND3
	cmp #$30
	jeq cmd3
	EIF
	IFT FEAT_COMMAND4
	cmp #$40
	jeq cmd4
	EIF
	IFT FEAT_COMMAND5
	cmp #$50
	jeq cmd5
	EIF
	IFT FEAT_COMMAND6
	cmp #$60
	jeq cmd6
	EIF
	IFT FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	jmp cmd7
	EIF
	EIF
	ELS
	IFT FEAT_FILTER||FEAT_BASS16
	lda reg2
	sta trackn_command,x
	EIF
	EIF
cmd1
	IFT FEAT_COMMAND1
	lda reg3
	jmp cmd0c
	EIF
cmd2
	IFT FEAT_COMMAND2
	lda reg3
	sta frqaddcmd2
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd3
	IFT FEAT_COMMAND3
	lda trackn_note,x
	clc
	adc reg3
	sta trackn_note,x
	jmp cmd0a
	EIF
cmd4
	IFT FEAT_COMMAND4
	lda trackn_shiftfrq,x
	clc
	adc reg3
	sta trackn_shiftfrq,x
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd5
	IFT FEAT_COMMAND5&&FEAT_PORTAMENTO
	IFT FEAT_TABLETYPE
	lda trackn_tabletypespeed,x
	bpl cmd5a1
	ldy trackn_note,x
	lda (nr),y
	clc
	adc trackn_tablenote,x
	jmp cmd5ax
	EIF
cmd5a1
	lda trackn_note,x
	clc
	adc trackn_tablenote,x
	cmp #61
	bcc cmd5a2
	lda #63
cmd5a2
	tay
	lda (nr),y
cmd5ax
	sta trackn_portafrqc,x
	ldy reg3
	bne cmd5a
	sta trackn_portafrqa,x
cmd5a
	tya
	lsr @
	lsr @
	lsr @
	lsr @
	sta trackn_portaspeed,x
	sta trackn_portaspeeda,x
	lda reg3
	and #$0f
	sta trackn_portadepth,x
	lda trackn_note,x
	jmp cmd0a
	ELI FEAT_COMMAND5
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd6
	IFT FEAT_COMMAND6&&FEAT_FILTER
	lda reg3
	clc
	adc trackn_filter,x
	sta trackn_filter,x
	lda trackn_note,x
	jmp cmd0a
	ELI FEAT_COMMAND6
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd7
	IFT FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	IFT FEAT_COMMAND7SETNOTE
	lda reg3
	IFT FEAT_COMMAND7VOLUMEONLY
	cmp #$80
	beq cmd7a
	EIF
	sta trackn_note,x
	jmp cmd0a
	EIF
	IFT FEAT_COMMAND7VOLUMEONLY
cmd7a
	lda trackn_audc,x
	ora #$f0
	sta trackn_audc,x
	lda trackn_note,x
	jmp cmd0a
	EIF
	EIF
cmd0
	lda trackn_note,x
	clc
	adc reg3
cmd0a
	IFT FEAT_TABLETYPE
	ldy trackn_tabletypespeed,x
	bmi cmd0b
	EIF
	clc
	adc trackn_tablenote,x
	cmp #61
	bcc cmd0a1
	lda #0
	sta trackn_audc,x
	lda #63
cmd0a1
	IFT FEAT_BASS16
	sta trackn_outnote,x
	EIF
	tay
	lda (nr),y
	clc
	adc trackn_shiftfrq,x
	IFT FEAT_COMMAND2
	clc
	adc frqaddcmd2
	EIF
	IFT FEAT_TABLETYPE
	jmp cmd0c
cmd0b
	cmp #61
	bcc cmd0b1
	lda #0
	sta trackn_audc,x
	lda #63
cmd0b1
	tay
	lda trackn_shiftfrq,x
	clc
	adc trackn_tablenote,x
	clc
	adc (nr),y
	IFT FEAT_COMMAND2
	clc
	adc frqaddcmd2
	EIF
	EIF
cmd0c
	sta trackn_audf,x
pp9
	IFT FEAT_PORTAMENTO
	lda trackn_portaspeeda,x
	beq pp10
	dec trackn_portaspeeda,x
	bne pp10
	lda trackn_portaspeed,x
	sta trackn_portaspeeda,x
	lda trackn_portafrqa,x
	cmp trackn_portafrqc,x
	beq pp10
	bcs pps1
	adc trackn_portadepth,x
	bcs pps8
	cmp trackn_portafrqc,x
	bcs pps8
	jmp pps9
pps1
	sbc trackn_portadepth,x
	bcc pps8
	cmp trackn_portafrqc,x
	bcs pps9
pps8
	lda trackn_portafrqc,x
pps9
	sta trackn_portafrqa,x
pp10
	lda reg2
	and #$01
	beq pp11
	lda trackn_portafrqa,x
	clc
	adc trackn_shiftfrq,x
	sta trackn_audf,x
pp11
	EIF
ppnext
	dex
	bmi rmt_p4
	jmp pp1
rmt_p4
	IFT FEAT_AUDCTLMANUALSET
	lda trackn_audctl+0
	ora trackn_audctl+1
	ora trackn_audctl+2
	ora trackn_audctl+3
	tax
	ELS
	ldx #0
	EIF
qq1
	stx v_audctl
	IFT FEAT_FILTER
	IFT FEAT_FILTERG0L
	lda trackn_command+0
	bpl qq2
	lda trackn_audc+0
	and #$0f
	beq qq2
	lda trackn_audf+0
	clc
	adc trackn_filter+0
	sta trackn_audf+2
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq1a
	ELS
	lda #0
	EIF
	sta trackn_audc+2
qq1a
	txa
	ora #4
	tax
	EIF
qq2
	IFT FEAT_FILTERG1L
	lda trackn_command+1
	bpl qq3
	lda trackn_audc+1
	and #$0f
	beq qq3
	lda trackn_audf+1
	clc
	adc trackn_filter+1
	sta trackn_audf+3
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3L
	lda trackn_audc+3
	and #$10
	bne qq2a
	ELS
	lda #0
	EIF
	sta trackn_audc+3
qq2a
	txa
	ora #2
	tax
	EIF
qq3
	IFT FEAT_FILTERG0L||FEAT_FILTERG1L
	cpx v_audctl
	bne qq5
	EIF
	EIF
	IFT FEAT_BASS16
	IFT FEAT_BASS16G1L
	lda trackn_command+1
	and #$0e
	cmp #6
	bne qq4
	lda trackn_audc+1
	and #$0f
	beq qq4
	ldy trackn_outnote+1
	IFT FEAT_PATCH
	lda (rmtfrqload),y
	ELS
	lda frqtabbasslo,y
	EIF
	sta trackn_audf+0
	IFT FEAT_PATCH
	lda (rmtfrqhiad),y
	ELS
	lda frqtabbasshi,y
	EIF
	sta trackn_audf+1
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0L
	lda trackn_audc+0
	and #$10
	bne qq3a
	EIF
	lda #0
	sta trackn_audc+0
qq3a
	txa
	ora #$50	;$d0 u analmuxa
	tax
	EIF
qq4
	IFT FEAT_BASS16G3L
	lda trackn_command+3
	and #$0e
	cmp #6
	bne qq5
	lda trackn_audc+3
	and #$0f
	beq qq5
	ldy trackn_outnote+3
	IFT FEAT_PATCH
	lda (rmtfrqload),y
	ELS
	lda frqtabbasslo,y
	EIF
	sta trackn_audf+2
	IFT FEAT_PATCH
	lda (rmtfrqhiad),y
	ELS
	lda frqtabbasshi,y
	EIF
	sta trackn_audf+3
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq4a
	EIF
	lda #0
	sta trackn_audc+2
qq4a
	txa
	ora #$28	;$a8 u analmuxa
	tax
	EIF
	EIF
qq5
	stx v_audctl

	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	lda v_channel_number
	cmp #8
	jcc rmt_p5

	;IFT TRACKS>4
	IFT FEAT_AUDCTLMANUALSET
	lda trackn_audctl+4
	ora trackn_audctl+5
	ora trackn_audctl+6
	ora trackn_audctl+7
	tax
	ELS
	ldx #0
	EIF
	stx v_audctl2
	IFT FEAT_FILTER
	IFT FEAT_FILTERG0R
	lda trackn_command+0+4
	bpl qs2
	lda trackn_audc+0+4
	and #$0f
	beq qs2
	lda trackn_audf+0+4
	clc
	adc trackn_filter+0+4
	sta trackn_audf+2+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
	lda trackn_audc+2+4
	and #$10
	bne qs1a
	ELS
	lda #0
	EIF
	sta trackn_audc+2+4
qs1a
	txa
	ora #4
	tax
	EIF
qs2
	IFT FEAT_FILTERG1R
	lda trackn_command+1+4
	bpl qs3
	lda trackn_audc+1+4
	and #$0f
	beq qs3
	lda trackn_audf+1+4
	clc
	adc trackn_filter+1+4
	sta trackn_audf+3+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3R
	lda trackn_audc+3+4
	and #$10
	bne qs2a
	ELS
	lda #0
	EIF
	sta trackn_audc+3+4
qs2a
	txa
	ora #2
	tax
	EIF
qs3
	IFT FEAT_FILTERG0R||FEAT_FILTERG1R
	cpx v_audctl2
	bne qs5
	EIF
	EIF
	IFT FEAT_BASS16
	IFT FEAT_BASS16G1R
	lda trackn_command+1+4	;+0+4 u analmuxa
	and #$0e
	cmp #6
	bne qs4
	lda trackn_audc+1+4	;+0+4 u analmuxa
	and #$0f
	beq qs4
	ldy trackn_outnote+1+4	;+0+4 u analmuxa
	IFT FEAT_PATCH
	lda (rmtfrqload),y
	ELS
	lda frqtabbasslo,y
	EIF
	sta trackn_audf+0+4
	IFT FEAT_PATCH
	lda (rmtfrqhiad),y
	ELS
	lda frqtabbasshi,y
	EIF
	sta trackn_audf+1+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0R
	lda trackn_audc+0+4
	and #$10
	bne qs3a
	EIF
	lda #0
	sta trackn_audc+0+4
qs3a
	txa
	ora #$50	;$d0 u analmuxa
	tax
	EIF
qs4
	IFT FEAT_BASS16G3R
	lda trackn_command+3+4	;+2+4 u analmuxa
	and #$0e
	cmp #6
	bne qs5
	lda trackn_audc+3+4	;+2+4 u analmuxa
	and #$0f
	beq qs5
	ldy trackn_outnote+3+4	;+2+4 u analmuxa
	IFT FEAT_PATCH
	lda (rmtfrqload),y
	ELS
	lda frqtabbasslo,y
	EIF
	sta trackn_audf+2+4
	IFT FEAT_PATCH
	lda (rmtfrqhiad),y
	ELS
	lda frqtabbasshi,y
	EIF
	sta trackn_audf+3+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
	lda trackn_audc+2+4
	and #$10
	bne qs4a
	EIF
	lda #0
	sta trackn_audc+2+4
qs4a
	txa
	ora #$28	;$a8 u analmuxa
	tax
	EIF
	EIF
qs5
	stx v_audctl2
	;EIF
	EIF
rmt_p5
	IFT FEAT_INSTRSPEED==0||FEAT_INSTRSPEED>1
	lda v_ainstrspeed
	ELS
	lda #1
	EIF
	rts
SetPokey
	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4

	lda v_audctl
	ldy v_audctl2

	ldx v_channel_number
	cpx #8
	jcc ?playthesame

	pha
	lda trackn_audf+0+4
	ldx trackn_audf+0
	sta $d210
	stx $d200
	lda trackn_audc+0+4
	ldx trackn_audc+0
	sta $d211
	stx $d201
	lda trackn_audf+1+4
	ldx trackn_audf+1
	sta $d212
	stx $d202
	lda trackn_audc+1+4
	ldx trackn_audc+1
	sta $d213
	stx $d203
	lda trackn_audf+2+4
	ldx trackn_audf+2
	sta $d214
	stx $d204
	lda trackn_audc+2+4
	ldx trackn_audc+2
	sta $d215
	stx $d205
	lda trackn_audf+3+4
	ldx trackn_audf+3
	sta $d216
	stx $d206
	lda trackn_audc+3+4
	ldx trackn_audc+3
	sta $d217
	stx $d207
	pla
	sty $d218
	sta $d208

	bcs ?done

?playthesame:
	ldy trackn_audf+0
	sty $d210
	sty $d200
	ldy trackn_audc+0
	sty $d211
	sty $d201
	ldy trackn_audf+1
	sty $d212
	sty $d202
	ldy trackn_audc+1
	sty $d213
	sty $d203
	ldy trackn_audf+2
	sty $d214
	sty $d204
	ldy trackn_audc+2
	sty $d215
	sty $d205
	ldy trackn_audf+3
	sty $d216
	sty $d206
	ldy trackn_audc+3
	sty $d217
	sty $d207
	sta $d218
	sta $d208

?done:

	ELI STEREOMODE==0		;* L1 L2 L3 L4
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta $d200
	stx $d201
	lda trackn_audf+1
	ldx trackn_audc+1
	sta $d200+2
	stx $d201+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta $d200+4
	stx $d201+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta $d200+6
	stx $d201+6
	sty $d208
	ELI STEREOMODE==2		;* L1 R2 R3 L4
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta $d200
	stx $d201
	sta $d210
	lda trackn_audf+1
	ldx trackn_audc+1
	sta $d210+2
	stx $d211+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta $d210+4
	stx $d211+4
	sta $d200+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta $d200+6
	stx $d201+6
	sta $d210+6
	sty $d218
	sty $d208
	ELI STEREOMODE==3		;* L1 L2 R3 R4
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta $d200
	stx $d201
	lda trackn_audf+1
	ldx trackn_audc+1
	sta $d200+2
	stx $d201+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta $d210+4
	stx $d211+4
	sta $d200+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta $d210+6
	stx $d211+6
	sta $d200+6
	sty $d218
	sty $d208
	EIF
	rts
RMTPLAYEREND


	IFT FEAT_PATCH
tabdistortabad:
	.word tabdistor
	.word miker_tabdistor

	IFT FEAT_BASS16
basslotabad:
	.word frqtabbasslo
	.word miker_frqtabbasslo

basshitabad:
	.word frqtabbasshi
	.word miker_frqtabbasshi
	EIF
	EIF


;for SDX relocation
tabbegad:
	.word frqtabpure
	.word frqtabpure
	.word frqtabpure
	.word frqtabbass1
	.word frqtabpure
	.word frqtabpure
	.word frqtabbass1
	.word frqtabbass2

tabdistor:
;tablice mikera do patcha 0a (16-bit bass A0)
miker_tabdistor = *+1
	.byte $00,$00
	.byte $20,$20
	.byte $40,$40
	.byte $c0,$a0	;!
	.byte $80,$80
	.byte $a0,$a0
	.byte $c0,$c0
	.byte $c0,$c0

;tabbeganddistor:
; .byte frqtabpure-frqtab,$00
; .byte frqtabpure-frqtab,$20
; .byte frqtabpure-frqtab,$40
; .byte frqtabbass1-frqtab,$c0
; .byte frqtabpure-frqtab,$80
; .byte frqtabpure-frqtab,$a0
; .byte frqtabbass1-frqtab,$c0
; .byte frqtabbass2-frqtab,$c0

		IFT FEAT_EFFECTVIBRATO
vib0	.byte 0
vib1	.byte 1,-1,-1,1
vib2	.byte 1,0,-1,-1,0,1
vib3	.byte 1,1,0,-1,-1,-1,-1,0,1,1

;for sdx relocation

;vibtabbeg	.byte <(vib0-vib0),<(vib1-vib0),<(vib2-vib0),<(vib3-vib0)
;vibtabnext	.byte <(vib0-vib0+0)
;		.byte <(vib1-vib0+1),<(vib1-vib0+2),<(vib1-vib0+3),<(vib1-vib0+0)
;		.byte <(vib2-vib0+1),<(vib2-vib0+2),<(vib2-vib0+3),<(vib2-vib0+4),<(vib2-vib0+5),<(vib2-vib0+0)
;		.byte <(vib3-vib0+1),<(vib3-vib0+2),<(vib3-vib0+3),<(vib3-vib0+4),<(vib3-vib0+5),<(vib3-vib0+6),<(vib3-vib0+7),<(vib3-vib0+8),<(vib3-vib0+9),<(vib3-vib0+0)

vibtabbeg:
	.byte   $00,$01,$05,$0B

vibtabnext:
	.byte   $00
	.byte	$02,$03,$04,$01
	.byte	$06,$07,$08,$09,$0A,$05
	.byte	$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$0B

		EIF

	IFT FEAT_BASS16
frqtabbasslo
	.byte $F2,$33,$96,$E2,$38,$8C,$00,$6A,$E8,$6A,$EF,$80,$08,$AE,$46,$E6
	.byte $95,$41,$F6,$B0,$6E,$30,$F6,$BB,$84,$52,$22,$F4,$C8,$A0,$7A,$55
	.byte $34,$14,$F5,$D8,$BD,$A4,$8D,$77,$60,$4E,$38,$27,$15,$06,$F7,$E8
	.byte $DB,$CF,$C3,$B8,$AC,$A2,$9A,$90,$88,$7F,$78,$70,$6A,$64,$5E,$00

frqtabbasshi
	.byte $0D,$0D,$0C,$0B,$0B,$0A,$0A,$09,$08,$08,$07,$07,$07,$06,$06,$05
	.byte $05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02
	.byte $02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	IFT FEAT_PATCH
miker_frqtabbasslo; A0 distorsion based.
        .byte $DD,$DD,$34,$DB,$D0,$0D,$8E,$50,$4F,$88,$F7,$99,$6B,$6B,$96,$EA
        .byte $64,$03,$C4,$A5,$A4,$C0,$F8,$49,$B2,$32,$C8,$72,$2F,$FE,$DE,$CF
        .byte $CF,$DD,$F8,$21,$56,$96,$E0,$35,$94,$FB,$6C,$E4,$64,$EB,$79,$0D
        .byte $A7,$47,$ED,$97,$46,$FA,$B2,$6E,$2E,$F2,$B9,$83,$50,$20,$F3,$C8

miker_frqtabbasshi; A0 distorsion based.
        .byte $6A,$64,$5F,$59,$54,$50,$4B,$47,$43,$3F,$3B,$38,$35,$32,$2F,$2C
        .byte $2A,$28,$25,$23,$21,$1F,$1D,$1C,$1A,$19,$17,$16,$15,$13,$12,$11
        .byte $10,$0F,$0E,$0E,$0D,$0C,$0B,$0B,$0A,$09,$09,$08,$08,$07,$07,$07
        .byte $06,$06,$05,$05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02
	EIF
	EIF

frqtab
frqtabbass1
	.byte $BF,$B6,$AA,$A1,$98,$8F,$89,$80,$F2,$E6,$DA,$CE,$BF,$B6,$AA,$A1
	.byte $98,$8F,$89,$80,$7A,$71,$6B,$65,$5F,$5C,$56,$50,$4D,$47,$44,$3E
	.byte $3C,$38,$35,$32,$2F,$2D,$2A,$28,$25,$23,$21,$1F,$1D,$1C,$1A,$18
	.byte $17,$16,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07
frqtabbass2
	.byte $FF,$F1,$E4,$D8,$CA,$C0,$B5,$AB,$A2,$99,$8E,$87,$7F,$79,$73,$70
	.byte $66,$61,$5A,$55,$52,$4B,$48,$43,$3F,$3C,$39,$37,$33,$30,$2D,$2A
	.byte $28,$25,$24,$21,$1F,$1E,$1C,$1B,$19,$17,$16,$15,$13,$12,$11,$10
	.byte $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00
frqtabpure
	.byte $F3,$E6,$D9,$CC,$C1,$B5,$AD,$A2,$99,$90,$88,$80,$79,$72,$6C,$66
	.byte $60,$5B,$55,$51,$4C,$48,$44,$40,$3C,$39,$35,$32,$2F,$2D,$2A,$28
	.byte $25,$23,$21,$1F,$1D,$1C,$1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F
	.byte $0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00,$00


volumetab
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
	.byte $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
	.byte $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
	.byte $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
	.byte $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
	.byte $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
	.byte $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
	.byte $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
	.byte $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
	.byte $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
	.byte $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
	.byte $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
	.byte $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F


track_variables

.var trackn_db		:TRACKS .byte
.var trackn_hb		:TRACKS .byte
.var trackn_idx		:TRACKS .byte
.var trackn_pause	:TRACKS .byte
.var trackn_note	:TRACKS .byte
.var trackn_volume	:TRACKS .byte
.var trackn_distor 	:TRACKS .byte
.var trackn_shiftfrq	:TRACKS .byte

	IFT FEAT_PORTAMENTO
	.var trackn_portafrqc	:TRACKS .byte
	.var trackn_portafrqa	:TRACKS .byte
	.var trackn_portaspeed	:TRACKS .byte
	.var trackn_portaspeeda	:TRACKS .byte
	.var trackn_portadepth	:TRACKS .byte
	EIF

.var trackn_instrx2	:TRACKS .byte
.var trackn_instrdb	:TRACKS .byte
.var trackn_instrhb	:TRACKS .byte
.var trackn_instridx	:TRACKS .byte
.var trackn_instrlen	:TRACKS .byte
.var trackn_instrlop	:TRACKS .byte
.var trackn_instrreachend	:TRACKS .byte
.var trackn_volumeslidedepth	:TRACKS .byte
.var trackn_volumeslidevalue	:TRACKS .byte

	IFT FEAT_VOLUMEMIN
	.var trackn_volumemin	:TRACKS .byte
	EIF

;FEAT_EFFECTS equ FEAT_EFFECTVIBRATO||FEAT_EFFECTFSHIFT
	IFT FEAT_EFFECTS
	.var trackn_effdelay	:TRACKS .byte
	EIF

	IFT FEAT_EFFECTVIBRATO
	.var trackn_effvibratoa	:TRACKS .byte
	EIF

	IFT FEAT_EFFECTFSHIFT
	.var trackn_effshift	:TRACKS .byte
	EIF

.var trackn_tabletypespeed	:TRACKS .byte

	IFT FEAT_TABLEMODE
	.var trackn_tablemode	:TRACKS .byte
	EIF

.var trackn_tablenote	:TRACKS .byte
.var trackn_tablea	:TRACKS .byte
.var trackn_tableend	:TRACKS .byte

	IFT FEAT_TABLEGO
	.var trackn_tablelop	:TRACKS .byte
	EIF

.var trackn_tablespeeda	:TRACKS .byte

	IFT FEAT_FILTER||FEAT_BASS16
	.var trackn_command	:TRACKS .byte
	EIF

	IFT FEAT_BASS16
	.var trackn_outnote	:TRACKS .byte
	EIF

	IFT FEAT_FILTER
	.var trackn_filter	:TRACKS .byte
	EIF

.var trackn_audf	:TRACKS .byte
.var trackn_audc	:TRACKS .byte

	IFT FEAT_AUDCTLMANUALSET
	.var trackn_audctl	:TRACKS .byte
	EIF

.var .byte v_aspeed

	IFT FEAT_CONSTANTSPEED==0
	.var .byte v_speed
	.var .byte v_bspeed
	EIF

.var .byte v_audctl
.var .byte v_audctl2

	IFT FEAT_INSTRSPEED==0
	.var .byte v_instrspeed
	EIF

.var .byte v_abeat
.var .byte v_maxtracklen

	IFT FEAT_INSTRSPEED==0||FEAT_INSTRSPEED>1
	.var .byte v_ainstrspeed
	EIF

.var .byte v_channel_number
.var .byte v_channel_number_less1

	IFT FEAT_RECALCADDR
	.var .word v_addr_delta
	EIF

track_endvariables

;	IFT FEAT_GLOBALVOLUMEFADE
;	.var .byte RMTGLOBALVOLUMEFADE
;	EIF

;	IFT FEAT_SFX
;	.var .byte RMTSFXVOLUME
;	EIF

	IFT FEAT_PATCH
	.var .byte RMTPATCH
	EIF

	IFT FEAT_RECALCADDR
	.var .word RMTORIGINALADDR
	EIF
