
.proc	@putchar 
  
		pha
		sta 	DParameters 				; sending A
		lda 	#6
		sta 	DFunction 					; we don't inline it because inline uses it
		lda 	#2
		sta 	DCommand
		pla
		rts

.endp
