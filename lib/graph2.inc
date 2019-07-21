
{

MoveTo

}


procedure MoveTo(x, y: smallint); assembler;
(*
@description:
Move cursor to absolute position.
*)
asm
{	lda y+1
	bpl _0

	lda #0
	sta y
	sta y+1
_0
	lda x+1
	bpl _1

	lda #0
	sta x
	sta x+1
_1
	cpw y main.system.ScreenHeight
	bcc _2

	sbw main.system.ScreenHeight #1 y
_2
	cpw x main.system.ScreenWidth
	bcc _3

	sbw main.system.ScreenWidth #1 x
_3
	mwa x CurrentX
	mwa y CurrentY
};
end;
