procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/50 second).
*)
asm
	@SendMessage
	dta 1,1
	@WaitMessage
	mva DParameters last
@	
	@SendMessage
	dta 1,1
	@WaitMessage
	lda DParameters 
    cmp #0 
last = *-1
	beq @-
	rts 
end;


procedure Pause(n: word); assembler; overload;
(*
@description:
Delay program execution (N * 1/50 second).

@param: N - number of '1/50 second'
*)
asm
	@SendMessage
	dta 1,1
	@WaitMessage
	mwa DParameters last
	adw last n last
@	
	@SendMessage
	dta 1,1
	@WaitMessage
	cpw DParameters last
	bmi @-
	rts 
last 
	dta a(0)
end;

procedure Randomize; assembler;
(*
@description:
Initialize random number generator
*)
asm
    lda #$2d 
    sta randv0
    lda #$10
    sta randv1
    @ShuffleLFSR
    lda randv0
    eor randv1 
    sta RndSeed
    mva #$00 RndSeed+1
end;



function Random: Real; overload;
(*
@description:
Generate random number

@returns: Real (Q24.8)
*)
begin
 asm
    @ShuffleLFSR
	lda randv0
	sta Result

	stz Result+1
	stz Result+2
	stz Result+3
 end;

 Result:= 1 - Result;
end;


function RandomF: Float;
(*
@description:
Generate random number

@returns: Float (Single)
*)
begin
 asm
    @ShuffleLFSR
	lda randv0
	sta Result+2

	lda randv1		; minimum interval between RANDOM register reads is 8 cycles
	sta Result+1

	lda #$00
	sta Result
	lda #$3f
	sta Result+3
 end;

 Result:= 1 - Result;
end;


function RandomF16: Float16;
(*
@description:
Generate random number

@returns: Float (Single)
*)
var a: word;
begin

 asm
	@ShuffleLFSR
	lda randv0
	and #$7f
	sta a+1

	lda randv1		; minimum interval between RANDOM register reads is 8 cycles
	sta a
 end;

 Result:= a * (1/32767);

end;


function Random(range: byte): byte; assembler; overload;
(*
@description:
Generate random number

@param: range (0..range-1)

@returns: byte
*)
asm
  @ShuffleLFSR
  //lda randv0   ; RANDOM
  lda randv1
  tay

  lda range
  beq stop

  sta :ecx
  sty :eax

  jsr imulCL
  tay

stop  sty Result
end;


function Random(range: smallint): smallint; overload;
(*
@description:
Generate random number

@param: range (0..range-1), (-range..0)

@returns: smallint
*)
begin

 if range = 0 then
  Result := 0
 else begin

  RndSeed := $4595 * RndSeed;
  Result := RndSeed mod range;

asm
	lda range+1
	bpl plus

	lda Result+1
	bmi ok
	bpl sign

plus	lda Result+1
	bpl ok

sign 	lda #0
	sub Result
	sta Result

	lda #0
	sbc Result+1
	sta Result+1
ok
end;

 end;

end;


function ParamCount: byte; assembler;
(*
@description:
Return number of command-line parameters passed to the program.

@returns: byte
*)
asm

end;


function ParamStr(i: byte): TString; assembler;
(*
@description:
Return value of a command-line argument.

@param: i - of a command-line argument

@returns: string[32]
*)
asm

end;

