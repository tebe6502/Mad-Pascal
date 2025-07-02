unit music;

interface
		procedure PlaySong(song: char);
	


implementation

uses crt, saplzss;

	{$i music.inc
}

procedure PlaySong(song: char);
var msx: TLZSSPlay;
    p: pointer;
    speed: byte;
begin

	case song of

	 '1': GetResourceHandle(p, 'msx1');
	 '2': GetResourceHandle(p, 'msx2');
	 '3': GetResourceHandle(p, 'msx3');
	 '4': GetResourceHandle(p, 'msx4');
	 '5': GetResourceHandle(p, 'msx5');
	 '6': GetResourceHandle(p, 'msx6');

	else

	  exit

	end;


	if song = '1' then
	 speed := 2
	else
	 speed :=1;


	msx.modul := p;
	msx.player := pointer(play_r);

	fillbyte(pointer(play_r+$300), $900, 0);	// clear buffers

	msx.init($00);	// $00 -> $d200..
	//msx.play;


	while true do begin

asm
			//--- 	Set replay speed
			ldy 	speed	;SongSpeed
			lda 	tabpp-1,y
			sta 	acpapx2+1				;sync counter spacing
			lda 	tabppFixP-1,y
			sta 	acpapx2fp+1				;sync counter spacing

			lda 	#4+0
			sta 	acpapx1+1				;sync counter init

LoopMainNoDLI

			lda 	fixP
			clc
acpapx2fp		adc 	#$ff				;parameter overwrite (sync line counter spacing)
			sta 	fixP

acpapx1			lda 	#$ff				;parameter overwrite (sync line counter value)
acpapx2			adc 	#$ff				;parameter overwrite (sync line counter spacing)
			cmp 	#156
			bcc 	lop4
			sbc 	#156

lop4
			sta 	acpapx1+1
waipap
			cmp 	VCOUNT					;vertical line counter synchro
			bne 	waipap
end;

		//poke($d01a, $0e);

		if msx.decode then Break;
		if keypressed then begin ReadKey; Break end;

		msx.play;
		//poke($d01a, $00);

asm
			jsr begindraw

			jmp LoopMainNoDLI



fixP 		.byte 0
tabpp  		dta 156,78,52,39,19,9,4			;line counter spacing table for instrument speed from 1 to 6
tabppFixP  	dta 0,0,0,0,$80,$c0,$e0			;line counter spacing table for instrument speed from 1 to 6



;-----------------
// https://github.com/VinsCool/VUPlayer-LZSS/blob/main/VUPlayer.asm?fbclid=IwAR1C6yt_UE6sZgfT2eEvMfuV9azWa-CDGm5w4JQwQ18cha3ZyDVJQoHXIhk#L1080

;* Draw the VUMeter display and process all the variables related to it

begindraw
;	ldx #7			; 4 AUDF + 4 AUDC

set_decay_update

	.rept 4

	lda buffers+$700-#*$200,y	; AUDC
	and #$0F			; keep only the volume bits
	beq @+				; if the volume is already 0, don't even bother, skip
	pha
	lda buffers+$800-#*$200,y	; AUDF
	:3 lsr @			; divide by 8
	tax				; transfer to Y	for the decay buffer index
	pla
	cmp decay_buffer,x		; compare to the current volume level from memory
	bcc @+
	sta decay_buffer,x		; write the new value in memory, the decay is now reset for this column
@
	.endr

;	:2 dex 			; decrement twice since each POKEY channel use 2 bytes
;	bpl set_decay_update	; repeat until all channels are done
/*
begindraw_a
	lda is_stereo_flag	; is the stereo flag set?
	bpl drawnow		; if not set, don't check the other POKEY registers
*/

/*
	ldx #7			; 4 AUDF + 4 AUDC
set_decay_update_a
	lda SDWPOK1,x		; AUDC
	and #$0F		; keep only the volume bits
	beq skip_decay_merge_a	; if the volume is already 0, don't even bother, skip
	pha
	lda SDWPOK1-1,x		; AUDF
	:3 lsr @		; divide by 8
	tay			; transfer to Y	for the decay buffer index
	pla
	cmp decay_buffer,y	; compare to the current volume level from memory
	bcc skip_decay_merge_a
	sta decay_buffer,y	; write the new value in memory, the decay is now reset for this column
skip_decay_merge_a
	:2 dex 			; decrement twice since each POKEY channel use 2 bytes
	bpl set_decay_update_a	; repeat until all channels are done


*/

drawnow
	mwa #$bc40+20*40+4 DISPLAY

	mwa 560 :bp2

	ldy #25
	lda #4
	sta (:bp2),y+
	sta (:bp2),y+
	sta (:bp2),y+
	sta (:bp2),y

drawagain
	ldx #3
	drawloopcount equ *-1
	lda vu_tbl,x
	sta tbl_colour
	lda vu_sub,x
	sta drawlinesub
	ldy vu_ypos,x
	ldx #31
drawlineloop
	lda decay_buffer,x
	beq drawemptyline
	sec
	sbc #0
	drawlinesub equ *-1
	beq drawemptyline
	bpl drawlineloop_good
drawemptyline
	lda #vol_0
	bpl drawlinenothing
drawlineloop_good
	cmp #4
	bcc drawlineloop_part
	lda #3
drawlineloop_part
	adc #0			; carry will be added for values above 3, to draw 4 bars per line
	tbl_colour equ *-1
drawlinenothing
	sta DISPLAY: $ffff,y
	iny
	dex
	bpl drawlineloop
drawnext
	dec drawloopcount
	bpl drawagain
	lda #3			; reset the 4 lines offset and counter for the next frame
	sta drawloopcount
drawdone
	dec decay_speed
	bpl decay_done		; if value is positive, it's over, wait for the next frame
reset_decay_speed
	lda #1;SPEED
	sta decay_speed		; reset the value in memory, for the next cycle
do_decay
	ldx #31
	lda #0
decay_next
	dec decay_buffer,x
	bpl decay_good
	sta decay_buffer,x
decay_good
	dex
	bpl decay_next
decay_done
	rts

vol_0	equ $46
vol_grn	equ $47
vol_ylw	equ $4B
vol_red	equ $CB

decay_buffer
	:32 dta $00

decay_speed
	dta $00
vu_tbl
	dta vol_grn-1, vol_grn-1, vol_ylw-1, vol_red-1
vu_sub
	dta $00,$04,$08,$0C
vu_ypos
	dta $78,$50,$28,$00


end;

	end;

	msx.stop($00);

end;

end.
