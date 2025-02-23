unit xsfx;
(*
 @type: unit
 @author: Krzysztof (XXL) Dudek, Tomasz (Tebe) Biela
 @name: xSFX Engine
 @version: 1.0 (2022-12-10)

 @description:
 <https://atariage.com/forums/topic/320982-sfx-engine/>

 <http://xxl.atari.pl/sfx-engine/>
*)


{

TSFX.Add
TSFX.Clear
TSFX.Init
TSFX.Play
TSFX.Stop

}

interface


type	TSFX = Object
(*
@description:
object for controling xSFX player
*)
	procedure Init(sfx: byte); assembler; overload;			// Initialize SFX on the first available channel
	procedure Init(sfx, chn: byte); assembler; overload;		// Initialize SFX at designated channel

	procedure Clear; assembler;					// All SFX set to NIL
	procedure Add(asfx: pointer); assembler; overload;		// Add SFX on the first available slot
	procedure Add(asfx: pointer; slot: byte); assembler; overload;  // Add SFX at designated slot
	procedure Play; assembler;					// Play initialized SFX
	procedure Stop; assembler;					// Stops SFX

	end;

implementation

uses misc;

const

{$IFDEF SFX_POKEY_SECOND}
	VPOKEY = $D210;
{$ELSE}
	VPOKEY = $D200;
{$ENDIF}


var
	SFX_CNT: array [0..3] of byte = ($ff,$ff,$ff,$ff);

	SFX_NO, SFX_TIME, SFX_AUDC, SFX_AUDF, SFX_FLAG, SFX_REPEAT, SFX_RTIME, SFX_RTS, SFX_RCNT: array [0..3] of byte;

	SFX_ADR_TAB: array [0..31] of pointer;

	ntsc: byte;


procedure SFX_CHANNEL_OFF; assembler; keep;
(*
@description:
disable channel
*)
asm
	txa
	asl @
	tay
	lda #$ff
	sta adr.SFX_CNT,x
	lda #$00
	sta adr.SFX_NO,x
	sta adr.SFX_TIME,x
	sta adr.SFX_REPEAT,x
	sta adr.SFX_RTS,x
	sta VPOKEY,y
	sta VPOKEY+1,y
end;


procedure SFX_PROCEED; assembler; keep;
(*
@description:

*)
asm

; ================================================ LEVEL 2
; === SFX ENGINE ====
;xSFX_ENGINE - jump here 1 per frame at least
;
;xSFX_ENGINE+3  in:  A=sfx, X=channel, C=1 (force)
;                    A=sfx, C=0 (find free channel)
;               out: C=1 no free channel
;                    C=0 ok
;
;xSFX_ENGINE+6  in:  X=channel - will immediately terminate SFX on the specified channel
; ===
;
; Command:
;
;1. TIME,AUDF,AUDC          ; graj TIME ilość ramek, zapisz rejestry AUDF, AUDC
;2. REPF,TIME,COUNT,AUDC    ; powtórz COUNT razy: graj TIME ilosc ramek, zainicjuj AUDC, wpisuj AUDF COUNT razy
;3. REPC,TIME,COUNT,AUDF    ; powtórz COUNT razy: graj TIME ilosc ramek, zainicjuj AUDF, wpisuj AUDC COUNT razy
;4. LOOP                    ; powtórz ten sam dźwięk od komendy na pozycji loop
;5. RTS                     ; koniec opisu dźwięku
;6. JSR nnnnn               ; wywołaj SFX nr. nn i po jego zakończeniu wróć kontynuuj odtwarzanie obecnego
;7. JMP nnnnn               ; skocz do SFX nr.
;
; Code:
;
; TIME = $01..$0f
; REPF = $c0
; REPC = $80
; LOOP = $00,NUM
; RTS  = $00,$ff
; JSR  = $a0,SFX
; JMP  = $e0,SFX


xSFX_ENGINE     jmp xSFX_PROCEED         ; xSFX_ENGINE
;xSFX_START      jmp SFX_INSERT           ; xSFX_ENGINE+3
;xSFX_STOP       jmp SFX_CHANNEL_OFF      ; xSFX_ENGINE+6


SFX_ENDRTS	jsr GET_BYTE

		tay
                dey
                cmp #$ff
                beq SFX_RTSEND
                jmp SFX_RELOAD

SFX_RTSEND      lda adr.SFX_RTS,x
                bne SFX_DORTS
                jsr SFX_CHANNEL_OFF
                jmp SFX_NXTCH

SFX_DORTS       pha
                lda #$00
                sta adr.SFX_RTS,x
                lda adr.SFX_RCNT,x
                sta adr.SFX_CNT,x
                jmp SFX_DORTSF

SFX_REP         dec adr.SFX_REPEAT,x
                lda adr.SFX_RTIME,x
                sta adr.SFX_TIME,x
                lda #$00
                lda adr.SFX_FLAG,x
                asl @
                bcs SFX_DF
                bcc SFX_DC

xSFX_PROCEED    ldx #3
SFX_CONTCH      lda adr.SFX_NO,x
                bne SFX_PROCED
SFX_NXTCH       dex
                bpl SFX_CONTCH
                rts

SFX_PROCED      ldy adr.SFX_TIME,x
                bne SFX_CONTTONE
SFX_CONTCHJ     tay
                lda adr.SFX_ADR_TAB-1,y
		beq SFX_NXTCH

                sta SFXZP+1

                lda adr.SFX_ADR_TAB-2,y
                sta SFXZP

                ldy adr.SFX_CNT,x
                lda adr.SFX_REPEAT,x
                bne SFX_REP
SFX_RELOAD
		jsr GET_BYTE

                beq SFX_ENDRTS
SFX_TOKEN       asl @
                bcc SFX_TIM
                asl @
                ror adr.SFX_FLAG,x
                asl @
                bcs SFX_JUMP

		jsr GET_BYTE

                sta adr.SFX_RTIME,x

		jsr GET_BYTE

                sta adr.SFX_REPEAT,x
                lda adr.SFX_FLAG,x
                asl @

		jsr GET_BYTE

                bcs SFX_C0C
                sta adr.SFX_AUDF,x
                bcc SFX_REP
SFX_C0C         sta adr.SFX_AUDC,x
                bcs SFX_REP

SFX_TIM         lsr @
                sta adr.SFX_TIME,x
SFX_DF
		jsr GET_BYTE

                sta adr.SFX_AUDF,x
                bcs SFX_N3
SFX_DC
		jsr GET_BYTE

                sta adr.SFX_AUDC,x
SFX_N3          tya
                sta adr.SFX_CNT,x
SFX_CONTTONE    txa
                asl @
                tay
                lda adr.SFX_AUDF,x
                sta VPOKEY,y
                lda adr.SFX_AUDC,x
                sta VPOKEY+1,y
                dec adr.SFX_TIME,x
                jmp SFX_NXTCH

SFX_JUMP        lsr @
                lsr @
                pha
                lda adr.SFX_FLAG,x
                bmi SFX_JMP
                lda adr.SFX_NO,x
                sta adr.SFX_RTS,x
                tya
                sta adr.SFX_RCNT,x
SFX_JMP         lda #$ff
                sta adr.SFX_CNT,x
SFX_DORTSF      pla
                sta adr.SFX_NO,x
                jmp SFX_CONTCHJ


GET_BYTE	iny
		lda SFXZP: $1000,y
		rts
end;


procedure TSFX.Init(sfx: byte); assembler; overload;
(*
@description:
Initialize xSFX player
*)
asm
		txa:pha

		lda sfx

                ldx #$03
SFX_FIND        ldy adr.SFX_NO,x
                beq SFX_SETNO
                dex
                bpl SFX_FIND
                sec
                bcs quit

SFX_SETNO       asl @
                sta adr.SFX_NO,x
                clc

quit		pla:tax
end;


procedure TSFX.Init(sfx, chn: byte); assembler; overload;
(*
@description:
Initialize xSFX player
*)
asm
		txa:pha

		lda chn
		and #3
		tax

		lda sfx

SFX_FORCE       pha
                jsr SFX_CHANNEL_OFF
                pla
SFX_SETNO       asl @
                sta adr.SFX_NO,x
                clc

		pla:tax
end;


procedure TSFX.Play; assembler;
(*
@description:
Play SFX
*)
asm
	txa:pha

	asl ntsc		; =0 PAL, =4 NTSC
	bcc skp

	lda #%00000100
	sta ntsc

	bne quit
skp
	jsr SFX_PROCEED

quit	pla:tax
end;


procedure TSFX.Clear; assembler;
(*
@description:
Clear all SFX
*)
asm
	ldy #$3f
	lda #0
	sta:rpl adr.SFX_ADR_TAB,y-
end;


procedure TSFX.Add(asfx: pointer); assembler; overload;
(*
@description:
Add new SFX, at first empty position [1..32]
*)
asm
	ldy #2
loop	lda adr.SFX_ADR_TAB-1,y
	beq empty

	iny
	iny
	cpy #66
	bne loop

	sec
	jmp @exit

empty	lda asfx
	sta adr.SFX_ADR_TAB-2,y
	lda asfx+1
	sta adr.SFX_ADR_TAB-1,y

	clc
end;


procedure TSFX.Add(asfx: pointer; slot: byte); assembler; overload;
(*
@description:
Add new SFX, at designated position [1..32]
*)
asm
	sec

	lda slot
	beq @exit
	asl @
	cmp #66
	bcs @exit

	tay

	lda asfx
	sta adr.SFX_ADR_TAB-2,y
	lda asfx+1
	sta adr.SFX_ADR_TAB-1,y

	clc
end;


procedure TSFX.Stop; assembler;
(*
@description:
Halt xSFX player
*)
asm
	txa:pha

        ldx #0
        jsr SFX_CHANNEL_OFF
	ldx #1
	jsr SFX_CHANNEL_OFF
	ldx #2
	jsr SFX_CHANNEL_OFF
	ldx #3
	jsr SFX_CHANNEL_OFF

	pla:tax
end;


initialization

if DetectAntic then
 ntsc:=0
else
 ntsc:=4;

end.
