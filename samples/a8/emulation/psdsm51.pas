{
*  Programowy Symulator DSM-51 v. 0.1
*  by Noname, Erni and Gawor (98?/00/25)
}

program PSDSM51;

uses
  SysUtils, Crt, PMG;

Const
  // Rozmiary rozkazow
  OpCodeSize: array[Byte] of Byte = (
    1,2,3,1,1,2,1,1,1,1,1,1,1,1,1,1,
    3,2,3,1,1,2,1,1,1,1,1,1,1,1,1,1,
    3,2,1,1,2,2,1,1,1,1,1,1,1,1,1,1,
    3,2,1,1,2,2,1,1,1,1,1,1,1,1,1,1,
    2,2,2,3,2,2,1,1,1,1,1,1,1,1,1,1,
    2,2,2,3,2,2,1,1,1,1,1,1,1,1,1,1,
    2,2,2,3,2,2,1,1,1,1,1,1,1,1,1,1,
    2,2,2,1,2,3,2,2,2,2,2,2,2,2,2,2,
    2,2,2,1,1,3,2,2,2,2,2,2,2,2,2,2,
    3,2,2,1,2,2,1,1,1,1,1,1,1,1,1,1,
    2,2,2,1,1,1,2,2,2,2,2,2,2,2,2,2,
    2,2,2,1,3,3,3,3,3,3,3,3,3,3,3,3,
    2,2,2,1,1,2,1,1,1,1,1,1,1,1,1,1,
    2,2,2,1,1,3,1,1,2,2,2,2,2,2,2,2,
    1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1,
    1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1 );

var
  // Nazwy rejestrow bitowych
  BitRegName: array[0..95] of String[5] = (
 {80}   'P0.0','P0.1','P0.2','P0.3','P0.4','P0.5','P0.6','P0.7',
 {88}   'IT0','IE0','IT1','IE1','TR0','TF0','TR1','TF1',
 {90}   'P1.0','P1.1','P1.2','P1.3','P1.4','P1.5','P1.6','P1.7',
 {98}   'RI','TI','RB8','TB8','REN','SM2','SM1','SM0',
 {A0}   'P2.0','P2.1','P2.2','P2.3','P2.4','P2.5','P2.6','P2.7',
 {A8}   'EX0','ET0','EX1','ET1','ES','ET2','IE6','EA',
 {B0}   'P3.0','P3.1','P3.2','P3.3','P3.4','P3.5','P3.6','P3.7',
 {B8}   'PX0','PT0','PX1','PT1','PS','PT2','IP6','IP7',
 {C8}   'RL2','T2','TR2','EXEN2','TCLK','RCLK','EXF2','TF2',
 {D0}   'P','PSW.1','OV','RS0','RS1','F0','AC','CY',
 {E0}   'A.0','A.1','A.2','A.3','A.4','A.5','A.6','A.7',
 {F0}   'B.0','B.1','B.2','B.3','B.4','B.5','B.6','B.7');

const
  // Mapa nazw rejestrow bitowych
  BitRegNameMap: array[0..127] of Byte = (
 {80}   0,1,2,3,4,5,6,7,
        8,9,$a,$b,$c,$d,$e,$f,
 {90}   $10,$11,$12,$13,$14,$15,$16,$17,
        $18,$19,$1a,$1b,$1c,$1d,$1e,$1f,
 {A0}   $20,$21,$22,$23,$24,$25,$26,$27,
        $28,$29,$2a,$2b,$2c,$2d,$2e,$2f,
 {B0}   $30,$31,$32,$33,$34,$35,$36,$37,
        $38,$39,$3a,$3b,$3c,$3d,$3e,$3f,
 {C0}   $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        $40,$41,$42,$43,$44,$45,$46,$47,
 {D0}   $48,$49,$4a,$4b,$4c,$4d,$4e,$4f,
        $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
 {E0}   $50,$51,$52,$53,$54,$55,$56,$57,
        $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
 {F0}   $58,$59,$5a,$5b,$5c,$5d,$5e,$5f,
        $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);

var
  // Nazwy rejestrow
  RegName: array[0..25] of String[6] = (
 {80}   'P0','SP','DPL','DPH','PCON',
        'TCON','TMOD','TL0','TL1','TH0','TH1',
 {90}   'P1',
        'SCON','SBUF',
 {A0}   'P2',
        'IE',
 {B0}   'P3',
        'IP',
 {C0}
        'T2CON','RCAP2L','RCAP2H','TL2','TH2',
 {D0}   'PSW',

 {E0}   'A',

 {F0}   'B'
        );
const
  // Mapa rejestrow
  RegNameMap: array[0..127] of Byte = (
 {80}   0,1,2,3,$ff,$ff,$ff,4,
        5,6,7,8,9,10,$ff,$ff,
 {90}   11,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        12,13,$ff,$ff,$ff,$ff,$ff,$ff,
 {A0}   14,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        15,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
 {B0}   16,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        17,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
 {C0}   $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        18,$ff,19,20,21,22,$ff,$ff,
 {D0}   23,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
 {E0}   24,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
 {F0}   25,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
        $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);

  // Mnemoniki
  OpCodeName: array[0..44] of String[5] = (
    {0}'NOP', {1}'AJMP', {2}'LJMP', {3}'RR', {4}'INC', {5}'JBC',
    {6}'ACALL', {7}'LCALL', {8}'RRC', {9}'DEC', {10}'JB', {11}'RET',
    {12}'RL', {13}'ADD', {14}'JNB', {15}'RETI', {16}'RLC', {17}'ADDC',
    {18}'JC', {19}'ORL', {20}'JNC', {21}'ANL', {22}'JZ', {23}'XRL',
    {24}'JNZ', {25}'JMP', {26}'MOV', {27}'SJMP', {28}'MOVC', {29}'DIV',
    {30}'SUBB', {31}'MUL', {32}'reser', {33}'CPL', {34}'CJNE',
    {35}'PUSH', {36}'CLR', {37}'SWAP', {38}'XCH', {39}'POP', {40}'SETB',
    {41}'DA', {42}'DJNZ', {43}'XCHD', {44}'MOVX');

  // Mapa mnemonikow
  OpCodeNameMap: array[Byte] of Byte = (
    0, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 6, 7, 8, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 9, 10, 1, 11, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
    13, 13, 14, 6, 15, 16,  17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18,
    1, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 6, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 1, 23, 23, 23, 23, 23,
    23, 23, 23, 23, 23, 23, 23, 23, 23, 24, 6, 19, 25, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 26, 26, 26, 27, 1, 21, 28, 29, 26, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 26, 6, 26, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
    19, 1, 26, 4, 31, 32, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 21, 6, 33, 33,
    34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 35, 1, 36, 36, 37, 38, 38,
    38, 38, 38, 38, 38, 38, 38, 38, 38, 39, 6, 40, 40, 41, 42, 43, 43, 42, 42,
    42, 42, 42, 42, 42, 42, 44, 1, 44, 44, 36, 26, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 44, 6, 44, 44, 33, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26);

  // Rejestry
  RegP0=$80;      RegP1=$90;      RegP2=$A0;      RegP3=$B0;
  RegSP=$81;
  RegDPL=$82;     RegDPH=$83;
  RegSBUF=$99;
  RegIE=$A8;
  RegPSW=$D0;
  RegACC=$E0;     RegB=$F0;
  BitRI=$98;      BitTI=$99;
  BitP=$D0;       BitOV=$D2;      BitAC=$D6;      BitCY=$D7;

var
  // Grafiki P/M dla "Test LED" i "Buzzer"
  PG_LED: array[0.._P_MAX] of Byte = (
    {%11111111,
    %11011111,
    %11011111,
    %11011111,
    %11011111,
    %11011111,
    %11000011,
    %11111111,}

    %11111111,
    %10001111,
    %11011111,
    %11011111,
    %11110111,
    %11110111,
    %11110001,
    %11111111,
    0, 0, 0, 0, 0, 0, 0);

  PG_BUZZER: array[0.._P_MAX] of Byte = (
    %11111111,
    %11000111,
    %11011011,
    %11000111,
    %11011011,
    %11011011,
    %11000111,
    %11111111,
    0, 0, 0, 0, 0, 0, 0);

const
  // Rozmiar pamieci CODE
  XCODE_SIZE = 1024 * 6;
  // Rozmiar pamieci DATA
  XDATA_SIZE = 1024 * 6;
  // Maksymalna liczba pulapek
  MAX_BREAKPOINTS = 16;

  // Adresy podprogramow w EPROM
  DR_WRITE_TEXT = $8100;
  DR_WRITE_DATA = $8102;
  DR_WRITE_HEX = $8104;
  DR_WRITE_INSTR = $8106;
  DR_LCD_INIT = $8108;
  DR_LCD_OFF = $810A;
  DR_LCD_CLR = $810C;
  DR_DELAY_US = $810E;
  DR_DELAY_MS = $8110;
  DR_DELAY_100MS = $8112;
  DR_WAIT_ENTER = $8114;
  DR_WAIT_ENTER_NW = $8116;
  DR_TEST_ENTER = $8118;
  DR_WAIT_ENT_ESC = $811A;
  DR_WAIT_KEY = $811C;
  DR_GET_NUM = $811E;
  DR_BCD_HEX = $8120;
  DR_HEX_BCD = $8122;
  DR_MUL_2_2 = $8124;
  DR_MUL_3_1 = $8126;
  DR_DIV_2_1 = $8128;
  DR_DIV_4_2 = $812A;

var
  // Pamiec CODE
  xCODE: array[0..XCODE_SIZE - 1] of Byte;
  // Pamiec DATA
  xDATA: array[0..XDATA_SIZE - 1] of Byte;
  // Pamiec RAM
  iRAM: array[Byte] of Byte;
  // SFR. Nieużywane dolne 128 bajtów jako bufor 'StrBuf'
  SFR: array[Byte] of Byte;
  // Licznik programu - rejestr PC
  PC: Word;
  // Czy pamiec wspoldzielona
  SharedMem: Boolean;
  // Lancuch pomocniczy. Niewykorzystane dolne 128 bajtow zmiennej SFR
  StrBuf: String[125] absolute SFR;
  // Aktualna pozycja bufora
  StrBufIdx: Byte;

  // Aktualna instrukcja
  OpCode1: Byte register;
  OpCode2: Byte register;
  OpCode3: Byte register;
  OpL: Byte register;
  OpH: Byte register;
  OpLen: Byte register;

  // Zdekodowane polecenie
  Command, SubCommand: Char;
  // Parametry polecenia
  CmdParam1: String[5];
  CmdParam2: String[64];
  // Pomocnicze adresy polecenia
  TmpAddr: Word;
  TmpAddr2: Word;
  TmpAddr3: Word;
  TmpPB: PByte;
  // Pulapki
  Breakpoints: array[0..MAX_BREAKPOINTS - 1] of Word;
  // Zawartosc LCD
  LCD: array[0..$1F] of Char;
  // Pozycja kursora LCD
  LCDIdx: Byte;
  // Poprzednia wartosc portu P.1 dla grafiki P/M
  OldP1: Byte;

// Pobierz pamiec CODE
function GetMemCode(AAddr: Word): Byte;
begin
  if (SharedMem and (AAddr < XCODE_SIZE + XDATA_SIZE)) or ((not SharedMem) and (AAddr < XCODE_SIZE)) then
    Result := xCODE[AAddr]
  else
    Result := 0;
end;

// Pobierz pamiec DATA
function GetMemData(AAddr: Word): Byte;
begin
  if SharedMem and (AAddr < XDATA_SIZE + XCODE_SIZE) then
    Result := xCODE[AAddr]
  else if (not SharedMem) and (AAddr < XDATA_SIZE) then
    Result := xDATA[AAddr]
  else
    Result := 0;
end;

// Ustaw pamiec DATA
procedure SetMemData(AAddr: Word; AValue: Byte);
begin
  if SharedMem and (AAddr < XDATA_SIZE + XCODE_SIZE) then
    xCODE[AAddr] := AValue
  else if (not SharedMem) and (AAddr < XDATA_SIZE) then
    xDATA[AAddr] := AValue;
end;

// Pobierz pamiec RAM/SFR
function GetMemRam(AAddr: Byte): Byte;
begin
  if AAddr < $80 then
    Result := iRAM[AAddr]
  else
    Result := SFR[AAddr];
end;

// Ustaw pamiec RAM/SFR
procedure SetMemRam(AAddr: Byte; AValue: Byte);
begin
  if AAddr < $80 then
    iRAM[AAddr] := AValue
  else
    SFR[AAddr] := AValue;
end;

// Pobierz rejestr bitowy
function GetBit(ABitNum: Byte): Boolean;
var
  AdrBit, Mask: byte;
begin
  if ABitNum < $80 then
    Result := ((iRAM[$20+(ABitNum div 8)] and (1 shl (ABitNum and 7)))>0)
  else
  begin
    AdrBit := ABitNum and $F8;
    Mask := 1 shl (ABitNum and 7);
    Result := ((SFR[AdrBit] and Mask)>0);
  end;
end;

// Ustaw rejestr bitowy
procedure SetBit(ABitNum: Byte; AValue: Boolean);
var
  AdrBit, MAnd, MOr: byte;
begin
  MOr := 1 shl (ABitNum and 7);
  if AValue then
    MAnd := $FF
  else
  begin
    MAnd := not(MOr);
    MOr := 0;
  end;

  if ABitNum < $80 then
  begin
    AdrBit := $20 + (ABitNum shr 3);
    iRAM[AdrBit] := (iRAM[AdrBit] or MOr) and MAnd;
  end
  else
  begin
    AdrBit := ABitNum and $F8;
    SFR[AdrBit] := (SFR[AdrBit] or MOr) and MAnd;
  end;
end;

// Pobierz rejestr z aktualnego banku
function GetReg(AReg: Byte): Byte;
begin
  Result := iRAM[AReg + (SFR[RegPSW] and $18)];
end;

// Odloz na stos
procedure Push(AValue: Byte);
begin
  Inc(SFR[RegSP]);
  iRAM[SFR[RegSP]] := AValue;
end;

// Zdejmij ze stosu
function Pop: Byte;
begin
  Result := iRAM[SFR[RegSP]];
  Dec(SFR[RegSP]);
end;

// Odloz rejestr PC na stos
procedure PushPC;
begin
  Push(Lo(PC));
  Push(Hi(PC));
end;

// Zdejmij rejestr PC ze stosu
procedure PopPC;
var
  B1, B2: Byte;
begin
  B1 := Pop;
  B2 := Pop;
  PC := (B1 shl 8) + B2;
end;

// Pobierz rejestr DPTR
function GetDPTR: Word;
begin
  Result := (Word(SFR[RegDPH]) shl 8) + SFR[RegDPL];
end;

// Dodawanie z przeniesieniem
procedure ADDC(AValue: Byte; Cy: Boolean);
var
  ValC: Byte;
begin
  if Cy then
    ValC := 1
  else
    ValC := 0;
  Cy := ((Word(SFR[RegACC]) + AValue + ValC) > $FF);
  SetBit(BitCY, Cy);

  SetBit(BitAC, ((SFR[RegACC] and $F) + (AValue and $F) + ValC) > $F);
  SetBit(BitOV, Cy xor (((SFR[RegACC] and $7F) + (AValue and $7F) + ValC) > $7F));
  Inc(SFR[RegACC], AValue + ValC);
  SetBit(BitP, not Odd(SFR[RegACC]));
end;

// Odejmowanie
procedure SUBB(AValue: Byte);
var
  ValC: SmallInt;
  Carry: Boolean;
begin
  Carry := GetBit(BitCY);
  if Carry then
    ValC := 1
  else
    ValC := 0;
  Carry := ((SmallInt(SFR[RegACC]) - SmallInt(AValue) - ValC) < 0);
  SetBit(BitCY, Carry);

  SetBit(BitAC, (SmallInt(SFR[RegACC] and $F) - SmallInt(AValue and $F) - ValC) < 0);
  SetBit(BitOV, Carry xor ((SmallInt(SFR[RegACC] and $7F) - SmallInt(AValue and $7F) - ValC) < 0));
  Dec(SFR[RegACC], AValue + ValC);
  SetBit(BitP, not Odd(SFR[RegACC]));
end;

// Aktualizuj znacznik parzystosci
procedure UpdateParityFlag;
var
  B, C: Byte;
begin
  B := GetMemRam(RegACC);
  C := 0;
  while B <> 0 do
  begin
    if B and 1 <> 0 then
      Inc(C);
    B := B shr 1;
  end;
  SetBit(BitP, Odd(C));
end;

// Dekoduj instrukcje o adresie
procedure FetchOpcode(AAddres: Word);
begin
  OpCode1 := GetMemCode(AAddres);
  OpCode2 := GetMemCode(AAddres + 1);
  OpCode3 := GetMemCode(AAddres + 2);
  OpLen := OpCodeSize[OpCode1];
  OpL := OpCode1 and $F;
  OpH := OpCode1 shr 4;
end;

// Wykonaj pojedyncza  instrujcje
procedure Step;
var
  b: Byte;
  w: Word;
  cy: Boolean;
begin
  FetchOpcode(PC);
  Inc(PC, OpLen);
  case OpL of
    $0: case OpH of
      { NOP }
      $0: ;
      {JBC}
      $1: begin
        if GetBit(OpCode2) then
        begin
          SetBit(OpCode2, False);
          Inc(PC, ShortInt(OpCode3));
        end;
      end;
      {JB}
      $2: begin
        if GetBit(OpCode2) then
          Inc(PC, ShortInt(OpCode3));
      end;
      {JNB}
      $3: begin
        if not(GetBit(OpCode2)) then
          Inc(PC, ShortInt(OpCode3));
      end;
      {JC}
      $4: begin
        if GetBit(BitCY) then
          Inc(PC, ShortInt(OpCode2));
      end;
      {JNC}
      $5: begin
        if not GetBit(BitCY) then
          Inc(PC, ShortInt(OpCode2));
      end;
      {JZ}
      $6: begin
        if SFR[RegACC] = 0 then
          Inc(PC, ShortInt(OpCode2));
      end;
      {JNZ}
      $7: begin
        if SFR[RegACC] <> 0 then
          Inc(PC, ShortInt(OpCode2));
      end;
      {SJMP}
      $8: Inc(PC, ShortInt(OpCode2));
      {MOV DPTR,#}
      $9: begin
        SFR[RegDPH] := OpCode2;
        SFR[RegDPL] := OpCode3;
      end;
      {ORL C,/b}
      $A: SetBit(BitCY, GetBit(BitCY) or not(GetBit(OpCode2)));
      {ANL C,/b}
      $B: SetBit(BitCY, GetBit(BitCY) and not(GetBit(OpCode2)));
      {PUSH}
      $C: Push(GetMemRam(OpCode2));
      {POP}
      $D: SetMemRam(OpCode2,Pop);
      {MOVX A,@DPTR}
      $E: SFR[RegACC]:=GetMemData(GetDPTR);
      {MOVX @DPTR,A}
      $F: SetMemData(GetDPTR,SFR[RegACC]);
    end;
    $1: begin
      {ACALL}
      if Odd(OpH) then PushPC;
      {AJMP}
      PC := (PC and $F800) + ((OpCode1 and $E0) shl 3) + OpCode2;
    end;
    $2: case OpH of
      {LJMP}
      $0: begin
        //wordrec(PC).hiB := OpCode2;
        //wordrec(PC).loB := OpCode3;
        PC := (OpCode2 shl 8) + OpCode3;
      end;
      {LCALL}
      $1: begin
        PushPC;
        //wordrec(PC).hiB := OpCode2;
        //wordrec(PC).loB := OpCode3;
        PC := (OpCode2 shl 8) + OpCode3;
      end;
      {RET}
      $2: PopPC;
      {RETI}
      $3: PopPC;
      {ORL r,A}
      $4: SetMemRam(OpCode2,GetMemRam(OpCode2) or SFR[RegACC]);
      {ANL r,A}
      $5: SetMemRam(OpCode2,GetMemRam(OpCode2) and SFR[RegACC]);
      {XRL r,A}
      $6: SetMemRam(OpCode2,GetMemRam(OpCode2) xor SFR[RegACC]);
      {ORL C,b}
      $7: SetBit(BitCY, GetBit(BitCY) or GetBit(OpCode2));
      {ANL C,b}
      $8: SetBit(BitCY, GetBit(BitCY) and GetBit(OpCode2));
      {MOV b,C}
      $9: SetBit(OpCode2, GetBit(BitCY));
      {MOV C,b}
      $A: SetBit(BitCY, GetBit(OpCode2));
      {CPL b}
      $B: SetBit(OpCode2, not GetBit(OpCode2));
      {CLR b}
      $C: SetBit(OpCode2, false);
      {SETB b}
      $D: SetBit(OpCode2, true);
      {MOVX A,@R0}
      $E: SFR[RegACC] := GetMemData(SFR[RegP2] * $100 + GetReg(0));
      {MOVX @R0,A}
      $F: SetMemData(SFR[RegP2] * $100 + GetReg(0),SFR[RegACC]);
    end;
    $3: case OpH of
      {RR A}
      $0: SFR[RegACC] := (SFR[RegACC] shr 1) + (SFR[RegACC] shl 7);
      {RRC A}
      $1: begin
        b := SFR[RegACC];
        SFR[RegACC] := (SFR[RegACC] shr 1);
        if GetBit(BitCY) then
          Inc(SFR[RegACC], $80);
        SetBit(BitCY, Odd(b));
      end;
      {RL A}
      $2: SFR[RegACC] := (SFR[RegACC] shl 1) + (SFR[RegACC] shr 7);
      {RLC A}
      $3: begin
        b := SFR[RegACC];
        SFR[RegACC] := (SFR[RegACC] shl 1);
        if GetBit(BitCY) then inc(SFR[RegACC]);
        SetBit(BitCY, (b>=$80));
      end;
      {ORL r,#}
      $4: SetMemRam(OpCode2, GetMemRam(OpCode2) or OpCode3);
      {ANL r,#}
      $5: SetMemRam(OpCode2, GetMemRam(OpCode2) and OpCode3);
      {XRL r,#}
      $6: SetMemRam(OpCode2, GetMemRam(OpCode2) xor OpCode3);
      {JMP @A+DPTR}
      $7: PC := GetDPTR + SFR[RegACC];
      {MOVC A,@A+PC}
      $8: SFR[RegACC] := GetMemCode(SFR[RegACC] + PC);
      {MOVC A,@A+DPTR}
      $9: SFR[RegACC] := GetMemCode(SFR[RegACC] + GetDPTR);
      {INC DPTR}
      $A: begin
        Inc(SFR[RegDPL]);
        if SFR[RegDPL] = 0 then
          Inc(SFR[RegDPH]);
      end;
      {CPL C}
      $B: SetBit(BitCY, not(GetBit(BitCY)));
      {CLR C}
      $C: SetBit(BitCY, False);
      {SETB C}
      $D: SetBit(BitCY, True);
      {MOVX A,@R1}
      $E: SFR[RegACC] := GetMemData(SFR[RegP2] * $100 + GetReg(1));
      {MOVX @R1,A}
      $F: SetMemData(SFR[RegP2] * $100 + GetReg(1), SFR[RegACC]);
    end;
    $4..$F: begin
      case OpCode1 of
        {DIV AB}
        $84: begin
          b := SFR[RegB];
          if b = 0 then
            SetBit(BitOV, True)
          else
          begin
            SFR[RegB] := SFR[RegACC] mod b;
            SFR[RegACC] := SFR[RegACC] div b;
            SetBit(BitOV, False);
          end;
          SetBit(BitCY, False);
        end;
        {MUL AB}
        $A4: begin
          w := SFR[RegACC] * SFR[RegB];
          SFR[RegACC] := lo(w);
          SFR[RegB] := hi(w);
          SetBit(BitOV, w >= $100);
          SetBit(BitCY, False);
        end;
        {reserved}
        $A5: ;//ReservedOpcode;
        {SWAP A}
        $C4: SFR[RegACC] := (SFR[RegACC] shr 4) + ((SFR[RegACC] shl 4) and $F0);
        {DA A}
        $D4: begin
          cy := GetBit(BitCY);
          if ((SFR[RegACC] and $F) >= $A) or GetBit(BitAC) then
          begin
            Inc(SFR[RegACC], 6);
            cy := cy or (SFR[RegACC] < 6);
          end;
          if (SFR[RegACC] >= $A0) or cy then
          begin
            Inc(SFR[RegACC], $60);
            cy := cy or (SFR[RegACC] < $60);
          end;
          SetBit(BitCY, cy);
        end;
        {DJNZ r,rel}
        $D5: begin
          SetMemRam(OpCode2, GetMemRam(OpCode2) - 1);
          if GetMemRam(OpCode2)<>0 then
            Inc(PC, ShortInt(OpCode3));
        end;
        {XCHD A,@Rx}
        $D6, $D7: begin
          b := SFR[RegACC];
          SFR[RegACC] := (SFR[RegACC] and $F0) + (iRAM[GetReg(OpCode1 and 1)] and $F);
          iRAM[GetReg(OpCode1 and 1)] := (iRAM[GetReg(Opcode1 and 1)] and $F0) + (b and $F);
        end;
        {CLR A}
        $E4: SFR[RegACC] := 0;
        {CPL A}
        $F4: SFR[RegACC] := not(SFR[RegACC]);
        else begin
          case OpH of
            $0, $1: begin
              if Odd(OpH) then
                b:=$FF
              else
                b:=1;
              case OpL of
                {INC A}
                $4: Inc(SFR[RegACC], b);
                {INC r}
                $5: SetMemRam(OpCode2, GetMemRam(OpCode2) + b);
                {INC @Rx}
                $6, $7: Inc(iRAM[GetReg(OpL and 1)], b);
                {INC Rx}
                $8..$F: Inc(iRAM[(OpL and 7) + (SFR[RegPSW] and $18)], b);
              end;
            end;
            $2: case OpL of
              {ADD A,#}
              $4: ADDC(OpCode2, False);
              {ADD A,r}
              $5: ADDC(GetMemRam(OpCode2), False);
              {ADD A,@Rx}
              $6, $7: ADDC(iRAM[GetReg(OpL and 1)], False);
              {ADD A,Rx}
              $8..$F: ADDC(iRAM[(OpL and 7) + (SFR[RegPSW] and $18)], False);
            end;
            $3: case OpL of
              {ADDC A,#}
              $4: ADDC(OpCode2, GetBit(BitCY));
              {ADDC A,r}
              $5: ADDC(GetMemRam(OpCode2), GetBit(BitCY));
              {ADDC A,@Rx}
              $6, $7: ADDC(iRAM[GetReg(OpL and 1)], GetBit(BitCY));
              {ADDC A,Rx}
              $8..$F: ADDC(iRAM[(OpL and 7) + (SFR[RegPSW] and $18)], GetBit(BitCY));
            end;
            $4: case OpL of
              {ORL A,#}
              $4: SFR[RegACC] := SFR[RegACC] or OpCode2;
              {ORL A,r}
              $5: SFR[RegACC] := SFR[RegACC] or GetMemRam(OpCode2);
              {ORL A,@Rx}
              $6, $7: SFR[RegACC] := SFR[RegACC] or iRAM[GetReg(OpL and 1)];
              {ORL A,Rx}
              $8..$F: SFR[RegACC] := SFR[RegACC] or iRAM[(OpL and 7) + (SFR[RegPSW] and $18)];
            end;
            $5: case OpL of
              {ANL A,#}
              $4: SFR[RegACC] := SFR[RegACC] and OpCode2;
              {ANL A,r}
              $5: SFR[RegACC] := SFR[RegACC] and GetMemRam(OpCode2);
              {ANL A,@Rx}
              $6, $7: SFR[RegACC] := SFR[RegACC] and iRAM[GetReg(OpL and 1)];
              {ANL A,Rx}
              $8..$F: SFR[RegACC] := SFR[RegACC] and iRAM[(OpL and 7) + (SFR[RegPSW] and $18)];
            end;
            $6: case OpL of
              {XRL A,#}
              $4: SFR[RegACC] := SFR[RegACC] xor OpCode2;
              {XRL A,r}
              $5: SFR[RegACC] := SFR[RegACC] xor GetMemRam(OpCode2);
              {XRL A,@Rx}
              $6, $7: SFR[RegACC] := SFR[RegACC] xor iRAM[GetReg(OpL and 1)];
              {XRL A,Rx}
              $8..$F: SFR[RegACC] := SFR[RegACC] xor iRAM[(OpL and 7) + (SFR[RegPSW] and $18)];
            end;
            $9: case OpL of
              {SUBB A,#}
              $4: SUBB(OpCode2);
              {SUBB A,r}
              $5: SUBB(GetMemRam(OpCode2));
              {SUBB A,@Rx}
              $6, $7: SUBB(iRAM[GetReg(OpL and 1)]);
              {SUBB A,Rx}
              $8..$F: SUBB(iRAM[(OpL and 7) + (SFR[RegPSW] and $18)]);
            end;
            $C: begin
              b := SFR[RegACC];
              case OpL of
                {XCH A,r}
                $5: begin
                  SFR[RegACC] := GetMemRam(OpCode2);
                  SetMemRam(OpCode2, b);
                end;
                {XCH A,@Rx}
                $6, $7: begin
                  SFR[RegACC] := iRAM[GetReg(OpL and 1)];
                  iRAM[GetReg(OpL and 1)] := b;
                end;
                {XCH A,Rx}
                $8..$F: begin
                  SFR[RegACC] := iRAM[(OpL and 7) + (SFR[RegPSW] and $18)];
                  iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] := b;
                end;
              end;
            end;
            $E: case OpL of
              {MOV A,r}
              $5: SFR[RegACC] := GetMemRam(OpCode2);
              {MOV A,@Rx}
              $6, $7: SFR[RegACC] := iRAM[GetReg(OpL and 1)];
              {MOV A,Rx}
              $8..$F: SFR[RegACC] := iRAM[(OpL and 7) + (SFR[RegPSW] and $18)];
            end;
            $7: case OpL of
              {MOV A,#}
              $4: SFR[RegACC] := OpCode2;
              {MOV r,#}
              $5: SetMemRam(OpCode2, OpCode3);
              {MOV @Rx,#}
              $6, $7: iRAM[GetReg(OpL and 1)] := OpCode2;
              {MOV Rx,#}
              $8..$F: iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] := OpCode2;
            end;
            $8: case OpL of
              {MOV r,r}
              $5: SetMemRam(OpCode3, GetMemRam(OpCode2));
              {MOV r,@Rx}
              $6, $7: SetMemRam(OpCode2, iRAM[GetReg(OpL and 1)]);
              {MOV r,Rx}
              $8..$F: SetMemRam(OpCode2, iRAM[(OpL and 7) + (SFR[RegPSW] and $18)]);
            end;
            $A: case OpL of
              {MOV @Rx,r}
              $6, $7: iRAM[GetReg(OpL and 1)] := GetMemRam(OpCode2);
              {MOV Rx,r}
              $8..$F: iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] := GetMemRam(OpCode2);
            end;
            $B: case OpL of
              {CJNE A,#,rel}
              $4: begin
                SetBit(BitCY, (SFR[RegACC] < OpCode2));
                if SFR[RegACC] <> OpCode2 then
                  Inc(PC, ShortInt(OpCode3));
              end;
              {CJNE A,r,rel}
              $5: begin
                SetBit(BitCY, (SFR[RegACC] < GetMemRam(OpCode2)));
                if SFR[RegACC] <> GetMemRam(OpCode2) then
                  Inc(PC, ShortInt(OpCode3));
              end;
              {CJNE @Rx,#,rel}
              $6,$7: begin
                SetBit(BitCY, (iRAM[GetReg(OpL and 1)] < OpCode2));
                if iRAM[GetReg(OpL and 1)] <> OpCode2 then
                  Inc(PC, ShortInt(OpCode3));
              end;
              {CJNE Rx,#,rel}
              $8..$F: begin
                SetBit(BitCY, (iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] < OpCode2));
                if iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] <> OpCode2 then
                  Inc(PC, ShortInt(OpCode3));
              end;
            end;
            {DJNZ Rx,rel}
            $D: begin
              dec(iRAM[(OpL and 7) + (SFR[RegPSW] and $18)]);
              if iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] <> 0 then
                Inc(PC, ShortInt(OpCode2));
            end;
            $F: case OpL of
              {MOV r,A}
              $5: SetMemRam(OpCode2, SFR[RegACC]);
              {MOV @Rx,A}
              $6, $7: iRAM[GetReg(OpL and 1)] := SFR[RegACC];
              {MOV Rx,A}
              $8..$F: iRAM[(OpL and 7) + (SFR[RegPSW] and $18)] := SFR[RegACC];
            end;
          end;
        end;
      end;
    end;
  end;
  // Ustaw flage "P" (Parzystosc ACC)
  UpdateParityFlag;
end;

// Konwersja znaku cyfry szesnastkowej na liczbe
function HexCharToByte(AChar: Char): Byte;
begin
  case AChar of
    '0'..'9': Result := Ord(AChar) - 48;
    'A'..'F': Result := Ord(AChar) - 55;
    'a'..'f': Result := Ord(AChar) - 87;
    else Result := $FF;
  end;
end;

// Konwersja lancucha szesnastokwego na wartosn 16-bit
function HexToWord(AStr: PString): Word;
var
  I, B: Byte;
begin
  Result := 0;
  for I := 1 to Length(AStr^) do
  begin
    if I > 4 then
      Exit;
    B := HexCharToByte(AStr[I]);
    if B > $F then
      Exit;
    Result := (Result shl 4) + B;
  end;
end;

// Aktualizuj grafike P/M (Test LED/Buzzer)
procedure UpdatePG;
begin
  if OldP1 = SFR[RegP1] then
    Exit;
  ClearPM;
  if SFR[RegP1] and %10000000 = 0 then
    MoveP(0, 176, 8);
  if SFR[RegP1] and %100000 = 0 then
    MoveP(1, 192, 8);
  OldP1 := SFR[RegP1];
end;

// Czysc zawartosc LCD
procedure LCD_Clear;
begin
  FillChar(@LCD, SizeOf(LCD), ' ');
  LCDIdx := 0;
end;

// Napisz znak w buforze LCD i zmien pozycje kursora
procedure LCD_PutChar(AChar: Char);
begin
  LCD[LCDIdx] := AChar;
  Inc(LCDIdx);
  if LCDIdx > $1F then
    LCDIdx := 0;
end;

// Napisz lancuch w LCD i zmien pozycje kursora
procedure LCD_PutString(AStr: String);
var
  I: Byte;
begin
  for I := 1 to Length(AStr^) do
    LCD_PutChar(AStr[I]);
end;

// Wyswietl zawartosc LCD
procedure LCD_Dump;
var
  I: Byte;
  C: Char;
begin
  WriteLn(#$11#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$05);
  Write(#$7C);
  for I := 0 to $1F do
  begin
    C := LCD[I];
    if I = LCDIdx then
      C := Chr(Ord(C) or $80);
    Write(C);
    if I = $F then
    begin
      WriteLn(#$7C);
      Write(#$7C);
    end;
  end;
  WriteLn(#$7C);
  WriteLn(#$1A#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$03);
end;

// Podprogramy DSM-51 w EPROM

// Wypisuje na wyświetlacz LCD tekst wskazany rejestrem DPTR, zakończony bajtem=0.
procedure DSM_WRITE_TEXT;
var
  D: Word;
  B: Byte;
begin
  D := GetDPTR;
  repeat
    B := xCODE[D];
    if B = 0 then
      Break;
    LCD_PutChar(Chr(B));
    Inc(D);
  until False;
  SFR[RegDPL] := D and $FF;
  SFR[RegDPH] := D shr 8;
  LCD_Dump;
end;

// Wypisuje znakowo bajt z Akumulatora na wyświetlacz LCD.
procedure DSM_WRITE_DATA;
begin
  LCD_PutChar(Chr(GetMemRam(RegACC)));
  LCD_Dump;
end;

// Wypisuje szesnastkowo bajt z Akumulatora na wyświetlacz LCD.
procedure DSM_WRITE_HEX;
var
  S: String[2];
begin
  S := IntToHex(GetMemRam(RegACC), 2);
  LCD_PutChar(S[1]);
  LCD_PutChar(S[2]);
  LCD_Dump;
end;

// Wysyła do wyświetlacza LCD rozkaz z Akumulatora. (nie obslugiwane, todo)
procedure DSM_WRITE_INSTR;
begin
  LCD_Dump;
end;

// Inicjuje pracę wyświetlacza LCD.
procedure DSM_LCD_INIT;
begin
  LCD_Clear;
  LCD_Dump;
end;

// Wyłącza wyświetlacz LCD.
procedure DSM_LCD_OFF;
begin
  LCD_Clear;
  LCD_Dump;
end;

//Kasuje zawartość wyświetlacza LCD i ustawia kursor na początku.
procedure DSM_LCD_CLR;
begin
  LCD_Clear;
  LCD_Dump;
end;

// Oczekuje przez czas zgodnie ze wzorem (łącznie z wywołaniem procedury):
// Czas[μs] = ( A*2 + 6 ) * 12 / 11.0592
procedure DSM_DELAY_US;
var
  T: Integer;
begin
  T := GetMemRam(RegACC);
  WriteLn('Delay ', T, ' us');
  T:=(((T*2+6)*12) div 11) div 1000;
  Delay(T);
end;

// Odczekuje przez czas A[ms] (A=0 oznacza 256 ms).
procedure DSM_DELAY_MS;
var
  T: Byte;
begin
  T := GetMemRam(RegACC);
  if T = 0 then
    T := 255; // wg. dokumentacji powinno byc 256ms
  WriteLn('Delay ', T, ' ms');
  Delay(T);
end;

// Odczekuje przez czas A*100[ms] (A=0 oznacza 25.6 s).
procedure DSM_DELAY_100MS;
var
  T, I: Byte;
begin
  T := GetMemRam(RegACC);
  if T = 0 then
    T := 255; // wg. dokumentacji powinno byc 25,6s
  WriteLn('Delay ', T, ' *100ms');
  for I := 0 to T do
  begin
    Delay(100);
    if KeyPressed then
      Break;
  end;
end;

// Pisze na wyświetlaczu „PRESS ENTER...” i czeka na naciśnięcie klawisza [Enter].
procedure DSM_WAIT_ENTER;
begin
  LCD_PutString('PRESS ENTER...');
  WriteLn('Press enter to continue...');
  LCD_Dump;
  ReadLn;
  LCD_Clear;
  LCD_Dump;
end;

// Czeka na naciśnięcie klawisza [ENTER] (niczego nie pisze na wyświetlaczu).
procedure DSM_WAIT_ENTER_NW;
begin
  WriteLn('Press enter to continue...');
  ReadLn;
end;

// Sprawdza, klawisz [Enter]. C=0 - klawisz naciśnięty, C=1 - klawisz puszczony.
procedure DSM_TEST_ENTER;
begin
  WriteLn('Is Enter pressed (Y - yes, N - no)');
  ReadLn(StrBuf);
  if (StrBuf[0] = #1) and (StrBuf[1] = 'Y') then
    SetMemRam(RegPSW, GetMemData(RegPSW) and $7F)
  else
    SetMemRam(RegPSW, GetMemData(RegPSW) or $80);
end;

// Czeka na [Enter] lub [Esc]. Zwraca informację: C=0 - [Enter], C=1 - [Esc])
procedure DSM_WAIT_ENT_ESC;
var
  C: Char;
begin
  WriteLn('Press Enter or ESC');
  repeat
    repeat until KeyPressed;
    C := ReadKey;
  until (C = #13) or (C = #27);
  if C = #13 then
    SetMemRam(RegPSW, GetMemData(RegPSW) and $7F)
  else
    SetMemRam(RegPSW, GetMemData(RegPSW) or $80);
end;

// Program czeka na dowolny klawisz z klawiatury matrycowej. Nr klawisza zwraca w Akumulatorze.
procedure DSM_WAIT_KEY;
var
  B: Byte;
begin
  WriteLn('Press 0..F');
  repeat
    repeat until KeyPressed;
    B := HexCharToByte(Upcase(ReadKey));
  until (B >= 0) and (B <= $F);
  SetMemRam(RegACC, B);
end;

// Wczytuje liczbę BCD (4 cyfry) z klawiatury pod adres @R0. Koniec wpisywania: [Enter] (C=0), po 4 cyfrze również [Esc] (C=1).
procedure DSM_GET_NUM;
begin
  WriteLn('Enter number (hex)');
  ReadLn(StrBuf);
  if Length(StrBuf) > 0 then
  begin
    TmpAddr := HexToWord(StrBuf);
    SetMemRam(GetReg(0), TmpAddr and $FF);
    SetMemRam(GetReg(0) + 1, TmpAddr shr 8);
    SetMemRam(RegPSW, GetMemRam(RegPSW) and $7F);
  end
  else
    SetMemRam(RegPSW, GetMemRam(RegPSW) or $80);
end;

// Zamienia liczbę z postaci upakowane BCD na 2 bajtach wskazanych przez @R0 na HEX na tych bajtach.
procedure DSM_BCD_HEX;
var
  R1, R2, A, B, C, D: Byte;
  W: Word;
begin
  R1 := GetMemRam(GetReg(0));
  R2 := GetMemRam(GetReg(0) + 1);
  A := R2 and $F;
  B := R2 shr 4;
  C := R1 and $F;
  D := R1 shr 4;
  W := A + B * 10 + C * 100 + D * 1000;
  SetMemRam(GetReg(0), W and $FF);
  SetMemRam(GetReg(0) + 1, W shr 8);
end;

// Zamienia liczbę HEX na 2 bajtach (@R0) na postać upakowane BCD (3 bajty @R0).
procedure DSM_HEX_BCD;
var
  W: Word;
  B: Byte;
  T: array[0..5] of Byte;
begin
  W := GetMemRam(GetReg(0)+1);
  W := (W shl 8) + GetMemRam(GetReg(0));
  FillChar(@T, SizeOf(T), #0);
  B := 0;
  while W <> 0 do
  begin
    T[B] := W mod 10;
    W := W div 10;
    Inc(B);
  end;
  B := (T[1] shl 4) + T[0];
  SetMemRam(GetReg(0), B);
  B := (T[3] shl 4) + T[2];
  SetMemRam(GetReg(0) + 1, B);
  B := (T[5] shl 4) + T[4];
  SetMemRam(GetReg(0) + 2, B);
end;

// Mnoży 2 bajty * 2 bajty (mnożna - @R0, mnożnik - B,A (B-high), iloczyn - @R0 (4 bajty))
procedure DSM_MUL_2_2;
var
  W1, W2: Word;
  D: Cardinal;
  BA: array[0..3] of Byte absolute D;
begin
  W1 := GetMemRam(RegACC);
  W1 := (W1 shl 8) + GetMemRam(RegB);
  W2 := GetMemRam(GetReg(0));
  W2 := (W2 shl 8) + GetMemRam(GetReg(0) + 1);
  D := W1 * W2;
  SetMemRam(GetReg(0), BA[0]);
  SetMemRam(GetReg(0) + 1, BA[1]);
  SetMemRam(GetReg(0) + 2, BA[2]);
  SetMemRam(GetReg(0) + 3, BA[3]);
end;

// Mnoży 3 bajty * 1 bajt (mnożna - @R0 (3 bajty), mnożnik - A, iloczyn - @R0 (4 bajty))
procedure DSM_MUL_3_1;
var
  D: Cardinal;
  BA: array[0..3] of Byte absolute D;
begin
  D := GetMemRam(GetReg(0));
  D := (D shl 8) + GetMemRam(GetReg(0) + 1);
  D := (D shl 8) + GetMemRam(GetReg(0) + 2);
  D := D * GetMemRam(RegACC);
  SetMemRam(GetReg(0), BA[0]);
  SetMemRam(GetReg(0) + 1, BA[1]);
  SetMemRam(GetReg(0) + 2, BA[2]);
  SetMemRam(GetReg(0) + 3, BA[3]);
end;

// Dzieli 2 bajty przez 1 bajt (dzielna - @R0, dzielnik - B, iloraz - na dzielnej (@R0), reszta - A)
procedure DSM_DIV_2_1;
var
  W, W2: Word;
  B: Byte;
begin
  B := GetMemRam(RegB);
  if B = 0 then
    Exit;
  W := GetMemRam(GetReg(0));
  W := (W shl 8) + GetMemRam(GetReg(0) + 1);
  W2 := W div B;
  B := W mod B;
  SetMemRam(GetReg(0), Lo(W2));
  SetMemRam(GetReg(0) + 1, Hi(W2));
  SetMemRam(RegACC, B);
end;

// Dzieli 4 bajty przez 2 bajty (dzielna -@R0,dzielnik -B,A (B=high), iloraz - na dzielnej (@R0), reszta - @(R0+4), @(R0+5))
procedure DSM_DIV_4_2;
var
  D1, D2: Cardinal;
  W: Word;
  BA1: array[0..3] of Byte absolute D1;
  BA2: array[0..3] of Byte absolute D2;
begin
  W := GetMemRam(RegACC);
  W := (W shl 8) + GetMemRam(RegB);
  if W = 0 then
    Exit;
  BA1[0] := GetMemRam(GetReg(0));
  BA1[1] := GetMemRam(GetReg(0) + 1);
  BA1[2] := GetMemRam(GetReg(0) + 2);
  BA1[3] := GetMemRam(GetReg(0) + 3);
  D2 := D1 div W;
  W := D1 mod W;
  SetMemRam(GetReg(0), BA2[0]);
  SetMemRam(GetReg(0) + 1, BA2[1]);
  SetMemRam(GetReg(0) + 2, BA2[2]);
  SetMemRam(GetReg(0) + 3, BA2[3]);
  SetMemRam(GetReg(0) + 4, Lo(W));
  SetMemRam(GetReg(0) + 5, Hi(W));
end;

// Moze obsluzycz wywolanie podporgramu w EPROM?
procedure UpdateDSM;
begin
  if (Hi(PC) = $81) and (Lo(PC) <= $2A) then
  begin
    case Lo(PC) of
      Lo(DR_WRITE_TEXT): DSM_WRITE_TEXT;
      Lo(DR_WRITE_DATA): DSM_WRITE_DATA;
      Lo(DR_WRITE_HEX): DSM_WRITE_HEX;
      Lo(DR_WRITE_INSTR): DSM_WRITE_INSTR;
      Lo(DR_LCD_INIT): DSM_LCD_INIT;
      Lo(DR_LCD_OFF): DSM_LCD_OFF;
      Lo(DR_LCD_CLR): DSM_LCD_CLR;
      Lo(DR_DELAY_US): DSM_DELAY_US;
      Lo(DR_DELAY_MS): DSM_DELAY_MS;
      Lo(DR_DELAY_100MS): DSM_DELAY_100MS;
      Lo(DR_WAIT_ENTER): DSM_WAIT_ENTER;
      Lo(DR_WAIT_ENTER_NW): DSM_WAIT_ENTER_NW;
      Lo(DR_TEST_ENTER): DSM_TEST_ENTER;
      Lo(DR_WAIT_ENT_ESC): DSM_WAIT_ENT_ESC;
      Lo(DR_WAIT_KEY): DSM_WAIT_KEY;
      Lo(DR_GET_NUM): DSM_GET_NUM;
      Lo(DR_BCD_HEX): DSM_BCD_HEX;
      Lo(DR_HEX_BCD): DSM_HEX_BCD;
      Lo(DR_MUL_2_2): DSM_MUL_2_2;
      Lo(DR_MUL_3_1): DSM_MUL_3_1;
      Lo(DR_DIV_2_1): DSM_DIV_2_1;
      Lo(DR_DIV_4_2): DSM_DIV_4_2;
    end;
    PopPC;
    UpdateParityFlag;
  end;
  UpdatePG;
end;

// Reset emulatora
procedure ResetEmu;
begin
  PC := 0;
  if not SharedMem then
    FillChar(xDATA, SizeOf(xDATA), 0);
  FillChar(iRAM, SizeOf(iRAM), 0);
  FillChar(SFR, SizeOf(SFR), 0);

  SFR[RegSP] := 7;
  SFR[RegP0] := $FF;
  SFR[RegP1] := $FF;
  SFR[RegP2] := $FF;
  SFR[RegP3] := $FF;

  LCD_Clear;
  UpdatePG;
end;

// Pobierz i parsuj polecenie
procedure GetAndParesCommand;
var
  CurStr, I, J: Byte;
begin
  StrBuf := '';
  Command := #0;
  SubCommand := #0;
  CmdParam1 := '';
  CmdParam2 := '';
  CurStr := 0;
  J := 1;
  Write('>');
  ReadLn(StrBuf);
  StrBuf := UpCase(StrBuf);
  for I := 1 to Length(StrBuf) do
  begin
    if StrBuf[I] = ' ' then
    begin
      if CurStr < 2 then
      begin
        Inc(CurStr);
        J := 1;
      end;
      Continue;
    end;
    case CurStr of
      0: begin
        case I of
          1: Command := StrBuf[1];
          2: SubCommand := StrBuf[2];
        end;
      end;
      1: begin
        Inc(CmdParam1[0]);
        CmdParam1[J] := StrBuf[I];
      end;
      2: begin
        Inc(CmdParam2[0]);
        CmdParam2[J] := StrBuf[I];
      end;
    end;
    Inc(J);
  end;
end;

// Przygotuj adresy pomocnicze dla polecenia
procedure PrepareMemAddr;
begin
  case SubCommand of
    'R': begin
      if TmpAddr > $FF then TmpAddr := 0;
      TmpAddr2 := Word(@iRAM);
      TmpAddr3 := Word(@iRAM) + $FF;
      TmpPB := Pointer(@iRAM + TmpAddr);
    end;
    'S': begin
      if (TmpAddr < $80) or (TmpAddr > $FF) then TmpAddr := $80;
      TmpAddr2 := Word(@SFR);
      TmpAddr3 := Word(@SFR) + $FF;
      TmpPB := Pointer(@SFR + TmpAddr);
    end;
    'C': begin
      if (SharedMem and (TmpAddr >= XCODE_SIZE + XDATA_SIZE)) or
        ((not SharedMem) and (TmpAddr >= XCODE_SIZE)) then
        TmpAddr := 0;
      TmpAddr2 := Word(@xCODE);
      TmpAddr3 := Word(@xCODE) + XCODE_SIZE - 1;
      if SharedMem then
        Inc(TmpAddr3, XDATA_SIZE - 1);
      TmpPB := Pointer(@xCODE + TmpAddr);
    end;
    'D': begin
      if SharedMem then
      begin
        if TmpAddr >= XDATA_SIZE + XCODE_SIZE then TmpAddr := 0;
        TmpAddr2 := Word(@xCODE);
        TmpAddr3 := Word(@xCODE) + XDATA_SIZE + XCODE_SIZE - 1;
        TmpPB := Pointer(@xCODE + TmpAddr);
      end
      else
      begin
        if TmpAddr >= XDATA_SIZE then TmpAddr := 0;
        TmpAddr2 := Word(@xDATA);
        TmpAddr3 := Word(@xDATA) + XDATA_SIZE - 1;
        TmpPB := Pointer(@xDATA + TmpAddr);
      end;
    end;
  end;
end;

// Zrob inwersje tekstu
procedure InvertStr(var S: String);
var
  I, J: Byte;
begin
  for I := 1 to Length(S) do
  begin
    J := Ord(S[I]);
    if J < $80 then
    begin
      J := J or $80;
      S[I] := Chr(J);
    end;
  end;
end;

// Prosty zrzut - wypisz podstawowe rejestry
procedure SimpleDump;
var
  I, J: Byte;
  S: String[5];
begin
  WriteLn('PC=', IntToHex(PC, 4), ' SP=', IntToHex(SFR[RegSP], 2),
    ' A=', IntToHex(SFR[RegACC], 2), ' B=', IntToHex(SFR[RegB], 2),
    ' DPTR=', IntToHex(GetDPTR, 4));
  Write('PSW: ');
  I := SFR[RegPSW];
  for J := 0 to 7 do
  begin
    S := BitRegName[$48 + J];
    if I and (1 shl J) <> 0 then
      InvertStr(S);
    Write(S, ' ');
  end;
  WriteLn;
  for I := 0 to 3 do
    Write('R', IntToStr(I), '=', IntToHex(GetReg(I), 2), ' ');
  WriteLn;
  for I := 4 to 7 do
    Write('R', IntToStr(I), '=', IntToHex(GetReg(I), 2), ' ');
  WriteLn;
end;

// Wyswietl zawartosc pamieci
procedure DumpMem;
var
  I: Byte;
begin
  PrepareMemAddr;
  I := 0;
  while (Word(TmpPB) <= TmpAddr3) and (I <= 183) do
  begin
    if I mod 8 = 0 then
      Write(IntToHex(TmpAddr, 4), ' ');
    Write(IntToHex(TmpPB^, 2), ' ');
    if I mod 8 = 7 then
      WriteLn;
    Inc(TmpPB);
    Inc(I);
    Inc(TmpAddr);
  end;
  if I mod 8 > 0 then
    WriteLn;
end;

// Konweruj ciag liczb szesnastkowych na zawartosc bajtow w pamieci
procedure ReadHex;
var
  B: Byte;
  S: ShortInt;
  P: PChar;
begin
  PrepareMemAddr;
  P := @CmdParam2[1];
  S := Length(CmdParam2);
  if S = 1 then
    TmpPB^ := HexCharToByte(P^)
  else
    if S > 1 then
    begin
      if Odd(S) then
        Dec(S);
      while (Word(TmpPB) <= TmpAddr3) and (S > 0) do
      begin
        B := HexCharToByte(P^);
        Inc(P);
        B := (B shl 4) + HexCharToByte(P^);
        Inc(P);
        TmpPB^ := B;
        Inc(TmpPB);
        Dec(S, 2);
      end;
    end;
end;

// Usun wskazana pulapke lub wszystkie
procedure ClearBreakpoints(ABreakpointIndex: Byte);
begin
  case ABreakpointIndex of
    0..$F: Breakpoints[ABreakpointIndex] := $FFFF;
    $FF: FillChar(@Breakpoints, SizeOf(Breakpoints), #$FF);
  end;
end;

// Sprawdz, czy podany adres posiada przypisana pulapke
function IsBreakpoint(AAddr: Word): Boolean;
var
  I: Byte;
begin
  // Przerwij na jedynym nieprawidlowym op-kodzie
  if Opcode1 = $A5 then
  begin
    Result := True;
    Exit;
  end;
  for I := 0 to $F do
    if Breakpoints[I] = AAddr then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

{procedure PutStrAt(AIndex: Byte; AStr: PString);
begin
  Move(@AStr[1], @StrBuf[AIndex], Length(AStr));
end;}

// Umiesc wskazany lancuch w buforze i przesun wskaznik
procedure PutStr(AStr: PString);
begin
  Move(@AStr[1], @StrBuf[StrBufIdx], Length(AStr^));
  Inc(StrBufIdx, Length(AStr^));
end;

// Umiesc znak w buforze i przesun wskaznik
procedure PutChar(AChr: Char);
begin
  StrBuf[StrBufIdx] := AChr;
  Inc(StrBufIdx);
end;

// Czysc bufor
procedure ClearStr;
var
  I: Byte;
begin
  for I := 1 to 37 do
    StrBuf[I] := ' ';
  SetLength(StrBuf, 37);
end;

// Pobierz nazwe rejestru
function GetRegName(ARegIndex: Byte): String[5];
var
  I: Byte;
begin
  if (ARegIndex > $7F) then
    I := RegNameMap[ARegIndex - $80]
  else
    I := $FF;
  if I < $FF then
    Result := RegName[I]
  else
  begin
    Result := IntToHex(ARegIndex, 2);
    Inc(Result[0]);
    Result[3] := 'H';
  end;
end;

// Pbierz nazwe rejestru bitowego
function GetBitRegName(ARegIndex: Byte): String[6];
var
  I: Byte;
begin
  if (ARegIndex > $7F) then
    I := BitRegNameMap[ARegIndex - $80]
  else
    I := $FF;
  if I < $FF then
    Result := BitRegName[I]
  else
  begin
    if ARegIndex < $80 then
      I := (ARegIndex div 8) + $20
    else
      I := ARegIndex and $F8;
    Result := IntToHex(I, 2);
    Result[0] := #5;
    Result[3] := 'H';
    Result[4] := '.';
    Result[5] := Chr(Ord('0') + (ARegIndex and 7));
  end;
end;

// Umiesc nazwe rejestru w buforze
procedure PutStdArg;
begin
  case OpL of
    6,7: begin
      PutStr('@R');
      PutChar(Chr(42 + OpL));
    end;
    8..15: begin
      PutChar('R');
      PutChar(Chr(40 + OpL));
    end;
  end;
end;

// Deasemblacja instrukvji o podanym adresie
procedure Disassemble(AAddr: Word);
begin
  FetchOpcode(AAddr);
  ClearStr;
  if IsBreakpoint(AAddr) then
    StrBuf[1] := 'X';
  if PC = AAddr then
    StrBuf[1] := '*';
  StrBufIdx := 2;
  PutStr(IntToHex(AAddr, 4));
  Inc(StrBufIdx);
  PutStr(IntToHex(OpCode1, 2));
  if OpLen >= 2 then
    PutStr(IntToHex(OpCode2, 2));
  if OpLen = 3 then
    PutStr(IntToHex(OpCode3, 2));
  StrBufIdx := 14;
  PutStr(OpCodeName[OpCodeNameMap[OpCode1]]);
  StrBufIdx := 20;
  case OpL of
    0: case OpH of
      //0: ; //NOP
      1..3: begin
        PutStr(GetBitRegName(OpCode2));
        PutChar(',');
        PutStr(IntToHex(AAddr + 3 + ShortInt(OpCode3), 4));
        PutChar('H');
      end;
      4..8: begin
        PutStr(IntToHex(AAddr + 2 + ShortInt(OpCode2), 4));
        PutChar('H');
      end;
      9: begin
        PutStr('DPTR,#');
        PutStr(IntToHex(OpCode2, 2));
        PutStr(IntToHex(OpCode3, 2));
        PutChar('H');
      end;
      10, 11: begin
        PutStr('C,/');
        PutStr(GetBitRegName(OpCode2));
      end;
      12, 13: PutStr(GetRegName(OpCode2));
      14: PutStr('A,@DPTR');
      15: PutStr('@DPTR,A');
    end;
    1: begin
      PutStr(IntToHex(((AAddr + 2) and $F800) or ((OpCode1 and $E0) shl 3) or OpCode2, 4));
      PutChar('H');
    end;
    2: begin
      case OpH of
        0, 1: begin
          PutStr(IntToHex((Word(OpCode2) shl 8) + OpCode3, 4));
          PutChar('H');
        end;
        //2,3: ; //RET/RETI
        4..6: begin
          PutStr(GetRegName(OpCode2));
          PutStr(',A');
        end;
        7, 8, 10: begin
          PutStr('C,');
          PutStr(GetBitRegName(OpCode2));
        end;
        9: begin
          PutStr(GetBitRegName(OpCode2));
          PutStr(',C');
        end;
        11..13: PutStr(GetBitRegName(OpCode2));
        14: PutStr('A,@R0');
        15: PutStr('@R0,A');
      end;
    end;
    3: begin
      case OpH of
        0..3: PutChar('A');
        4..6: begin
          PutStr(GetRegName(OpCode2));
          PutStr(',#');
          PutStr(IntToHex(OpCode3, 2));
        end;
        7: PutStr('@A+DPTR');
        8: PutStr('A,@A+PC');
        9: PutStr('A,@A+DPTR');
        10: PutStr('DPTR');
        11..13: PutChar('C');
        14: PutStr('A,@R1');
        15: PutStr('@R1,A');
      end;
    end;
    4..15: begin
      case OpCode1 of
        $84,$A4: PutStr('AB');
        //$A5: ; //reserved
        $C4, $D4, $E4, $F4: PutChar('A');
        $D5: begin
          PutStr(GetRegName(OpCode2));
          PutChar(',');
          PutStr(IntToHex(AAddr + 3 + ShortInt(OpCode3), 4));
          PutChar('H');
        end;
        $D6,$D7: begin
          PutStr('A,@R');
          PutChar(Chr(42 + OpL));
        end;
      else
        case OpH of
          0,1: case OpL of
            4: PutChar('A');
            5: PutStr(GetRegName(OpCode2));
            {6,7 : Desassemble := '@R'+chr(42+cl);
            8..15 : Desassemble := 'R'+chr(40+cl);}
            6..15: PutStdArg;
          end;
          2..6, 9, 12, 14: case OpL of
            4: begin
              PutStr('A,#');
              PutStr(IntToHex(OpCode2, 2));
            end;
            5: begin
              PutStr('A,');
              PutStr(GetRegName(OpCode2));
            end;
            {6,7 : Desassemble := 'A,@R'+chr(42+cl);
            8..15 : Desassemble := 'A,R'+chr(40+cl);}
            6..15: begin
              PutStr('A,');
              PutStdArg;
            end;
          end;
          7: case OpL of
            4: begin
              PutStr('A,#');
              PutStr(IntToHex(OpCode2, 2));
            end;
            5: begin
              PutStr(GetRegName(OpCode2));
              PutStr(',#');
              PutStr(IntToHex(OpCode3, 2));
            end;
            {6,7: Desassemble := '@R'+chr(42+cl)+',#'+HexaShort(c1);
            8..15: Desassemble := 'R'+chr(40+cl)+',#'+HexaShort(c1);}
            6..15: begin
              PutStdArg;
              PutStr(',#');
              PutStr(IntToHex(OpCode2, 2));
            end;
          end;
          8: case OpL of
            5: begin
              PutStr(GetRegName(OpCode3));
              PutChar(',');
              PutStr(GetRegName(OpCode2));
            end;
            {6,7 : Desassemble := RegName[c1]+',@R'+chr(42+cl);
            8..15 : Desassemble := RegName[c1]+',R'+chr(40+cl);}
            6..15: begin
              PutStr(GetRegName(OpCode2));
              PutChar(',');
              PutStdArg;
            end;
          end;
          10: case OpL of
            {6,7 : Desassemble := '@R'+chr(42+cl)+','+RegName[c1];
            8..15 : Desassemble := 'R'+chr(40+cl)+','+RegName[c1];}
            6..15: begin
              PutStdArg;
              PutChar(',');
              PutStr(GetRegName(OpCode2));
            end;
          end;
          11: case OpL of
            4: begin
              PutStr('A,#');
              PutStr(IntToHex(OpCode2, 2));
              PutChar(',');
              PutStr(IntToHex(AAddr + 3 + ShortInt(OpCode3), 4));
              PutChar('H');
            end;
            5: begin
              PutStr('A,');
              PutStr(GetRegName(OpCode2));
              PutChar(',');
              PutStr(IntToHex(AAddr + 3 + ShortInt(OpCode3), 4));
              PutChar('H');
            end;
            {6,7 : Desassemble := '@R'+chr(42+cl)+',#'+HexaShort(c1)+','+HexaWord(adr+3+ShortInt(c2))+'H';
            8..15 : Desassemble := 'R'+chr(40+cl)+',#'+HexaShort(c1)+','+HexaWord(adr+3+ShortInt(c2))+'H';}
            6..15: begin
              PutStdArg;
              PutStr(',#');
              PutStr(IntToHex(OpCode2, 2));
              PutChar(',');
              PutStr(IntToHex(AAddr + 3 + ShortInt(OpCode3), 4));
              PutChar('H');
            end;
          end;
          13 : begin
            PutChar('R');
            PutChar(Chr(40 + OpL));
            PutChar(',');
            PutStr(IntToHex(AAddr + 2 + ShortInt(OpCode2), 4));
            PutChar('H');
          end;
          15: case OpL of
            5: begin
              PutStr(GetRegName(OpCode2));
              PutStr(',A');
            end;
            {6,7: Desassemble := '@R'+chr(42+cl)+',A';
            8..15: Desassemble := 'R'+chr(cl+40)+',A';}
            6..15: begin
              PutStdArg;
              PutStr(',A');
            end;
          end;
        end;
      end;
    end;
  end;
  WriteLn(StrBuf);
end;

// Pobierz adres polecenia
procedure GetCmdAddres;
begin
  if Length(CmdParam1) > 0 then
    TmpAddr := HexToWord(CmdParam1)
  else
    TmpAddr := $FFFF;
end;

// Wczytaj plik binarny
procedure LoadBinFile;
var
  F: File;
begin
  TmpAddr3 := TmpAddr3 - Word(TmpPB);
  Assign(F, CmdParam2);
  Reset(F, 1);
  if IOResult = 1 then
    BlockRead(F, TmpPB^, TmpAddr3);
  Close(F);
end;

// Wczytaj plik Intel HEX
procedure LoadHexFile;
label
  Fin;
var
  F: File;
  Ch1, Ch2: Char;
  Len: Byte;

function FetchChar(var Ch: Char): Boolean;
begin
  BlockRead(F, Ch, 1);
  Result := IOResult = 1;
end;

begin
  Assign(F, CmdParam2);
  Reset(F, 1);
  StrBuf := '';
  repeat
    repeat
      if not FetchChar(Ch1) then goto Fin;
    until Ch1 = ':';
    if not FetchChar(Ch1) then goto Fin;
    if not FetchChar(Ch2) then goto Fin;
    Len := HexCharToByte(Ch1) * 16 + HexCharToByte(Ch2);
    if not FetchChar(Ch1) then goto Fin;
    if not FetchChar(Ch2) then goto Fin;
    TmpAddr := HexCharToByte(Ch1) * 16 + HexCharToByte(Ch2);
    if not FetchChar(Ch1) then goto Fin;
    if not FetchChar(Ch2) then goto Fin;
    TmpAddr := TmpAddr shl 8 + HexCharToByte(Ch1) * 16 + HexCharToByte(Ch2);
    if not FetchChar(Ch1) then goto Fin;
    if not FetchChar(Ch2) then goto Fin;
    TmpPB := Pointer(TmpAddr2 + TmpAddr);
    if (Ch1 = '0') and (Ch2 = '0') and (Word(TmpPB) <= TmpAddr3) then
    repeat
      if not FetchChar(Ch1) then goto Fin;
      if not FetchChar(Ch2) then goto Fin;
      TmpPB^ := HexCharToByte(Ch1) * 16 + HexCharToByte(Ch2);
      Dec(Len);
      Inc(TmpPB);
    until (Len = 0) or (Word(TmpPB) > TmpAddr3);
  until False;
Fin:
  Close(F);
end;

var
  I: Byte;

begin
  //Poke(82, 0);
  WriteLn;
  WriteLn('Programowy Symulator DSM-51 v. 0.1');
  WriteLn('by Noname, Erni and Gawor (98?/00/25)');

  // Inicjuj PMG - indykatory "Test LED" i "Buzzer"
  p_data[0] := @PG_LED;
  p_data[1] := @PG_BUZZER;
  SetPM(_PM_DOUBLE_RES);
  InitPM(_PM_DOUBLE_RES);
  ShowPM(_PM_SHOW_ON);
  ColorPM(0, $34);
  ColorPM(1, $B8);
  SizeP(0, _PM_DOUBLE_SIZE);
  SizeP(1, _PM_DOUBLE_SIZE);

  // Resetuj maszyne i pamiec
  FillByte(xCODE, SizeOf(xCODE), 0);
  FillByte(xDATA, SizeOf(xDATA), 0);
  ResetEmu;
  // Domyslnie wspoldzielona pamiec CODE i DATA, jak w DSM-51
  SharedMem := True;
  // Inicjuj pulapki
  ClearBreakpoints($FF);

  // Glowna petla programu
  repeat
    GetAndParesCommand;
    case Command of
      // S - "Step" - krok
      'S': begin
        Disassemble(PC);
        Step;
        UpdateDSM;
        if SubCommand <> 'A' then
          SimpleDump;
      end;
      // R - "Run" - uruchom, przerywa dowolny klawisz
      'R': begin
        WriteLn('Running... pres any key to stop.');
        repeat
          Step;
          UpdateDSM;
        until IsBreakpoint(PC) or KeyPressed;
        ReadKey;
        Disassemble(PC);
        SimpleDump;
      end;
      // T - "Trace" - uruchamia krokowo
      'T': begin
        WriteLn('Trace... press any key to stop.');
        repeat
          Disassemble(PC);
          Step;
          UpdateDSM;
          if SubCommand <> 'A' then
            SimpleDump;
        until IsBreakpoint(PC) or KeyPressed;
        ReadKey;
      end;
      // D - "Dump" - pokaz pamiec, rejestry, itp
      'D': begin
        case SubCommand of
          // DA - desassemblacja od podanego adresu lub od PC jesli nie podano adresu
          'A': begin
            GetCmdAddres;
            if TmpAddr = $FFFF then
              TmpAddr := PC;
            for I := 0 to 22 do
            begin
              Disassemble(TmpAddr);
              TmpAddr := TmpAddr + OpLen;
            end;
          end;
          // DC, DR, DD, DS - wyswietl zawartosc pamieci C - kodu, R - pamieci wewnetrznej, D - mapieci DATA, S - rejestry SFR
          'C', 'R', 'D', 'S': begin
            GetCmdAddres;
            DumpMem;
          end;
          // Wyswietl zawartosc LCD
          'L': LCD_Dump;
          else begin
            Disassemble(PC);
            SimpleDump;
          end;
        end;
      end;
      // M - "Modify" - zmien zawartosc pamieci i rejestrow
      'M': begin
        GetCmdAddres;
        case SubCommand of
          'C', 'R', 'D', 'S': begin
            ReadHex;
            case SubCommand of
              'R', 'S': begin
                UpdateParityFlag;
                UpdatePG;
              end;
            end;
          end;
          'P': PC := TmpAddr;
          'O': begin
            SFR[RegDPL] := TmpAddr and $FF;
            SFR[RegDPH] := TmpAddr shr 8;
          end;
          'T': SFR[RegSP] := TmpAddr;
        end;
      end;
      // L - "Load" - wczytanie z pliku
      // LC, LR, LD, LS - wczytaj zawartosc pamieci C - kodu, R - pamieci wewnetrznej, D - mapieci DATA, S - rejestry SFR
      'L': begin
        if FileExists(CmdParam2) then
        begin
          if (CmdParam1[0] = #1) and (CmdParam1[1] = 'H') then
          begin
            // L* H <nazwa pliku> - wczytanie z pliku Intel HEX
            TmpAddr := 0;
            PrepareMemAddr;
            LoadHexFile;
          end
          else
          begin
            // L* <adres> <nazwa pliku> - wczytanie z pliku binarnego od wskazanego adresu
            GetCmdAddres;
            PrepareMemAddr;
            LoadBinFile;
          end;
          UpdateParityFlag;
          UpdatePG;
        end
        else
          WriteLn('File not found.');
      end;
      // B - "Breakpoint" - Pulapki
      'B': begin
        case SubCommand of
          // B - wyswietl pulapki
          #0: begin
            for I := 0 to MAX_BREAKPOINTS - 1 do
              if Breakpoints[I] < $FFFF then
                WriteLn(IntToHex(I, 1), ': ', IntToHex(Breakpoints[I], 4));
          end;
          // BA <adres> <nr pulapki> - dodaj pulapke o adresie
          'A': begin
            I := HexToWord(CmdParam2);
            if (I >= 0) and (I <= $F) then
            begin
              GetCmdAddres;
              Breakpoints[I] := TmpAddr;
            end;
          end;
          // BD <nr pulapki> usun pulapke o indeksie (0-F)
          'D': begin
            I := HexToWord(CmdParam1);
            if (I >= 0) and (I <= $F) then
              Breakpoints[I] := $FFFF;
          end;
          // BC usun wszystkie pulapki
          'C': begin
            for I := 0 to MAX_BREAKPOINTS - 1 do
              Breakpoints[I] := $FFFF;
          end;
        end;
      end;
      // C - "Clear" - czysc pamiec/ resetuj
      'C': begin
        case SubCommand of
          // CA - resetuj emulatort
          'A': ResetEmu;
          // CC czysc pamiec kodu
          'C': begin
            FillChar(@xCODE, SizeOf(xCODE), #0);
            if SharedMem then
              FillChar(@xDATA, SizeOf(xDATA), #0);
          end;
          // CD - czysc pamiec DATA
          'D': begin
            if SharedMem then
              FillChar(@xCODE, SizeOf(xCODE), #0);
            FillChar(@xDATA, SizeOf(xDATA), #0);
          end;
          // CL czysc LCD
          'L': begin
            LCD_Clear;
            LCD_Dump;
          end;
        end;
      end;
      // P - "Params" - parametry
      'P': begin
        GetCmdAddres;
        case SubCommand of
          // PM <0/1> - wlacz/wylacz wspoldzilona pamiec CODE i DATA (domyslnie wlaczone)
          // 0 - CODE i DATA posiadaja wlasna przestrzen (6kb dla CODE i 6kb dla DATA)
          // 1 - CODE i DATA wspoldziela przestrzen (wspolne 12kb, jak domyslnie w DSM-51)
          'M': SharedMem := TmpAddr <> 0;
          // PC <kolor> - ustaw kolor (wartosc hex)
          'C': begin
            Poke(710, Hi(TmpAddr));
            Poke(712, Lo(TmpAddr));
          end;
          // P - pokaz parametry
          #0: WriteLn('Shared CODE and DATA ram: ', SharedMem);
        end;
      end;
    end;
  until Command = 'Q';
  ShowPM(_PM_SHOW_OFF);
  ClearPM;
end.

