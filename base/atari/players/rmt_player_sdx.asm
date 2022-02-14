// Mono:
// Ja tam robiłem jakieś modyfikacje do patchowanej tabeli basów 0a i do
// playera analmuxa (sa dwa rozne).
// Odpowiada za to zmienna patch (bajt).
// 0=standard RMT 1.28
// 1=0A patch
// 2=Analmux 3 (instrumentarium)
// 3=Analmux 3R1 (instrumentarium remix 1)

;*
;* Raster Music Tracker, RMT Atari routine version 1.20090108
;* (c) Radek Sterba, Raster/C.P.U., 2002 - 2009
;* http://raster.atari.org
;
; Modified by Mono for relocation with SDX.
;*
;* Warnings:
;*
;* 1. RMT player routine needs 19 itself reserved bytes in zero page (no accessed
;*    from any other routines) as well as cca 1KB of memory before the "PLAYER"
;*    address for frequency tables and functionary variables. It's:
;*	  a) from PLAYER-$03c0 to PLAYER for stereo RMTplayer
;*    b) from PLAYER-$0320 to PLAYER for mono RMTplayer
;*
;* 2. RMT player routine MUST (!!!) be compiled from the begin of the memory page.
;*    i.e. "PLAYER" address can be $..00 only!
;*
;* 3. Because of RMTplayer provides a lot of effects, it spent a lot of CPU time.
;*
;* STEREOMODE	equ 0..3			;0 => compile RMTplayer for 4 tracks mono
;*									;1 => compile RMTplayer for 8 tracks stereo
;*									;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;*									;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4
;*
	IFT STEREOMODE==1
TRACKS		equ 8
	ELS
TRACKS		equ 4
	EIF
;*
;PLAYER		equ $3400
;*
;* RMT FEATures definitions file
;* For optimizations of RMT player routine to concrete RMT modul only!
;	icl "rmt_feat.a65"
;*
;* RMT ZeroPage addresses
	org $e0
p_tis
p_instrstable		org *+2
p_trackslbstable	org *+2
p_trackshbstable	org *+2
p_song			org *+2
ns			org *+2
nr			org *+2
nt			org *+2
reg1			org *+1
reg2			org *+1
reg3			org *+1
tmp			org *+1

;	IFT FEAT_COMMAND2
;frqaddcmd2		org *+1
;	EIF



	org PLAYER
;*
;* Set of RMT main vectors:
;*
rmt_player:
RASTERMUSICTRACKER
	jmp rmt_init
	jmp rmt_play
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

  lda patch
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
  lda tabbegtabad,y
  sta rmtbegad
  lda tabbegtabad+1,y
  sta rmtbegad+1
  lda skctltabad,y
  sta patchroutineaddr
  lda skctltabad+1,y
  sta patchroutineaddr+1
  lda patch
  cmp #2	;analmux instrumentarium patch
  bcc ?skipanalmux
  lda #$d0
  sta rmtaudctl1mask
  lda #$a8
  sta rmtaudctl2mask
  lda addr11
  sne
  dec addr11+1
  dec addr11
  lda addr12
  sne
  dec addr12+1
  dec addr12
  lda addr13
  sne
  dec addr13+1
  dec addr13
  lda addr21
  sne
  dec addr21+1
  dec addr21
  lda addr22
  sne
  dec addr22+1
  dec addr22
  lda addr23
  sne
  dec addr23+1
  dec addr23

;calc analmux instrumentarium tabs
  ldy #0
?loop:
  clc
  tya
  adc rmtoffset
  ldx patch
  cpx #3
  ldx #%00000011	;3
  bcs ?remix1

  ;analmux instrumentarium
  and #$fb
  eor #$88
  bne ?next
  beq ?sync

?remix1:
  ;analmux instrumentarium remix 1
  ora #0
  beq ?sync
  cmp #$fc
  bne ?next

?sync:
  ldx #%10001011	;$8b

?next:
  txa
  sta analmux_instrumentarium_tab,y
  iny
  bne ?loop

?skipanalmux:

	ldy #4
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
	ldy #8
ri1	lda (ns),y
	sta p_tis-8,y
	iny
	cpy #8+8
	bne ri1
	IFT FEAT_NOSTARTINGSONGLINE==0
	
;modified by mono
	lda #0
	sta rmttmp
	lda moduletype
	cmp #8
	pla
	bcc ?x4
	asl @
	rol rmttmp
?x4:
	asl @
	rol rmttmp
	asl @
	rol rmttmp
	;clc
	adc p_song
	sta p_song
	lda rmttmp
	
;	pla
;	pha
;	IFT TRACKS>4
;	asl @
;	asl @
;	asl @
;	clc
;	adc p_song
;	sta p_song
;	pla
;	php
;	and #$e0
;	asl @
;	rol @
;	rol @
;	rol @
;	ELS
;	asl @
;	asl @
;	clc
;	adc p_song
;	sta p_song
;	pla
;	php
;	and #$c0
;	asl @
;	rol @
;	rol @
;	EIF
;	plp
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
	sta trackn_db,x
	lda (p_trackshbstable),y
nn1a sta trackn_hb,x
	lda #0
	sta trackn_idx,x
	lda #1
nn1a2 sta trackn_pause,x
	lda #$80
	sta trackn_instrx2,x
	inx
;modified by mono
xtracks01	cpx moduletype	;#TRACKS
	bne nn1
	lda p_song
	clc
;modified by mono
xtracks02	adc moduletype	;#TRACKS
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
	tax
	iny
	lda (p_song),y
	sta p_song+1
	stx p_song
	ldx #0
	beq nn0
GetTrackLine
oo0
oo0a
	IFT FEAT_CONSTANTSPEED==0
	lda #$ff
v_speed equ *-1
	sta v_bspeed
	EIF
;;mono - optimize
;	ldx #0
;oo1
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
	sbc #$00
RMTGLOBALVOLUMEFADE equ *-1
	bcs voig
	lda #0
voig
	EIF
	and #$f0
	sta trackn_volume,x
oo1x
;modified by mono
xtracks03sub1:
  inx
  cpx moduletype
  php
  dex
  plp
;xtracks03sub1	cpx #TRACKS-1
	bne oo1
	IFT FEAT_CONSTANTSPEED==0
	lda #$ff
v_bspeed equ *-1
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
	lda #$f0				;* sfx note volume*16
RMTSFXVOLUME equ *-1		;* label for sfx note volume parameter overwriting
	sta trackn_volume,x
	EIF
SetUpInstrumentY2
	lda (p_instrstable),y
	sta trackn_instrdb,x
	sta nt
	iny
	lda (p_instrstable),y
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

;added by mono - analmux patch 3 - only for instrumentarium.rmt
patchroutineaddr = *+1
  jsr $ffff
  stx $d21f
  stx $d20f

	jsr SetPokey
rmt_p1
	IFT FEAT_INSTRSPEED==0||FEAT_INSTRSPEED>1
	dec v_ainstrspeed
	bne rmt_p3
	EIF
	IFT FEAT_INSTRSPEED==0
	lda #$ff
v_instrspeed	equ *-1
	sta v_ainstrspeed
	ELI FEAT_INSTRSPEED>1
	lda #FEAT_INSTRSPEED
	sta v_ainstrspeed
	EIF
rmt_p2
	dec v_aspeed
	bne rmt_p3
	inc v_abeat
	lda #$ff
v_abeat equ *-1
	cmp #$ff
v_maxtracklen equ *-1
	beq p2o3
	jmp GetTrackLine
p2o3
	jmp GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
go_ppnext	jmp ppnext
rmt_p3
  ;moved below by mono for sdx relocation
	;lda #>frqtab
	;sta nr+1
	
;modified by mono
xtracks05sub1	ldx moduletype
  dex
;xtracks05sub1	ldx #TRACKS-1
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
	
;modified by mono
	ldy moduletype
	cpy #8
	bcc ?pp2s
	cpx #4
	bcc ?pp2s
	lsr @
	lsr @
	lsr @
	lsr @
?pp2s:
;	IFT TRACKS>4
;	cpx #4
;	bcc pp2s
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;pp2s
;	EIF
	
	and #$0f
	ora trackn_volume,x
	tay
	lda volumetab,y
	sta tmp
	lda reg2
	and #$0e
	tay
	
	;modified by Mono for SDX relocation
	lda (rmtbegad),y	;tabbegad,y
	sta nr
	iny
	lda (rmtbegad),y	;tabbegad+1,y
	sta nr+1
	dey
	;lda tabbeganddistor,y
	;sta nr
	
	lda tmp
	ora (rmtdistad),y ;tabbeganddistor+1,y
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
	lsr @
	lsr @
	sta jmx+1
jmx	bcc *
	jmp cmd0
	nop
	jmp cmd1
	IFT FEAT_COMMAND2||FEAT_COMMAND3||FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	nop
	jmp cmd2
	EIF
	IFT FEAT_COMMAND3||FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	nop
	jmp cmd3
	EIF
	IFT FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	nop
	jmp cmd4
	EIF
	IFT FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	nop
	jmp cmd5
	EIF
	IFT FEAT_COMMAND6||FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	nop
	jmp cmd6
	EIF
	IFT FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	nop
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
	EIF
	lda #0
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
	EIF
	lda #0
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
addr11 = *+1
	lda trackn_command+1
	and #$0e
	cmp #6
	bne qq4
addr12 = *+1
	lda trackn_audc+1
	and #$0f
	beq qq4
addr13 = *+1
	ldy trackn_outnote+1
	lda (rmtfrqload),y	;frqtabbasslo,y
	sta trackn_audf+0
	lda (rmtfrqhiad),y	;frqtabbasshi,y
	sta trackn_audf+1
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0L
	lda trackn_audc+0
	and #$10
	bne qq3a
	EIF

;mono - analmux instrumentarium patch
  lda patch
  cmp #2
  bcs qq3a

	lda #0
	sta trackn_audc+0
qq3a
	txa
rmtaudctl1mask = *+1
      ora #$50	;$d0 u analmuxa
	tax
	EIF
qq4
	IFT FEAT_BASS16G3L
addr21 = *+1
	lda trackn_command+3
	and #$0e
	cmp #6
	bne qq5
addr22 = *+1
	lda trackn_audc+3
	and #$0f
	beq qq5
addr23 = *+1
	ldy trackn_outnote+3
	lda (rmtfrqload),y	;frqtabbasslo,y
	sta trackn_audf+2
	lda (rmtfrqhiad),y	;frqtabbasshi,y
	sta trackn_audf+3
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq4a
	EIF

;mono - analmux instrumentarium patch
  lda patch
  cmp #2
  bcs qq4a

	lda #0
	sta trackn_audc+2
qq4a
	txa
rmtaudctl2mask = *+1
      ora #$28	;$a8 u analmuxa
	tax
	EIF
	EIF
qq5
	stx v_audctl
	
	;modified by mono
	lda moduletype
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
    EIF ;FEAT_AUDCTLMANUALSET
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
        EIF ;FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
      lda #0
      sta trackn_audc+2+4
qs1a
      txa
      ora #4
      tax
      EIF ;FEAT_FILTERG0R
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
        EIF ;FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3R
      lda #0
      sta trackn_audc+3+4
qs2a
      txa
      ora #2
      tax
      EIF ;FEAT_FILTERG1R
qs3
      IFT FEAT_FILTERG0R||FEAT_FILTERG1R
      cpx v_audctl2
      bne qs5
      EIF ;FEAT_FILTERG0R||FEAT_FILTERG1R
    EIF ;FEAT_FILTER
    
    IFT FEAT_BASS16
      IFT FEAT_BASS16G1R
;addr11 = *+1
      lda trackn_command+1+4	;+0+4 u analmuxa
      and #$0e
      cmp #6
      bne qs4
;addr12 = *+1
      lda trackn_audc+1+4	;+0+4 u analmuxa
      and #$0f
      beq qs4
;addr13 = *+1
      ldy trackn_outnote+1+4	;+0+4 u analmuxa
      lda (rmtfrqload),y	;frqtabbasslo,y
      sta trackn_audf+0+4
      lda (rmtfrqhiad),y	;frqtabbasshi,y
      sta trackn_audf+1+4
        IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0R
        lda trackn_audc+0+4
        and #$10
        bne qs3a
        EIF

;;mono - analmux instrumentarium patch
;  lda patch
;  cmp #2
;  bcs qs3a

      lda #0
      sta trackn_audc+0+4
qs3a
      txa
;rmtaudctl1mask = *+1
      ora #$50	;$d0 u analmuxa
      tax
      EIF
qs4
      IFT FEAT_BASS16G3R
;addr21 = *+1
      lda trackn_command+3+4	;+2+4 u analmuxa
      and #$0e
      cmp #6
      bne qs5
;addr22 = *+1
      lda trackn_audc+3+4	;+2+4 u analmuxa
      and #$0f
      beq qs5
;addr23 = *+1
      ldy trackn_outnote+3+4	;+2+4 u analmuxa
      lda (rmtfrqload),y	;frqtabbasslo,y
      sta trackn_audf+2+4
      lda (rmtfrqhiad),y	;frqtabbasshi,y
      sta trackn_audf+3+4
        IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
        lda trackn_audc+2+4
        and #$10
        bne qs4a
        EIF

;;mono - analmux instrumentarium patch
;  lda patch
;  cmp #2
;  bcs qs4a

      lda #0
      sta trackn_audc+2+4
qs4a
      txa
;rmtaudctl2mask = *+1
      ora #$28	;$a8 u analmuxa
      tax
      EIF
    EIF
qs5
	stx v_audctl2
	;EIF
rmt_p5
	IFT FEAT_INSTRSPEED==0||FEAT_INSTRSPEED>1
	lda #$ff
v_ainstrspeed equ *-1
	ELS
	lda #1
	EIF
	rts
SetPokey

	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	
	lda #$ff
v_audctl equ *-1
	ldy #$ff
v_audctl2 equ *-1
  ;added by mono
  ldx moduletype
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
	ldy #$ff
v_audctl equ *-1
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
	ldy #$ff
v_audctl equ *-1
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
	ldy #$ff
v_audctl equ *-1
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




;dodatkowe procedury dla instrumentarium i instrumentarium remix1 analmuxa

standard_skctl:
  ldx #%00000011
  rts

analmux_instrumentarium_skctl:
  ldy p_song	;$d1
  ldx analmux_instrumentarium_tab,y
  rts




		;org PLAYER-$100-$140-$40+2
;INSTRPAR	equ 12
;modified by Mono for SDX relocation
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
 .byte $00,$ff
 .byte $20,$ff
 .byte $40,$ff
 .byte $c0,$ff
 .byte $80,$ff
 .byte $a0,$ff
 .byte $c0,$ff
 .byte $c0,$ff

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

;modified by mono for sdx relocation

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
		;org PLAYER-$100-$140
	IFT FEAT_BASS16
frqtabbasslo
	.byte $F2,$33,$96,$E2,$38,$8C,$00,$6A,$E8,$6A,$EF,$80,$08,$AE,$46,$E6
	.byte $95,$41,$F6,$B0,$6E,$30,$F6,$BB,$84,$52,$22,$F4,$C8,$A0,$7A,$55
	.byte $34,$14,$F5,$D8,$BD,$A4,$8D,$77,$60,$4E,$38,$27,$15,$06,$F7,$E8
	.byte $DB,$CF,$C3,$B8,$AC,$A2,$9A,$90,$88,$7F,$78,$70,$6A,$64,$5E,$00
	EIF
		;org PLAYER-$100-$100
frqtab
	;ERT [<frqtab]!=0	;* frqtab must begin at the memory page bound! (i.e. $..00 address)
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
	IFT FEAT_BASS16
frqtabbasshi
	.byte $0D,$0D,$0C,$0B,$0B,$0A,$0A,$09,$08,$08,$07,$07,$07,$06,$06,$05
	.byte $05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02
	.byte $02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	EIF


;tablice do instrumentarium analmuxa (patch3)
;$80,$00
;$00,$20
;$40,$A0
;$00,$80
;$80,$80
;$80,$A0
;$00,$C0
;$40,$C0

analmux_tabbegad:
 .word frqtabpure
 .word analmux_frqtabbass1
 .word analmux_frqtabbass2
 .word analmux_frqtabbass1
 .word frqtabpure
 .word frqtabpure
 .word analmux_frqtabbass1
 .word analmux_frqtabbass2

analmux_tabdistor:
	.byte   $00,$ff
	.byte   $20,$ff
	.byte	$A0,$ff
	.byte	$80,$ff
        .byte   $80,$ff
	.byte	$A0,$ff
	.byte	$C0,$ff
	.byte	$C0,$ff

	IFT FEAT_BASS16
analmux_frqtabbasslo:
	.byte   $8D,$93,$99,$9E,$A3,$A8,$AD,$B1
        .byte   $B5,$B9,$BD,$C0,$C3,$C7,$C9,$CC
        .byte   $CF,$D1,$D3,$D6,$D8,$DA,$DB,$DD
        .byte   $DF,$E0,$E2,$E3,$E4,$E6,$E7,$E8
        .byte   $E9,$EA,$EB,$EC,$EC,$ED,$EE,$EF
        .byte   $EF,$F0,$F0,$F1,$F1,$F2,$F2,$F3
        .byte   $F3,$F4,$F4,$F4,$F5,$F5,$F5,$F5
        .byte   $F6,$F6,$F6,$F6,$F7,$F7,$F7,$F7
	EIF

analmux_frqtabbass1:
        .byte   $DC,$CF,$C4,$B8,$AE,$A4,$9A,$92
        .byte   $89,$81,$7A,$73,$6C,$66,$60,$5A
        .byte   $55,$50,$4B,$47,$43,$3F,$3B,$37
        .byte   $34,$31,$2E,$2B,$28,$26,$24,$21
        .byte   $1F,$1D,$1C,$1A,$18,$16,$15,$14
        .byte   $12,$11,$10,$0F,$0E,$0D,$0C,$0B
        .byte   $0A,$09,$08,$08,$07,$06,$06,$05
        .byte   $05,$04,$04,$03,$03,$03,$02,$02

analmux_frqtabbass2:
        .byte   $71,$6E,$6B,$68,$65,$62,$5F,$5C
        .byte   $59,$56,$54,$51,$4F,$4D,$4A,$48
        .byte   $46,$44,$42,$40,$3E,$3C,$3A,$38
        .byte   $36,$35,$33,$32,$30,$2F,$2D,$2C
        .byte   $2A,$29,$28,$26,$25,$24,$23,$22
        .byte   $21,$20,$1F,$1E,$1D,$1C,$1B,$1A
        .byte   $19,$18,$17,$17,$16,$15,$14,$14
        .byte   $13,$12,$12,$11,$10,$10,$0F,$0F

	IFT FEAT_BASS16
analmux_frqtabbasshi:
	.byte   $D9,$CD,$C1,$B7,$AD,$A3,$99,$91
        .byte   $89,$81,$79,$73,$6B,$65,$61,$5B
        .byte   $55,$51,$4D,$47,$43,$3F,$3D,$39
        .byte   $35,$33,$2F,$2D,$2B,$27,$25,$23
        .byte   $21,$1F,$1D,$1B,$1B,$19,$17,$15
        .byte   $15,$13,$13,$11,$11,$0F,$0F,$0D
        .byte   $0D,$0B,$0B,$0B,$09,$09,$09,$09
        .byte   $07,$07,$07,$07,$05,$05,$05,$05
	EIF



;tablice mikera do patcha 0a (16-bit bass A0)
miker_tabdistor:
	.byte $00,$ff
	.byte $20,$ff
	.byte $40,$ff
	.byte $a0,$ff
	.byte $80,$ff
	.byte $a0,$ff
	.byte $c0,$ff
	.byte $c0,$ff

	IFT FEAT_BASS16
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


skctltabad:
	.word standard_skctl
	.word standard_skctl
	.word analmux_instrumentarium_skctl
	.word analmux_instrumentarium_skctl

tabbegtabad:
	.word tabbegad
	.word tabbegad
	.word analmux_tabbegad
	.word analmux_tabbegad

tabdistortabad:
	.word tabdistor
	.word miker_tabdistor
	.word analmux_tabdistor
	.word analmux_tabdistor

	IFT FEAT_BASS16
basslotabad:
	.word frqtabbasslo
	.word miker_frqtabbasslo
	.word analmux_frqtabbasslo
	.word analmux_frqtabbasslo

basshitabad:
	.word frqtabbasshi
	.word miker_frqtabbasshi
	.word analmux_frqtabbasshi
	.word analmux_frqtabbasshi
	EIF


		;org PLAYER-$0100
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
	

	;IFT TRACKS>4
	;org PLAYER-$400+$40
	;ELS
	;org PLAYER-$400+$e0
	;EIF
track_variables
trackn_db	.ds TRACKS
trackn_hb	.ds TRACKS
trackn_idx	.ds TRACKS
trackn_pause	.ds TRACKS
trackn_note	.ds TRACKS
trackn_volume	.ds TRACKS
trackn_distor 	.ds TRACKS
trackn_shiftfrq	.ds TRACKS
	IFT FEAT_PORTAMENTO
trackn_portafrqc .ds TRACKS
trackn_portafrqa .ds TRACKS
trackn_portaspeed .ds TRACKS
trackn_portaspeeda .ds TRACKS
trackn_portadepth .ds TRACKS
	EIF
trackn_instrx2	.ds TRACKS
trackn_instrdb	.ds TRACKS
trackn_instrhb	.ds TRACKS
trackn_instridx	.ds TRACKS
trackn_instrlen	.ds TRACKS
trackn_instrlop	.ds TRACKS
trackn_instrreachend	.ds TRACKS
trackn_volumeslidedepth .ds TRACKS
trackn_volumeslidevalue .ds TRACKS
	IFT FEAT_VOLUMEMIN
trackn_volumemin		.ds TRACKS
	EIF
;FEAT_EFFECTS equ FEAT_EFFECTVIBRATO||FEAT_EFFECTFSHIFT
	IFT FEAT_EFFECTS
trackn_effdelay			.ds TRACKS
	EIF
	IFT FEAT_EFFECTVIBRATO
trackn_effvibratoa		.ds TRACKS
	EIF
	IFT FEAT_EFFECTFSHIFT
trackn_effshift		.ds TRACKS
	EIF
trackn_tabletypespeed .ds TRACKS
	IFT FEAT_TABLEMODE
trackn_tablemode	.ds TRACKS
	EIF
trackn_tablenote	.ds TRACKS
trackn_tablea		.ds TRACKS
trackn_tableend		.ds TRACKS
	IFT FEAT_TABLEGO
trackn_tablelop		.ds TRACKS
	EIF
trackn_tablespeeda	.ds TRACKS
	IFT FEAT_FILTER||FEAT_BASS16
trackn_command		.ds TRACKS
	EIF
	IFT FEAT_BASS16
trackn_outnote		.ds TRACKS
	EIF
	IFT FEAT_FILTER
trackn_filter		.ds TRACKS
	EIF
trackn_audf	.ds TRACKS
trackn_audc	.ds TRACKS
	IFT FEAT_AUDCTLMANUALSET
trackn_audctl	.ds TRACKS
	EIF
v_aspeed		.ds 1
track_endvariables

;tablica wartosci SKCTL dla instrumentarium analmuxa
analmux_instrumentarium_tab .ds $100

