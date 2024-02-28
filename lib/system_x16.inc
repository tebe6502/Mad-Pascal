procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/60 second).
*)
asm
        phx
        jsr RDTIM
        sta r11L
wait:   jsr RDTIM
        cmp r11L
        beq wait
        plx
end;

procedure Pause(n: word); assembler; overload;
(*
@description:
Delay program execution (N * 1/60 second).

@param: N - number of '1/60 second'
*)
asm
        phx
loop:   lda n
        ora n+1
        beq stop

        jsr RDTIM
        sta r11L // zero page register to store start time

wait:   jsr RDTIM
        cmp r11L
        beq wait

        dew n

        jmp loop
stop:   plx
end;


procedure Randomize; assembler;
(*
@description:
Initialize random number generator
*)
asm
	phx
	jsr entropy_get
	sta RndSeed
	stx RndSeed+1
	plx
end;


function Random: Real; overload;
(*
@description:
Generate random number

@returns: Real (Q24.8)
*)
begin
	asm
		phx
		jsr entropy_get
		sta Result
		stz Result+1
		stz Result+2
		stz Result+3
		plx
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
		phx
		jsr entropy_get
		and #$7f
		sta Result+2
		stx Result+1
		stz Result
		lda #$3f
		sta Result+3
		plx
 	end;
	Result:= 1 - Result;
end;


function RandomF16: Float16;
(*
@description:
Generate random number

@returns: Float16 (Half-Single)
*)
var a: word;
begin

	asm
		phx
		jsr entropy_get
		and #$7f
		sta a+1
		stx a
		plx
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
		phx
		jsr entropy_get
		lda range
		beq stop
		sta :ecx
		sty :eax
		jsr imulCL
		tay
stop	sty Result
		plx
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

