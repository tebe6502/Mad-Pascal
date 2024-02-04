//
// Neo6502
//
	
ControlPort = $ff00

DCommand = ControlPort+0
DFunction = ControlPort+1
DError = ControlPort+2
DStatus = ControlPort+3
DParameters = ControlPort+4
DTopOfStack = ControlPort+12

.proc @SendMessage
		@WaitMessage 				; wait for command to be released.

		sta 	KSMReturnA+1 				; save A reloaded at end.
		pla 								; pop return address to the read instruction
		sta 	KSMRAddress+1 			
		pla
		sta 	KSMRAddress+2

		jsr 	KSMReadAdvance 				; read the command.
		pha 								; save, write it after the command.
		jsr 	KSMReadAdvance 				; read the function number
		sta 	DFunction 					
		pla
		sta 	DCommand 					; save the command, starting the message.
.DEF :KSMAdvanceReturn
		jsr 	KSMReadAdvance 				; use jmp indirect so advance it again.
.DEF :KSMReturnA		
		lda 	#$FF 						; original A value
		jmp 	(KSMRAddress+1)

.DEF :KSMReadAdvance
		inc 	KSMRAddress+1 				; pre-inc because of 6502 RTS behaviour
		bne 	KSMRAddress
		inc 	KSMRAddress+2
.DEF :KSMRAddress
		lda 	$FFFF 						; holds the return address.
		rts
.endp

.proc @WriteCharacterInLine
		sta 	KSMReturnA+1 				; save A reloaded at end.
		pla 								; pop return address to the read instruction
		sta 	KSMRAddress+1 			
		pla
		sta 	KSMRAddress+2
		jsr 	KSMReadAdvance 				; output a character
		@putchar
		bra 	KSMAdvanceReturn
.endp


.proc @WaitMessage
		pha
KWaitMessage1
		lda 	DCommand 					; wait until the handler has finished.
		bne 	KWaitMessage1
		pla
		rts
.endp

.proc @ShuffleLFSR
	lda seed+1
	tay ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0 ; recombine with original low byte
	sta seed+1
	; compute seed+0 ($39 = %111001)
	tya ; original high byte
	sta seed+0
	asl
	eor seed+0
	asl
	eor seed+0
	asl
	asl
	asl
	eor seed+0
	sta seed+0
	rts
	
seed
.DEF :randv0
	DTA 0
.DEF :randv1
	DTA 0
.endp
