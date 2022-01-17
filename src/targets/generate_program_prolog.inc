procedure GenerateProgramProlog;
var i, j: Integer;
    tmp: Boolean;
    a: string;
begin

if Pass = CODEGENERATIONPASS then begin

 tmp := optimize.use;
 optimize.use := false;

 Gen;

 asm65separator(false);
 asm65('; ' + CompilerTitle);
 asm65separator(false);
 asm65;

 asm65('STACKWIDTH'#9'= 16');

 if target.id = 'a8' then
  asm65('CODEORIGIN'#9'= $'+IntToHex(CODEORIGIN_BASE, 4));

// if target.id = 'raw' then
//  asm65('CODEORIGIN'#9'= $'+IntToHex(target.codeorigin, 4));

 asm65;

 asm65('TRUE'#9#9'= '+IntToStr(Ident[GetIdent('TRUE')].Value));
 asm65('FALSE'#9#9'= '+IntToStr(Ident[GetIdent('FALSE')].Value));

 asm65separator;
 asm65;

 if ZPAGE_Atari > 0 then
  asm65(#9'org $'+IntToHex(ZPAGE_Atari, 2))
 else begin
  asm65(#9''+target.zpage);
 end;

 asm65;
 asm65('zpage');
 asm65;

 if target.id = 'a8' then begin

  asm65('.ifdef @vbxe_detect');
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

 if STACK_Atari > 0 then begin
  asm65;
  asm65(#9'org $'+IntToHex(STACK_Atari, 4));
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


 asm65;
 asm65(#9'org eax');
 asm65;
 asm65('FP1MAN0'#9'.ds 1');
 asm65('FP1MAN1'#9'.ds 1');
 asm65('FP1MAN2'#9'.ds 1');
 asm65('FP1MAN3'#9'.ds 1');

 asm65;
 asm65(#9'org ztmp8');
 asm65;
 asm65('FP1SGN'#9'.ds 1');
 asm65('FP1EXP'#9'.ds 1');

 asm65;
 asm65(#9'org edx');
 asm65;
 asm65('FP2MAN0'#9'.ds 1');
 asm65('FP2MAN1'#9'.ds 1');
 asm65('FP2MAN2'#9'.ds 1');
 asm65('FP2MAN3'#9'.ds 1');

 asm65;
 asm65(#9'org ztmp10');
 asm65;
 asm65('FP2SGN'#9'.ds 1');
 asm65('FP2EXP'#9'.ds 1');

 asm65;
 asm65(#9'org ecx');
 asm65;
 asm65('FPMAN0'#9'.ds 1');
 asm65('FPMAN1'#9'.ds 1');
 asm65('FPMAN2'#9'.ds 1');
 asm65('FPMAN3'#9'.ds 1');

 asm65;
 asm65(#9'org bp2');
 asm65;
 asm65('FPSGN'#9'.ds 1');
 asm65('FPEXP'#9'.ds 1');

 if target.id = 'a8' then begin
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

 if (High(resArray) > 0) and (target.id = 'a8') then begin

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


 if target.id = 'a8' then begin
  asm65;
  asm65(#9'org CODEORIGIN');
 end else begin
  for header in target.header do
   if (header = 'END') then break else
    if header <> '' then asm65(#9''+header) else asm65;

  if target.id = 'raw' then begin

   asm65;
   asm65(#9'opt h-f+');
   asm65;
   asm65(#9'org $' + IntToHex(raw.codeorigin, 4));
   asm65(#9'jmp START');
   asm65;

   CODEORIGIN_BASE := target.codeorigin + 3;

  end else
   CODEORIGIN_BASE := target.codeorigin;

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

 asm65(#9'icl ''rtl6502_'+target.id+'.asm''');

 asm65;

 asm65('.print ''ZPAGE: '',zpage,''..'',zpend-1');

 asm65;
 asm65('.print ''RTLIB: '',RTLIB,''..'',*-1');

 asm65separator;


 asm65;
 asm65('START');

 Gen; Gen; Gen;             // mov bx, :STACKORIGIN
// asm65(#9'mwa #:STACKORIGIN bx', '; mov bx, :STACKORIGIN');

 asm65(#9'tsx');
 asm65(#9'stx MAIN.@halt+1');
// asm65(#9'mva #$ff portb');


 asm65;
 asm65(#9'.ifdef fmulinit');
 asm65(#9'fmulinit');
 asm65(#9'.fi');


 asm65;
 asm65('VLEN'#9'= VARDATASIZE-VARINITSIZE');
 asm65('VADR'#9'= DATAORIGIN+VARINITSIZE');
 asm65;
 asm65(#9'ift VADR > $BFFF');
 asm65(#9'ert ''Invalid memory address range '',VADR');
 asm65(#9'eli (VLEN>0) && (VLEN<=256)');
 asm65(#9'ldx #256-VLEN');
 asm65(#9'lda #$00');
 asm65(#9'sta:rne VADR+VLEN-256,x+');
 asm65(#9'eli VLEN>256');
 asm65(#9'@fill #VADR #VLEN #$00');
 asm65(#9'eif');
 asm65;

 asm65('.ifdef :psptr');
 asm65(#9'mwa #PROGRAMSTACK :psptr');
 asm65('.fi');
 asm65;


 if (target.id = 'c64') or (target.id = 'c4p') then begin

  asm65(#9'lda #$0e');
  asm65(#9'jsr $ffd2','; shifted charset');

 end;



 if target.id = 'a8' then begin

  asm65(#9'.ifdef MAIN.@DEFINES.ROMOFF');
  asm65(#9'icl ''atari\romoff.asm''');
  asm65(#9'.fi');
  asm65;

  asm65(#9'ldx #$0F','; DOS II+/D ParamStr');     // DOS II+/D ParamStr
  asm65(#9'mva:rpl $340,x MAIN.IOCB@COPY,x-');
  asm65;

  asm65(#9'inx','; X = 0');
  asm65(#9'stx bp','; BP = 0');

  asm65;
  asm65(#9'stx skctl','; reset POKEY');
  asm65(#9'lda #3');
  asm65(#9'sta skctl');
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


// if CPUMode = 65816 then asm65(#9'opt c+');


 asm65;
 asm65(#9'UNITINITIALIZATION');

 optimize.use := tmp;
end;

end;
