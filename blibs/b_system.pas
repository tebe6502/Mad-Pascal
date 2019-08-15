unit b_system;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: System Tools
* @version: 0.5.3
* @description:
* Set of useful constants, registers and methods to simplify common
* system related tasks in Atari 8-bit programming.
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses atari;
procedure SystemOff(port_b: byte); assembler; overload;
(*
* @description:
* Turns off OS with custom PORTB($D301) value.
*
* @param: port_b - value of PORTB register
*)
procedure SystemOff; overload;
(*
* @description:
* Turns off OS and BASIC.
* *
* Gives maximum available RAM.
*)
procedure SystemReset(port_b: byte); assembler; overload;
procedure SystemReset; overload;
(*
* @description:
* Turns on OS back and resets machine.
*)
procedure EnableVBLI(vblptr: pointer); assembler;
(*
* @description:
* Enable and set custom handler for Vertical Blank Interrupt.
* 
*
* To set vertical blank interrupt vector from your inline assembly code, use label __vblvec to store new routine address. 
* 
*
* Example: 
* 
* &nbsp; lda &lt;myVblRoutine  
* 
* &nbsp; sta __vblvec  
* 
* &nbsp; lda &gt;myVblRoutine  
* 
* &nbsp; sta __vblvec+1  
*
* @param: vblptr - pointer to interrupt handler routine
*)
procedure DisableVBLI; assembler;
(*
* @description:
* Disables custom routine of Vertical Blank Interrupt.
*)
procedure EnableDLI(dliptr: pointer); assembler;
(*
* @description:
* Enable and set custom handler for Display List Interrupt.
* 
* 
* To set display list interrupt vector from your inline assembly code, use label __dlivec to store new routine address. 
* 
*
* Example: 
*  
* &nbsp; lda &lt;myDliRoutine  
* 
* &nbsp; sta __dlivec  
* 
* &nbsp; lda &gt;myDliRoutine  
* 
* &nbsp; sta __dlivec+1  
*
* @param: dliptr - pointer to interrupt handler routine
*)
procedure DisableDLI; assembler;
(*
* @description:
* Disables Display List Interrupts.
*)
procedure EnableIRQ; assembler;
(*
* @description:
* Enables IRQ Interrupts.
*)
procedure DisableIRQ; assembler;
(*
* @description:
* Disables IRQ Interrupts.
*)
procedure SetIRQ(irqptr:pointer); assembler;
(*
* @description:
* Set IRQ Interrupt Vector.
*)
procedure WaitFrame; assembler;
(*
* @description:
* Waits till drawing of current frame ends.
*)
procedure WaitFrames(frames: byte);
(*
* @description:
* Waits for a specified number of frames.
*
* Each frame is 1/50 sec for PAL systems, or 1/60 sec for NTSC.
*
* @param: frames - number of frames to wait.
*)
procedure SetCharset(msb: byte);
(*
* @description:
* Sets font charset located at specified page of memory.
*
* @param: msb - most significant byte of charset address (memory page number).
*)

var __nmien:byte;

const
	PORTB_SELFTEST_OFF = %10000000; // portb bit value to turn Self-Test off
	PORTB_BASIC_OFF = %00000010;	// portb bit value to turn Basic off
	PORTB_SYSTEM_ON = %00000001;	// portb bit value to turn System on

implementation

procedure SystemOff(port_b: byte); assembler; overload;
asm
{
		;lda:cmp:req 20 ;; removed due to problem with nmien = 0 already set
		sei
		mva #0 NMIEN

		mva port_b PORTB
		mwa #__nmi NMIVEC

		lda <__iret
		sta IRQVEC
		sta __vblvec
		sta __dlivec

		lda >__iret
		sta IRQVEC+1
		sta __vblvec+1
		sta __dlivec+1

		mva #$40 NMIEN
		sta __nmien
		bne __stop
__nmi
		bit NMIST
		bpl __vbl
		jmp __dlivec
.def :__dlivec = *-2
		rti
__vbl
		inc rtclok+2
		bne __vblvec-1
		inc rtclok+1
		bne __vblvec-1
		inc rtclok
		jmp __vblvec
.def :__vblvec = *-2
.def :__iret
    	rti
__stop
};
end;

procedure SystemOff;overload;
begin
	SystemOff(PORTB_BASIC_OFF + PORTB_SELFTEST_OFF + %01111100);
end;

procedure SystemReset(port_b: byte); assembler; overload;
asm
{
		;lda:cmp:req 20
		sei
		mva #0 NMIEN
		mva port_b PORTB
		jmp ($fffc)
};
end;

procedure SystemReset; overload;
begin
	SystemReset(PORTB_SYSTEM_ON);
end;

procedure EnableVBLI(vblptr: pointer); assembler;
asm
{
		lda:cmp:req 20
		mva #0 NMIEN
		mwa vblptr __vblvec
		lda __nmien
		ora #$40
		sta NMIEN
		sta __nmien
};
end;

procedure DisableVBLI; assembler;
asm
{
		lda:cmp:req 20
		mva #0 NMIEN
		mwa #__iret __vblvec
		lda __nmien
		ora #$40
		sta NMIEN
		sta __nmien
};
end;

procedure EnableIRQ; assembler;
asm
{ cli };
end;

procedure DisableIRQ; assembler;
asm
{ sei };
end;

procedure SetIRQ(irqptr:pointer); assembler;
asm
{ mwa irqptr $fffe };
end;

procedure EnableDLI(dliptr: pointer); assembler;
asm
{
		lda:cmp:req 20
		mva #0 NMIEN
		mwa dliptr __dlivec
		mva #$c0 NMIEN
		sta __nmien
};
end;

procedure DisableDLI; assembler;
asm
{
		lda:cmp:req 20
		mva #$40 NMIEN
		sta __nmien
};
end;

procedure WaitFrame; assembler;
asm {
    lda:cmp:req rtclok+2
};
end;

procedure WaitFrames(frames: byte);
begin
    while frames>0 do begin
        WaitFrame;
        Dec(frames);
    end;
end;

procedure SetCharset(msb: byte);
begin
    chbase := msb;
end;


end.
