
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

	.sav [$4000] 64
	opt l+
.endm

	opt h-

	.get 'alwa_4c.mic'

; @@CutMIC x y

	@@CutMIC 1 4
	@@CutMIC 1 6

	@@CutMIC 5 4
	@@CutMIC 5 6

	@@CutMIC 9 4
	@@CutMIC 9 6

	@@CutMIC 13 4
	@@CutMIC 13 6


	@@CutMIC 1 0
	@@CutMIC 1 2


	@@CutMIC 22 4
	@@CutMIC 22 6

	@@CutMIC 26 4
	@@CutMIC 26 6

	@@CutMIC 30 4
	@@CutMIC 30 6

	@@CutMIC 34 4
	@@CutMIC 34 6
