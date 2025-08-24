unit sam;
(*
@type: unit
@author: Don't Ask Software, Sidney Cadot, Tomasz 'Tebe' Biela
@name: Software Automatic Mouth

@version: 1.0

@description:

<https://github.com/sidneycadot/sam/tree/main/assembly>

<https://discordier.github.io/sam/>

zeropage: $CB..$FF

*)


interface

const
	DEFAULT_SPEED_L1 = $41;
	DEFAULT_PITCH_L1 = $40;
	DEFAULT_SPEED_L0 = $46;
	DEFAULT_PITCH_L0 = $40;

	procedure say(s: string); overload;
	procedure say(video: Boolean; speed, pitch: byte); overload; assembler;
	procedure say; overload; assembler;


implementation

{$link sam\sam_reloc.obj}
	
{$link sam\reciter_reloc.obj}


procedure say(video: Boolean; speed, pitch: byte); overload; assembler;
asm
 ldy speed

 lda video
 sta LIGHTS

 beq off

 sty SPEED_L1
 lda pitch
 sta PITCH_L1
 
 jmp @exit

off

 sty SPEED_L0
 lda pitch
 sta PITCH_L0

end;


procedure say(s: string); overload;
var i: byte;
     p: PChar register;
begin
 
  if s[0] <> #0 then begin

     asm  
	mwa #SAM_BUFFER p
     end;

   for i:=1 to length(s) do begin
    p[0]:=s[i];
    inc(p);
   end;

   p[0] := #$9b;

     asm
	txa:pha

	jsr RECITER_VIA_SAM_FROM_MACHINE_LANGUAGE
	jsr SAM_SAY_PHONEMES

	pla:tax
     end;
  
  end;
 
end;
 
 
procedure say; overload; assembler;
asm
	txa:pha

	jsr SAM_SAY_PHONEMES

	pla:tax
end;



end.




