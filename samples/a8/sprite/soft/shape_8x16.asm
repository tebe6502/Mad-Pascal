
.macro	@@CopyLine
	:+16 .put[?dst+#]=.get[?x+?y+#*40]

	.def ?x++
	.def ?dst+=16
.endm

.macro	@@CutMIC
	opt l-
	.def ?x = :1
	.def ?y = :2*320

	.def ?dst = $4000

	@@CopyLine
	@@CopyLine
	@@CopyLine

	.sav [$4000] 32
	opt l+
.endm

	opt h-

	.get 'shape_8x16.mic'

; @@CutMIC x y

s0	@@CutMIC 0 0
s1	@@CutMIC 0 2
s2	@@CutMIC 0 4
s3	@@CutMIC 0 6
s4	@@CutMIC 0 8
s5	@@CutMIC 0 10
s6	@@CutMIC 0 12
s7	@@CutMIC 0 14
s8	@@CutMIC 0 16
s9	@@CutMIC 0 18
s10	@@CutMIC 0 20
s11	@@CutMIC 0 22
s12	@@CutMIC 0 24
