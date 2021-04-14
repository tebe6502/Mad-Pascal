
// http://atariki.krap.pl/index.php/Programowanie:_U%C5%BCycie_OS-a_przy_wy%C5%82%C4%85czonym_ROM-ie

.local	rominit

        sei
        lda #%00000000
        sta NMIEN       ;$D40E
        lda #%11111110
        sta PORTB       ;$D301

	ldx #3
	ldy #0
mv	inc portb
afnt0	lda $e000,y
	dec portb
afnt1	sta $e000,y
	iny
	bne mv
	inc afnt0+2
	inc afnt1+2
	dex
	bpl mv

        ldx #<nmiint
        ldy #>nmiint
        stx NMIVEC      ;$FFFA
        sty NMIVEC+1

        ldx #<irqint
        ldy #>irqint
        stx IRQVEC      ;$FFFE
        sty IRQVEC+1

        lda #%01000000
        sta NMIEN       ;$D40E
        cli

	jmp skp



nmiint  bit NMIST        ;$D40F
        spl
        jmp (VDSLST)     ;$0200

        sec
        .byte $24        ;BIT $18

irqint  clc

        ;wlaczenie OS ROM

        inc PORTB       ;$D301

        pha
        txa
        pha
        tsx

        ;odlozenie na stos danych dla powrotu z przerwania (RTI)

        lda #>iret      ;adres procedury iret
        pha
        lda #<iret
        pha
        lda $103,x      ;skopiowanie wartosci rejestru stanu procesora
        pha

        ;skok przez odpowiedni wektor przerwania

        scc
        jmp (NMIVEC)    ;$FFFA
        jmp (IRQVEC)    ;$FFFE

iret	pla
	tax
	pla

        ;wylaczenie OS ROM

        dec PORTB       ;$D301
        rti

skp

.endl

