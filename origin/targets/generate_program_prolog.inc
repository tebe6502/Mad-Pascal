procedure GenerateProgramProlog;
var i, j: Integer;
    tmp: Boolean;
    a, header: string;
begin

if Pass = CODEGENERATIONPASS then begin

 tmp := common.optimize.use;
 common.optimize.use := false;

 Gen;

 asm65separator(false);
 asm65('; ' + CompilerTitle);
 asm65separator(false);
 asm65;

 asm65('STACKWIDTH'#9'= 16');

 if target.id = ___a8 then
  asm65('CODEORIGIN'#9'= $'+IntToHex(CODEORIGIN_BASE, 4));

 asm65;

 asm65('TRUE'#9#9'= '+IntToStr(Ident[GetIdent('TRUE')].Value));
 asm65('FALSE'#9#9'= '+IntToStr(Ident[GetIdent('FALSE')].Value));
 asm65('EOL'#9#9'= $'+IntToHex(Ident[GetIdent('EOL')].Value,2));
 asm65('__BUFFER'#9'= $'+IntToHex(Ident[GetIdent('__BUFFER')].Value,4));
 asm65('@BUF'#9#9'= __BUFFER');

 asm65separator;
 asm65;

 asm65(#9'org $' + IntToHex(ZPAGE_BASE, 2));

 asm65;
 asm65('zpage');
 asm65;

 if target.id = ___a8 then begin

  asm65('.if .def(@vbxe_detect)');
  asm65('fxptr'#9'.ds 2','; VBXE pointer');
  asm65('.fi');
  asm65;

 end;

 asm65('.if .def(@AllocMem)||.def(MAIN.SYSTEM.GETMEM)||.def(MAIN.SYSTEM.FREEMEM)');
 asm65('psptr'#9'.ds 2','; PROGRAMSTACK Pointer');
 asm65('.fi');
 asm65;

 asm65('bp'#9'.ds 2');
 asm65('bp2'#9'.ds 2');
 asm65('bp3'#9'= bp+1');
 asm65;

 asm65('eax'#9'.ds 4', ';8 bytes (aex + edx) -> divREAL');
 asm65('edx'#9'.ds 4');
 asm65('ecx'#9'.ds 4');
 asm65;

 asm65('TMP');

 asm65('ztmp');
 asm65('ztmp8'#9'.ds 1');
 asm65('ztmp9'#9'.ds 1');
 asm65('ztmp10'#9'.ds 1');
 asm65('ztmp11'#9'.ds 1');

 if STACK_BASE >= 0 then begin
  asm65;
  asm65(#9'org $'+IntToHex(STACK_BASE, 4));
 end;

 asm65;
 asm65('STACKORIGIN'#9'.ds STACKWIDTH*4');

 asm65('zpend');

 asm65separator;
 asm65;

 asm65('ax'#9'= eax');
 asm65('al'#9'= eax');
 asm65('ah'#9'= eax+1');

 asm65;
 asm65('cx'#9'= ecx');
 asm65('cl'#9'= ecx');
 asm65('ch'#9'= ecx+1');

 asm65;
 asm65('dx'#9'= edx');
 asm65('dl'#9'= edx');
 asm65('dh'#9'= edx+1');

if (target.id = ___neo) then begin
 asm65;
 asm65('FP1MAN0 = VAR1_B0');
 asm65('FP1MAN1 = VAR1_B1');
 asm65('FP1MAN2 = VAR1_B2');
 asm65('FP1MAN3 = VAR1_B3');
 asm65;
 asm65('FP2MAN0 = VAR2_B0');
 asm65('FP2MAN1 = VAR2_B1');
 asm65('FP2MAN2 = VAR2_B2');
 asm65('FP2MAN3 = VAR2_B3');
 asm65;
 asm65('FPMAN0 = FP1MAN0');
 asm65('FPMAN1 = FP1MAN1');
 asm65('FPMAN2 = FP1MAN2');
 asm65('FPMAN3 = FP1MAN3');
end else begin
 asm65;
 asm65(#9'org eax');
 asm65;
 asm65('FP1MAN0'#9'.ds 1');
 asm65('FP1MAN1'#9'.ds 1');
 asm65('FP1MAN2'#9'.ds 1');
 asm65('FP1MAN3'#9'.ds 1');
 asm65;
 asm65(#9'org edx');
 asm65;
 asm65('FP2MAN0'#9'.ds 1');
 asm65('FP2MAN1'#9'.ds 1');
 asm65('FP2MAN2'#9'.ds 1');
 asm65('FP2MAN3'#9'.ds 1');
 asm65;
 asm65(#9'org ecx');
 asm65;
 asm65('FPMAN0'#9'.ds 1');
 asm65('FPMAN1'#9'.ds 1');
 asm65('FPMAN2'#9'.ds 1');
 asm65('FPMAN3'#9'.ds 1');
end;

 asm65;
 asm65(#9'org ztmp8');
 asm65;
 asm65('FP1SGN'#9'.ds 1');
 asm65('FP1EXP'#9'.ds 1');

 asm65;
 asm65(#9'org ztmp10');
 asm65;
 asm65('FP2SGN'#9'.ds 1');
 asm65('FP2EXP'#9'.ds 1');

 asm65;
 asm65(#9'org bp2');
 asm65;
 asm65('FPSGN'#9'.ds 1');
 asm65('FPEXP'#9'.ds 1');


 if (target.id = ___a8) and (LIBRARY_USE = FALSE) then begin

  if RCLIBRARY then begin
    asm65;
    asm65(#9'org MAIN.SYSTEM.__PORTB_BANKS+$40');
    asm65(#9'icl ''atari\xmsproc.asm''');
  end;

  asm65;
  asm65(#9'.ifdef MAIN.@DEFINES.BASICOFF');
  asm65(#9'org CODEORIGIN');
  asm65(#9'icl ''atari\basicoff.asm''');
  asm65(#9'ini CODEORIGIN');
  asm65(#9'.fi');

  asm65;
  asm65(#9'.ifdef MAIN.@DEFINES.S_VBXE');
  asm65(#9'opt h-');
  asm65(#9'ins ''atari\s_vbxe\sdxld2.obx''');
  asm65(#9'opt h+');
  asm65(#9'.fi');

 end;


// if (High(resArray) > 0) and (target.id = ___a8) and LIBRARY_USE then
// asm65(#9'ert ''Resources in LIBRARY not allowed''');


 if (High(resArray) > 0) and (target.id = ___a8) and (LIBRARY_USE = FALSE) then begin

  asm65;
  asm65(#9'org CODEORIGIN');
  asm65;
  asm65('.local'#9'MAIN.@RESOURCE');
  asm65('.endl');

  asm65;
  asm65('.local'#9'RESOURCE');

  asm65(#9'icl ''atari\resource.asm''');

  asm65(#9'?EXTDETECT = 0');
  asm65(#9'?VBXDETECT = 0');

  asm65;

  for i := 0 to High(resArray) - 1 do
   if resArray[i].resStream = false then begin
    a:=#9+resArray[i].resType+' '''+resArray[i].resFile+''''+' ';

    a:=a+resArray[i].resFullName;

    for j := 1 to MAXPARAMS do a:=a+' '+resArray[i].resPar[j];

    asm65(a);
   end;

  asm65('.endl');
 end;

 asm65separator;


 if target.id = ___a8 then begin

  asm65;
  asm65(#9'org CODEORIGIN');

 end else begin

  for header in target.header do
   if (header = 'END') then break else
    if header <> '' then asm65(#9'' + header) else asm65;

  if (target.id = ___raw) then begin

   asm65;
   asm65(#9'opt h-f+');
   asm65;
   asm65(#9'org $' + IntToHex(target.codeorigin, 4));
   asm65(#9'jmp START');
   asm65;

   CODEORIGIN_BASE := target.codeorigin + 3;

  end else if (target.id = ___neo) then begin

   asm65;
   asm65(#9'opt h-f+c+');
   asm65;
   asm65(#9'org $' + IntToHex(target.codeorigin, 4));
   asm65(#9'jmp START');
   asm65;

   CODEORIGIN_BASE := target.codeorigin + 3;

  end;

  asm65('CODEORIGIN');

 end;


// asm65(#13#10#9'jmp start');


// Build static string data table
 for i := 0 to NumStaticStrChars - 1 do Gen;      // db StaticStringData[i]

 asm65;
 asm65(#9'STATICDATA');


 asm65separator;

 asm65;
 asm65('RTLIB');


 if target.id = ___a8 then
  asm65(#9'icl ''rtl6502_a8.asm''')
 else
  asm65(#9'icl ''rtl6502_' + AnsiLowerCase(target.name) + '.asm''');

 asm65;
 asm65('.print ''ZPAGE: '',zpage,''..'',zpend-1');

 asm65;
 asm65('.print ''RTBUF: '',@buf,''..'',@buf+255');

 asm65;
 asm65('.print ''RTLIB: '',RTLIB,''..'',*-1');

 asm65separator;

 asm65;
 asm65('START');


 if LIBRARY_USE then asm65(#9'stx MAIN.@regX+1');

 
 asm65(#9'tsx');
 asm65(#9'stx MAIN.@halt+1');
 asm65;


 if (target.id = ___a8) and (LIBRARY_USE = FALSE) then begin

  asm65(#9'.ifdef MAIN.@DEFINES.ROMOFF');
  asm65(#9'icl ''atari\romoff.asm''');
  asm65(#9'.fi');
  asm65;

 end;


 if FastMul > 0 then begin asm65(#9'fmulinit'); asm65; end;


 if (LIBRARY_USE = FALSE) then begin

  asm65('VLEN'#9'= VARDATASIZE-VARINITSIZE');
  asm65('VADR'#9'= DATAORIGIN+VARINITSIZE');
  asm65;

  if (target.id = ___a8) then begin
   asm65(#9'ift (VADR > $BFFF) && .not(.def MAIN.@DEFINES.ROMOFF)');
   asm65(#9'ert ''Invalid memory address range '',VADR');
   asm65(#9'eif');
   asm65;
  END;

  asm65(#9'ift (VLEN > 0) && (VLEN <= 256)');
  asm65(#9'ldx #256-VLEN');
  asm65(#9'lda #$00');
  asm65(#9'sta:rne VADR+VLEN-256,x+');
  asm65(#9'eli VLEN>256');
  asm65(#9'm@init');
  asm65(#9'eif');
  asm65;

 end;


 asm65('.ifdef psptr');
 asm65(#9'mwa #PROGRAMSTACK psptr');
 asm65('.fi');
 asm65;


 if (target.id in [___c64, ___c4p]) then begin

  asm65(#9'lda #$0e');
  asm65(#9'jsr $ffd2','; shifted charset');
  asm65;

 end;


 if (target.id = ___neo) then begin

   asm65(#9'stz $FF04','; set radians as default');
   asm65(#9'mva #35 $FF01');
   asm65(#9'mva #4  $FF00');

 end;


 if (target.id = ___a8) and (LIBRARY_USE = FALSE) then begin

  asm65(#9'ldx #$00','; X = 0');
  asm65(#9'stx bp','; BP = 0');
  asm65;

  asm65(#9'stx audctl','; reset POKEY');
  asm65(#9'stx audctl+$10');
  asm65(#9'lda #3');
  asm65(#9'sta skctl');
  asm65(#9'sta skctl+$10');
  asm65;
  asm65(#9'dex','; X = 255');
  asm65;

 end else begin

  asm65(#9'ldx #$00');
  asm65(#9'stx bp','; BP = 0');
  asm65;
  asm65(#9'dex','; X = 255');
  asm65;

 end;


 if target.cpu <> CPU_6502 then asm65(#9'opt c+');


 asm65(#9'UNITINITIALIZATION');
 asm65;

 common.optimize.use := tmp;
end;

end;
