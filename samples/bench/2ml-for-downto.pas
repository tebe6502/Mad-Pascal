// 591

// Effectus auto-generated Mad Pascal source code listing
program testPrg;

uses
  Crt;

const
  DL : array[0..8] of byte = ($70, $70, $70, $42, $E0, $00, $41, $00, $20);

var

  A : byte absolute $E0;
  B : byte absolute $E1;
  C : byte absolute $E2;
  D : byte absolute $E3;
  E : byte absolute $E4;
  F : byte absolute $E5;
  G : byte absolute $E6;
  RT2 : byte absolute $14;
  RT1 : byte absolute $13;
  CHBAS : byte absolute $2F4;
var
  SDLSTL : word absolute $230;


procedure MAINProc;
begin
  Move(pointer($E080), pointer($4000),  80);
  CHBAS := $40;
  SDLSTL := word(@DL);

  pause(1);

  RT1 := 0;
  RT2 := 0;
 for a:=1 downto 0 do
	  for b:=9 downto 0 do
		 for c:=9 downto 0 do
			 for d:=9 downto 0 do
				 for e:=9 downto 0 do
					 for f:=9 downto 0 do
						 for g:=9 downto 0 do ;

  TextMode(0);
  Write(RT1*256+RT2);
  repeat
  until false;
end;

begin
  MAINProc;
end.
