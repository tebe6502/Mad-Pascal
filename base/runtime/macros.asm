
.macro	m@index2 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm

.macro	m@index4 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm


.macro	m@call (os_proc)

	.ifdef MAIN.@DEFINES.ROMOFF

		inc portb

		jsr %%os_proc

		dec portb

	.else

		jsr %%os_proc

	.endif

.endm


.macro m@string

	dta .len(str)
	.local str
	dta ":1"
	.endl
.endm

