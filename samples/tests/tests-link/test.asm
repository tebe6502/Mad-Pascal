
	.reloc

.extrn edx .dword

.extrn	print .proc (.dword edx) .var

.public	prc


.proc	prc (.dword a .dword b .dword c) .var

.var a,b,c .dword
	print a
	print b
	print c

	rts

.endp
