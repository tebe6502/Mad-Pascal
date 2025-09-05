
; https://github.com/cc65/cc65/blob/master/libsrc/common/mul40.s

.proc   @mul40			; = 33 bytes, 48/53 cycles

        sta     :eax+1		; remember value for later addition...
        ldy     #0              ; clear high-byte

	sty	:eax+2
	sty	:eax+3

        asl     @		; * 2
        bcc     mul4            ; high-byte affected?
        ldy     #2              ; this will be the 1st high-bit soon...

mul4:   asl     @               ; * 4
        bcc     mul5            ; high-byte affected?
        iny                     ; => yes, apply to 0 high-bit
        clc                     ; prepare addition

mul5:   adc     :eax+1		; * 5
        bcc     mul10		; high-byte affected?
        iny			; yes, correct...

mul10:  sty     :eax+1		; continue with classic shifting...
        
        asl     @		; * 10
        rol     :eax+1

        asl     @		; * 20
        rol     :eax+1

        asl     @		; * 40
        rol     :eax+1
	
	sta	:eax

        rts

.endp
