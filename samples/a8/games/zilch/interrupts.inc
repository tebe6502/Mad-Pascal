
procedure vbli;interrupt;
begin
	asm {
        pha
        txa
        pha
		tya
		pha
	};	
	msx.Play;
	msx.Play;
	msx.Play;
		
	asm {
		pla
		tay
        pla
        tax
        pla
        jmp $E462
	};
end;


procedure dli;assembler;interrupt;
asm {
        pha
        txa
        pha

        lda #8      ; text color gradient of BANK amount
        sta wsync
        sta $d017
        sta wsync
        sta $d017
        lda #10
        sta wsync
        sta $d017
        lda #12
        sta wsync
        sta $d017
        lda #14
        sta wsync
        sta $d017
        lda #12
        :2 sta wsync
        sta $d017
        lda #8
        sta wsync
        sta $d017
        lda #15
        sta wsync
        sta $d017

		lda #BLINKCOLOR
		sta $d012
		sta $d013
		sta $d014
		sta $d015

        lda #$c2    ; dice table colors
        :4 sta wsync
        sta $d018

		lda blinkDices ; dice highligths
		ldx #0
		lsr 
		scc 
		ldx #57
		stx hposp0
		stx wsync
		
		ldx #0
		lsr 
		scc 
		ldx #57+24
		stx hposp1
		stx wsync
		
		ldx #0
		lsr 
		scc 
		ldx #57+48
		stx hposp2
		stx wsync
		
		ldx #0
		lsr 
		scc 
		ldx #57+72
		stx hposp3
		stx wsync		
		
		ldx #0
		lsr 
		scc 
		ldx #57+96
		stx hposm0
		:8 inx
		stx hposm1
		stx wsync		
		
		ldx #0
		lsr 
		scc 
		ldx #57+120
		stx hposm2
		:8 inx
		stx hposm3
		stx wsync		

        lda #BGCOLOR    ; remaining background
        :40 sta wsync
        sta $d018

        ldx #0  ; turnoff pmg
        lda menupos
        and #$f0;
        seq 
        ldx #3  ; turnon pmg
        stx $D01D
		sta wsync

        ldx #89
        lda menupos
        and #$10
        sne
        ldx #129
        stx hposp0
        txa
        add #28
        sta hposm0


        lda 20
        :2 lsr
        and #%00000011
        ora #ROLLMENUCOLOR
        sta $D012
        lda 20
        :2 lsr
        and #%00001111
        ora #SCOREMENUCOLOR
        :48 sta wsync
        sta $D012
        ldx #0  ; turnoff pmg
        lda menupos
        and #$0f
        seq 
        ldx #3  ; turnon pmg
        stx $D01D
        sta wsync

        ldx #49
        lda menupos
        cmp #2
        sne
        ldx #89
        cmp #3
        sne
        ldx #129
        cmp #3
        sne
        ldx #169
        stx hposp0
        txa
        add #30
        sta hposm0
		sta wsync

        lda #4
        :2 sta wsync
        sta $d017
        lda #6
        :4 sta wsync
        sta $d017
        :2 sta wsync
        lda #8
        sta $d017
        lda #6
        :4 sta wsync
        sta $d017
        lda #4
        :2 sta wsync
        sta $d017
        lda #2
        :6 sta wsync
        sta $d017
        lda #3  ; turnon pmg
        sta $D01D
        mva #49 hposp0
        mva #48+31 hposm0
        mva #P1COLOR $D012
        mva #P2COLOR $D013
        mva #P3COLOR $D014
        mva #P4COLOR $D015
		
		mva #49 hposp0
		mva #49+40 hposp1
		mva #49+80 hposp2
		mva #49+120 hposp3
		mva #49+31 hposm0
		mva #49+40+31 hposm1
		mva #49+80+31 hposm2
		mva #49+120+31 hposm3
    
        ldx playerCurrent ; selected player highlight
        lda 704,x
        add #6
        sta $D012,x
        sub #6
        :17 sta wsync
        sta $D012,x

        lda #0       ; players text colors
        sta $d017
        lda #4
        :12 sta wsync
        sta $d017
        lda #0
        :8 sta wsync
        sta $d017
        :8 sta wsync

        lda 20      ; blinking last row
        :2 lsr
        ora #8
        sta $d017

        pla
        tax
        pla
    };
end;

