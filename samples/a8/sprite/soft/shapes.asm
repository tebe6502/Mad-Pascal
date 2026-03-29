
.macro	@@CopyLine
	:+21 .put[?dst+#]=.get[?x+?y+#*40]

	.def ?x++
	.def ?dst+=21
.endm

.macro	@@CutMIC
	opt l-
	.def ?x = :1
	.def ?y = :2*320

	.def ?dst = $4000

	@@CopyLine
	@@CopyLine
	@@CopyLine

	.sav [$4000] 64
	opt l+
.endm

	opt h-

	.get 'krakout_sprites.mic'

; @@CutMIC x y

s0	@@CutMIC 0 0
s1	@@CutMIC 0 3
s2	@@CutMIC 0 6
s3	@@CutMIC 0 9
s4	@@CutMIC 0 12
s5	@@CutMIC 0 15
s6	@@CutMIC 0 18
s7	@@CutMIC 0 21
s8	@@CutMIC 0 24
s9	@@CutMIC 6 0
s10	@@CutMIC 6 3
s11	@@CutMIC 6 6

m0	@@CutMIC 6 21
m1	@@CutMIC 6 24
m2	@@CutMIC 6 27

b0	@@CutMIC 27 0
b1	@@CutMIC 27 3
b2	@@CutMIC 27 6
b3	@@CutMIC 27 9
b4	@@CutMIC 27 12
b5	@@CutMIC 27 15
b6	@@CutMIC 27 18
b7	@@CutMIC 27 21



