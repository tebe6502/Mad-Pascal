;* Mad Pascal version -> resource RMTPLAYV
;*
;* Raster Music Tracker, RMT Atari routine version Patch16-3.2
;* (c) Radek Sterba, Raster/C.P.U., 2002 - 2009
;* http://raster.atari.org
;*
;* Unofficial version by VinsCool, 2021 - 2022
;* https://github.com/VinsCool/RMT-Patch16
;*
;* TO DO: A lot... So much to re-order and cleanup...
;* I must recalculate everything, once the full code cleanup and optimisation is done.
;* Currently, all infos are incorrect due to the massive amount of changes I have done into the code.
;* I apologise for the inconvenience, I am doing my best to clean everything to make sense again.
;*

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* RMT FEATures definitions file

;	icl "rmt_feat.a65"
	
;* For optimizations of RMT player routine to concrete RMT module only!

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of RMT definitions...

;	IFT FEAT_IS_SIMPLEP
;PLAYER			equ $3100	; VUPlayer export driver 
;	ELS
;PLAYER			equ $3400	; tracker.obx driver and everything else by default
;	EIF

	IFT STEREOMODE==1
TRACKS			equ 8
	ELS
TRACKS			equ 4
	EIF

//TABLES			equ $B000	; This may be moved elsewhere if necessary 

INSTRPAR		equ 12

;* RMT ZeroPage addresses
;	org $e0	     	;* org $CB
;	.ZPVAR = $e0
	
p_tis = .ZPVAR

.ZPVAR ptrInstrumentTbl	.word			; ptr to Instrument table ptrs
.ZPVAR ptrTracksTblLo	.word			; ptr to low byte of track ptrs
.ZPVAR ptrTracksTblHi	.word			; ptr to high byte of track ptrs
.ZPVAR ptrSongLines	.word			; ptr to song data
.ZPVAR ns		.word
.ZPVAR nr		.word
.ZPVAR nt		.word
.ZPVAR reg1		.byte
.ZPVAR reg2		.byte
.ZPVAR reg3		.byte
.ZPVAR tmp		.byte

	IFT FEAT_COMMAND2
.ZPVAR frqaddcmd2	.byte
	EIF
	
;* possible improvement: setting variables after the RMT driver itself? 
;* That would make adjustments easier to manage, if this works as I expect...

;	IFT TRACKS>4			
;	org PLAYER-$400+$40
;	ELS
;	org PLAYER-$400+$e0
;	EIF
	

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of RMT jump table...

;        org PLAYER			;* Possible improvement: give proper labels to each JMPs below... to avoid confusion, and also make things easier to map in memory, unless the destination is being JSR'ed directly...

RASTERMUSICTRACKER
	jmp rmt_play			;* One play each subroutine call. SetPokey is executed first, then all the play code is ran once, until the RTS. rmt_play could be called multiple times per frame if wanted.

	jmp rmt_init			;* Must be run first, to clear memory and initialise the player... Once this is done, run rmt_play afterwards, or Set_Pokey if you want to manually time certain things.
	jmp rmt_p3				;* Similar to rmt_play, but will also skip SetPokey and the instruments/songlines/tracklines initialisation, very useful for playing simple things.
	jmp rmt_silence			;* Run this to stop the driver, and reset all POKEY registers to 0. This is also part of rmt_init when it is executed first.
	jmp SetPokey			;* Run to copy the contents of the Shadow POKEY registers (v_audctl, v_skctl, trackn_audf,x etc) into the real ones. Will be run first each time rmt_play is called.
	IFT FEAT_SFX
	jmp rmt_sfx				;* A=note(0,..,60),X=channel(0,..,3 or 0,..,7),Y=instrument*2(0,2,4,..,126)
	EIF
	
;* end of RMT jump table... from here, all the main driver code is being executed, have fun playing around! ;)

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of rmt_init code...
; A = Starting song line
; X = low byte of the RMT module
; Y = hi byte of the RMT module
rmt_init
	; (ns) -> module data
	stx ns
	sty ns+1
	IFT FEAT_NOSTARTINGSONGLINE==0
		pha	; backup the song line into the stack for now... I wonder if I could just use tmp in zeropage instead...
	EIF
	
	; Clear the RMT variables
	IFT track_endvariables-track_variables>255
		; more than 255 bytes in variables memory...
		; so clear from the front and 256 bytes from the end |>--->----|
		ldy #0
		tya
ri_clear_loop	
		sta track_variables,y
		sta track_endvariables-$100,y
		iny
		bne ri_clear_loop
	ELS
		; Clear from the back  |----<|
		ldy #track_endvariables-track_variables	; How many bytes to clear
		lda #0
ri_clear_loop	
		sta track_variables-1,y
		dey
		bne ri_clear_loop
	EIF
	
	; Parse the RMT module data
	; Track length: +4
	ldy #4
	lda (ns),y
	sta smc_maxtracklen				; Change the code to store the track length

	; Song speed: +5
	iny
	IFT FEAT_CONSTANTSPEED==0
		lda (ns),y
		sta smc_speed				; Change the code to store the song speed
	EIF
	
	; Instrument speed: +6
	IFT FEAT_INSTRSPEED==0
		iny
		lda (ns),y
		sta smc_instrspeed			; Change the code to store the instrument speed
		sta smc_silence_instrspeed
	ELI FEAT_INSTRSPEED>1
		lda #FEAT_INSTRSPEED
		sta smc_silence_instrspeed
	EIF

	; Copy 4 pointers: +8
	; -> InstrumentPtrs[] 	2 bytes
	; -> TracksPtrsLow[]	2 bytes
	; -> TracksPtrsHi		2 bytes
	; -> SongData			2 bytes
	ldy #8
ri_copy_loop	
	lda (ns),y
	sta p_tis-8,y
	iny
	cpy #8+8						; loop until y is 16
	bne ri_copy_loop

	IFT FEAT_NOSTARTINGSONGLINE==0
		; Set the starting song line by moving ptrSongLines forward
		pla							; Get the saved starting song line
		pha
		IFT TRACKS>4
			; Stereo
			; ptrSongLines += song_line * 8
			asl @					; offset * 8
			asl @
			asl @
			clc
			adc ptrSongLines				; ptrSongLines += offset * 8 (low) part
			sta ptrSongLines
			pla						; restore offset, but keep carry bit
			php						; store flags on stack (carry bit!)
			and #$e0
			asl @
			rol @
			rol @
			rol @
		ELS
			; Mono
			; ptrSongLines += song_line * 4
			asl @
			asl @
			clc
			adc ptrSongLines
			sta ptrSongLines
			pla
			php
			and #$c0
			asl @
			rol @
			rol @
		EIF
		plp							; restore the carry bit
		adc ptrSongLines+1
		sta ptrSongLines+1
	EIF
	jsr GetSongLine					; Setup the first song line
	
;* end of rmt_init code... rmt_silence will always be executed after the JSR above.

;---------------------------------------------------------------------------------------------------------------------------------------------;
	
; RMT_SILENCE
; Reset POKEY causes all sound to be stopped
	
rmt_silence
	; Reset POKEY
	IFT STEREOMODE>0
		lda #0
		sta $d208			; AUDCTL
		sta $d218
		ldy #3
		sty $d20f			; SKCTL
		sty $d21f
		; Clear AUDFx & AUDCx
		ldy #8
silence_loop	
		sta $d200,y
		sta $d210,y
		dey
		bpl silence_loop
	ELS
		lda #0
		sta $d208
		ldy #3
		sty $d20f
		ldy #8
silence_loop	
		sta $d200,y	
		dey
		bpl silence_loop
	EIF
	
	IFT FEAT_IS_TRACKER 		; reset the tables pointers 
	lda #<frqtabsawtooth_ch1	; reset the Sawtooth table inversion
	sta saw_ch1
	lda #<frqtabsawtooth_ch3
	sta saw_ch3	
	lda #$0A			; reset the Distortion 6 16-bit pointer
	sta bass16_pointer 
	lda #3				; reset the SKCTL state to normal
	sta v_skctl
	sta v_skctl2	
	EIF	

	IFT FEAT_INSTRSPEED==0
		lda #$ff
smc_silence_instrspeed equ *-1			; return instrument speed, does not seem to matter after rmt_init?
	ELS
		lda #FEAT_INSTRSPEED
	EIF
	rts
	
;* end of rmt_silence code...
	
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* start of mainloop code here... most of it is related to the songlines, tracklines and instruments initialisation...
	
GetSongLine
	ldx #0
	stx smc_abeat						; set the pattern row to 0 for the new songline... This could be exploited with an effect command related to premature pattern end, or pattern goto...
gsl_continueProcessing
	IFT FEAT_IS_SIMPLEP
		IFT EXPORTXEX					; Simple RMT Player hack for colour cycling, change the rasterbar colour every new pattern played
			lda loop+1				; the #RASTERBAR colour defined will be loaded there specifically
			add #16					; offset the value by #$10 for a simple colour shuffle
			sta loop+1   				; store back where it was loaded, overwriting the previous value
			lda ptrSongLines			; calculate the songline position below, this is done once every new songline
			sub MODUL+14 				; TODO: relocate this code elsewhere, so toggling it would be easier
			sta v_ord 
			lda ptrSongLines+1
			sbc MODUL+15
			lsr @
			ror v_ord
			lsr @
			ror v_ord
			IFT TRACKS>4
				lsr @
				ror v_ord
			EIF 
		EIF 
	EIF
	
gsl_nextSongLine	
	txa								; A = X = Y = 0,1,2,3
	tay
	lda (ptrSongLines),y			; Get track info from the songline[y]
	cmp #$fe				; #$FE = Goto songline, #$FF = Empty track
	bcs gsl_GotoOrEmpty			; if A >= $FE --> gsl_GotoOrEmpty
	; (A) = Real track #
	; Get the ptr to the track data and store it in ptrTracksTblLo
	tay
	lda (ptrTracksTblLo),y			; trackn_TblLo[x] = ptrTracksTblLo[y]
	sta trackn_TblLo,x
	lda (ptrTracksTblHi),y			; trackn_TblHi[x] = ptrTracksTblHi[y]
	sta trackn_TblHi,x

	lda #0
	sta trackn_idx,x			; reset the track index to 0 trackn_idx[x] = 0

	lda #1
gsl_initTrack 	
	sta trackn_pause,x			; #1 is a new track, #0 is no new track
	lda #$80				; Mark that there is no new instrument
	sta trackn_instrx2,x			; #$80 is negative, will BMI when encountered, meaning no new instrument initialisation
	inx								; ++x
	cpx #TRACKS				; if x < TRACKS --> gsl_nextSongLine
	bne gsl_nextSongLine

	; Done with data points of a song line, move to the next line
	lda ptrSongLines			; ptrSontLines += #TRACKS (4 or 8)
	clc	
	adc #TRACKS
	sta ptrSongLines
	bcc GetTrackLine
	inc ptrSongLines+1
	
	jmp GetTrackLine			; Now progress the notes in a track

gsl_GotoOrEmpty
	beq gsl_thisIsAGoto			; branch if equal to #$FE, this is a Goto songline command

	lda #0							; Used to set the instrument to 0, meaning no new track
	beq gsl_initTrack			; unconditional

gsl_thisIsAGoto
	; Data format: 0xFE, 0x00, low, high bytes of ptr to next song line
	ldy #2
	lda (ptrSongLines),y			; lo = ptrSongLines[2]
	tax
	iny
	lda (ptrSongLines),y			; hi = ptrSongLinex[3]
	sta ptrSongLines+1
	stx ptrSongLines				; (ptrSongLines) = ptrSongLines[2,3]
	ldx #0
	beq gsl_continueProcessing

; Process one line of a track
GetTrackLine
	IFT FEAT_CONSTANTSPEED==0
		lda #$ff					; This value is changed by the code
smc_speed equ *-1					; ptr to #$ff location in the code
		sta smc_bspeed
	EIF
	ldx #$ff						;-1 track data index
gtl_loopTracks
	inx								; 0,1, .. #TRACKS
	dec trackn_pause,x				; --trackn_pause[x]
	bne gtl_checkEndOfLoop			; if trackn_pause[x] != 0 --> gtl_checkEndOfLoop

	; Setup ptr to track data
	lda trackn_TblLo,x				; (ns) = trackn_TblLo/hi[x]
	sta ns
	lda trackn_TblHi,x
	sta ns+1
oo1i
	ldy trackn_idx,x				; Y = index into track data
	inc trackn_idx,x				; ++trackn_idx[x]
	; Get a track data point
	; 0 - 60 = Note, instr and volume data
	; 61 - Volume only
	; 62 = Pause/empty line
	; 63 - Speed, go loop or end
	lda (ns),y						; reg1 = A = ns[y]
	sta reg1
	and #$3f						; 0-63
	cmp #61							; 61 = Volume only
	beq gtl_ProcessVolumeData
	bcs gtl_Is62or63
	; Not a command so store the note
	sta trackn_note,x				; note[x] = data & 0x3f

	; Process the instrument #
	iny
	lda (ns),y						; instr = (data & 0xfc) >> 1
	lsr
	and #$3f*2
	sta trackn_instrx2,x			; trackn_instrx2[x] = instrument # * 2

gtl_ProcessVolumeData
	lda #1
	sta trackn_pause,x				; got a note

	; Get the volume
	ldy trackn_idx,x				; y = track index
	inc trackn_idx,x				; move to the next data point in the track
	lda (ns),y
	lsr
	ror reg1
	lsr
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
gtl_checkEndOfLoop	
	cpx #TRACKS-1
	bne gtl_loopTracks

	IFT FEAT_CONSTANTSPEED==0
		lda #$ff					; This value is changed by the code
smc_bspeed equ *-1					; ptr to #$ff location in the code
		sta smc_speed
	ELS
		lda #FEAT_CONSTANTSPEED
	EIF
	sta v_aspeed
	jmp InitOfNewSetInstrumentsOnly
	
gtl_Is62or63
	cmp #63
	beq oo63
	lda reg1
	and #$c0
	beq oo62_b
	asl @
	rol @
	rol @
	sta trackn_pause,x
	jmp gtl_checkEndOfLoop
oo62_b
	iny
	lda (ns),y
	sta trackn_pause,x
	inc trackn_idx,x
	jmp gtl_checkEndOfLoop
oo63
	lda reg1
	IFT FEAT_CONSTANTSPEED==0
		bmi oo63_1X
		iny
		lda (ns),y
		sta smc_bspeed				; Set the song speed
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
	
p2xrmtp3	
	jmp rmt_p3
p2x0 	
	dex
	bmi p2xrmtp3
	
InitOfNewSetInstrumentsOnly
p2x1 	
	ldy trackn_instrx2,x
	bmi p2x0		; if negative, there is no new instrument to initialise for this channel
	
;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of RMT_SFX code...
	
	IFT FEAT_SFX
	jsr SetUpInstrumentY2
	jmp p2x0
rmt_sfx
	sta trackn_note,x
	lda RMTSFXVOLUME:: #$f0		;* sfx note volume*16
	sta trackn_volume,x
	EIF
	
;* end of RMT_SFX code...

;---------------------------------------------------------------------------------------------------------------------------------------------;
	
SetUpInstrumentY2
	lda (ptrInstrumentTbl),y
	sta trackn_instrdb,x
	sta nt
	iny
	lda (ptrInstrumentTbl),y
	sta trackn_instrhb,x
	sta nt+1
	
	IFT FEAT_FILTER
;		lda #1
	lda #0			;* EXPERIMENTAL approach for more precise manipulation of the PWM
	sta trackn_filter,x	; set the offset value to 0 on new notes always
	ora #1			; the value of 1 is expected here, so just provide it I guess
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
	IFT FEAT_TABLE_MANUAL	; Manual tuning table loaded from instruments, based on the unused 12th byte, this is not yet fully implemented into RMT
	ldy #11
	lda (nt),y
	sta trackn_pointertable,x	
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

	IFT FEAT_SFX||FEAT_IS_TRACKER
	rts 			
;* a rts is mandatory for the 'tracker.obx' binary, else a lot of things break in RMT! 
;* look inside 'rmtextra.a65' for the exclusive tracker.obx code
	ELS
	jmp p2x0		; go process the next channel's instrument
	EIF

;---------------------------------------------------------------------------------------------------------------------------------------------;

rmt_play
rmt_p0
	jsr SetPokey
	
rmt_p1
	IFT FEAT_INSTRSPEED==0||FEAT_INSTRSPEED>1
		dec smc_silence_instrspeed
		bne rmt_p3
	EIF
	IFT FEAT_INSTRSPEED==0
		lda #$ff
smc_instrspeed	equ *-1				; ptr to #$ff location in the code
		sta smc_silence_instrspeed
	ELI FEAT_INSTRSPEED>1
		lda #FEAT_INSTRSPEED
		sta smc_silence_instrspeed
	EIF
	
rmt_p2
	dec v_aspeed
	bne rmt_p3
	inc smc_abeat					; ++smc_abeat
	lda #$ff						; if (smc_abeat == smc_maxtracklen) GetSongLine else GetTrackLine
smc_abeat equ *-1					; smc_abeat is the index into the track
	cmp #$ff
smc_maxtracklen equ *-1
	beq p2o3
	jmp GetTrackLine
p2o3
	jmp GetSongLine

rmt_p3	
	ldx #TRACKS-1

;*
;* Aggressive initialisation every new player call here, the method was originally done to get the AUDCTL early, but many things can be exploited here the same way.
;* Combining the aggressive init and rmt_p3 in 1 thing, this is now an even more aggressive approach! 
;*
;* POSSIBLE IMPROVEMENT: process ALL effect commands here instead... Meaning there won't be workarounds necessary later, for several commands.
;* Example: Get AUDCTL early, get Effect values early, process instrument accordingly afterwards.
;* Doing certain things in a different order might drastically speed up several parts that end up being redundant or even overwritten later during certain effects like AUTOFILTER or BASS16.
;* Let's say, process 16-bit here... in such case, there won't be anything stopping the player to know it can safely skip a channel's instrument if it was going to be overwritten anyway...
;* This is purely speculation, however, so what is done here currently does the job, at least. This is still very different from the original RMT driver code as it is.
;* 
	
dodex	
	lda trackn_instrhb,x
	beq dexnext			; process the next channel's bytes immediately if empty
	sta ns+1
	lda trackn_instrdb,x
	sta ns
	ldy trackn_instridx,x
	lda (ns),y			; volume byte	
	sta trackn_volumeenvelope,x	; sta reg1
	iny
	lda (ns),y			; command and distortion byte
	sta trackn_command,x		; sta reg2
	iny
	lda (ns),y			; $XY parameter byte
	sta trackn_effectparameter,x	; sta reg3
	iny
	tya
	cmp trackn_instrlen,x
	bcc dodex_a
	beq dodex_a
	lda #$80
	sta trackn_instrreachend,x
	lda trackn_instrlop,x
dodex_a
	sta trackn_instridx,x

	IFT FEAT_AUDCTLMANUALSET&&FEAT_COMMAND7		; POSSIBLE IMPROVEMENT: process the Two-Tone Filter commands here instead, leaving CMD7 only useful for Volume Only checks later
dex_cmd7	
		lda trackn_command,x
		and #$70					; clear distortion and other bits
		cmp #$70 					; command 7? 
		bne dexnext					; skip if not equal
		lda trackn_effectparameter,x	
dex_xy
		cmp #$FD					; failsafe -> Volume Only Mode or SKCTL toggle 
		bcs dexnext					; skip if above or equal #$FD 
		sta trackn_audctl,x			; overwrite the previous value	
	EIF
	
dexnext
	dex
	bpl dodex			; continue until x is negative
	
;* FORCE ALL INSTRUMENTS TO USE THE SAME AUDCTL TO NOT OVERLAP IN PRIORITY-- DOESNT WORK LIKE THAT FUCK, HOW COULD I FORCE A AUDCTL CLEAR ON A CHANNEL ABOVE ONE I AM USING?
;* Ideally... what would be even better is to have a global effect channel... y'know, like a music tracker? That could also be useful for setting certain global values like tempo, note offset, etc 	

pp0	

;* get AUDCTL as early as possible, properly this time!

	IFT FEAT_AUDCTLMANUALSET
		lda trackn_audctl+0
		ora trackn_audctl+1
		ora trackn_audctl+2
		ora trackn_audctl+3
		sta v_audctl
	
		;* Assign flags early here as soon as possible 
		
		IFT FEAT_FULL_16BIT||FEAT_BASS16||FEAT_FULL_SAWTOOTH 
			tay				; backup the now combined audctl for the flags attribution 
			and #1				; 64khz == 0, 15khz == 1 always, the other flags will then take priority over this
			sta g_flag+0			; ch1
			sta g_flag+1			; ch2
			sta g_flag+2			; ch3
			sta g_flag+3			; ch4
			tya				; get the AUDCTL back for the BIT tests below 
pp0_a	
			bit CH1_179
			beq pp0_d			; BNE => 1.79mhz, BEQ => Nothing, skip the next BIT test 	
			bit JOIN_12
			bne pp0_b			; BNE => 16-bit, BEQ => 1.79mhz 
			ldx #$40			; 1.79mhz pointer
			bne pp0_c			; unconditional 
pp0_b
			ldx #$80			; 16-bit pointer
			stx g_flag+1			; flag set in ch2
			dex				; #$80 becomes #$7F
pp0_c		
			stx g_flag+0			; flag set in ch1
pp0_d 
			bit CH3_179 
			beq pp0_g			; BNE => 1.79mhz, BEQ => Nothing, skip the next BIT test 
			bit JOIN_34
			bne pp0_e			; BNE => 16-bit, BEQ => 1.79mhz 
			ldx #$40			; 1.79mhz pointer
			bne pp0_f			; unconditional 
pp0_e
			ldx #$80			; 16-bit pointer
			stx g_flag+3			; flag set in ch4 
			dex				; #$80 becomes #$7F 
pp0_f		
			stx g_flag+2			; flag set in ch3 
pp0_g 
		EIF
	
		IFT TRACKS>4			; Stereo 
			lda trackn_audctl+4
			ora trackn_audctl+5
			ora trackn_audctl+6
			ora trackn_audctl+7
			sta v_audctl2

			IFT FEAT_FULL_16BIT||FEAT_BASS16||FEAT_FULL_SAWTOOTH 
				tay				; backup the now combined audctl for the flags attribution 
				and #1				; 64khz == 0, 15khz == 1 always, the other flags will then take priority over this
				sta g_flag+0+4			; ch1
				sta g_flag+1+4			; ch2
				sta g_flag+2+4			; ch3
				sta g_flag+3+4			; ch4
				tya				; get the AUDCTL back for the BIT tests below 
pp0_h	
				bit CH1_179
				beq pp0_k			; BNE => 1.79mhz, BEQ => Nothing, skip the next BIT test 	
				bit JOIN_12
				bne pp0_i			; BNE => 16-bit, BEQ => 1.79mhz 
				ldx #$40			; 1.79mhz pointer
				bne pp0_j			; unconditional 
pp0_i
				ldx #$80			; 16-bit pointer
				stx g_flag+1+4			; flag set in ch2
				dex				; #$80 becomes #$7F
pp0_j		
				stx g_flag+0+4			; flag set in ch1
pp0_k 
				bit CH3_179 
				beq pp0_n			; BNE => 1.79mhz, BEQ => Nothing, skip the next BIT test 
				bit JOIN_34
				bne pp0_l			; BNE => 16-bit, BEQ => 1.79mhz 
				ldx #$40			; 1.79mhz pointer
				bne pp0_m			; unconditional 
pp0_l
				ldx #$80			; 16-bit pointer
				stx g_flag+3+4			; flag set in ch4 
				dex				; #$80 becomes #$7F 
pp0_m		
				stx g_flag+2+4			; flag set in ch3 
pp0_n 
			EIF	
		EIF
	ELS
		lda #0
		sta v_audctl
		IFT TRACKS>4
			sta v_audctl2
		EIF
	EIF

pp0_o
	ldx #TRACKS-1			; must get the tracks value again before the next part

pp1					; copying the values to the zeropage to make things faster... but not all bytes need this...

;* OPTIMISATION: reg1 is now free to use for a different purpose! 

	lda trackn_instrhb,x
	bne pp1_b			; continue if not equal 
	jmp ppnext			; skip this channel and process the next one
pp1_b
	lda g_flag,x			; AUDCTL flags
	sta reg1			; backup to the zeropage for quicker accesses
	lda trackn_command,x		; command and distortion byte
	sta reg2			; backup to the zeropage for quicker accesses
	lda trackn_effectparameter,x	; $XY parameter byte
	sta reg3			; backup to the zeropage for quicker accesses
	
pp2
	lda trackn_volumeenvelope,x	; volume envelope byte
	IFT TRACKS>4
		cpx #4
		bcc pp2s
		lsr @
		lsr @
		lsr @
		lsr @
	EIF
pp2s
	and #$0f
	ora trackn_volume,x
	tay
	lda volumetab,y
	sta tmp				; backup the resulting volume here, it will then used to make the AUDC value a bit later

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of manual tables code (unfinished)...

	IFT FEAT_TABLE_MANUAL		; Manual tuning table loaded from instruments, this is currently not fully implemented into RMT...
		lda trackn_pointertable,x
		beq do_tuning_tables		; a value of 0 means no pointer will be used, thus, can be skipped immediately
		tay
		and #$0F
		ora #$B0
		sta nr+1			; Bx00, where x is manipulated
;* hack for Reverse-16 proof of concept, won't be used later		
		lda #0
		cpx #1
		bne stayzero
;* end hack
		tya
		and #$C0
stayzero	
		sta nr				; B0x0, where is manipulated
	;* hack for Reverse-16 proof of concept, won't be used later	 
		cpx #0
		bne getdist
		lda tmp
		ora #$C0	
		jmp store_tables_lsb_c 
	;* end of Reverse-16 hack, what is below should always be the same 
getdist	
		lda reg2
		and #$0e
		tay
		jmp store_tables_lsb_b
	EIF
	
;* end of manual tables code...
	
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* start of the tuning tables code... 

;*
;* POSSIBLE IMPROVEMENT: make a JMP table indexed by X, instead of these dumb 1 by 1 checks... now done?
;* ANOTEHR POSSIBLE IMPROVEMENT: get the combined Distortion and Volume value as soon as possible, then get the tables pointer loaded...
;*
;* This may potentially debloat a lot of this part, and make things much faster as well 
;* AUDCTL BIT bytes could also be snuck in between the JMPs, replacing the NOPs, saving some space too! 
;* In fact, a lot of the things here need to get improved a lot more... 6502 ASM is hard!!!
;*

do_tuning_tables
	lda reg2		; Distortion and Command
	and #$0E		; Only keep the Distortion bits
	tay			; will be used for the tables MSB pointer, and the Distortion itself	
		
	IFT FEAT_AUDCTLMANUALSET	;*!!!! big block begins here 

		IFT FEAT_FULL_16BIT||FEAT_BASS16
			lda reg1		; load the channel flag for the initial 16-bit checks
			bmi get_16bit_flag	; 16-bit MSB flag detected, jump and finish there immediately 	
			cmp #$7F		; 16-bit LSB flag
			bcc check_index		; if not #$7F, the index checks will take care of everything else
			
			;lda trackn_bass16,x	; get the LSB pitch value
			;sta trackn_audf,x	; and write into the appropriate channel! -- BUG! This may be skipped entirely, unfortunately
			
			lda #0			; the 16-bit LSB flag was set, so first load 0
			sta trackn_audc,x	; then mute the channel
			;sta trackn_bass16,x	; and reset the LSB value before the next call-- BUG? if this is not done, the channel seems to outputs garbage on certain commands, why does this happen?
			jmp ppnext		; and finish this one early, there is nothing else to do here!
		EIF

check_index			; IMPROVEMENT: the flags system should work much better this time!
		txa
		IFT TRACKS>4		; stereo mode 	
			cpx #4			; are we in the right POKEY channels?
			bcc check_index_a	; if x is below 4, we are not 
			sbc #4			; carry is set, 4 will be subtracted 
		EIF 
check_index_a
		asl @ 
		asl @ 
		sta c_index+1
		lda reg1		; load the channel flag back in memory for the upcoming checks
c_index	bcc *
		jmp check_ch1 
		nop
		jmp check_ch2
		nop
		jmp check_ch3
		nop
		jmp check_ch4 

check_ch1 
		IFT FEAT_FULL_SAWTOOTH
			cmp #$40 		; 1.79mhz flag 
			bne get_15khz_flag	; no Sawtooth and no 1.79mhz if not equal
			cpy #$0A		; Distortion A?
			bne store_tables_lsb	; no Sawtooth if not equal, but the 1.79mhz flag is set! 
			lda tmp			; volume value backup
			beq check_ch1_a		; no Sawtooth if the volume is 0
			lda reg2 		; commands backup 
			bpl check_ch1_a		; no Sawtooth if the AUTOFILTER command is off 
			jmp do_sawtooth		; if all checks passed, process the Sawtooth code from here 
check_ch1_a
			lda reg1
			bpl store_tables_lsb	; 1.79mhz flag is still set, finish like normal 
		ELS			; no Sawtooth code 
			bpl check_ch3		; the 1.79mhz flag is the same regardless of the channel used, saves some bytes
		EIF
	
check_ch2 
		IFT FEAT_BASS16
			cpy #$06		; Distortion 6?
			bne get_15khz_flag	; if not equal, no BASS16	
			lda tmp 		; volume value backup
			beq reload_flag		; if the volume is 0, no BASS16	
			lda #$50		; JOIN_12 + CH1_179 bits 
			jmp do_bass16		; if all checks passed, process the BASS16 code from here 	
		ELS 
			bpl get_15khz_flag	; there is nothing else to check, unconditional 
		EIF
	
check_ch3 
		cmp #$40 		; 1.79mhz flag 
		beq store_tables_lsb	; yes! finish from there
		bne get_15khz_flag	; there is nothing else to check, unconditional 
	
check_ch4 
		IFT FEAT_BASS16
			cpy #$06		; Distortion 6?
			bne get_15khz_flag	; if not equal, no BASS16
			lda tmp 		; volume value backup
			beq reload_flag		; if the volume is 0, no BASS16	
			lda #$28		; JOIN_34 + CH3_179 bits 
			jmp do_bass16		; if all checks passed, process the BASS16 code from here
reload_flag
			lda reg1 		;* reload the channel flag if no longer in memory before the 15khz checks! 
		EIF 

;* from here, the flag MUST be in memory, so reload it unless it is 100% certain it is ready to use! 
	
get_15khz_flag
		and #1			; #$01 == 15khz flag, unconditional 
		beq store_tables_lsb	; #$00 == 64khz flag, unconditional
	
check_15khz 
		cpy #$0C		; are we in Distortion C/E?
		bcs check_15khz_b	; if equal or above, use the Distortion C 15khz table, else, use the Distortion A 15khz table
		lda #<frqtabpure_15khz	; Distortion A 15khz table LSB
		bcc check_15khz_c	; carry flag still set
check_15khz_b
		lda #<frqtabbuzzy_15khz	; Distortion C 15khz table LSB
check_15khz_c
		sta nr
		lda #>PAGE_EXTRA_0	; tables MSB pointer, it's the same one regardless of the table used
		bne store_tables_lsb_a	; unconditional 
	
		IFT FEAT_FULL_16BIT 
goto_bass16
			jmp do_bass16_c		; go directly in the BASS16 code handling the CMD6 hijack, skipping the AUDCTL update
get_16bit_flag
			cpy #$06		; Distortion 6?
			beq goto_bass16		; yes! finish from there 
		EIF
	
	EIF			;*!!! end of condition FEAT_AUDCTLMANUALSET
	
store_tables_lsb
	sta nr			; tables LSB pointer, divided in slices of 64 bytes each	
	lda TABLES_MSB,y	; 64khz, 1.79mhz and 16-bit all use their flag directly, #$00, #$40 and #$80 are valid pointers! 
	
store_tables_lsb_a
	sta nr+1		; tables MSB pointer, which is the memory page used for tables divided based on their Distortion
	
store_tables_lsb_b
	lda tmp			; volume value backup
	ora DISTORTIONS,y	; merge the Distortion and Volume values
store_tables_lsb_c
	sta trackn_audc,x	; update the channel's AUDC for the next SetPokey subroutine call
	
;* end of tuning tables code...

;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* start of instruments effect code...
	
InstrumentsEffects
	IFT FEAT_EFFECTS
		lda trackn_effdelay,x
		beq ei2
	
; possible improvement: use CMP #2 instead? This could save a CLC instruction...
;	cmp #2			; if A >= 2 -> skip, 
;	bcs ei1			; if A < 2 -> carry flag not set, so it must be A = 1, 0 was done with beq ei2
	
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
	IFT FEAT_COMMAND1||FEAT_COMMAND2||FEAT_COMMAND3||FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7	
		lda reg2
		and #$70
		IFT 1==[FEAT_COMMAND1+FEAT_COMMAND2+FEAT_COMMAND3+FEAT_COMMAND4+FEAT_COMMAND5+FEAT_COMMAND6+FEAT_COMMAND7]	
			beq cmd0	
		ELS
			lsr @
			lsr @
			sta jmx+1
jmx			bcc *
			jmp cmd0
			nop
			jmp cmd1
			IFT FEAT_COMMAND2||FEAT_COMMAND3||FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7	
				nop
				jmp cmd2
			EIF
			IFT FEAT_COMMAND3||FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7	
				nop
				jmp cmd3
			EIF
			IFT FEAT_COMMAND4||FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7	
				nop
				jmp cmd4
			EIF
			IFT FEAT_COMMAND5||FEAT_COMMAND6||FEAT_COMMAND7	
				nop
				jmp cmd5
			EIF
			IFT FEAT_COMMAND6||FEAT_COMMAND7 
				nop
				jmp cmd6
			EIF
			IFT FEAT_COMMAND7 
				nop
				jmp cmd7
			EIF
		EIF
	EIF
	
;* end of instruments effects code...
	
;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of instruments commands code... this is a direct followup of the instruments effects code.
	
cmd1
	IFT FEAT_COMMAND1
		lda reg3
		IFT FEAT_PORTAMENTO
			jmp pp10d		; fixes Portamento overwriting the CMD1 command (absolute pitch) 
		ELS
			jmp cmd0c
		EIF
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
			lda trackn_tabletypespeed,x		; table type? 
			bpl cmd5a1						; positive is notes table mode
			ldy trackn_note,x				; current note
		
			IFT FEAT_FULL_16BIT||FEAT_BASS16
				lda reg1					; flag in memory
				bpl cmd5a0					; positive means no 16-bit mode active
				tya 
				asl @						; offset for the 16-bit addressing
				tay
				iny							; 16-bit MSB offset
			EIF

cmd5a0
;			lda (nr),y						; actual note from table
;			clc								; clear carry flag	
;			adc trackn_tablenote,x			; frequency from table-- FIXME: might overflow!

			lda (nr),y						; this is the actual note base frequency, or AUDF 
			clc								; clear carry 
			bpl cmd5a0b						; if the value is positive, branch and finish there
cmd5a0a
			adc trackn_tablenote,x
			bvs cmd5ax
			bmi cmd5ax
			lda #$FF						; if overflow, force #$FF!
			bne cmd5ax
cmd5a0b
			adc trackn_tablenote,x
			bvs cmd5ax
			bpl cmd5ax
			lda #0					; if overflow, force #$00! 
			beq cmd5ax
;			jmp cmd5ax				; process the remaining of the code there
		EIF
	
cmd5a1
		lda trackn_note,x			; current note
		clc					; clear carry
		adc trackn_tablenote,x			; add the note from table
		cmp #61					; max possible note 
		bcc cmd5a2				; branch if lower than 61, finish with it 
		lda #63					; else, max possible note value
cmd5a2
		tay
	
		IFT FEAT_FULL_16BIT||FEAT_BASS16	;* TODO: fix the proper 16-bit mode, as well as the Sawtooth and/or AUTOFILTER when combined as well
			lda reg1				; flag in memory
			bpl cmd5a3				; positive means no 16-bit mode active
			tya 
			asl @					; offset for the 16-bit addressing
			tay
			iny					; 16-bit MSB offset
		EIF

cmd5a3	
		lda (nr),y				; actual note from table
cmd5ax
		sta trackn_portafrqc,x			; set the target portamento frequency
		ldy reg3				; #$XY instrument parameter
		bne cmd5a				; jump aheead if not zero 
		sta trackn_portafrqa,x			; else, set the current portamento pitch instantly
		;* BUG: Portamento is never initialised if the #$XY parameter is not on the very first player call! 
cmd5a
		lda trackn_portafrqa,x			; is the current frequency set to 0?
		bne cmd5b				; if not, it's most likely correctly set
		tay					; force the #$XY parameter to 0 to force Portamento to not run 
		sta reg3				; it will be called again further below
		lda trackn_portafrqc,x			; target frequency previously set
		sta trackn_portafrqa,x			; overwrite forced on the current frequency, to avoid the "pitch from 0" bug
cmd5b
		tya					; transfer the #$XY parameter to the accumulator
		lsr @					; divide by 16
		lsr @
		lsr @
		lsr @
		sta trackn_portaspeed,x			; set the portamento speed with the new value
		sta trackn_portaspeeda,x
		lda reg3				; #$XY parameter again
		and #$0f				; Only keep the Y values
		sta trackn_portadepth,x			; set the portamento pitch offset to process each step
		lda trackn_note,x			; current note
		jmp cmd0a				; finish everything else like normal from there
	ELI FEAT_COMMAND5
		lda trackn_note,x
		jmp cmd0a
	EIF

cmd6
	IFT FEAT_COMMAND6&&FEAT_FILTER		;* EXPERIMENTAL: do NOT stack the effects together, and start the offset at 0!
		lda reg3				; $XY parameter for the effect command
;		clc					; clear the carry flag
;		adc trackn_filter,x			; add it to the frequency offset currently in memory	
		sta trackn_filter,x			; overwrite the frequency offset with the new value 
		lda trackn_note,x			; current note for this instrument
		jmp cmd0a				; process the remaining of CMD0 without adding the $XY value to it 
	ELI FEAT_COMMAND6			; CMD6 alone is essentially no command at all, regardless of the $XY value
		lda trackn_note,x			; current note for this instrument
		jmp cmd0a				; process the remaining of CMD0 without adding the $XY value to it 
	EIF

cmd7
	IFT FEAT_COMMAND7
		IFT FEAT_TWO_TONE||FEAT_VOLUME_ONLY
			IFT FEAT_TWO_TONE
				lda reg3
				cmp #$FD		; #$FD toggles Two-Tone off
				bcc cmd7f		; no values will match if less than this, failsafe in case the BPL above didn't catch it
				beq cmd7b		; turn off the Two-Tone Filter if equal
				cmp #$FE		; #$FE toggles Two-Tone on
				beq cmd7c		; turn on the Two-Tone Filter if equal
				IFT FEAT_VOLUME_ONLY	
					bne cmd7a		; #$FF sets volume only mode, and will always be that value here, unconditional branching
				ELS
					bne cmd7f		; skip ahead, and don't set volume only mode either
				EIF
cmd7b				
				lda #3			; disable the Two-Tone Filter with this value
				bne cmd7d		; unconditional
cmd7c				
				lda #$8B		; enable the Two-Tone Filter with this value
cmd7d
				IFT TRACKS>4
					cpx #4
					bcc cmd7e		; less than 4
					sta v_skctl2		; SKCTL, Right POKEY 
					bcs cmd7f		; carry flag still set, unconditional
				EIF
cmd7e
				sta v_skctl		; SKCTL, Left POKEY
			ELS
				IFT FEAT_VOLUME_ONLY	
					lda reg3
					cmp #$FF
					beq cmd7a		; set volume only mode if equal
				EIF
			EIF
cmd7f
			lda trackn_note,x	; this is the expected variable in memory
			jmp cmd0a 
cmd7a
			IFT FEAT_VOLUME_ONLY
				lda trackn_audc,x
				ora #$f0
				sta trackn_audc,x
				bne cmd7f		; unconditional
			EIF
		ELS
			lda trackn_note,x	; this is the expected variable in memory
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
	tay
	
cmd0a1_a 	
	IFT FEAT_FULL_16BIT||FEAT_BASS16
		lda reg1
		beq cmd0a3		; no 16-bit flag set
		bpl cmd0a2		; Sawtooth flag set (maybe) 
		tya
		asl @			; offset for the 16-bit addressing!!!
		tay
		iny			; offset to load the MSB value first
		lda (nr),y
		dey			; offset to load the LSB value later
		sta trackn_audf,x	; get and store the MSB channel early
		lda trackn_shiftfrq,x
		IFT FEAT_COMMAND2
			clc
			adc frqaddcmd2
		EIF
		sta tmp			; get and store the frequency shift early, combined if CMD2 is also enabled
		bmi cmd0a1sub		; will subtract 1 from the MSB if negative on overflow
cmd0a1add
		lda (nr),y
		clc
		adc tmp
		sta trackn_bass16-1,x	; LSB channel
		bcc cmd0a1adddone	; no overflow, done
		inc trackn_audf,x	; increment the MSB if the value went past #$FF
cmd0a1adddone	
		jmp pp9			; done
		
cmd0a1sub
		lda (nr),y
		clc
		adc tmp
		sta trackn_bass16-1,x	; LSB channel
		bcs cmd0a1adddone	; no overflow, done
		dec trackn_audf,x	; decrement the MSB if the value went past #$00
		
cmd0a1subdone	
		jmp pp9			; done	
	EIF
	
cmd0a2	;* Sawtooth is so unlikely to even range the low #$FF frequencies that applying the vibrato fixes is pointless!
	IFT FEAT_FULL_SAWTOOTH&&FEAT_AUDCTLMANUALSET
		cmp #$41		; 1.79mhz => Sawtooth?
		bne cmd0a3		; no Sawtooth for sure
		lda (nr),y
		clc
		adc trackn_shiftfrq,x
		IFT FEAT_COMMAND2
			clc
			adc frqaddcmd2
		EIF	
		sta trackn_audf+2,x	; since we're in channel 1 of either POKEY, offset +2 will always be the 3rd channel
		pla			; get the second sawtooth pointer back from stack
		sta nr			; update the tables pointer to the other sawtooth table
	EIF

cmd0a3
;	lda (nr),y
;	clc
;	adc trackn_shiftfrq,x 
;	IFT FEAT_COMMAND2
;	clc
;	adc frqaddcmd2
;	EIF

	lda trackn_shiftfrq,x	; vibrato, and some other shifts use this value 
	IFT FEAT_COMMAND2 
		clc			; clear carry 
		adc frqaddcmd2		; if the CMD2 feature is also enabled, add that value as well 
	EIF 
	sta tmp			; temporary, for faster operation below
cmd0a3a
	lda (nr),y		; this is the actual note base frequency, or AUDF 
	clc			; clear carry 
	bpl cmd0a3c		; if the value is positive, branch and finish there
cmd0a3b
	adc tmp
	bvs cmd0a4
	bmi cmd0a4
	lda #$FF		; if overflow, force #$FF!
	bne cmd0a4
cmd0a3c
	adc tmp
	bvs cmd0a4
	bpl cmd0a4
	lda #0			; if overflow, force #$00!
cmd0a4 

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

cmd0b1_a 
	IFT FEAT_FULL_16BIT||FEAT_BASS16
		lda reg1 
		beq cmd0b3		; no 16-bit flag set
		bpl cmd0b2		; Sawtooth flag set (maybe) 
		tya
		asl @			; offset for the 16-bit addressing!!!
		tay
		iny			; offset to load the MSB value first
		lda (nr),y
		dey			; offset to load the LSB value later
		sta trackn_audf,x	; get and store the MSB channel early
		lda trackn_shiftfrq,x
		clc
		adc trackn_tablenote,x
		clc
		IFT FEAT_COMMAND2
			clc
			adc frqaddcmd2
		EIF
		sta tmp			; get and store the frequency shift early, combined if CMD2 is also enabled
		bmi cmd0b1sub		; will subtract 1 from the MSB if negative on overflow
cmd0b1add
		lda (nr),y
		clc
		adc tmp
		sta trackn_bass16-1,x	; LSB 16-bit channel, update early here
		bcc cmd0b1adddone	; no overflow, done
		inc trackn_audf,x	; increment the MSB if the value went past #$FF
cmd0b1adddone	
		jmp pp9			; done
cmd0b1sub
		lda (nr),y
		clc
		adc tmp
		sta trackn_bass16-1,x	; LSB 16-bit channel, update early here
		bcs cmd0b1adddone	; no overflow, done
		dec trackn_audf,x	; decrement the MSB if the value went past #$00
cmd0b1subdone	
		jmp pp9			; done 	
	EIF
	
cmd0b2	;* Sawtooth is so unlikely to even range the low #$FF frequencies that applying the vibrato fixes is pointless!
	IFT FEAT_FULL_SAWTOOTH&&FEAT_AUDCTLMANUALSET
		cmp #$41					; 1.79mhz => Sawtooth?
		bne cmd0b3					; no Sawtooth for sure 
		lda trackn_shiftfrq,x
		clc
		adc trackn_tablenote,x
		clc
		adc (nr),y	
		IFT FEAT_COMMAND2
			clc
			adc frqaddcmd2
		EIF	
		sta trackn_audf+2,x			; since we're in channel 1 of either POKEY, offset +2 will always be the 3rd channel
		pla							; get the second sawtooth pointer back from stack
		sta nr						; update the tables pointer to the other sawtooth table
	EIF

cmd0b3
;	lda trackn_shiftfrq,x
;	clc
;	adc trackn_tablenote,x
;	clc
;	adc (nr),y
;	IFT FEAT_COMMAND2
;	clc
;	adc frqaddcmd2
;	EIF

	lda trackn_shiftfrq,x			; vibrato, and some other shifts use this value 
	clc								; clear carry 
	adc trackn_tablenote,x			; freq table
	IFT FEAT_COMMAND2 
		clc							; clear carry 
		adc frqaddcmd2				; if the CMD2 feature is also enabled, add that value as well 
	EIF 
	sta tmp							; temporary, for faster operation below
cmd0b3a
	lda (nr),y						; this is the actual note base frequency, or AUDF 
	clc								; clear carry 
	bpl cmd0b3c						; if the value is positive, branch and finish there
cmd0b3b
	adc tmp
	bvs cmd0c
	bmi cmd0c
	lda #$FF						; if overflow, force #$FF!
	bne cmd0c
cmd0b3c
	adc tmp
	bvs cmd0c
	bpl cmd0c
	lda #0							; if overflow, force #$00! 

	EIF
	
cmd0c
	sta trackn_audf,x
	
;* end of instruments commands code... 
	
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* start of Portamento code... This is currently not properly compatible with 16-bit mode or Sawtooth, unfortunately.
;* TODO: fix Portamento for things that use combined channels to run
;* UPDATE: starting to understand a bit more how Portamento is working in the code...
;* POTENTIAL IMPROVEMENT: process the command in a different order? Add CMD2 pitch, and Vibrato Fix?
;* Maybe even set a flag to make sure the "reached" pitch clears the portamento mode? 
;* That way, it won't try to process it infinitely and possibly output incorrect pitch...
	
pp9
	IFT FEAT_PORTAMENTO
		lda trackn_portaspeeda,x	; is the portamento effect curently active?
		beq pp10					; it will be skipped if equal 
		dec trackn_portaspeeda,x	; decrease the value by 1
		bne pp10					; then jump ahead if it is not 0
		lda trackn_portaspeed,x		; portamento speed in memory
		sta trackn_portaspeeda,x	; overwrite the current portamento speed value to reset it
		lda trackn_portafrqa,x		; current portamento frequency in memory
		cmp trackn_portafrqc,x		; compare to target frequency
		beq pp10					; if equal, portamento is done and can be skipped
		bcs pps1					; if the current portamento pitch is higher, branch here
	
pps0 ; else, it is below the target pitch here
		adc trackn_portadepth,x		; add the portamento frequency offset to it
		bcs pps8					; overflown? branch if the carry flag is set
		cmp trackn_portafrqc,x		; compare to the target frequency
		bcs pps8					; equal or above means it was reached
		jmp pps9					; otherwise, it is still not reached yet
	
pps1 ; current pitch is higher than the target pitch here
		sbc trackn_portadepth,x		; subtract the portamento frequency offset from it
		bcc pps8					; overflown? branch if the carry flag is clear
		cmp trackn_portafrqc,x		; compare to the target frequency
		bcs pps9					; equal or above means it was not yet reached
pps8
		lda trackn_portafrqc,x		; the target pitch was reached, load it in memory
pps9
		sta trackn_portafrqa,x		; update the current portamento pitch with the new pitch
pp10
		lda reg2					; instrument commands and distortion
		and #$01					; Portamento bit
		beq pp11					; if 0 it is not set and will be skipped
	
pp10a
;		lda trackn_portafrqa,x		; load the current portamento frequency in memory
;		clc							; clear the carry flag 
;		adc trackn_shiftfrq,x		; add to it the shiftfrq/vibrato pitch

	;* TODO: add support for CMD2 offset, and fix vibrato when TableFreq is also involved, they have been ignored here!
	;* looks like the CMD0, and CMD1 were also ignored??? but why? 
	;* seems like the Table of Freqs mode is broken? Adding Negative values	

		lda trackn_shiftfrq,x		; vibrato, and some other shifts use this value 
		IFT FEAT_COMMAND2 
			clc						; clear carry 
			adc frqaddcmd2			; if the CMD2 feature is also enabled, add that value as well 
		EIF 
		sta tmp						; temporary, for faster operation below
		lda trackn_portafrqa,x		; load the current portamento frequency in memory
		clc							; clear the carry flag	
		bpl pp10c 					; positive value is outside of the dangerous range and can be processed
pp10b
		adc tmp
		bvs pp10d
		bmi pp10d
		lda #$FF					; if overflow, force #$FF!
		bne pp10d
pp10c
		adc tmp
		bvs pp10d
		bpl pp10d
		lda #0						; if overflow, force #$00! 
	
pp10d
		sta trackn_audf,x			; update the channel AUDF with the new value if Portamento was processed 
pp11
	EIF

;* end of Portamento code...

;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* part of mainloop code... this is an extra step added for the purpose of clearning the memory from 16-bit or Sawtooth addresses when unused.
	
ppnext
	dex
	bmi rmt_p4
	jmp pp1
rmt_p4
	ldy #0					; will be used to mute channels and reset the flags

;* end of mainloop code... everything below will be conditionally assembled for easy optimisation.

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of 16-bit flag code... a much more stripped down version
;* TODO: implement in a much more efficient way...
;* BUG? LSB channels need to be reset to process certain commands properly? That doesn't sound right...

;* UPDATE: this entire block may not even be necessary after all! 
;* It could be moved right in the channels index bit right where the initial flag check is done!
;* UPDATE2: nevermind, this might fail on empty instrument channels, so better keep it here... 

	IFT FEAT_FULL_16BIT||FEAT_BASS16	;****
bb1	
		lda g_flag+1
		bpl bb2						; not 16-bit flag, do nothing here	
		lda trackn_bass16+0			; ch1
		sta trackn_audf+0
bb2
		lda g_flag+3
		bpl bb3						; not 16-bit flag, do nothing here
		lda trackn_bass16+2			; ch3
		sta trackn_audf+2
bb3
		sty trackn_bass16+0
		sty trackn_bass16+2
	
		IFT STEREOMODE==1
bs1	
			lda g_flag+1+4
			bpl bs2					; not 16-bit flag, do nothing here	
			lda trackn_bass16+0+4	; ch1
			sta trackn_audf+0+4
bs2
			lda g_flag+3+4
			bpl bs3					; not 16-bit flag, do nothing here
			lda trackn_bass16+2+4	; ch3
			sta trackn_audf+2+4
bs3
			sty trackn_bass16+0+4
			sty trackn_bass16+2+4
		EIF
	EIF					;****

;* end of 16-bit flag code...
	
;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of Autofilter code... a much more stripped down version
;* TODO: redesign the implementation to allow a much more precise manipulation to be achieved
;* UPDATE: an attempt to mitigate overflows has been done here... 

	IFT FEAT_FILTER 
		ldx v_audctl 
qq1
		IFT FEAT_FILTERG0L
			lda trackn_command+0		; AUTOFILTER command set? BIT7 == #$80
			bpl qq2				; if the value is positive, the command is not set, skip
			lda trackn_audc+0		; AUDC value from ch1 currently in memory
			and #$0f			; only keep the volume value from the byte
			beq qq2				; if the volume is 0, skip 
			lda trackn_audf+0		; AUDF value from ch1 currently in memory 
			clc				; clear the carry flag
			bpl qq1a			; it's alright! carry on if the value is in the positive range
			sta tmp				; quick backup first
			adc trackn_filter+0		; add the frequency offset 
			bmi qq1b			; all good, carry on!
			lda tmp				; reload the backup value if it had overflown
			sec				; set the carry flag first!
			sbc trackn_filter+0		; subtract the frequency offset instead!
			bmi qq1b			; finish like normal from here
qq1a
			adc trackn_filter+0		; add the frequency offset for the AUTOFILTER modulation into the ch1 frequency 
qq1b
			sta trackn_audf+2		; overwrite the ch3 frequency with the new offset frequency 
			sty trackn_filter+0		; reset that value until a new CMD6 overwrites it
qq1c
			txa				; get the AUDCTL into the accumulator
			ora #4				; set the High Pass Filter Ch1+3 bit into it
			tax				; tramsfer back into X to process the next channel the exact same way
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
			bpl qq2a
			sta tmp
			adc trackn_filter+1
			bmi qq2b
			lda tmp
			sec
			sbc trackn_filter+1
			bmi qq2b
qq2a
			adc trackn_filter+1
qq2b
			sta trackn_audf+3
			sty trackn_filter+1
qq2c
			txa
			ora #2
			tax
			
		EIF
qq3
		stx v_audctl
	EIF

	IFT FEAT_FILTER&&TRACKS>4
		ldx v_audctl2 
qs1
		IFT FEAT_FILTERG0R
			lda trackn_command+0+4
			bpl qs2
			lda trackn_audc+0+4
			and #$0f
			beq qs2
			lda trackn_audf+0+4
			clc
			bpl qs1a
			sta tmp
			adc trackn_filter+0+4
			bmi qs1b
			lda tmp
			sec
			sbc trackn_filter+0+4
			bmi qs1b
qs1a	
			adc trackn_filter+0+4
qs1b
			sta trackn_audf+2+4
			sty trackn_filter+0+4
qs1c
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
			bpl qs2a
			sta tmp
			adc trackn_filter+1+4
			bmi qs2b
			lda tmp 
			sec
			sbc trackn_filter+1+4
			bmi qs2b 
qs2a
			adc trackn_filter+1+4
qs2b
			sta trackn_audf+3+4
			sty trackn_filter+1+4
qs2c
			txa
			ora #2
			tax
		EIF
qs3
		stx v_audctl2
	EIF
	
;* end of Autofilter code...

;---------------------------------------------------------------------------------------------------------------------------------------------;	
	
;* end of mainloop code, hit that RTS and that's it!
	
rmt_p5	
	rts 

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of Sawtooth code... there is room for improvements

	IFT FEAT_FULL_SAWTOOTH&&FEAT_AUDCTLMANUALSET
do_sawtooth
		IFT FEAT_FILTER
			eor #$80				; inverts the AUTOFILTER bit, so it does not overwrite things later
			sta trackn_command,x	; overwrite the command byte before the AUTOFILTER code since things where done early
		EIF
		lda #$64					; high pass filter, CH1+3 + 1.79mhz CH1+3
		IFT TRACKS>4				; stereo mode
			cpx #4					; are we in the right POKEY channels?
			bcc do_sawtooth_a 		; if x is lower than 4, we are not
			ora v_audctl2			; combine the existing AUDCTL value to it
			sta v_audctl2			; store the new AUDCTL value, right POKEY
			bne do_sawtooth_b 		; unconditional
		EIF
do_sawtooth_a	
		ora v_audctl				; combine the existing AUDCTL value to it
		sta v_audctl				; store the new AUDCTL value, left POKEY
do_sawtooth_b

		IFT FEAT_COMMAND6			; Sawtooth CMD6 hack... could be optimised much better, or maybe moved into the commands? 
			lda reg2				; Command and Distortion
			and #$70				; keep the Command bits only
			cmp #$60				; CMD6?
			bne do_sawtooth_c 		; skip if not equal
			lda reg3				; $XY parameter
			beq do_sawtooth_c 		; skip if the value is 0, nothing will be changed
			bmi sawtooth_reverse	; negative values (#$80 to #$FF) will reverse the pointers, positive values (#$01 to #$7F) will set the pointers back to normal
sawtooth_normal
			lda #<frqtabsawtooth_ch1
			sta saw_ch1
			lda #<frqtabsawtooth_ch3
			sta saw_ch3	
			bpl do_sawtooth_c 
sawtooth_reverse
			lda #<frqtabsawtooth_ch3
			sta saw_ch1
			lda #<frqtabsawtooth_ch1
			sta saw_ch3
		EIF
	
do_sawtooth_c
		lda #<frqtabsawtooth_ch1
saw_ch1	equ *-1	
		pha							; very TEMPORARILY keep the other pointer in the stack
		lda #<frqtabsawtooth_ch3
saw_ch3	equ *-1	
		sta nr
		inc reg1					; #$40 => #$41, will be necessary later to help differentiate the other flags!
do_sawtooth_d
		lda #>PAGE_EXTRA_0			; tables MSB pointer, it's the same one regardless of the table used
		jmp store_tables_lsb_a		; finish in the middle of the 64khz/1.79mhz branch

	EIF

;* end of Sawtooth code...

;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* start of BASS16 code...

	IFT FEAT_BASS16	
do_bass16 
		IFT TRACKS>4				; stereo mode
			cpx #4					; are we in the right POKEY channels?
			bcc do_bass16_a 		; if x is lower than 4, we are not
			ora v_audctl2			; merge the values with the AUDCTL in memory
			sta v_audctl2			; overwrite the AUDCTL, to force 16-bit mode through Distortion 6
			bne do_bass16_b			; unconditional	
		EIF
do_bass16_a
		ora v_audctl				; merge the values with the AUDCTL in memory
		sta v_audctl				; overwrite the AUDCTL, to force 16-bit mode through Distortion 6
do_bass16_b 
		lda #$80 					; 16-bit pointer
		sta g_flag,x				; flag set in the MSB channel --actually necessary since the flag is retrieved later!
		sta reg1					; since it is not permanent, it is good for immediate use!
		eor #$FF 					; invert, #$80 becomes #$7F
		sta g_flag-1,x				; flag set for the next channel, which will be skipped due to being in 16-bit mode now! 
do_bass16_c
		IFT FEAT_COMMAND6&&FEAT_FULL_16BIT
			lda reg2				; Distortion and Commands
			and #$70				; leave only the Commands bits
			cmp #$60				; CMD6?
			bne do_bass16_d			; skip if not CMD6
			lda reg3				; XY parameter 
			and #$0E				; strip away all unwanted bits, left nybble will not affect anything
			sta bass16_pointer		; PERMANENTLY change the value until a new CMD6 value is read
		EIF 
		IFT FEAT_FULL_16BIT	
do_bass16_d
			ldy #$0A				; Distortion A
bass16_pointer equ *-1 
			lda reg1				; the flag has been set, and also became the tables pointer!
			jmp store_tables_lsb	; continue like normal from there
			
		ELS			;* FIXMEEEE... later 
			lda #<frqtabpure_hi
			sta nr
			lda #<frqtabpure_lo
			sta trackn_bass16 	
			lda #0				
			sta trackn_audc-1,x		; update the next channel's AUDC early, it will always be volume 0, and Distortion won't matter
			lda #>PAGE_DISTORTION_A
			sta trackn_bass16+1		; this value can also be used to identify if 16-bit mode is active or not, since it will never be 0
			sta nr+1
			lda tmp
			ora #$A0
			jmp store_tables_lsb_c
		EIF
	
	EIF

;* end of BASS16 code...

;---------------------------------------------------------------------------------------------------------------------------------------------;
	
;* start of the SetPokey routines...

SetPokey
	ldy #0
v_audctl equ *-1			; left POKEY AUDCTL is loaded as the very first thing, for all STEREOMODE variations
	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
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
		lda #0
v_audctl2 equ *-1
		sta $d218
		sty $d208
		IFT FEAT_TWO_TONE
			lda #$03
v_skctl equ *-1	
			ldy #$03
v_skctl2 equ *-1
			sty $d21f
			sta $d20f 		
		EIF
	ELI STEREOMODE==0		;* L1 L2 L3 L4
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
		IFT FEAT_TWO_TONE
			lda #$03
v_skctl equ *-1	
			sta $d20f
		EIF	
	ELI STEREOMODE==2		;* L1 R2 R3 L4
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
		IFT FEAT_TWO_TONE
			lda #$03
v_skctl equ *-1	
			sta $d20f
			sta $d21f
		EIF
	ELI STEREOMODE==3		;* L1 L2 R3 R4
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
		IFT FEAT_TWO_TONE
			lda #$03
v_skctl equ *-1	
			sta $d20f
			sta $d21f
		EIF
	ELI STEREOMODE==4		;* LR1 LR2 LR3 LR4
		lda trackn_audf+0
		ldx trackn_audc+0
		sta $d200
		stx $d201
		sta $d210
		stx $d211
		lda trackn_audf+1
		ldx trackn_audc+1
		sta $d200+2
		stx $d201+2
		sta $d210+2
		stx $d211+2
		lda trackn_audf+2
		ldx trackn_audc+2
		sta $d200+4
		stx $d201+4
		sta $d210+4
		stx $d211+4
		lda trackn_audf+3
		ldx trackn_audc+3
		sta $d200+6
		stx $d201+6
		sta $d210+6
		stx $d211+6
		sty $d208
		sty $d218
		IFT FEAT_TWO_TONE
			lda #$03
v_skctl equ *-1	
			sta $d20f
			sta $d21f
		EIF
	EIF
	rts
	
;* end of SetPokey routines...
	
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
RMTPLAYEREND
	
;* Player ends here, what lies after is anything you want, and the extra workaround code if assembled as a 'tracker.obx' binary	

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* start of RMT data... maybe this could be moved elsewhere, much like the tuning tables?
	
	;org PLAYER-$0200	; I need to improve the label organisation here as well, also do I really need to org there? my memory is hazy, why did even do this...?
	.align $100,$00
	
	IFT FEAT_AUDCTLMANUALSET
AUDCTLBITS	; bits to test for AUDCTL lookup tables
POLY9	dta $80	; bit 7
CH1_179	dta $40	; bit 6
CH3_179	dta $20	; bit 5
JOIN_12	dta $10	; bit 4
JOIN_34	dta $08	; bit 3
HPF_CH1	dta $04	; bit 2
HPF_CH2	dta $02	; bit 1
CLOCK15	dta $01	; bit 0
	EIF	
	
TABLES_MSB
DISTORTIONS equ *+1
	dta >PAGE_DISTORTION_A,$00
	dta >PAGE_DISTORTION_2,$20
	dta >PAGE_DISTORTION_4,$40 	
	dta >PAGE_DISTORTION_A,$A0
	dta >PAGE_DISTORTION_A,$80
	dta >PAGE_DISTORTION_A,$A0
	dta >PAGE_DISTORTION_C,$C0
	dta >PAGE_DISTORTION_E,$C0
	
	IFT FEAT_EFFECTVIBRATO
vibtabbeg 
	dta 0,vib1-vib0,vib2-vib0,vib3-vib0
vib0	dta 0
vib1	dta 1,-1,-1,1
vib2	dta 1,0,-1,-1,0,1
vib3	dta 1,1,0,-1,-1,-1,-1,0,1,1
vibtabnext
		dta vib0-vib0+0
		dta vib1-vib0+1,vib1-vib0+2,vib1-vib0+3,vib1-vib0+0
		dta vib2-vib0+1,vib2-vib0+2,vib2-vib0+3,vib2-vib0+4,vib2-vib0+5,vib2-vib0+0
		dta vib3-vib0+1,vib3-vib0+2,vib3-vib0+3,vib3-vib0+4,vib3-vib0+5,vib3-vib0+6,vib3-vib0+7,vib3-vib0+8,vib3-vib0+9,vib3-vib0+0
	EIF	


	;org PLAYER-$0100	;* it may be possible to reduce this table by half the size it is... this was something I did for the older RMT Patch16 code, so the option is still valuable...
	
	.align $100,$00
	
volumetab
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
	dta $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
	dta $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
	dta $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
	dta $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
	dta $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
	dta $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
	dta $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
	dta $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
	dta $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
	dta $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
	dta $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
	dta $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
	dta $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	dta $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

;* end of RMT data...

;---------------------------------------------------------------------------------------------------------------------------------------------;

;* Let's not forget the tables and other RMT data! 

	.align $100,$00

;* Big re-organisation in progress, nothing is definitive currently!

; Each memory page are bound to a specific purpose, and must be memory alligned
; Due to the current implementation, it is imperative all tables are at the expected addresses!
; This will be refined over time, so for now this is what it is

;---------------------------------------------------------------------------------------------------------------------------------------------;
PAGE_DISTORTION_2	; in order: 64khz, 1.79mhz, and 16-bit (hi and lo) tables, 256 bytes 
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
; Poly5 Table, 64khz, Distortion 2

frqtabpoly5_64khz
        dta $3E,$3A,$37,$33,$30,$2E,$2B,$29,$26,$24,$22,$20
        dta $1F,$1C,$1B,$19,$18,$16,$15,$14,$13,$12,$10,$10
        dta $0F,$0E,$0D,$0C,$0B,$0B,$0A,$09,$09,$08,$08,$07
        dta $07,$06,$06,$06,$05,$05,$05,$04,$04,$04,$03,$03
        dta $03,$03,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01
        dta $00,$00,$00,$00
        
; Poly5 Table, 1.79mhz, Distortion 2

frqtabpoly5_179mhz
        dta $D7,$CA,$BE,$B3,$A9,$9F,$96,$8D,$85,$7E,$77,$70
        dta $69,$63,$5E,$58,$53,$4E,$49,$45,$41,$3D,$39,$36
        dta $32,$2F,$2D,$2A,$27,$25,$23,$20,$1E,$1D,$1A,$19
        dta $17,$16,$14,$13,$12,$11,$0F,$0E,$0D,$0C,$0B,$0A
        dta $0A,$09,$08,$07,$07,$06,$06,$05,$05,$04,$04,$03
        dta $03,$02,$02,$02 
	
; Poly5 Table, 16-bit, Distortion 2

frqtabpoly5_16bit
	dta a($0362,$0331,$0303,$02D7,$02AE,$0287,$0262,$0240,$021F,$0200,$01E3,$01C7)
	dta a($01AD,$0195,$017E,$0168,$0153,$0140,$012E,$011C,$010C,$00FD,$00EE,$00E0)
	dta a($00D3,$00C7,$00BB,$00B1,$00A6,$009D,$0093,$008B,$0082,$007B,$0073,$006D)
	dta a($0066,$0060,$005A,$0055,$0050,$004B,$0046,$0042,$003E,$003A,$0036,$0033)
	dta a($0030,$002C,$002A,$0027,$0024,$0022,$0020,$001D,$001B,$0019,$0017,$0016)
	dta a($0014,$0013,$0011,$0010)

;---------------------------------------------------------------------------------------------------------------------------------------------;
PAGE_DISTORTION_4	; in order: 64khz, 1.79mhz, and 16-bit (hi and lo) tables, 256 bytes 
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
; 64khz, Distortion 4

frqtabdist4_64khz
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00
        
; 1.79mhz, Distortion 4

frqtabdist4_179mhz
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dta $00,$00,$00,$00 
	
; 16-bit, Distortion 4

frqtabdist4_16bit
	dta a($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000)
	dta a($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000)
	dta a($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000)
	dta a($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000)
	dta a($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000)
	dta a($0000,$0000,$0000,$0000) 

;---------------------------------------------------------------------------------------------------------------------------------------------;
PAGE_DISTORTION_A	; in order: 64khz, 1.79mhz, and 16-bit (hi and lo) tables, 256 bytes 
;---------------------------------------------------------------------------------------------------------------------------------------------;
	
; Pure Table, 64khz, Distortion A

frqtabpure_64khz
	dta $F1,$E3,$D6,$CA,$BF,$B4,$AA,$A0,$97,$8F,$87,$7F
	dta $78,$71,$6B,$65,$5F,$5A,$54,$50,$4B,$47,$43,$3F
	dta $3B,$38,$35,$32,$2F,$2C,$2A,$27,$25,$23,$21,$1F
	dta $1D,$1C,$1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F
	dta $0E,$0D,$0C,$0C,$0B,$0A,$0A,$09,$09,$08,$07,$07
	dta $07,$06,$06,$05

; Pure Table, 1.79mhz, Distortion A

frqtabpure_179mhz
        dta $CF,$C4,$B8,$AE,$A4,$9A,$92,$89,$81,$7A,$73,$6C	; Octave 8
        dta $66,$60,$5A,$55,$50,$4B,$47,$43,$3F,$3B,$37,$34
        dta $31,$2E,$2B,$28,$26,$24,$21,$1F,$1D,$1B,$1A,$18
        dta $17,$16,$14,$13,$12,$11,$0F,$0E,$0D,$0C,$0B,$0A	; copied from Poly5 1.79mhz, mostly
        dta $0A,$09,$08,$07,$07,$06,$06,$05,$05,$04,$04,$03
        dta $03,$02,$01,$00 

; Pure Table, 16-bit, Distortion A

frqtabpure_16bit
	dta a($69B0,$63C1,$5E27,$58DE,$53E1,$4F2B,$4AB9,$4687,$4291,$3ED5,$3B4D,$37F9)
	dta a($34D4,$31DD,$2F10,$2C6B,$29ED,$2792,$2559,$2340,$2145,$1F67,$1DA3,$1BF9)
	dta a($1A67,$18EB,$1785,$1632,$14F3,$13C6,$12A9,$119D,$109F,$0FB0,$0ECE,$0DF9)
	dta a($0D30,$0C72,$0BBF,$0B16,$0A76,$09DF,$0951,$08CB,$084C,$07D4,$0764,$06F9)
	dta a($0694,$0635,$05DC,$0587,$0537,$04EC,$04A5,$0462,$0423,$03E7,$03AE,$0379)
	dta a($0347,$0317,$02EA,$02C0)

;---------------------------------------------------------------------------------------------------------------------------------------------;
PAGE_DISTORTION_C	; in order: 64khz, 1.79mhz, and 16-bit (hi and lo) tables, 256 bytes 
;---------------------------------------------------------------------------------------------------------------------------------------------;

; Buzzy Bass Table, 64khz, Distortion C

frqtabbuzzy_64khz
        dta $7F,$79,$73,$6C,$66,$60,$5A,$55,$F2,$E6,$D7,$CB
        dta $BF,$B6,$AA,$A1,$98,$8F,$89,$80,$7A,$71,$6B,$65
        dta $5F,$5C,$56,$50,$4D,$47,$44,$41,$3E,$38,$35,$32
        dta $2F,$2F,$29,$29,$26,$23,$20,$20,$20,$1A,$1A,$17
        dta $17,$17,$14,$14,$11,$11,$11,$11,$11,$0B,$0B,$0B
        dta $0B,$0B,$0B,$08
        
; Poly4 Buzzy Table, 1.79mhz, Distortion C

frqtabbuzzy_179mhz
        dta $6D,$66,$61,$5A,$55,$F8,$E9,$E0,$D1,$C5,$B9,$AD	; Octave 6
        dta $A4,$9B,$95,$89,$80,$7A,$71,$6E,$68,$62,$5C,$53
        dta $50,$4D,$4A,$44,$3E,$3B,$35,$35,$32,$2F,$2C,$26
        dta $26,$23,$23,$20,$1D,$1D,$1D,$17,$17,$14,$14,$11
        dta $0A,$09,$08,$07,$07,$06,$06,$05,$05,$04,$04,$03	; copied from Poly5 1.79mhz, mostly
        dta $03,$02,$01,$00 

; Poly4 Buzzy Table, 16-bit, Distortion C

frqtabbuzzy_16bit
	dta a($2A41,$27E3,$25A3,$2387,$2189,$1FA6,$1DE1,$1C31,$1A9C,$191F,$17B7,$165E)
	dta a($151D,$13EE,$12CE,$11C0,$10C1,$0FD1,$0EED,$0E15,$0D4C,$0C8C,$0BD8,$0B2D)
	dta a($0A8B,$09F2,$0965,$08DE,$085D,$07E5,$0773,$0707,$06A1,$0641,$05E7,$0593)
	dta a($0542,$04F7,$04AF,$046A,$042B,$03EF,$03B6,$0380,$034D,$031D,$02F0,$02C6)
	dta a($029F,$0278,$0254,$0230,$0212,$01F4,$01D6,$01BE,$01A3,$018B,$0176,$015E)
	dta a($014C,$0137,$0128,$0113)

;---------------------------------------------------------------------------------------------------------------------------------------------;
PAGE_DISTORTION_E	; in order: 64khz, 1.79mhz, and 16-bit (hi and lo) tables, 256 bytes
;---------------------------------------------------------------------------------------------------------------------------------------------;

; Gritty Bass Table, 64khz, Distortion C

frqtabgritty_64khz 
        dta $FF,$F3,$E4,$D8,$CD,$C0,$B5,$AB,$A2,$99,$91,$88 
        dta $7F,$79,$73,$6C,$66,$60,$5A,$55,$51,$4C,$48,$43
        dta $3F,$3C,$39,$34,$33,$30,$2D,$2A,$28,$25,$24,$21
        dta $1F,$1E,$1C,$50,$19,$47,$16,$15,$3E,$12,$35,$10
        dta $0F,$0F,$0D,$0D,$0C,$23,$0A,$0A,$0A,$1A,$1A,$07
        dta $07,$07,$06,$06

; Poly4 Gritty Table, 1.79mhz, Distortion C

frqtabgritty_179mhz
        dta $DE,$D0,$C6,$BB,$AF,$A5,$9A,$93,$8A,$82,$7B,$73	; Octave 5
        dta $6D,$66,$61,$5A,$55,$4F,$4B,$48,$43,$3F,$3C,$37
        dta $34,$31,$2D,$2B,$28,$27,$25,$22,$21,$1E,$1C,$19
        dta $18,$16,$16,$13,$12,$12,$0F,$0F,$0D,$0D,$0C,$0A
        dta $0A,$09,$09,$07,$07,$07,$07,$04,$04,$04,$04,$03
	dta $03,$02,$01,$00

; Poly4 Gritty Table, 16-bit, Distortion C

frqtabgritty_16bit
	dta a($0E11,$0D47,$0C87,$0BD3,$0B29,$0A89,$09F1,$0961,$08DA,$085B,$07E3,$0771)
	dta a($0705,$06A0,$0640,$05E6,$0591,$0541,$04F5,$04AD,$0469,$042A,$03EE,$03B5)
	dta a($037F,$034C,$031C,$02EF,$02C5,$029D,$0277,$0253,$0231,$0211,$01F3,$01D7)
	dta a($01BC,$01A4,$018A,$0174,$015F,$014B,$0138,$0126,$0115,$0105,$00F6,$00E8)
	dta a($00DB,$00CD,$00C3,$00B8,$00AC,$00A2,$0097,$0090,$0087,$007F,$0078,$0070)
	dta a($006A,$0063,$005E,$0057)

;---------------------------------------------------------------------------------------------------------------------------------------------;
PAGE_EXTRA_0	; in order: Sawtooth tables, and 15khz tables for Distortion A and C, 256 bytes 
;---------------------------------------------------------------------------------------------------------------------------------------------;

; Croissant Sawtooth, use on Channel 1 or 3, must be muted on channel 3

	IFT FEAT_TABLE_MANUAL

; Clarinet Tone Table, Reverse-16 lo, Distortion C

clarinet_lo
frqtabsawtooth_ch1
	dta $E2,$D6,$06,$63,$FC,$95,$5B,$30,$41,$70,$BD,$FB
	dta $75,$EF,$96,$5B,$F3,$E5,$9B,$AB,$9D,$BC,$DB,$FA
	dta $19,$74,$CF,$1B,$76,$D1,$59,$B4,$4B,$D3,$6A,$F2
	dta $89,$4D,$E4,$7B,$3F,$03,$9A,$5E,$22,$E6,$AA,$7D
	dta $41,$14,$E7,$BA,$9C,$7E,$42,$24,$06,$F2,$D9,$BB
	dta $9D,$8E,$70,$61      

; Clarinet Harmonic Table, Reverse-16 hi, Distortion A

clarinet_hi
frqtabsawtooth_ch3
	dta $34,$31,$2F,$2C,$29,$27,$25,$23,$21,$1F,$1D,$1B
	dta $1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F,$0E,$0D
	dta $0D,$0C,$0B,$0B,$0A,$09,$09,$08,$08,$07,$07,$06
	dta $06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03
	dta $03,$03,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01
	dta $01,$01,$01,$01

	ELS

frqtabsawtooth_ch1
	dta $E4,$DE,$D7,$D1,$CB,$C5,$BF,$BA,$B4,$AF,$AA,$A5
	dta $A0,$9B,$97,$92,$8E,$8A,$86,$82,$7E,$7A,$77,$73
	dta $70,$6D,$69,$66,$63,$60,$5D,$81,$58,$7A,$76,$50
	dta $4E,$6C,$69,$47,$45,$43,$5D,$5A,$57,$3B,$52,$62
	dta $4D,$34,$68,$31,$62,$42,$5C,$2B,$6A,$67,$6C,$58
	dta $35,$4A,$32,$4E

; Croissant Sawtooth, use on Channel 1 or 3, must be muted on channel 3

frqtabsawtooth_ch3
	dta $E5,$DF,$D8,$D2,$CC,$C6,$C0,$BB,$B5,$B0,$AB,$A6
	dta $A1,$9C,$98,$93,$8F,$8B,$87,$83,$7F,$7B,$78,$74
	dta $71,$6E,$6A,$67,$64,$61,$5E,$83,$59,$7C,$78,$51
	dta $4F,$6E,$6B,$48,$46,$44,$5F,$5C,$59,$3C,$54,$65
	dta $4F,$35,$6C,$32,$66,$44,$60,$2C,$70,$6D,$73,$5D
	dta $37,$4E,$34,$53

	EIF

; Pure Table, 15khz, Distortion A

frqtabpure_15khz
        dta $ED,$DF,$D2,$C7,$BB,$B1,$A7,$9D,$95,$8C,$84,$7D
        dta $76,$6F,$69,$63,$5D,$58,$53,$4E,$4A,$45,$42,$3E
        dta $3A,$37,$34,$31,$2E,$2B,$29,$27,$24,$22,$20,$1E
        dta $1D,$1B,$1A,$18,$17,$15,$14,$13,$12,$11,$10,$0F
        dta $0E,$0D,$0C,$0C,$0B,$0A,$0A,$09,$08,$08,$07,$07
        dta $06,$06,$06,$05

; Buzzy Bass Table, 15khz, Distortion C

frqtabbuzzy_15khz
        dta $BC,$B2,$A8,$9E,$96,$8D,$85,$7E,$76,$70,$6A,$64
        dta $5F,$58,$53,$4E,$4B,$46,$42,$3E,$3A,$37,$34,$32
        dta $2E,$2B,$29,$26,$25,$23,$21,$1F,$1C,$1B,$1A,$19
        dta $17,$16,$15,$14,$12,$11,$10,$0F,$0D,$0D,$0C,$0C
        dta $0B,$0A,$0A,$0A,$08,$08,$07,$07,$06,$06,$06,$05
        dta $05,$05,$05,$03

;---------------------------------------------------------------------------------------------------------------------------------------------;
;PAGE_EXTRA_1	; Unused
;---------------------------------------------------------------------------------------------------------------------------------------------;

;	IFT FEAT_TABLE_MANUAL
;	org TABLES+$500

; Clarinet Tone Table, Reverse-16 lo, Distortion C

;clarinet_lo
;	dta $E2,$D6,$06,$63,$FC,$95,$5B,$30,$41,$70,$BD,$FB
;	dta $75,$EF,$96,$5B,$F3,$E5,$9B,$AB,$9D,$BC,$DB,$FA
;	dta $19,$74,$CF,$1B,$76,$D1,$59,$B4,$4B,$D3,$6A,$F2
;	dta $89,$4D,$E4,$7B,$3F,$03,$9A,$5E,$22,$E6,$AA,$7D
;	dta $41,$14,$E7,$BA,$9C,$7E,$42,$24,$06,$F2,$D9,$BB
;	dta $9D,$8E,$70,$61      

; Clarinet Harmonic Table, Reverse-16 hi, Distortion A

;clarinet_hi
;	dta $34,$31,$2F,$2C,$29,$27,$25,$23,$21,$1F,$1D,$1B
;	dta $1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F,$0E,$0D
;	dta $0D,$0C,$0B,$0B,$0A,$09,$09,$08,$08,$07,$07,$06
;	dta $06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03
;	dta $03,$03,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01
;	dta $01,$01,$01,$01
	;EIF

;---------------------------------------------------------------------------------------------------------------------------------------------;

; and that's all... I guess 

	
;---------------------------------------------------------------------------------------------------------------------------------------------;

	.align $100,$00

track_variables

.var trackn_TblLo		:tracks .byte			; low byte of ptrs to each track's data
.var trackn_TblHi		:tracks .byte			; Hi byte of ptrs to each track's data
.var trackn_idx			:tracks .byte			; How far into each track
.var trackn_pause		:tracks .byte			; 1 new note, 0 nothing new
.var trackn_note		:tracks .byte
.var trackn_volume		:tracks .byte
.var trackn_volumeenvelope	:tracks .byte
.var trackn_command		:tracks .byte
.var trackn_effectparameter	:tracks .byte
.var trackn_shiftfrq		:tracks .byte

	IFT FEAT_PORTAMENTO
.var trackn_portafrqc 		:tracks .byte
.var trackn_portafrqa 		:tracks .byte
.var trackn_portaspeed 		:tracks .byte
.var trackn_portaspeeda 	:tracks .byte
.var trackn_portadepth 		:tracks .byte
	EIF
	
.var trackn_instrx2		:tracks .byte			; New instrument init required (-1 = new new instrument)
.var trackn_instrdb		:tracks .byte
.var trackn_instrhb		:tracks .byte
.var trackn_instridx		:tracks .byte
.var trackn_instrlen		:tracks .byte
.var trackn_instrlop		:tracks .byte
.var trackn_instrreachend	:tracks .byte
.var trackn_volumeslidedepth	:tracks .byte
.var trackn_volumeslidevalue 	:tracks .byte

	IFT FEAT_VOLUMEMIN
.var trackn_volumemin		:tracks .byte
	EIF
	
FEAT_EFFECTS equ FEAT_EFFECTVIBRATO||FEAT_EFFECTFSHIFT

	IFT FEAT_EFFECTS
.var trackn_effdelay		:tracks .byte
	EIF
	
	IFT FEAT_EFFECTVIBRATO
.var trackn_effvibratoa		:tracks .byte
	EIF
	
	IFT FEAT_EFFECTFSHIFT
.var trackn_effshift		:tracks .byte
	EIF
	
.var trackn_tabletypespeed 	:tracks .byte

	IFT FEAT_TABLEMODE
.var trackn_tablemode		:tracks .byte
	EIF

.var trackn_tablenote		:tracks .byte
.var trackn_tablea		:tracks .byte
.var trackn_tableend		:tracks .byte

	IFT FEAT_TABLEGO
.var trackn_tablelop		:tracks .byte
	EIF
	
.var trackn_tablespeeda		:tracks .byte

	IFT FEAT_FILTER
.var trackn_filter		:tracks .byte		;* POTENTIAL OPTIMISATION: it is NOT necessary to use all tracks... only channel 1 and 2 will use it to offset the other...
	EIF

	IFT FEAT_FULL_16BIT||FEAT_BASS16	;* EXPERIMENTAL METHOD: full 16-bit values, Sawtooth and Filter may also benefit from this approach...
.var trackn_bass16		:tracks .byte
	EIF
	
	IFT FEAT_FULL_16BIT||FEAT_BASS16||FEAT_FULL_SAWTOOTH
.var g_flag			:tracks .byte
	EIF
	
	IFT FEAT_TABLE_MANUAL
.var trackn_pointertable	:tracks .byte	
	EIF
	
	IFT FEAT_AUDCTLMANUALSET
.var trackn_audctl		:tracks .byte
	EIF	
	
.var trackn_audf		:tracks .byte
.var trackn_audc		:tracks .byte

.var v_aspeed				.byte

track_endvariables

;* end of RMT definitions...

