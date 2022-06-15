// changes 2020-01-12

uses	crt, misc, atari;

var	i, bnk: shortint;
	a: Boolean;
	p: word;
	cpu: byte;

//{$define romoff}

begin

 lmargin:=1;

 writeln;

(* ------------------------------- *)
(* ---		CPU 		-- *)
(* ------------------------------- *)

 write('    CPU: ');

 cpu:=DetectCPU;

 case cpu of
  0: write('6502');
  1: write('65c02')
 else
  write('65816')
 end;

 writeln(' ',DetectCPUSpeed,' MHz');


(* ------------------------------- *)
(* ---		EVIE 		-- *)
(* ------------------------------- *)

// writeln('Evie: ', DetectEvie);


(* ------------------------------- *)
(* ---		VBXE 		-- *)
(* ------------------------------- *)

 a:=DetectVBXE(p);

 write('   VBXE: ', a);
 if a then begin
  write(' ($',HexStr(p shr 8, 2),'00), CORE 1.',HexStr(p and $7f,2));
  if p and $80<>0 then write(' RAMBO');
 end;
 writeln;


(* ------------------------------- *)
(* ---	     GTIA		-- *)
(* ------------------------------- *)
{
 write('   GTIA: ');

 case TVSystem of
   1: writeln('PAL');
  15: writeln('NTSC');
 else
  writeln('UNKNOWN')
 end;
}

(* ------------------------------- *)
(* ---	     ANTIC		-- *)
(* ------------------------------- *)

 write('  ANTIC: ');

 case DetectANTIC of
   true: writeln('PAL');
  false: writeln('NTSC');
 end;


(* ------------------------------- *)
(* ---	        BASIC		-- *)
(* ------------------------------- *)

 write('  Basic: ');

 case DetectBASIC of
    0: writeln('ROM OFF');
  162: writeln('Atari Basic Rev.A');
   96: writeln('Atari Basic Rev.B');
  234: writeln('Atari Basic Rev.C');
 else
  writeln('UNKNOWN')
 end;


(* ------------------------------- *)
(* ---		SYSTEM 		-- *)
(* ------------------------------- *)

 write(' System: ');

 case DetectOS of
    1: writeln('XL/XE OS Rev.1');
    2: writeln('XL/XE OS Rev.2');
    3: writeln('XL/XE OS Rev.3');
    4: writeln('XL/XE/XEGS OS Rev.4');
   10: writeln('XL/XE OS Rev.10');
   11: writeln('XL/XE OS Rev.11');
   59: writeln('XL/XE OS Rev.3B');
   64: writeln('QMEG+OS 4.04');
  253: writeln('QMEG+OS RC01');
 else
  if portb and 1 = 0 then
   writeln('ROM OFF')
  else
   writeln('UNKNOWN');
 end;


(* ------------------------------- *)
(* ---		STEREO 		-- *)
(* ------------------------------- *)

 writeln(' Stereo: ', DetectStereo);


(* ------------------------------- *)
(* ---		MAPRAM 		-- *)
(* ------------------------------- *)

 writeln(' MapRam: ', DetectMapRam);


(* ------------------------------- *)
(* ---		HIGHMEM		-- *)
(* ------------------------------- *)

 if cpu>127 then
  writeln('HighMem: ', (DetectHighMem and $00ff)*64 ,'KB' );


(* ------------------------------- *)
(* ---	     EXTENDED MEM	-- *)
(* ------------------------------- *)

 bnk:=DetectMEM;
 writeln(' ExtMem: ', bnk,' banks');

 for i:=0 to bnk-1 do begin

  if i mod 8 = 0 then begin writeln; write(#$7f#31#31#31) end;

  write(HexStr(banks[i],2),' ');

 end;

 writeln(#$9b);
 writeln('Press any key');

 repeat until keypressed;

end.
