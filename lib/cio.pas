unit cio;
(*
 @type: unit
 @author: Tomasz Biela (Tebe), Daniel Koźmiński (Dely)
 @name: CIO interface
 @version: 1.0

 @description:
 CIO - Central Input/Output
*)


{

Cls
BGet
FindFirstFreeChannel
Get
Opn
Put
RGet
RSkip
XIO

}

interface

	procedure BGet(chn: byte; buf: PByte; cnt: word); assembler; register;
	procedure BPut(chn: byte; buf: PByte; cnt: word); assembler; register;
	procedure Cls(chn: byte); assembler;
	function FindFirstFreeChannel: byte; assembler;
	function Get(chn: byte): byte; assembler;
	procedure Opn(chn, ax1, ax2: byte; device: PString); assembler;
	procedure Put(chn, a: byte); assembler;
	function RGet(chn: byte; buffer: PByte): TString; register;
	procedure RSkip(chn: byte; buffer: PByte); assembler; register;
	procedure XIO(cmd, chn, ax1, ax2: byte; device: PString); assembler;

implementation


procedure Opn(chn, ax1, ax2: byte; device: PString); assembler;
(*
@description:
Open channel

@param: chn - channel 0..7
@param: ax1 - parameter
@param: ax2 - parameter
@param: device - name of device, example "D:"
*)
asm
	txa:pha

	lda chn
	:4 asl @
	tax

	lda #$03		;komenda: OPEN
	sta iccmd,x

	inw device		;omin bajt z dlugoscia STRING-a

	lda device		;adres nazwy pliku
	sta icbufa,x
	lda device+1
	sta icbufa+1,x

	lda ax1			;kod dostepu: $04 odczyt, $08 zapis, $09 dopisywanie, $0c odczyt/zapis, $0d odczyt/dopisywanie
	sta icax1,x

	lda ax2			;dodatkowy parametr, $00 jest zawsze dobre
	sta icax2,x

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
end;


procedure Cls(chn: byte); assembler;
(*
@description:
Close channel

@param: chn - channel 0..7
*)
asm
	txa:pha

	lda chn
	:4 asl @
	tax

	lda #$0c		;komenda: CLOSE
	sta iccmd,x

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
end;


function Get(chn: byte): byte; assembler;
(*
@description:
Get one byte

@param: chn - channel 0..7
@result: byte
*)
asm
	txa:pha

	lda chn
	:4 asl @
	tax

	lda #7		;get char command
	sta iccmd,x

	lda #$00	;zero out the unused
	sta icbufl,x	;store in accumulator
	sta icbufh,x	;...after CIOV jump

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	sta Result

	pla:tax
end;


procedure BGet(chn: byte; buf: PByte; cnt: word); assembler; register;
(*
@description:
Get CNT bytes to BUF

@param: chn - channel 0..7
@param: buf - buffer
@param: cnt - bytes counter
*)
asm
	txa:pha

	lda chn
	:4 asl @
	tax

	lda #7		;get char/s command
	sta iccmd,x

	lda buf
	sta icbufa,x
	lda buf+1
	sta icbufa+1,x

	lda cnt
	sta icbufl,x
	lda cnt+1
	sta icbufh,x

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
end;


procedure Put(chn, a: byte); assembler;
(*
@description:
Write one byte

@param: chn - channel 0..7
@param: a - byte
*)
asm
	txa:pha

	lda chn
	:4 asl @
	tax

	lda #11		;put char command
	sta iccmd,x

	lda #$00	;zero out the unused
	sta icbufl,x	;store in accumulator
	sta icbufh,x	;...after CIOV jump

	lda a

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
end;


procedure BPut(chn: byte; buf: PByte; cnt: word); assembler; register;
(*
@description:
Put CNT bytes from BUF

@param: chn - channel 0..7
@param: buf - buffer
@param: cnt - bytes counter
*)
asm
	txa:pha

	lda chn
	:4 asl @
	tax

	lda #11		;put char/s command
	sta iccmd,x

	lda buf
	sta icbufa,x
	lda buf+1
	sta icbufa+1,x

	lda cnt
	sta icbufl,x
	lda cnt+1
	sta icbufh,x

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
end;


procedure XIO(cmd, chn, ax1, ax2: byte; device: PString); assembler;
(*
@description:
Special command

@param: cmd - command
@param: chn - channel 0..7
@param: ax1 - parameter
@param: ax2 - parameter
@param: device - name of device, example "S2:"
*)
asm
	stx @sp

	lda chn
	:4 asl @
	tax

	lda cmd
	sta iccmd,x

	lda ax1
	sta icax1,x

	lda ax2
	sta icax2,x

	inw device		;skip [0]

	lda device		;device name
	sta icbufa,x
	lda device+1
	sta icbufa+1,x

	m@call	ciov

	sty MAIN.SYSTEM.IOResult

	ldx #0
@sp	equ *-1
end;


function RGet(chn: byte; buffer: PByte): TString; register;
(*
* @description:
* Gets text record and returns as Tstring. Equivalent in Atari BASIC: INPUT #channel VAR$
*
* @param: (byte) chn - Free IOCB channel.
* @param: (PByte) buffer - Where to place data.
* @returns: (Tstring) - Record contents.
*)
var
     cnt  : byte;
     tmp  : Tstring;
begin

     asm
	txa:pha

        lda chn
        :4 asl @
        tax

        lda #5
        sta iccmd,x

        lda buffer
        sta icbufa,x
        lda buffer+1
        sta icbufa+1,x
        lda #$ff
        sta icbufl,x
        lda #0
        sta icbufl+1,x

        m@call	ciov

	pla:tax
     end;

     // Temporary string

     tmp := '';

     // Counter

     cnt := 0;

     // Move result record to result variable
     While Peek(word(buffer) + cnt) <> $9b do begin
          tmp := Concat(tmp, Chr(Peek(word(buffer) + cnt)));
          Inc(cnt);
     end;

     Result := tmp;
end;


procedure RSkip(chn: byte; buffer: PByte); assembler; register;
(*
* @description:
* Skips record. Equivalent in Atari BASIC: INPUT #channel VAR$
*
* @param: (byte) chn - Free IOCB channel.
* @param: (PByte) buffer - Where to place data.
*)
asm
	txa:pha

	lda chn
        :4 asl @
        tax

        lda #5
        sta iccmd,x

        lda buffer
        sta icbufa,x
        lda buffer+1
        sta icbufa+1,x
        lda #$ff
        sta icbufl,x
        lda #0
        sta icbufl+1,x

	m@call ciov

	pla:tax
end;


function FindFirstFreeChannel: byte; assembler;
(*
* @description:
* Find first available IOCB channel
*
* @returns: (byte) - first available channel number (multiplied by 16) or error -95.
* Source: http://atariki.krap.pl/index.php/Programowanie:_Jak_wyszuka%C4%87_pierwszy_wolny_IOCB
*)
asm
	txa:pha

	ldx #$00
        ldy #$01
loop	lda icchid,x
        cmp #$ff
        beq found
        txa
        clc
        adc #$10
        tax
        bpl loop
        ldx #-95
found 	stx Result

	pla:tax
end;

end.
