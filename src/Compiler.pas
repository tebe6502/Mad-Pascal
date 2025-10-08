unit Compiler;

interface

{$I Defines.inc}

uses FileIO, CompilerTypes;

function CompilerTitle: String;

procedure Initialize;
procedure Main(const programUnit: TSourceFile; const unitPathList: TPathList);
procedure Free;

implementation

uses
  SysUtils,
  Math, // Required for Min(), do not remove
  Common,
  CommonTypes,
  Console,
  Datatypes,
  Debugger,
  MathEvaluate,
  Memory,
  Messages,
  Numbers,
  Scanner,
  Optimize,
  Parser,
  StringUtilities,
  Targets,
  Tokens,
  Utilities;

  // Temporarily own variable, because main program is no class yet.
var
  evaluationContext: IEvaluationContext;

type
  TEvaluationContext = class(TInterfacedObject, IEvaluationContext)
  public
    constructor Create;
    function GetConstantName(const expression: String; var index: TStringIndex): String;
    function GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  end;

constructor TEvaluationContext.Create;
begin
end;

function TEvaluationContext.GetConstantName(const expression: String; var index: TStringIndex): String;
begin
  Result := GetConstantUpperCase(expression, index);
end;

function TEvaluationContext.GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
var
  identTemp: Integer;
begin

  identTemp := Parser.GetIdentIndex(constantName);
  if identTemp > 0 then
  begin

    constantValue := IdentifierAt(IdentTemp).Value;
    Result := True;
  end
  else
  begin
    constantValue := 0;
    Result := False;
  end;
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure Initialize;
begin

end;

function GetIdentResult(ProcAsBlock: Integer): Integer;
var
  IdentIndex: Integer;
begin

  Result := 0;

  for IdentIndex := 1 to NumIdent do
    if (IdentifierAt(IdentIndex).Block = ProcAsBlock) and (IdentifierAt(IdentIndex).Name = 'RESULT') then
      exit(IdentIndex);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetOverloadName(IdentIndex: Integer): String;
var
  ParamIndex: Integer;
begin

  // Result := '@' + IntToHex(IdentifierAt(IdentIndex).Value, 4);

  Result := '@' + IntToHex(IdentifierAt(IdentIndex).NumParams, 2);

  if IdentifierAt(IdentIndex).NumParams > 0 then
    for ParamIndex := IdentifierAt(IdentIndex).NumParams downto 1 do
      Result := Result + IntToHex(Ord(IdentifierAt(IdentIndex).Param[ParamIndex].PassMethod), 2) +
        IntToHex(Ord(IdentifierAt(IdentIndex).Param[ParamIndex].DataType), 2) +
        IntToHex(Ord(IdentifierAt(IdentIndex).Param[ParamIndex].AllocElementType), 2) +
        IntToHex(IdentifierAt(IdentIndex).Param[ParamIndex].NumAllocElements, 8 *
        Ord(IdentifierAt(IdentIndex).Param[ParamIndex].NumAllocElements <> 0));

end;


function GetLocalName(IdentIndex: Integer; a: String = ''): String;
begin

  if ((IdentifierAt(IdentIndex).SourceFile.UnitIndex > 1) and (IdentifierAt(IdentIndex).SourceFile <>
    ActiveSourceFile) and IdentifierAt(IdentIndex).Section) then
    Result := IdentifierAt(IdentIndex).SourceFile.Name + '.' + a + IdentifierAt(IdentIndex).Name
  else
    Result := a + IdentifierAt(IdentIndex).Name;

end;


function ExtractName(IdentIndex: Integer; const a: String): String;
var
  lab: String;
begin

  lab := IdentifierAt(IdentIndex).Name;

  if (lab <> a) and (pos(IdentifierAt(IdentIndex).SourceFile.Name + '.', a) = 1) then
  begin

    lab := IdentifierAt(IdentIndex).Name;
    if lab.IndexOf('.') > 0 then lab := copy(lab, 1, lab.LastIndexOf('.'));

    if (pos(IdentifierAt(IdentIndex).SourceFile.Name + '.adr.', a) = 1) then
      Result := IdentifierAt(IdentIndex).SourceFile.Name + '.adr.' + lab
    else
      Result := IdentifierAt(IdentIndex).SourceFile.Name + '.' + lab;

  end
  else
    Result := copy(a, 1, a.IndexOf('.'));

end;


function TestName(IdentIndex: Integer; a: String): Boolean;
begin

  if (IdentIndex > 0) and (IdentifierAt(IdentIndex).SourceFile.UnitIndex > 1) and
    (pos(IdentifierAt(IdentIndex).SourceFile.Name + '.', a) = 1) then
  begin
    a := copy(a, a.IndexOf('.') + 2, length(a));
  end;

  Result := pos('.', a) > 0;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetIdentProc(S: TString; ProcIdentIndex: Integer; Param: TParamList; NumParams: Integer): Integer;
type
  TBest = record
    hit: Cardinal;
    IdentIndex, b: Integer;
  end;
var
  IdentIndex, BlockStackIndex, i, k, b: Integer;
  hits, m: Cardinal;
  df: Byte;
  yes: Boolean;

  best: array of TBest;
begin

  Result := 0;

  best := nil;
  SetLength(best, 1);
  best[0] := Default(TBest);

  for BlockStackIndex := BlockStackTop downto 0 do
    // search all nesting levels from the current one to the most outer one
  begin
    for IdentIndex := NumIdent downto 1 do
      if (IdentifierAt(IdentIndex).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
        TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) and
        (IdentifierAt(IdentIndex).SourceFile.UnitIndex = IdentifierAt(ProcIdentIndex).SourceFile.UnitIndex) and
        (S = IdentifierAt(IdentIndex).Name) and (BlockStack[BlockStackIndex] = IdentifierAt(IdentIndex).Block) and
        (IdentifierAt(IdentIndex).NumParams = NumParams) then
      begin

        hits := 0;


        for i := 1 to NumParams do
          if (((IdentifierAt(IdentIndex).Param[i].DataType in UnsignedOrdinalTypes) and
            (Param[i].DataType in UnsignedOrdinalTypes)) and
            (GetDataSize(IdentifierAt(IdentIndex).Param[i].DataType) >= GetDataSize(Param[i].DataType)))
            // .
            or (((IdentifierAt(IdentIndex).Param[i].DataType in SignedOrdinalTypes) and
            (Param[i].DataType in SignedOrdinalTypes)) and
            (GetDataSize(IdentifierAt(IdentIndex).Param[i].DataType) >= GetDataSize(Param[i].DataType)))
            // .
            or (((IdentifierAt(IdentIndex).Param[i].DataType in SignedOrdinalTypes) and
            (Param[i].DataType in UnsignedOrdinalTypes)) and  // smallint > byte
            (GetDataSize(IdentifierAt(IdentIndex).Param[i].DataType) >= GetDataSize(Param[i].DataType)))
            // .
            or ((IdentifierAt(IdentIndex).Param[i].DataType =
            Param[i].DataType) {and (IdentifierAt(IdentIndex).Param[i].AllocElementType = Param[i].AllocElementType)})
            // .
            // or ( (IdentifierAt(IdentIndex).Param[i].AllocElementType = TDataType.PROCVARTOK) and (IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16 = Param[i].NumAllocElements shr 16) )
            // .
            or ((Param[i].DataType in Pointers) and (IdentifierAt(IdentIndex).Param[i].DataType =
            Param[i].AllocElementType))    // dla parametru VAR
            // .
            or ((IdentifierAt(IdentIndex).Param[i].DataType = TDataType.UNTYPETOK) and
            (IdentifierAt(IdentIndex).Param[i].PassMethod = TParameterPassingMethod.VARPASSING))

          // or ( (IdentifierAt(IdentIndex).Param[i].DataType = TDataType.UNTYPETOK) and (IdentifierAt(IdentIndex).Param[i].PassMethod = TParameterPassingMethod.VARPASSING) and (Param[i].DataType in OrdinalTypes {+ [POINTERTOK]} {IntegerTypes + [CHARTOK]}) )

          then
          begin

            if (IdentifierAt(IdentIndex).Param[i].AllocElementType = TDataType.PROCVARTOK) then
            begin

              //  writeln(IdentifierAt(IdentIndex).Name,',', IdentifierAt(GetIdentIndex('@FN' + IntToHex(IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16, 4))].NumParams,',',Param[i].AllocElementType,' | ', IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].AllocElementType,',',IdentifierAt(GetIdentIndex('@FN' + IntToHex(Param[i).NumAllocElements shr 16, 4))].NumParams);

              case Param[i].AllocElementType of

                TDataType.PROCEDURETOK, TDataType.FUNCTIONTOK:
                  yes := IdentifierAt(GetIdentIndex('@FN' + IntToHex(
                    IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16, 4))).NumParams =
                    IdentifierAt(GetIdentIndex(Param[i].Name)).NumParams;

                TDataType.PROCVARTOK:
                  yes := (IdentifierAt(GetIdentIndex('@FN' + IntToHex(
                    IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16, 4))).NumParams) =
                    (IdentifierAt(GetIdentIndex('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))).NumParams);

                else

                  yes := False

              end;

              if yes then Inc(hits);

            end
            else
              Inc(hits);

{
writeln('_C: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}

            if (IdentifierAt(IdentIndex).Param[i].DataType = TDataType.UNTYPETOK) and
              (Param[i].DataType = TDataType.POINTERTOK) and
              (IdentifierAt(IdentIndex).Param[i].AllocElementType = TDataType.UNTYPETOK) and
              (Param[i].AllocElementType <> TDataType.UNTYPETOK) and (Param[i].NumAllocElements > 0)
            {and (IdentifierAt(IdentIndex).Param[i].NumAllocElements = Param[i].NumAllocElements)} then
            begin
{
writeln('_A: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
              Inc(hits);

            end;


            if (IdentifierAt(IdentIndex).Param[i].DataType in IntegerTypes) and
              (Param[i].DataType in IntegerTypes) then
            begin

              if IdentifierAt(IdentIndex).Param[i].DataType in UnsignedOrdinalTypes then
              begin

                b := GetDataSize(IdentifierAt(IdentIndex).Param[i].DataType);  // required parameter type
                k := GetDataSize(Param[i].DataType);      // type of parameter passed

                //       writeln('+ ',IdentifierAt(IdentIndex).Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',IdentifierAt(IdentIndex).Param[i].DataType);

                if b >= k then
                begin
                  df := 4 - abs(b - k);
                  if Param[i].DataType in UnsignedOrdinalTypes then Inc(df, 2);  // +2pts

                  Inc(hits, df);
                  //while df > 0 do begin inc(hits); dec(df) end;
                end;

              end
              else
              begin            // signed

                b := GetDataSize(IdentifierAt(IdentIndex).Param[i].DataType);  // required parameter type
                k := GetDataSize(Param[i].DataType);      // type of parameter passed

                if Param[i].DataType in [TDataType.BYTETOK, TDataType.WORDTOK] then Inc(k);  // -> signed

                //       writeln('- ',IdentifierAt(IdentIndex).Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',IdentifierAt(IdentIndex).Param[i].DataType);

                if b >= k then
                begin
                  df := 4 - abs(b - k);
                  if Param[i].DataType in SignedOrdinalTypes then Inc(df, 2);  // +2pts if the same types

                  Inc(hits, df);
                  //while df > 0 do begin inc(hits); dec(df) end;
                end;

              end;

            end;


            if (IdentifierAt(IdentIndex).Param[i].DataType = Param[i].DataType) and
              (IdentifierAt(IdentIndex).Param[i].AllocElementType <> TDataType.UNTYPETOK) and
              (IdentifierAt(IdentIndex).Param[i].AllocElementType = Param[i].AllocElementType) then

            begin
{
writeln('_D: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex, ' - ',IdentifierAt(IdentIndex).NumParams,',', NumParams);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
              Inc(hits);

            end;


            if (IdentifierAt(IdentIndex).Param[i].DataType = Param[i].DataType) and
              ((IdentifierAt(IdentIndex).Param[i].AllocElementType = Param[i].AllocElementType) or
              ((IdentifierAt(IdentIndex).Param[i].AllocElementType = TDataType.UNTYPETOK) and
              (Param[i].AllocElementType <> TDataType.UNTYPETOK) and
              (IdentifierAt(IdentIndex).Param[i].NumAllocElements = Param[i].NumAllocElements)) or
              ((IdentifierAt(IdentIndex).Param[i].AllocElementType <> TDataType.UNTYPETOK) and
              (Param[i].AllocElementType = TDataType.UNTYPETOK) and
              (IdentifierAt(IdentIndex).Param[i].NumAllocElements = Param[i].NumAllocElements))) then
            begin
{
writeln('_B: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex, ' - ',IdentifierAt(IdentIndex).NumParams,',', NumParams);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
              Inc(hits);

            end;

          end;


        k := High(best);

        best[k].IdentIndex := IdentIndex;
        best[k].hit := hits;
        best[k].b := IdentifierAt(IdentIndex).Block;

        SetLength(best, k + 2);

      end;

  end;// for


  m := 0;
  b := 0;

  if High(best) = 1 then
    Result := best[0].IdentIndex
  else
  begin

    if NumParams = 0 then
    begin

      for i := 0 to High(best) - 1 do
        if {(best[i].hit > m) and} (best[i].b >= b) then
        begin
          b := best[i].b;
          Result := best[i].IdentIndex;
        end;

    end
    else

      for i := 0 to High(best) - 1 do
        if (best[i].hit > m) and (best[i].b >= b) then
        begin
          m := best[i].hit;
          b := best[i].b;
          Result := best[i].IdentIndex;
        end;

  end;

  SetLength(best, 0);

end;  //GetIdentProc


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TestIdentProc(x: Integer; S: TString);
type
  TOV = record
    i, j, b: Integer;
    SourceFile: TSourceFile;
  end;
type
  TL = record
    SourceFile: TSourceFile;
    b: Integer;
    Param: TParamList;
    NumParams: Word;
  end;
var
  IdentIndex, BlockStackIndex: Integer;
  i, k, m: Integer;
  ok: Boolean;

  ov: array of TOV;

  l: array of TL;


  procedure addOverlay(SourceFile: TSourceFile; Block: Integer; ovr: Boolean);
  var
    i: Integer;
  begin

    for i := High(ov) - 1 downto 0 do
      if (ov[i].SourceFile.UnitIndex = SourceFile.UnitIndex) and (ov[i].b = Block) then
      begin

        Inc(ov[i].i, Ord(ovr));
        Inc(ov[i].j);

        exit;
      end;

    i := High(ov);

    ov[i].SourceFile := SourceFile;
    ov[i].b := Block;
    ov[i].i := Ord(ovr);
    ov[i].j := 1;

    SetLength(ov, i + 2);

  end;

begin

  ov := nil;
  SetLength(ov, 1);
  l := nil;
  SetLength(l, 1);

  for BlockStackIndex := BlockStackTop downto 0 do
    // search all nesting levels from the current one to the most outer one
  begin
    for IdentIndex := NumIdent downto 1 do
      if (IdentifierAt(IdentIndex).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
        TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) and (S = IdentifierAt(IdentIndex).Name) and
        (BlockStack[BlockStackIndex] = IdentifierAt(IdentIndex).Block) then
      begin

        for k := 0 to High(l) - 1 do
          if (IdentifierAt(IdentIndex).NumParams = l[k].NumParams) and
            (IdentifierAt(IdentIndex).SourceFile.UnitIndex = l[k].SourceFile.UnitIndex) and
            (IdentifierAt(IdentIndex).Block = l[k].b) then
          begin

            ok := True;

            for m := 1 to l[k].NumParams do
            begin
              if (IdentifierAt(IdentIndex).Param[m].DataType <> l[k].Param[m].DataType) or
                (IdentifierAt(IdentIndex).Param[m].AllocElementType <> l[k].Param[m].AllocElementType) then
              begin
                ok := False;
                Break;
              end;


              if (IdentifierAt(IdentIndex).Param[m].DataType = l[k].Param[m].DataType) and
                (IdentifierAt(IdentIndex).Param[m].AllocElementType = TDataType.PROCVARTOK) and
                (l[k].Param[m].AllocElementType = TDataType.PROCVARTOK) and
                (IdentifierAt(IdentIndex).Param[m].NumAllocElements shr 16 <>
                l[k].Param[m].NumAllocElements shr 16) then
              begin

                //writeln('>',IdentifierAt(IdentIndex).NumParams);//,',', l[k].Param[m].NumParams );

                ok := False;
                Break;

              end;

            end;

            if ok then
              Error(x, TMessage.Create(TErrorCode.WrongParameterList, 'Overloaded functions ''' +
                IdentifierAt(IdentIndex).Name + ''' have the same parameter list'));

          end;

        k := High(l);

        l[k].NumParams := IdentifierAt(IdentIndex).NumParams;
        l[k].Param := IdentifierAt(IdentIndex).Param;
        l[k].SourceFile := IdentifierAt(IdentIndex).SourceFile;
        l[k].b := IdentifierAt(IdentIndex).Block;

        SetLength(l, k + 2);

        addOverlay(IdentifierAt(IdentIndex).SourceFile, IdentifierAt(IdentIndex).Block,
          IdentifierAt(IdentIndex).isOverload);
      end;

  end;// for

  for i := 0 to High(ov) - 1 do
    if ov[i].j > 1 then
      if ov[i].i <> ov[i].j then
        Error(x, TMessage.Create(TErrorCode.NotAllDeclarationsOverloaded, 'Not all declarations of ' +
          IdentifierAt(NumIdent).Name + ' are declared with OVERLOAD'));

  SetLength(l, 0);
  SetLength(ov, 0);

end;  //TestIdentProc


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddCallGraphChild(ParentBlock, ChildBlock: Integer);
begin

  if ParentBlock <> ChildBlock then
  begin

    Inc(CallGraph[ParentBlock].NumChildren);
    CallGraph[ParentBlock].ChildBlock[CallGraph[ParentBlock].NumChildren] := ChildBlock;

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure asm65separator(a: Boolean = True);
begin

  if a then asm65;

  asm65('; ' + StringOfChar('-', 60));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetStackVariable(n: Byte): TString;
begin

  case n of
    0: Result := ' :STACKORIGIN,x';
    1: Result := ' :STACKORIGIN+STACKWIDTH,x';
    2: Result := ' :STACKORIGIN+STACKWIDTH*2,x';
    3: Result := ' :STACKORIGIN+STACKWIDTH*3,x';
    else
      Result := ''
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure a65(code: TCode65; Value: Int64 = 0; Kind: TTokenKind = TTokenKind.CONSTTOK;
  Size: Byte = 4; IdentIndex: Integer = 0);
var
  v: Byte;
  svar: String;
begin

  case code of

    TCode65.putEOL: asm65(#9'@printEOL');
    TCode65.putCHAR: asm65(#9'jsr @printCHAR');

    TCode65.shlAL_CL: asm65(#9'jsr @shlEAX_CL.BYTE');
    TCode65.shlAX_CL: asm65(#9'jsr @shlEAX_CL.WORD');
    TCode65.shlEAX_CL: asm65(#9'jsr @shlEAX_CL.CARD');

    TCode65.shrAL_CL: asm65(#9'jsr @shrAL_CL');
    TCode65.shrAX_CL: asm65(#9'jsr @shrAX_CL');
    TCode65.shrEAX_CL: asm65(#9'jsr @shrEAX_CL');

    // TCode65.je: asm65(#9'beq *+5');          // =
    // TCode65.jne: asm65(#9'bne *+5');          // <>
    // TCode65.jg: begin asm65(#9'seq'); asm65(#9'bcs *+5') end;  // >
    // TCode65.jge: asm65(#9'bcs *+5');          // >=
    // TCode65.jl: asm65(#9'bcc *+5');          // <
    // TCode65.jle: begin asm65(#9'bcc *+7'); asm65(#9'beq *+5') end;  // <=

    TCode65.addBX: asm65(#9'inx');
    TCode65.subBX: asm65(#9'dex');

    TCode65.addAL_CL: asm65(#9'jsr addAL_CL');
    TCode65.addAX_CX: asm65(#9'jsr addAX_CX');
    TCode65.addEAX_ECX: asm65(#9'jsr addEAX_ECX');

    TCode65.subAL_CL: asm65(#9'jsr subAL_CL');
    TCode65.subAX_CX: asm65(#9'jsr subAX_CX');
    TCode65.subEAX_ECX: asm65(#9'jsr subEAX_ECX');

    TCode65.imulECX: asm65(#9'jsr imulECX');

    TCode65.movaBX_Value: begin

      if Kind = TTokenKind.VARTOK then
      begin          // @label

        svar := GetLocalName(IdentIndex);

        asm65(#9'mva <' + svar + GetStackVariable(0));
        asm65(#9'mva >' + svar + GetStackVariable(1));

      end
      else
      begin

        // Size:=4;

        v := Byte(Value);
        asm65(#9'mva #$' + IntToHex(Byte(v), 2) + GetStackVariable(0));

        if Size in [2, 4] then
        begin
          v := Byte(Value shr 8);
          asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(1));
        end;

        if Size = 4 then
        begin
          v := Byte(Value shr 16);
          asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(2));

          v := Byte(Value shr 24);
          asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(3));
        end;

      end;

    end;

  end;

end;  //a65


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Gen;
begin

  if not OutputDisabled then Inc(CodeSize);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandParam(const Dest, Source: TDataType);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var
  i: Integer;
begin

  if (Source in IntegerTypes) and (Dest in IntegerTypes) then
  begin

    i := GetDataSize(Dest) - GetDataSize(Source);

    if i > 0 then
      case i of
        1: if (Source in SignedOrdinalTypes) then  // to WORD
            asm65(#9'jsr @expandSHORT2SMALL')
          else
            asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x');

        2: if (Source in SignedOrdinalTypes) then  // to CARDINAL
            asm65(#9'jsr @expandToCARD.SMALL')
          else
          begin
            //       asm65(#9'jsr @expandToCARD.WORD');

            asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x');
          end;

        3: if (Source in SignedOrdinalTypes) then  // to CARDINAL
            asm65(#9'jsr @expandToCARD.SHORT')
          else
          begin
            //       asm65(#9'jsr @expandToCARD.BYTE');

            asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x');
          end;

      end;

  end;

end;  //ExpandParam


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandParam_m1(Dest, Source: TDataType);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var
  i: Integer;
begin

  if (Source in IntegerTypes) and (Dest in IntegerTypes) then
  begin

    i := GetDataSize(Dest) - GetDataSize(Source);


    if i > 0 then
      case i of
        1: if (Source in SignedOrdinalTypes) then  // to WORD
            asm65(#9'jsr @expandSHORT2SMALL1')
          else
            asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x');

        2: if (Source in SignedOrdinalTypes) then  // to CARDINAL
            asm65(#9'jsr @expandToCARD1.SMALL')
          else
          begin
            //       asm65(#9'jsr @expandToCARD1.WORD');

            asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*3,x');
          end;

        3: if (Source in SignedOrdinalTypes) then  // to CARDINAL
            asm65(#9'jsr @expandToCARD1.SHORT')
          else
          begin
            //       asm65(#9'jsr @expandToCARD1.BYTE');

            asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*3,x');
          end;

      end;

  end;

end;  //ExpandParam_m1

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandExpression(var ValType: TDataType; RightValType, VarType: TDataType; ForceMinusSign: Boolean = False);
var
  m: Byte;
  sign: Boolean;
begin

  if (ValType in IntegerTypes) and (RightValType in IntegerTypes) then
  begin

    if (GetDataSize(ValType) < GetDataSize(RightValType)) and ((VarType = TDataType.UNTYPETOK) or
      (GetDataSize(RightValType) >= GetDataSize(VarType))) then
    begin
      ExpandParam_m1(RightValType, ValType);    // -1
      ValType := RightValType;        // przyjmij najwiekszy typ dla operacji
    end
    else
    begin

      if VarType in Pointers then VarType := TDataType.WORDTOK;

      m := GetDataSize(ValType);
      if GetDataSize(RightValType) > m then m := GetDataSize(RightValType);

      if VarType = TDataType.BOOLEANTOK then
        Inc(m)            // dla sytuacji np.: boolean := (shortint + shorint > 0)
      else

        if VarType <> TDataType.UNTYPETOK then
          if GetDataSize(VarType) > m then Inc(m);    // okreslamy najwiekszy wspolny typ
      //m:=GetDataSize(VarType];


      if (ValType in SignedOrdinalTypes) or (RightValType in SignedOrdinalTypes) or ForceMinusSign then
        sign := True
      else
        sign := False;

      case m of
        1: if sign then VarType := TDataType.SHORTINTTOK
          else
            VarType := TDataType.BYTETOK;
        2: if sign then VarType := TDataType.SMALLINTTOK
          else
            VarType := TDataType.WORDTOK;
        else
          if sign then VarType := TDataType.INTEGERTOK
          else
            VarType := TDataType.CARDINALTOK
      end;

      ExpandParam_m1(VarType, ValType);
      ExpandParam(VarType, RightValType);

      ValType := VarType;

    end;

  end;

end;  //ExpandExpression

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandWord; //(regA: integer = -1);
begin

  Gen;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandByte;
begin

  Gen;

  ExpandWord;  // (0);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function InfoAboutSize(Size: Byte): String;
begin

  case Size of
    1: Result := ' BYTE / CHAR / SHORTINT / BOOLEAN';
    2: Result := ' WORD / SMALLINT / SHORTREAL / POINTER';
    4: Result := ' CARDINAL / INTEGER / REAL / SINGLE';
    else
      Result := ' unknown'
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIndexShift(ElementType: TDataType; Ofset: Byte = 0);
begin

  case GetDataSize(ElementType) of

    2: if Ofset = 0 then
      begin
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta :STACKORIGIN,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

        asm65(#9'asl :STACKORIGIN,x');
        asm65(#9'rol @');

        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta :STACKORIGIN,x');
      end
      else
      begin
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');

        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');

        asm65(#9'asl :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'rol @');

        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
      end;

    4: if Ofset = 0 then
      begin
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta :STACKORIGIN,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

        asm65(#9'asl :STACKORIGIN,x');
        asm65(#9'rol @');
        asm65(#9'asl :STACKORIGIN,x');
        asm65(#9'rol @');

        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta :STACKORIGIN,x');
      end
      else
      begin
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');

        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');

        asm65(#9'asl :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'rol @');
        asm65(#9'asl :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'rol @');

        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');
        asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
      end;

  end;

end;  //GenerateIndexShift


(*
procedure GenerateInterrupt(InterruptNumber: Byte);

 DLI     5  ($200)   Wektor przerwan NMI listy displejowej
 VBI     6  ($222)   Wektor NMI natychmiastowego VBI
 VBL     7  ($224)   Wektor NMI opoznionego VBI
 RESET
 IRQ
 BRK

VDSLST $0200 $E7B3 Wektor przerwan NMI listy displejowej
VPRCED $0202 $E7B3 Wektor IRQ procedury pryferyjnej
VINTER $0204 $E7B3 Wektor IRQ urzadzen peryferyjnych
VBREAK $0206 $E7B3 Wektor IRQ programowej instrukcji BRK
VKEYBD $0208 $EFBE Wektor IRQ klawiatury
VSERIN $020A $EB11 Wektor IRQ gotowosci wejscia szeregowego
VSEROR $020C $EA90 Wektor IRQ gotowosci wyjscia szeregowego
VSEROC $020E $EAD1 Wektor IRQ zakonczenia przesylania szereg.
VTIMR1 $0210 $E7B3 Wektor IRQ licznika 1 ukladu POKEY
VTIMR2 $0212 $E7B3 Wektor IRQ licznika 2 ukladu POKEY
VTIMR4 $0214 $E7B3 Wektor IRQ licznika 4 ukladu POKEY

VIMIRQ $0216 $E6F6 Wektor sterownika przerwan IRQ
VVBLKI $0222 $E7D1 Wektor NMI natychmiastowego VBI
VVBLKD $0224 $E93E Wektor NMI opoznionego VBI
CDTMA1 $0226 $XXXX Adres JSR licznika systemowego 1
CDTMA2 $0228 $XXXX Adres JSR licznika systemowego 2
BRKKEY $0236 $E754 Wektor IRQ klawisza BREAK **

begin

end;// GenerateInterrupt
*)


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure StopOptimization;
begin

  if run_func = 0 then
  begin

    common.optimize.use := False;

    if High(OptimizeBuf) > 0 then asm65;

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure StartOptimization(i: TTokenIndex);
begin

  StopOptimization;

  common.optimize.use := True;
  common.optimize.SourceFile := TokenAt(i).SourceLocation.SourceFile;
  common.optimize.line := TokenAt(i).SourceLocation.Line;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure LoadBP2(IdentIndex: Integer; svar: String);
var
  lab: String;
begin

  if (pos('.', svar) > 0) then
  begin

    //  lab:=copy(svar,1,pos('.', svar)-1);
    lab := ExtractName(IdentIndex, svar);

    if IdentifierAt(GetIdentIndex(lab)).AllocElementType = TDataType.RECORDTOK then
    begin

      asm65(#9'mwy ' + lab + ' :bp2');    // !!! koniecznie w ten sposob
      // !!! kolejne optymalizacje podstawia pod :BP2 -> LAB
      asm65(#9'lda :bp2');
      asm65(#9'add #' + svar + '-DATAORIGIN');
      asm65(#9'sta :bp2');
      asm65(#9'lda :bp2+1');
      asm65(#9'adc #$00');
      asm65(#9'sta :bp2+1');

    end
    else
      asm65(#9'mwy ' + svar + ' :bp2');

  end
  else
    asm65(#9'mwy ' + svar + ' :bp2');

end;  //LoadBP2


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Push(Value: Int64; IndirectionLevel: TIndirectionLevel; Size: Byte;
  IdentIndex: TIdentifierIndex = 0; par: Byte = 0);
var
  Kind: TTokenKind;
  NumAllocElements: Cardinal;
  svar, svara, lab: String;
begin

  if IdentIndex > 0 then
  begin
    Kind := IdentifierAt(IdentIndex).Kind;

    if IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK then
    begin
      Size := GetDataSize(IdentifierAt(IdentIndex).AllocElementType);
      NumAllocElements := 0;
    end
    else
      NumAllocElements := Elements(IdentIndex);  //IdentifierAt(IdentIndex).NumAllocElements;

    svar := GetLocalName(IdentIndex);

  end
  else
  begin
    Kind := TTokenKind.CONSTTOK;
    NumAllocElements := 0;
    svar := '';
  end;

  svara := svar;
  if pos('.', svar) > 0 then
    svara := GetLocalName(IdentIndex, 'adr.')
  else
    svara := 'adr.' + svar;

  asm65separator;

  asm65;
  asm65('; Push' + InfoAboutSize(Size));

  case IndirectionLevel of

    ASVALUE:
    begin
      asm65('; as Value $' + IntToHex(Value, 8) + ' (' + IntToStr(Value) + ')');
      asm65;

      a65(TCode65.addBX);

      Gen;
      a65(TCode65.movaBX_Value, Value, Kind, Size, IdentIndex);

    end;


    ASPOINTER:
    begin
      asm65('; as Pointer');
      asm65;

      Gen;

      a65(TCode65.addBX);

      case Size of

        1: begin
          asm65(#9'mva ' + svar + GetStackVariable(0));

          ExpandByte;
        end;

        2: begin

          if TestName(IdentIndex, svar) then
          begin

            lab := ExtractName(IdentIndex, svar);

            if IdentifierAt(GetIdentIndex(lab)).AllocElementType = TDataType.RECORDTOK then
            begin
              asm65(#9'lda ' + lab);
              asm65(#9'ldy ' + lab + '+1');
              asm65(#9'add #' + svar + '-DATAORIGIN');
              asm65(#9'scc');
              asm65(#9'iny');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'sty' + GetStackVariable(1));
            end
            else
            begin
              asm65(#9'mva ' + svar + GetStackVariable(0));
              asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
            end;

          end
          else
          begin
            asm65(#9'mva ' + svar + GetStackVariable(0));
            asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
          end;

          ExpandWord;
        end;

        4: begin
          asm65(#9'mva ' + svar + GetStackVariable(0));
          asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
          asm65(#9'mva ' + svar + '+2' + GetStackVariable(2));
          asm65(#9'mva ' + svar + '+3' + GetStackVariable(3));
        end;

      end;

    end;


    ASPOINTERTORECORD:
    begin
      asm65('; as Pointer to Record');
      asm65;

      Gen;

      a65(TCode65.addBX);

      if TestName(IdentIndex, svar) then
        asm65(#9'lda #' + svar + '-DATAORIGIN')
      else
        asm65(#9'lda #$' + IntToHex(par, 2));

      if TestName(IdentIndex, svar) then
      begin
        asm65(#9'add ' + ExtractName(IdentIndex, svar));
        asm65(#9'sta' + GetStackVariable(0));
        asm65(#9'lda #$00');
        asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
        asm65(#9'sta' + GetStackVariable(1));
      end
      else
      begin
        asm65(#9'add ' + svar);
        asm65(#9'sta' + GetStackVariable(0));
        asm65(#9'lda #$00');
        asm65(#9'adc ' + svar + '+1');
        asm65(#9'sta' + GetStackVariable(1));
      end;

    end;


    ASPOINTERTOPOINTER:
    begin
      asm65('; as Pointer to Pointer');
      asm65;

      Gen;

      a65(TCode65.addBX);

      if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <>
        TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('+' + svar);  // +lda

      //  writeln(IdentifierAt(IdentIndex).PassMethod,',', IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', svar,',',ExtractName(IdentIndex, svar),',',par);

      if TestName(IdentIndex, svar) then
      begin

        if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
          (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
          (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) then
          asm65(#9'mwy ' + svar + ' :bp2')
        else
          asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

      end
      else
        asm65(#9'mwy ' + svar + ' :bp2');


      if TestName(IdentIndex, svar) then
      begin

        if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
          (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
          (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) then
          asm65(#9'ldy #$' + IntToHex(par, 2))
        else
          asm65(#9'ldy #' + svar + '-DATAORIGIN');

      end
      else
        asm65(#9'ldy #$' + IntToHex(par, 2));

      case Size of
        1: begin

          asm65(#9'mva (:bp2),y' + GetStackVariable(0));

          ExpandByte;
        end;

        2: begin

          asm65(#9'mva (:bp2),y' + GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'mva (:bp2),y' + GetStackVariable(1));

          ExpandWord;
        end;

        4: begin

          asm65(#9'mva (:bp2),y' + GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'mva (:bp2),y' + GetStackVariable(1));
          asm65(#9'iny');
          asm65(#9'mva (:bp2),y' + GetStackVariable(2));
          asm65(#9'iny');
          asm65(#9'mva (:bp2),y' + GetStackVariable(3));

        end;
      end;

      if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <>
        TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then
        asm65('+');  // +lda

    end;


    ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
      asm65('; as Pointer to Array Origin');
      asm65;

      Gen;

      case Size of
        1: begin                    // PUSH BYTE

          if (NumAllocElements > 256) or (NumAllocElements in [0, 1]) then
          begin

            if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <>
              TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then
              asm65('+' + svar);  // +lda

            if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
              TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
            begin

              asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
              asm65(#9'add' + GetStackVariable(0));
              asm65(#9'tay');
              asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
              asm65(#9'adc' + GetStackVariable(1));
              asm65(#9'sta :bp+1');
              asm65(#9'lda (:bp),y');
              asm65(#9'sta' + GetStackVariable(0));

            end
            else
            begin

              if IdentifierAt(IdentIndex).ObjectVariable and (IdentifierAt(IdentIndex).PassMethod =
                TParameterPassingMethod.VARPASSING) then
              begin

                asm65(#9'mwy ' + svar + ' :TMP');

                asm65(#9'ldy #$00');
                asm65(#9'lda (:TMP),y');
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'sta :bp2');
                asm65(#9'iny');
                asm65(#9'lda (:TMP),y');
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp2+1');
                asm65(#9'ldy #$00');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta' + GetStackVariable(0));

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'tay');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp+1');
                asm65(#9'lda (:bp),y');
                asm65(#9'sta' + GetStackVariable(0));

              end;

            end;

            if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <>
              TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then
              asm65('+');  // +lda

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN,x');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(0));

            end
            else
            begin

              asm65(#9'lda' + GetStackVariable(0));
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda' + GetStackVariable(1));
              asm65(#9'adc #$00');
              asm65(#9'sta' + GetStackVariable(1));

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta' + GetStackVariable(0));
              // =b'
            end;

          end;

          ExpandByte;
        end;

        2: begin                    // PUSH WORD

          if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
            GenerateIndexShift(TDataType.WORDTOK);

          asm65;

          if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
          begin

            if IdentifierAt(IdentIndex).isStriped then
            begin

              asm65(#9'lda' + GetStackVariable(0));
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda' + GetStackVariable(1));
              asm65(#9'adc #$00');
              asm65(#9'sta' + GetStackVariable(1));

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
              asm65(#9'sta' + GetStackVariable(1));

            end
            else
            begin

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
                TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'sta :bp2');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp2+1');

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'sta :bp2');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp2+1');

              end;

              asm65(#9'ldy #$00');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(1));

            end;

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN,x');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(1));

            end
            else
            begin

              asm65(#9'lda' + GetStackVariable(0));
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda' + GetStackVariable(1));
              asm65(#9'adc #$00');
              asm65(#9'sta' + GetStackVariable(1));

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta' + GetStackVariable(0));

              if IdentifierAt(IdentIndex).isStriped then
                asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
              else
                asm65(#9'lda ' + svara + '+1,y');

              asm65(#9'sta' + GetStackVariable(1));
              // =w'
            end;

          end;

          ExpandWord;
        end;

        4: begin                      // PUSH CARDINAL

          if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
            GenerateIndexShift(TDataType.CARDINALTOK);

          asm65;

          if (NumAllocElements * 4 > 256) or (NumAllocElements in [0, 1]) then
          begin

            if IdentifierAt(IdentIndex).isStriped then
            begin

              asm65(#9'lda' + GetStackVariable(0));
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda' + GetStackVariable(1));
              asm65(#9'adc #$00');
              asm65(#9'sta' + GetStackVariable(1));

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
              asm65(#9'sta' + GetStackVariable(1));
              asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
              asm65(#9'sta' + GetStackVariable(2));
              asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
              asm65(#9'sta' + GetStackVariable(3));

            end
            else
            begin

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
                TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'sta :bp2');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp2+1');

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'sta :bp2');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp2+1');

              end;

              asm65(#9'ldy #$00');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(1));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(2));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(3));

            end;

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN,x');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(0));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(1));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(2));
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta' + GetStackVariable(3));

            end
            else
            begin

              asm65(#9'lda' + GetStackVariable(0));
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda' + GetStackVariable(1));
              asm65(#9'adc #$00');
              asm65(#9'sta' + GetStackVariable(1));

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta' + GetStackVariable(0));

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9'sta' + GetStackVariable(1));
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9'sta' + GetStackVariable(2));
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                asm65(#9'sta' + GetStackVariable(3));

              end
              else
              begin

                asm65(#9'lda ' + svara + '+1,y');
                asm65(#9'sta' + GetStackVariable(1));
                asm65(#9'lda ' + svara + '+2,y');
                asm65(#9'sta' + GetStackVariable(2));
                asm65(#9'lda ' + svara + '+3,y');
                asm65(#9'sta' + GetStackVariable(3));

              end;
              // =c'
            end;

          end;

        end;
      end;

    end;


    ASPOINTERTOARRAYRECORD:                  // array [0..X] of ^record
    begin
      asm65('; as Pointer to Array ^Record');
      asm65;

      Gen;

      asm65(#9'lda' + GetStackVariable(0));

      if TestName(IdentIndex, svar) then
      begin
        asm65(#9'add ' + ExtractName(IdentIndex, svar));
        asm65(#9'sta :TMP');
        asm65(#9'lda' + GetStackVariable(1));
        asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
        asm65(#9'sta :TMP+1');
      end
      else
      begin
        asm65(#9'add ' + svar);
        asm65(#9'sta :TMP');
        asm65(#9'lda' + GetStackVariable(1));
        asm65(#9'adc ' + svar + '+1');
        asm65(#9'sta :TMP+1');
      end;

      asm65(#9'ldy #$00');
      asm65(#9'lda (:TMP),y');
      asm65(#9'sta :bp2');
      asm65(#9'iny');
      asm65(#9'lda (:TMP),y');
      asm65(#9'sta :bp2+1');

      if TestName(IdentIndex, svar) then
        asm65(#9'ldy #' + svar + '-DATAORIGIN')
      else
        asm65(#9'ldy #$' + IntToHex(par, 2));

      case Size of
        1: begin

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(0));

          ExpandByte;
        end;

        2: begin

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(1));

          ExpandWord;
        end;

        4: begin

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(1));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(2));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(3));

        end;
      end;

    end;


    ASPOINTERTOARRAYRECORDTOSTRING:                  // array_of_pointer_to_record[index].string
    begin
      asm65('; as Pointer to Array ^Record to String');
      asm65;

      Gen;

      asm65(#9'lda' + GetStackVariable(0));

      if TestName(IdentIndex, svar) then
      begin
        asm65(#9'add ' + ExtractName(IdentIndex, svar));
        asm65(#9'sta :bp2');
        asm65(#9'lda' + GetStackVariable(1));
        asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
        asm65(#9'sta :bp2+1');
      end
      else
      begin
        asm65(#9'add ' + svar);
        asm65(#9'sta :bp2');
        asm65(#9'lda' + GetStackVariable(1));
        asm65(#9'adc ' + svar + '+1');
        asm65(#9'sta :bp2+1');
      end;

      asm65(#9'ldy #$00');
      asm65(#9'lda (:bp2),y');

      if TestName(IdentIndex, svar) then
      begin
        asm65(#9'add #' + svar + '-DATAORIGIN');
      end
      else
        asm65(#9'add #$' + IntToHex(par, 2));

      asm65(#9'sta' + GetStackVariable(0));

      asm65(#9'iny');
      asm65(#9'lda (:bp2),y');
      asm65(#9'adc #$00');
      asm65(#9'sta' + GetStackVariable(1));

    end;


    ASPOINTERTORECORDARRAYORIGIN:                  // record^.array[i]
    begin
      asm65('; as Pointer to Record^ Array Origin');
      asm65;

      Gen;

      if TestName(IdentIndex, svar) then
        asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2')
      else
        asm65(#9'mwy ' + svar + ' :bp2');

      asm65(#9'lda' + GetStackVariable(0));

      if TestName(IdentIndex, svar) then
        asm65(#9'add #' + svar + '-DATAORIGIN')
      else
        asm65(#9'add #$' + IntToHex(par, 2));

      asm65(#9'sta' + GetStackVariable(0));
      asm65(#9'lda' + GetStackVariable(1));
      asm65(#9'adc #$00');
      asm65(#9'sta' + GetStackVariable(1));

      asm65(#9'ldy' + GetStackVariable(0));

      case Size of
        1: begin

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(0));

          ExpandByte;
        end;

        2: begin

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(1));

          ExpandWord;
        end;

        4: begin

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(1));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(2));
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta' + GetStackVariable(3));

        end;
      end;

    end;


    ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN:              // record_array[index].array[i]
    begin

      if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
      begin

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'lda ' + ExtractName(IdentIndex, svar));
          asm65(#9'add :STACKORIGIN-1,x');
          asm65(#9'sta :TMP');
          asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
          asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :TMP+1');
        end
        else
        begin
          asm65(#9'lda ' + svar);
          asm65(#9'add :STACKORIGIN-1,x');
          asm65(#9'sta :TMP');
          asm65(#9'lda ' + svar + '+1');
          asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :TMP+1');
        end;

        asm65(#9'ldy #$00');
        asm65(#9'lda (:TMP),y');
        asm65(#9'sta :bp2');
        asm65(#9'iny');
        asm65(#9'lda (:TMP),y');
        asm65(#9'sta :bp2+1');

      end
      else
      begin

        asm65(#9'ldy :STACKORIGIN-1,x');
        //   asm65(#9'lda adr.' + svar + ',y');
        asm65(#9'lda ' + svara + ',y');
        asm65(#9'sta :bp2');
        //   asm65(#9'lda adr.' + svar + '+1,y');
        asm65(#9'lda ' + svara + '+1,y');
        asm65(#9'sta :bp2+1');

      end;

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'add #$' + IntToHex(par, 2));
      asm65(#9'sta :STACKORIGIN,x');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'adc #$00');
      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

      asm65(#9'ldy :STACKORIGIN,x');

      case Size of
        1: begin
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1,x');
        end;

        2: begin
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
        end;

        4: begin
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
        end;

      end;

      //     a65(TCode65.subBX);
      a65(TCode65.subBX);

    end;

  end;// case

end;  //Push


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveToSystemStack(cnt: Integer);
var
  i: Integer;
begin
  // asm65;
  // asm65('; Save conditional expression');    //at expression stack top onto the system :STACK');

  Gen;
  Gen;
  Gen;            // push dword ptr [bx]

  if Pass = TPass.CODE_GENERATION then
    for i in IFTmpPosStack do
      if i = cnt then
      begin
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta :STACKORIGIN,x');

        Break;
      end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RestoreFromSystemStack(cnt: Integer);
var
  i: Integer;
begin
  //asm65;
  //asm65('; Restore conditional expression');

  Gen;
  Gen;
  Gen;            // add bx, 4

  asm65(#9'lda IFTMP_' + IntToHex(cnt, 4));

  if Pass = TPass.CALL_DETERMINATION then
  begin

    i := High(IFTmpPosStack);

    IFTmpPosStack[i] := cnt;

    SetLength(IFTmpPosStack, i + 2);

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RemoveFromSystemStack;
begin

  Gen;
  Gen;            // pop :eax

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateFileOpen(IdentIndex: Integer; ioCode: TIOCode);
begin

  ResetOpty;

  asm65;
  asm65(#9'txa:pha');

  if IOCheck then
    asm65(#9'sec')
  else
    asm65(#9'clc');

  case ioCode of

    TIOCode.Append,
    TIOCode.OpenRead,
    TIOCode.OpenWrite:

      asm65(#9'@openfile ' + IdentifierAt(IdentIndex).Name + ', #' + IntToStr(GetIOBits(ioCode)));

    TIOCode.FileMode:

      asm65(#9'@openfile ' + IdentifierAt(IdentIndex).Name + ', MAIN.SYSTEM.FileMode');

    TIOCode.Close:

      asm65(#9'@closefile ' + IdentifierAt(IdentIndex).Name);

  end;

  asm65(#9'pla:tax');
  asm65;

end;  //GenerateFileOpen


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateFileRead(IdentIndex: Integer; ioCode: TIOCode; NumParams: Integer = 0);
begin

  ResetOpty;

  asm65;
  asm65(#9'txa:pha');

  if IOCheck then
    asm65(#9'sec')
  else
    asm65(#9'clc');

  case ioCode of

    TIOCode.Read,
    TIOCode.Write,
    TIOCode.ReadRecord,
    TIOCode.WriteRecord:

      if NumParams = 3 then
        asm65(#9'@readfile ' + IdentifierAt(IdentIndex).Name + ', #' + IntToStr(GetIOBits(ioCode) or $80))
      else
        asm65(#9'@readfile ' + IdentifierAt(IdentIndex).Name + ', #' + IntToStr(GetIOBits(ioCode)));

  end;

  asm65(#9'pla:tax');
  asm65;

end;  //GenerateFileRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIncDec(IndirectionLevel: Byte; ExpressionType: TDataType; Down: Boolean; IdentIndex: TIdentIndex);
var
  b, c, svar, svara: String;
  NumAllocElements: Cardinal;
begin

  //svar := GetLocalName(IdentIndex);
  //NumAllocElements := Elements(IdentIndex);

  if IdentIndex > 0 then
  begin

    if IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK then
    begin
      NumAllocElements := 0;
    end
    else
      NumAllocElements := Elements(IdentIndex); //IdentifierAt(IdentIndex).NumAllocElements;

    svar := GetLocalName(IdentIndex);

  end
  else
  begin
    NumAllocElements := 0;
    svar := '';
  end;

  svara := svar;
  if pos('.', svar) > 0 then
    svara := GetLocalName(IdentIndex, 'adr.')
  else
    svara := 'adr.' + svar;


  if Down then
  begin
    // asm65;
    // asm65('; Dec(var X [ ; N: int ] ) -> ' + InfoAboutToken(ExpressionType));

    //  a:='sbb';
    b := 'sub';
    c := 'sbc';

  end
  else
  begin
    // asm65;
    // asm65('; Inc(var X [ ; N: int ] ) -> ' + InfoAboutToken(ExpressionType));

    //  a:='adb';
    b := 'add';
    c := 'adc';

  end;

  case IndirectionLevel of

    ASPOINTER:
    begin
      asm65('; as Pointer');
      asm65;

      case GetDataSize(ExpressionType) of
        1: begin
          asm65(#9'lda ' + svar);
          asm65(#9 + b + ' :STACKORIGIN,x');
          asm65(#9'sta ' + svar);
        end;

        2: begin
          asm65(#9'lda ' + svar);
          asm65(#9 + b + ' :STACKORIGIN,x');
          asm65(#9'sta ' + svar);

          asm65(#9'lda ' + svar + '+1');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta ' + svar + '+1');
        end;

        4: begin
          asm65(#9'lda ' + svar);
          asm65(#9 + b + ' :STACKORIGIN,x');
          asm65(#9'sta ' + svar);

          asm65(#9'lda ' + svar + '+1');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta ' + svar + '+1');

          asm65(#9'lda ' + svar + '+2');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta ' + svar + '+2');

          asm65(#9'lda ' + svar + '+3');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta ' + svar + '+3');
        end;

      end;

    end;


    ASPOINTERTOPOINTER:
    begin

      asm65('; as Pointer To Pointer');
      asm65;

      LoadBP2(IdentIndex, svar);

      asm65(#9'ldy #$00');

      case GetDataSize(ExpressionType) of
        1: begin
          asm65(#9'lda (:bp2),y');
          asm65(#9 + b + ' :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
        end;

        2: begin
          asm65(#9'lda (:bp2),y');
          asm65(#9 + b + ' :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
        end;

        4: begin
          asm65(#9'lda (:bp2),y');
          asm65(#9 + b + ' :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (:bp2),y');
        end;

      end;

    end;


    ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin

      asm65('; as Pointer To Array Origin');
      asm65;

      case GetDataSize(ExpressionType) of
        1: begin

          if (NumAllocElements > 256) or (NumAllocElements in [0, 1]) then
          begin
            if (IdentIndex > 0) and (IdentifierAt(IdentIndex).isAbsolute) and
              (IdentifierAt(IdentIndex).idType = TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
            begin

              asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
              asm65(#9'add :STACKORIGIN-1,x');
              asm65(#9'tay');
              asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
              asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'sta :bp+1');

              asm65(#9'lda (:bp),y');
              asm65(#9 + b + ' :STACKORIGIN,x');
              asm65(#9'sta (:bp),y');

            end
            else
            begin

              asm65(#9'lda ' + svar);
              asm65(#9'add :STACKORIGIN-1,x');
              asm65(#9'tay');
              asm65(#9'lda ' + svar + '+1');
              asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'sta :bp+1');

              asm65(#9'lda (:bp),y');
              asm65(#9 + b + ' :STACKORIGIN,x');
              asm65(#9'sta (:bp),y');

            end;

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN-1,x');
              asm65(#9'lda (:bp2),y');
              asm65(#9 + b + ' :STACKORIGIN,x');
              asm65(#9'sta (:bp2),y');

            end
            else
            begin
{
        asm65(#9'ldy :STACKORIGIN-1,x');
        asm65(#9'lda '+svara+',y');
        asm65(#9 + b + ' :STACKORIGIN,x');
        asm65(#9'sta '+svara+',y');
}
              asm65(#9'lda <' + svara);
              asm65(#9'add :STACKORIGIN-1,x');
              asm65(#9'tay');

              asm65(#9'lda >' + svara);
              asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'sta :bp+1');

              asm65(#9'lda (:bp),y');
              asm65(#9 + b + ' :STACKORIGIN,x');
              asm65(#9'sta (:bp),y');

            end;

          end;

        end;

        2: if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
          begin

            LoadBP2(IdentIndex, svar);

            asm65(#9'lda :bp2');
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :bp2+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:bp2),y');
            asm65(#9 + b + ' :STACKORIGIN,x');
            asm65(#9'sta (:bp2),y');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta (:bp2),y');

          end
          else
          begin

            if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda ' + svara + ',y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

              end
              else
              begin

                if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
                  TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
                begin

                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                  asm65(#9'add :STACKORIGIN-1,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');

                end
                else
                begin

                  asm65(#9'lda ' + svar);
                  asm65(#9'add :STACKORIGIN-1,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda ' + svar + '+1');
                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');

                end;

                asm65(#9'ldy #$00');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta (:bp2),y');

              end;

            end
            else
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda ' + svara + ',y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

              end
              else
              begin

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda ' + svara + ',y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda ' + svara + '+1,y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+1,y');

              end;

            end;

          end;
        4: if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
          begin

            LoadBP2(IdentIndex, svar);

            asm65(#9'lda :bp2');
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :bp2+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:bp2),y');
            asm65(#9 + b + ' :STACKORIGIN,x');
            asm65(#9'sta (:bp2),y');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta (:bp2),y');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta (:bp2),y');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta (:bp2),y');

          end
          else
          begin

            if (NumAllocElements * 4 > 256) or (NumAllocElements in [0, 1]) then
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda ' + svara + ',y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

              end
              else
              begin

                if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
                  TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
                begin

                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                  asm65(#9'add :STACKORIGIN-1,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');

                end
                else
                begin

                  asm65(#9'lda ' + svar);
                  asm65(#9'add :STACKORIGIN-1,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda ' + svar + '+1');
                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');

                end;

                asm65(#9'ldy #$00');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta (:bp2),y');

              end;

            end
            else
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda ' + svara + ',y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

              end
              else
              begin

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda ' + svara + ',y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda ' + svara + '+1,y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+1,y');
                asm65(#9'lda ' + svara + '+2,y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svara + '+2,y');
                asm65(#9'lda ' + svara + '+3,y');
                asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svara + '+3,y');

              end;

            end;

          end;

      end;
      a65(TCode65.subBX);

    end;

  end;

  a65(TCode65.subBX);
end;  //GenerateIncDec


procedure GenerateAssignment(IndirectionLevel: Byte; Size: Byte; IdentIndex: TIdentIndex;
  Param: String = ''; ParamY: String = '');
var
  NumAllocElements: Cardinal;
  IdentTemp: Integer;
  svar, svara: String;


  procedure LoadRegisterY;
  begin

    if ParamY <> '' then
      asm65(#9'ldy #' + ParamY)
    else
      if pos('.', IdentifierAt(IdentIndex).Name) > 0 then
      begin

        if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and not
          (IdentifierAt(IdentIndex).AllocElementType in [TDataType.UNTYPETOK, TDataType.PROCVARTOK]) then
          asm65(#9'ldy #$00')
        else
          asm65(#9'ldy #' + svar + '-DATAORIGIN');

      end
      else
        asm65(#9'ldy #$00');

  end;

begin

  if IdentIndex > 0 then
  begin

    if IdentifierAt(IdentIndex).DataType = TDatatype.ENUMTOK then
    begin
      Size := GetDataSize(IdentifierAt(IdentIndex).AllocElementType);
      NumAllocElements := 0;
    end
    else
      NumAllocElements := Elements(IdentIndex);

    svar := GetLocalName(IdentIndex);
  end
  else
  begin
    svar := Param;
    NumAllocElements := 0;
  end;

  svara := svar;

  if pos('.', svar) > 0 then
    svara := GetLocalName(IdentIndex, 'adr.')
  else
    svara := 'adr.' + svar;

  asm65separator;

  asm65;
  asm65('; Generate Assignment for' + InfoAboutSize(Size));

  Gen;
  Gen;
  Gen;          // mov :eax, [bx]


  case IndirectionLevel of

    ASPOINTERTOARRAYRECORD:            // array_of_record_pointers[index]
    begin
      asm65('; as Pointer to Array ^Record');


      if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
      begin

        if TestName(IdentIndex, svar) then
        begin

          IdentTemp := GetIdentIndex(ExtractName(IdentIndex, svar));
          if (IdentTemp > 0) and (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) and
            (IdentifierAt(IdentTemp).AllocElementType = TDataType.RECORDTOK) and
            (IdentifierAt(IdentTemp).NumAllocElements_ > 1) and (IdentifierAt(IdentTemp).NumAllocElements_ <= 128) then
          begin

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'add #$00');
            asm65(#9'tay');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'adc #$00');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

            asm65(#9'lda ' + GetLocalName(IdentTemp, 'adr.') + ',y');
            asm65(#9'sta :bp2');
            asm65(#9'lda ' + GetLocalName(IdentTemp, 'adr.') + '+1,y');
            asm65(#9'sta :bp2+1');

          end
          else
          begin
            asm65(#9'lda ' + ExtractName(IdentIndex, svar));
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :TMP');
            asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :TMP+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:TMP),y');
            asm65(#9'sta :bp2');
            asm65(#9'iny');
            asm65(#9'lda (:TMP),y');
            asm65(#9'sta :bp2+1');

          end;

        end
        else
        begin
          asm65(#9'lda ' + svar);
          asm65(#9'add :STACKORIGIN-1,x');
          asm65(#9'sta :TMP');
          asm65(#9'lda ' + svar + '+1');
          asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :TMP+1');

          asm65(#9'ldy #$00');
          asm65(#9'lda (:TMP),y');
          asm65(#9'sta :bp2');
          asm65(#9'iny');
          asm65(#9'lda (:TMP),y');
          asm65(#9'sta :bp2+1');

        end;

      end
      else
      begin

        asm65(#9'ldy :STACKORIGIN-1,x');
        //   asm65(#9'lda adr.' + svar + ',y');
        asm65(#9'lda ' + svara + ',y');
        asm65(#9'sta :bp2');
        //   asm65(#9'lda adr.'+svar+'+1,y');
        asm65(#9'lda ' + svara + '+1,y');
        asm65(#9'sta :bp2+1');

      end;

      LoadRegisterY;

      case Size of
        1: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
        end;

        2: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
        end;

        4: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (:bp2),y');
        end;

      end;

      a65(TCode65.subBX);
      a65(TCode65.subBX);

    end;


    ASPOINTERTODEREFERENCE:
    begin
      asm65('; as Pointer to Dereference');

      asm65(#9'lda :STACKORIGIN-1,x');
      asm65(#9'sta :bp2');
      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
      asm65(#9'sta :bp2+1');

      LoadRegisterY;

      case Size of

        1: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
        end;

        2: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
        end;

        4: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (:bp2),y');
        end;

      end;

      a65(TCode65.subBX);
      a65(TCode65.subBX);

    end;


    ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
      asm65('; as Pointer to Array Origin');

      case Size of
        1: begin                    // PULL BYTE

          if (NumAllocElements > 256) or (NumAllocElements in [0, 1]) then
          begin

            if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <>
              TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('-' + svar);  // -sta

            if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
              TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
            begin

              asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
              asm65(#9'add :STACKORIGIN-1,x');
              asm65(#9'tay');
              asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
              asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'sta :bp+1');
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta (:bp),y');

            end
            else
            begin

              if IdentifierAt(IdentIndex).ObjectVariable and (IdentifierAt(IdentIndex).PassMethod =
                TParameterPassingMethod.VARPASSING) then
              begin

                asm65(#9'mwy ' + svar + ' :TMP');

                asm65(#9'ldy #$00');
                asm65(#9'lda (:TMP),y');
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'sta :bp2');
                asm65(#9'iny');
                asm65(#9'lda (:TMP),y');
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp2+1');
                asm65(#9'ldy #$00');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta (:bp2),y');

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'tay');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp+1');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta (:bp),y');

              end;

            end;

            if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <>
              TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('-');  // -sta

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN-1,x');
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta (:bp2),y');

            end
            else
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svara + ',y');
              // =b'
            end;

          end;

          a65(TCode65.subBX);
          a65(TCode65.subBX);
        end;

        2: begin                    // PULL WORD

          if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
            GenerateIndexShift(TDataType.WORDTOK, 1);

          if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
          begin

            if IdentifierAt(IdentIndex).isStriped then
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svara + ',y');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

            end
            else
            begin

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
                TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'sta :bp2');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp2+1');

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'sta :bp2');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp2+1');

              end;

              asm65(#9'ldy #$00');
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta (:bp2),y');

            end;

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN-1,x');
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta (:bp2),y');

            end
            else
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svara + ',y');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

              if IdentifierAt(IdentIndex).isStriped then
                asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
              else
                asm65(#9'sta ' + svara + '+1,y');
              // w='
            end;

          end;

          a65(TCode65.subBX);
          a65(TCode65.subBX);

        end;

        4: begin                    // PULL CARDINAL

          if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
            GenerateIndexShift(TDataType.CARDINALTOK, 1);

          if (NumAllocElements * 4 > 256) or (NumAllocElements in [0, 1]) then
          begin

            if IdentifierAt(IdentIndex).isStriped then
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svara + ',y');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

            end
            else
            begin

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType =
                TDataType.ARRAYTOK) and (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'sta :bp2');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp2+1');

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'sta :bp2');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp2+1');

              end;

              asm65(#9'ldy #$00');
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta (:bp2),y');

            end;

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN-1,x');
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta (:bp2),y');
              asm65(#9'iny');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta (:bp2),y');

            end
            else
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svara + ',y');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

              end
              else
              begin

                asm65(#9'sta ' + svara + '+1,y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svara + '+2,y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svara + '+3,y');

              end;
              // c='
            end;

          end;

          a65(TCode65.subBX);
          a65(TCode65.subBX);

        end;
      end;
    end;


    ASSTRINGPOINTER1TOARRAYORIGIN:
    begin
      asm65('; as StringPointer to Array Origin');

      case Size of

        2: begin

          if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
          begin

            asm65(#9'lda ' + svar);
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda ' + svar + '+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:bp2),y');
            asm65(#9'pha');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :bp2+1');
            asm65(#9'pla');
            asm65(#9'sta :bp2');

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN-1,x');
              asm65(#9'lda (:bp2),y');
              asm65(#9'pha');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :bp2+1');
              asm65(#9'pla');
              asm65(#9'sta :bp2');

            end
            else
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta :bp2');
              asm65(#9'lda ' + svara + '+1,y');
              asm65(#9'sta :bp2+1');

            end;

          end;

          asm65(#9'ldy #$00');
          asm65(#9'lda #$01');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');

          a65(TCode65.subBX);
          a65(TCode65.subBX);

        end;
      end;
    end;


    ASSTRINGPOINTERTOARRAYORIGIN:
    begin
      asm65('; as StringPointer to Array Origin');

      case Size of

        2: begin

          if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
          begin

            asm65(#9'lda ' + svar);
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda ' + svar + '+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta @move.dst');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta @move.dst+1');

          end
          else
          begin

            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            begin

              LoadBP2(IdentIndex, svar);

              asm65(#9'ldy :STACKORIGIN-1,x');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta @move.dst');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta @move.dst+1');

            end
            else
            begin

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'lda ' + svara + ',y');
              asm65(#9'sta @move.dst');
              asm65(#9'lda ' + svara + '+1,y');
              asm65(#9'sta @move.dst+1');

            end;

          end;

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta @move.src');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta @move.src+1');

          if IdentifierAt(IdentIndex).NestedNumAllocElements > 0 then
          begin

            asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NestedNumAllocElements));
            asm65(#9'sta @move.cnt');
            asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NestedNumAllocElements));
            asm65(#9'sta @move.cnt+1');

            asm65(#9'jsr @move');

            if IdentifierAt(IdentIndex).NestedNumAllocElements < 256 then
            begin
              asm65(#9'ldy #$00');
              asm65(#9'lda #' + IntToStr(IdentifierAt(IdentIndex).NestedNumAllocElements - 1));
              asm65(#9'cmp (@move.src),y');
              asm65(#9'scs');
              asm65(#9'sta (@move.dst),y');
            end;

          end
          else
          begin

            asm65(#9'ldy #$00');
            asm65(#9'lda (@move.src),y');
            asm65(#9'add #1');
            asm65(#9'sta @move.cnt');
            asm65(#9'scc');
            asm65(#9'iny');
            asm65(#9'sty @move.cnt+1');

            asm65(#9'jsr @move');

          end;

          a65(TCode65.subBX);
          a65(TCode65.subBX);

        end;
      end;
    end;


    ASPOINTERTOARRAYRECORDTOSTRING:                  // array_of_pointer_to_record[index].string
    begin

      Gen;

      asm65(#9'lda :STACKORIGIN-1,x');

      if TestName(IdentIndex, svar) then
      begin
        asm65(#9'add ' + ExtractName(IdentIndex, svar));
        asm65(#9'sta :bp2');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
        asm65(#9'sta :bp2+1');
      end
      else
      begin
        asm65(#9'add ' + svar);
        asm65(#9'sta :bp2');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'adc ' + svar + '+1');
        asm65(#9'sta :bp2+1');
      end;

      asm65(#9'ldy #$00');
      asm65(#9'lda (:bp2),y');

      if TestName(IdentIndex, svar) then
        asm65(#9'add #' + svar + '-DATAORIGIN')
      else
        asm65(#9'add #' + paramY);

      asm65(#9'sta @move.dst');

      asm65(#9'iny');
      asm65(#9'lda (:bp2),y');
      asm65(#9'adc #$00');
      asm65(#9'sta @move.dst+1');

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @move.src');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @move.src+1');

      asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements));
      asm65(#9'sta @move.cnt');
      asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements));
      asm65(#9'sta @move.cnt+1');

      asm65(#9'jsr @move');

      a65(TCode65.subBX);
      a65(TCode65.subBX);

    end;


    ASPOINTERTORECORDARRAYORIGIN:            // record^.array[i]
    begin
      asm65('; as Pointer to Record^ Array Origin');
      asm65;

      Gen;

      if TestName(IdentIndex, svar) then
        asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2')
      else
        asm65(#9'mwy ' + svar + ' :bp2');

      asm65(#9'lda :STACKORIGIN-1,x');

      if TestName(IdentIndex, svar) then
        asm65(#9'add #' + svar + '-DATAORIGIN')
      else
        asm65(#9'add #' + ParamY);

      asm65(#9'sta :STACKORIGIN-1,x');

      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
      asm65(#9'adc #$00');
      asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

      asm65(#9'ldy :STACKORIGIN-1,x');

      case Size of
        1: begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');

        end;

        2: begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');

        end;

        4: begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (:bp2),y');

        end;

      end;

      a65(TCode65.subBX);
      a65(TCode65.subBX);

    end;


    ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN:        // record_array[index].array[i]
    begin

      asm65(#9'dex');              // maksymalnie mozemy uzyc :STACKORIGIN-1 lub :STACKORIGIN+1, pomagamy przez DEX/INX

      if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
      begin

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'lda ' + ExtractName(IdentIndex, svar));
          asm65(#9'add :STACKORIGIN-1,x');
          asm65(#9'sta :TMP');
          asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
          asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :TMP+1');
        end
        else
        begin
          asm65(#9'lda ' + svar);
          asm65(#9'add :STACKORIGIN-1,x');
          asm65(#9'sta :TMP');
          asm65(#9'lda ' + svar + '+1');
          asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :TMP+1');
        end;

        asm65(#9'ldy #$00');
        asm65(#9'lda (:TMP),y');
        asm65(#9'sta :bp2');
        asm65(#9'iny');
        asm65(#9'lda (:TMP),y');
        asm65(#9'sta :bp2+1');

      end
      else
      begin
        asm65(#9'ldy :STACKORIGIN-1,x');
        //   asm65(#9'lda adr.' + svar + ',y');
        asm65(#9'lda ' + svara + ',y');
        asm65(#9'sta :bp2');
        //   asm65(#9'lda adr.' + svar + '+1,y');
        asm65(#9'lda ' + svara + '+1,y');
        asm65(#9'sta :bp2+1');
      end;

      asm65(#9'inx');

      asm65(#9'lda :STACKORIGIN-1,x');
      asm65(#9'add #' + ParamY);
      asm65(#9'sta :STACKORIGIN-1,x');
      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
      asm65(#9'adc #$00');
      asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

      asm65(#9'ldy :STACKORIGIN-1,x');

      case Size of
        1: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
        end;

        2: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
        end;

        4: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (:bp2),y');
        end;

      end;

      a65(TCode65.subBX);
      a65(TCode65.subBX);
      a65(TCode65.subBX);

    end;


    ASPOINTERTOPOINTER:
    begin
      asm65('; as Pointer to Pointer');

      if (IdentIndex > 0) and (IdentifierAt(IdentIndex).isAbsolute) and
        (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then
        asm65('-' + svar);  // -sta

      //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,' / ',svar ,' / ', UnitArray[IdentifierAt(IdentIndex).UnitIndex].Name,',',svar.LastIndexOf('.'));

      if TestName(IdentIndex, svar) then
      begin

        if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and not
          (IdentifierAt(IdentIndex).AllocElementType in [TDataType.UNTYPETOK, TDataType.PROCVARTOK]) then
          asm65(#9'mwy ' + svar + ' :bp2')
        else
          asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

      end
      else
        asm65(#9'mwy ' + svar + ' :bp2');


      LoadRegisterY;

      case Size of
        1: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
        end;

        2: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
        end;

        4: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (:bp2),y');
          asm65(#9'iny');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (:bp2),y');
        end;

      end;

      if (IdentIndex > 0) and (IdentifierAt(IdentIndex).isAbsolute) and
        (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then
        asm65('-');  // -sta

      a65(TCode65.subBX);

    end;


    ASPOINTER:
    begin
      asm65('; as Pointer');

      case Size of
        1: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta ' + svar);
        end;

        2: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta ' + svar);
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta ' + svar + '+1');
        end;

        4: begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta ' + svar);
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta ' + svar + '+1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta ' + svar + '+2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta ' + svar + '+3');
        end;
      end;

      a65(TCode65.subBX);

    end;

  end;// case

  StopOptimization;

end;  //GenerateAssignment


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateReturn(IsFunction, isInt, isInl, isOvr: Boolean);
var
  yes: Boolean;
begin
  Gen;            // ret

  yes := True;

  if not isInt then        // not Interrupt
    if not IsFunction then
    begin
      asm65('@exit');

      if not isInl then
      begin
        asm65(#9'.ifdef @new');      // @FreeMem
        asm65(#9'lda <@VarData');
        asm65(#9'sta :ztmp');
        asm65(#9'lda >@VarData');
        asm65(#9'ldy #@VarDataSize-1');
        asm65(#9'jmp @FreeMem');
        asm65(#9'els');
        asm65(#9'rts', '; ret');
        asm65(#9'eif');
      end;

      yes := False;
    end;

  if yes and (isInl = False) then
    if isInt then
      asm65(#9'rti', '; ret')
    else
      asm65(#9'rts', '; ret');

  asm65('.endl');

  if isOvr then
  begin
    asm65('.endl', '; overload');
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIfThenCondition;
begin
  //asm65;
  //asm65('; If Then Condition');

  Gen;
  Gen;
  Gen;                // mov :eax, [bx]

  a65(TCode65.subBX);

  asm65(#9'lda :STACKORIGIN+1,x');
  asm65(#9'bne *+5');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateElseCondition;
begin
  //asm65;
  //asm65('; else condition');

  Gen;
  Gen;
  Gen;                // mov :eax, [bx]

  asm65(#9'beq *+5');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


{$IFDEF WHILEDO}

procedure GenerateWhileDoCondition;
begin

 GenerateIfThenCondition;

end;

{$ENDIF}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRepeatUntilCondition;
begin

  GenerateIfThenCondition;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelationOperation(relation: TTokenKind; ValType: TDataType);
begin

  case relation of
    TTokenKind.EQTOK:
    begin
      Gen;
      Gen;                // je +3   =

      asm65(#9'beq @+');
    end;

    TTokenKind.NETOK, TTokenKind.UNTYPETOK:
    begin
      Gen;
      Gen;                // jne +3  <>

      asm65(#9'bne @+');
    end;

    TTokenKind.GTTOK:
    begin
      Gen;
      Gen;                // jg +3   >

      asm65(#9'seq');

      if ValType in (RealTypes + SignedOrdinalTypes) then
        asm65(#9'bpl @+')
      else
        asm65(#9'bcs @+');

    end;

    TTokenKind.GETOK:
    begin
      Gen;
      Gen;                // jge +3  >=

      if ValType in (RealTypes + SignedOrdinalTypes) then
        asm65(#9'bpl @+')
      else
        asm65(#9'bcs @+');

    end;

    TTokenKind.LTTOK:
    begin
      Gen;
      Gen;                // jl +3   <

      if ValType in (RealTypes + SignedOrdinalTypes) then
        asm65(#9'bmi @+')
      else
        asm65(#9'bcc @+');

    end;

    TTokenKind.LETOK:
    begin
      Gen;
      Gen;                // jle +3  <=

      if ValType in (RealTypes + SignedOrdinalTypes) then
      begin
        asm65(#9'bmi @+');
        asm65(#9'beq @+');
      end
      else
      begin
        asm65(#9'bcc @+');
        asm65(#9'beq @+');
      end;

    end;

  end;  // case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateForToDoCondition(ValType: TDataType; Down: Boolean; IdentIndex: TIdentIndex);
var
  svar: String;
  CounterSize: Byte;
begin

  svar := GetLocalName(IdentIndex);
  CounterSize := GetDataSize(ValType);

  asm65(';' + InfoAboutSize(CounterSize));

  Gen;
  Gen;
  Gen;            // mov :ecx, [bx]

  a65(TCode65.subBX);

  case CounterSize of

    1: begin
      ExpandByte;

      if ValType = TDataType.SHORTINTTOK then
      begin    // @cmpFor_SHORTINT

        asm65(#9'lda ' + svar);
        asm65(#9'sub :STACKORIGIN+1,x');
        asm65(#9'svc');
        asm65(#9'eor #$80');

      end
      else
      begin

        asm65(#9'lda ' + svar);
        asm65(#9'cmp :STACKORIGIN+1,x');

      end;

    end;

    2: begin
      ExpandWord;

      if ValType = TDataType.SMALLINTTOK then
      begin    // @cmpFor_SMALLINT

        asm65(#9'.LOCAL');
        asm65(#9'lda ' + svar + '+1');
        asm65(#9'sub :STACKORIGIN+1+STACKWIDTH,x');
        asm65(#9'bne L4');
        asm65(#9'lda ' + svar);
        asm65(#9'cmp :STACKORIGIN+1,x');
        asm65('L1'#9'beq L5');
        asm65(#9'bcs L3');
        asm65(#9'lda #$FF');
        asm65(#9'bne L5');
        asm65('L3'#9'lda #$01');
        asm65(#9'bne L5');
        asm65('L4'#9'bvc L5');
        asm65(#9'eor #$FF');
        asm65(#9'ora #$01');
        asm65('L5');
        asm65(#9'.ENDL');

      end
      else
      begin

        asm65(#9'lda ' + svar + '+1');
        asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
        asm65(#9'bne @+');
        asm65(#9'lda ' + svar);
        asm65(#9'cmp :STACKORIGIN+1,x');
        asm65('@');

      end;

    end;

    4: begin

      if ValType = TDataType.INTEGERTOK then
      begin      // @cmpFor_INT

        asm65(#9'.LOCAL');
        asm65(#9'lda ' + svar + '+3');
        asm65(#9'sub :STACKORIGIN+1+STACKWIDTH*3,x');
        asm65(#9'bne L4');
        asm65(#9'lda ' + svar + '+2');
        asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
        asm65(#9'bne L1');
        asm65(#9'lda ' + svar + '+1');
        asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
        asm65(#9'bne L1');
        asm65(#9'lda ' + svar);
        asm65(#9'cmp :STACKORIGIN+1,x');
        asm65('L1'#9'beq L5');
        asm65(#9'bcs L3');
        asm65(#9'lda #$FF');
        asm65(#9'bne L5');
        asm65('L3'#9'lda #$01');
        asm65(#9'bne L5');
        asm65('L4'#9'bvc L5');
        asm65(#9'eor #$FF');
        asm65(#9'ora #$01');
        asm65('L5');
        asm65(#9'.ENDL');

      end
      else
      begin

        asm65(#9'lda ' + svar + '+3');
        asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*3,x');
        asm65(#9'bne @+');
        asm65(#9'lda ' + svar + '+2');
        asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
        asm65(#9'bne @+');
        asm65(#9'lda ' + svar + '+1');
        asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
        asm65(#9'bne @+');
        asm65(#9'lda ' + svar);
        asm65(#9'cmp :STACKORIGIN+1,x');
        asm65('@');

      end;

    end;

  end;


  Gen;
  Gen;
  Gen;              // cmp :eax, :ecx

  if Down then
  begin

    if ValType in [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK] then
      asm65(#9'bpl *+5')
    else
      asm65(#9'bcs *+5');

  end

  else
  begin

    if ValType in [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK] then
    begin
      asm65(#9'bmi *+7');
      asm65(#9'beq *+5');
    end
    else
    begin
      asm65(#9'bcc *+7');
      asm65(#9'beq *+5');
    end;

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIfThenProlog;
begin

  Inc(CodePosStackTop);

  CodePosStack[CodePosStackTop] := CodeSize;

  Gen;                // nop   ; jump to the IF..THEN block end will be inserted here
  Gen;                // nop   ; !!!
  Gen;                // nop   ; !!!

  asm65(#9'jmp l_' + IntToHex(CodeSize, 4));

end;


procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: TDataType; Join: Boolean; CaseLocalCnt: Integer);
begin
  Gen;
  Gen;              // cmp :ecx, Value

  case GetDataSize(SelectorType) of

    1: if join = False then
      begin
        asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

        if Value <> 0 then asm65(#9'cmp #$' + IntToHex(Byte(Value), 2));
      end
      else
        asm65(#9'cmp #$' + IntToHex(Byte(Value), 2));

    // 2: asm65(#9'cpw :STACKORIGIN,x #$'+IntToHex(Value, 4));
    // 4: asm65(#9'cpd :STACKORIGIN,x #$'+IntToHex(Value, 4));
  end;

  asm65(#9'beq @+');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: TDataType; Join: Boolean;
  CaseLocalCnt: Integer);
begin

  Gen;
  Gen;              // cmp :ecx, Value1

  if (SelectorType in [TDataType.BYTETOK, TDataType.CHARTOK, TDataType.ENUMTOK]) and
    (Value1 >= 0) and (Value2 >= 0) then
  begin

    if (Value1 = 0) and (Value2 = 255) then
    begin

      asm65(#9'jmp @+');
    end
    else
      if Value1 = 0 then
      begin

        if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

        if Value2 = 127 then
        begin
          asm65(#9'cmp #$00');
          asm65(#9'bpl @+');
        end
        else
        begin
          asm65(#9'cmp #$' + IntToHex(Value2 + 1, 2));
          asm65(#9'bcc @+');
        end;

      end
      else
        if Value2 = 255 then
        begin

          if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

          if Value1 = 128 then
          begin
            asm65(#9'cmp #$00');
            asm65(#9'bmi @+');
          end
          else
          begin
            asm65(#9'cmp #$' + IntToHex(Value1, 2));
            asm65(#9'bcs @+');
          end;

        end
        else
          if Value1 = Value2 then
          begin

            if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

            asm65(#9'cmp #$' + IntToHex(Value1, 2));
            asm65(#9'beq @+');
          end
          else
          begin

            if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

            asm65(#9'clc', '; clear carry for add');
            asm65(#9'adc #$FF-$' + IntToHex(Value2, 2), '; make m = $FF');
            asm65(#9'adc #$' + IntToHex(Value2, 2) + '-$' + IntToHex(Value1, 2) + '+1',
              '; carry set if in range n to m');
            asm65(#9'bcs @+');
          end;

  end
  else
  begin

    case GetDataSize(SelectorType) of
      1: begin
        if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

        asm65(#9'cmp #' + IntToStr(Byte(Value1)));
      end;

    end;

    GenerateRelationOperation(TTokenKind.LTTOK, SelectorType);

    case GetDataSize(SelectorType) of
      1: begin
        //       asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

        asm65(#9'cmp #' + IntToStr(Byte(Value2)));
      end;

    end;

    GenerateRelationOperation(TTokenKind.GTTOK, SelectorType);

    asm65(#9'jmp *+6');
    asm65('@');

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseStatementProlog;
begin

  GenerateIfThenProlog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseStatementEpilog(cnt: Integer);
var
  StoredCodeSize: Integer;
begin

  resetOpty;

  asm65(#9'jmp a_' + IntToHex(cnt, 4));

  asm65('s_' + IntToHex(CodeSize, 4));        // opt_TEMP_TAIL_CASE


  StoredCodeSize := CodeSize;

  Gen;                // nop   ; jump to the CASE block end will be inserted here
  // Gen;                // nop
  // Gen;                // nop

  asm65('l_' + IntToHex(CodePosStack[CodePosStackTop] + 3, 4));

  Gen;

  CodePosStack[CodePosStackTop] := StoredCodeSize;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseEpilog(NumCaseStatements: Integer; cnt: Integer);
begin

  resetOpty;

  //asm65;
  //asm65('; GenerateCaseEpilog');

  Dec(CodePosStackTop, NumCaseStatements);

  if not OutputDisabled then Inc(CodeSize, NumCaseStatements);

  asm65('a_' + IntToHex(cnt, 4));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateAsmLabels(l: Integer);
//var i: integer;
begin

  if not OutputDisabled then
    if Pass = TPass.CODE_GENERATION then
    begin
{
   for i in AsmLabels do
     if i = l then exit;

   i := High(AsmLabels);

   AsmLabels[i] := l;

   SetLength(AsmLabels, i+2);
}
      asm65('l_' + IntToHex(l, 4));

    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIfThenEpilog;
var
  CodePos: Word;
begin

  ResetOpty;

  // asm65(#13#10'; IfThenEpilog');

  CodePos := CodePosStack[CodePosStackTop];
  Dec(CodePosStackTop);

  GenerateAsmLabels(CodePos + 3);

end;


procedure GenerateWhileDoProlog;
begin

  GenerateIfThenProlog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateWhileDoEpilog;
var
  CodePos, ReturnPos: Word;
begin
  //asm65(#13#10'; WhileDoEpilog');

  CodePos := CodePosStack[CodePosStackTop];
  Dec(CodePosStackTop);

  ReturnPos := CodePosStack[CodePosStackTop];
  Dec(CodePosStackTop);

  Gen;                // jmp ReturnPos

  asm65(#9'jmp l_' + IntToHex(ReturnPos, 4));

  GenerateAsmLabels(CodePos + 3);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRepeatUntilProlog;
begin

  Inc(CodePosStackTop);
  CodePosStack[CodePosStackTop] := CodeSize;

  GenerateAsmLabels(CodeSize);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRepeatUntilEpilog;
var
  ReturnPos: Word;
begin

  ResetOpty;

  ReturnPos := CodePosStack[CodePosStackTop];
  Dec(CodePosStackTop);

  Gen;

  asm65(#9'jmp l_' + IntToHex(ReturnPos, 4));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateForToDoProlog;
begin

  GenerateWhileDoProlog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateForToDoEpilog(ValType: TDataType; Down: Boolean; IdentIndex: TIdentIndex = 0;
  Epilog: Boolean = True; forBPL: Byte = 0);
var
  svar: String;
  CounterSize: Byte;
begin

  svar := GetLocalName(IdentIndex);
  CounterSize := GetDataSize(ValType);

  case CounterSize of
    1: begin
      Gen;            // ... byte ptr ...
    end;
    2: begin
      Gen;            // ... word ptr ...
    end;
    4: begin
      Gen;
      Gen;            // ... dword ptr ...
    end;
  end;

  if Down then
  begin
    Gen;               // dec ...

    case CounterSize of
      1: asm65(#9'dec ' + svar);

      2: begin
        asm65(#9'lda ' + svar);
        asm65(#9'bne @+');

        asm65(#9'dec ' + svar + '+1');
        asm65('@');
        asm65(#9'dec ' + svar);
      end;

      4: begin
        asm65(#9'lda ' + svar);
        asm65(#9'bne @+1');

        asm65(#9'lda ' + svar + '+1');
        asm65(#9'bne @+');

        asm65(#9'lda ' + svar + '+2');
        asm65(#9'sne');
        asm65(#9'dec ' + svar + '+3');
        asm65(#9'dec ' + svar + '+2');
        asm65('@');
        asm65(#9'dec ' + svar + '+1');
        asm65('@');
        asm65(#9'dec ' + svar);
      end;

    end;

  end
  else
  begin
    Gen;              // inc ...

    case CounterSize of
      1: asm65(#9'inc ' + svar);

      2: begin
        asm65(#9'inc ' + svar);        // dla optymalizacji z 'JMP L_xxxx'
        asm65(#9'sne');
        asm65(#9'inc ' + svar + '+1');
      end;

      4: begin
        asm65(#9'inc ' + svar);
        asm65(#9'bne @+');
        asm65(#9'inc ' + svar + '+1');
        asm65(#9'bne @+');
        asm65(#9'inc ' + svar + '+2');
        asm65(#9'bne @+');
        asm65(#9'inc ' + svar + '+3');
        asm65('@');
      end;

    end;

  end;

  Gen;
  Gen;            // ... [CounterAddress]

  if Epilog then
  begin

    if ValType in [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK] then
    begin

      case CounterSize of
        1: begin

          if Down then
          begin
            asm65(#9'lda ' + svar);
            asm65(#9'cmp #$7f');
            asm65(#9'seq');
          end
          else
          begin
            asm65(#9'lda ' + svar);
            asm65(#9'cmp #$80');
            asm65(#9'seq');
          end;

        end;
{
   2: begin
      end;

   4: begin
      end;
}

      end;

    end
    else
      if Down then
      begin          // for label = exp to max(type)

        case CounterSize of

          1: if forBPL and 1 <> 0 then    // [BYTE < 128] DOWNTO 0
              asm65(#9'bmi *+5')
            else
              if forBPL and 2 <> 0 then    // BYTE DOWNTO [exp > 0]
                asm65(#9'seq')
              else
              begin
                asm65(#9'lda ' + svar);
                asm65(#9'cmp #$FF');
                asm65(#9'seq');
              end;

          2: begin
            asm65(#9'lda ' + svar + '+1');
            asm65(#9'cmp #$FF');
            asm65(#9'seq');
          end;

          4: begin
            asm65(#9'lda ' + svar + '+3');
            asm65(#9'cmp #$FF');
            asm65(#9'seq');
          end;
        end;

      end
      else
      begin

        asm65(#9'seq');

      end;

    GenerateWhileDoEpilog;
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompilerTitle: String;
begin

  Result := 'Mad Pascal Compiler version ' + title + ' [' + {$I %DATE%} + '] for MOS 6502 CPU';

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


{$i targets/generate_program_prolog.inc}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateProgramEpilog(ExitCode: Byte);
begin

  Gen;
  Gen;              // mov ah, 4Ch

  asm65(#9'lda #$' + IntToHex(ExitCode, 2));
  asm65(#9'jmp @halt');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateDeclarationProlog;
begin
  Inc(CodePosStackTop);
  CodePosStack[CodePosStackTop] := CodeSize;

  Gen;                // nop   ; jump to the IF..THEN block end will be inserted here
  Gen;                // nop   ; !!!
  Gen;                // nop   ; !!!

  asm65(#9'jmp l_' + IntToHex(CodeSize, 4));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateDeclarationEpilog;
begin

  GenerateIfThenEpilog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRead;//(Value: Int64);
begin
  // Gen; Gen;              // mov bp, [bx]

  asm65(#9'@getline');

end;  // GenerateRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateWriteString(Address: Word; IndirectionLevel: Byte; ValueType: TDataType = TDataType.INTEGERTOK);
begin
  //Gen; Gen;              // mov ah, 09h

  asm65;

  case IndirectionLevel of

    ASBOOLEAN_:
    begin
      asm65(#9'jsr @printBOOLEAN');

      a65(TCode65.subBX);
    end;

    ASCHAR:
    begin
      asm65(#9'@printCHAR');

      a65(TCode65.subBX);
    end;

    ASSHORTREAL:
    begin
      asm65(#9'jsr @printSHORTREAL');

      a65(TCode65.subBX);
    end;

    ASREAL:
    begin
      asm65(#9'jsr @printREAL');

      a65(TCode65.subBX);
    end;

    ASSINGLE:
    begin
      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @FTOA.I');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @FTOA.I+1');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
      asm65(#9'sta @FTOA.I+2');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
      asm65(#9'sta @FTOA.I+3');

      a65(TCode65.subBX);

      asm65(#9'jsr @FTOA');
    end;

    ASHALFSINGLE:
    begin
      //     asm65(#9'jsr @f16toa');

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @F16_F2A.I');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @F16_F2A.I+1');

      a65(TCode65.subBX);

      asm65(#9'jsr @F16_F2A');
    end;


    ASVALUE:
    begin

      case GetDataSize(ValueType) of
        1: if ValueType = TDataType.SHORTINTTOK then
            asm65(#9'jsr @printSHORTINT')
          else
            asm65(#9'jsr @printBYTE');

        2: if ValueType = TDataType.SMALLINTTOK then
            asm65(#9'jsr @printSMALLINT')
          else
            asm65(#9'jsr @printWORD');

        4: if ValueType = TDataType.INTEGERTOK then
            asm65(#9'jsr @printINT')
          else
            asm65(#9'jsr @printCARD');
      end;

      a65(TCode65.subBX);
    end;

    ASPOINTER:
    begin

      asm65(#9'@printSTRING #CODEORIGIN+$' + IntToHex(Address - CODEORIGIN, 4));

      //    a65(TCode65.subBX);   !!!   bez DEX-a
    end;

    ASPOINTERTOPOINTER:
    begin

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'jsr @printSTRING');

      a65(TCode65.subBX);
    end;


    ASPCHAR:
    begin

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'jsr @printPCHAR');

      a65(TCode65.subBX);
    end;

  end;

end;  //GenerateWriteString


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateUnaryOperation(op: TTokenKind; ValType: TDataType = TDataType.UNTYPETOK);
begin

  case op of

    TTokenKind.PLUSTOK:
    begin
    end;

    TTokenKind.MINUSTOK:
    begin
      Gen;
      Gen;
      Gen;            // neg dword ptr [bx]

      if ValType = TDataType.HALFSINGLETOK then
      begin

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta :STACKORIGIN,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'eor #$80');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

      end
      else
        if ValType = TDataType.SINGLETOK then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'eor #$80');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

        end
        else

          case GetDataSize(ValType) of
            1: begin //asm65(#9'jsr negBYTE');

              asm65(#9'lda #$00');
              asm65(#9'sub :STACKORIGIN,x');
              asm65(#9'sta :STACKORIGIN,x');

              asm65(#9'lda #$00');
              asm65(#9'sbc #$00');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc #$00');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc #$00');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            end;

            2: begin //asm65(#9'jsr negWORD');

              asm65(#9'lda #$00');
              asm65(#9'sub :STACKORIGIN,x');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

              asm65(#9'lda #$00');
              asm65(#9'sbc #$00');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc #$00');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            end;

            4: begin //asm65(#9'jsr negCARD');

              asm65(#9'lda #$00');
              asm65(#9'sub :STACKORIGIN,x');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda #$00');
              asm65(#9'sbc :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            end;

          end;

    end;

    TTokenKind.NOTTOK:
    begin
      Gen;
      Gen;
      Gen;            // not dword ptr [bx]

      if ValType = TDataType.BOOLEANTOK then
      begin
        //     a65(TCode65.notBOOLEAN)

        asm65(#9'ldy #1');          // !!! wymagana konwencja
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'beq @+');
        asm65(#9'dey');
        asm65('@');
        //       asm65(#9'tya');    !!! ~
        asm65(#9'sty :STACKORIGIN,x');

      end
      else
      begin

        ExpandParam(TDataType.INTEGERTOK, ValType);

        //     a65(TCode65.notaBX);

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'eor #$FF');
        asm65(#9'sta :STACKORIGIN,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'eor #$FF');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'eor #$FF');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'eor #$FF');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

      end;

    end;

  end;// case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateBinaryOperation(op: TTokenKind; ResultType: TDataType);
begin

  // asm65;
  // asm65('; Generate Binary Operation for ' + InfoAboutToken(ResultType));

  Gen;
  Gen;
  Gen;              // mov :ecx, [bx]      :STACKORIGIN,x

  case op of

    TTokenKind.PLUSTOK:
    begin

      if ResultType = TDataType.HALFSINGLETOK then
      begin

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_ADD.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_ADD.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_ADD.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_ADD.A+1');

        asm65(#9'jsr @F16_ADD');

        asm65(#9'lda :eax');
        asm65(#9'sta :STACKORIGIN-1,x');
        asm65(#9'lda :eax+1');
        asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

      end
      else
        if ResultType = TDataType.SINGLETOK then
        begin
          //       asm65(#9'jsr @FADD')

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :FP2MAN0');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :FP2MAN1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :FP2MAN2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :FP2MAN3');

          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'sta :FP1MAN0');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :FP1MAN1');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'sta :FP1MAN2');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
          asm65(#9'sta :FP1MAN3');

          asm65(#9'jsr @FADD');

          asm65(#9'lda :FPMAN0');
          asm65(#9'sta :STACKORIGIN-1,x');
          asm65(#9'lda :FPMAN1');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'lda :FPMAN2');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'lda :FPMAN3');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

        end
        else

          case GetDataSize(ResultType) of
            1: a65(TCode65.addAL_CL);
            2: a65(TCode65.addAX_CX);
            4: a65(TCode65.addEAX_ECX);
          end;

    end;

    TTokenKind.MINUSTOK:
    begin

      if ResultType = TDataType.HALFSINGLETOK then
      begin

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_SUB.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_SUB.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_SUB.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_SUB.A+1');

        asm65(#9'jsr @F16_SUB');

        asm65(#9'lda :eax');
        asm65(#9'sta :STACKORIGIN-1,x');
        asm65(#9'lda :eax+1');
        asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

      end
      else
        if ResultType = TDataType.SINGLETOK then
        begin
          //      asm65(#9'jsr @FSUB')

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :FP2MAN0');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :FP2MAN1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :FP2MAN2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :FP2MAN3');

          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'sta :FP1MAN0');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta :FP1MAN1');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'sta :FP1MAN2');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
          asm65(#9'sta :FP1MAN3');

          asm65(#9'jsr @FSUB');

          asm65(#9'lda :FPMAN0');
          asm65(#9'sta :STACKORIGIN-1,x');
          asm65(#9'lda :FPMAN1');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'lda :FPMAN2');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'lda :FPMAN3');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

        end
        else

          case GetDataSize(ResultType) of
            1: a65(TCode65.subAL_CL);
            2: a65(TCode65.subAX_CX);
            4: a65(TCode65.subEAX_ECX);
          end;

    end;

    TTokenKind.MULTOK:
    begin

      if ResultType in RealTypes then
      begin    // Real multiplication

        case ResultType of

          TDataType.SHORTREALTOK:        // Q8.8 fixed-point
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @SHORTREAL_MUL.B');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @SHORTREAL_MUL.B+1');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta @SHORTREAL_MUL.A');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta @SHORTREAL_MUL.A+1');

            asm65(#9'jsr @SHORTREAL_MUL');

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          end;

          TDataType.REALTOK:        // Q24.8 fixed-point
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @REAL_MUL.B');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @REAL_MUL.B+1');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta @REAL_MUL.B+2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta @REAL_MUL.B+3');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta @REAL_MUL.A');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta @REAL_MUL.A+1');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'sta @REAL_MUL.A+2');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
            asm65(#9'sta @REAL_MUL.A+3');

            asm65(#9'jsr @REAL_MUL');

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'lda :eax+2');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'lda :eax+3');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

          end;

          TDataType.SINGLETOK: //asm65(#9'jsr @FMUL');       // IEEE-754, 32-bit
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :FP2MAN0');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :FP2MAN1');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta :FP2MAN2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta :FP2MAN3');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta :FP1MAN0');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :FP1MAN1');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'sta :FP1MAN2');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
            asm65(#9'sta :FP1MAN3');

            asm65(#9'jsr @FMUL');

            asm65(#9'lda :FPMAN0');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :FPMAN1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'lda :FPMAN2');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'lda :FPMAN3');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

          end;

          TDataType.HALFSINGLETOK:          // IEEE-754, 16-bit
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @F16_MUL.B');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @F16_MUL.B+1');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta @F16_MUL.A');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta @F16_MUL.A+1');

            asm65(#9'jsr @F16_MUL');

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          end;

        end;

      end
      else
      begin          // Integer multiplication

        if ResultType in SignedOrdinalTypes then
        begin

          case ResultType of
            TDataType.SHORTINTTOK: asm65(#9'jsr mulSHORTINT');
            TDataType.SMALLINTTOK: asm65(#9'jsr mulSMALLINT');
            TDataType.INTEGERTOK: asm65(#9'jsr mulINTEGER');
          end;

        end
        else
        begin

          case GetDataSize(ResultType) of
            1: asm65(#9'jsr imulBYTE');
            2: asm65(#9'jsr imulWORD');
            4: asm65(#9'jsr imulCARD');
          end;

          //       asm65(#9'jsr movaBX_EAX');

          if GetDataSize(ResultType) = 1 then
          begin

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          end
          else
          begin

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'lda :eax+2');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'lda :eax+3');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

          end;

        end;

      end;

    end;

    TTokenKind.DIVTOK, TTokenKind.IDIVTOK, TTokenKind.MODTOK:
    begin

      if ResultType in RealTypes then
      begin    // Real division

        case ResultType of
          TDataType.SHORTREALTOK:          // Q8.8 fixed-point
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @SHORTREAL_DIV.B');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @SHORTREAL_DIV.B+1');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta @SHORTREAL_DIV.A');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta @SHORTREAL_DIV.A+1');

            asm65(#9'jsr @SHORTREAL_DIV');

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          end;

          TDataType.REALTOK:          // Q24.8 fixed-point
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @REAL_DIV.B');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @REAL_DIV.B+1');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta @REAL_DIV.B+2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta @REAL_DIV.B+3');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta @REAL_DIV.A');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta @REAL_DIV.A+1');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'sta @REAL_DIV.A+2');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
            asm65(#9'sta @REAL_DIV.A+3');

            asm65(#9'jsr @REAL_DIV');

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'lda :eax+2');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'lda :eax+3');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

          end;

          TDataType.SINGLETOK:          // IEEE-754, 32-bit
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :FP2MAN0');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :FP2MAN1');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta :FP2MAN2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta :FP2MAN3');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta :FP1MAN0');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :FP1MAN1');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'sta :FP1MAN2');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
            asm65(#9'sta :FP1MAN3');

            asm65(#9'jsr @FDIV');

            asm65(#9'lda :FPMAN0');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :FPMAN1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'lda :FPMAN2');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
            asm65(#9'lda :FPMAN3');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

          end;

          TDataType.HALFSINGLETOK:          // IEEE-754, 16-bit
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @F16_DIV.B');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @F16_DIV.B+1');

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'sta @F16_DIV.A');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta @F16_DIV.A+1');

            asm65(#9'jsr @F16_DIV');

            asm65(#9'lda :eax');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :eax+1');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          end;
        end;

      end

      else            // Integer division
      begin

        if ResultType in SignedOrdinalTypes then
        begin

          case ResultType of

            TDataType.SHORTINTTOK:
              if op = TTokenKind.MODTOK then
              begin
                //            asm65(#9'jsr SHORTINTTOK.MOD')

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @SHORTINT.MOD.B');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @SHORTINT.MOD.A');

                asm65(#9'jsr @SHORTINT.MOD');

                asm65(#9'lda @SHORTINT.MOD.RESULT');
                asm65(#9'sta :STACKORIGIN-1,x');

              end
              else
              begin
                //            asm65(#9'jsr @SHORTINTTOK.DIV');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @SHORTINT.DIV.B');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @SHORTINT.DIV.A');

                asm65(#9'jsr @SHORTINT.DIV');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN-1,x');

              end;


            TDataType.SMALLINTTOK:
              if op = TTokenKind.MODTOK then
              begin
                //            asm65(#9'jsr @SMALLINT.MOD')

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @SMALLINT.MOD.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @SMALLINT.MOD.B+1');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @SMALLINT.MOD.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @SMALLINT.MOD.A+1');

                asm65(#9'jsr @SMALLINT.MOD');

                asm65(#9'lda @SMALLINT.MOD.RESULT');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda @SMALLINT.MOD.RESULT+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              end
              else
              begin
                //            asm65(#9'jsr @SMALLINT.DIV');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @SMALLINT.DIV.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @SMALLINT.DIV.B+1');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @SMALLINT.DIV.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @SMALLINT.DIV.A+1');

                asm65(#9'jsr @SMALLINT.DIV');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda :eax+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              end;

            TDataType.INTEGERTOK:
              if op = TTokenKind.MODTOK then
              begin
                //            asm65(#9'jsr @INTEGER.MOD')

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @INTEGER.MOD.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @INTEGER.MOD.B+1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta @INTEGER.MOD.B+2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta @INTEGER.MOD.B+3');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @INTEGER.MOD.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @INTEGER.MOD.A+1');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'sta @INTEGER.MOD.A+2');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
                asm65(#9'sta @INTEGER.MOD.A+3');

                asm65(#9'jsr @INTEGER.MOD');

                asm65(#9'lda @INTEGER.MOD.RESULT');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda @INTEGER.MOD.RESULT+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'lda @INTEGER.MOD.RESULT+2');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'lda @INTEGER.MOD.RESULT+3');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

              end
              else
              begin
                //            asm65(#9'jsr @INTEGER.DIV');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @INTEGER.DIV.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @INTEGER.DIV.B+1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta @INTEGER.DIV.B+2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta @INTEGER.DIV.B+3');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @INTEGER.DIV.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @INTEGER.DIV.A+1');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'sta @INTEGER.DIV.A+2');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
                asm65(#9'sta @INTEGER.DIV.A+3');

                asm65(#9'jsr @INTEGER.DIV');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda :eax+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'lda :eax+2');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'lda :eax+3');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

              end;

          end;

        end
        else
        begin

          case ResultType of

            TDataType.BYTETOK:
              if op = TTokenKind.MODTOK then
              begin
                //      asm65(#9'jsr @BYTE.MOD');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @BYTE.MOD.B');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @BYTE.MOD.A');

                asm65(#9'jsr @BYTE.MOD');

                asm65(#9'lda @BYTE.MOD.RESULT');
                asm65(#9'sta :STACKORIGIN-1,x');

              end
              else
              begin
                //      asm65(#9'jsr @BYTE.DIV');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @BYTE.DIV.B');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @BYTE.DIV.A');

                asm65(#9'jsr @BYTE.DIV');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN-1,x');

              end;

            TDataType.WORDTOK:
              if op = TTokenKind.MODTOK then
              begin
                //          asm65(#9'jsr @WORD.MOD');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @WORD.MOD.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @WORD.MOD.B+1');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @WORD.MOD.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @WORD.MOD.A+1');

                asm65(#9'jsr @WORD.MOD');

                asm65(#9'lda @WORD.MOD.RESULT');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda @WORD.MOD.RESULT+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              end
              else
              begin
                //      asm65(#9'jsr @WORD.DIV');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @WORD.DIV.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @WORD.DIV.B+1');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @WORD.DIV.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @WORD.DIV.A+1');

                asm65(#9'jsr @WORD.DIV');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda :eax+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              end;

            TDataType.CARDINALTOK:
              if op = TTokenKind.MODTOK then
              begin
                //         asm65(#9'jsr @CARDINAL.MOD');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @CARDINAL.MOD.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @CARDINAL.MOD.B+1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta @CARDINAL.MOD.B+2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta @CARDINAL.MOD.B+3');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @CARDINAL.MOD.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @CARDINAL.MOD.A+1');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'sta @CARDINAL.MOD.A+2');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
                asm65(#9'sta @CARDINAL.MOD.A+3');

                asm65(#9'jsr @CARDINAL.MOD');

                asm65(#9'lda @CARDINAL.MOD.RESULT');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda @CARDINAL.MOD.RESULT+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'lda @CARDINAL.MOD.RESULT+2');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'lda @CARDINAL.MOD.RESULT+3');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

              end
              else
              begin
                //      asm65(#9'jsr @CARDINAL.DIV');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @CARDINAL.DIV.B');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @CARDINAL.DIV.B+1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta @CARDINAL.DIV.B+2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta @CARDINAL.DIV.B+3');

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'sta @CARDINAL.DIV.A');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta @CARDINAL.DIV.A+1');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'sta @CARDINAL.DIV.A+2');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
                asm65(#9'sta @CARDINAL.DIV.A+3');

                asm65(#9'jsr @CARDINAL.DIV');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda :eax+1');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'lda :eax+2');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
                asm65(#9'lda :eax+3');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

              end;

          end;  // case

        end;  // end else begin

      end;  // if ResultType in SignedOrdinalTypes

    end;


    TTokenKind.SHLTOK:
    begin

      if ResultType in SignedOrdinalTypes then
      begin

        case GetDataSize(ResultType) of

          1: begin
            asm65(#9'jsr @expandToCARD1.SHORT');
            a65(TCode65.shlEAX_CL);
          end;

          2: begin
            asm65(#9'jsr @expandToCARD1.SMALL');
            a65(TCode65.shlEAX_CL);
          end;

          4: a65(TCode65.shlEAX_CL);

        end;

      end
      else
        case GetDataSize(ResultType) of
          1: a65(TCode65.shlAL_CL);
          2: a65(TCode65.shlAX_CL);
          4: a65(TCode65.shlEAX_CL);
        end;

    end;


    TTokenKind.SHRTOK:
    begin

      if ResultType in SignedOrdinalTypes then
      begin

        case GetDataSize(ResultType) of

          1: begin
            asm65(#9'jsr @expandToCARD1.SHORT');
            a65(TCode65.shrEAX_CL);
          end;

          2: begin
            asm65(#9'jsr @expandToCARD1.SMALL');
            a65(TCode65.shrEAX_CL);
          end;

          4: a65(TCode65.shrEAX_CL);

        end;

      end
      else
        case GetDataSize(ResultType) of
          1: a65(TCode65.shrAL_CL);
          2: a65(TCode65.shrAX_CL);
          4: a65(TCode65.shrEAX_CL);
        end;

    end;


    TTokenKind.ANDTOK:
    begin

      case GetDataSize(ResultType) of
        1: //a65(TCode65.andAL_CL);
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'and :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');
        end;

        2: //a65(TCode65.andAX_CX);
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'and :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'and :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
        end;

        4: //a65(TCode65.andEAX_ECX)
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'and :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'and :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'and :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
          asm65(#9'and :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
        end;

      end;

    end;


    TTokenKind.ORTOK:
    begin

      case GetDataSize(ResultType) of
        1: //a65(TCode65.orAL_CL);
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'ora :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');
        end;

        2: //a65(TCode65.orAX_CX);
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'ora :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'ora :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
        end;

        4: //a65(TCode65.orEAX_ECX)
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'ora :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'ora :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'ora :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
          asm65(#9'ora :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
        end;

      end;

    end;


    TTokenKind.XORTOK:
    begin

      case GetDataSize(ResultType) of
        1: //a65(TCode65.xorAL_CL);
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'eor :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');
        end;

        2: //a65(TCode65.xorAX_CX);
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'eor :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'eor :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
        end;

        4: //a65(TCode65.xorEAX_ECX)
        begin
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'eor :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN-1,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'eor :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
          asm65(#9'eor :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
          asm65(#9'eor :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
        end;

      end;

    end;

  end;// case

  a65(TCode65.subBX);

end;  //GenerateBinaryOperation


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelationString(relation: TTokenKind; LeftValType, RightValType: TDataType);
begin

  // asm65;
  // asm65('; relation STRING');

  Gen;

  asm65(#9'ldy #1');

  Gen;

{
 if (LeftValType = POINTERTOK) and (RightValType = POINTERTOK) then begin

   asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta @cmpPCHAR.B');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR.B+1');

  asm65(#9'lda :STACKORIGIN-1,x');
  asm65(#9'sta @cmpPCHAR.A');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR.A+1');

  asm65(#9'jsr @cmpPCHAR');

 end else

 if (LeftValType = POINTERTOK) and (RightValType = STRINGPOINTERTOK) then begin

   asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta @cmpPCHAR2STRING.B');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR2STRING.B+1');

  asm65(#9'lda :STACKORIGIN-1,x');
  asm65(#9'sta @cmpPCHAR2STRING.A');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR2STRING.A+1');

  asm65(#9'jsr @cmpPCHAR2STRING');

 end else
 if (LeftValType = STRINGPOINTERTOK) and (RightValType = POINTERTOK) then begin

   asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta @cmpSTRING2PCHAR.B');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  asm65(#9'sta @cmpSTRING2PCHAR.B+1');

  asm65(#9'lda :STACKORIGIN-1,x');
  asm65(#9'sta @cmpSTRING2PCHAR.A');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
  asm65(#9'sta @cmpSTRING2PCHAR.A+1');

  asm65(#9'jsr @cmpSTRING2PCHAR');

 end else
 }

  if (LeftValType = TDatatype.STRINGPOINTERTOK) and (RightValType = TDatatype.STRINGPOINTERTOK) then
  begin
    //  a65(TCode65.cmpSTRING)          // STRING ? STRING

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'sta @cmpSTRING.B');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'sta @cmpSTRING.B+1');

    asm65(#9'lda :STACKORIGIN-1,x');
    asm65(#9'sta @cmpSTRING.A');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'sta @cmpSTRING.A+1');

    asm65(#9'jsr @cmpSTRING');

  end
  else
    if LeftValType = TDatatype.CHARTOK then
    begin
      //  a65(TCode65.cmpCHAR2STRING)        // CHAR ? STRING

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @cmpCHAR2STRING.B');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @cmpCHAR2STRING.B+1');

      asm65(#9'lda :STACKORIGIN-1,x');
      asm65(#9'sta @cmpCHAR2STRING.A');

      asm65(#9'jsr @cmpCHAR2STRING');

    end
    else
      if RightValType = TDatatype.CHARTOK then
      begin
        //  a65(TCode65.cmpSTRING2CHAR);        // STRING ? CHAR

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @cmpSTRING2CHAR.B');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @cmpSTRING2CHAR.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @cmpSTRING2CHAR.A+1');

        asm65(#9'jsr @cmpSTRING2CHAR');
      end;

  GenerateRelationOperation(relation, TDatatype.BYTETOK);

  Gen;

  asm65(#9'dey');
  asm65('@');
  // asm65(#9'tya');      !!! ~
  asm65(#9'sty :STACKORIGIN-1,x');

  a65(TCode65.subBX);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelation(relation: TTokenKind; ValType: TDataType);
begin
  // asm65;
  // asm65('; relation');

  Gen;

  if ValType = TDataType.HALFSINGLETOK then
  begin

    case relation of
      TTokenKind.EQTOK:  // =
      begin
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_EQ.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_EQ.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_EQ.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_EQ.A+1');

        asm65(#9'jsr @F16_EQ');

        asm65(#9'dex');
      end;

      TTokenKind.NETOK, TTokenKind.UNTYPETOK:  // <>
      begin
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_EQ.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_EQ.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_EQ.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_EQ.A+1');

        asm65(#9'jsr @F16_EQ');

        asm65(#9'dex');
        asm65(#9'eor #$01');
      end;

      TTokenKind.GTTOK:  // >
      begin
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_GT.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_GT.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_GT.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_GT.A+1');

        asm65(#9'jsr @F16_GT');

        asm65(#9'dex');
      end;

      TTokenKind.LTTOK:  // <
      begin
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_GT.B');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_GT.B+1');

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_GT.A');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_GT.A+1');

        asm65(#9'jsr @F16_GT');

        asm65(#9'dex');
      end;

      TTokenKind.GETOK:  // >=
      begin
        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_GTE.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_GTE.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_GTE.A');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_GTE.A+1');

        asm65(#9'jsr @F16_GTE');

        asm65(#9'dex');
      end;

      TTokenKind.LETOK:  // <=
      begin
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @F16_GTE.B');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sta @F16_GTE.B+1');

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @F16_GTE.A');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @F16_GTE.A+1');

        asm65(#9'jsr @F16_GTE');

        asm65(#9'dex');
      end;

    end;

    asm65(#9'sta :STACKORIGIN,x');

  end
  else
  begin

    if ValType = TDataType.SINGLETOK then
    begin

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @FCMPL.A');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @FCMPL.A+1');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
      asm65(#9'sta @FCMPL.A+2');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
      asm65(#9'sta @FCMPL.A+3');

      asm65(#9'lda :STACKORIGIN-1,x');
      asm65(#9'sta @FCMPL.B');
      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
      asm65(#9'sta @FCMPL.B+1');
      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
      asm65(#9'sta @FCMPL.B+2');
      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
      asm65(#9'sta @FCMPL.B+3');
    end;

    asm65(#9'ldy #1');

    Gen;

    case ValType of
      TDataType.BYTETOK, TDataType.CHARTOK, TDataType.BOOLEANTOK:
      begin
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'cmp :STACKORIGIN,x');
      end;

      TDataType.SHORTINTTOK:
      begin  //a65(TCode65.cmpSHORTINT);

        asm65(#9'.LOCAL');
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sub :STACKORIGIN,x');
        asm65(#9'beq L5');
        asm65(#9'bvc L5');
        asm65(#9'eor #$FF');
        asm65(#9'ora #$01');
        asm65('L5');
        asm65(#9'.ENDL');

      end;

      TDataType.SMALLINTTOK, TDataType.SHORTREALTOK:
      begin  //a65(TCode65.cmpSMALLINT);

        asm65(#9'.LOCAL');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'sub :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'bne L4');
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'cmp :STACKORIGIN,x');
        asm65(#9'beq L5');
        asm65(#9'lda #$00');
        asm65(#9'adc #$FF');
        asm65(#9'ora #$01');
        asm65(#9'bne L5');
        asm65('L4'#9'bvc L5');
        asm65(#9'eor #$FF');
        asm65(#9'ora #$01');
        asm65('L5');
        asm65(#9'.ENDL');

      end;

      TDataType.SINGLETOK: asm65(#9'jsr @FCMPL');

      TDataType.REALTOK, TDataType.INTEGERTOK:
      begin  //a65(TCode65.cmpINT);

        asm65(#9'.LOCAL');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
        asm65(#9'sub :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'bne L4');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
        asm65(#9'cmp :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'bne L1');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'bne L1');
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'cmp :STACKORIGIN,x');
        asm65('L1'#9'beq L5');
        asm65(#9'bcs L3');
        asm65(#9'lda #$FF');
        asm65(#9'bne L5');
        asm65('L3'#9'lda #$01');
        asm65(#9'bne L5');
        asm65('L4'#9'bvc L5');
        asm65(#9'eor #$FF');
        asm65(#9'ora #$01');
        asm65('L5');
        asm65(#9'.ENDL');

      end;

      TDataType.WORDTOK, TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK:
      begin  //a65(TCode65.cmpAX_CX);

        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'bne @+');
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'cmp :STACKORIGIN,x');
        asm65('@');

      end;

      else
      begin  //a65(TCode65.cmpEAX_ECX);          // TTokenKind.CARDINALTOK

        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
        asm65(#9'cmp :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'bne @+');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
        asm65(#9'cmp :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'bne @+');
        asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
        asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'bne @+');
        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'cmp :STACKORIGIN,x');
        asm65('@');

      end;

    end;

    GenerateRelationOperation(relation, ValType);

    Gen;

    asm65(#9'dey');
    asm65('@');
    //asm65(#9'tya');      !!! ~
    asm65(#9'sty :STACKORIGIN-1,x');

    a65(TCode65.subBX);

  end; // if ValType = TDataType.HALFSINGLETOK

end;  //GenerateRelation


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// The following functions implement recursive descent parser in accordance with Sub-Pascal EBNF
// Parameter i is the index of the first token of the current EBNF symbol, result is the index of the last one

function CompileExpression(i: Integer; out ValType: TDataType; VarType: TDataType = TDataType.INTEGERTOK): Integer;
  forward;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

{
procedure InfoAboutArray(IdentIndex: Integer; c: Boolean = false);
var t: string;
begin

  if c then
   t := ' Const'
  else
   t := '';

  asm65;

  if IdentifierAt(IdentIndex).NumAllocElements_ > 0 then
   asm65(';' + t + ' Array index '+IdentifierAt(IdentIndex).Name+'[0..'+IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1)+', 0..'+IntToStr(IdentifierAt(IdentIndex).NumAllocElements_ - 1)+']')
  else
   asm65(';' + t + ' Array index '+IdentifierAt(IdentIndex).Name+'[0..'+IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1)+']');

end;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function SafeCompileConstExpression(var i: Integer; out ConstVal: Int64; out ValType: TDataType;
  VarType: TDataType; Err: Boolean = False; War: Boolean = True): Boolean;
var
  j: Integer;
begin

  j := i;

  isError := False;     // dodatkowy test
  isConst := True;

  i := CompileConstExpression(i, ConstVal, ValType, VarType, Err, War);

  Result := not isError;

  isConst := False;
  isError := False;

  if not Result then i := j;

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileArrayIndex(i: Integer; IdentIndex: Integer; out VarType: TDataType): Integer;
var
  ConstVal: Int64;
  ActualParamType, ArrayIndexType: TDataType;
  Size: Byte;
  NumAllocElements, NumAllocElements_: Cardinal;
  j: Integer;
  yes, ShortArrayIndex: Boolean;
begin

  if common.optimize.use = False then StartOptimization(i);


  if (IdentifierAt(IdentIndex).isStriped) then
    Size := 1
  else
    Size := GetDataSize(IdentifierAt(IdentIndex).AllocElementType);


  ShortArrayIndex := False;

  VarType := IdentifierAt(IdentIndex).AllocElementType;


  if ((IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
    (IdentifierAt(IdentIndex).IdType = TDataType.DEREFERENCEARRAYTOK)) then
  begin
    NumAllocElements := IdentifierAt(IdentIndex).NestedNumAllocElements and $FFFF;
    NumAllocElements_ := IdentifierAt(IdentIndex).NestedNumAllocElements shr 16;

    if NumAllocElements_ > 0 then
    begin
      if (NumAllocElements * NumAllocElements_ > 1) and (NumAllocElements * NumAllocElements_ * Size < 256) then
        ShortArrayIndex := True;
    end
    else
      if (NumAllocElements > 1) and (NumAllocElements * Size < 256) then ShortArrayIndex := True;

  end
  else
  begin
    NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements;
    NumAllocElements_ := IdentifierAt(IdentIndex).NumAllocElements_;
  end;


  if IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK, TDataType.PROCVARTOK] then
    NumAllocElements_ := 0;


  ActualParamType := TDatatype.WORDTOK;    // !!! aby dzialaly optymalizacje dla ADR.


  j := i + 2;

  if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then
  begin
    i := j;

    CheckArrayIndex(i, IdentIndex, ConstVal, ArrayIndexType);

    ArrayIndexType := TDataType.WORDTOK;
    ShortArrayIndex := False;

    if NumAllocElements_ > 0 then
      Push(ConstVal * NumAllocElements_ * Size, ASVALUE, GetDataSize(ArrayIndexType))
    else
      Push(ConstVal * Size, ASVALUE, GetDataSize(ArrayIndexType));

  end
  else
  begin
    i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);  // array index [x, ..]

    GetCommonType(i, ActualParamType, ArrayIndexType);

    case ArrayIndexType of
      TDataType.SHORTINTTOK: ArrayIndexType := TDataType.BYTETOK;
      TDataType.SMALLINTTOK: ArrayIndexType := TDataType.WORDTOK;
      TDataType.INTEGERTOK: ArrayIndexType := TDataType.CARDINALTOK;
    end;

    if GetDataSize(ArrayIndexType) = 4 then
    begin  // remove oldest bytes
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
      asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
      asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
    end;

    if GetDataSize(ArrayIndexType) = 1 then
    begin
      ExpandParam(TDataType.WORDTOK, ArrayIndexType);
      //      ArrayIndexType := WORDTOK;
    end
    else
      ArrayIndexType := TDataType.WORDTOK;

    if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0, 1]) {or (NumAllocElements_ > 0)} then
    begin
      //        ExpandParam(WORDTOK, ArrayIndexType);
      ArrayIndexType := TDataType.WORDTOK;
    end;


    if NumAllocElements_ > 0 then
    begin

      Push(Integer(NumAllocElements_ * Size), ASVALUE, GetDataSize(ArrayIndexType));

      GenerateBinaryOperation(MULTOK, ArrayIndexType);

    end
    else
      if IdentifierAt(IdentIndex).isStriped = False then
        GenerateIndexShift(IdentifierAt(IdentIndex).AllocElementType);

  end;


  yes := False;

  if NumAllocElements_ > 0 then
  begin

    if (TokenAt(i + 1).Kind = CBRACKETTOK) and (TokenAt(i + 2).Kind <> OBRACKETTOK)
    {(Tok[i + 2].Kind in [ASSIGNTOK, SEMICOLONTOK])} then
    begin
      yes := False;

      Push(0, ASVALUE, GetDataSize(ArrayIndexType));

      GenerateBinaryOperation(PLUSTOK, TDataType.WORDTOK);

      VarType := TDataType.ARRAYTOK;
    end
    else
      if TokenAt(i + 1).Kind = CBRACKETTOK then
      begin
        Inc(i);
        CheckTok(i + 1, OBRACKETTOK);
        yes := True;
      end
      else
      begin
        CheckTok(i + 1, COMMATOK);
        yes := True;
      end;

  end
  else
    CheckTok(i + 1, CBRACKETTOK);


  if { TokenAt(i + 1].Kind = COMMATOK} yes then
  begin

    j := i + 2;

    if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then
    begin
      i := j;

      CheckArrayIndex_(i, IdentIndex, ConstVal, ArrayIndexType);

      ArrayIndexType := TDatatype.WORDTOK;
      ShortArrayIndex := False;

      Push(ConstVal * Size, ASVALUE, GetDataSize(ArrayIndexType));

    end
    else
    begin
      i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);  // array index [.., y]

      GetCommonType(i, ActualParamType, ArrayIndexType);

      case ArrayIndexType of
        TDataType.SHORTINTTOK: ArrayIndexType := TDatatype.BYTETOK;
        TDataType.SMALLINTTOK: ArrayIndexType := TDatatype.WORDTOK;
        TDataType.INTEGERTOK: ArrayIndexType := TDatatype.CARDINALTOK;
      end;

      if GetDataSize(ArrayIndexType) = 4 then
      begin  // remove oldest bytes
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
      end;

      if GetDataSize(ArrayIndexType) = 1 then
      begin
        ExpandParam(TDatatype.WORDTOK, ArrayIndexType);
        ArrayIndexType := TDatatype.WORDTOK;
      end
      else
        ArrayIndexType := TDatatype.WORDTOK;

      //      if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
      //        ExpandParam(WORDTOK, ArrayIndexType);
      //        ArrayIndexType := WORDTOK;
      //      end;

      if IdentifierAt(IdentIndex).isStriped = False then GenerateIndexShift(IdentifierAt(IdentIndex).AllocElementType);

    end;

    GenerateBinaryOperation(TTokenKind.PLUSTOK, TDatatype.WORDTOK);

  end;


  if ShortArrayIndex then
  begin

    asm65(#9'lda #$00');
    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

  end;

  //  writeln(IdentifierAt(IdentIndex).Name,',',Elements(IdentIndex));

  Result := i;

end;  //CompileArrayIndex

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileAddress(i: Integer; out ValType, AllocElementType: TDataType; VarPass: Boolean = False): Integer;
var
  IdentIndex, IdentTemp, j: Integer;
  Name, svar, lab: String;
  NumAllocElements: Cardinal;
  rec, dereference, address: Boolean;
begin

  Result := i;

  lab := '';

  rec := False;
  dereference := False;

  address := False;

  AllocElementType := TDataType.UNTYPETOK;


  if TokenAt(i + 1).Kind = TTokenKind.ADDRESSTOK then
  begin

    if VarPass then
      Error(i + 1, TMessage.Create(TErrorCode.CantAsignValuesToAnAddress, 'Can''t assign values to an address'));

    address := True;

    Inc(i);
  end;


  if (TokenAt(i + 1).Kind = TTokenKind.PCHARTOK) and (TokenAt(i + 2).Kind = TTokenKind.OPARTOK) then
  begin

    j := CompileExpression(i + 3, ValType, TDataType.POINTERTOK);

    CheckTok(j + 1, TTokenKind.CPARTOK);

    if TokenAt(j + 2).Kind <> TTokenKind.DEREFERENCETOK then
      Error(i + 3, TMessage.Create(TErrorCode.CantAsignValuesToAnAddress, 'Can''t assign values to an address'));

    i := j + 1;

  end
  else

    if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
      Error(i + 1, TErrorCode.IdentifierExpected)
    else
    begin
      IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);


      if IdentIndex > 0 then
      begin

        if not (IdentifierAt(IdentIndex).Kind in [TTokenKind.CONSTTOK, TTokenKind.VARTOK,
          TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK,
          TTokenKind.DESTRUCTORTOK, TTokenKind.ADDRESSTOK]) then
          Error(i + 1, TErrorCode.VariableExpected)
        else
        begin

          if IdentifierAt(IdentIndex).Kind = TTokenKind.CONSTTOK then
            if not ((IdentifierAt(IdentIndex).DataType in Pointers) and
              (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
              Error(i + 1, TErrorCode.CantAdrConstantExp);


          //  writeln(IdentifierAt(IdentIndex).nAME,' = ',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod );


          if IdentifierAt(IdentIndex).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
            TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
          begin

            Name := GetLocalName(IdentIndex);

            if IdentifierAt(IdentIndex).isOverload then Name := Name + '.' + GetOverloadName(IdentIndex);

            a65(TCode65.addBX);
            asm65(#9'mva <' + Name + ' :STACKORIGIN,x');
            asm65(#9'mva >' + Name + ' :STACKORIGIN+STACKWIDTH,x');

            if Pass = TPass.CALL_DETERMINATION then
              AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(IdentIndex).ProcAsBlock);

          end
          else

            if (TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK) and (IdentifierAt(IdentIndex).DataType in Pointers) and
              ((IdentifierAt(IdentIndex).NumAllocElements > 0) or
              ((IdentifierAt(IdentIndex).NumAllocElements = 0) and
              (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK))) then
            begin                  // array index
              Inc(i);

              // atari    // a := @tab[x,y]

              i := CompileArrayIndex(i, IdentIndex, AllocElementType);


              if IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK then
                NumAllocElements := 0
              else
                NumAllocElements := Elements(IdentIndex);

              svar := GetLocalName(IdentIndex);

              if (pos('.', svar) > 0) then
              begin
                //   lab:=copy(svar, 1, svar.IndexOf('.'));
                lab := ExtractName(IdentIndex, svar);

                rec := (IdentifierAt(GetIdentIndex(lab)).AllocElementType = TDataType.RECORDTOK);
              end;

              //AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

              //  WritelLn(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',VarPass ,',',rec,',',IdentifierAt(IdentIndex).idType);

              if rec then
              begin              // record.array[]

                asm65(#9'lda ' + lab);
                asm65(#9'add :STACKORIGIN,x');
                asm65(#9'sta :STACKORIGIN,x');
                asm65(#9'lda ' + lab + '+1');
                asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'add #' + svar + '-DATAORIGIN');
                asm65(#9'sta :STACKORIGIN,x');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

              end
              else

                if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) or
                  (NumAllocElements * GetDataSize(AllocElementType) > 256) or (NumAllocElements in [0, 1]) then
                begin

                  //  writeln(IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',IdentifierAt(IdentIndex).idType );

                  asm65(#9'lda ' + svar);
                  asm65(#9'add :STACKORIGIN,x');
                  asm65(#9'sta :STACKORIGIN,x');
                  asm65(#9'lda ' + svar + '+1');
                  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                end
                else
                begin

                  //  writeln(IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',IdentifierAt(IdentIndex).idType );

                  asm65(#9'lda <' + GetLocalName(IdentIndex, 'adr.'));
                  asm65(#9'add :STACKORIGIN,x');
                  asm65(#9'sta :STACKORIGIN,x');
                  asm65(#9'lda >' + GetLocalName(IdentIndex, 'adr.'));
                  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                end;

              CheckTok(i + 1, TTokenKind.CBRACKETTOK);

            end
            else
              if (IdentifierAt(IdentIndex).DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK,
                TDataType.RECORDTOK, TDataType.OBJECTTOK] {+ Pointers}) or
                ((IdentifierAt(IdentIndex).DataType in Pointers) and
                (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
                (IdentifierAt(IdentIndex).NumAllocElements > 0)) or
                (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) or
                (VarPass and (IdentifierAt(IdentIndex).DataType in Pointers)) then
              begin

                //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',TokenAt(i + 2).Kind);

                DEREFERENCE := (TokenAt(i + 2).Kind = TTokenKind.DEREFERENCETOK);


                if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) and
                  (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                  (IdentifierAt(IdentIndex).DataType in Pointers) and
                  (IdentifierAt(IdentIndex).AllocElementType in Pointers) and
                  (IdentifierAt(IdentIndex).idType = TDataType.DATAORIGINOFFSET) then
                begin

                  Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORD, GetDataSize(TDataType.POINTERTOK),
                    IdentIndex);
                end
                else
                  if DEREFERENCE then
                  begin

                    svar := GetLocalName(IdentIndex);

                    //       if (pos('.', svar) > 0) then begin
                    //       lab:=copy(svar,1,pos('.', svar)-1);
                    //       rec:=(IdentifierAt(GetIdentIndex(lab)).AllocElementType = TDataType.RECORDTOK);
                    //     end;

                    if (IdentifierAt(IdentIndex).DataType in Pointers)
                    {and (TokenAt(i + 2).Kind = TTokenKind.DEREFERENCETOK)} then
                      if (IdentifierAt(IdentIndex).AllocElementType = TDataType.RECORDTOK) and
                        (TokenAt(i + 3).Kind = TTokenKind.DOTTOK) then
                      begin    // var record^.field

                        //        DEREFERENCE := true;

                        CheckTok(i + 4, TTokenKind.IDENTTOK);
                        IdentTemp := RecordSize(IdentIndex, TokenAt(i + 4).Name);

                        if IdentTemp < 0 then
                          Error(i + 4, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                            'Identifier idents no member ''{0}''.', TokenAt(i + 4).Name));

                        AllocElementType := TDataType(IdentTemp shr 16);

                        IdentTemp := GetIdentIndex(svar + '.' + String(TokenAt(i + 4).Name));

                        if IdentTemp = 0 then
                          Error(i + 4, TErrorCode.UnknownIdentifier);

                        Push(IdentifierAt(IdentTemp).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentTemp);

                        Inc(i, 3);

                      end
                      else
                      begin                      // type^
                        AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                        //  writeln('^',',', IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' / ',IdentifierAt(IdentIndex).NumAllocElements_,' = ',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);

                        if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                          (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                        begin

                          if IdentifierAt(IdentIndex).AllocElementType in
                            [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                          begin

                            if IdentifierAt(IdentIndex).NumAllocElements_ = 0 then

                            else
                              Error(i + 4, TErrorCode.IllegalQualifier);  // array of ^record

                          end
                          else
                            Error(i + 4, TErrorCode.IllegalQualifier);  // array

                        end;
                        //trs
                        if IdentifierAt(IdentIndex).ObjectVariable and
                          (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) then
                          Push(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER,
                            GetDataSize(TDataType.POINTERTOK), IdentIndex)
                        else
                          Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK),
                            IdentIndex);

                        Inc(i);
                      end;


                    //  writeln('5: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE,',',VarPass);

                  end
                  else
                    if address or VarPass then
                    begin
                      //       if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements = 0) {and (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING)} then begin

                      //  writeln('1: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,'..',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE,',',varpass,' o ',IdentifierAt(IdentIndex).isAbsolute);

                      if (IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK,
                        TDataType.OBJECTTOK, TDataType.FILETOK, TDataType.TEXTFILETOK]) or
                        (VarPass and (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                        (IdentifierAt(IdentIndex).AllocElementType in AllTypes -
                        [TDataType.PROCVARTOK, TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                        (IdentifierAt(IdentIndex).NumAllocElements = 0)) or
                        ((IdentifierAt(IdentIndex).DataType in Pointers) and
                        (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                        (VarPass or (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING))) or
                        (IdentifierAt(IdentIndex).isAbsolute and
                        (abs(IdentifierAt(IdentIndex).Value) and $ff = 0) and
                        (Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) in [1..127])) or
                        ((IdentifierAt(IdentIndex).DataType in Pointers) and
                        (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                        (IdentifierAt(IdentIndex).NumAllocElements_ = 0)) or
                        ((IdentifierAt(IdentIndex).DataType in Pointers) and
                        (IdentifierAt(IdentIndex).idType = TDataType.DATAORIGINOFFSET)) or
                        ((IdentifierAt(IdentIndex).DataType in Pointers) and not
                        (IdentifierAt(IdentIndex).AllocElementType in [TDataType.UNTYPETOK,
                        TDataType.RECORDTOK, TDataType.OBJECTTOK, TDataType.PROCVARTOK]) and
                        (IdentifierAt(IdentIndex).NumAllocElements > 0)) or
                        ((IdentifierAt(IdentIndex).DataType in Pointers) and
                        (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING)) then
                        Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex)
                      else
                        Push(IdentifierAt(IdentIndex).Value, ASVALUE, GetDataSize(TDataType.POINTERTOK), IdentIndex);

                      AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                    end
                    else
                    begin

                      //  writeln('2: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);

                      Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);

                      AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                    end;

              end
              else
              begin

                if (IdentifierAt(IdentIndex).DataType in Pointers) and (TokenAt(i + 2).Kind =
                  TTokenKind.DEREFERENCETOK) then
                begin
                  AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                  Inc(i);

                  Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);
                end
                else
                  //      if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType <> 0) and (IdentifierAt(IdentIndex).NumAllocElements = 0) then begin
                  //  writeln('3: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);
                  //       Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);
                  //      end else
                begin

                  //  writeln('4: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);

                  Push(IdentifierAt(IdentIndex).Value, ASVALUE, GetDataSize(TDataType.POINTERTOK), IdentIndex);

                end;

              end;

          ValType := TDataType.POINTERTOK;

          Result := i + 1;
        end;

      end
      else
        Error(i + 1, TErrorCode.UnknownIdentifier);
    end;

end;  //CompileAddress


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function NumActualParameters(i: Integer; IdentIndex: Integer; out NumActualParams: Integer): TParamList;
  (*----------------------------------------------------------------------------*)
  (* moze istniec wiele funkcji/procedur o tej samej nazwie ale roznej liczbie  *)
  (* parametrow                      *)
  (*----------------------------------------------------------------------------*)
var
  ActualParamType, AllocElementType: TDataType;
  NumAllocElements: Cardinal;
  oldPass: TPass;
  oldCodeSize, IdentTemp: Integer;
begin

  oldPass := pass;
  oldCodeSize := CodeSize;
  Pass := TPass.CALL_DETERMINATION;

  NumActualParams := 0;
  ActualParamType := TDataType.UNTYPETOK;

  Result[1].i_ := i + 1;

  if (TokenAt(i + 1).Kind = TTokenKind.OPARTOK) and (TokenAt(i + 2).Kind <> TTokenKind.CPARTOK) then
    // Actual parameter list found
  begin
    repeat

      Inc(NumActualParams);

      if NumActualParams > MAXPARAMS then
        ErrorForIdentifier(i, TErrorCode.TooManyParameters, IdentIndex);

      Result[NumActualParams].i := i;

{
       if (IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod = TParameterPassingMethod.VARPASSING) then begin    // !!! to nie uwzglednia innych procedur/funkcji o innej liczbie parametrow

  CompileExpression(i + 2, ActualParamType);

  Result[NumActualParams].AllocElementType := ActualParamType;

  i := CompileAddress(i + 1, ActualParamType, AllocElementType);

       end else}

      i := CompileExpression(i + 2, ActualParamType{, IdentifierAt(IdentIndex).Param[NumActualParams].DataType});
      // Evaluate actual parameters and push them onto the stack

      AllocElementType := TDataType.UNTYPETOK;
      NumAllocElements := 0;

      if (ActualParamType in [TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK]) and
        (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
      begin

        IdentTemp := GetIdentIndex(TokenAt(i).Name);

        if (TokenAt(i - 1).Kind = TTokenKind.ADDRESSTOK) and
          (not (IdentifierAt(IdentTemp).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then

        else
        begin
          AllocElementType := IdentifierAt(IdentTemp).AllocElementType;
          NumAllocElements := IdentifierAt(IdentTemp).NumAllocElements;
        end;


        if IdentifierAt(IdentTemp).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK] then
        begin

          Result[NumActualParams].Name := IdentifierAt(IdentTemp).Name;

          AllocElementType := IdentifierAt(IdentTemp).CastKindToDataType;

        end;

        //  writeln(IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements,'/',IdentifierAt(IdentTemp).NumAllocElements_,'|',ActualParamType,',',AllocElementType);

      end
      else
      begin

        if TokenAt(i).Kind = TTokenKind.IDENTTOK then
        begin

          IdentTemp := GetIdentIndex(TokenAt(i).Name);

          AllocElementType := IdentifierAt(IdentTemp).AllocElementType;
          NumAllocElements := IdentifierAt(IdentTemp).NumAllocElements;

          //  writeln(IdentifierAt(IdentTemp).Name,' > ',ActualPAramType,',',AllocElementType,',',NumAllocElements,' | ',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements);

        end
        else
          AllocElementType := TDataType.UNTYPETOK;

      end;

      Result[NumActualParams].DataType := ActualParamType;
      Result[NumActualParams].AllocElementType := AllocElementType;
      Result[NumActualParams].NumAllocElements := NumAllocElements;


      //  writeln(Result[NumActualParams].DataType,',',Result[NumActualParams].AllocElementType);

    until TokenAt(i + 1).Kind <> TTokenKind.COMMATOK;

    CheckTok(i + 1, TTokenKind.CPARTOK);

    Result[1].i_ := i;

    //     inc(i);
  end;  // if (TokenAt(i + 1).Kind = OPARTOR) and (TokenAt(i + 2).Kind <> TTokenKind.CPARTOK)


  Pass := oldPass;
  CodeSize := oldCodeSize;

end;  //NumActualParameters


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: Should the last pameter be a token or a datatype?
procedure RealTypeConversion(var ValType, RightValType: TDataType; castDataType: TDataType = TDataType.UNTYPETOK);
begin

  if ((ValType = TDataType.SINGLETOK) or (castDataType = TDataType.SINGLETOK)) and (RightValType in IntegerTypes) then
  begin

    ExpandParam(TDataType.INTEGERTOK, RightValType);

    //   asm65(#9'jsr @I2F');

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'sta :FPMAN0');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'sta :FPMAN1');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
    asm65(#9'sta :FPMAN2');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
    asm65(#9'sta :FPMAN3');

    asm65(#9'jsr @I2F');

    asm65(#9'lda :FPMAN0');
    asm65(#9'sta :STACKORIGIN,x');
    asm65(#9'lda :FPMAN1');
    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'lda :FPMAN2');
    asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
    asm65(#9'lda :FPMAN3');
    asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

    if (ValType <> TDataType.SINGLETOK) and (castDataType = TDataType.SINGLETOK) then
      RightValType := castDataType
    else
      RightValType := ValType;

  end;


  if (ValType in IntegerTypes) and ((RightValType = TDataType.SINGLETOK) or (castDataType = TDataType.SINGLETOK)) then
  begin

    ExpandParam_m1(TDataType.INTEGERTOK, ValType);

    //   asm65(#9'jsr @I2F_M');

    asm65(#9'lda :STACKORIGIN-1,x');
    asm65(#9'sta :FPMAN0');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'sta :FPMAN1');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
    asm65(#9'sta :FPMAN2');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
    asm65(#9'sta :FPMAN3');

    asm65(#9'jsr @I2F');

    asm65(#9'lda :FPMAN0');
    asm65(#9'sta :STACKORIGIN-1,x');
    asm65(#9'lda :FPMAN1');
    asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'lda :FPMAN2');
    asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
    asm65(#9'lda :FPMAN3');
    asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

    if (RightValType <> TDataType.SINGLETOK) and (castDataType = TDataType.SINGLETOK) then
      ValType := castDataType
    else
      ValType := RightValType;

  end;


  if ((ValType = TDataType.HALFSINGLETOK) or (castDataType = TDataType.HALFSINGLETOK)) and
    (RightValType in IntegerTypes) then
  begin

    ExpandParam(TDataType.INTEGERTOK, RightValType);

    //   asm65(#9'jsr @F16_I2F');

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'sta @F16_I2F.SV');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'sta @F16_I2F.SV+1');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
    asm65(#9'sta @F16_I2F.SV+2');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
    asm65(#9'sta @F16_I2F.SV+3');

    asm65(#9'jsr @F16_I2F');

    asm65(#9'lda :eax');
    asm65(#9'sta :STACKORIGIN,x');
    asm65(#9'lda :eax+1');
    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

    if (ValType <> TDataType.HALFSINGLETOK) and (castDataType = TDataType.HALFSINGLETOK) then
      RightValType := castDataType
    else
      RightValType := ValType;

  end;


  if (ValType in IntegerTypes) and ((RightValType = TDataType.HALFSINGLETOK) or
    (castDataType = TDataType.HALFSINGLETOK)) then
  begin

    ExpandParam_m1(TDataType.INTEGERTOK, ValType);

    //   asm65(#9'jsr @F16_I2F');//_m');

    asm65(#9'lda :STACKORIGIN-1,x');
    asm65(#9'sta @F16_I2F.SV');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'sta @F16_I2F.SV+1');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
    asm65(#9'sta @F16_I2F.SV+2');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
    asm65(#9'sta @F16_I2F.SV+3');

    asm65(#9'jsr @F16_I2F');

    asm65(#9'lda :eax');
    asm65(#9'sta :STACKORIGIN-1,x');
    asm65(#9'lda :eax+1');
    asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');


    if (RightValType <> TDataType.HALFSINGLETOK) and (castDataType = TDataType.HALFSINGLETOK) then
      ValType :=castDataType
    else
      ValType := RightValType;
  end;


  if ((ValType in [TDatatype.REALTOK, TDatatype.SHORTREALTOK]) or
    (castDataType in [TDataType.REALTOK, TDataType.SHORTREALTOK])) and (RightValType in IntegerTypes) then
  begin

    ExpandParam(TDataType.INTEGERTOK, RightValType);

    asm65(#9'jsr @expandToREAL');
{
   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
   asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
   asm65(#9'lda :STACKORIGIN,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'lda #$00');
   asm65(#9'sta :STACKORIGIN,x');
}
    if not (ValType in [TDatatype.REALTOK, TDatatype.SHORTREALTOK]) and
      (castDataType in [TDataType.REALTOK, TDataType.SHORTREALTOK]) then
      RightValType := castDataType
    else
      RightValType := ValType;

  end;


  if (ValType in IntegerTypes) and ((RightValType in [TDataType.REALTOK, TDataType.SHORTREALTOK]) or
    (castDataType in [TDataType.REALTOK, TDataType.SHORTREALTOK])) then
  begin

    ExpandParam_m1(TDataType.INTEGERTOK, ValType);

    asm65(#9'jsr @expandToREAL1');
{
   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
   asm65(#9'lda :STACKORIGIN-1,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'lda #$00');
   asm65(#9'sta :STACKORIGIN-1,x');
}

    if not (RightValType in [TDatatype.REALTOK, TDatatype.SHORTREALTOK]) and
      (castDataType in [TDatatype.REALTOK, TDatatype.SHORTREALTOK]) then
      ValType := castDataType
    else
      ValType := RightValType;

  end;

end;  //RealTypeConversion

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileActualParameters(var i: Integer; IdentIndex: Integer; ProcVarIndex: Integer = 0);
var
  NumActualParams, IdentTemp, ParamIndex, j, old_i, old_func: Integer;
  ActualParamType, AllocElementType: TDataType;
  svar, lab: String;
  yes: Boolean;
  Param: TParamList;
begin

  svar := '';
  lab := '';

  old_i := i;

  if IdentifierAt(IdentIndex).ProcAsBlock = BlockStack[BlockStackTop] then
    IdentifierAt(IdentIndex).isRecursion := True;


  yes := {(IdentifierAt(IdentIndex).ObjectIndex > 0) or} IdentifierAt(IdentIndex).isRecursion or
    IdentifierAt(IdentIndex).isStdCall;

  for ParamIndex := IdentifierAt(IdentIndex).NumParams downto 1 do
    if not ((IdentifierAt(IdentIndex).Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING) or
      ((IdentifierAt(IdentIndex).Param[ParamIndex].DataType in Pointers) and
      (IdentifierAt(IdentIndex).Param[ParamIndex].NumAllocElements and $FFFF in [0, 1])) or
      ((IdentifierAt(IdentIndex).Param[ParamIndex].DataType in Pointers) and
      (IdentifierAt(IdentIndex).Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or
      (IdentifierAt(IdentIndex).Param[ParamIndex].DataType in OrdinalTypes + RealTypes)) then
    begin
      yes := True;
      Break;
    end;


  //   yes:=true;

  (*------------------------------------------------------------------------------------------------------------*)

  if ProcVarIndex > 0 then
  begin

    svar := GetLocalName(ProcVarIndex);

    if (TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK) then
    begin
      i := CompileArrayIndex(i, ProcVarIndex, AllocElementType);

      CheckTok(i + 1, TTokenKind.CBRACKETTOK);

      Inc(i);

      if (IdentifierAt(ProcVarIndex).NumAllocElements * 2 > 256) or
        (IdentifierAt(ProcVarIndex).NumAllocElements in [0, 1]) then
      begin

        asm65(#9'lda ' + svar);
        asm65(#9'add :STACKORIGIN,x');
        asm65(#9'sta :bp2');
        asm65(#9'lda ' + svar + '+1');
        asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta :bp2+1');
        asm65(#9'ldy #$00');
        asm65(#9'lda (:bp2),y');
        asm65(#9'sta :TMP+1');
        asm65(#9'iny');
        asm65(#9'lda (:bp2),y');
        asm65(#9'sta :TMP+2');

        asm65(#9'dex');

      end
      else
      begin

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'add #$00');
        asm65(#9'tay');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'adc #$00');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

        asm65(#9'lda adr.' + svar + ',y');
        asm65(#9'sta :TMP+1');
        asm65(#9'lda adr.' + svar + '+1,y');
        asm65(#9'sta :TMP+2');

        asm65(#9'dex');

      end;

      asm65(#9'lda #$4C');
      asm65(#9'sta :TMP');

    end
    else
    begin

      if IdentifierAt(ProcVarIndex).isAbsolute and (IdentifierAt(ProcVarIndex).NumAllocElements = 0) then
      begin

        //        asm65(#9'jsr *+6');
        //        asm65(#9'jmp *+6');

      end
      else
      begin

        if (IdentifierAt(ProcVarIndex).PassMethod = TParameterPassingMethod.VARPASSING) then
        begin

          if pos('.', svar) > 0 then
          begin

            lab := ExtractName(ProcVarIndex, svar);

            asm65(#9'mwy ' + lab + ' :bp2');
            asm65(#9'ldy #' + svar + '-DATAORIGIN');
          end
          else
          begin
            asm65(#9'mwy ' + svar + ' :bp2');
            asm65(#9'ldy #$00');
          end;

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :TMP+1');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :TMP+2');

        end
        else
        begin

          //   writeln(IdentifierAt(ProcVarIndex).Name,',',IdentifierAt(ProcVarIndex).DataType,',',   IdentifierAt(ProcVarIndex).NumAllocElements,',', IdentifierAt(ProcVarIndex).AllocElementType,',',IdentifierAt(ProcVarIndex).isAbsolute);

          if IdentifierAt(ProcVarIndex).NumAllocElements = 0 then
          begin

            asm65(#9'lda ' + svar);
            asm65(#9'sta :TMP+1');
            asm65(#9'lda ' + svar + '+1');
            asm65(#9'sta :TMP+2');

          end
          else

            if (IdentifierAt(ProcVarIndex).NumAllocElements * 2 > 256) or
              (IdentifierAt(ProcVarIndex).NumAllocElements in [1]) then
            begin

              asm65(#9'lda ' + svar);
              asm65(#9'add :STACKORIGIN,x');
              asm65(#9'sta :bp2');
              asm65(#9'lda ' + svar + '+1');
              asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :bp2+1');
              asm65(#9'ldy #$00');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :TMP+1');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :TMP+2');

              asm65(#9'dex');

            end
            else
            begin

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'add #$00');
              asm65(#9'tay');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'adc #$00');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda adr.' + svar + ',y');
              asm65(#9'sta :TMP+1');
              asm65(#9'lda adr.' + svar + '+1,y');
              asm65(#9'sta :TMP+2');

              asm65(#9'dex');

            end;

        end;

        asm65(#9'lda #$4C');
        asm65(#9'sta :TMP');

      end;

    end;

  end;

  (*------------------------------------------------------------------------------------------------------------*)

  Param := NumActualParameters(i, IdentIndex, NumActualParams);

  if NumActualParams <> IdentifierAt(IdentIndex).NumParams then
    if ProcVarIndex > 0 then
      Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters specified for {0}.',
        IdentifierAt(ProcVarIndex).Name))
    else
      Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters specified for {0}.',
        IdentifierAt(identIndex).Name));


  ParamIndex := NumActualParams;

  AllocElementType := TDataType.UNTYPETOK;

  //   NumActualParams := 0;
  IdentTemp := 0;

  if (TokenAt(i + 1).Kind = TTokenKind.OPARTOK) then        // Actual parameter list found
  begin

    if (TokenAt(i + 2).Kind = TTokenKind.CPARTOK) then
      Inc(i)
    else
      //repeat

      while NumActualParams > 0 do
      begin

        //       Inc(NumActualParams);

        //       if NumActualParams > IdentifierAt(IdentIndex).NumParams then
        //        if ProcVarIndex > 0 then
        //   Error(i, WrongNumParameters, ProcVarIndex)
        //  else
        //   Error(i, WrongNumParameters, IdentIndex);

        i := Param[NumActualParams].i;

        if (IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod = TParameterPassingMethod.VARPASSING) then
        begin

          i := CompileAddress(i + 1, ActualParamType, AllocElementType, True);

          //  writeln(IdentifierAt(IdentIndex).Param[NumActualParams].Name,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType  ,',',IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements and $FFFF,'/',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements shr 16,' | ',ActualParamType,',', AllocElementType);


          if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> TDataType.UNTYPETOK) and
            (ActualParamType = TDataType.POINTERTOK) and (AllocElementType in
            [TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK, TDataType.PCHARTOK]) then
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :STACKORIGIN,x');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

          end;

          if AllocElementType = TDataType.ARRAYTOK then
          begin
            AllocElementType := TDataType.POINTERTOK;
          end;

          if TokenAt(i).Kind = TTokenKind.IDENTTOK then
            IdentTemp := GetIdentIndex(TokenAt(i).Name)
          else
            IdentTemp := 0;

          if IdentTemp > 0 then
          begin

            if IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK then Error(i, TErrorCode.CantAdrConstantExp);
            // TParameterPassingMethod.VARPASSING function not possible


            //  writeln(' - ',TokenAt(i).Name,',',ActualParamType,',',AllocElementType, ',', IdentifierAt(IdentTemp).NumAllocElements );
            //  writeln(IdentifierAt(IdentTemp).Kind,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

            if IdentifierAt(IdentTemp).DataType in Pointers then
              if not (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
                [TDataType.FILETOK, TDataType.TEXTFILETOK]) then
              begin

{
 writeln('--- ',IdentifierAt(IdentIndex).Name);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',', IdentifierAt(IdentTemp).DataType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',', IdentifierAt(IdentTemp).NumAllocElements);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod,',', IdentifierAt(IdentTemp).PassMethod);
}

                if IdentifierAt(IdentTemp).PassMethod <> TParameterPassingMethod.VARPASSING then

                  if IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
                    [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                    Error(i, TMessage.Create(TErrorCode.IncompatibleTypes,
                      'Incompatible types: got "{0}" expected "^{1}".',
                      GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name,
                      GetTypeAtIndex(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements).Field[0].Name))
                  else
                    GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType,
                      IdentifierAt(IdentTemp).DataType);

              end;



            if (IdentifierAt(IdentTemp).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])
            {and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK])}
            then
              if (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements > 0) and
                (IdentifierAt(IdentTemp).NumAllocElements <> IdentifierAt(
                IdentIndex).Param[NumActualParams].NumAllocElements) then
              begin

                if IdentifierAt(IdentTemp).PassMethod <> IdentifierAt(
                  IdentIndex).Param[NumActualParams].PassMethod then
                  Error(i, TErrorCode.CantAdrConstantExp)
                else
                  ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentTemp);
              end;


            if (IdentifierAt(IdentTemp).AllocElementType = TDataType.UNTYPETOK) then
            begin

              GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType,
                IdentifierAt(IdentTemp).DataType);

              if (IdentifierAt(IdentTemp).AllocElementType = TDataType.UNTYPETOK) then
                if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> TDataType.UNTYPETOK) and
                  (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> IdentifierAt(IdentTemp).DataType) then
                  ErrorIncompatibleTypes(i, IdentifierAt(IdentTemp).DataType,
                    IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

            end
            else
              if IdentifierAt(IdentIndex).Param[NumActualParams].DataType in Pointers then
              begin

                //     GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType, IdentifierAt(IdentTemp).AllocElementType);

                if (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements = 0) and
                  (IdentifierAt(IdentTemp).NumAllocElements = 0) then
                // ok ?
                else
                  if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <>
                    IdentifierAt(IdentTemp).AllocElementType then
                  begin

{
 writeln('--- ',IdentifierAt(IdentIndex).Name);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',', IdentifierAt(IdentTemp).DataType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,',', IdentifierAt(IdentTemp).AllocElementType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',', IdentifierAt(IdentTemp).NumAllocElements);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod,',', IdentifierAt(IdentTemp).PassMethod);
}

                    if (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType =
                      TDataType.UNTYPETOK) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
                      [TDataType.POINTERTOK, TDataType.PCHARTOK]) then
                    begin

                      if IdentifierAt(IdentTemp).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then

                      else
                        ErrorIdentifierIncompatibleTypesArray(i, IdentTemp,
                          IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

                    end
                    else
                      ErrorIncompatibleTypes(i, IdentifierAt(IdentTemp).AllocElementType,
                        IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType);

                  end;

              end
              else
                GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType,
                  IdentifierAt(IdentTemp).AllocElementType);

          end
          else
            if IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> TDataType.UNTYPETOK then
              if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> AllocElementType) then
              begin

                //  writeln(IdentifierAt(IdentIndex).name,',', IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType);

                if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> TDataType.UNTYPETOK then
                begin

                  if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> AllocElementType then
                    ErrorIncompatibleTypes(i, AllocElementType,
                      IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

                end
                else
                  ErrorIncompatibleTypes(i, AllocElementType,
                    IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

              end;


          //  Writeln('x ',IdentifierAt(IdentIndex).name,',', IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType,',',IdentTemp);


          if IdentTemp = 0 then
            if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.RECORDTOK) and
              (ActualParamType = TDataType.POINTERTOK) and (AllocElementType = TDataType.RECORDTOK) then

            else
              if (ActualParamType = TDataType.POINTERTOK) and (AllocElementType <> TDataType.UNTYPETOK) then
                GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, AllocElementType)
              else
                GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);

        end
        else
        begin

          if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.POINTERTOK) and
            (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements > 0) and not
            (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType in
            [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
            i := CompileAddress(i + 1, ActualParamType, AllocElementType)
          else
            i := CompileExpression(i + 2, ActualParamType, IdentifierAt(IdentIndex).Param[NumActualParams].DataType);
          // Evaluate actual parameters and push them onto the stack



          //  writeln(IdentifierAt(IdentIndex).name,',', IdentifierAt(IdentIndex).kind,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',',IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType ,'|',ActualParamType);


          if (ActualParamType in IntegerTypes) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
            RealTypes) then
          begin

            AllocElementType := IdentifierAt(IdentIndex).Param[NumActualParams].DataType;

            RealTypeConversion(AllocElementType, ActualParamType);

          end;

          if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in IntegerTypes + RealTypes) and
            (ActualParamType in RealTypes) then
            GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);

          if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDatatype.POINTERTOK) then
            GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);

          if (TokenAt(i).Kind = IDENTTOK) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType =
            TDataType.ENUMTOK) then
          begin
            IdentTemp := GetIdentIndex(TokenAt(i).Name);

            if _TypeArray[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name <>
              _TypeArray[IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements].Field[0].Name then
              Error(i, 'Incompatible types: got "' +
                _TypeArray[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                '" expected "' + _TypeArray[IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements].Field[
                0].Name + '"');

            ActualParamType := IdentifierAt(IdentTemp).CastKindToDataType;

            //    writeln(IdentifierAt(IdentTemp).Kind,',', IdentifierAt(IdentTemp).NumAllocElements,'/', IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements, ',',Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].name);
          end;

          if (TokenAt(i).Kind = TTokenKind.IDENTTOK) and (ActualParamType in
            [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and not
            (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in Pointers) then
            if IdentifierAt(GetIdentIndex(TokenAt(i).Name)).isNestedFunction then
            begin

              if IdentifierAt(GetIdentIndex(TokenAt(i).Name)).NestedFunctionNumAllocElements <>
                IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements then
                ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, GetIdentIndex(TokenAt(i).Name));

            end
            else
              if IdentifierAt(GetIdentIndex(TokenAt(i).Name)).NumAllocElements <>
                IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements then
                ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, GetIdentIndex(TokenAt(i).Name));


          if ((ActualParamType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
            (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in Pointers)) or
            ((ActualParamType in Pointers) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
            [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then
            //  jesli wymagany jest POINTER a przekazujemy RECORD (lub na odwrot) to OK

          begin

            if (ActualParamType = TDataType.POINTERTOK) and (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
            begin
              IdentTemp := GetIdentIndex(TokenAt(i).Name);

              if (TokenAt(i - 1).Kind = TTokenKind.ADDRESSTOK) then
                AllocElementType := TDataType.UNTYPETOK
              else
                AllocElementType := IdentifierAt(IdentTemp).AllocElementType;

              if AllocElementType = TDataType.UNTYPETOK then
                ErrorIncompatibleTypes(i, ActualParamType, IdentifierAt(IdentIndex).Param[NumActualParams].DataType);
{
 writeln('--- ',IdentifierAt(IdentIndex).Name,',',ActualParamType,',',AllocElementType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',', IdentifierAt(IdentTemp).DataType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,',', IdentifierAt(IdentTemp).AllocElementType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',', IdentifierAt(IdentTemp).NumAllocElements);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod,',', IdentifierAt(IdentTemp).PassMethod);
}
            end
            else
              ErrorIncompatibleTypes(i, ActualParamType, IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

          end

          else
          begin

            if (ActualParamType = TDataType.POINTERTOK) and (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
            begin
              IdentTemp := GetIdentIndex(TokenAt(i).Name);

              if (TokenAt(i - 1).Kind = TTokenKind.ADDRESSTOK) then
                AllocElementType := TDataType.UNTYPETOK
              else
                AllocElementType := IdentifierAt(IdentTemp).AllocElementType;


              if (IdentifierAt(IdentTemp).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType)
              else
                if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> AllocElementType then
                begin

                  if (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType = TDataType.UNTYPETOK) and
                    (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.POINTERTOK) and
                    ({IdentifierAt(IdentIndex).Param[NumActualParams]} IdentifierAt(
                    IdentTemp).NumAllocElements > 0) then
                    ErrorIdentifierIncompatibleTypesArray(i, IdentTemp, TDataType.POINTERTOK)
                  else
                    if (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <>
                      TDataType.PROCVARTOK) and
                      (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements > 0) then
                      ErrorIncompatibleTypes(i, AllocElementType,
                        IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType);

                end;

            end
            else
              if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
                [TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK]) and (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
              begin
                IdentTemp := GetIdentIndex(TokenAt(i).Name);

                //  writeln('1 > ',IdentifierAt(IdentTemp).name,',', IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements,' | ',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements );

                if (IdentifierAt(IdentTemp).DataType = TDataType.STRINGPOINTERTOK) and
                  (IdentifierAt(IdentTemp).NumAllocElements <> 0) and
                  (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.POINTERTOK) and
                  (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements = 0) then
                  if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType = TDataType.UNTYPETOK then
                    ErrorIncompatibleTypes(i, IdentifierAt(IdentTemp).DataType,
                      IdentifierAt(IdentIndex).Param[NumActualParams].DataType)
                  else
                    if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> TDataType.BYTETOK then
                      // Exceptionally we accept PBYTE as STRING
                      ErrorIncompatibleTypes(i, IdentifierAt(IdentTemp).DataType,
                        IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType, True);

{
        if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.PCHARTOK) then begin

          if IdentifierAt(IdentTemp).DataType = TDataType.STRINGPOINTERTOK then begin
            asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'add #$01');
            asm65(#9'sta :STACKORIGIN,x');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'adc #$00');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
    end;

        end;
}

                GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType,
                  IdentifierAt(IdentTemp).DataType);

              end
              else
              begin

                //  writeln('2 > ',IdentifierAt(IdentIndex).Name,',',ActualParamType,',',AllocElementType,',',TokenAt(i).Kind,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements);

                if (ActualParamType = TDataType.POINTERTOK) and
                  (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.STRINGPOINTERTOK) then
                  ErrorIncompatibleTypes(i, ActualParamType, TDataType.STRINGPOINTERTOK, True);

                if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.STRINGPOINTERTOK) then
                begin    // CHAR -> STRING

                  if (ActualParamType = TDataType.CHARTOK) and (TokenAt(i).Kind = TTokenKind.CHARLITERALTOK) then
                  begin

                    ActualParamType := TDataType.STRINGPOINTERTOK;

                    if Pass = TPass.CODE_GENERATION then
                    begin
                      DefineStaticString(i, chr(TokenAt(i).Value));
                      TokenAt(i).Kind := TTokenKind.STRINGLITERALTOK;

                      asm65(#9'lda :STACKORIGIN,x');
                      asm65(#9'sta :STACKORIGIN,x');
                      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                      asm65(#9'lda <CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN, 4));
                      asm65(#9'sta :STACKORIGIN,x');
                      asm65(#9'lda >CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN, 4));
                      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                    end;

                  end;

                end;


                if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = TDataType.PCHARTOK) then
                begin

                  if (ActualParamType = TDataType.STRINGPOINTERTOK) then
                  begin
                    asm65(#9'lda :STACKORIGIN,x');
                    asm65(#9'add #$01');
                    asm65(#9'sta :STACKORIGIN,x');
                    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'adc #$00');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                  end;


                  if (ActualParamType = TDataType.CHARTOK) and (TokenAt(i).Kind = TTokenKind.CHARLITERALTOK) then
                  begin

                    ActualParamType := TDataType.PCHARTOK;

                    if Pass = TPass.CODE_GENERATION then
                    begin
                      DefineStaticString(i, chr(TokenAt(i).Value));
                      TokenAt(i).Kind := TTokenKind.STRINGLITERALTOK;

                      asm65(#9'lda :STACKORIGIN,x');
                      asm65(#9'sta :STACKORIGIN,x');
                      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                      asm65(#9'lda <CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN + 1, 4));
                      asm65(#9'sta :STACKORIGIN,x');
                      asm65(#9'lda >CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN + 1, 4));
                      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                    end;

                  end;

                end;

                // GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);

              end;

          end;

          ExpandParam(IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);
        end;



        if (IdentifierAt(IdentIndex).isRecursion = False) and (IdentifierAt(IdentIndex).isStdCall = False) and
          (ParamIndex > 1) and (IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod <>
          TParameterPassingMethod.VARPASSING) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
          [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
          (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements and $FFFF > 1) then

          if IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
            [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
          begin

            if IdentifierAt(IdentIndex).isOverload then
              svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
            else
              svar := GetLocalName(IdentIndex);

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');

            j := RecordSize(GetIdentIndex(
              GetTypeAtIndex(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements).Field[0].Name));

            //  writeln('1: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).Kind ,',',  IdentifierAt(IdentIndex).Param[NumActualParams].name,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',j);

            if j = 256 then
            begin
              asm65(#9'ldy #$00');
              ;
              asm65(#9'mva:rne (:bp2),y ' + svar + '.adr.' + IdentifierAt(
                IdentIndex).Param[NumActualParams].Name + ',y+');
            end
            else
              if j <= 128 then
              begin
                asm65(#9'ldy #$' + IntToHex(j - 1, 2));
                asm65(#9'mva:rpl (:bp2),y ' + svar + '.adr.' + IdentifierAt(
                  IdentIndex).Param[NumActualParams].Name + ',y-');
              end
              else
                asm65(#9'@move ":bp2" #' + svar + '.adr.' + IdentifierAt(IdentIndex).Param[NumActualParams].Name +
                  ' #' + IntToStr(j));

          end
          else
            if not (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType in
              [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
            begin

              if IdentifierAt(IdentIndex).isOverload then
                svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
              else
                svar := GetLocalName(IdentIndex);

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta :bp2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :bp2+1');

              if IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements shr 16 <> 0 then
                j := (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements and $FFFF) *
                  (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements shr 16)
              else
                j := IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements;

              j := j * GetDataSize(IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType);

              //  writeln('2: ',IdentifierAt(IdentIndex).isStdCall ,',',IdentifierAt(IdentIndex).NumAllocElements,',',  IdentifierAt(IdentIndex).Param[NumActualParams].name,',',IdentifierAt(IdentIndex).Param[0].AllocElementType,',',j);

              if j = 256 then
              begin
                asm65(#9'ldy #$00');
                ;
                asm65(#9'mva:rne (:bp2),y ' + svar + '.adr.' + IdentifierAt(
                  IdentIndex).Param[NumActualParams].Name + ',y+');
              end
              else
                if j <= 128 then
                begin
                  asm65(#9'ldy #$' + IntToHex(j - 1, 2));
                  asm65(#9'mva:rpl (:bp2),y ' + svar + '.adr.' +
                    IdentifierAt(IdentIndex).Param[NumActualParams].Name + ',y-');
                end
                else
                  asm65(#9'@move ":bp2" #' + svar + '.adr.' + IdentifierAt(IdentIndex).Param[NumActualParams].Name +
                    ' #' + IntToStr(j));

            end;


        Dec(NumActualParams);
      end;

    //until TokenAt(i + 1).Kind <> TTokenKind.COMMATOK;

    i := Param[1].i_;

    CheckTok(i + 1, TTokenKind.CPARTOK);

    Inc(i);
  end;// if TokenAt(i + 1).Kind = OPARTOR


  NumActualParams := ParamIndex;


  //writeln(IdentifierAt(IdentIndex).name,',',NumActualParams,',',IdentifierAt(IdentIndex).isUnresolvedForward ,',',IdentifierAt(IdentIndex).isRecursion );


  if Pass = TPass.CALL_DETERMINATION then                      // issue #103 fixed
    if IdentifierAt(IdentIndex).isUnresolvedForward then

      IdentifierAt(IdentIndex).updateResolvedForward := True
    else
      AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(IdentIndex).ProcAsBlock);


  (*------------------------------------------------------------------------------------------------------------*)

  // if IdentifierAt(IdentIndex).isUnresolvedForward then begin
  //   Error(i, 'Unresolved forward declaration of ' + IdentifierAt(IdentIndex).Name);

{
 if (IdentifierAt(IdentIndex).isExternal) and (IdentifierAt(IdentIndex).Libraries > 0) then begin

  if IdentifierAt(IdentIndex).isOverload then
   svar := IdentifierAt(IdentIndex).Alias+ '.' + GetOverloadName(IdentIndex)
  else
   svar := GetLocalName(IdentIndex) + '.' + IdentifierAt(IdentIndex).Alias;

 end else
}



  if IdentifierAt(IdentIndex).isOverload then
    svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
  else
    svar := GetLocalName(IdentIndex);


  if RCLIBRARY and IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) and
    (IdentifierAt(IdentIndex).isStdCall = False) then
  begin

    asm65('#lib:' + svar);

  end;


  if (yes = False) and (IdentifierAt(IdentIndex).NumParams > 0) then
  begin

    for ParamIndex := 1 to NumActualParams do
    begin

      ActualParamType := IdentifierAt(IdentIndex).Param[ParamIndex].DataType;
      if ActualParamType = TDataType.ENUMTOK then
        ActualParamType := IdentifierAt(IdentIndex).Param[ParamIndex].AllocElementType;

      if IdentifierAt(IdentIndex).Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then
      begin

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+1');

        a65(TCode65.subBX);
      end
      else
        if (NumActualParams = 1) and (GetDataSize(ActualParamType) = 1) then
        begin      // only ONE parameter SIZE = 1

          if IdentifierAt(IdentIndex).ObjectIndex > 0 then
          begin
            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
            a65(TCode65.subBX);
          end
          else
          begin
            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @PARAM?');
            a65(TCode65.subBX);
          end;

        end
        else
          case ActualParamType of

            TDataType.BYTETOK, TDataType.CHARTOK, TDataType.BOOLEANTOK, TDataType.SHORTINTTOK:
            begin
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);

              a65(TCode65.subBX);
            end;

            TDataType.WORDTOK, TDataType.SMALLINTTOK, TDataType.SHORTREALTOK, TDataType.HALFSINGLETOK,
            TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK, TDataType.PCHARTOK:
            begin
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+1');

              a65(TCode65.subBX);
            end;

            TDataType.CARDINALTOK, TDataType.INTEGERTOK, TDataType.REALTOK, TDataType.SINGLETOK:
            begin
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+1');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+3');

              a65(TCode65.subBX);
            end;

            else
              Error(i, TMessage.Create(TErrorCode.Unassigned, 'Unassigned: {0}',
                InfoAboutDataType(ActualParamType)));
          end;
    end;


    old_func := run_func;
    run_func := 0;

    if (IdentifierAt(IdentIndex).isStdCall = False) then
      if IdentifierAt(IdentIndex).Kind = TTokenKind.FUNCTIONTOK then
        StartOptimization(i)
      else
        StopOptimization;
    run_func := old_func;

  end;

  Gen;


  (*------------------------------------------------------------------------------------------------------------*)

  if IdentifierAt(IdentIndex).ObjectIndex > 0 then
  begin

    if TokenAt(old_i).Kind <> TTokenKind.IDENTTOK then
      Error(old_i, TErrorCode.IdentifierExpected)
    else
      IdentTemp := GetIdentIndex(copy(TokenAt(old_i).Name, 1, pos('.', TokenAt(old_i).Name) - 1));

    asm65(#9'lda ' + GetLocalName(IdentTemp));
    asm65(#9'ldy ' + GetLocalName(IdentTemp) + '+1');
  end;

  (*------------------------------------------------------------------------------------------------------------*)


  if IdentifierAt(IdentIndex).isInline then
  begin

    // if pass = CODE_GENERATION then
    //    writeln(svar,',', IdentifierAt(IdentIndex).ProcAsBlock,',', BlockStack[BlockStackTop], ',' ,IdentifierAt(IdentIndex).Block ,',', IdentifierAt(IdentIndex).UnitIndex );

    //  asm65(#9'.LOCAL ' + svar);


    if (IdentifierAt(IdentIndex).Block > 1) and (IdentifierAt(IdentIndex).Block <> BlockStack[BlockStackTop]) then
      // issue #102 fixed
      for IdentTemp := NumIdent downto 1 do
        if (IdentifierAt(IdentTemp).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK]) and
          (IdentifierAt(IdentTemp).ProcAsBlock = IdentifierAt(IdentIndex).Block) then
        begin
          svar := IdentifierAt(IdentTemp).Name + '.' + svar;
          Break;
        end;


    if (BlockStack[BlockStackTop] <> 1) and (IdentifierAt(IdentIndex).Block = BlockStack[BlockStackTop]) then
      // w aktualnym bloku procedury/funkcji
      asm65(#9'.LOCAL ' + svar)
    else

      if (IdentifierAt(IdentIndex).SourceFile.UnitIndex > 1) and
        (IdentifierAt(IdentIndex).SourceFile.UnitIndex <> ActiveSourceFile.UnitIndex) and
        IdentifierAt(IdentIndex).Section then
        asm65(#9'.LOCAL +MAIN.' + svar)
      // w tym samym module poza aktualnym blokiem procedury/funkcji
      else
        if (IdentifierAt(IdentIndex).SourceFile.UnitIndex > 1) then
          asm65(#9'.LOCAL +MAIN.' + IdentifierAt(IdentIndex).SourceFile.Name + '.' + svar)      // w innym module
        else
          asm65(#9'.LOCAL +MAIN.' + svar);
    // w tym samym module poza aktualnym blokiem procedury/funkcji

{
  if IdentifierAt(IdentIndex).SourceFile.UnitIndex > 1 then
   asm65(#9'.LOCAL +MAIN.' + IdentifierAt(IdentIndex).SourceFile.Name + '.' + svar)      // w innym module
  else
   asm65(#9'.LOCAL +MAIN.' + svar);                  // w tym samym module poza aktualnym blokiem procedury/funkcji
}

    asm65(#9 + 'm@INLINE');
    asm65(#9'.ENDL');

    resetOpty;

  end
  else
  begin

    if ProcVarIndex > 0 then
    begin

      if (IdentifierAt(ProcVarIndex).isAbsolute) and (IdentifierAt(ProcVarIndex).NumAllocElements = 0) then
      begin

        asm65(#9'jsr *+6');
        asm65(#9'jmp *+6');
        asm65(#9'jmp (' + GetLocalName(ProcVarIndex) + ')');

      end
      else
        asm65(#9'jsr :TMP');

    end
    else
      if RCLIBRARY and IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) and
        IdentifierAt(IdentIndex).isStdCall then
      begin

        asm65(#9'ldy <' + svar + '.@INITLIBRARY');
        asm65(#9'sty @xmsProc.ini');
        asm65(#9'ldy >' + svar + '.@INITLIBRARY');
        asm65(#9'sty @xmsProc.ini+1');

        asm65(#9'ldy <' + svar);
        asm65(#9'sty @xmsProc.prc');
        asm65(#9'ldy >' + svar);
        asm65(#9'sty @xmsProc.prc+1');

        asm65(#9'ldy #=' + svar);
        asm65(#9'jsr @xmsProc');

      end
      else
        asm65(#9'jsr ' + svar);        // Generate Call

  end;

  //writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).Kind,',',IdentifierAt(IdentIndex).isStdCall,',',IdentifierAt(IdentIndex).isRecursion);

  if (IdentifierAt(IdentIndex).Kind = TTokenKind.FUNCTIONTOK) and (IdentifierAt(IdentIndex).isStdCall = False) and
    (IdentifierAt(IdentIndex).isRecursion = False) then
  begin

    asm65(#9'inx');

    ActualParamType := IdentifierAt(IdentIndex).DataType;
    if ActualParamType = TDataType.ENUMTOK then
      ActualParamType := IdentifierAt(IdentIndex).NestedFunctionAllocElementType;

    case GetDataSize(ActualParamType) of

      1: begin
        asm65(#9'mva ' + svar + '.RESULT :STACKORIGIN,x');
      end;

      2: begin
        asm65(#9'mva ' + svar + '.RESULT :STACKORIGIN,x');
        asm65(#9'mva ' + svar + '.RESULT+1 :STACKORIGIN+STACKWIDTH,x');
      end;

      4: begin
        asm65(#9'mva ' + svar + '.RESULT :STACKORIGIN,x');
        asm65(#9'mva ' + svar + '.RESULT+1 :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'mva ' + svar + '.RESULT+2 :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'mva ' + svar + '.RESULT+3 :STACKORIGIN+STACKWIDTH*3,x');
      end;

    end;

  end;


  if RCLIBRARY and IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) and
    (IdentifierAt(IdentIndex).isStdCall = False) then
  begin

    asm65(#9'pla');
    asm65(#9'sta portb');

  end;

end;  //CompileActualParameters


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileFactor(i: Integer; out isZero: Boolean; out ValType: TDataType;
  VarType: TDataType = TDataType.INTEGERTOK): Integer;
var
  IdentTemp, IdentIndex, oldCodeSize, j: Integer;
  ActualParamType: TDataType;
  AllocElementType: TDataType;
  IndirectionLevel: TIndirectionLevel;
  Kind: TTokenKind;
  oldPass: TPass;
  yes: Boolean;
  Value, ConstVal: Int64;
  svar, lab: String;
  Param: TParamList;
begin

  isZero := False;

  Result := i;

  ValType := TDataType.UNTYPETOK;
  ConstVal := 0;
  IdentIndex := 0;

  // WRITELN(TokenAt(i).line, ',', TokenAt(i).kind);

  case TokenAt(i).Kind of

    TTokenKind.HIGHTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 2).GetDataType in AllTypes {+ [TDataType.STRINGTOK]} then
      begin

        ValType := TokenAt(i + 2).GetDataType;

        j := i + 2;

      end
      else
      begin

        oldPass := pass;
        oldCodeSize := CodeSize;
        Pass := TPass.CALL_DETERMINATION;

        j := CompileExpression(i + 2, ValType);

        Pass := oldPass;
        CodeSize := oldCodeSize;

      end;
{
      if ValType = TDataType.ENUMTOK then begin

       if TokenAt(j].Kind = TTokenKind.IDENTTOK then
  IdentIndex := GetIdentIndex(TokenAt(j].Name)
       else
   Error(i, TypeMismatch);

       if IdentIndex = 0 then Error(i, TypeMismatch);

       IdentTemp := GetIdentIndex(GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).NumFields].Name);

       if IdentifierAt(IdentTemp).NumAllocElements = 0 then Error(i, TypeMismatch);

       Push(IdentifierAt(IdentTemp).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentTemp);

       GenerateWriteString(IdentifierAt(IdentTemp).Value, ASPOINTERTOPOINTER, IdentifierAt(IdentTemp).DataType, IdentTemp)

      end else begin
}
      if ValType in Pointers then
      begin
        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

        if IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
          Value := IdentifierAt(IdentIndex).NumAllocElements_ - 1
        else
          if IdentifierAt(IdentIndex).NumAllocElements > 0 then
            Value := IdentifierAt(IdentIndex).NumAllocElements - 1
          else
            Value := HighBound(j, IdentifierAt(IdentIndex).AllocElementType);

      end
      else
        Value := HighBound(j, ValType);

      ValType := GetValueType(Value);

      if IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK then
      begin
        a65(TCode65.addBX);
        asm65(#9'lda adr.' + GetLocalName(IdentIndex));
        asm65(#9'sta :STACKORIGIN,x');

        ValType := TDataType.BYTETOK;
      end
      else
        Push(Value, ASVALUE, GetDataSize(ValType));

      //     end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      Result := j + 1;
    end;


    TTokenKind.LOWTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := TPass.CALL_DETERMINATION;

      //      j := i + 2;

      i := CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

{
      if ValType = TDataType.ENUMTOK then begin

       if TokenAt(j].Kind = TTokenKind.IDENTTOK then
  IdentIndex := GetIdentIndex(TokenAt(j).Name)
       else
   Error(i, TypeMismatch);

       if IdentIndex = 0 then Error(i, TypeMismatch);

       IdentTemp := GetIdentIndex(GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[1].Name);

       if IdentifierAt(IdentTemp).NumAllocElements = 0 then Error(i, TypeMismatch);

       ValType := TDataType.ENUMTOK;
       Push(IdentifierAt(IdentTemp).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentTemp);

       GenerateWriteString(IdentifierAt(IdentTemp).Value, ASPOINTERTOPOINTER, IdentifierAt(IdentTemp).DataType, IdentTemp)

      end else begin
}

      if ValType in Pointers then
      begin
        Value := 0;

        if ValType = TDataType.STRINGPOINTERTOK then Value := 1;

      end
      else
        Value := LowBound(i, ValType);

      ValType := GetValueType(Value);

      Push(Value, ASVALUE, GetDataSize(ValType));

      //      end;

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Result := i + 1;
    end;


    TTokenKind.SIZEOFTOK:
    begin
      Value := 0;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 2).GetDataType in OrdinalTypes + RealTypes + [TDataType.POINTERTOK] then
      begin

        Value := GetDataSize(TokenAt(i + 2).GetDataType);

        ValType := TDataType.BYTETOK;

        j := i + 2;

      end
      else
      begin

        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected);

        oldPass := Pass;
        oldCodeSize := CodeSize;
        Pass := TPass.CALL_DETERMINATION;

        j := CompileExpression(i + 2, ValType);

        Pass := oldPass;
        CodeSize := oldCodeSize;

        Value := GetSizeof(i, ValType);

        ValType := GetValueType(Value);

      end;  // if TokenAt(i + 2).Kind in


      Push(Value, ASVALUE, GetDataSize(ValType));

      CheckTok(j + 1, TTokenKind.CPARTOK);

      Result := j + 1;

    end;


    TTokenKind.LENGTHTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      Value := 0;


      if TokenAt(i + 2).Kind = TTokenKind.CHARLITERALTOK then
      begin

        Push(1, ASVALUE, 1);

        ValType := TDataType.BYTETOK;

        Inc(i, 2);

      end
      else
        if TokenAt(i + 2).Kind = TTokenKind.STRINGLITERALTOK then
        begin

          Push(TokenAt(i + 2).StrLength, ASVALUE, 1);

          ValType := TDataType.BYTETOK;

          Inc(i, 2);

        end
        else

          if TokenAt(i + 2).Kind = TTokenKind.IDENTTOK then
          begin

            IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

            if IdentIndex = 0 then
              Error(i + 2, TErrorCode.UnknownIdentifier);

            //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).AllocElementType );


            if IdentifierAt(IdentIndex).Kind in [TTokenKind.VARTOK, TTokenKind.CONSTTOK] then
            begin

              if IdentifierAt(IdentIndex).DataType = TDataType.CHARTOK then
              begin          // length(CHAR) = 1

                Push(1, ASVALUE, 1);

                ValType := TDataType.BYTETOK;

              end
              else

                if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                  (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                begin

                  i := CompileArrayIndex(i + 2, IdentIndex, ValType);            // array[ ].field

                  CheckTok(i + 2, TTokenKind.DOTTOK);
                  CheckTok(i + 3, TTokenKind.IDENTTOK);

                  IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);

                  if IdentTemp < 0 then
                    Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                      'Identifier idents no member ''{0}''.', TokenAt(i + 3).Name));

                  //       ValType := IdentifierAt(GetIdentIndex(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name)].AllocElementType;


                  if TTokenKind(IdentTemp shr 16) = TTokenKind.CHARTOK then
                  begin

                    a65(TCode65.subBX);

                    Push(1, ASVALUE, 1);

                  end
                  else
                  begin

                    if TTokenKind(IdentTemp shr 16) <> TTokenKind.STRINGPOINTERTOK then
                      Error(i + 1, TErrorCode.TypeMismatch);

                    Push(0, ASVALUE, 1);

                    Push(1, ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN, 1, IdentIndex, IdentTemp and $ffff);

                  end;

                  ValType := TDataType.BYTETOK;

                  Inc(i);

                end
                else

                  if (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) or
                    ((IdentifierAt(IdentIndex).DataType in Pointers) and
                    (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
                  begin

                    if ((IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) or
                      (IdentifierAt(IdentIndex).AllocElementType = TDataType.CHARTOK)) or
                      ((IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                      (IdentifierAt(IdentIndex).AllocElementType = TDataType.STRINGPOINTERTOK)) then
                    begin

                      if IdentifierAt(IdentIndex).AllocElementType = TDataType.STRINGPOINTERTOK then
                      begin    // length(array[x])

                        i := CompileArrayIndex(i + 2, IdentIndex, ValType);

                        a65(TCode65.addBX);

                        svar := GetLocalName(IdentIndex);

                        if (IdentifierAt(IdentIndex).NumAllocElements * 2 > 256) or
                          (IdentifierAt(IdentIndex).NumAllocElements in [0, 1]) or
                          (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING)
                        then
                        begin

                          asm65(#9'lda ' + svar);
                          asm65(#9'add :STACKORIGIN-1,x');
                          asm65(#9'sta :bp2');
                          asm65(#9'lda ' + svar + '+1');
                          asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                          asm65(#9'sta :bp2+1');

                          asm65(#9'ldy #$01');
                          asm65(#9'lda (:bp2),y');
                          asm65(#9'sta :bp+1');
                          asm65(#9'dey');
                          asm65(#9'lda (:bp2),y');
                          asm65(#9'tay');

                        end
                        else
                        begin

                          svar := GetLocalName(IdentIndex, 'adr.');

                          asm65(#9'ldy :STACKORIGIN-1,x');
                          asm65(#9'lda ' + svar + '+1,y');
                          asm65(#9'sta :bp+1');
                          asm65(#9'lda ' + svar + ',y');
                          asm65(#9'tay');

                        end;

                        a65(TCode65.subBX);

                        asm65(#9'lda (:bp),y');
                        asm65(#9'sta :STACKORIGIN,x');

                        CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                        CheckTok(i + 2, TTokenKind.CPARTOK);

                        ValType := TDataType.BYTETOK;

                        Result := i + 2;
                        exit;

                      end
                      else
                        if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) or
                          (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                        begin
                          a65(TCode65.addBX);

                          svar := GetLocalName(IdentIndex);

                          if TestName(IdentIndex, svar) then
                          begin

                            lab := ExtractName(IdentIndex, svar);

                            if IdentifierAt(GetIdentIndex(lab)).AllocElementType = TDataType.RECORDTOK then
                            begin
                              asm65(#9'lda ' + lab);
                              asm65(#9'ldy ' + lab + '+1');
                              asm65(#9'add #' + svar + '-DATAORIGIN');
                              asm65(#9'scc');
                              asm65(#9'iny');
                            end
                            else
                            begin
                              asm65(#9'lda ' + svar);
                              asm65(#9'ldy ' + svar + '+1');
                            end;

                          end
                          else
                          begin
                            asm65(#9'lda ' + svar);
                            asm65(#9'ldy ' + svar + '+1');
                          end;

                          asm65(#9'sty :bp+1');
                          asm65(#9'tay');

                          asm65(#9'lda (:bp),y');
                          asm65(#9'sta :STACKORIGIN,x');

                        end
                        else
                        begin
                          a65(TCode65.addBX);

                          asm65(#9'lda ' + GetLocalName(IdentIndex, 'adr.'));
                          asm65(#9'sta :STACKORIGIN,x');

                        end;

                      ValType := TDataType.BYTETOK;

                    end
                    else
                    begin

                      if TokenAt(i + 3).Kind = TTokenKind.OBRACKETTOK then

                        Error(i + 2, TErrorCode.TypeMismatch)

                      else
                      begin

                        Value := IdentifierAt(IdentIndex).NumAllocElements;

                        ValType := GetValueType(Value);
                        Push(Value, ASVALUE, GetDataSize(ValType));

                      end;

                    end;

                  end
                  else
                    Error(i + 2, TErrorCode.TypeMismatch);

            end
            else
              Error(i + 2, TErrorCode.IdentifierExpected);

            Inc(i, 2);
          end
          else
            Error(i + 2, TErrorCode.IdentifierExpected);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Result := i + 1;
    end;


    TTokenKind.LOTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);
      GetCommonConstType(i, TDataType.INTEGERTOK, ActualParamType);

      if GetDataSize(ActualParamType) > 2 then WarningLoHi(i);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      // asm65;
      // asm65('; Lo(X)');

      case ActualParamType of
        TDataType.SHORTINTTOK, TDataType.BYTETOK:
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'and #$0F');
          asm65(#9'sta :STACKORIGIN,x');
        end;
      end;

      if ActualParamType in [TDataType.INTEGERTOK, TDataType.CARDINALTOK] then
        ValType := TDataType.WORDTOK
      else
        ValType := TDataType.BYTETOK;

      Result := i + 1;
    end;


    TTokenKind.HITOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);
      GetCommonConstType(i, TDataType.INTEGERTOK, ActualParamType);

      if GetDataSize(ActualParamType) > 2 then WarningLoHi(i);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      // asm65;
      // asm65('; Hi(X)');

      case ActualParamType of
        TDataType.SHORTINTTOK, TDataType.BYTETOK: asm65(#9'jsr @hiBYTE');
        TDataType.SMALLINTTOK, TDataType.WORDTOK: asm65(#9'jsr @hiWORD');
        TDataType.INTEGERTOK, TDataType.CARDINALTOK: asm65(#9'jsr @hiCARD');
      end;

      if ActualParamType in [TDataType.INTEGERTOK, TDataType.CARDINALTOK] then
        ValType := TDataType.WORDTOK
      else
        ValType := TDataType.BYTETOK;

      Result := i + 1;
    end;


    TTokenKind.CHRTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType, TDataType.BYTETOK);
      GetCommonConstType(i, TDataType.INTEGERTOK, ActualParamType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      ValType := TDataType.CHARTOK;
      Result := i + 1;
    end;


    TTokenKind.INTTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);

      if not (ActualParamType in RealTypes) then
        ErrorIncompatibleTypes(i + 2, ActualParamType, TDataType.REALTOK);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      case ActualParamType of

        TDataType.SHORTREALTOK: asm65(#9'jsr @INT_SHORT');

        TDataType.REALTOK: asm65(#9'jsr @INT');

        TDataType.HALFSINGLETOK:
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta @F16_INT.A');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta @F16_INT.A+1');

          asm65(#9'jsr @F16_INT');
          asm65(#9'jsr @F16_I2F');

          asm65(#9'lda :eax');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :eax+1');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
        end;

        TDataType.SINGLETOK:
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :FPMAN0');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :FPMAN1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :FPMAN2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :FPMAN3');

          asm65(#9'jsr @F2I');
          asm65(#9'jsr @I2F');

          asm65(#9'lda :FPMAN0');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :FPMAN1');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'lda :FPMAN2');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :FPMAN3');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
        end;
      end;

      ValType := ActualParamType;
      Result := i + 1;
    end;


    TTokenKind.FRACTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);

      if not (ActualParamType in RealTypes) then
        ErrorIncompatibleTypes(i + 2, ActualParamType, TDataType.REALTOK);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      case ActualParamType of

        TDataType.SHORTREALTOK: asm65(#9'jsr @SHORTREAL_FRAC');

        TDataType.REALTOK:
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta @REAL_FRAC.A');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta @REAL_FRAC.A+1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta @REAL_FRAC.A+2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta @REAL_FRAC.A+3');

          asm65(#9'jsr @REAL_FRAC');

          asm65(#9'lda :eax');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :eax+1');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'lda :eax+2');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :eax+3');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
        end;

        TDataType.HALFSINGLETOK:
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta @F16_FRAC.A');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta @F16_FRAC.A+1');

          asm65(#9'jsr @F16_FRAC');

          asm65(#9'lda :eax');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :eax+1');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
        end;

        TDataType.SINGLETOK:
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :FPMAN0');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :FPMAN1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :FPMAN2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :FPMAN3');

          asm65(#9'jsr @FFRAC');

          asm65(#9'lda :FPMAN0');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :FPMAN1');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'lda :FPMAN2');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :FPMAN3');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
        end;

      end;

      ValType := ActualParamType;

      Result := i + 1;
    end;


    TTokenKind.TRUNCTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      if ActualParamType in IntegerTypes then
        ValType := ActualParamType
      else
        if ActualParamType in RealTypes then
        begin

          ValType := TDataType.INTEGERTOK;

          case ActualParamType of

            TDataType.SHORTREALTOK:
            begin
              //asm65(#9'jsr @SHORTREAL_TRUNC');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta @SHORTREAL_TRUNC.A');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta @SHORTREAL_TRUNC.A+1');

              asm65(#9'jsr @SHORTREAL_TRUNC');

              asm65(#9'lda :eax');
              asm65(#9'sta :STACKORIGIN,x');

              ValType := TDataType.SHORTINTTOK;
            end;

            TDataType.REALTOK:
            begin
              // asm65(#9'jsr @REAL_TRUNC');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta @REAL_TRUNC.A');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta @REAL_TRUNC.A+1');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta @REAL_TRUNC.A+2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta @REAL_TRUNC.A+3');

              asm65(#9'jsr @REAL_TRUNC');

              asm65(#9'lda :eax');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda :eax+1');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda :eax+2');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda :eax+3');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
            end;

            TDataType.HALFSINGLETOK:
            begin
              // asm65(#9'jsr @F16_INT');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta @F16_INT.A');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta @F16_INT.A+1');

              asm65(#9'jsr @F16_INT');

              asm65(#9'lda :eax');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda :eax+1');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda :eax+2');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda :eax+3');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
            end;

            TDataType.SINGLETOK:
            begin
              // asm65(#9'jsr @F2I');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta :FPMAN0');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :FPMAN1');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta :FPMAN2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta :FPMAN3');

              asm65(#9'jsr @F2I');

              asm65(#9'lda :FPMAN0');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda :FPMAN1');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda :FPMAN2');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda :FPMAN3');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
            end;

          end;

        end
        else
          GetCommonConstType(i, TDataType.REALTOK, ActualParamType);

      Result := i + 1;
    end;


    TTokenKind.ROUNDTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      if ActualParamType in IntegerTypes then
        ValType := ActualParamType
      else
        if ActualParamType in RealTypes then
        begin

          ValType := TDataType.INTEGERTOK;

          case ActualParamType of

            TDataType.SHORTREALTOK:
            begin

              asm65(#9'jsr @SHORTREAL_ROUND');

              ValType := TDataType.SHORTINTTOK;

            end;

            TDataType.REALTOK:
            begin

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta @REAL_ROUND.A');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta @REAL_ROUND.A+1');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta @REAL_ROUND.A+2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta @REAL_ROUND.A+3');

              asm65(#9'jsr @REAL_ROUND');

              asm65(#9'lda :eax');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda :eax+1');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda :eax+2');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda :eax+3');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            end;

            TDataType.HALFSINGLETOK:
            begin

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta @F16_ROUND.A');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta @F16_ROUND.A+1');

              asm65(#9'jsr @F16_ROUND');

              asm65(#9'lda :eax');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda :eax+1');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda :eax+2');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda :eax+3');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            end;

            TDataType.SINGLETOK:
            begin
              //asm65(#9'jsr @FROUND');

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta :FP2MAN0');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :FP2MAN1');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'sta :FP2MAN2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
              asm65(#9'sta :FP2MAN3');

              asm65(#9'jsr @FROUND');

              asm65(#9'lda :FPMAN0');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'lda :FPMAN1');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'lda :FPMAN2');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'lda :FPMAN3');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            end;

          end;

        end
        else
          GetCommonConstType(i, TDataType.REALTOK, ActualParamType);

      Result := i + 1;
    end;


    TTokenKind.ODDTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ActualParamType);
      GetCommonConstType(i, TDataType.CARDINALTOK, ActualParamType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'and #$01');
      asm65(#9'sta :STACKORIGIN,x');

      ValType := TDataType.BOOLEANTOK;
      Result := i + 1;
    end;


    TTokenKind.ORDTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      j := i + 2;

      i := CompileExpression(i + 2, ValType, TDataType.BYTETOK);

      if not (ValType in OrdinalTypes + [TDataType.ENUMTOK]) then
        Error(i, TErrorCode.OrdinalExpExpected);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      if ValType in [TDataType.CHARTOK, TDataType.BOOLEANTOK, TDataType.ENUMTOK] then
        ValType := TDataType.BYTETOK;

      Result := i + 1;
    end;


    TTokenKind.PREDTOK, TTokenKind.SUCCTOK:
    begin
      Kind := TokenAt(i).Kind;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ValType);

      if not (ValType in OrdinalTypes) then
        Error(i, TErrorCode.OrdinalExpExpected);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Push(1, ASVALUE, GetDataSize(ValType));

      if Kind = TTokenKind.PREDTOK then
        GenerateBinaryOperation(TTokenKind.MINUSTOK, ValType)
      else
        GenerateBinaryOperation(TTokenKind.PLUSTOK, ValType);

      Result := i + 1;
    end;


    TTokenKind.INTOK:
    begin

      writeln('IN');

{    CaseLocalCnt := CaseCnt;
    inc(CaseCnt);

    ResetOpty;

    StopOptimization;    // !!! potrzebujemy zachowac na stosie testowana wartosc

    i := CompileExpression(i + 1, SelectorType);

  if TokenAt(i).Kind = TTokenKind.IDENTTOK then
   EnumName := GetEnumName(GetIdentIndex(TokenAt(i).Name));


    if GetDataSize( TDataType.SelectorType]<>1 then
     Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, TTokenKind.OFTOK);

    GenerateCaseProlog;

    NumCaseStatements := 0;

    inc(i, 2);

    SetLength(CaseLabelArray, 1);

    repeat       // Loop over all cases

      repeat     // Loop over all constants for the current case
  i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

  GetCommonType(i, ConstValType, SelectorType);

  if (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
   if ((EnumName = '') and (GetEnumName(GetIdentIndex(TokenAt(i).Name)) <> '')) or
        ((EnumName <> '') and (GetEnumName(GetIdentIndex(TokenAt(i).Name)) <> EnumName)) then
    Error(i, 'Constant and CASE types do not match');

  if TokenAt(i + 1].Kind = TTokenKind.RANGETOK then              // Range check
    begin
    i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

    GetCommonType(i, ConstValType, SelectorType);

    if ConstVal > ConstVal2 then
     Error(i, 'Upper bound of case range is less than lower bound');

    GenerateCaseRangeCheck(ConstVal, ConstVal2, SelectorType);

    CaseLabel.left:=ConstVal;
    CaseLabel.right:=ConstVal2;
    end
  else begin
    GenerateCaseEqualityCheck(ConstVal, SelectorType);        // Equality check

    CaseLabel.left:=ConstVal;
    CaseLabel.right:=ConstVal;
  end;

  UpdateCaseLabels(i, CaseLabelArray, CaseLabel);

  inc(i);

  ExitLoop := FALSE;
  if TokenAt(i).Kind = TTokenKind.COMMATOK then
    inc(i)
  else
    ExitLoop := TRUE;
      until ExitLoop;


      CheckTok(i, TTokenKind.COLONTOK);

      GenerateCaseStatementProlog;

      ResetOpty;

      asm65('@');

      j := CompileStatement(i + 1);
      i := j + 1;
      GenerateCaseStatementEpilog(CaseLocalCnt);

      Inc(NumCaseStatements);

      ExitLoop := FALSE;
      if TokenAt(i).Kind <> TTokenKind.SEMICOLONTOK then
  begin
  if TokenAt(i).Kind = TTokenKind.ELSETOK then        // Default statements
    begin

    j := CompileStatement(i + 1);
    while TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

    i := j + 1;
    end;
  ExitLoop := TRUE;
  end
      else
  begin
  inc(i);

  if TokenAt(i).Kind = TTokenKind.ELSETOK then begin
    j := CompileStatement(i + 1);
    while TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

    i := j + 1;
  end;

  if TokenAt(i).Kind = TTokenKind.ENDTOK then ExitLoop := TRUE;

  end

    until ExitLoop;

    CheckTok(i, TTokenKind.ENDTOK);

    GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

}
      Result := i;
    end;


    TTokenKind.IDENTTOK:
    begin
      IdentIndex := GetIdentIndex(TokenAt(i).Name);

      if IdentIndex > 0 then
        if (IdentifierAt(IdentIndex).Kind = TTokenKind.TYPETOK) and (TokenAt(i + 1).Kind = TTokenKind.OPARTOK) then
        begin

          //    CheckTok(i + 1, TTokenKind.OPARTOK);

          if (IdentifierAt(IdentIndex).DataType = TDatatype.POINTERTOK) and (Elements(IdentIndex) > 0) then
          begin

            i := CompileAddress(i + 1, VarType, ValType);


            //writeln(IdentifierAt(IdentIndex).name, ',', IdentifierAt(IdentIndex).PassMethod,',',VarType,',',ValType);


            CheckTok(i + 1, CPARTOK);
            CheckTok(i + 2, OBRACKETTOK);

            i := CompileArrayIndex(i + 1, IdentIndex, AllocElementType);

            asm65(#9'lda :STACKORIGIN-1,x');
            asm65(#9'add :STACKORIGIN,x');
            asm65(#9'sta :STACKORIGIN-1,x');
            asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

            asm65(#9'dex');

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');
            asm65(#9'ldy #$00');
            // perl
            //     writeln(IdentifierAt(IdentIndex).name,',', GetDataSize(IdentifierAt(IdentIndex).AllocElementType],',', IdentifierAt(IdentIndex).AllocElementType ,',',ValType,',',VarType);

            ValType := IdentifierAt(IdentIndex).AllocElementType;

            case GetDataSize(ValType) of
              1: begin
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN,x');
              end;

              2: begin
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN,x');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              end;

              4: begin
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN,x');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
              end;

            end;

            exit(i + 1);
          end;

          j := CompileExpression(i + 2, ValType);


          if not (ValType in AllTypes) then
            Error(i, TErrorCode.TypeMismatch);


          if (ValType = TDataType.POINTERTOK) and not (IdentifierAt(IdentIndex).DataType in
            [TDataType.POINTERTOK, TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
          begin
            ValType := IdentifierAt(IdentIndex).DataType;

            if (TokenAt(i + 4).Kind = TTokenKind.DEREFERENCETOK) then exit(j + 2);
          end;


          if ValType in IntegerTypes then

            case IdentifierAt(IdentIndex).DataType of

              TDatatype.ENUMTOK:
              begin
                ValType := TDatatype.ENUMTOK;
              end;


              TDatatype.SHORTREALTOK:
              begin
                ExpandParam(TDatatype.SMALLINTTOK, ValType);

                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'lda #$00');
                asm65(#9'sta :STACKORIGIN,x');

                ValType := TDataType.SHORTREALTOK;
              end;


              TDatatype.REALTOK:
              begin
                ExpandParam(TDatatype.INTEGERTOK, ValType);

                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'lda #$00');
                asm65(#9'sta :STACKORIGIN,x');

                ValType := TDataType.REALTOK;
              end;


              TDatatype.HALFSINGLETOK:
              begin
                ExpandParam(TDatatype.INTEGERTOK, ValType);

                //asm65(#9'jsr @F16_I2F');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta @F16_I2F.SV');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta @F16_I2F.SV+1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta @F16_I2F.SV+2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta @F16_I2F.SV+3');

                asm65(#9'jsr @F16_I2F');

                asm65(#9'lda :eax');
                asm65(#9'sta :STACKORIGIN,x');
                asm65(#9'lda :eax+1');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                ValType := TDataType.HALFSINGLETOK;
              end;


              TDatatype.SINGLETOK:
              begin
                ExpandParam(TDatatype.INTEGERTOK, ValType);

                //asm65(#9'jsr @I2F');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta :FPMAN0');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta :FPMAN1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta :FPMAN2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta :FPMAN3');

                asm65(#9'jsr @I2F');

                asm65(#9'lda :FPMAN0');
                asm65(#9'sta :STACKORIGIN,x');
                asm65(#9'lda :FPMAN1');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'lda :FPMAN2');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'lda :FPMAN3');
                asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

                ValType := TDataType.SINGLETOK;
              end;

            end;

          CheckTok(j + 1, TTokenKind.CPARTOK);

          if (ValType = TDataType.POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType =
            TDataType.PROCVARTOK) then
          begin

            IdentTemp := GetIdentIndex('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

            if IdentifierAt(IdentTemp).IsNestedFunction = False then
              Error(j, TMessage.Create(TErrorCode.VariableConstantOrFunctionExpectedButProcedureFound,
                'Variable, constant or function name expected but procedure {0} found.',
                IdentifierAt(IdentIndex).Name));

            if TokenAt(j).Kind <> TTokenKind.IDENTTOK then Error(j, TErrorCode.VariableExpected);

            svar := GetLocalName(GetIdentIndex(TokenAt(j).Name));

            asm65(#9'lda ' + svar);
            asm65(#9'sta :TMP+1');
            asm65(#9'lda ' + svar + '+1');
            asm65(#9'sta :TMP+2');
            asm65(#9'lda #$4C');
            asm65(#9'sta :TMP');
            asm65(#9'jsr :TMP');

            ValType := IdentifierAt(IdentTemp).DataType;

          end
          else
            if ((ValType = TDataType.POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType in
              OrdinalTypes + RealTypes + [TDatatype.RECORDTOK, TDataType.OBJECTTOK])) or
              ((ValType = TDataType.POINTERTOK) and (IdentifierAt(IdentIndex).DataType in
              [TDatatype.RECORDTOK, TDataType.OBJECTTOK])) then
            begin

              yes := False;

              if (IdentifierAt(IdentIndex).DataType in [TDatatype.RECORDTOK, TDatatype.OBJECTTOK]) and
                (TokenAt(j).Kind = TTokenKind.DEREFERENCETOK) then yes := True;
              if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                (TokenAt(j + 2).Kind = TTokenKind.DEREFERENCETOK) then
                yes := True;

              //     yes := (TokenAt(j + 2).Kind = TTokenKind.DEREFERENCETOK);


              //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',TokenAt(j ].Kind,',',TokenAt(j + 1).Kind,',',TokenAt(j + 2).Kind);

              if (IdentifierAt(IdentIndex).AllocElementType in [TDatatype.RECORDTOK, TDatatype.OBJECTTOK]) or
                (IdentifierAt(IdentIndex).DataType in [TDatatype.RECORDTOK, TDatatype.OBJECTTOK]) then
              begin

                if TokenAt(j + 2).Kind = TTokenKind.DEREFERENCETOK then Inc(j);


                if TokenAt(j + 2).Kind <> TTokenKind.DOTTOK then yes := False
                else

                  if TokenAt(j + 2).Kind = TTokenKind.DOTTOK then
                  begin          // (pointer).field :=

                    CheckTok(j + 3, TTokenKind.IDENTTOK);
                    IdentTemp := RecordSize(IdentIndex, TokenAt(j + 3).Name);

                    if IdentTemp < 0 then
                      Error(j + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                        'Identifier idents no member ''{0}''.', TokenAt(j + 3).Name));

                    ValType := TDataType(IdentTemp shr 16);

                    asm65(#9'lda :STACKORIGIN,x');
                    asm65(#9'sta :bp2');
                    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'sta :bp2+1');
                    asm65(#9'ldy #$' + IntToHex(IdentTemp and $ffff, 2));

                    Inc(j, 2);
                  end;

              end
              else
                if TokenAt(j + 2).Kind = TTokenKind.DEREFERENCETOK then        // ASPOINTERTODEREFERENCE
                  if ValType = TDataType.POINTERTOK then
                  begin

                    asm65(#9'lda :STACKORIGIN,x');
                    asm65(#9'sta :bp2');
                    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'sta :bp2+1');
                    asm65(#9'ldy #$00');

                    ValType := IdentifierAt(IdentIndex).AllocElementType;

                    Inc(j);

                  end
                  else
                    Error(j + 2, TErrorCode.IllegalQualifier);


              if yes then
                case GetDataSize(ValType) of

                  1: begin
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN,x');
                  end;

                  2: begin
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN,x');
                    asm65(#9'iny');
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                  end;

                  4: begin
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN,x');
                    asm65(#9'iny');
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'iny');
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
                    asm65(#9'iny');
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
                  end;

                end;

            end;

          ExpandParam(IdentifierAt(IdentIndex).DataType, ValType);

          Result := j + 1;

        end
        else



          if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
            (IdentifierAt(IdentIndex).AllocElementType = TDataType.PROCVARTOK) then
          begin

            //        writeln('!! ',hexstr(IdentifierAt(IdentIndex).NumAllocElements_,8));

            IdentTemp := GetIdentIndex('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

            //  if IdentifierAt(IdentTemp).IsNestedFunction = FALSE then
            //   Error(i, 'Variable, constant or function name expected but procedure ' + IdentifierAt(IdentIndex).Name + ' found');


            if TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK then
            begin
              i := CompileArrayIndex(i, IdentIndex, ValType);

              CheckTok(i + 1, TTokenKind.CBRACKETTOK);

              Inc(i);
            end;


            if TokenAt(i + 1).Kind = TTokenKind.OPARTOK then

              CompileActualParameters(i, IdentTemp, IdentIndex)

            else
            begin

              if IdentifierAt(IdentIndex).NumAllocElements > 0 then
                Push(0, ASPOINTERTOARRAYORIGIN2, GetDataSize(TDataType.POINTERTOK), IdentIndex)
              else
                Push(0, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);

            end;

            ValType := TDataType.POINTERTOK;

            Result := i;

          end
          else

            if IdentifierAt(IdentIndex).Kind = TTokenKind.PROCEDURETOK then
              Error(i, TMessage.Create(TErrorCode.VariableConstantOrFunctionExpectedButProcedureFound,
                'Variable, constant or function name expected but procedure {0} found.',
                IdentifierAt(IdentIndex).Name))
            else if IdentifierAt(IdentIndex).Kind = TTokenKind.FUNCTIONTOK then       // Function call
              begin

                Param := NumActualParameters(i, IdentIndex, j);

                //    if IdentifierAt(IdentIndex).isOverload then begin
                IdentTemp := GetIdentProc(IdentifierAt(IdentIndex).Name, IdentIndex, Param, j);

                if IdentTemp = 0 then
                  if IdentifierAt(IdentIndex).isOverload then
                  begin

                    if IdentifierAt(IdentIndex).NumParams <> j then
                      Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters,
                        'Wrong number of parameters specified for {0}.', IdentifierAt(identIndex).Name));


                    ErrorForIdentifier(i, TErrorCode.CantDetermine, IdentIndex);
                  end
                  else
                    Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters,
                      'Wrong number of parameters specified for {0}.', IdentifierAt(identIndex).Name));

                IdentIndex := IdentTemp;

                //    end;


                if (IdentifierAt(IdentIndex).isStdCall = False) then
                  StartOptimization(i)
                else
                  if common.optimize.use = False then StartOptimization(i);


                Inc(run_func);

                CompileActualParameters(i, IdentIndex);

                ValType := IdentifierAt(IdentIndex).DataType;
                if (ValType = TDataType.ENUMTOK) then
                  ValType := IdentifierAt(IdentIndex).NestedFunctionAllocElementType;

                Dec(run_func);

                Result := i;
              end // FUNC
              else
              begin

                // -----------------------------------------------------------------------------
                // ===         record^.
                // -----------------------------------------------------------------------------

                if (TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK) then
                  if (IdentifierAt(IdentIndex).Kind <> TTokenKind.VARTOK) or not
                    (IdentifierAt(IdentIndex).DataType in Pointers) then
                    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
                  else
                  begin

                    if (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) and
                      (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                      ValType := TDataType.STRINGPOINTERTOK
                    else
                      ValType := IdentifierAt(IdentIndex).AllocElementType;


                    if (ValType = TDataType.UNTYPETOK) and (IdentifierAt(IdentIndex).DataType =
                      TDataType.POINTERTOK) then
                    begin

                      ValType := TDataType.POINTERTOK;

                      Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(ValType), IdentIndex);

                    end
                    else
                      if (ValType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                      begin            // record^.


                        if (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) then
                        begin

                          //  writeln(IdentifierAt(IdentIndex).Name,',',TokenAt(i + 3).Name,' | ',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements);

                          CheckTok(i + 3, TTokenKind.IDENTTOK);
                          IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);

                          if IdentTemp < 0 then
                            Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                              'Identifier idents no member ''{0}''.', TokenAt(i + 3).Name));

                          ValType := TDataType(IdentTemp shr 16);

                          Inc(i, 2);


                          if (TokenAt(i + 1).Kind = TTokenKind.IDENTTOK) and
                            (TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK) then
                          begin    // record^.label[x]

                            Inc(i);

                            ValType := IdentifierAt(GetIdentIndex(IdentifierAt(IdentIndex).Name +
                              '.' + TokenAt(i).Name)).AllocElementType;

                            i := CompileArrayIndex(i, GetIdentIndex(IdentifierAt(IdentIndex).Name +
                              '.' + TokenAt(i).Name), ValType);

                            Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORDARRAYORIGIN, GetDataSize(ValType),
                              IdentIndex, IdentTemp and $ffff);

                          end
                          else

                            if ValType = TDataType.STRINGPOINTERTOK then
                              Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORD, GetDataSize(ValType),
                                IdentIndex, IdentTemp and $ffff)
                            // record^.string
                            else
                              Push(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER, GetDataSize(ValType),
                                IdentIndex, IdentTemp and $ffff);
                          // record_lebel.field^

                        end
                        else
                          // fake code, do nothing ;)
                          Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(ValType), IdentIndex);
                        // record_label^

                      end
                      else
                        if IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK then
                          Push(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(ValType), IdentIndex)
                        else
                          Push(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER, GetDataSize(ValType), IdentIndex);

                    // LUCI
                    Result := i + 1;
                  end
                else

                // -----------------------------------------------------------------------------
                // ===         array [index].
                // -----------------------------------------------------------------------------

                  if TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK then      // Array element access
                    if not (IdentifierAt(IdentIndex).DataType in Pointers)
                    {or ((IdentifierAt(IdentIndex).NumAllocElements = 0) and (IdentifierAt(IdentIndex).idType <> TTokenKind.PCHARTOK))}
                    then
                      // PByte, PWord
                      ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
                    else
                    begin

                      // Writeln('> ',Ident[IdentIndex].Name,',',ValType,',',Ident[GetIdent(Tok[i].Name^)].name,',',VarType);
                      // perl
                      i := CompileArrayIndex(i, IdentIndex, ValType);              // array[ ].field


                      if ValType = TDataType.ARRAYTOK then
                      begin

                        ValType := TDataType.POINTERTOK;

                        Push(0, ASPOINTER, GetDataSize(ValType), IdentIndex, 0);

                      end
                      else
                        if TokenAt(i + 2).Kind = TTokenKind.DEREFERENCETOK then
                        begin

                          //  writeln(valType,' / ',IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_);

                          Push(0, ASPOINTERTORECORDARRAYORIGIN, GetDataSize(ValType), IdentIndex, 0);

                          Inc(i);
                        end
                        else

                          if (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) and
                            (ValType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                          begin

                            //  writeln(valType,' / ',IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_,',',TokenAt(i + 3).Kind );

                            CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                            CheckTok(i + 3, TTokenKind.IDENTTOK);
                            IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);

                            if IdentTemp < 0 then
                              Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                                'Identifier idents no member ''{0}''.', TokenAt(i + 3).Name));

                            ValType := TDataType(IdentTemp shr 16);

                            Inc(i, 2);


                            if (TokenAt(i + 1).Kind = TTokenKind.IDENTTOK) and
                              (TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK) then
                            begin    // array_of_record_pointers[x].array[i]

                              Inc(i);

                              ValType :=
                                IdentifierAt(GetIdentIndex(IdentifierAt(IdentIndex).Name +
                                '.' + TokenAt(i).Name)).AllocElementType;

                              IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;


                              if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                                (IdentifierAt(IdentIndex).AllocElementType in
                                [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                              begin

                                //  writeln(ValType,',',IdentifierAt(IdentIndex).Name + '||' + TokenAt(i).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_ );

                                IdentTemp := RecordSize(IdentIndex, TokenAt(i).Name);

                                if IdentTemp < 0 then
                                  Error(i, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                                    'Identifier idents no member ''{0}''.', TokenAt(i).Name));

                                ValType :=
                                  IdentifierAt(GetIdentIndex(IdentifierAt(IdentIndex).Name +
                                  '.' + TokenAt(i).Name)).AllocElementType;

                                IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

                              end;


                              i := CompileArrayIndex(i, GetIdentIndex(IdentifierAt(IdentIndex).Name +
                                '.' + TokenAt(i).Name), AllocElementType);

                              Push(IdentifierAt(IdentIndex).Value, IndirectionLevel, GetDataSize(ValType),
                                IdentIndex, IdentTemp and $ffff);

                            end
                            else

                              if ValType = TDataType.STRINGPOINTERTOK then
                                // array_of_record_pointers[index].string
                                Push(0, ASPOINTERTOARRAYRECORDTOSTRING, GetDataSize(ValType),
                                  IdentIndex, IdentTemp and $ffff)
                              else
                                Push(0, ASPOINTERTOARRAYRECORD, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);

                          end
                          else
                            if (TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK) and
                              (ValType = TDataType.STRINGPOINTERTOK) then
                            begin

                              Error(i, TMessage.Create(TErrorCode.UnderConstruction, 'Under construction'));
{
       ValType := TDataType.CHARTOK;
       inc(i, 3);

       Push(2, ASVALUE, 2);

       GenerateBinaryOperation(PLUSTOK, TTokenKind.WORDTOK);
}
                            end
                            else
                            begin

                              // -----------------------------------------------------------------------------
                              //          record.
                              // record_ptr.label[index] traktowane jest jako 'record_ptr.label'
                              // zamiast 'record_ptr'
                              // -----------------------------------------------------------------------------

                              //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_);

                              IdentTemp := 0;

                              IndirectionLevel := ASPOINTERTOARRAYORIGIN2;


                              if (pos('.', IdentifierAt(IdentIndex).Name) > 0) then
                              begin         // record_ptr.field[index]

                                //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).AllocElementType );

                                IdentTemp :=
                                  GetIdentIndex(copy(IdentifierAt(IdentIndex).Name, 1,
                                  pos('.', IdentifierAt(IdentIndex).Name) - 1));

                                if (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) and
                                  (IdentifierAt(IdentTemp).AllocElementType in
                                  [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                                begin

                                  svar :=
                                    copy(IdentifierAt(IdentIndex).Name, pos('.', IdentifierAt(IdentIndex).Name) +
                                    1, length(IdentifierAt(IdentIndex).Name));

                                  IdentIndex := IdentTemp;

                                  IdentTemp := RecordSize(IdentIndex, svar);

                                  if IdentTemp < 0 then
                                    Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                                      'Identifier idents no member ''{0}''.', svar));

                                  IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                                  //         Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORDARRAYORIGIN, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);

                                end;

                              end;


                              if ValType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                              begin
                                ValType := TDataType.POINTERTOK;
                              end;

                              if VarType <> TDataType.UNTYPETOK then
                              begin
                                if GetDataSize(ValType) > GetDataSize(VarType) then ValType := VarType;
                              end;

                              Push(IdentifierAt(IdentIndex).Value, IndirectionLevel,
                                GetDataSize(ValType), IdentIndex, IdentTemp and $ff);

                              CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                            end;


                      Result := i + 1;
                    end
                  else                // Usual variable or constant
                  begin

                    j := i;

                    isError := False;
                    isConst := True;


                    if IdentifierAt(IdentIndex).isVolatile then
                    begin
                      asm65('?volatile:');

                      resetOPTY;
                    end;


                    i := CompileConstTerm(i, ConstVal, ValType);

                    if isError then
                    begin
                      i := j;


                      if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) and
                        (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                      begin

                        //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).idType,'/',IdentifierAt(IdentIndex).Kind,' = ',IdentifierAt(IdentIndex).PassMethod ,' | ',ValType,',',TokenAt(j).Kind,',',TokenAt(j+1].kind);

                        ValType := IdentifierAt(IdentIndex).AllocElementType;

                        if (ValType = TDataType.CHARTOK) then

                          case IdentifierAt(IdentIndex).DataType of
                            TDataType.POINTERTOK: ValType := TDataType.PCHARTOK;
                            TDataType.STRINGPOINTERTOK: ValType := TDataType.STRINGPOINTERTOK;
                          end;


                        if ValType = TDataType.UNTYPETOK then ValType := IdentifierAt(IdentIndex).DataType;  // RECORD.

                      end
                      else
                        ValType := IdentifierAt(IdentIndex).DataType;


                      // LUCI
                      //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).idType,'/',IdentifierAt(IdentIndex).Kind,' = ',IdentifierAt(IdentIndex).PassMethod ,' | ',ValType,',',TokenAt(j].kind,',',TokenAt(j+1].kind);


                      if (ValType = TDataType.ENUMTOK) and (IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK) then
                        ValType := IdentifierAt(IdentIndex).AllocElementType;


                      //    if ValType in IntegerTypes then
                      //      if GetDataSize(ValType) > GetDataSize(VarType) then ValType := VarType;     // skracaj typ danych    !!! niemozliwe skoro VarType = TDataType.INTEGERTOK


                      if (IdentifierAt(IdentIndex).Kind = TTokenKind.CONSTTOK) then
                      begin
                        if {(Ident[IdentIndex].Kind = TTokenKind.CONSTANT) and} (ValType in Pointers) then
                          ConstVal := IdentifierAt(IdentIndex).Value - CODEORIGIN
                        else
                          ConstVal := IdentifierAt(IdentIndex).Value;


                        if (ValType in IntegerTypes) and (VarType in [TDataType.SINGLETOK,
                          TDataType.HALFSINGLETOK]) then
                          ConstVal := FromInt64(ConstVal);

                        if (VarType = TDataType.HALFSINGLETOK)
                        {or (ValType = TDataType.HALFSINGLETOK)} then
                        begin
                          ConstVal := CastToHalfSingle(ConstVal);
                          //ValType := TDataType.HALFSINGLETOK;
                        end;

                        if (VarType = TDataType.SINGLETOK) then
                        begin
                          ConstVal := CastToSingle(ConstVal);
                          //ValType := TDataType.SINGLETOK;
                        end;

                      end;



                      if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) and
                        (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                        (IdentifierAt(IdentIndex).DataType in Pointers) and
                        (IdentifierAt(IdentIndex).AllocElementType in Pointers) and
                        (IdentifierAt(IdentIndex).idType = TDataType.DATAORIGINOFFSET) then

                        Push(ConstVal, ASPOINTERTORECORD, GetDataSize(ValType), IdentIndex)
                      else
                        if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) and
                          (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                          Push(ConstVal, ASPOINTERTOPOINTER, GetDataSize(ValType), IdentIndex)
                        else
    {if IdentifierAt(IdentIndex).IdType = TDataType.DEREFERENCETOK then    // !!! test-record\record_dereference_as_val.pas !!!
     Push(ConstVal, ASVALUE, GetDataSize(ValType), IdentIndex)
    else}
                          Push(ConstVal, Ord(IdentifierAt(IdentIndex).Kind = TTokenKind.VARTOK),
                            GetDataSize(ValType), IdentIndex);


                      if (BLOCKSTACKTOP = 1) then
                        if not (IdentifierAt(IdentIndex).isInit or IdentifierAt(IdentIndex).isInitialized or
                          IdentifierAt(IdentIndex).LoopVariable) then
                          WarningVariableNotInitialized(i, IdentIndex);

                    end
                    else
                    begin  // isError

                      if (ValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) or
                        (VarType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) then
                      begin  // constants

                        if ValType in IntegerTypes then ConstVal := FromInt64(ConstVal);

                        if (VarType = TDataType.HALFSINGLETOK) or (ValType = TDataType.HALFSINGLETOK) then
                        begin
                          ConstVal := CastToHalfSingle(ConstVal);
                          ValType := TDataType.HALFSINGLETOK;
                        end
                        else
                        begin
                          ConstVal := CastToSingle(ConstVal);
                          ValType := TDataType.SINGLETOK;
                        end;

                      end;

                      Push(ConstVal, ASVALUE, GetDataSize(ValType));

                    end;

                    isConst := False;
                    isError := False;

                    Result := i;
                  end;

              end
      else
        Error(i, TErrorCode.UnknownIdentifier);
    end;


    TTokenKind.ADDRESSTOK:
      Result := CompileAddress(i - 1, ValType, AllocElementType);


    TTokenKind.INTNUMBERTOK:
    begin

      ConstVal := TokenAt(i).Value;
      ValType := GetValueType(ConstVal);

      if VarType in RealTypes then
      begin
        ConstVal := FromInt64(ConstVal);

        if VarType = TDataType.HALFSINGLETOK then
          ConstVal := CastToHalfSingle(ConstVal)
        else
          if VarType = TDataType.SINGLETOK then
            ConstVal := CastToSingle(ConstVal);

        ValType := VarType;
      end;

      Push(ConstVal, ASVALUE, GetDataSize(ValType));

      isZero := (ConstVal = 0);

      Result := i;
    end;


    TTokenKind.FRACNUMBERTOK:
    begin

      constVal := FromSingle(TokenAt(i).FracValue);

      ValType := TDataType.REALTOK;

      if VarType in RealTypes then
      begin

        case VarType of
          TDataType.SINGLETOK: ConstVal := CastToSingle(ConstVal);
          TDataType.HALFSINGLETOK: ConstVal := CastToHalfSingle(ConstVal);
          else
            ConstVal := CastToReal(ConstVal);
        end;

        ValType := VarType;
      end;

      Push(ConstVal, ASVALUE, GetDataSize(ValType));

      isZero := (ConstVal = 0);

      Result := i;
    end;


    TTokenKind.STRINGLITERALTOK:
    begin
      Push(TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE, ASVALUE, GetDataSize(TDataType.STRINGPOINTERTOK));
      ValType := TDataType.STRINGPOINTERTOK;

      Result := i;
    end;


    TTokenKind.CHARLITERALTOK:
    begin
      Push(TokenAt(i).Value, ASVALUE, GetDataSize(TDataType.CHARTOK));
      ValType := TDataType.CHARTOK;
      Result := i;
    end;


    TTokenKind.OPARTOK:       // a whole expression in parentheses suspected
    begin
      j := CompileExpression(i + 1, ValType, VarType);

      CheckTok(j + 1, TTokenKind.CPARTOK);

      Result := j + 1;
    end;


    TTokenKind.NOTTOK:
    begin
      Result := CompileFactor(i + 1, isZero, ValType, TDataType.INTEGERTOK);
      CheckOperator(i, TTokenKind.NOTTOK, ValType);
      GenerateUnaryOperation(TTokenKind.NOTTOK, Valtype);
    end;


    TTokenKind.SHORTREALTOK:          // SHORTREAL  fixed-point  Q8.8
    begin

      //    CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i, TMessage.Create(TErrorCode.TypeIdentifierNotAllowed, 'Type identifier not allowed here'));

      j := CompileExpression(i + 2, ValType);//, TTokenKind.SHORTREALTOK);

      // ASPOINTERTODEREFERENCE

      if TokenAt(j + 1).Kind = TTokenKind.DEREFERENCETOK then
      begin

        if ValType = TDataType.POINTERTOK then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :bp2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :bp2+1');
          asm65(#9'ldy #$00');

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

          Inc(j);

        end
        else
          Error(j + 1, TErrorCode.IllegalQualifier);

      end
      else
      begin

        if ValType in IntegerTypes + RealTypes then
        begin

          ExpandParam(TDataType.SMALLINTTOK, ValType);

          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'lda #$00');
          asm65(#9'sta :STACKORIGIN,x');

        end
        else
          Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeConversion,
            'Illegal type conversion: "{0}" to "{1}".', InfoAboutDataType(ValType),
            InfoAboutDataType(TDataType.SHORTREALTOK)));

      end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      ValType := TDataType.SHORTREALTOK;

      Result := j + 1;
    end;


    TTokenKind.REALTOK:          // REAL    fixed-point  Q24.8
    begin

      //    CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i, TMessage.Create(TErrorCode.TypeIdentifierNotAllowed, 'Type identifier not allowed here.'));

      j := CompileExpression(i + 2, ValType);//, TTokenKind.REALTOK);


      // ASPOINTERTODEREFERENCE

      if TokenAt(j + 1).Kind = TTokenKind.DEREFERENCETOK then
      begin

        if ValType = TDataType.POINTERTOK then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :bp2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :bp2+1');
          asm65(#9'ldy #$00');

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

          Inc(j);

        end
        else
          Error(j + 1, TErrorCode.IllegalQualifier);

      end
      else
      begin

        if ValType in IntegerTypes + RealTypes then
        begin

          ExpandParam(TDataType.INTEGERTOK, ValType);

          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'lda #$00');
          asm65(#9'sta :STACKORIGIN,x');

        end
        else
          Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeConversion,
            'Illegal type conversion: "{0}" to "{1}".', InfoAboutDataType(ValType),
            InfoAboutDataType(TDataType.REALTOK)));

      end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      ValType := TDataType.REALTOK;

      Result := j + 1;
    end;


    TTokenKind.HALFSINGLETOK:
    begin

      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i, TMessage.Create(TErrorCode.TypeIdentifierNotAllowed, 'Type identifier not allowed here'));

      j := CompileExpression(i + 2, ValType);

      // ASPOINTERTODEREFERENCE

      if TokenAt(j + 1).Kind = TTokenKind.DEREFERENCETOK then
      begin

        if ValType = TDataType.POINTERTOK then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :bp2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :bp2+1');
          asm65(#9'ldy #$00');

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

          Inc(j);

        end
        else
          Error(j + 1, TErrorCode.IllegalQualifier);

      end
      else
      begin

        if ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK] then
          Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeConversion,
            'Illegal type conversion: "{0}" to "{1}".', InfoAboutDataType(ValType),
            InfoAboutDataType(TDataType.HALFSINGLETOK)));


        if ValType in IntegerTypes + RealTypes then
        begin

          ExpandParam(TDataType.INTEGERTOK, ValType);

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta @F16_I2F.SV');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta @F16_I2F.SV+1');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta @F16_I2F.SV+2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta @F16_I2F.SV+3');

          asm65(#9'jsr @F16_I2F');

          asm65(#9'lda :eax');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :eax+1');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
        end
        else
          Error(i + 2, 'Illegal type conversion: "' + InfoAboutDataType(ValType) + '" to "' +
            InfoAboutDataType(TDataType.HALFSINGLETOK) + '"');

      end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      ValType := TDataType.HALFSINGLETOK;

      Result := j + 1;

    end;


    TTokenKind.SINGLETOK:          // SINGLE  IEEE-754  Q32
    begin

      //    CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i, 'type identifier not allowed here');

      j := i + 2;

      if SafeCompileConstExpression(j, ConstVal, ValType, TDataType.SINGLETOK) then
      begin

        if not (ValType in RealTypes) then ConstVal := FromInt64(ConstVal);

        ConstVal := CastToSingle(ConstVal);

        ValType := TDataType.SINGLETOK;

        Push(ConstVal, ASVALUE, GetDataSize(ValType));

      end
      else
      begin
        j := CompileExpression(i + 2, ValType);

        // ASPOINTERTODEREFERENCE

        if TokenAt(j + 1).Kind = TTokenKind.DEREFERENCETOK then
        begin

          if ValType = TDataType.POINTERTOK then
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');
            asm65(#9'ldy #$00');

            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :STACKORIGIN,x');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

            Inc(j);

          end
          else
            Error(j + 1, TErrorCode.IllegalQualifier);

        end
        else
        begin

          if ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK] then
            Error(i + 2, 'Illegal type conversion: "' + InfoAboutDataType(ValType) + '" to "' +
              InfoAboutDataType(TDataType.SINGLETOK) + '"');


          if ValType in IntegerTypes + RealTypes then
          begin

            ExpandParam(TDataType.INTEGERTOK, ValType);

            //asm65(#9'jsr @I2F');

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :FPMAN0');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :FPMAN1');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta :FPMAN2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta :FPMAN3');

            asm65(#9'jsr @I2F');

            asm65(#9'lda :FPMAN0');
            asm65(#9'sta :STACKORIGIN,x');
            asm65(#9'lda :FPMAN1');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'lda :FPMAN2');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'lda :FPMAN3');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

          end
          else
            Error(i + 2, 'Illegal type conversion: "' + InfoAboutDataType(ValType) + '" to "' +
              InfoAboutDataType(TDataType.SINGLETOK) + '"');

        end;

      end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      ValType := TDataType.SINGLETOK;

      Result := j + 1;

    end;


    TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK, TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK,
    TTokenKind.CHARTOK, TTokenKind.PCHARTOK, TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK,
    TTokenKind.BOOLEANTOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK:  // type conversion operations
    begin

      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i, 'type identifier not allowed here');


      j := CompileExpression(i + 2, ValType, TokenAt(i).GetDataType);


      if (ValType in Pointers) and (TokenAt(i + 2).Kind = TTokenKind.IDENTTOK) and
        (TokenAt(i + 3).Kind <> TTokenKind.OBRACKETTOK) then
      begin

        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

        if (IdentifierAt(IdentIndex).DataType in Pointers) and
          ((IdentifierAt(IdentIndex).NumAllocElements > 0) and
          (IdentifierAt(IdentIndex).AllocElementType <> TDataType.RECORDTOK)) then
          if ((IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
            (IdentifierAt(IdentIndex).NumAllocElements in [0, 1])) or
            (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) then

          else
            ErrorIdentifierIllegalTypeConversion(i + 2, IdentIndex, TokenAt(i).GetDataType);

      end;


      // ASPOINTERTODEREFERENCE

      if TokenAt(j + 1).Kind = TTokenKind.DEREFERENCETOK then
        if ValType = TDataType.POINTERTOK then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :bp2');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta :bp2+1');
          asm65(#9'ldy #$00');

          case GetDataSize(TokenAt(i).GetDataType) of

            1: begin
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN,x');
            end;

            2: begin
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
            end;

            4: begin
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN,x');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
            end;

          end;

          Inc(j);

        end
        else
          Error(j + 1, TErrorCode.IllegalQualifier);


      if not (ValType in AllTypes) then
        Error(i, TErrorCode.TypeMismatch);

      ExpandParam(TokenAt(i).GetDataType, ValType);

      CheckTok(j + 1, TTokenKind.CPARTOK);

      ValType := TokenAt(i).GetDataType;


      if TokenAt(j + 2).Kind = TTokenKind.DEREFERENCETOK then
        if (ValType = TDataType.PCHARTOK) then
        begin

          ValType := TDataType.CHARTOK;

          Inc(j);

        end
        else
          Error(j + 1, TErrorCode.IllegalQualifier);

      Result := j + 1;

    end;

    else
      Error(i, TErrorCode.IdNumExpExpected);
  end;// case

end;  //CompileFactor

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ResizeType(var ValType: TDataType);
// For SHL, MUL operations we extend the type for the operation result
begin

  if ValType in [TDataType.BYTETOK, TDataType.WORDTOK, TDataType.SHORTINTTOK, TDataType.SMALLINTTOK] then
    ValType := Succ(ValType);

end;




// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileTerm(i: Integer; out ValType: TDataType; VarType: TDataType = TDataType.INTEGERTOK): Integer;
var
  j, k, oldCodeSize: Integer;
  RightValType: TDataType;
  CastRealType: TDataType;
  oldPass: TPass;
  isZero: Boolean;
begin

  oldPass := Pass;
  oldCodeSize := CodeSize;
  Pass := TPass.CALL_DETERMINATION;

  j := CompileFactor(i, isZero, ValType, VarType);

  Pass := oldPass;
  CodeSize := oldCodeSize;


  if TokenAt(j + 1).Kind in [TTokenKind.MODTOK, TTokenKind.IDIVTOK, TTokenKind.SHLTOK,
    TTokenKind.SHRTOK, TTokenKind.ANDTOK] then
    j := CompileFactor(i, isZero, ValType, TDataType.INTEGERTOK)
  else
  begin

    if ValType in RealTypes then VarType := ValType;

    j := CompileFactor(i, isZero, ValType, VarType);

  end;

  while TokenAt(j + 1).Kind in [TTokenKind.MULTOK, TTokenKind.DIVTOK, TTokenKind.MODTOK,
      TTokenKind.IDIVTOK, TTokenKind.SHLTOK, TTokenKind.SHRTOK, TTokenKind.ANDTOK] do
  begin

    if ValType in RealTypes then VarType := ValType;


    if TokenAt(j + 1).Kind in [TTokenKind.MULTOK, TTokenKind.DIVTOK] then
      k := CompileFactor(j + 2, isZero, RightValType, VarType)
    else
      k := CompileFactor(j + 2, isZero, RightValType, TDataType.INTEGERTOK);

    if (TokenAt(j + 1).Kind in [TTokenKind.MODTOK, TTokenKind.IDIVTOK]) and isZero then
      Error(j + 1, 'Division by zero');


    if ((ValType in [TDataType.HALFSINGLETOK, TDataType.SINGLETOK]) and (RightValType in
      [TDataType.SHORTREALTOK, TDataType.REALTOK])) or
      ((ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) and (RightValType in
      [TDataType.HALFSINGLETOK, TDataType.SINGLETOK])) then
      Error(j + 2, 'Illegal type conversion: "' + InfoAboutDataType(ValType) + '" to "' +
        InfoAboutDataType(RightValType) + '"');


    if VarType in RealTypes then
    begin
      if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
      if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
    end;

    if TokenAt(j + 1).Kind = TTokenKind.DIVTOK then
    begin
      if VarType in RealTypes then
      begin
        CastRealType := VarType;
      end
      else
      begin
        CastRealType := TDataType.REALTOK;
      end;
    end
    else
    begin
      CastRealType := TDataType.UNTYPETOK;
    end;

    RealTypeConversion(ValType, RightValType, CastRealType);


    ValType := GetCommonType(j + 1, ValType, RightValType);

    CheckOperator(i, TokenAt(j + 1).Kind, ValType, RightValType);

    if not (TokenAt(j + 1).Kind in [TTokenKind.SHLTOK, TTokenKind.SHRTOK]) then
      // dla SHR, SHL nie wyrownuj typow parametrow
      ExpandExpression(ValType, RightValType, TDataType.UNTYPETOK);

    if TokenAt(j + 1).Kind = TTokenKind.MULTOK then
      if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
        if GetDataSize(ValType) > GetDataSize(VarType) then ValType := VarType;

    GenerateBinaryOperation(TokenAt(j + 1).Kind, ValType);

    case TokenAt(j + 1).Kind of              // !!! tutaj a nie przed ExpandExpression
      TTokenKind.MULTOK: begin
        ResizeType(ValType);
        ExpandExpression(VarType, TDataType.UNTYPETOK, TDataType.UNTYPETOK);
      end;

      TTokenKind.SHRTOK: if (ValType in SignedOrdinalTypes) and (GetDataSize(ValType) > 1) then
        begin
          ResizeType(ValType);
          ResizeType(ValType);
        end;  // int:=smallint(-90100) shr 4;

      TTokenKind.SHLTOK: begin
        ResizeType(ValType);
        ResizeType(ValType);
      end;             // !!! Silly Intro lub "x(byte) shl 14" tego wymaga
    end;

    j := k;
  end;

  Result := j;
end;  //CompileTerm


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileSimpleExpression(i: Integer; out ValType: TDataType; VarType: TDataType): Integer;
var
  j, k: Integer;
  ConstVal: Int64;
  RightValType: TDataType;
begin

  if TokenAt(i).Kind in [TTokenKind.PLUSTOK, TTokenKind.MINUSTOK] then j := i + 1
  else
    j := i;

  if SafeCompileConstExpression(j, ConstVal, ValType, VarType) then
  begin

    if (ValType in IntegerTypes) and (VarType in RealTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ValType := VarType;
    end;

    if VarType in RealTypes then
    begin
      ValType := VarType;
    end;

    if TokenAt(i).Kind = TTokenKind.MINUSTOK then
    begin
      ConstVal := Negate(ValType, ConstVal);
    end;

    if ValType = TDataType.SINGLETOK then
    begin
      ConstVal := CastToSingle(ConstVal);
    end;

    if ValType = TDataType.HALFSINGLETOK then
    begin
      ConstVal := CastToHalfSingle(ConstVal);
    end;


    Push(ConstVal, ASVALUE, GetDataSize(ValType));

  end
  else
  begin  // if SafeCompileConstExpression

    j := CompileTerm(j, ValType, VarType);

    if TokenAt(i).Kind = TTokenKind.MINUSTOK then
    begin

      GenerateUnaryOperation(TTokenKind.MINUSTOK, ValType);  // Unary minus

      if ValType in UnsignedOrdinalTypes then  // jesli odczytalismy typ bez znaku zamieniamy na 'ze znakiem'
        if ValType = TDataType.BYTETOK then
          ValType := TDataType.SMALLINTTOK
        else
          ValType := TDataType.INTEGERTOK;

    end;

  end;


  while TokenAt(j + 1).Kind in [TTokenKind.PLUSTOK, TTokenKind.MINUSTOK, TTokenKind.ORTOK, TTokenKind.XORTOK] do
  begin

    if ValType in RealTypes then VarType := ValType;

    k := CompileTerm(j + 2, RightValType, VarType);

    if ((ValType in [TDataType.HALFSINGLETOK, TDataType.SINGLETOK]) and (RightValType in
      [TDataType.SHORTREALTOK, TDataType.REALTOK])) or
      ((ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) and (RightValType in
      [TDataType.HALFSINGLETOK, TDataType.SINGLETOK])) then
      Error(j + 2, 'Illegal type conversion: "' + InfoAboutDataType(ValType) + '" to "' +
        InfoAboutDataType(RightValType) + '"');


    if VarType in RealTypes then
    begin
      if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
      if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
    end;

    RealTypeConversion(ValType, RightValType);//, VarType);


    if (ValType = TDataType.POINTERTOK) and (RightValType in IntegerTypes) then
    begin
      ExpandParam(TDataType.WORDTOK, RightValType);
      RightValType := TDataType.POINTERTOK;
    end;
    if (RightValType = TDataType.POINTERTOK) and (ValType in IntegerTypes) then
    begin
      ExpandParam_m1(TDataType.WORDTOK, ValType);
      ValType := TDataType.POINTERTOK;
    end;


    ValType := GetCommonType(j + 1, ValType, RightValType);

    CheckOperator(i, TokenAt(j + 1).Kind, ValType, RightValType);


    if TokenAt(j + 1).Kind in [TTokenKind.PLUSTOK, TTokenKind.MINUSTOK] then
    begin        // dla PLUSTOK, MINUSTOK rozszerz typ wyniku

      if (TokenAt(j + 1).Kind = TTokenKind.MINUSTOK) and (RightValType in UnsignedOrdinalTypes) and
        (VarType in SignedOrdinalTypes + [TDataType.BOOLEANTOK, TDataType.REALTOK,
        TDataType.HALFSINGLETOK, TDataType.SINGLETOK]) then
      begin

        if (ValType = VarType) and (RightValType = VarType) then
        // do nothing, all types are with sign
        else
          ExpandExpression(ValType, RightValType, VarType, True);    // promote to type with sign

      end
      else
        ExpandExpression(ValType, RightValType, VarType);

    end
    else
      ExpandExpression(ValType, RightValType, TDataType.UNTYPETOK);

    if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
      if GetDataSize(ValType) > GetDataSize(VarType) then ValType := VarType;


    GenerateBinaryOperation(TokenAt(j + 1).Kind, ValType);

    j := k;
  end;

  Result := j;
end;  //CompileSimpleExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function CompileExpression(i: Integer; out ValType: TDataType; VarType: TDataType = TDataType.INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType, ConstValType: TDataType;
  isZero: TDataType;
  sLeft, sRight, cRight, yes: Boolean;
  ConstVal, ConstValRight: Int64;
begin

  Debugger.debugger.CompileExpression(i, ValType, VarType);

  ConstVal := 0;

  isZero := TDataType.INTEGERTOK;

  cRight := False;    // constantRight

  if SafeCompileConstExpression(i, ConstVal, ValType, VarType, False) then
  begin

    if (ValType in IntegerTypes) and (VarType in RealTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ValType := VarType;
    end;

    if VarType in RealTypes then ValType := VarType;


    if (ValType = TDataType.HALFSINGLETOK) {or ((VarType = TDataType.HALFSINGLETOK) and (ValType in RealTypes))} then
    begin
      ConstVal := CastToHalfSingle(ConstVal);
      ValType := TDataType.HALFSINGLETOK;  // Currently redundant
    end;

    if (ValType = TDataType.SINGLETOK) {or ((VarType = TDataType.SINGLETOK) and (ValType in RealTypes))} then
    begin
      ConstVal := CastToSingle(ConstVal);
      ValType := TDataType.SINGLETOK; // Currently redundant
    end;

    Push(ConstVal, ASVALUE, GetDataSize(ValType));

    Result := i;
    exit;
  end;

  ConstValRight := 0;

  sLeft := False;    // stringLeft
  sRight := False;    // stringRight


  i := CompileSimpleExpression(i, ValType, VarType);


  if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) or (ValType = TDataType.STRINGPOINTERTOK) then sLeft := True
  else
    if (ValType in Pointers) and (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
      if (IdentifierAt(GetIdentIndex(TokenAt(i).Name)).AllocElementType = TDataType.CHARTOK) and
        (Elements(GetIdentIndex(TokenAt(i).Name)) > 0) then sLeft := True;


  if TokenAt(i + 1).Kind = TTokenKind.INTOK then writeln('IN');        // not yet programmed


  if TokenAt(i + 1).Kind in [TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LTTOK, TTokenKind.LETOK,
    TTokenKind.GTTOK, TTokenKind.GETOK] then
  begin

    if ValType in RealTypes + [TDataType.ENUMTOK] then VarType := ValType;

    j := CompileSimpleExpression(i + 2, RightValType, VarType);


    k := i + 2;
    if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
      if (ConstValType in IntegerTypes) and (VarType in IntegerTypes + [TDataType.BOOLEANTOK]) then
      begin

        if ConstVal = 0 then
        begin
          isZero := TDataType.BYTETOK;

          if (ValType in SignedOrdinalTypes) and (TokenAt(i + 1).Kind in [TTokenKind.EQTOK, TTokenKind.NETOK]) then
          begin

            case ValType of
              TDataType.SHORTINTTOK: ValType := TDataType.BYTETOK;
              TDataType.SMALLINTTOK: ValType := TDataType.WORDTOK;
              TDataType.INTEGERTOK: ValType := TDataType.CARDINALTOK;
            end;

          end;

        end;


        if ConstValType in SignedOrdinalTypes then
          if ConstVal < 0 then isZero := TDataType.SHORTINTTOK;

        cRight := True;

        ConstValRight := ConstVal;
        RightValType := ConstValType;

      end;    // if ConstValType in IntegerTypes



    if (TokenAt(i + 2).Kind = TTokenKind.STRINGLITERALTOK) or (RightValType = TDataType.STRINGPOINTERTOK) then
      sRight := True
    else
      if (RightValType in Pointers) and (TokenAt(i + 2).Kind = TTokenKind.IDENTTOK) then
        if (IdentifierAt(GetIdentIndex(TokenAt(i + 2).Name)).AllocElementType = TDataType.CHARTOK) and
          (Elements(GetIdentIndex(TokenAt(i + 2).Name)) > 0) then sRight := True;

    //  if (ValType in [SHORTREALTOK, TDataType.REALTOK]) and (RightValType in [TDataType.SHORTREALTOK, TDataType.TTokenKind.REALTOK]) then
    //    RightValType := ValType;

    if VarType in RealTypes then
    begin
      if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
      if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
    end;

    RealTypeConversion(ValType, RightValType);//, VarType);

    //  writeln(VarType,  ' | ', ValType,'/',RightValType,',',isZero,',',TokenAt(i + 1).Kind ,' : ', ConstVal);


    if cRight and (TokenAt(i + 1).Kind in [TTokenKind.LTTOK, TTokenKind.GTTOK]) and (ValType in IntegerTypes) then
    begin

      yes := False;

      if TokenAt(i + 1).Kind = TTokenKind.LTTOK then
      begin

        case ValType of
          TDataType.BYTETOK, TDataType.WORDTOK, TDataType.CARDINALTOK: yes := (isZero = TDataType.BYTETOK);
          // TDataType.BYTETOK: yes := (ConstVal = Low(byte));  // < 0
          // TDataType.WORDTOK: yes := (ConstVal = Low(word));  // < 0
          // TDataType.CARDINALTOK: yes := (ConstVal = Low(cardinal));  // < 0
          TDataType.SHORTINTTOK: yes := (ConstVal = Low(Shortint));  // < -128
          TDataType.SMALLINTTOK: yes := (ConstVal = Low(Smallint));  // < -32768
          TDataType.INTEGERTOK: yes := (ConstVal = Low(Integer));  // < -2147483648
        end;

      end
      else

        case ValType of
          TDataType.BYTETOK: yes := (ConstVal = High(Byte));  // > 255
          TDataType.WORDTOK: yes := (ConstVal = High(Word));  // > 65535
          TDataType.CARDINALTOK: yes := (ConstVal = High(Cardinal));  // > 4294967295
          TDataType.SHORTINTTOK: yes := (ConstVal = High(Shortint));  // > 127
          TDataType.SMALLINTTOK: yes := (ConstVal = High(Smallint));  // > 32767
          TDataType.INTEGERTOK: yes := (ConstVal = High(Integer));  // > 2147483647
        end;

      if yes then
      begin
        WarningAlwaysFalse(i + 2);
        WarningUnreachableCode(i + 2);
      end;

    end;


    if (isZero = TDataType.BYTETOK) and (ValType in UnsignedOrdinalTypes) then
      case TokenAt(i + 1).Kind of
        //  TTokenKind.LTTOK: WarningAlwaysFalse(i + 2);             // BYTE, WORD, CARDINAL '<' 0
        TTokenKind.GETOK: WarningAlwaysTrue(i + 2);      // BYTE, WORD, CARDINAL '>', '>=' 0
      end;


    if (isZero = TDataType.SHORTINTTOK) and (ValType in UnsignedOrdinalTypes) then
      case TokenAt(i + 1).Kind of

        TTokenKind.EQTOK, TTokenKind.LTTOK, TTokenKind.LETOK: begin        // BYTE, WORD, CARDINAL '=', '<'. '<=' -X
          WarningAlwaysFalse(i + 2);
          WarningUnreachableCode(i + 2);
        end;

        TTokenKind.GTTOK, TTokenKind.GETOK: WarningAlwaysTrue(i + 2);  // BYTE, WORD, CARDINAL '>', '>=' -X
      end;


    //  writeln(ValType,',',RightValType,' / ',ConstValRight);

    if sLeft or sRight then
    else
      GetCommonType(j, ValType, RightValType);


    if VarType in RealTypes then
    begin
      if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
      if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
    end;


    // !!! exception !!! comparison of types of the same size but with different signs

    if ((ValType in SignedOrdinalTypes) and (RightValType in UnsignedOrdinalTypes)) or
      ((ValType in UnsignedOrdinalTypes) and (RightValType in SignedOrdinalTypes)) then
      if GetDataSize(ValType) = GetDataSize(RightValType) then
        { if ValType in UnsignedOrdinalTypes then} begin

        case GetDataSize(ValType) of
          1: begin

            if cRight and ((ConstValRight >= Low(Shortint)) and (ConstValRight <= High(Shortint))) then
              // when it does not exceed the range for the SHORTINT type
              RightValType := ValType
            else
            begin
              ExpandParam_m1(TDataType.SMALLINTTOK, ValType);
              ExpandParam(TDataType.SMALLINTTOK, RightValType);
              ValType := TDataType.SMALLINTTOK;
              RightValType := TDataType.SMALLINTTOK;
            end;

          end;

          2: begin

            if cRight and ((ConstValRight >= Low(Smallint)) and (ConstValRight <= High(Smallint))) then
              // when it does not exceed the range for the SMALLINT type
              RightValType := ValType
            else
            begin
              ExpandParam_m1(TDataType.INTEGERTOK, ValType);
              ExpandParam(TDataType.INTEGERTOK, RightValType);
              ValType := TDataType.INTEGERTOK;
              RightValType := TDataType.INTEGERTOK;
            end;

          end;
        end;

      end;

    ExpandExpression(ValType, RightValType, TDataType.UNTYPETOK);

    if sLeft or sRight then
    begin

      if (ValType in [TDataType.CHARTOK, TDataType.STRINGPOINTERTOK, TDataType.POINTERTOK]) and
        (RightValType in [TDataType.CHARTOK, TDataType.STRINGPOINTERTOK, TDataType.POINTERTOK]) then
      begin

        if (ValType = TDataType.POINTERTOK) or (RightValType = TDataType.POINTERTOK) then
          Error(i, 'Can''t determine PCHAR length, consider using COMPAREMEM');

        GenerateRelationString(TokenAt(i + 1).Kind, ValType, RightValType);
      end
      else
        GetCommonType(j, ValType, RightValType);

    end
    else
      GenerateRelation(TokenAt(i + 1).Kind, ValType);

    i := j;

    ValType := TDataType.BOOLEANTOK;
  end;

  Result := i;
end;  //CompileExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveBreakAddress;
begin

  Inc(BreakPosStackTop);

  BreakPosStack[BreakPosStackTop].ptr := CodeSize;
  BreakPosStack[BreakPosStackTop].brk := False;
  BreakPosStack[BreakPosStackTop].cnt := False;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RestoreBreakAddress;
begin

  if BreakPosStack[BreakPosStackTop].brk then asm65('b_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

  Dec(BreakPosStackTop);

  ResetOpty;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileBlockRead(var i: TTokenIndex; IdentIndex: TIdentIndex; IdentBlock: Integer): Integer;
var
  NumActualParams, idx: Integer;
  ActualParamType, AllocElementType: TDataType;
begin

  NumActualParams := 0;
  AllocElementType := TDataType.UNTYPETOK;

  repeat
    Inc(NumActualParams);

    StartOptimization(i);

    if NumActualParams > 3 then
      ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentBlock);

    if fBlockRead_ParamType[NumActualParams] in Pointers + [TDataType.UNTYPETOK] then
    begin

      if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
        Error(i + 2, TErrorCode.VariableExpected)
      else
      begin
        idx := GetIdentIndex(TokenAt(i + 2).Name);


        if (IdentifierAt(idx).Kind = TTokenKind.CONSTTOK) then
        begin

          if not (IdentifierAt(idx).DataType in Pointers) or (Elements(idx) = 0) then
            Error(i + 2, TErrorCode.VariableExpected);

        end
        else

          if (IdentifierAt(idx).Kind <> TTokenKind.VARTOK) then
            Error(i + 2, TErrorCode.VariableExpected);

      end;

      i := CompileAddress(i + 1, ActualParamType, AllocElementType, fBlockRead_ParamType[NumActualParams] in
        Pointers);

    end
    else
      i := CompileExpression(i + 2, ActualParamType);  // Evaluate actual parameters and push them onto the stack

    GetCommonType(i, fBlockRead_ParamType[NumActualParams], ActualParamType);

    ExpandParam(fBlockRead_ParamType[NumActualParams], ActualParamType);

    case NumActualParams of
      1: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.buffer');  // VAR LABEL;
      2: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.nrecord');
      // VAR LABEL: POINTER;
      3: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.numread');
    end;

  until TokenAt(i + 1).Kind <> TTokenKind.COMMATOK;

  if NumActualParams < 2 then
    ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentBlock);

  CheckTok(i + 1, TTokenKind.CPARTOK);

  Inc(i);

  Result := NumActualParams;

end;  //CompileBlockRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure UpdateCaseLabels(j: Integer; var tb: TCaseLabelArray; lab: TCaseLabel);
var
  i: Integer;
begin

  for i := 0 to High(tb) - 1 do
    if ((lab.left >= tb[i].left) and (lab.left <= tb[i].right)) or
      ((lab.right >= tb[i].left) and (lab.right <= tb[i].right)) or
      ((tb[i].left >= lab.left) and (tb[i].right <= lab.right)) then
      Error(j, 'Duplicate case label');

  i := High(tb);

  tb[i] := lab;

  SetLength(tb, i + 2);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckAssignment(i: Integer; IdentIndex: Integer);
begin

  if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.CONSTPASSING then
    Error(i, 'Can''t assign values to const variable');

  if IdentifierAt(IdentIndex).LoopVariable then
    Error(i, 'Illegal assignment to for-loop variable ''' + IdentifierAt(IdentIndex).Name + '''');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function CompileStatement(i: TTokenIndex; isAsm: Boolean = False): Integer;
var
  j, k, IdentIndex, IdentTemp, NumActualParams, NumCharacters, IfLocalCnt, CaseLocalCnt,
  NumCaseStatements, vlen: Integer;
  oldPass: TPass;
  oldCodeSize: Integer;
  Param: TParamList;
  IndirectionLevel: TIndirectionLevel;
  ExpressionType, ActualParamType, ConstValType, VarType, SelectorType: TDataType;
  Value, ConstVal, ConstVal2: Int64;
  Down, ExitLoop, yes, DEREFERENCE, ADDRESS: Boolean;        // To distinguish TO / DOWNTO loops
  CaseLabelArray: TCaseLabelArray;
  CaseLabel: TCaseLabel;
  forLoop: TForLoop;
  Name, EnumName, svar, par1, par2: String;
  forBPL: Byte;
begin
  Debugger.debugger.CompileStatement(i, isAsm);

  Result := i;

  //FillChar(Param, sizeof(Param), 0);
  Param := Default(TParamList);

  IdentIndex := 0;
  ExpressionType := TDataType.UNTYPETOK;

  par1 := '';
  par2 := '';

  StopOptimization;


  case TokenAt(i).Kind of

    TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK, TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK,
    TTokenKind.CHARTOK, TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK, TTokenKind.BOOLEANTOK,
    TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.SHORTREALTOK, TTokenKind.REALTOK,
    TTokenKind.SINGLETOK, TTokenKind.HALFSINGLETOK:  // type conversion operations
    begin

      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i, 'type identifier not allowed here');

      StartOptimization(i + 1);

      if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
        Error(i + 2, TErrorCode.VariableExpected)
      else
        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

      VarType := IdentifierAt(IdentIndex).DataType;

      if VarType <> TokenAt(i).GetDataType then
        Error(i, 'Argument cannot be assigned to');

      CheckTok(i + 3, TTokenKind.CPARTOK);

      if TokenAt(i + 4).Kind <> TTokenKind.ASSIGNTOK then
        Error(i + 4, TErrorCode.IllegalExpression);

      i := CompileExpression(i + 5, ExpressionType, VarType);

      GenerateAssignment(ASPOINTER, GetDataSize(VarType), IdentIndex);

      Result := i;

    end;


    TTokenKind.IDENTTOK:
    begin
      IdentIndex := GetIdentIndex(TokenAt(i).Name);

      if (IdentIndex > 0) and (IdentifierAt(IdentIndex).Kind = TTokenKind.FUNCTIONTOK) and
        (BlockStackTop > 1) and (TokenAt(i + 1).Kind <> TTokenKind.OPARTOK) then
        for j := NumIdent downto 1 do
          if (IdentifierAt(j).ProcAsBlock = NumBlocks) and (IdentifierAt(j).Kind = TTokenKind.FUNCTIONTOK) then
          begin
            if (IdentifierAt(j).Name = IdentifierAt(IdentIndex).Name) and
              (IdentifierAt(j).SourceFile.UnitIndex = IdentifierAt(IdentIndex).SourceFile.UnitIndex) then
              IdentIndex := GetIdentResult(NumBlocks);
            Break;
          end;


      if IdentIndex > 0 then

        case IdentifierAt(IdentIndex).Kind of


          TTokenKind.LABELTOK:
          begin
            CheckTok(i + 1, TTokenKind.COLONTOK);

            if IdentifierAt(IdentIndex).isInit then
              Error(i, 'Label already defined');

            IdentifierAt(IdentIndex).isInit := True;

            asm65(IdentifierAt(IdentIndex).Name);

            Result := i;

          end;


          TTokenKind.VARTOK, TTokenKind.TYPETOK:                // Variable or array element assignment
          begin

            VarType := TDataType.UNTYPETOK;

            StartOptimization(i + 1);


            if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
              (IdentifierAt(IdentIndex).AllocElementType = TDataType.PROCVARTOK) and
              (not (TokenAt(i + 1).Kind in [TTokenKind.ASSIGNTOK, TTokenKind.OBRACKETTOK])) then
            begin

              IdentTemp := GetIdentIndex('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

              CompileActualParameters(i, IdentTemp, IdentIndex);

              Result := i;
              exit;

            end;



            if IdentifierAt(IdentIndex).IdType = TDataType.DATAORIGINOFFSET then
            begin

              IdentTemp := GetIdentIndex(ExtractName(IdentIndex, IdentifierAt(IdentIndex).Name));

              if (IdentifierAt(IdentTemp).NumAllocElements_ > 0) and
                (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) and
                (IdentifierAt(IdentTemp).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                Error(i, TErrorCode.IllegalQualifier);

              //       writeln(IdentifierAt(IdentTemp).name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements_);

            end;



            IndirectionLevel := ASPOINTERTOPOINTER;


            if (IdentifierAt(IdentIndex).Kind = TYPETOK) and (TokenAt(i + 1).Kind <> OPARTOK) then
              Error(i + 1, TErrorCode.VariableExpected);


            if (TokenAt(i + 1).Kind = OPARTOK) and (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
              (Elements(IdentIndex) > 0) then
            begin

              //  writeln('= ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements);

              IndirectionLevel := ASPOINTERTODEREFERENCE;

              j := i;

              i := CompileAddress(i + 1, ExpressionType, VarType);


              //      writeln(ExpressionType,',',VarTYpe,',',Elements(GetIdent(TokenAt(j + 2).Name^)));

              if GetDataSize(VarType) <> Elements(IdentIndex) * GetDataSize(
                IdentifierAt(IdentIndex).AllocElementType) then
                if VarType = TDataType.UNTYPETOK then
                  Error(j + 2, 'Illegal type conversion: "POINTER" to "Array[0..' +
                    IntToStr(Elements(IdentIndex) - 1) + '] Of ' +
                    InfoAboutDataType(IdentifierAt(IdentIndex).AllocElementType) + '"')
                else
                  if Elements(GetIdentIndex(TokenAt(j + 2).Name)) = 0 then
                    Error(j + 2, 'Illegal type conversion: "' + InfoAboutDataType(VarType) +
                      '" to "' + IdentifierAt(IdentIndex).Name + '"')
                  else
                    Error(j + 2, 'Illegal type conversion: "Array[0..' +
                      IntToStr(Elements(GetIdentIndex(TokenAt(j + 2).Name)) - 1) + '] Of ' +
                      InfoAboutDataType(VarType) + '" to "' + IdentifierAt(IdentIndex).Name + '"');

              // perl
              CheckTok(i + 1, CPARTOK);

              Inc(i);

              CheckTok(i + 1, OBRACKETTOK);

              i := CompileArrayIndex(i, IdentIndex, VarType);

              CheckTok(i + 1, CBRACKETTOK);

              Inc(i);

              asm65(#9'lda :STACKORIGIN-1,x');
              asm65(#9'add :STACKORIGIN,x');
              asm65(#9'sta :STACKORIGIN-1,x');
              asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

              asm65(#9'dex');

            end
            else

              if TokenAt(i + 1).Kind = OPARTOK then
              begin        // (pointer)

                //  writeln('= ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).Kind,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType);

                if not (IdentifierAt(IdentIndex).DataType in [TDataType.POINTERTOK,
                  TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                  Error(i, TErrorCode.IllegalExpression);

                if IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK then
                  VarType := IdentifierAt(IdentIndex).AllocElementType
                else
                  VarType := IdentifierAt(IdentIndex).DataType;


                i := CompileExpression(i + 2, ExpressionType, TDataType.POINTERTOK);

                CheckTok(i + 1, TTokenKind.CPARTOK);


                if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                  (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) then
                begin

                  IndirectionLevel := ASPOINTERTODEREFERENCE;

                  CheckTok(i + 3, TTokenKind.IDENTTOK);
                  IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);    // (pointer^).field :=

                  if IdentTemp < 0 then
                    Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name + '''');

                  VarType := TDataType(IdentTemp shr 16);
                  par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                  Inc(i, 2);

                end
                else

                  if TokenAt(i + 2).Kind = TTokenKind.DEREFERENCETOK then
                  begin

                    IndirectionLevel := ASPOINTERTODEREFERENCE;

                    Inc(i);

                    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                      (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) then
                    begin

                      CheckTok(i + 3, TTokenKind.IDENTTOK);
                      IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);    // (pointer)^.field :=

                      if IdentTemp < 0 then
                        Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name + '''');

                      VarType := TDataType(IdentTemp shr 16);
                      par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                      Inc(i, 2);

                    end;

                  end
                  else
                  begin

                    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                      (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) then
                    begin

                      IndirectionLevel := ASPOINTERTODEREFERENCE;

                      CheckTok(i + 3, TTokenKind.IDENTTOK);
                      IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);    // (pointer).field :=

                      if IdentTemp < 0 then
                        Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name + '''');

                      VarType := TDataType(IdentTemp shr 16);
                      par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                      Inc(i, 2);

                    end;

                  end;


                Inc(i);

              end
              else

                if TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK then        // With dereferencing '^'
                begin

                  if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                    ErrorForIdentifier(i + 1, TErrorCode.IncompatibleTypeOf, IdentIndex);

                  if (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) and
                    (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                    VarType := TDataType.STRINGPOINTERTOK
                  else
                    VarType := IdentifierAt(IdentIndex).AllocElementType;

                  IndirectionLevel := ASPOINTERTOPOINTER;


                  //  writeln('= ',IdentifierAt(IdentIndex).name,',',VarTYpe,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).PassMethod);


                  if TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK then
                  begin        // pp^[index] :=

                    Inc(i);

                    if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                      ErrorForIdentifier(i + 1, TErrorCode.IncompatibleTypeOf, IdentIndex);

                    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

                    i := CompileArrayIndex(i, IdentIndex, VarType);

                    CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                  end
                  else

                    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                      (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) then
                    begin

                      CheckTok(i + 3, TTokenKind.IDENTTOK);
                      IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);

                      if IdentTemp < 0 then
                        Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name + '''');


                      if TokenAt(i + 4).Kind = TTokenKind.OBRACKETTOK then
                      begin        // pp^.field[index] :=

                        if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                          ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                        IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                        i := CompileArrayIndex(i + 3, GetIdentIndex(IdentifierAt(IdentIndex).Name +
                          '.' + TokenAt(i + 3).Name), VarType);

                        CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                      end
                      else
                      begin              // pp^.field :=

                        VarType := TDataType(IdentTemp shr 16);
                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                        if GetIdentIndex(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name) > 0 then
                          IdentIndex := GetIdentIndex(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name);

                        Inc(i, 2);

                      end;

                    end;

                  i := i + 1;
                end
                else if (TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK) then        // With indexing
                  begin

                    if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                      ErrorForIdentifier(i + 1, TErrorCode.IncompatibleTypeOf, IdentIndex);

                    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

                    j := i;

                    i := CompileArrayIndex(i, IdentIndex, VarType);

                    if VarType = TDataType.ARRAYTOK then
                    begin
                      IndirectionLevel := ASPOINTER;
                      VarType := TDataType.POINTERTOK;
                    end;


                    if TokenAt(i + 2).Kind = TTokenKind.DEREFERENCETOK then
                    begin
                      Inc(i);

                      Push(0, ASPOINTERTOARRAYORIGIN2, GetDataSize(VarType), IdentIndex, 0);

                    end;

                    // label.field[index] -> label + field[index]

                    if pos('.', IdentifierAt(IdentIndex).Name) > 0 then
                    begin      // record_ptr.field[index] :=

                      IdentTemp := GetIdentIndex(copy(IdentifierAt(IdentIndex).Name, 1,
                        pos('.', IdentifierAt(IdentIndex).Name) - 1));

                      if (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) and
                        (IdentifierAt(IdentTemp).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                      begin
                        IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                        svar := copy(IdentifierAt(IdentIndex).Name, pos('.', IdentifierAt(IdentIndex).Name) +
                          1, length(IdentifierAt(IdentIndex).Name));

                        IdentIndex := IdentTemp;

                        IdentTemp := RecordSize(IdentIndex, svar);

                        if IdentTemp < 0 then
                          Error(i + 3, 'identifier idents no member ''' + svar + '''');

                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);  // offset to record field -> 'svar'

                      end;

                    end;


                    //      writeln(IdentifierAt(IdentIndex).Name,',',vartype,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).Kind);//+ '.' + TokenAt(i + 3).Name);

                    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                      (TokenAt(i + 2).Kind = TTokenKind.DOTTOK) then
                    begin
                      IndirectionLevel := ASPOINTERTOARRAYRECORD;

                      CheckTok(i + 3, TTokenKind.IDENTTOK);
                      IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name);

                      if IdentTemp < 0 then
                        Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name + '''');


                      //         writeln('>',IdentifierAt(IdentIndex).Name+ '||' + TokenAt(i + 3).Name,',',IdentTemp shr 16,',',VarType,'||',TokenAt(i+4].Kind,',',IdentifierAt(GetIdentIndex(IdentifierAt(IdentIndex).Name+ '.' + TokenAt(i + 3).Name)].AllocElementTYpe);


                      if TokenAt(i + 4).Kind = TTokenKind.OBRACKETTOK then
                      begin        // array_to_record_pointers[x].field[index] :=

                        if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                          ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                        IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

                        i := CompileArrayIndex(i + 3, GetIdentIndex(IdentifierAt(IdentIndex).Name +
                          '.' + TokenAt(i + 3).Name), VarType);

                        CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                      end
                      else
                      begin                // array_to_record_pointers[x].field :=
                        //-------
                        VarType := TDataType(IdentTemp shr 16);
                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                        if GetIdentIndex(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name) > 0 then
                          IdentIndex := GetIdentIndex(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name);

                        if VarType = TDataType.STRINGPOINTERTOK then
                          IndirectionLevel := ASPOINTERTOARRAYRECORDTOSTRING;

                        Inc(i, 2);

                      end;

                    end
                    else
                      if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK, TDataType.PROCVARTOK] then
                        VarType := TDataType.POINTERTOK;

                    //CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                    Inc(i);

                  end
                  else                // Without dereferencing or indexing
                  begin

                    if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) then
                    begin
                      IndirectionLevel := ASPOINTERTOPOINTER;

                      if IdentifierAt(IdentIndex).AllocElementType = TDataType.UNTYPETOK then
                        VarType := IdentifierAt(IdentIndex).DataType      // RECORD.
                      else
                        VarType := IdentifierAt(IdentIndex).AllocElementType;

                    end
                    else
                    begin
                      IndirectionLevel := ASPOINTER;

                      VarType := IdentifierAt(IdentIndex).DataType;
                    end;

                    //  writeln('= ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', VarType,',',IndirectionLevel);

                  end;


            if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
              (IdentifierAt(IdentIndex).AllocElementType = TDataType.PROCVARTOK) and
              (TokenAt(i + 1).Kind <> TTokenKind.ASSIGNTOK) then
            begin

              IdentTemp := GetIdentIndex('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

              CompileActualParameters(i, IdentTemp, IdentIndex);

              if IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK then a65(TCode65.subBX);

              Result := i;
              exit;

            end
            else
              CheckTok(i + 1, TTokenKind.ASSIGNTOK);


            //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IndirectionLevel);


            if (IdentifierAt(IdentIndex).DataType = TDataType.PCHARTOK) and
              //         ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING)) ) and
              (IndirectionLevel = ASPOINTER) and (TokenAt(i + 2).Kind in
              [TTokenKind.STRINGLITERALTOK, TTokenKind.CHARLITERALTOK, TTokenKind.IDENTTOK]) then
            begin

              {$i include/compile_pchar.inc}

            end
            else

              if (IdentifierAt(IdentIndex).DataType in Pointers) and
                (IdentifierAt(IdentIndex).AllocElementType = TDataType.CHARTOK) and
                (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                ((IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or
                ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and
                (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING))) and
                (TokenAt(i + 2).Kind in [TTokenKind.STRINGLITERALTOK, TTokenKind.CHARLITERALTOK,
                TTokenKind.IDENTTOK]) then
              begin

                {$i include/compile_string.inc}

              end // if
              else
              begin                // Usual assignment

                if VarType = TDataType.UNTYPETOK then
                  Error(i, 'Assignments to formal parameters and open arrays are not possible');



                Result := CompileExpression(i + 2, ExpressionType, VarType);  // Right-hand side expression



                k := i + 2;


                RealTypeConversion(VarType, ExpressionType);

                if (VarType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) and
                  (ExpressionType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then
                  ExpressionType := VarType;


                if (VarType = TDataType.POINTERTOK) and (ExpressionType = TDataType.STRINGPOINTERTOK) then
                begin

                  if (IdentifierAt(IdentIndex).AllocElementType = TDataType.CHARTOK) then
                  begin  // +1
                    asm65(#9'lda :STACKORIGIN,x');
                    asm65(#9'add #$01');
                    asm65(#9'sta :STACKORIGIN,x');
                    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'adc #$00');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                  end
                  else
                    if IdentifierAt(IdentIndex).AllocElementType = TDataType.UNTYPETOK then
                      ErrorIncompatibleTypes(i + 1, TDataType.STRINGPOINTERTOK, TDataType.POINTERTOK)
                    else
                      GetCommonType(i + 1, IdentifierAt(IdentIndex).AllocElementType, TDataType.STRINGPOINTERTOK);

                end;


                if (TokenAt(i).Kind = TTokenKind.DEREFERENCETOK) and (VarType = TDataType.POINTERTOK) and
                  (ExpressionType = TDataType.RECORDTOK) then
                begin

                  ExpressionType := TDataType.RECORDTOK;
                  VarType := TDataType.RECORDTOK;

                end;


                //  if (TokenAt(k).Kind = TTokenKind.IDENTTOK) then
                //    writeln(IdentifierAt(IdentIndex).Name,'/',TokenAt(k).Name,',', VarType,':', ExpressionType,' - ', IdentifierAt(IdentIndex).DataType,':',IdentifierAt(IdentIndex).AllocElementType,':',IdentifierAt(IdentIndex).NumAllocElements,' | ',IdentifierAt(GetIdentIndex(TokenAt(k).Name)).DataType,':',IdentifierAt(GetIdentIndex(TokenAt(k).Name)).AllocElementType,':',IdentifierAt(GetIdentIndex(TokenAt(k).Name)).NumAllocElements ,' / ',IndirectionLevel)
                //  else
                //    writeln(IdentifierAt(IdentIndex).Name,',', VarType,',', ExpressionType,' - ', IdentifierAt(IdentIndex).DataType,':',IdentifierAt(IdentIndex).AllocElementType,':',IdentifierAt(IdentIndex).NumAllocElements,' / ',IndirectionLevel);


                if VarType <> ExpressionType then
                  if (ExpressionType = TDataType.POINTERTOK) and (TokenAt(k).Kind = TTokenKind.IDENTTOK) then
                    if (IdentifierAt(GetIdentIndex(TokenAt(k).Name)).DataType = TDataType.POINTERTOK) and
                      (IdentifierAt(GetIdentIndex(TokenAt(k).Name)).AllocElementType = TDataType.PROCVARTOK) then
                    begin

                      IdentTemp := GetIdentIndex('@FN' + IntToHex(
                        IdentifierAt(GetIdentIndex(TokenAt(k).Name)).NumAllocElements_, 4));

                      //CompileActualParameters(i, IdentTemp, GetIdentIndex(TokenAt(k).Name));

                      if IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK then
                        ExpressionType := IdentifierAt(IdentTemp).DataType;

                    end;


                CheckAssignment(i + 1, IdentIndex);

                if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2])
                {and not (IdentifierAt(IdentIndex).AllocElementType in [PROCEDURETOK, FUNC])} then
                begin

                  //  writeln(ExpressionType,' | ',IdentifierAt(IdentIndex).idtype,',', IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).Name,',',IndirectionLevel);
                  //  writeln(IdentifierAt(GetIdentIndex(IdentifierAt(IdentIndex).Name)].AllocElementType);


                  if (ExpressionType = TDataType.CHARTOK) and (IdentifierAt(IdentIndex).DataType =
                    TDataType.POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType =
                    TDataType.STRINGPOINTERTOK) then

                    IndirectionLevel := ASSTRINGPOINTER1TOARRAYORIGIN    // tab[ ] := 'a'

                  else
                    if IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                    begin

                      if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                        (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then

                      else
                        GetCommonType(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

                    end
                    else
                      GetCommonType(i + 1, IdentifierAt(IdentIndex).AllocElementType, ExpressionType);

                end
                else
                  if (IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) then
                  begin

                    if (ExpressionType in Pointers - [TDataType.STRINGPOINTERTOK]) and
                      (TokenAt(k).Kind = TTokenKind.IDENTTOK) then
                    begin

                      IdentTemp := GetIdentIndex(TokenAt(k).Name);

                      if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK) then
                        IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

        {if (TokenAt(i + 3).Kind <> TTokenKind.OBRACKETTOK) and ((Elements(IdentTemp) <> Elements(IdentIndex)) or (IdentifierAt(IdentTemp).AllocElementType <> IdentifierAt(IdentIndex).AllocElementType)) then
         Error(k, IncompatibleTypesArray, GetIdentIndex(TokenAt(k).Name), ExpressionType )
        else
         if (Elements(IdentTemp) > 0) and (TokenAt(i + 3).Kind <> TTokenKind.OBRACKETTOK) then
          Error(k, IncompatibleTypesArray, IdentTemp, ExpressionType )
        else}

                      if IdentifierAt(IdentTemp).AllocElementType = TDataType.RECORDTOK then
                      // GetCommonType(i + 1, VarType, TTokenKind.RECORDTOK)
                      else

                        if (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
                          (IdentifierAt(IdentTemp).AllocElementType <> TDataType.UNTYPETOK) and
                          (IdentifierAt(IdentTemp).AllocElementType <> IdentifierAt(IdentIndex).AllocElementType) and
                          (TokenAt(k + 1).Kind <> TTokenKind.OBRACKETTOK) then
                        begin

                          if ((IdentifierAt(IdentTemp).NumAllocElements >
                            0) {and (IdentifierAt(IdentTemp).AllocElementType <> TDataType.RECORDTOK)}) and
                            ((IdentifierAt(IdentIndex).NumAllocElements >
                            0) {and (IdentifierAt(IdentIndex).AllocElementType <> TDataType.RECORDTOK)}) then
                            ErrorIdentifierIncompatibleTypesArrayIdentifier(k, IdentTemp, IdentIndex)

                          else
                          begin

                            //      writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,':',IdentifierAt(IdentIndex).AllocElementType,':',IdentifierAt(IdentIndex).NumAllocElements,' | ',IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,':',IdentifierAt(IdentTemp).AllocElementType,':',IdentifierAt(IdentTemp).NumAllocElements);

                            if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                              (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
                              (IdentifierAt(IdentIndex).NumAllocElements = 0) and
                              (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) and
                              (IdentifierAt(IdentTemp).AllocElementType <> TDataType.UNTYPETOK) and
                              (IdentifierAt(IdentTemp).NumAllocElements = 0) then
                              Error(k, 'Incompatible types: got "^' +
                                InfoAboutDataType(IdentifierAt(IdentTemp).AllocElementType) +
                                '" expected "^' + InfoAboutDataType(IdentifierAt(IdentIndex).AllocElementType) + '"')
                            else
                              ErrorIdentifierIncompatibleTypesArray(k, IdentTemp, ExpressionType);

                          end;

                        end;

                    end
                    else
                      if (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                      begin

                        IdentTemp := GetIdentIndex(TokenAt(k).Name);

                        case IndirectionLevel of
                          ASPOINTER:
                            if (IdentifierAt(IdentIndex).AllocElementType <>
                              IdentifierAt(IdentTemp).AllocElementType) and not
                              (IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                              Error(k, 'Incompatible types: got "' +
                                GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                                '" expected "^' + GetTypeAtIndex(
                                IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"');

                          ASPOINTERTOPOINTER:
                            if (IdentifierAt(IdentIndex).AllocElementType <>
                              IdentifierAt(IdentTemp).AllocElementType) and not
                              (IdentifierAt(IdentTemp).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                              Error(k, 'Incompatible types: got "' +
                                GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                                '" expected "^' + GetTypeAtIndex(
                                IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"');
                          else
                            GetCommonType(i + 1, VarType, ExpressionType);

                        end;

                      end
                      else
                      begin

                        //     writeln('1> ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,', P:', IdentifierAt(IdentIndex).PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

                        if ((IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                          (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or
                          ((VarType = TDataType.STRINGPOINTERTOK) and (ExpressionType = TDataType.PCHARTOK))
                        then

                        else
                          if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                            Error(i, 'Incompatible types: got "' + InfoAboutDataType(ExpressionType) +
                              '" expected "' + GetTypeAtIndex(
                              IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"')
                          else
                            GetCommonType(i + 1, VarType, ExpressionType);

                      end;

                  end
                  else
                    if (VarType = TDataType.ENUMTOK) {and (TokenAt(k).Kind = TTokenKind.IDENTTOK)} then
                    begin

                      if (TokenAt(k).Kind = TTokenKind.IDENTTOK) then
                        IdentTemp := GetIdentIndex(TokenAt(k).Name)
                      else
                        IdentTemp := 0;

                      if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK) then
                        IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

                      if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = TTokenKind.TYPETOK) and
                        (IdentifierAt(IdentTemp).DataType = TDataType.ENUMTOK) then
                      begin

                        if IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements then
                          ErrorIncompatibleEnumIdentifiers(i, IdentTemp, IdentIndex);

                      end
                      else
                        if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = TTokenKind.ENUMTOK) then
                        begin

                          if IdentifierAt(IdentTemp).NumAllocElements <> IdentifierAt(IdentIndex).NumAllocElements then
                            ErrorIncompatibleEnumIdentifiers(i, IdentTemp, IdentIndex);

                        end
                        else
                          if (IdentTemp > 0) and (IdentifierAt(IdentTemp).DataType = TDataType.ENUMTOK) then
                          begin

                            if (IdentifierAt(IdentTemp).NumAllocElements <>
                              IdentifierAt(IdentIndex).NumAllocElements) then
                              ErrorIncompatibleEnumIdentifiers(i, IdentTemp, IdentIndex);

                          end
                          else
                            if (IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK) and
                              (ExpressionType in UnsignedOrdinalTypes + [TDataType.ENUMTOK]) then

                            else
                              ErrorIncompatibleEnumTypeIdentifier(i, ExpressionType, IdentIndex);
                    end
                    else
                    begin

                      if (TokenAt(k).Kind = TTokenKind.IDENTTOK) and (TokenAt(k + 1).Kind =
                        TTokenKind.SEMICOLONTOK) then
                        IdentTemp := GetIdentIndex(TokenAt(k).Name)
                      else
                        IdentTemp := 0;

                      if (IdentTemp > 0) and ((IdentifierAt(IdentTemp).Kind = TTokenKind.ENUMTOK) or
                        (IdentifierAt(IdentTemp).DataType = TDataType.ENUMTOK)) then
                      begin

                        if (IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements) then
                          ErrorIncompatibleEnumIdentifierType(i, IdentTemp, ExpressionType);

                      end
                      else
                        GetCommonType(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

                    end;


                ExpandParam(VarType, ExpressionType);           // :=

                IdentifierAt(IdentIndex).isInit := True;


                //  writeln(vartype,',',ExpressionType,',',IdentifierAt(IdentIndex).Name);

                //       writeln('0> ',IdentifierAt(IdentIndex).Name,',',VarType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', ExpressionType,',',IndirectionLevel);


                if (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) and
                  (IndirectionLevel <> ASPOINTERTODEREFERENCE) and
                  (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                  (IdentifierAt(IdentIndex).NumAllocElements = 0) and (ExpressionType <> TDataType.POINTERTOK) then
                begin

                  if (IdentifierAt(IdentIndex).AllocElementType in {IntegerTypes}OrdinalTypes) and
                    (ExpressionType in {IntegerTypes}OrdinalTypes) then

                  else
                    if IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK then
                    begin

                      if (ExpressionType in [TDataType.PCHARTOK, TDataType.STRINGPOINTERTOK]) and
                        (IdentifierAt(IdentIndex).AllocElementType = TDataType.CHARTOK) then

                      else
                        Error(i + 1, 'Incompatible types: got "' + InfoAboutDataType(ExpressionType) +
                          '" expected "' + IdentifierAt(IdentIndex).Name + '"');

                    end
                    else
                      GetCommonType(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

                end;


                if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) or
                  ((VarType = TDataType.POINTERTOK) and (ExpressionType in
                  [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then
                begin

                  ADDRESS := False;

                  if TokenAt(k).Kind = TTokenKind.ADDRESSTOK then
                  begin
                    Inc(k);

                    ADDRESS := True;
                  end;

                  if TokenAt(k).Kind <> TTokenKind.IDENTTOK then Error(k, TErrorCode.IdentifierExpected);

                  IdentTemp := GetIdentIndex(TokenAt(k).Name);


                  if IdentifierAt(IdentIndex).PassMethod = IdentifierAt(IdentTemp).PassMethod then
                    case IndirectionLevel of
                      ASPOINTER:
                        if (TokenAt(k + 1).Kind <> TTokenKind.DEREFERENCETOK) and
                          (IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) and
                          not (IdentifierAt(IdentTemp).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                          Error(k, 'Incompatible types: got "^' +
                            GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                            '" expected "' + GetTypeAtIndex(
                            IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"');

                      ASPOINTERTOPOINTER:
                        //         if {(TokenAt(i + 1).Kind <> TTokenKind.DEREFERENCETOK) and }(IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) and not ( IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] ) then
                        //          Error(k, 'Incompatible types: got "^' + GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +'" expected "' + GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"');
                      else
                        GetCommonType(i + 1, VarType, ExpressionType);

                    end;


                  if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                    (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                    (IdentifierAt(IdentIndex).PassMethod = IdentifierAt(IdentTemp).PassMethod) then
                  begin

                    //       writeln('2> ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements);

                    if IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK then
                      yes := IdentifierAt(IdentIndex).NumAllocElements <>
                        IdentifierAt(GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock)).NumAllocElements
                    else
                      yes := IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements;


                    if yes and (ADDRESS = False) and (ExpressionType in [TDataType.RECORDTOK,
                      TDataType.OBJECTTOK]) then
                      if (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) and
                        (IdentifierAt(IdentTemp).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                        Error(i, 'Incompatible types: got "^' +
                          GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                          '" expected "^' + GetTypeAtIndex(
                          IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"')
                      else
                        Error(i, 'Incompatible types: got "' +
                          GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                          '" expected "^' + GetTypeAtIndex(
                          IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"');

                  end;


                  if (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) or
                    ((ExpressionType = TDataType.POINTERTOK) and
                    (IdentifierAt(IdentTemp).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then
                  begin

                    svar := TokenAt(k).Name;

                    if (IdentifierAt(IdentTemp).DataType = TDataType.RECORDTOK) and
                      (IdentifierAt(IdentTemp).AllocElementType <> TDataType.RECORDTOK) then
                      Name := 'adr.' + svar
                    else
                      Name := svar;


                    if (IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK) then
                    begin
                      svar := GetLocalName(IdentTemp);

                      IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

                      Name := svar + '.adr.result';
                      svar := svar + '.result';
                    end;


                    DEREFERENCE := False;
                    if (TokenAt(k + 1).Kind = TTokenKind.DEREFERENCETOK) then
                    begin
                      Inc(k);

                      DEREFERENCE := True;
                    end;


                    if TokenAt(k + 1).Kind = TTokenKind.DOTTOK then
                    begin

                      CheckTok(k + 2, TTokenKind.IDENTTOK);

                      Name := svar + '.' + TokenAt(k + 2).Name;
                      IdentTemp := GetIdentIndex(Name);

                    end;

                    //writeln( IdentifierAt(IdentIndex).Name,',', IdentifierAt(IdentIndex).NumAllocElements, ',', IdentifierAt(IdentIndex).AllocElementType  ,' / ', IdentifierAt(IdentTemp).Name,',', IdentifierAt(IdentTemp).NumAllocElements,',',IdentifierAt(IdentTemp).AllocElementType );
                    //writeln( '>', IdentifierAt(IdentIndex).Name,',', IdentifierAt(IdentIndex).DataType, ',', IdentifierAt(IdentIndex).AllocElementTYpe );
                    //writeln( '>', IdentifierAt(IdentTemp).Name,',', IdentifierAt(IdentTemp).DataType, ',', IdentifierAt(IdentTemp).AllocElementTYpe );
                    //writeln(GetTypeAtIndex(5].Field[0].Name);

                    if IdentTemp > 0 then

                      if IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements then
                        // porownanie indeksow do tablicy TYPES
                        //      Error(i, IncompatibleTypeOf, IdentTemp);
                        if (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                          Error(i, 'Incompatible types: got "' +
                            GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                            '" expected "' + InfoAboutDataType(IdentifierAt(IdentIndex).DataType) + '"')
                        else
                          Error(i, 'Incompatible types: got "' +
                            GetTypeAtIndex(IdentifierAt(IdentTemp).NumAllocElements).Field[0].Name +
                            '" expected "' + GetTypeAtIndex(
                            IdentifierAt(IdentIndex).NumAllocElements).Field[0].Name + '"');


                    a65(TCode65.subBX);
                    StopOptimization;

                    ResetOpty;


                    if (IdentifierAt(IdentIndex).DataType = TDataType.RECORDTOK) and
                      (IdentifierAt(IdentTemp).DataType = TDataType.RECORDTOK) and
                      (IdentifierAt(IdentTemp).AllocElementType = TDataType.RECORDTOK) then
                    begin

                      if DEREFERENCE then
                      begin                // issue #98 fixed

                        asm65(#9'lda :bp2');
                        asm65(#9'add #' + Name + '-DATAORIGIN');
                        asm65(#9'sta :bp2');
                        asm65(#9'lda :bp2+1');
                        asm65(#9'adc #$00');
                        asm65(#9'sta :bp2+1');

                      end
                      else
                      begin

                        asm65(#9'sta :bp2');
                        asm65(#9'sty :bp2+1');

                      end;

{
            if RecordSize(IdentIndex) <= 8 then begin

       asm65(#9'ldy #$00');

       for j:=0 to RecordSize(IdentIndex)-1 do begin
        asm65(#9'lda (:bp2),y');
        asm65(#9'sta adr.'+IdentifierAt(IdentIndex).Name + '+' + IntToStr(j));

        if j <> RecordSize(IdentIndex)-1 then asm65(#9'iny');
       end;
}
                      if RecordSize(IdentIndex) <= 128 then
                      begin

                        asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                        asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

                      end
                      else
                        asm65(#9'@move ":bp2" ' + GetLocalName(IdentIndex) + ' #' +
                          IntToStr(RecordSize(IdentIndex)));

                    end
                    else
                      if (IdentifierAt(IdentIndex).DataType = TDataType.RECORDTOK) and
                        (IdentifierAt(IdentTemp).DataType = TDataType.RECORDTOK) and (RecordSize(IdentIndex) <= 8) then
                      begin

                        if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
                        begin

                          svar := GetLocalName(IdentIndex);
                          LoadBP2(IdentIndex, svar);

                          asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                          asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

                        end
                        else
                          if RecordSize(IdentIndex) = 1 then
                            asm65(#9' mva ' + Name + ' ' + GetLocalName(IdentIndex, 'adr.'))
                          else
                            asm65(#9':' + IntToStr(RecordSize(IdentIndex)) + ' mva ' + Name +
                              '+# ' + GetLocalName(IdentIndex, 'adr.') + '+#');

                      end
                      else
                        if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                          (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) then
                        begin

                          //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType ,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).pASSmETHOD);
                          //  writeln(IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType ,',',IdentifierAt(IdentTemp).NumAllocElements,'/',IdentifierAt(IdentTemp).NumAllocElements_,',',IdentifierAt(IdentTemp).pASSmETHOD);
                          //  writeln('--- ', IndirectionLevel);

                          asm65(#9'@move ' + Name + ' ' + GetLocalName(IdentIndex) + ' #' +
                            IntToStr(RecordSize(IdentIndex)));

                        end
                        else
                          if (IdentifierAt(IdentIndex).DataType = TDataType.RECORDTOK) and
                            (IdentifierAt(IdentTemp).DataType = TDataType.POINTERTOK) then
                          begin

                            //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType ,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).pASSmETHOD);
                            //  writeln(IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType ,',',IdentifierAt(IdentTemp).NumAllocElements,'/',IdentifierAt(IdentTemp).NumAllocElements_,',',IdentifierAt(IdentTemp).pASSmETHOD);
                            //  writeln('--- ', IndirectionLevel);


                            if IdentifierAt(IdentTemp).PassMethod = TParameterPassingMethod.VARPASSING then
                            begin

                              asm65(#9'mwy ' + GetLocalName(IdentTemp) + ' :bp2');

                              if RecordSize(IdentIndex) <= 128 then
                              begin

                                asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

                              end
                              else
                                asm65(#9'@move ":bp2" #' + GetLocalName(IdentIndex, 'adr.') +
                                  ' #' + IntToStr(RecordSize(IdentIndex)));

                            end
                            else

                              if RecordSize(IdentIndex) <= 128 then
                              begin

                                asm65(#9'mwy ' + GetLocalName(IdentTemp) + ' :bp2');

                                asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

                              end
                              else
                                asm65(#9'@move ' + Name + ' #' + GetLocalName(IdentIndex, 'adr.') +
                                  ' #' + IntToStr(RecordSize(IdentIndex)));

                          end
                          else
                          begin

                            if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
                            begin

                              svar := GetLocalName(IdentIndex);
                              LoadBP2(IdentIndex, svar);

                              if RecordSize(IdentIndex) <= 128 then
                              begin

                                asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

                              end
                              else
                                asm65(#9'@move #' + Name + ' ":bp2" #' + IntToStr(RecordSize(IdentIndex)));

                            end
                            else

                              if (pos('adr.', Name) > 0) and (RecordSize(IdentIndex) <= 128) then
                              begin

                                if IndirectionLevel = ASPOINTERTOARRAYORIGIN2 then
                                begin

                                  asm65(#9'lda' + GetStackVariable(0));
                                  asm65(#9'sta :bp2');
                                  asm65(#9'lda' + GetStackVariable(1));
                                  asm65(#9'sta :bp2+1');

                                end
                                else
                                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                                asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

                              end
                              else
                                asm65(#9'@move #' + Name + ' ' + GetLocalName(IdentIndex) +
                                  ' #' + IntToStr(RecordSize(IdentIndex)));

                          end;

                  end
                  else     // ExpressionType <> TTokenKind.RECORDTOK + TTokenKind.OBJECTTOK
                    GetCommonType(i + 1, ExpressionType, TDataType.RECORDTOK);

                end
                else

                  if// (TokenAt(k).Kind = TTokenKind.IDENTTOK) and
                  (VarType = TDataType.STRINGPOINTERTOK) and (ExpressionType in Pointers)
                  {and (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])} then
                  begin

                    //  writeln(IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType ,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).Name,',',IndirectionLevel,',',vartype,' || ',IdentifierAt(GetIdentIndex(TokenAt(k).Name)).NumAllocElements,',',IdentifierAt(GetIdentIndex(TokenAt(k).Name)).PassMethod);

                    //  writeln(address,',',TokenAt(k).kind,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).AllocElementType,' / ', VarType,',',ExpressionType,',',IndirectionLevel);


                    if (TokenAt(k).Kind <> TTokenKind.ADDRESSTOK) and (IndirectionLevel in
                      [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) and
                      (IdentifierAt(IdentIndex).AllocElementType = TDataType.STRINGPOINTERTOK) then
                    begin

                      if (TokenAt(k).Kind = TTokenKind.IDENTTOK) and
                        (IdentifierAt(GetIdentIndex(TokenAt(k).Name)).AllocElementType <> TDataType.UNTYPETOK) then
                        IndirectionLevel := ASSTRINGPOINTERTOARRAYORIGIN;

                      GenerateAssignment(IndirectionLevel, GetDataSize(VarType), IdentIndex);

                      StopOptimization;

                      ResetOpty;

                    end
                    else
                      GenerateAssignment(IndirectionLevel, GetDataSize(VarType), IdentIndex, par1, par2);

                  end
                  else


                  // dla PROC, FUNC -> IdentifierAt(GetIdentIndex(TokenAt(k).Name)).NumAllocElements -> oznacza liczbe parametrow takiej procedury/funkcji
                    if (VarType in Pointers) and ((ExpressionType in Pointers) and (TokenAt(k).Kind = TTokenKind.IDENTTOK)) and
                      (not (IdentifierAt(IdentIndex).AllocElementType in Pointers + [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
                      not (IdentifierAt(GetIdentIndex(TokenAt(k).Name)).AllocElementType in
                      Pointers + [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then
                    begin

                      j := Elements(IdentIndex) {IdentifierAt(IdentIndex).NumAllocElements} *
                        GetDataSize(IdentifierAt(IdentIndex).AllocElementType);

                      IdentTemp := GetIdentIndex(TokenAt(k).Name);

                      Name := 'adr.' + TokenAt(k).Name;
                      svar := TokenAt(k).Name;

                      if IdentTemp > 0 then
                      begin

                        if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then
                        begin

                          svar := GetLocalName(IdentTemp);

                          IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

                          Name := svar + '.adr.result';
                          svar := svar + '.result';

                        end;


                        //if (IdentifierAt(IdentIndex).NumAllocElements > 1) and (IdentifierAt(IdentTemp).NumAllocElements > 1) then begin
                        if (Elements(IdentIndex) > 1) and (Elements(IdentTemp) > 1) then
                        begin

                          //writeln(j,',', Elements(IdentTemp) );
                          // perl
                          if IdentifierAt(IdentTemp).AllocElementType <> TDataType.RECORDTOK then
                            if (j <> Integer(Elements(IdentTemp) {IdentifierAt(IdentTemp).NumAllocElements} *
                              GetDataSize(IdentifierAt(IdentTemp).AllocElementType))) then
                              if (IdentifierAt(IdentIndex).AllocElementType <>
                                IdentifierAt(IdentTemp).AllocElementType) or
                                ((IdentifierAt(IdentTemp).NumAllocElements <>
                                IdentifierAt(IdentIndex).NumAllocElements_) and
                                (IdentifierAt(IdentTemp).NumAllocElements_ = 0)) or
                                ((IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(
                                IdentTemp).NumAllocElements_) and (IdentifierAt(IdentIndex).NumAllocElements_ = 0))
                              then
                                ErrorIdentifierIncompatibleTypesArrayIdentifier(i, IdentTemp, IdentIndex);

{
           a65(TCode65.subBX);
        StopOptimization;

        ResetOpty;
}

                          if j <> Integer(Elements(IdentTemp) *
                            GetDataSize(IdentifierAt(IdentTemp).AllocElementType)) then
                          begin

                            if (IdentifierAt(IdentIndex).NumAllocElements_ > 0) and
                              ((IdentifierAt(IdentIndex).NumAllocElements_ =
                              IdentifierAt(IdentTemp).NumAllocElements) or
                              (IdentifierAt(IdentIndex).NumAllocElements_ =
                              IdentifierAt(IdentTemp).NumAllocElements_)) then
                            begin

                              // WriteLn(TokenAt(k].line,',', IdentifierAt(IdentTemp).NumAllocElements_);

                              if IdentifierAt(IdentTemp).NumAllocElements_ = 0 then
                              begin

                                asm65(#9'lda ' + GetLocalName(IdentIndex));
                                asm65(#9'add :STACKORIGIN-1,x');
                                asm65(#9'sta @move.dst');
                                asm65(#9'lda ' + GetLocalName(IdentIndex) + '+1');
                                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                                asm65(#9'sta @move.dst+1');

                                asm65(#9'lda ' + GetLocalName(IdentTemp));
                                asm65(#9'sta @move.src');
                                asm65(#9'lda ' + GetLocalName(IdentTemp) + '+1');
                                asm65(#9'sta @move.src+1');

                              end
                              else
                              begin
                                a65(TCode65.subBX);

                                asm65(#9'lda ' + GetLocalName(IdentIndex));
                                asm65(#9'add :STACKORIGIN-1,x');
                                asm65(#9'sta @move.dst');
                                asm65(#9'lda ' + GetLocalName(IdentIndex) + '+1');
                                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                                asm65(#9'sta @move.dst+1');

                                asm65(#9'lda ' + GetLocalName(IdentTemp));
                                asm65(#9'add :STACKORIGIN,x');
                                asm65(#9'sta @move.src');
                                asm65(#9'lda ' + GetLocalName(IdentTemp) + '+1');
                                asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                                asm65(#9'sta @move.src+1');

                              end;

                              a65(TCode65.subBX);
                              a65(TCode65.subBX);
                              StopOptimization;

                              ResetOpty;

                              asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements_ *
                                GetDataSize(IdentifierAt(IdentIndex).AllocElementType)));
                              asm65(#9'sta @move.cnt');
                              asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements_ *
                                GetDataSize(IdentifierAt(IdentIndex).AllocElementType)));
                              asm65(#9'sta @move.cnt+1');

                              asm65(#9'jsr @move');

                            end
                            else
                            begin

                              //writeln('2: ',IdentifierAt(IdentIndex).NumAllocElements);

                              asm65(#9'lda ' + GetLocalName(IdentIndex));
                              asm65(#9'sta @move.dst');
                              asm65(#9'lda ' + GetLocalName(IdentIndex) + '+1');
                              asm65(#9'sta @move.dst+1');

                              asm65(#9'lda ' + GetLocalName(IdentTemp));
                              asm65(#9'add :STACKORIGIN-1,x');
                              asm65(#9'sta @move.src');
                              asm65(#9'lda ' + GetLocalName(IdentTemp) + '+1');
                              asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                              asm65(#9'sta @move.src+1');

                              a65(TCode65.subBX);
                              a65(TCode65.subBX);
                              StopOptimization;

                              ResetOpty;

                              asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements *
                                GetDataSize(IdentifierAt(IdentIndex).AllocElementType)));
                              asm65(#9'sta @move.cnt');
                              asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements *
                                GetDataSize(IdentifierAt(IdentIndex).AllocElementType)));
                              asm65(#9'sta @move.cnt+1');

                              asm65(#9'jsr @move');

                            end;

                          end
                          else
                          begin

                            a65(TCode65.subBX);
                            StopOptimization;

                            ResetOpty;

                            if (j <= 4) and (IdentifierAt(IdentTemp).AllocElementType <> TDataType.RECORDTOK) then
                              asm65(#9':' + IntToStr(j) + ' mva ' + Name + '+# ' +
                                GetLocalName(IdentIndex, 'adr.') + '+#')
                            else
                              asm65(#9'@move ' + svar + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(j));

                          end;

                        end
                        else
                          GenerateAssignment(IndirectionLevel, GetDataSize(VarType), IdentIndex, par1, par2);

                      end
                      else
                        Error(k, TErrorCode.UnknownIdentifier);

                    end
                    else
                      GenerateAssignment(IndirectionLevel, GetDataSize(VarType), IdentIndex, par1, par2);

              end;

            //      StopOptimization;

          end;// VARIABLE



          TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK,
          TTokenKind.DESTRUCTORTOK:    // Procedure, Function (without assignment) call
          begin

            Param := NumActualParameters(i, IdentIndex, j);

            //    if IdentifierAt(IdentIndex).isOverload then begin
            IdentTemp := GetIdentProc(IdentifierAt(IdentIndex).Name, IdentIndex, Param, j);

            if IdentTemp = 0 then
              if IdentifierAt(IdentIndex).isOverload then
              begin

                if IdentifierAt(IdentIndex).NumParams <> j then
                  ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentIndex);

                ErrorForIdentifier(i, TErrorCode.CantDetermine, IdentIndex);
              end
              else
                ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentIndex);

            IdentIndex := IdentTemp;

            //    end;

            if (IdentifierAt(IdentIndex).isStdCall = False) then
              StartOptimization(i)
            else
              if common.optimize.use = False then StartOptimization(i);


            Inc(run_func);

            CompileActualParameters(i, IdentIndex);

            Dec(run_func);

            if IdentifierAt(IdentIndex).Kind = TTokenKind.FUNCTIONTOK then
            begin
              a65(TCode65.subBX);              // zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji
              StartOptimization(i);
            end;

            Result := i;
          end;  // PROC

          else
            Error(i, 'Assignment or procedure call expected but ' + IdentifierAt(IdentIndex).Name + ' found');
        end// case IdentifierAt(IdentIndex).Kind
      else
        Error(i, TErrorCode.UnknownIdentifier);
    end;

    TTokenKind.INFOTOK:
    begin

      if Pass = TPass.CODE_GENERATION then writeln('User defined: ' + msgLists.msgUser[TokenAt(i).Value]);

      Result := i;
    end;


    TTokenKind.WARNINGTOK:
    begin

      WarningUserDefined(i);

      Result := i;
    end;


    TTokenKind.ERRORTOK:
    begin

      if Pass = TPass.CODE_GENERATION then Error(i, TErrorCode.UserDefined);

      Result := i;
    end;


    TTokenKind.IOCHECKON:
    begin
      IOCheck := True;

      Result := i;
    end;


    TTokenKind.IOCHECKOFF:
    begin
      IOCheck := False;

      Result := i;
    end;


    TTokenKind.LOOPUNROLLTOK:
    begin
      loopunroll := True;

      Result := i;
    end;


    TTokenKind.NOLOOPUNROLLTOK:
    begin
      loopunroll := False;

      Result := i;
    end;


    TTokenKind.PROCALIGNTOK:
    begin
      codealign.proc := TokenAt(i).Value;

      Result := i;
    end;


    TTokenKind.LOOPALIGNTOK:
    begin
      codealign.loop := TokenAt(i).Value;

      Result := i;
    end;


    TTokenKind.LINKALIGNTOK:
    begin
      codealign.link := TokenAt(i).Value;

      Result := i;
    end;


    TTokenKind.GOTOTOK:
    begin
      CheckTok(i + 1, TTokenKind.IDENTTOK);

      IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

      if IdentIndex > 0 then
      begin

        if IdentifierAt(IdentIndex).Kind <> TTokenKind.LABELTOK then
          Error(i + 1, 'Identifier isn''t a label');

        asm65(#9'jmp ' + IdentifierAt(IdentIndex).Name);

      end
      else
        Error(i + 1, TErrorCode.UnknownIdentifier);

      Result := i + 1;
    end;


    TTokenKind.BEGINTOK:
    begin

      if isAsm then
        CheckTok(i, TTokenKind.ASMTOK);

      j := CompileStatement(i + 1);
      while (TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK) or
        ((TokenAt(j + 1).Kind = TTokenKind.COLONTOK) and (TokenAt(j).Kind = TTokenKind.IDENTTOK)) do
        j := CompileStatement(j + 2);

      CheckTok(j + 1, TTokenKind.ENDTOK);

      Result := j + 1;
    end;


    TTokenKind.CASETOK:
    begin
      CaseLocalCnt := CaseCnt;
      Inc(CaseCnt);

      ResetOpty;

      EnumName := '';

      StartOptimization(i);

      j := i + 1;

      i := CompileExpression(i + 1, SelectorType);


      if (TokenAt(j).Kind = TTokenKind.IDENTTOK) and (IdentifierAt(GetIdentIndex(TokenAt(j).Name)).Kind =
        TTokenKind.FUNCTIONTOK) and (IdentifierAt(GetIdentIndex(TokenAt(j).Name)).DataType = TDatatype.ENUMTOK) then

        //      if (SelectorType = TDatatype.ENUMTOK) and (TokenAt(j).Kind = TTokenKind.IDENTTOK) and
        //      (IdentifierAt(GetIdentIndex(TokenAt(j).Name)).Kind = TTokenKind.FUNCTIONTOK) then
      begin

        IdentTemp := GetIdentIndex(TokenAt(j).Name);

        SelectorType := IdentifierAt(GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock)).AllocElementType;

        EnumName := GetTypeAtIndex(IdentifierAt(GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock)).NumAllocElements).Field[0].Name;

      end
      else

        if (SelectorType = TDatatype.ENUMTOK) and (TokenAt(j).Kind = TTokenKind.IDENTTOK) and
          (IdentifierAt(GetIdentIndex(TokenAt(j).Name)).Kind = TTokenKind.TYPETOK) then
        begin

          IdentTemp := GetIdentIndex(TokenAt(j).Name);
          EnumName := GetEnumName(IdentTemp);

          SelectorType := IdentifierAt(IdentTemp).AllocElementType;

        end
        else
          if TokenAt(i).Kind = IDENTTOK then
          begin

            IdentTemp := GetIdentIndex(TokenAt(i).Name);
            EnumName := GetEnumName(IdentTemp);

          end;


      if SelectorType <> TDataType.ENUMTOK then
        if GetDataSize(SelectorType) <> 1 then
          Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

      if not (SelectorType in OrdinalTypes + [TDataType.ENUMTOK]) then
        Error(i, 'Ordinal variable expected as ''CASE'' selector');

      CheckTok(i + 1, TTokenKind.OFTOK);


      GenerateAssignment(ASPOINTER, GetDataSize(SelectorType), 0, '@CASETMP_' + IntToHex(CaseLocalCnt, 4));

      DefineIdent(i, '@CASETMP_' + IntToHex(CaseLocalCnt, 4), TTokenKind.VARTOK, SelectorType, 0, TDataType.UNTYPETOK, 0);

      GetIdentIndex('@CASETMP_' + IntToHex(CaseLocalCnt, 4));

      yes := True;

      NumCaseStatements := 0;

      Inc(i, 2);

      CaseLabelArray := nil;
      SetLength(CaseLabelArray, 1);

      repeat  // Loop over all cases

        //      yes:=false;

        repeat  // Loop over all constants for the current case
          i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

          //   ConstVal:=ConstVal and $ff;
          // Warning(i, RangeCheckError, 0, ConstValType, SelectorType);

          GetCommonType(i, ConstValType, SelectorType);

          if (TokenAt(i).Kind = TTokenKind.IDENTTOK) then
            if ((EnumName = '') and (GetEnumName(GetIdentIndex(TokenAt(i).Name)) <> '')) or
              ((EnumName <> '') and (GetEnumName(GetIdentIndex(TokenAt(i).Name)) <> EnumName)) then
              Error(i, 'Constant and CASE types do not match');


          if TokenAt(i + 1).Kind = TTokenKind.RANGETOK then            // Range check
          begin
            i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

            //    ConstVal2:=ConstVal2 and $ff;
            // Warning(i, RangeCheckError, 0, ConstValType, SelectorType);

            GetCommonType(i, ConstValType, SelectorType);

            if ConstVal > ConstVal2 then
              Error(i, 'Upper bound of case range is less than lower bound');

            GenerateCaseRangeCheck(ConstVal, ConstVal2, SelectorType, yes, CaseLocalCnt);

            yes := False;

            CaseLabel.left := ConstVal;
            CaseLabel.right := ConstVal2;
          end
          else
          begin
            GenerateCaseEqualityCheck(ConstVal, SelectorType, yes, CaseLocalCnt);    // Equality check

            yes := True;

            CaseLabel.left := ConstVal;
            CaseLabel.right := ConstVal;
          end;

          UpdateCaseLabels(i, CaseLabelArray, CaseLabel);

          Inc(i);

          ExitLoop := False;
          if TokenAt(i).Kind = TTokenKind.COMMATOK then
            Inc(i)
          else
            ExitLoop := True;

        until ExitLoop;


        CheckTok(i, TTokenKind.COLONTOK);

        GenerateCaseStatementProlog; //(CaseLabel.equality);

        ResetOpty;

        asm65('@');

        j := CompileStatement(i + 1);
        i := j + 1;
        GenerateCaseStatementEpilog(CaseLocalCnt);

        Inc(NumCaseStatements);

        ExitLoop := False;
        if TokenAt(i).Kind <> TTokenKind.SEMICOLONTOK then
        begin
          if TokenAt(i).Kind = TTokenKind.ELSETOK then        // Default statements
          begin

            j := CompileStatement(i + 1);
            while TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

            i := j + 1;
          end;
          ExitLoop := True;
        end
        else
        begin
          Inc(i);

          if TokenAt(i).Kind = TTokenKind.ELSETOK then
          begin
            j := CompileStatement(i + 1);
            while TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

            i := j + 1;
          end;

          if TokenAt(i).Kind = TTokenKind.ENDTOK then ExitLoop := True;

        end

      until ExitLoop;

      CheckTok(i, TTokenKind.ENDTOK);

      GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

      Result := i;
    end;


    TTokenKind.IFTOK:
    begin
      ifLocalCnt := ifCnt;
      Inc(ifCnt);

      //    ResetOpty;

      StartOptimization(i + 1);

      j := CompileExpression(i + 1, ExpressionType);
      // !!! VarType = TDataType.INTEGERTOK, 'IF BYTE+SHORTINT < BYTE'

      GetCommonType(j, TDataType.BOOLEANTOK, ExpressionType);  // wywali blad jesli warunek bedzie typu IF A THEN

      CheckTok(j + 1, TTokenKind.THENTOK);

      SaveToSystemStack(ifLocalCnt);    // Save conditional expression at expression stack top onto the system stack

      GenerateIfThenCondition;      // Satisfied if expression is not zero
      GenerateIfThenProlog;

      Inc(CodeSize);        // !!! aby dzialaly petle WHILE, REPEAT po IF

      j := CompileStatement(j + 2);

      GenerateIfThenEpilog;
      Result := j;

      if TokenAt(j + 1).Kind = TTokenKind.ELSETOK then
      begin

        RestoreFromSystemStack(ifLocalCnt);  // Restore conditional expression
        GenerateElseCondition;      // Satisfied if expression is zero
        GenerateIfThenProlog;

        optyBP2 := '';

        j := CompileStatement(j + 2);
        GenerateIfThenEpilog;

        Result := j;
      end
      else
        RemoveFromSystemStack;      // Remove conditional expression

    end;

    WITHTOK:
    begin

      Inc(CodeSize);        // !!! aby dzialaly zagniezdzone WHILE

      CheckTok(i + 1, IDENTTOK);

      IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);


      if (IdentifierAt(IdentIndex).Kind = TTokenKind.TYPETOK) and (IdentifierAt(IdentIndex).DataType in
        [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then

      else
        if (IdentifierAt(IdentIndex).Kind <> TTokenKind.VARTOK) then
          Error(i + 1, 'Expression type must be object or record type');


      if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
        (IdentifierAt(IdentIndex).AllocElementType = TDataType.RECORDTOK) then

      else
        if not (IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
          Error(i + 1, 'Expression type must be object or record type');

      CheckTok(i + 2, DOTOK);

      k := High(WithName);
      WithName[k] := IdentifierAt(IdentIndex).Name;
      SetLength(WithName, k + 2);

      Inc(i, 2);

      j := CompileStatement(i + 1);

      SetLength(WithName, k + 1);

      Result := j;

    end;

    {$IFDEF WHILEDO}

WHILETOK:
    begin
//    writeln(codesize,',',CodePosStackTop);

    inc(CodeSize);				// !!! aby dzialaly zagniezdzone WHILE

    asm65;
    asm65('; --- WhileProlog');

    ResetOpty;

    GenerateRepeatUntilProlog;			// Save return address used by GenerateWhileDoEpilog

    SaveBreakAddress;


    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType);


    GetCommonType(j, TDataType.BOOLEANTOK, ExpressionType);

    CheckTok(j + 1, TTokenKind.DOTOK);

      asm65;
      asm65('; --- WhileDoCondition');
      GenerateWhileDoCondition;			// Satisfied if expression is not zero

      asm65;
      asm65('; --- WhileDoProlog');
      GenerateWhileDoProlog;

      j := CompileStatement(j + 2);

      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      GenerateWhileDoEpilog;

      asm65('; --- WhileDoEpilog');

      RestoreBreakAddress;

      Result := j;

//    writeln('.',codesize,',',CodePosStackTop);

    end;

    {$ELSE}

    TTokenKind.WHILETOK:
    begin
      // writeln(codesize,',',CodePosStackTop);

      Inc(CodeSize);        // !!! aby dzialaly zagniezdzone WHILE


      if codealign.loop > 0 then
      begin
        asm65;
        asm65(#9'jmp @+');
        asm65(#9'.align $' + IntToHex(codealign.loop, 4));
        asm65('@');
        asm65;
      end;


      asm65;
      asm65('; --- WhileProlog');

      ResetOpty;

      Inc(CodeSize);

      Inc(CodePosStackTop);
      CodePosStack[CodePosStackTop] := CodeSize;

      asm65(#9'jmp l_' + IntToHex(CodePosStack[CodePosStackTop], 4));

      Inc(CodeSize);

      GenerateRepeatUntilProlog;      // Save return address used by GenerateWhileDoEpilog

      SaveBreakAddress;



      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := TPass.CALL_DETERMINATION;

      k := i;

      StartOptimization(i + 1);

      j := CompileExpression(i + 1, ExpressionType);

      GetCommonType(j, TDataType.BOOLEANTOK, ExpressionType);

      CheckTok(j + 1, TTokenKind.DOTOK);

      Pass := oldPass;
      CodeSize := oldCodeSize;


      Inc(CodePosStackTop);
      CodePosStack[CodePosStackTop] := CodeSize;

      j := CompileStatement(j + 2);

      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      Dec(CodePosStackTop);
      Dec(CodePosStackTop);
      GenerateAsmLabels(CodePosStack[CodePosStackTop]);

      StartOptimization(k + 1);

      CompileExpression(k + 1, ExpressionType);


      asm65('; --- WhileDoCondition');

      Gen;
      Gen;
      Gen;                // mov :eax, [bx]

      a65(TCode65.subBX);

      asm65(#9'lda :STACKORIGIN+1,x');
      asm65(#9'jne l_' + IntToHex(CodePosStack[CodePosStackTop + 1], 4));

      Dec(CodePosStackTop);

      asm65('; --- WhileDoEpilog');

      RestoreBreakAddress;

      Result := j;

      // writeln('.',codesize,',',CodePosStackTop);

    end;

    {$ENDIF}

    TTokenKind.REPEATTOK:
    begin
      Inc(CodeSize);          // !!! aby dzialaly zagniezdzone REPEAT

      if codealign.loop > 0 then
      begin
        asm65;
        asm65(#9'jmp @+');
        asm65(#9'.align $' + IntToHex(codealign.loop, 4));
        asm65('@');
        asm65;
      end;

      asm65;
      asm65('; --- RepeatUntilProlog');

      ResetOpty;

      GenerateRepeatUntilProlog;

      SaveBreakAddress;

      j := CompileStatement(i + 1);

      while TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

      CheckTok(j + 1, TTokenKind.UNTILTOK);

      StartOptimization(j + 2);

      j := CompileExpression(j + 2, ExpressionType);

      GetCommonType(j, TDataType.BOOLEANTOK, ExpressionType);

      asm65;
      asm65('; --- RepeatUntilCondition');
      GenerateRepeatUntilCondition;

      asm65;
      asm65('; --- RepeatUntilEpilog');

      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      GenerateRepeatUntilEpilog;

      RestoreBreakAddress;

      Result := j;
    end;


    TTokenKind.FORTOK:
    begin
      if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
        Error(i + 1, TErrorCode.IdentifierExpected)
      else
      begin
        IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

        Inc(CodeSize);          // !!! aby dzialaly zagniezdzone FOR

        if IdentIndex > 0 then
          if not ((IdentifierAt(IdentIndex).Kind = TTokenKind.VARTOK) and
            (IdentifierAt(IdentIndex).DataType in OrdinalTypes +
            Pointers) {and (IdentifierAt(IdentIndex).AllocElementType = TDataType.UNTYPETOK)}) then
            Error(i + 1, 'Ordinal variable expected as ''FOR'' loop counter')
          else
            if (IdentifierAt(IdentIndex).isInitialized) or (IdentifierAt(IdentIndex).PassMethod <>
              TParameterPassingMethod.VALPASSING) then
              Error(i + 1, 'Simple local variable expected as FOR loop counter')
            else
            begin

              IdentifierAt(IdentIndex).LoopVariable := True;


              if codealign.loop > 0 then
              begin
                asm65;
                asm65(#9'jmp @+');
                asm65(#9'.align $' + IntToHex(codealign.loop, 4));
                asm65('@');
                asm65;
              end;


              if TokenAt(i + 2).Kind = TTokenKind.INTOK then
              begin    // IN

                j := i + 3;

                if TokenAt(j).Kind = TTokenKind.STRINGLITERALTOK then
                begin

                  {$i include/for_in_stringliteral.inc}

                end
                else
                begin

                  {$i include/for_in_ident.inc}

                end;

              end
              else
              begin          // = TTokenKind.INTOK

                CheckTok(i + 2, TTokenKind.ASSIGNTOK);

                //      asm65;
                //      asm65('; --- For');

                j := i + 3;

                StartOptimization(j);

                forLoop.begin_const := False;
                forLoop.end_const := False;

                forBPL := 0;

                if SafeCompileConstExpression(j, ConstVal, ExpressionType,
                  IdentifierAt(IdentIndex).DataType, True) then
                begin
                  Push(ConstVal, ASVALUE, GetDataSize(IdentifierAt(IdentIndex).DataType));

                  forLoop.begin_value := ConstVal;
                  forLoop.begin_const := True;

                  forBPL := Ord(ConstVal < 128);

                end
                else
                begin
                  j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);

                  ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);
                end;

                if not (ExpressionType in OrdinalTypes) then
                  Error(j, TErrorCode.OrdinalExpectedFOR);

                ActualParamType := ExpressionType;


                GenerateAssignment(ASPOINTER, GetDataSize(IdentifierAt(IdentIndex).DataType), IdentIndex);  //!!!!!

                if not (TokenAt(j + 1).Kind in [TTokenKind.TOTOK, TTokenKind.DOWNTOTOK]) then
                  Error(j + 1, '''TO'' or ''DOWNTO'' expected but ' +
                    TokenList.GetTokenSpellingAtIndex(j + 1) + ' found')
                else
                begin
                  Down := TokenAt(j + 1).Kind = TTokenKind.DOWNTOTOK;


                  Inc(j, 2);

                  StartOptimization(j);

                  IdentTemp := -1;


                  {$IFDEF OPTIMIZECODE}

                  if SafeCompileConstExpression(j, ConstVal, ExpressionType,
                    IdentifierAt(IdentIndex).DataType, True) then
                  begin

                    Push(ConstVal, ASVALUE, GetDataSize(IdentifierAt(IdentIndex).DataType));
                    DefineIdent(j, '@FORTMP_' + IntToHex(CodeSize, 4), TTokenKind.CONSTTOK, IdentifierAt(IdentIndex).DataType,
                      IdentifierAt(IdentIndex).NumAllocElements, IdentifierAt(IdentIndex).AllocElementType,
                      ConstVal, TokenAt(j).GetDataType);

                    forLoop.end_value := ConstVal;
                    forLoop.end_const := True;

                    if ConstVal > 0 then forBPL := forBPL or 2;

                  end
                  else
                  begin

                    if ((TokenAt(j).Kind = TTokenKind.IDENTTOK) and (TokenAt(j + 1).Kind = TTokenKind.DOTOK)) or
                      ((TokenAt(j).Kind = TTokenKind.OPARTOK) and (TokenAt(j + 1).Kind = TTokenKind.IDENTTOK) and
                      (TokenAt(j + 2).Kind = TTokenKind.CPARTOK) and (TokenAt(j + 3).Kind = TTokenKind.DOTOK)) then
                    begin

                      if TokenAt(j).Kind = TTokenKind.IDENTTOK then
                        IdentTemp := GetIdentIndex(TokenAt(j).Name)
                      else
                        IdentTemp := GetIdentIndex(TokenAt(j + 1).Name);

                      j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);
                      ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);

                    end
                    else
                    begin
                      j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);
                      ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);
                      DefineIdent(j, '@FORTMP_' + IntToHex(CodeSize, 4), TTokenKind.VARTOK, IdentifierAt(IdentIndex).DataType,
                        IdentifierAt(IdentIndex).NumAllocElements, IdentifierAt(IdentIndex).AllocElementType, 1);
                    end;

                  end;

                  {$ELSE}

                  j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);
                  ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);
                  DefineIdent(j, '@FORTMP_' + IntToHex(CodeSize, 4), TTokenKind.VARTOK, IdentifierAt(IdentIndex).DataType,
                    IdentifierAt(IdentIndex).NumAllocElements, IdentifierAt(IdentIndex).AllocElementType, 0);

                  {$ENDIF}

                  if not (ExpressionType in OrdinalTypes) then
                    Error(j, TErrorCode.OrdinalExpectedFOR);


                  //    if GetDataSize( TDataType.ExpressionType] > GetDataSize( IdentifierAt(IdentIndex).DataType) then
                  //      Error(i, 'FOR loop counter variable type (' + InfoAboutToken(IdentifierAt(IdentIndex).DataType) + ') is smaller than the type of the maximum range (' + InfoAboutToken(ExpressionType) +')' );


                  if ((ActualParamType in UnsignedOrdinalTypes) and (ExpressionType in UnsignedOrdinalTypes)) or
                    ((ActualParamType in SignedOrdinalTypes) and (ExpressionType in SignedOrdinalTypes)) then
                  begin

                    if GetDataSize(ExpressionType) > GetDataSize(ActualParamType) then
                      ActualParamType := ExpressionType;
                    if GetDataSize(ActualParamType) > GetDataSize(IdentifierAt(IdentIndex).DataType) then
                      ActualParamType := IdentifierAt(IdentIndex).DataType;

                  end
                  else
                    ActualParamType := IdentifierAt(IdentIndex).DataType;


                  if IdentTemp < 0 then IdentTemp := GetIdentIndex('@FORTMP_' + IntToHex(CodeSize, 4));

                  GenerateAssignment(ASPOINTER, {GetDataSize( TDataType.IdentifierAt(IdentTemp).DataType]} GetDataSize(
                    ActualParamType), IdentTemp);

                  asm65;    // ; --- To


                  if loopunroll and forLoop.begin_const and forLoop.end_const then

                  else
                    GenerateRepeatUntilProlog;  // Save return address used by GenerateForToDoEpilog


                  SaveBreakAddress;

                  asm65('; --- ForToDoCondition');


                  if (ActualParamType = ExpressionType) and (GetDataSize(IdentifierAt(IdentTemp).DataType) >
                    GetDataSize(ActualParamType)) then
                    Note(j, 'FOR loop counter variable type is of larger size than required');


                  StartOptimization(j);
                  ResetOpty;      // !!!

                  yes := True;


                  if loopunroll and forLoop.begin_const and forLoop.end_const then
                  begin

                    CheckTok(j + 1, TTokenKind.DOTOK);

                    ConstVal := forLoop.begin_value;


                    if ((Down = False) and (forLoop.end_value >= forLoop.begin_value)) or
                      (Down and (forLoop.end_value <= forLoop.begin_value)) then
                    begin

                      while ConstVal <> forLoop.end_value do
                      begin

                        ResetOpty;

                        CompileStatement(j + 2);

                        if yes then
                        begin

                          if Down then
                            asm65('---unroll---')
                          else
                            asm65('+++unroll+++');

                          yes := False;
                        end
                        else
                          asm65('===unroll===');

                        if Down then
                          Dec(ConstVal)
                        else
                          Inc(ConstVal);

                        case GetDataSize(ActualParamType) of
                          1: begin
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex));
                          end;

                          2: begin
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex));
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                          end;

                          4: begin
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex));
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 16), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+2');
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 24), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+3');
                          end;

                        end;

                      end;

                      ResetOpty;

                      j := CompileStatement(j + 2);

                      asm65('===unroll===');

                      optyY := '';

                      case GetDataSize(ActualParamType) of
                        1: begin
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex));
                        end;

                        2: begin
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex));
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                        end;

                        4: begin
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex));
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 16), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex) + '+2');
                          asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 24), 2));
                          asm65(#9'sty ' + GetLocalName(IdentIndex) + '+3');
                        end;

                      end;

                    end
                    else  //if ((Down = false)
                      Error(j, 'for loop with invalid range');

                  end
                  else
                  begin

                    Push(IdentifierAt(IdentTemp).Value, ASPOINTER,
                      {GetDataSize( IdentifierAt(IdentTemp).DataType)} GetDataSize(ActualParamType), IdentTemp);

                    GenerateForToDoCondition(ActualParamType, Down, IdentIndex);
                    // Satisfied if counter does not reach the second expression value

                    CheckTok(j + 1, TTokenKind.DOTOK);

                    GenerateForToDoProlog;

                    j := CompileStatement(j + 2);

                  end;


                  //          StartOptimization(j);    !!! zaremowac aby dzialaly optymalizacje w TemporaryBuf

                  asm65;
                  asm65('; --- ForToDoEpilog');


                  if BreakPosStack[BreakPosStackTop].cnt then
                    asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));


                  if loopunroll and forLoop.begin_const and forLoop.end_const then

                  else
                    GenerateForToDoEpilog(ActualParamType, Down, IdentIndex, True, forBPL);


                  RestoreBreakAddress;

                  Result := j;

                end;

              end;  // if TokenAt(i + 2).Kind = TTokenKind.INTTOK

              IdentifierAt(IdentIndex).LoopVariable := False;

            end
        else
          Error(i + 1, TErrorCode.UnknownIdentifier);
      end;
    end;


    TTokenKind.ASSIGNFILETOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; AssignFile');

          if not ((IdentifierAt(IdentIndex).DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or
            (IdentifierAt(IdentIndex).AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK])) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          CheckTok(i + 3, TTokenKind.COMMATOK);

          StartOptimization(i + 4);

          if TokenAt(i + 4).Kind = TTokenKind.STRINGLITERALTOK then
            Note(i + 4, 'Only uppercase letters preceded by the drive symbol, like ''D:FILENAME.EXT'' or ''S:''');

          i := CompileExpression(i + 4, ActualParamType);
          GetCommonType(i, TDataType.POINTERTOK, ActualParamType);

          GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.pfname');

          StartOptimization(i);

          Push(0, ASVALUE, GetDataSize(TDataType.BYTETOK));

          GenerateAssignment(ASPOINTERTOPOINTER, 1, 0, IdentifierAt(IdentIndex).Name, 's@file.status');

          if (IdentifierAt(IdentIndex).DataType = TDataType.TEXTFILETOK) or
            (IdentifierAt(IdentIndex).AllocElementType = TDataType.TEXTFILETOK) then
          begin

            asm65(#9'ldy #s@file.buffer');
            asm65(#9'lda <@buf');
            asm65(#9'sta (:bp2),y');
            asm65(#9'iny');
            asm65(#9'lda >@buf');
            asm65(#9'sta (:bp2),y');

          end;

          Result := i + 1;
        end;


    TTokenKind.RESETTOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; Reset');

          if not ((IdentifierAt(IdentIndex).DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or
            (IdentifierAt(IdentIndex).AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK])) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          StartOptimization(i + 3);

          if TokenAt(i + 3).Kind <> TTokenKind.COMMATOK then
          begin
            if IdentifierAt(IdentIndex).NumAllocElements * GetDataSize(
              IdentifierAt(IdentIndex).AllocElementType) = 0 then
              Push(128, ASVALUE, 2)
            else
              Push(Integer(IdentifierAt(IdentIndex).NumAllocElements *
                GetDataSize(IdentifierAt(IdentIndex).AllocElementType)),
                ASVALUE, 2);
            // predefined record by FILE OF (default =128)

            Inc(i, 3);
          end
          else
          begin

            if (IdentifierAt(IdentIndex).DataType = TDataType.TEXTFILETOK) or
              (IdentifierAt(IdentIndex).AllocElementType = TDataType.TEXTFILETOK) then
              Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' +
                InfoAboutDataType(IdentifierAt(IdentIndex).DataType) + '" expected "File"');

            i := CompileExpression(i + 4, ActualParamType);       // custom record size
            GetCommonType(i, TDataType.WORDTOK, ActualParamType);

            ExpandParam(TDataType.WORDTOK, ActualParamType);

            Inc(i);
          end;

          CheckTok(i, TTokenKind.CPARTOK);

          GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.record');

          GenerateFileOpen(IdentIndex, TIOCode.FileMode);

          Result := i;
        end;


    TTokenKind.REWRITETOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; Rewrite');

          if not ((IdentifierAt(IdentIndex).DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or
            (IdentifierAt(IdentIndex).AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK])) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          StartOptimization(i + 3);

          if TokenAt(i + 3).Kind <> TTokenKind.COMMATOK then
          begin

            if IdentifierAt(IdentIndex).NumAllocElements * GetDataSize(
              IdentifierAt(IdentIndex).AllocElementType) = 0 then
              Push(128, ASVALUE, 2)
            else
              Push(Integer(IdentifierAt(IdentIndex).NumAllocElements *
                GetDataSize(IdentifierAt(IdentIndex).AllocElementType)),
                ASVALUE, 2);
            // predefined record by FILE OF (default =128)

            Inc(i, 3);
          end
          else
          begin

            if (IdentifierAt(IdentIndex).DataType = TDataType.TEXTFILETOK) or
              (IdentifierAt(IdentIndex).AllocElementType = TDataType.TEXTFILETOK) then
              Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' +
                InfoAboutDataType(IdentifierAt(IdentIndex).DataType) + '" expected "File"');

            i := CompileExpression(i + 4, ActualParamType);       // custom record size
            GetCommonType(i, TDataType.WORDTOK, ActualParamType);

            ExpandParam(TDataType.WORDTOK, ActualParamType);

            Inc(i);
          end;

          CheckTok(i, TTokenKind.CPARTOK);

          GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.record');

          GenerateFileOpen(IdentIndex, TIOCode.OpenWrite);

          Result := i;
        end;


    TTokenKind.APPENDTOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin

          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; Append');

          if not ((IdentifierAt(IdentIndex).DataType in [TDataType.TEXTFILETOK]) or
            (IdentifierAt(IdentIndex).AllocElementType in [TDataType.TEXTFILETOK])) then
            Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' +
              InfoAboutDataType(IdentifierAt(IdentIndex).DataType) + '" expected "Text"');

          if TokenAt(i + 3).Kind = TTokenKind.COMMATOK then
            Error(i, 'Wrong number of parameters specified for call to Append');

          StartOptimization(i + 3);

          CheckTok(i + 3, TTokenKind.CPARTOK);

          Push(1, ASVALUE, 2);

          GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.record');

          GenerateFileOpen(IdentIndex, TIOCode.Append);

          Result := i + 3;
        end;


    TTokenKind.GETRESOURCEHANDLETOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          if IdentifierAt(IdentIndex).DataType <> TDataType.POINTERTOK then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          CheckTok(i + 3, TTokenKind.COMMATOK);

          CheckTok(i + 4, TTokenKind.STRINGLITERALTOK);

          svar := '';

          for k := 1 to TokenAt(i + 4).StrLength do
            svar := svar + chr(StaticStringData[TokenAt(i + 4).StrAddress - CODEORIGIN + k]);

          //   writeln(svar,',',TokenAt(i+4].StrLength);

          CheckTok(i + 5, TTokenKind.CPARTOK);

          //  asm65;
          //  asm65('; GetResourceHandle');

          asm65(#9'lda <MAIN.@RESOURCE.' + svar);
          asm65(#9'sta ' + TokenAt(i + 2).Name);
          asm65(#9'lda >MAIN.@RESOURCE.' + svar);
          asm65(#9'sta ' + TokenAt(i + 2).Name + '+1');

          Inc(i, 5);

          Result := i;
        end;


    TTokenKind.SIZEOFRESOURCETOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          if not (IdentifierAt(IdentIndex).DataType in IntegerTypes) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          CheckTok(i + 3, TTokenKind.COMMATOK);

          CheckTok(i + 4, TTokenKind.STRINGLITERALTOK);

          svar := '';

          for k := 1 to TokenAt(i + 4).StrLength do
            svar := svar + chr(StaticStringData[TokenAt(i + 4).StrAddress - CODEORIGIN + k]);

          CheckTok(i + 5, TTokenKind.CPARTOK);

          //  asm65;
          //  asm65('; GetResourceHandle');

          asm65(#9'lda <MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
          asm65(#9'sta ' + TokenAt(i + 2).Name);

          asm65(#9'lda >MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
          asm65(#9'sta ' + TokenAt(i + 2).Name + '+1');

          Inc(i, 5);

          Result := i;
        end;


    TTokenKind.BLOCKREADTOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; BlockRead');

          if not ((IdentifierAt(IdentIndex).DataType = TDataType.FILETOK) or
            (IdentifierAt(IdentIndex).AllocElementType = TDataType.FILETOK)) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          CheckTok(i + 3, TTokenKind.COMMATOK);

          Inc(i, 2);

          NumActualParams := CompileBlockRead(i, IdentIndex, GetIdentIndex('BLOCKREAD'));

          GenerateFileRead(IdentIndex, TIOCode.Read, NumActualParams);

          Result := i;
        end;


    TTokenKind.BLOCKWRITETOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; BlockWrite');

          if not ((IdentifierAt(IdentIndex).DataType = TDataType.FILETOK) or
            (IdentifierAt(IdentIndex).AllocElementType = TDataType.FILETOK)) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          CheckTok(i + 3, TTokenKind.COMMATOK);

          Inc(i, 2);
          NumActualParams := CompileBlockRead(i, IdentIndex, GetIdentIndex('BLOCKWRITE'));

          GenerateFileRead(IdentIndex, TIOCode.Write, NumActualParams);

          Result := i;
        end;


    TTokenKind.CLOSEFILETOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
        Error(i + 1, TErrorCode.OParExpected)
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if IdentIndex = 0 then
            Error(i + 2, TErrorCode.UnknownIdentifier);

          //  asm65('; CloseFile');

          if not ((IdentifierAt(IdentIndex).DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or
            (IdentifierAt(IdentIndex).AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK])) then
            ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

          CheckTok(i + 3, TTokenKind.CPARTOK);

          GenerateFileOpen(IdentIndex, TIOCode.Close);

          Result := i + 3;
        end;


    TTokenKind.READLNTOK:
      if TokenAt(i + 1).Kind <> TTokenKind.OPARTOK then
      begin

        if TokenAt(i + 1).Kind = TTokenKind.SEMICOLONTOK then
        begin
          GenerateRead;

          Result := i;
        end
        else
          Error(i + 1, TErrorCode.OParExpected);

      end
      else
        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected)
        else
        begin
          IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

          if (IdentIndex > 0) and (IdentifierAt(identIndex).DataType = TDataType.TEXTFILETOK) then
          begin

            asm65(#9'lda #eol');
            asm65(#9'sta @buf');
            GenerateFileRead(IdentIndex, TIOCode.ReadRecord, 0);

            Inc(i, 3);

            CheckTok(i, TTokenKind.COMMATOK);
            CheckTok(i + 1, TTokenKind.IDENTTOK);

            if IdentifierAt(GetIdentIndex(TokenAt(i + 1).Name)).DataType <> TDataType.STRINGPOINTERTOK then
              Error(i + 1, TErrorCode.VariableExpected);

            IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

            asm65(#9'@moveRECORD ' + GetLocalName(IdentIndex));

            CheckTok(i + 2, TTokenKind.CPARTOK);

            Result := i + 2;

          end
          else

            if IdentIndex > 0 then
              if (IdentifierAt(IdentIndex).Kind <> TTokenKind.VARTOK)
              {or (IdentifierAt(IdentIndex).DataType <> TDataType.CHARTOK)} then
                ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex)
              else
              begin
                //      Push(IdentifierAt(IdentIndex).Value, ASVALUE, GetDataSize( TDataType.CHARTOK));

                GenerateRead;//(IdentifierAt(IdentIndex).Value);

                ResetOpty;

                if (IdentifierAt(IdentIndex).DataType in Pointers) and
                  (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                  (IdentifierAt(IdentIndex).AllocElementType = TDataType.CHARTOK) then
                begin     // string

                  asm65(#9'@move #@buf #' + GetLocalName(IdentIndex, 'adr.') + ' #' +
                    IntToStr(IdentifierAt(IdentIndex).NumAllocElements));

                end
                else
                  if (IdentifierAt(IdentIndex).DataType = TDataType.CHARTOK) then
                    asm65(#9'mva @buf+1 ' + IdentifierAt(IdentIndex).Name)
                  else
                    if (IdentifierAt(IdentIndex).DataType in IntegerTypes) then
                    begin

                      asm65(#9'@StrToInt #@buf');

                      case GetDataSize(IdentifierAt(IdentIndex).DataType) of

                        1: asm65(#9'mva :edx ' + IdentifierAt(IdentIndex).Name);

                        2: begin
                          asm65(#9'mva :edx ' + IdentifierAt(IdentIndex).Name);
                          asm65(#9'mva :edx+1 ' + IdentifierAt(IdentIndex).Name + '+1');
                        end;

                        4: begin
                          asm65(#9'mva :edx ' + IdentifierAt(IdentIndex).Name);
                          asm65(#9'mva :edx+1 ' + IdentifierAt(IdentIndex).Name + '+1');
                          asm65(#9'mva :edx+2 ' + IdentifierAt(IdentIndex).Name + '+2');
                          asm65(#9'mva :edx+3 ' + IdentifierAt(IdentIndex).Name + '+3');
                        end;

                      end;

                    end
                    else
                      ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

                CheckTok(i + 3, TTokenKind.CPARTOK);

                Result := i + 3;
              end
            else
              Error(i + 2, TErrorCode.UnknownIdentifier);
        end;

    TTokenKind.WRITETOK, TTokenKind.WRITELNTOK:
    begin

      StartOptimization(i);

      yes := (TokenAt(i).Kind = TTokenKind.WRITELNTOK);


      if (TokenAt(i + 1).Kind = TTokenKind.OPARTOK) and (TokenAt(i + 2).Kind = TTokenKind.CPARTOK) then Inc(i, 2);


      if TokenAt(i + 1).Kind = TTokenKind.SEMICOLONTOK then
      begin

      end
      else
      begin

        CheckTok(i + 1, TTokenKind.OPARTOK);

        Inc(i);

        if (TokenAt(i + 1).Kind = TTokenKind.IDENTTOK) and
          (IdentifierAt(GetIdentIndex(TokenAt(i + 1).Name)).DataType = TDataType.TEXTFILETOK) then
        begin

          IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

          Inc(i);
          CheckTok(i + 1, TTokenKind.COMMATOK);
          Inc(i);

          case TokenAt(i + 1).Kind of

            TTokenKind.IDENTTOK:          // variable (pointer to string)
            begin

              if IdentifierAt(GetIdentIndex(TokenAt(i + 1).Name)).DataType <> TDataType.STRINGPOINTERTOK then
                Error(i + 1, TErrorCode.VariableExpected);

              asm65(#9'mwy ' + GetLocalName(GetIdentIndex(TokenAt(i + 1).Name)) + ' :bp2');
              asm65(#9'ldy #$01');
              asm65(#9'mva:rne (:bp2),y @buf-1,y+');
              asm65(#9'lda (:bp2),y');

              if yes then
              begin                 // WRITELN

                asm65(#9'tay');
                asm65(#9'lda #eol');
                asm65(#9'sta @buf,y');

                asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                asm65(#9'ldy #s@file.nrecord');
                asm65(#9'lda #$00');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda #$01');
                asm65(#9'sta (:bp2),y');

                GenerateFileRead(IdentIndex, TIOCode.WriteRecord, 0);

              end
              else
              begin                // WRITE

                asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                asm65(#9'ldy #s@file.nrecord');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda #$00');
                asm65(#9'sta (:bp2),y');

                GenerateFileRead(IdentIndex, TIOCode.Write, 0);

              end;

              Inc(i, 2);

            end;

            TTokenKind.STRINGLITERALTOK:            // 'text'
            begin
              asm65(#9'ldy #$00');
              asm65(#9'mva:rne CODEORIGIN+$' + IntToHex(TokenAt(i + 1).StrAddress - CODEORIGIN + 1, 4) + ',y @buf,y+');

              if yes then
              begin                 // WRITELN

                asm65(#9'lda #eol');
                asm65(#9'ldy CODEORIGIN+$' + IntToHex(TokenAt(i + 1).StrAddress - CODEORIGIN, 4));
                asm65(#9'sta @buf,y');

                asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                asm65(#9'ldy #s@file.nrecord');
                asm65(#9'lda #$00');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda #$01');
                asm65(#9'sta (:bp2),y');

                GenerateFileRead(IdentIndex, TIOCode.WriteRecord, 0);

              end
              else
              begin                // WRITE

                asm65(#9'lda CODEORIGIN+$' + IntToHex(TokenAt(i + 1).StrAddress - CODEORIGIN, 4));

                asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                asm65(#9'ldy #s@file.nrecord');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda #$00');
                asm65(#9'sta (:bp2),y');

                GenerateFileRead(IdentIndex, TIOCode.Write, 0);

              end;

              Inc(i, 2);
            end;


            TTokenKind.INTNUMBERTOK:            // 0..9
            begin
              asm65(#9'txa:pha');

              Push(TokenAt(i + 1).Value, ASVALUE, GetDataSize(TDataType.CARDINALTOK));

              asm65(#9'@ValueToRec #@printINT');

              asm65(#9'pla:tax');

              if yes then
              begin                 // WRITELN

                asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                asm65(#9'ldy #s@file.nrecord');
                asm65(#9'lda #$00');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda #$01');
                asm65(#9'sta (:bp2),y');

                GenerateFileRead(IdentIndex, TIOCode.WriteRecord, 0);

              end
              else
              begin                // WRITE

                asm65(#9'tya');

                asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                asm65(#9'ldy #s@file.nrecord');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda #$00');
                asm65(#9'sta (:bp2),y');

                GenerateFileRead(IdentIndex, TIOCode.Write, 0);

              end;

              Inc(i, 2);
            end;

          end;

          yes := False;

        end
        else

          repeat

            case TokenAt(i + 1).Kind of

              TTokenKind.CHARLITERALTOK:
              begin           // #65#32#77
                Inc(i);

                repeat
                  asm65(#9'@print #$' + IntToHex(TokenAt(i).Value, 2));
                  Inc(i);
                until TokenAt(i).Kind <> TTokenKind.CHARLITERALTOK;

              end;

              TTokenKind.STRINGLITERALTOK:            // 'text'
                repeat
                  GenerateWriteString(TokenAt(i + 1).StrAddress, ASPOINTER);
                  Inc(i, 2);
                until TokenAt(i + 1).Kind <> TTokenKind.STRINGLITERALTOK;

              else

              begin

                j := i + 1;

                i := CompileExpression(j, ExpressionType);


                if (ExpressionType = TDataType.CHARTOK) and (TokenAt(i).Kind = TTokenKind.DEREFERENCETOK) and
                  (TokenAt(i - 1).Kind <> TTokenKind.IDENTTOK) then
                begin

                  asm65(#9'lda :STACKORIGIN,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');
                  asm65(#9'ldy #$00');
                  asm65(#9'lda (:bp2),y');
                  asm65(#9'sta :STACKORIGIN,x');

                end;

                //    if ExpressionType = TDataType.ENUMTOK then
                //      GenerateWriteString(TokenAt(i).Value, ASVALUE, TTokenKind.INTEGERTOK)    // Enumeration argument
                //    else

                if (ExpressionType in IntegerTypes) then
                  GenerateWriteString(TokenAt(i).Value, ASVALUE, ExpressionType)  // Integer argument
                else if (ExpressionType = TDataType.BOOLEANTOK) then
                    GenerateWriteString(TokenAt(i).Value, ASBOOLEAN_)      // Boolean argument
                  else if (ExpressionType = TDataType.CHARTOK) then
                      GenerateWriteString(TokenAt(i).Value, ASCHAR)      // Character argument
                    else if ExpressionType = TDataType.REALTOK then
                        GenerateWriteString(TokenAt(i).Value, ASREAL)      // Real argument
                      else if ExpressionType = TDataType.SHORTREALTOK then
                          GenerateWriteString(TokenAt(i).Value, ASSHORTREAL)      // ShortReal argument
                        else if ExpressionType = TDataType.HALFSINGLETOK then
                            GenerateWriteString(TokenAt(i).Value, ASHALFSINGLE)      // Half Single argument
                          else if ExpressionType = TDataType.SINGLETOK then
                              GenerateWriteString(TokenAt(i).Value, ASSINGLE)      // Single argument
                            else if ExpressionType in Pointers then
                              begin

                                if TokenAt(j).Kind = TTokenKind.ADDRESSTOK then
                                  IdentIndex := GetIdentIndex(TokenAt(j + 1).Name)
                                else
                                  if TokenAt(j).Kind = TTokenKind.IDENTTOK then
                                    IdentIndex := GetIdentIndex(TokenAt(j).Name)
                                  else
                                    Error(i, TErrorCode.CantReadWrite);


                                //  writeln(IdentifierAt(IdentIndex).Name,',',ExpressionType,' | ',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).Kind);


                                if (IdentifierAt(IdentIndex).AllocElementType = TDataType.PROCVARTOK) then
                                begin

                                  IdentTemp :=
                                    GetIdentIndex('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

                                  if IdentifierAt(IdentTemp).Kind = TTokenKind.FUNCTIONTOK then
                                    ExpressionType := IdentifierAt(IdentTemp).DataType
                                  else
                                    ExpressionType := TDataType.UNTYPETOK;


                                  if (ExpressionType = TDataType.STRINGPOINTERTOK) then
                                    GenerateWriteString(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER,
                                      TDataType.POINTERTOK)
                                  else if (ExpressionType in IntegerTypes) then
                                      GenerateWriteString(TokenAt(i).Value, ASVALUE, ExpressionType)
                                    // Integer argument
                                    else if (ExpressionType = TDataType.BOOLEANTOK) then
                                        GenerateWriteString(TokenAt(i).Value, ASBOOLEAN_)      // Boolean argument
                                      else if (ExpressionType = TDataType.CHARTOK) then
                                          GenerateWriteString(TokenAt(i).Value, ASCHAR)      // Character argument
                                        else if ExpressionType = TDataType.REALTOK then
                                            GenerateWriteString(TokenAt(i).Value, ASREAL)      // Real argument
                                          else if ExpressionType = TDataType.SHORTREALTOK then
                                              GenerateWriteString(TokenAt(i).Value, ASSHORTREAL)
                                            // ShortReal argument
                                            else if ExpressionType = TDataType.HALFSINGLETOK then
                                                GenerateWriteString(TokenAt(i).Value, ASHALFSINGLE)
                                              // Half Single argument
                                              else if ExpressionType = TDataType.SINGLETOK then
                                                  GenerateWriteString(TokenAt(i).Value, ASSINGLE)
                                                // Single argument
                                                else
                                                  Error(i, TErrorCode.CantReadWrite);

                                end
                                else
                                  if (ExpressionType = TDataType.STRINGPOINTERTOK) or
                                    (IdentifierAt(IdentIndex).Kind = TTokenKind.FUNCTIONTOK) or
                                    ((ExpressionType = TDataType.POINTERTOK) and
                                    (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK)) then
                                    GenerateWriteString(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER,
                                      IdentifierAt(IdentIndex).DataType)
                                  else
                                    if (ExpressionType = TDataType.PCHARTOK) or
                                      (IdentifierAt(IdentIndex).AllocElementType in
                                      [TDataType.CHARTOK, TDataType.POINTERTOK]) then
                                      GenerateWriteString(IdentifierAt(IdentIndex).Value,
                                        ASPCHAR, IdentifierAt(IdentIndex).DataType)
                                    else
                                      Error(i, TErrorCode.CantReadWrite);

                              end
                              else
                                Error(i, TErrorCode.CantReadWrite);

              end;

                Inc(i);

            end;

            j := 0;

            ActualParamType := ExpressionType;

            if TokenAt(i).Kind = TTokenKind.COLONTOK then      // pomijamy formatowanie wyniku value:x:x
              repeat
                i := CompileExpression(i + 1, ExpressionType);
                a65(TCode65.subBX);          // zdejmujemy ze stosu
                Inc(i);

                Inc(j);

                if j > 2 - Ord(ActualParamType in OrdinalTypes) then// Break;      // maksymalnie :x:x
                  Error(i + 1, 'Illegal use of '':''');

              until TokenAt(i).Kind <> TTokenKind.COLONTOK;


          until TokenAt(i).Kind <> TTokenKind.COMMATOK;     // repeat

        CheckTok(i, TTokenKind.CPARTOK);

      end; // if TokenAt(i + 1).Kind = TTokenKind.SEMICOLONTOK

      if yes then a65(TCode65.putEOL);

      StopOptimization;

      Result := i;

    end;


    TTokenKind.ASMTOK:
    begin

      ResetOpty;

      StopOptimization;      // takich blokow nie optymalizujemy

      asm65;
      asm65('; -------------------  ASM Block ' + format('%.8d', [AsmBlockIndex]) + '  -------------------');
      asm65;


      if isInterrupt and ((pos(' :bp', AsmBlock[AsmBlockIndex]) > 0) or
        (pos(' :STACK', AsmBlock[AsmBlockIndex]) > 0)) then
      begin

        if (pos(' :bp', AsmBlock[AsmBlockIndex]) > 0) then
          Error(i, 'Illegal instruction in INTERRUPT block '':BP''');
        if (pos(' :STACK', AsmBlock[AsmBlockIndex]) > 0) then
          Error(i, 'Illegal instruction in INTERRUPT block '':STACKORIGIN''');

      end;


      asm65('#asm:' + IntToStr(AsmBlockIndex));


      //     if (OutputDisabled=false) and (Pass = CODE_GENERATION) then WriteOut(AsmBlock[AsmBlockIndex]);

      Inc(AsmBlockIndex);

      if isAsm and (TokenAt(i).Value = 0) then
      begin

        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
        Inc(i);

        CheckTok(i + 1, TTokenKind.ENDTOK);
        Inc(i);

      end;

      Result := i;

    end;


    TTokenKind.INCTOK, TTokenKind.DECTOK:
      // dwie wersje
      // krotka i szybka, jesli mamy jeden parametr, np. INC(VAR), DEC(VAR)
      // dluga i wolna, jesli mamy tablice lub dwa parametry, np. INC(TMP[1]), DEC(VAR, VALUE+12)
    begin

      Value := 0;
      ExpressionType := TDataType.UNTYPETOK;
      NumActualParams := 0;

      Down := (TokenAt(i).Kind = TTokenKind.DECTOK);

      CheckTok(i + 1, TTokenKind.OPARTOK);

      Inc(i, 2);

      if TokenAt(i).Kind = TTokenKind.IDENTTOK then
      begin          // first parameter
        IdentIndex := GetIdentIndex(TokenAt(i).Name);

        CheckAssignment(i, IdentIndex);

        if IdentIndex = 0 then
          Error(i, TErrorCode.UnknownIdentifier);

        if IdentifierAt(IdentIndex).Kind = TTokenKind.VARTOK then
        begin

          ExpressionType := IdentifierAt(IdentIndex).DataType;

          if ExpressionType = TDataType.CHARTOK then ExpressionType := TDataType.BYTETOK;
          // wyjatkowo TTokenKind.CHARTOK -> TTokenKind.BYTETOK

          if {((IdentifierAt(IdentIndex).DataType in Pointers) and
       (IdentifierAt(IdentIndex).NumAllocElements=0)) or}
          (IdentifierAt(IdentIndex).DataType = TDataType.REALTOK) then
            Error(i, 'Left side cannot be assigned to')
          else
          begin
            Value := IdentifierAt(IdentIndex).Value;

            if ExpressionType in Pointers then
            begin      // Alloc Element Type
              ExpressionType := TDataType.WORDTOK;

              if pos('mw? ' + TokenAt(i).Name, optyBP2) > 0 then optyBP2 := '';
            end;

          end;

        end
        else
          Error(i, 'Left side cannot be assigned to');

      end
      else
        Error(i, TErrorCode.IdentifierExpected);


      StartOptimization(i);

      IndirectionLevel := ASPOINTER;


      if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
        ExpressionType := IdentifierAt(IdentIndex).AllocElementType
      else
        if IdentifierAt(IdentIndex).DataType in Pointers then
          ExpressionType := TDataType.WORDTOK
        else
          ExpressionType := IdentifierAt(IdentIndex).DataType;


      if IdentifierAt(IdentIndex).AllocElementType = TDataType.REALTOK then
        Error(i, TErrorCode.OrdinalExpExpected);


      if not (IdentifierAt(IdentIndex).idType in [TDataType.PCHARTOK]) and
        (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) and
        (not (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then
      begin

        if TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK then
        begin      // array index

          ExpressionType := IdentifierAt(IdentIndex).AllocElementType;

          IndirectionLevel := ASPOINTERTOARRAYORIGIN;

          i := CompileArrayIndex(i, IdentIndex, ExpressionType);

          CheckTok(i + 1, TTokenKind.CBRACKETTOK);

          Inc(i);

        end
        else
          if TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK then
            Error(i + 1, TErrorCode.IllegalQualifier)
          else
            ErrorIncompatibleTypes(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

      end
      else

      //          if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements = 0) and (IdentifierAt(IdentIndex).AllocElementType <> 0) then begin

        if TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK then
        begin        // typed pointer: PByte[], Pword[] ...

          IndirectionLevel := ASPOINTERTOARRAYORIGIN;

          i := CompileArrayIndex(i, IdentIndex, ExpressionType);

          CheckTok(i + 1, TTokenKind.CBRACKETTOK);

          Inc(i);

        end
        else

          if TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK then
            if IdentifierAt(IdentIndex).AllocElementType = TDataType.UNTYPETOK then
              Error(i + 1, TErrorCode.CantAdrConstantExp)
            else
            begin

              ExpressionType := IdentifierAt(IdentIndex).AllocElementType;

              IndirectionLevel := ASPOINTERTOPOINTER;

              Inc(i);

            end;


      if TokenAt(i + 1).Kind = TTokenKind.COMMATOK then
      begin        // potencjalnie drugi parametr

        j := i + 2;
        yes := False;

        if SafeCompileConstExpression(j, ConstVal, ActualParamType,
          { IdentifierAt(IdentIndex).DataType } ExpressionType, True) then
          yes := True
        else
          j := CompileExpression(j, ActualParamType);

        i := j;

        GetCommonType(i, ExpressionType, ActualParamType);

        Inc(NumActualParams);

        if IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING then
        begin

          if yes = False then ExpandParam(ExpressionType, ActualParamType);

          if (IdentifierAt(IdentIndex).DataType in Pointers) and
            (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
          begin

            if yes then
              Push(ConstVal * RecordSize(IdentIndex), ASVALUE, 2)
            else
              Error(i, '-- under construction --');

          end
          else
            if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements = 0) and
              (IdentifierAt(IdentIndex).AllocElementType in OrdinalTypes) and
              (IndirectionLevel <> ASPOINTERTOPOINTER) then
            begin      // zwieksz o N * DATASIZE jesli to wskaznik ale nie tablica

              if yes then
              begin

                if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
                  Push(ConstVal, ASVALUE, GetDataSize(IdentifierAt(IdentIndex).DataType))
                else
                  Push(ConstVal * GetDataSize(IdentifierAt(IdentIndex).AllocElementType), ASVALUE,
                    GetDataSize(IdentifierAt(IdentIndex).DataType));

              end
              else
                GenerateIndexShift(IdentifierAt(IdentIndex).AllocElementType);    // * DATASIZE

            end
            else
              if yes then Push(ConstVal, ASVALUE, GetDataSize(IdentifierAt(IdentIndex).DataType));

        end
        else
        begin

          if yes then Push(ConstVal, ASVALUE, GetDataSize(IdentifierAt(IdentIndex).DataType));

          ExpressionType := IdentifierAt(IdentIndex).AllocElementType;
          if ExpressionType = TDataType.UNTYPETOK then ExpressionType := IdentifierAt(IdentIndex).DataType;  // RECORD.

          ExpandParam(ExpressionType, ActualParamType);
        end;

      end
      else  // if TokenAt(i + 1).Kind = TTokenKind.COMMATOK

        if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) or
          ((IdentifierAt(IdentIndex).DataType in Pointers) and
          (IdentifierAt(IdentIndex).AllocElementType in OrdinalTypes + Pointers +
          [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then

          if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) or
            (IdentifierAt(IdentIndex).NumAllocElements > 0) or (IndirectionLevel = ASPOINTERTOPOINTER) or
            ((IdentifierAt(IdentIndex).NumAllocElements = 0) and (IndirectionLevel = ASPOINTERTOARRAYORIGIN)) then
          begin

            ExpressionType := IdentifierAt(IdentIndex).AllocElementType;
            if ExpressionType = TDataType.UNTYPETOK then ExpressionType := IdentifierAt(IdentIndex).DataType;


            if ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
              Push(RecordSize(IdentIndex), ASVALUE, 2)
            else
              Push(1, ASVALUE, GetDataSize(ExpressionType));

            Inc(NumActualParams);
          end
          else
            if not (IdentifierAt(IdentIndex).AllocElementType in [TDataType.BYTETOK, TDataType.SHORTINTTOK]) then
            begin
              Push(GetDataSize(IdentifierAt(IdentIndex).AllocElementType), ASVALUE, 1);      // +/- DATASIZE

              ExpandParam(ExpressionType, TDataType.BYTETOK);

              Inc(NumActualParams);
            end;


      if (IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING) and
        (IndirectionLevel <> ASPOINTERTOARRAYORIGIN) then IndirectionLevel := ASPOINTERTOPOINTER;

      if ExpressionType = TDataType.UNTYPETOK then
        Error(i, 'Assignments to formal parameters and open arrays are not possible');

      //       NumActualParams:=1;
      //   Value:=3;

      if (NumActualParams = 0) then
      begin
{
        asm65;

        if Down then
          asm65('; Dec(var X) -> ' + InfoAboutToken(ExpressionType))
        else
          asm65('; Inc(var X) -> ' + InfoAboutToken(ExpressionType));

        asm65;
}
        GenerateForToDoEpilog(ExpressionType, Down, IdentIndex, False, 0);    // +1, -1
      end
      else
        GenerateIncDec(IndirectionLevel, ExpressionType, Down, IdentIndex);    // +N, -N

      StopOptimization;

      Inc(i);

      CheckTok(i, TTokenKind.CPARTOK);

      Result := i;
    end;


    TTokenKind.EXITTOK:
    begin

      if TokenAt(i + 1).Kind = TTokenKind.OPARTOK then
      begin

        StartOptimization(i);

        i := CompileExpression(i + 2, ActualParamType);

        CheckTok(i + 1, TTokenKind.CPARTOK);

        Inc(i);

        yes := False;

        for j := 1 to NumIdent do
          if (IdentifierAt(j).ProcAsBlock = BlockStack[BlockStackTop]) and
            (IdentifierAt(j).Kind = TTokenKind.FUNCTIONTOK) then
          begin

            IdentIndex := GetIdentResult(BlockStack[BlockStackTop]);

            yes := True;
            Break;
          end;


        if not yes then
          Error(i, 'Procedures cannot return a value');

        if (ActualParamType = TDataType.STRINGPOINTERTOK) and
          ((IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
          (IdentifierAt(IdentIndex).NumAllocElements = 0)) then
          ErrorIncompatibleTypes(i, ActualParamType, TDataType.PCHARTOK)
        else
          GetCommonConstType(i, IdentifierAt(IdentIndex).DataType, ActualParamType);

        GenerateAssignment(ASPOINTER, GetDataSize(IdentifierAt(IdentIndex).DataType), 0, 'RESULT');

      end;

      asm65(#9'jmp @exit');

      ResetOpty;

      Result := i;
    end;


    TTokenKind.BREAKTOK:
    begin
      if BreakPosStackTop = 0 then
        Error(i, 'BREAK not allowed');

      //     asm65;
      asm65(#9'jmp b_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      BreakPosStack[BreakPosStackTop].brk := True;

      ResetOpty;

      Result := i;
    end;


    TTokenKind.CONTINUETOK:
    begin
      if BreakPosStackTop = 0 then
        Error(i, 'CONTINUE not allowed');

      //     asm65;
      asm65(#9'jmp c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      BreakPosStack[BreakPosStackTop].cnt := True;

      Result := i;
    end;


    TTokenKind.HALTTOK:
    begin
      if TokenAt(i + 1).Kind = TTokenKind.OPARTOK then
      begin

        i := CompileConstExpression(i + 2, Value, ExpressionType);
        GetCommonConstType(i, TDataType.BYTETOK, ExpressionType);

        CheckTok(i + 1, TTokenKind.CPARTOK);

        Inc(i, 1);

        GenerateProgramEpilog(Value);

      end
      else
        GenerateProgramEpilog(0);

      Result := i;
    end;


    TTokenKind.GETINTVECTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
      GetCommonType(i, TDataType.INTEGERTOK, ActualParamType);

      CheckTok(i + 1, TTokenKind.COMMATOK);

      if not (Byte(ConstVal) in [0..4]) then
        Error(i, 'Interrupt Number in [0..4]');

      CheckTok(i + 2, TTokenKind.IDENTTOK);
      IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

      if IdentIndex = 0 then
        Error(i + 2, TErrorCode.UnknownIdentifier);

      if not (IdentifierAt(IdentIndex).DataType in Pointers) then
        ErrorIncompatibleTypes(i + 2, IdentifierAt(IdentIndex).DataType, TDataType.POINTERTOK);

      svar := GetLocalName(IdentIndex);

      Inc(i, 2);

      case ConstVal of
        Ord(TInterruptCode.DLI): begin
          asm65;
          asm65(#9'lda VDSLST');
          asm65(#9'sta ' + svar);
          asm65(#9'lda VDSLST+1');
          asm65(#9'sta ' + svar + '+1');
        end;

        Ord(TInterruptCode.VBLI): begin
          asm65;
          asm65(#9'lda VVBLKI');
          asm65(#9'sta ' + svar);
          asm65(#9'lda VVBLKI+1');
          asm65(#9'sta ' + svar + '+1');
        end;

        Ord(TInterruptCode.VBLD): begin
          asm65;
          asm65(#9'lda VVBLKD');
          asm65(#9'sta ' + svar);
          asm65(#9'lda VVBLKD+1');
          asm65(#9'sta ' + svar + '+1');
        end;

        Ord(TInterruptCode.TIM1): begin
          asm65;
          asm65(#9'lda VTIMR1');
          asm65(#9'sta ' + svar);
          asm65(#9'lda VTIMR1+1');
          asm65(#9'sta ' + svar + '+1');
        end;

        Ord(TInterruptCode.TIM2): begin
          asm65;
          asm65(#9'lda VTIMR2');
          asm65(#9'sta ' + svar);
          asm65(#9'lda VTIMR2+1');
          asm65(#9'sta ' + svar + '+1');
        end;

        Ord(TInterruptCode.TIM4): begin
          asm65;
          asm65(#9'lda VTIMR4');
          asm65(#9'sta ' + svar);
          asm65(#9'lda VTIMR4+1');
          asm65(#9'sta ' + svar + '+1');
        end;

      end;

      CheckTok(i + 1, TTokenKind.CPARTOK);

      //    GenerateInterrupt(InterruptNumber);
      Result := i + 1;
    end;


    TTokenKind.SETINTVECTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
      GetCommonType(i, TDataType.INTEGERTOK, ActualParamType);

      CheckTok(i + 1, TTokenKind.COMMATOK);

      StartOptimization(i + 1);

      if not (Byte(ConstVal) in [0..4]) then
        Error(i, 'Interrupt Number in [0..4]');

      i := CompileExpression(i + 2, ActualParamType);
      GetCommonType(i, TDataType.POINTERTOK, ActualParamType);

      case ConstVal of
        Ord(TInterruptCode.DLI): begin
          asm65(#9'mva :STACKORIGIN,x VDSLST');
          asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VDSLST+1');
          a65(TCode65.subBX);
        end;

        Ord(TInterruptCode.VBLI): begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'ldy #5');
          asm65(#9'sta wsync');
          asm65(#9'dey');
          asm65(#9'rne');
          asm65(#9'sta VVBLKI');
          asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sty VVBLKI+1');
          a65(TCode65.subBX);
        end;

        Ord(TInterruptCode.VBLD): begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'ldy #5');
          asm65(#9'sta wsync');
          asm65(#9'dey');
          asm65(#9'rne');
          asm65(#9'sta VVBLKD');
          asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sty VVBLKD+1');
          a65(TCode65.subBX);
        end;

        Ord(TInterruptCode.TIM1): begin
          asm65(#9'sei');
          asm65(#9'mva :STACKORIGIN,x VTIMR1');
          asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR1+1');
          a65(TCode65.subBX);

          if TokenAt(i + 1).Kind = TTokenKind.COMMATOK then
          begin

            i := CompileExpression(i + 2, ActualParamType);
            GetCommonType(i, TDataType.BYTETOK, ActualParamType);

            asm65(#9'lda #$00');
            asm65(#9'ldy #$03');
            asm65(#9'sta AUDCTL');
            asm65(#9'sta AUDC1');
            asm65(#9'sty SKCTL');

            asm65(#9'mva :STACKORIGIN,x AUDCTL');
            a65(TCode65.subBX);

            CheckTok(i + 1, TTokenKind.COMMATOK);

            i := CompileExpression(i + 2, ActualParamType);
            GetCommonType(i, TDataType.BYTETOK, ActualParamType);

            asm65(#9'mva :STACKORIGIN,x AUDF1');
            a65(TCode65.subBX);

            asm65(#9'lda irqens');
            asm65(#9'ora #$01');
            asm65(#9'sta irqens');
            asm65(#9'sta irqen');
            asm65(#9'sta stimer');

          end
          else
          begin

            asm65(#9'lda irqens');
            asm65(#9'and #$fe');
            asm65(#9'sta irqens');
            asm65(#9'sta irqen');

          end;

          asm65(#9'cli');
        end;

        Ord(TInterruptCode.TIM2): begin
          asm65(#9'sei');
          asm65(#9'mva :STACKORIGIN,x VTIMR2');
          asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR2+1');
          a65(TCode65.subBX);

          if TokenAt(i + 1).Kind = TTokenKind.COMMATOK then
          begin

            i := CompileExpression(i + 2, ActualParamType);
            GetCommonType(i, TDataType.BYTETOK, ActualParamType);

            asm65(#9'lda #$00');
            asm65(#9'ldy #$03');
            asm65(#9'sta AUDCTL');
            asm65(#9'sta AUDC2');
            asm65(#9'sty SKCTL');

            asm65(#9'mva :STACKORIGIN,x AUDCTL');
            a65(TCode65.subBX);

            CheckTok(i + 1, TTokenKind.COMMATOK);

            i := CompileExpression(i + 2, ActualParamType);
            GetCommonType(i, TDataType.BYTETOK, ActualParamType);

            asm65(#9'mva :STACKORIGIN,x AUDF2');
            a65(TCode65.subBX);

            asm65(#9'lda irqens');
            asm65(#9'ora #$02');
            asm65(#9'sta irqens');
            asm65(#9'sta irqen');
            asm65(#9'sta stimer');

          end
          else
          begin

            asm65(#9'lda irqens');
            asm65(#9'and #$fd');
            asm65(#9'sta irqens');
            asm65(#9'sta irqen');

          end;

          asm65(#9'cli');
        end;

        Ord(TInterruptCode.TIM4): begin
          asm65(#9'sei');
          asm65(#9'mva :STACKORIGIN,x VTIMR4');
          asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR4+1');
          a65(TCode65.subBX);

          if TokenAt(i + 1).Kind = TTokenKind.COMMATOK then
          begin

            i := CompileExpression(i + 2, ActualParamType);
            GetCommonType(i, TDataType.BYTETOK, ActualParamType);

            asm65(#9'lda #$00');
            asm65(#9'ldy #$03');
            asm65(#9'sta AUDCTL');
            asm65(#9'sta AUDC4');
            asm65(#9'sty SKCTL');

            asm65(#9'mva :STACKORIGIN,x AUDCTL');
            a65(TCode65.subBX);

            CheckTok(i + 1, TTokenKind.COMMATOK);

            i := CompileExpression(i + 2, ActualParamType);
            GetCommonType(i, TDataType.BYTETOK, ActualParamType);

            asm65(#9'mva :STACKORIGIN,x AUDF4');
            a65(TCode65.subBX);

            asm65(#9'lda irqens');
            asm65(#9'ora #$04');
            asm65(#9'sta irqens');
            asm65(#9'sta irqen');
            asm65(#9'sta stimer');

          end
          else
          begin

            asm65(#9'lda irqens');
            asm65(#9'and #$fb');
            asm65(#9'sta irqens');
            asm65(#9'sta irqen');

          end;

          asm65(#9'cli');
        end;
      end;

      StopOptimization;

      CheckTok(i + 1, TTokenKind.CPARTOK);

      //    GenerateInterrupt(InterruptNumber);
      Result := i + 1;
    end;

    else
      Result := i - 1;
  end;  // case

end;  //CompileStatement


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateProcFuncAsmLabels(BlockIdentIndex: Integer; VarSize: Boolean = False);
var
  IdentIndex, size: Integer;
  emptyLine, yes: Boolean;
  fnam, txt, svar: String;
  varbegin: TString;
  HeaFile: ITextFile;

  // ----------------------------------------------------------------------------

  function Value(dorig: Boolean = False; brackets: Boolean = False): String;
  const
    reg: array [1..3] of String = (':EDX', ':ECX', ':EAX');
    // !!! kolejnosc edx, ecx, eax !!! korzysta z tego memmove, memset !!!
  var
    v: Int64;
  begin

    v := IdentifierAt(IdentIndex).Value;

    case IdentifierAt(IdentIndex).DataType of
      TDataType.SHORTREALTOK, TDataType.REALTOK: v := CastToReal(v);
      TDataType.SINGLETOK: v := CastToSingle(v);
      TDataType.HALFSINGLETOK: v := CastToHalfSingle(v);
      else
        v := IdentifierAt(IdentIndex).Value;
    end;


    if dorig then
    begin

      if brackets then
        Result := #9'= [DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN, 4) + ']'
      else
        Result := #9'= DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN, 4);

    end
    else
      if IdentifierAt(IdentIndex).isAbsolute and (IdentifierAt(IdentIndex).Kind = TTokenKind.VARTOK) and
        (abs(IdentifierAt(IdentIndex).Value) and $ff = 0) and
        (Byte((abs(IdentifierAt(IdentIndex).Value) shr 24) and $7f) in [1..127]) then
      begin

        case Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) of
          1..3: Result := #9'= ' + reg[abs(IdentifierAt(IdentIndex).Value shr 24) and $7f];
          4..19: Result := #9'= :STACKORIGIN-' + IntToStr(
              Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) - 3);
          else
            Result := #9'= ''out of resource'''
        end;

        size := 0;
      end
      else

        if IdentifierAt(IdentIndex).isExternal {and (IdentifierAt(IdentIndex).Libraries = 0)} then
        begin
          Result := #9'= ' + IdentifierAt(IdentIndex).Alias;
        end
        else

          if IdentifierAt(IdentIndex).isAbsolute then
          begin

            if IdentifierAt(IdentIndex).Value < 0 then
              Result := #9'= DATAORIGIN+$' + IntToHex(abs(IdentifierAt(IdentIndex).Value), 4)
            else
              if abs(IdentifierAt(IdentIndex).Value) < 256 then
                Result := #9'= $' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2)
              else
                Result := #9'= $' + IntToHex(IdentifierAt(IdentIndex).Value, 4);

          end
          else

            if IdentifierAt(IdentIndex).NumAllocElements > 0 then
              Result := #9'= CODEORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - CODEORIGIN_BASE - CODEORIGIN, 4)
            else
              if abs(v) < 256 then
                Result := #9'= $' + IntToHex(Byte(v), 2)
              else
                Result := #9'= $' + IntToHex(v, 4);

  end;

  // ----------------------------------------------------------------------------

  function mads_data_size: String;
  begin

    Result := '';

    if IdentifierAt(IdentIndex).AllocElementType in [TDataType.BYTETOK..TDataType.FORWARDTYPE] then
    begin

      case GetDataSize(IdentifierAt(IdentIndex).AllocElementType) of
        //1: Result := ' .byte';
        2: Result := ' .word';
        4: Result := ' .dword';
      end;

    end
    else
      Result := ' ; type unknown';

  end;

  // ----------------------------------------------------------------------------

  function SetBank: Boolean;
  var
    i, IdentTemp: Integer;
    hnam, rnam: String;
  begin

    Result := False;

    hnam := AnsiUpperCase(ExtractFileName(fnam));
    hnam := ChangeFileExt(hnam, '');

    for i := 0 to High(resArray) - 1 do
    begin

      rnam := AnsiUpperCase(ExtractFileName(resArray[i].resFile));
      rnam := ChangeFileExt(rnam, '');

      if hnam = rnam then
      begin
        IdentTemp := GetIdentIndex(resArray[i].resName);

        if IdentTemp > 0 then
        begin
          asm65('');
          asm65(#9'lmb #$' + IntToHex(IdentifierAt(IdentTemp).Value + 1, 2));
          asm65('');

          Result := True;

          exit(True);
        end;

      end;

    end;

  end;

  // TODO Move to TIdentifier and use in all locations where the computation is redundant
  function GetIdentifierFullName(const identifier: TIdentifier): String;
  begin
    Result := identifier.SourceFile.Name + '.' + identifier.Name;
  end;

  function GetIdentifierDataSize(const identifier: TIdentifier): Integer;
  var
    dataSize: Byte;
  begin
    dataSize := GetDataSize(identifier.AllocElementType);
    Result := identifier.NumAllocElements * dataSize;
    // LogTrace(Format('Identifier %s has %d element of size %d = %d',
    //  [GetIdentifierFullName(identifier), identifier.NumAllocElements, dataSize, Result]));
  end;


  // ----------------------------------------------------------------------------

  procedure IncSize(bytes: Integer);
  begin
    // LogTrace(Format('IncSize %d by %d', [size, bytes]));
    Inc(size, bytes);
  end;

  // ----------------------------------------------------------------------------
begin

  if Pass = TPass.CODE_GENERATION then
  begin

    StopOptimization;

    emptyLine := True;
    size := 0;
    varbegin := '';

    for IdentIndex := 1 to NumIdent do
      if (IdentifierAt(IdentIndex).Block = IdentifierAt(BlockIdentIndex).ProcAsBlock) and
        (IdentifierAt(IdentIndex).SourceFile.UnitIndex = ActiveSourceFile.UnitIndex) then
      begin

        if emptyLine then
        begin
          asm65separator;
          asm65;

          emptyLine := False;
        end;


        if IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) then
        begin      // read file header libraryname.hea

          fnam := linkObj[TokenAt(IdentifierAt(IdentIndex).Libraries).Value];


          if RCLIBRARY then
            if SetBank = False then Error(IdentifierAt(IdentIndex).Libraries, 'Error: Bank identifier missing.');


          if ExtractFileExt(fnam) = '' then fnam := ChangeFileExt(fnam, '.hea');

          fnam := FindFile(fnam, 'header');

          if IdentifierAt(IdentIndex).isOverload then
            svar := IdentifierAt(IdentIndex).Alias + '.' + GetOverloadName(IdentIndex)
          else
            svar := IdentifierAt(IdentIndex).Alias;

          yes := True;

          HeaFile := TFileSystem.CreateTextFile;
          HeaFile.Assign(fnam);
          HeaFile.Reset;

          txt := '';
          while not HeaFile.EOF do
          begin
            HeaFile.ReadLn(txt);

            txt := AnsiUpperCase(txt);

            if (length(txt) > 255) or (pos(#0, txt) > 0) then
            begin
              HeaFile.Close;

              Error(IdentifierAt(IdentIndex).Libraries, 'Error: MADS header file ''' + fnam +
                ''' has invalid format.');
            end;

            if (txt.IndexOf('.@EXIT') < 0) and (txt.IndexOf('.@VARDATA') < 0) then      // skip '@.EXIT', '.@VARDATA'
              if (pos('MAIN.' + svar + ' ', txt) = 1) or (pos('MAIN.' + svar + #9, txt) = 1) or
                (pos('MAIN.' + svar + '.', txt) = 1) then
              begin
                yes := False;

                asm65(IdentifierAt(IdentIndex).Name + copy(txt, 6 + length(IdentifierAt(IdentIndex).Alias),
                  length(txt)));
              end;

          end;

          if yes then
            ErrorForIdentifier(IdentifierAt(IdentIndex).Libraries, TErrorCode.UnknownIdentifier, IdentIndex);

          HeaFile.Close;

          if RCLIBRARY then
          begin
            asm65('');
            asm65(#9'rmb');
            asm65('');
          end;        // reset bank -> #0

        end
        else


          case IdentifierAt(IdentIndex).Kind of

            VARIABLE: if IdentifierAt(IdentIndex).isAbsolute then
              begin    // ABSOLUTE = TRUE

                if (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) and
                  (IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
                  (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                begin

                  asm65('adr.' + IdentifierAt(IdentIndex).Name + Value);
                  asm65('.var ' + IdentifierAt(IdentIndex).Name + #9'= adr.' +
                    IdentifierAt(IdentIndex).Name + ' .word');

                  if size = 0 then varbegin := IdentifierAt(IdentIndex).Name;
                  IncSize(IdentifierAt(IdentIndex).NumAllocElements *
                    GetDataSize(IdentifierAt(IdentIndex).AllocElementType));

                end
                else
                  if IdentifierAt(IdentIndex).DataType = TDataType.FILETOK then
                    asm65('.var ' + IdentifierAt(IdentIndex).Name + Value + ' .word')
                  else
                    if pos('@FORTMP_', IdentifierAt(IdentIndex).Name) = 0 then
                      asm65(IdentifierAt(IdentIndex).Name + Value);

              end
              else            // ABSOLUTE = FALSE

                if (IdentifierAt(IdentIndex).PassMethod <> TParameterPassingMethod.VARPASSING) and
                  (IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
                  (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                begin

                  //  writeln(IdentifierAt(IdentIndex).Name,',', IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).IdType);

                  if ((IdentifierAt(IdentIndex).IdType <> TDataType.ARRAYTOK) and
                    (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or
                    (IdentifierAt(IdentIndex).IdType = TDataType.DATAORIGINOFFSET) then

                    asm65(IdentifierAt(IdentIndex).Name + Value(True))

                  else
                  begin

                    if IdentifierAt(IdentIndex).DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                      asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True) + #9'; [' +
                        IntToStr(RecordSize(IdentIndex)) + '] ' + InfoAboutToken(IdentifierAt(IdentIndex).DataType))
                    else

                      if Elements(IdentIndex) > 0 then
                      begin

                        //  writeln(IdentifierAt(IdentIndex).Name,' | ',Elements(IdentIndex),'/',IdentifierAt(IdentIndex).IdType,'/',IdentifierAt(IdentIndex).PassMethod ,' | ', IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).IdType);

                        if (IdentifierAt(IdentIndex).NumAllocElements_ > 0) and not
                          (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK,
                          TDataType.OBJECTTOK]) then
                          asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True, True) +
                            ' .array [' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements) +
                            '] [' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements_) + ']' + mads_data_size)
                        else
                          asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True, True) +
                            ' .array [' + IntToStr(Elements(IdentIndex)) + ']' + mads_data_size);  // !!!!

                      end
                      else
                        asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True));

                    asm65('.var ' + IdentifierAt(IdentIndex).Name + #9'= adr.' +
                      IdentifierAt(IdentIndex).Name + ' .word');
                    // !!!!

                  end;

                  if size = 0 then varbegin := IdentifierAt(IdentIndex).Name;
                  IncSize(GetIdentifierDataSize(IdentifierAt(IdentIndex)));

                end
                else
                  if (IdentifierAt(IdentIndex).DataType = TDataType.FILETOK)
                  {and (IdentifierAt(IdentIndex).Block = 1)} then
                    asm65('.var ' + IdentifierAt(IdentIndex).Name + Value(True) + ' .word')  // tylko wskaznik
                  else
                  begin
                    asm65(IdentifierAt(IdentIndex).Name + Value(True));

                    if size = 0 then varbegin := IdentifierAt(IdentIndex).Name;

                    if IdentifierAt(IdentIndex).idType <> TTokenKind.DATAORIGINOFFSET then
                      // indeksy do RECORD nie zliczaj

                      if (IdentifierAt(IdentIndex).Name = 'RESULT') and
                        (IdentifierAt(BlockIdentIndex).Kind = TTokenKind.FUNCTIONTOK) then
                      // RESULT nie zliczaj

                      else
                        if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
                          IncSize(GetDataSize(IdentifierAt(IdentIndex).AllocElementType))
                        else
                          IncSize(GetDataSize(IdentifierAt(IdentIndex).DataType));

                  end;

            CONSTANT: if (IdentifierAt(IdentIndex).DataType in Pointers) and
                (IdentifierAt(IdentIndex).NumAllocElements > 0) then
              begin

                asm65('adr.' + IdentifierAt(IdentIndex).Name + Value);
                asm65('.var ' + IdentifierAt(IdentIndex).Name + #9'= adr.' + IdentifierAt(IdentIndex).Name + ' .word');

              end
              else
                if pos('@FORTMP_', IdentifierAt(IdentIndex).Name) = 0 then
                  asm65(IdentifierAt(IdentIndex).Name + Value);
          end;

      end;

    if (BlockStack[BlockStackTop] <> 1) then
    begin

      asm65;

      if LIBRARY_USE then asm65('@InitLibrary'#9'= :START');

      if VarSize and (size > 0) then
      begin
        asm65('@VarData'#9'= ' + varbegin);
        asm65('@VarDataSize'#9'= ' + IntToStr(size));
        asm65;
      end;

    end;

  end;

end;  //GenerateProcFuncAsmLabels


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveToStaticDataSegment(ConstDataSize: Integer; ConstVal: Int64; ConstValType: TDataType);
begin

  if (ConstDataSize < 0) or (ConstDataSize > $FFFF) then
  begin
    writeln('SaveToStaticDataSegment: ' + IntToStr(ConstDataSize));
    RaiseHaltException(THaltException.COMPILING_ABORTED);
  end;

  case ConstValType of

    TDataType.SHORTINTTOK, TDataType.BYTETOK, TDataType.CHARTOK, TDataType.BOOLEANTOK:
      StaticStringData[ConstDataSize] := Byte(ConstVal);

    TDataType.SMALLINTTOK, TDataType.WORDTOK, TDataType.SHORTREALTOK, TDataType.POINTERTOK,
    TDataType.STRINGPOINTERTOK, TDataType.PCHARTOK:
    begin
      StaticStringData[ConstDataSize] := Byte(ConstVal);
      StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
    end;

    TDataType.DATAORIGINOFFSET:
    begin
      StaticStringData[ConstDataSize] := Byte(ConstVal) or $8000;
      StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8) or $4000;
    end;

    TDataType.CODEORIGINOFFSET:
    begin
      StaticStringData[ConstDataSize] := Byte(ConstVal) or $2000;
      StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8) or $1000;
    end;

    TDataType.INTEGERTOK, TDataType.CARDINALTOK, TDataType.REALTOK:
    begin
      StaticStringData[ConstDataSize] := Byte(ConstVal);
      StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
      StaticStringData[ConstDataSize + 2] := Byte(ConstVal shr 16);
      StaticStringData[ConstDataSize + 3] := Byte(ConstVal shr 24);
    end;

    TDataType.SINGLETOK: begin
      ConstVal := CastToSingle(ConstVal);

      StaticStringData[ConstDataSize] := Byte(ConstVal);
      StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
      StaticStringData[ConstDataSize + 2] := Byte(ConstVal shr 16);
      StaticStringData[ConstDataSize + 3] := Byte(ConstVal shr 24);
    end;

    TDataType.HALFSINGLETOK: begin
      ConstVal := CastToHalfSingle(ConstVal);

      StaticStringData[ConstDataSize] := Byte(ConstVal);
      StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
    end;

  end;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ReadDataArray(i: Integer; ConstDataSize: Integer; const ConstValType: TDataType;
  NumAllocElements: Cardinal; StaticData: Boolean; Add: Boolean = False): Integer;
var
  ActualParamType: TDataType;
  ch: Byte;
  NumActualParams, NumActualParams_, NumAllocElements_: Cardinal;
  ConstVal: Int64;

  // ----------------------------------------------------------------------------

  procedure SaveDataSegment(DataType: TDataType);
  begin

    if StaticData then
      SaveToStaticDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType)
    else
      SaveToDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType);

    if DataType = TDataType.DATAORIGINOFFSET then
      Inc(ConstDataSize, GetDataSize(TDataType.POINTERTOK))
    else
      Inc(ConstDataSize, GetDataSize(DataType));

  end;


  // ----------------------------------------------------------------------------

  procedure SaveData(compile: Boolean = True);
  begin

    if compile then
      i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


    if (ConstValType = TDataType.STRINGPOINTERTOK) and (ActualParamType = TDataType.CHARTOK) then
    begin  // rejestrujemy CHAR jako STRING

      if StaticData then
        Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

      ch := TokenAt(i).Value;
      DefineStaticString(i, chr(ch));

      ConstVal := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
      TokenAt(i).Value := ch;

      ActualParamType := TDataType.STRINGPOINTERTOK;

    end;


    if (ConstValType in StringTypes + [TDataType.CHARTOK, TDataType.STRINGPOINTERTOK]) and
      (ActualParamType in IntegerTypes + RealTypes) then
      Error(i, TErrorCode.IllegalExpression);


    if (ConstValType in StringTypes + [TDataType.STRINGPOINTERTOK]) and (ActualParamType = TDataType.CHARTOK) then
      ErrorIncompatibleTypes(i, ActualParamType, ConstValType);


    if (ConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
      (ActualParamType = TDataType.REALTOK) then
      ActualParamType := ConstValType;

    if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ActualParamType := ConstValType;
    end;

    if (ConstValType = TDataType.SHORTREALTOK) and (ActualParamType = TDataType.REALTOK) then
      ActualParamType := TDataType.SHORTREALTOK;


    if ActualParamType = TDataType.DATAORIGINOFFSET then

      SaveDataSegment(TDataType.DATAORIGINOFFSET)

    else
    begin

      if ConstValType in IntegerTypes then
      begin

        if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
          WarningForRangeCheckError(i, ConstVal, ConstValType);
      end
      else
        GetCommonConstType(i, ConstValType, ActualParamType);

      SaveDataSegment(ConstValType);

    end;

  end;


  // ----------------------------------------------------------------------------

  {$i include/doevaluate.inc}

  // ----------------------------------------------------------------------------
begin

{
  if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) and (ConstValType = TDataType.CHARTOK) then begin    // init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   if TokenAt(i).StrLength > NumAllocElements then
     Error(i, 'string length is larger than array of char length');

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > TokenAt(i).StrLength then
     ConstVal := byte(' ')
    else
     ConstVal := byte(StaticStringData[TokenAt(i).StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;
}

  CheckTok(i, TTokenKind.OPARTOK);

  NumActualParams := 0;
  NumActualParams_ := 0;

  NumAllocElements_ := NumAllocElements shr 16;
  NumAllocElements := NumAllocElements and $ffff;

  repeat

    Inc(NumActualParams);
    //  if NumActualParams > NumAllocElements then Break;

    if NumAllocElements_ > 0 then
    begin

      NumActualParams_ := 0;

      CheckTok(i + 1, TTokenKind.OPARTOK);
      Inc(i);

      repeat
        Inc(NumActualParams_);
        if NumActualParams_ > NumAllocElements_ then Break;

        SaveData;

        Inc(i);
      until TokenAt(i).Kind <> TTokenKind.COMMATOK;

      CheckTok(i, TTokenKind.CPARTOK);

      //inc(i);
    end
    else
    //SaveData;
      if TokenAt(i + 1).Kind = TTokenKind.EVALTOK then
        NumActualParams := doEvaluate(evaluationContext)
      else
        SaveData;


    Inc(i);

  until TokenAt(i).Kind <> TTokenKind.COMMATOK;

  CheckTok(i, TTokenKind.CPARTOK);


  if NumActualParams > NumAllocElements then
    Error(i, 'Number of elements (' + IntToStr(NumActualParams) + ') differs from declaration (' +
      IntToStr(NumAllocElements) + ')');

  if NumActualParams < NumAllocElements then
    Error(i, 'Expected another ' + IntToStr(NumAllocElements - NumActualParams) + ' array elements');

  if NumActualParams_ < NumAllocElements_ then
    Error(i, 'Expected another ' + IntToStr(NumAllocElements_ - NumActualParams_) + ' array elements');

  Result := i;

end;  //ReadDataArray


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ReadDataOpenArray(i: Integer; ConstDataSize: Integer; const ConstValType: TDataType;
  out NumAllocElements: Cardinal; StaticData: Boolean; Add: Boolean = False): Integer;
var
  ActualParamType: TDataType;
  ch: Byte;
  NumActualParams: Cardinal;
  ConstVal: Int64;


  // ----------------------------------------------------------------------------


  procedure SaveDataSegment(DataType: TDataType);
  begin

    if StaticData then
      SaveToStaticDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType)
    else
      SaveToDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType);

    if DataType = TDataType.DATAORIGINOFFSET then
      Inc(ConstDataSize, GetDataSize(TDataType.POINTERTOK))
    else
      Inc(ConstDataSize, GetDataSize(DataType));

  end;


  // ----------------------------------------------------------------------------


  procedure SaveData(compile: Boolean = True);
  begin

    if compile then
      i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


    if (ConstValType = TDataType.STRINGPOINTERTOK) and (ActualParamType = TDataType.CHARTOK) then
    begin  // rejestrujemy CHAR jako STRING

      if StaticData then
        Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

      ch := TokenAt(i).Value;
      DefineStaticString(i, chr(ch));

      ConstVal := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
      TokenAt(i).Value := ch;

      ActualParamType := TDataType.STRINGPOINTERTOK;

    end;


    if (ConstValType in StringTypes + [TDataType.CHARTOK, TDataType.STRINGPOINTERTOK]) and
      (ActualParamType in IntegerTypes + RealTypes) then
      Error(i, TErrorCode.IllegalExpression);


    if (ConstValType in StringTypes + [TDataType.STRINGPOINTERTOK]) and (ActualParamType = TDataType.CHARTOK) then
      ErrorIncompatibleTypes(i, ActualParamType, ConstValType);


    if (ConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
      (ActualParamType = TDataType.REALTOK) then
      ActualParamType := ConstValType;

    if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ActualParamType := ConstValType;
    end;

    if (ConstValType = TDataType.SHORTREALTOK) and (ActualParamType = TDataType.REALTOK) then
      ActualParamType := TDataType.SHORTREALTOK;


    if ActualParamType = TDataType.DATAORIGINOFFSET then

      SaveDataSegment(TDataType.DATAORIGINOFFSET)

    else
    begin

      if ConstValType in IntegerTypes then
      begin

        if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
          WarningForRangeCheckError(i, ConstVal, ConstValType);

      end
      else
        GetCommonConstType(i, ConstValType, ActualParamType);

      SaveDataSegment(ConstValType);

    end;

    Inc(NumActualParams);

  end;


  // ----------------------------------------------------------------------------

  {$i include/doevaluate.inc}

  // ----------------------------------------------------------------------------
begin

{
  if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) and (ConstValType = TDataType.CHARTOK) then begin    // init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   NumAllocElements := TokenAt(i).StrLength;

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > TokenAt(i).StrLength then
     ConstVal := byte(' ')
    else
     ConstVal := byte(StaticStringData[TokenAt(i).StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;
}

  CheckTok(i, TTokenKind.OBRACKETTOK);

  NumActualParams := 0;
  NumAllocElements := 0;


  if TokenAt(i + 1).Kind = TTokenKind.CBRACKETTOK then

    Inc(i)

  else
    repeat

      if TokenAt(i + 1).Kind = TTokenKind.EVALTOK then
        doEvaluate(evaluationContext)
      else
        SaveData;

      Inc(i);

    until TokenAt(i).Kind <> TTokenKind.COMMATOK;


  CheckTok(i, TTokenKind.CBRACKETTOK);

  NumAllocElements := NumActualParams;

  Result := i;

end;  //ReadDataOpenArray


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateLocal(BlockIdentIndex: Integer; IsFunction: Boolean);
var
  info: String;
begin

  if IsFunction then
    info := '; FUNCTION'
  else
    info := '; PROCEDURE';

  if IdentifierAt(BlockIdentIndex).isAsm then info := info + ' | ASSEMBLER';
  if IdentifierAt(BlockIdentIndex).isOverload then info := info + ' | OVERLOAD';
  if IdentifierAt(BlockIdentIndex).isRegister then info := info + ' | REGISTER';
  if IdentifierAt(BlockIdentIndex).isInterrupt then info := info + ' | INTERRUPT';
  if IdentifierAt(BlockIdentIndex).isKeep then info := info + ' | KEEP';
  if IdentifierAt(BlockIdentIndex).isPascal then info := info + ' | PASCAL';
  if IdentifierAt(BlockIdentIndex).isInline then info := info + ' | INLINE';

  asm65;

  if codealign.proc > 0 then
  begin
    asm65(#9'.align $' + IntToHex(codealign.proc, 4));
    asm65;
  end;

  asm65('.local'#9 + IdentifierAt(BlockIdentIndex).Name, info);

  if IdentifierAt(BlockIdentIndex).isOverload then
    asm65('.local'#9 + GetOverloadName(BlockIdentIndex));

{
 if IdentifierAt(BlockIdentIndex).isOverload then
   asm65('.local'#9 + IdentifierAt(BlockIdentIndex).Name+'_'+IntToHex(IdentifierAt(BlockIdentIndex).Value, 4), info)
 else
   asm65('.local'#9 + IdentifierAt(BlockIdentIndex).Name, info);
}
  if IdentifierAt(BlockIdentIndex).isInline then asm65(#13#10#9'.MACRO m@INLINE');

end;  //GenerateLocal


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure FormalParameterList(var i: Integer; var NumParams: Integer; var Param: TParamList;
  out Status: Word; IsNestedFunction: Boolean; out NestedFunctionResultType: TDataType;
  out NestedFunctionNumAllocElements: Cardinal; out NestedFunctionAllocElementType: TDataType);
var
  ListPassMethod: TParameterPassingMethod;
  NumVarOfSameType: Byte;
  VarType, AllocElementType: TDataType;
  NumAllocElements: Cardinal;
  VarOfSameTypeIndex: Integer;
  VarOfSameType: TVariableList;
begin

  //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
  VarOfSameType := Default(TVariableList);

  NumParams := 0;

  if (TokenAt(i + 3).Kind = TTokenKind.CPARTOK) and (TokenAt(i + 2).Kind = TTokenKind.OPARTOK) then
    i := i + 4
  else

    if (TokenAt(i + 2).Kind = TTokenKind.OPARTOK) then         // Formal parameter list found
    begin
      i := i + 2;
      repeat
        NumVarOfSameType := 0;

        ListPassMethod := TParameterPassingMethod.VALPASSING;

        if TokenAt(i + 1).Kind = TTokenKind.CONSTTOK then
        begin
          ListPassMethod := TParameterPassingMethod.CONSTPASSING;
          Inc(i);
        end
        else if TokenAt(i + 1).Kind = TTokenKind.VARTOK then
          begin
            ListPassMethod := TParameterPassingMethod.VARPASSING;
            Inc(i);
          end;

        repeat

          if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
            Error(i + 1, 'Formal parameter name expected but ' + TokenList.GetTokenSpellingAtIndex(i + 1) + ' found')
          else
          begin
            Inc(NumVarOfSameType);
            VarOfSameType[NumVarOfSameType].Name := TokenAt(i + 1).Name;
          end;
          i := i + 2;
        until TokenAt(i).Kind <> TTokenKind.COMMATOK;


        VarType := TDataType.UNTYPETOK;
        NumAllocElements := 0;
        AllocElementType := TDataType.UNTYPETOK;

        if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING]) and
          (TokenAt(i).Kind <> TTokenKind.COLONTOK) then
        begin

          ListPassMethod := TParameterPassingMethod.VARPASSING;
          Dec(i);

        end
        else
        begin

          CheckTok(i, TTokenKind.COLONTOK);

          if TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK then      // ^type
            Error(i + 1, 'Type identifier expected');

          i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

          if (VarType = TDataType.FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
            Error(i, 'File types must be var parameters');

        end;


        for VarOfSameTypeIndex := 1 to NumVarOfSameType do
        begin

          //      if NumAllocElements > 0 then
          //        Error(i, 'Structured parameters cannot be passed by value');

          Inc(NumParams);
          if NumParams > MAXPARAMS then
            ErrorForIdentifier(i, TErrorCode.TooManyParameters, NumIdent)
          else
          begin
            //        VarOfSameType[VarOfSameTypeIndex].DataType      := VarType;

            Param[NumParams].DataType := VarType;
            Param[NumParams].Name := VarOfSameType[VarOfSameTypeIndex].Name;
            Param[NumParams].NumAllocElements := NumAllocElements;
            Param[NumParams].AllocElementType := AllocElementType;
            Param[NumParams].PassMethod := ListPassMethod;

          end;
        end;

        i := i + 1;
      until TokenAt(i).Kind <> TTokenKind.SEMICOLONTOK;

      CheckTok(i, TTokenKind.CPARTOK);

      i := i + 1;
    end// if TokenAt(i + 2).Kind = OPARTOR
    else
      i := i + 2;

  //      NestedFunctionResultType := 0;
  //      NestedFunctionNumAllocElements := 0;
  //      NestedFunctionAllocElementType := 0;

  Status := 0;

  if IsNestedFunction then
  begin

    CheckTok(i, TTokenKind.COLONTOK);

    if TokenAt(i + 1).Kind = TDataType.ARRAYTOK then
      Error(i + 1, 'Type identifier expected');

    i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

    NestedFunctionResultType := VarType;         // Result
    NestedFunctionNumAllocElements := NumAllocElements;
    NestedFunctionAllocElementType := AllocElementType;

    i := i + 1;
  end;  // if IsNestedFunction

  CheckTok(i, TTokenKind.SEMICOLONTOK);


  while TokenAt(i + 1).Kind in [TTokenKind.OVERLOADTOK, TTokenKind.ASSEMBLERTOK, TTokenKind.FORWARDTOK,
      TTokenKind.REGISTERTOK, TTokenKind.INTERRUPTTOK, TTokenKind.PASCALTOK, TTokenKind.STDCALLTOK,
      TTokenKind.INLINETOK, TTokenKind.KEEPTOK] do
  begin

    case TokenAt(i + 1).Kind of

      TTokenKind.OVERLOADTOK: begin
        SetModifierBit(TModifierCode.mOverload, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.ASSEMBLERTOK: begin
        SetModifierBit(TModifierCode.mAssembler, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

{       TTokenKind.FORWARDTOK: begin
         SetModifierBit(TModifierCode.mForward, Status);
         inc(i);
         CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
       end;
 }
      TTokenKind.REGISTERTOK: begin
        SetModifierBit(TModifierCode.mRegister, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.STDCALLTOK: begin
        SetModifierBit(TModifierCode.mStdCall, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.INLINETOK: begin
        SetModifierBit(TModifierCode.mInline, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.INTERRUPTTOK: begin
        SetModifierBit(TModifierCode.mInterrupt, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.PASCALTOK: begin
        SetModifierBit(TModifierCode.mPascal, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.KEEPTOK: begin
        SetModifierBit(TModifierCode.mKeep, Status);
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;
    end;

    Inc(i);
  end;// while

end;  //FormalParameterList


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckForwardResolutions(typ: Boolean = True);
var
  TypeIndex, IdentIndex: Integer;
  Name: String;
begin

  // Search for unresolved forward references
  for TypeIndex := 1 to NumIdent do
    if (IdentifierAt(TypeIndex).AllocElementType = TDataType.FORWARDTYPE) and
      (IdentifierAt(TypeIndex).Block = BlockStack[BlockStackTop]) then
    begin

      Name := IdentifierAt(GetIdentIndex(TokenAt(IdentifierAt(TypeIndex).NumAllocElements).Name)).Name;

      if IdentifierAt(GetIdentIndex(TokenAt(IdentifierAt(TypeIndex).NumAllocElements).Name)).Kind =
        TTokenKind.TYPETOK then

        for IdentIndex := 1 to NumIdent do
          if (IdentifierAt(IdentIndex).Name = Name) and (IdentifierAt(IdentIndex).Block =
            BlockStack[BlockStackTop]) then
          begin

            IdentifierAt(TypeIndex).NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements;
            IdentifierAt(TypeIndex).NumAllocElements_ := IdentifierAt(IdentIndex).NumAllocElements_;
            IdentifierAt(TypeIndex).AllocElementType := IdentifierAt(IdentIndex).DataType;

            Break;
          end;

    end;


  // Search for unresolved forward references
  for TypeIndex := 1 to NumIdent do
    if (IdentifierAt(TypeIndex).AllocElementType = TDataType.FORWARDTYPE) and
      (IdentifierAt(TypeIndex).Block = BlockStack[BlockStackTop]) then

      if typ then
        Error(TypeIndex, 'Unresolved forward reference to type ' + IdentifierAt(TypeIndex).Name)
      else
        Error(TypeIndex, 'Identifier not found "' + IdentifierAt(
          GetIdentIndex(TokenAt(IdentifierAt(TypeIndex).NumAllocElements).Name)).Name + '"');

end;  //CheckForwardResolutions


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileRecordDeclaration(i: Integer; var VarOfSameType: TVariableList;
  var tmpVarDataSize: Integer; var ConstVal: Int64; VarOfSameTypeIndex: Integer;
  VarType, AllocElementType: TDataType; NumAllocElements: Cardinal; isAbsolute: Boolean; var idx: Integer);
var
  tmpVarDataSize_, ParamIndex: Integer;
begin

  //  writeln(iDtype,',',VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',GetTypeAtIndex(NumAllocElements).Block,' | ', AllocElementType);

  if ((VarType in Pointers) and (AllocElementType = TDataType.RECORDTOK)) then
  begin

    //   writeln('> ',VarOfSameType[VarOfSameTypeIndex].Name,',',NestedDataType, ',',NestedAllocElementType,',', NestedNumAllocElements,',',NestedNumAllocElements and $ffff,'/',NestedNumAllocElements shr 16);

    tmpVarDataSize_ := GetVarDataSize;


    if (NumAllocElements shr 16) > 0 then
    begin                      // array [0..x] of record

      IdentifierAt(NumIdent).NumAllocElements := NumAllocElements and $FFFF;
      IdentifierAt(NumIdent).NumAllocElements_ := NumAllocElements shr 16;

      SetVarDataSize(i, tmpVarDataSize + (NumAllocElements shr 16) * GetDataSize(TDataType.POINTERTOK));

      tmpVarDataSize := GetVarDataSize;

      NumAllocElements := NumAllocElements and $FFFF;

    end
    else
      if IdentifierAt(NumIdent).isAbsolute = False then Inc(tmpVarDataSize, GetDataSize(TDataType.POINTERTOK));
    // wskaznik dla ^record


    idx := IdentifierAt(NumIdent).Value - DATAORIGIN;

    //writeln(NumAllocElements);
    //!@!@
    for ParamIndex := 1 to GetTypeAtIndex(NumAllocElements).NumFields do                  // label: ^record
      if (GetTypeAtIndex(NumAllocElements).Block = 1) or (GetTypeAtIndex(NumAllocElements).Block =
        BlockStack[BlockStackTop]) then
      begin

        //      writeln('a ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + GetTypeAtIndex(NumAllocElements).Field[ParamIndex].Name,',',GetTypeAtIndex(NumAllocElements).Field[ParamIndex].DataType,',',GetTypeAtIndex(NumAllocElements).Field[ParamIndex].AllocElementType,',',GetTypeAtIndex(NumAllocElements).Field[ParamIndex].NumAllocElements);

        DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' +
          GetTypeAtIndex(NumAllocElements).Field[ParamIndex].Name,
          VARIABLE,
          GetTypeAtIndex(NumAllocElements).Field[ParamIndex].DataType,
          GetTypeAtIndex(NumAllocElements).Field[ParamIndex].NumAllocElements,
          GetTypeAtIndex(NumAllocElements).Field[ParamIndex].AllocElementType, 0, TTokenKind.DATAORIGINOFFSET);

        IdentifierAt(NumIdent).Value := IdentifierAt(NumIdent).Value - tmpVarDataSize_;
        IdentifierAt(NumIdent).PassMethod := TParameterPassingMethod.VARPASSING;
        //      IdentifierAt(NumIdent).AllocElementType := IdentifierAt(NumIdent).DataType;

      end;

    SetVarDataSize(i, tmpVarDataSize);

  end
  else

    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then                      // label: record
      for ParamIndex := 1 to GetTypeAtIndex(NumAllocElements).NumFields do
        if (GetTypeAtIndex(NumAllocElements).Block = 1) or (GetTypeAtIndex(NumAllocElements).Block =
          BlockStack[BlockStackTop]) then
        begin

          //      writeln('b ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + GetTypeAtIndex(NumAllocElements).Field[ParamIndex].Name,',',GetTypeAtIndex(NumAllocElements).Field[ParamIndex].DataType,',',GetTypeAtIndex(NumAllocElements).Field[ParamIndex].AllocElementType,',',GetTypeAtIndex(NumAllocElements).Field[ParamIndex].NumAllocElements,' | ',IdentifierAt(NumIdent).Value);

          tmpVarDataSize_ := GetVarDataSize;

          DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' +
            GetTypeAtIndex(NumAllocElements).Field[ParamIndex].Name,
            VARIABLE,
            GetTypeAtIndex(NumAllocElements).Field[ParamIndex].DataType,
            GetTypeAtIndex(NumAllocElements).Field[ParamIndex].NumAllocElements,
            GetTypeAtIndex(NumAllocElements).Field[ParamIndex].AllocElementType, Ord(isAbsolute) * ConstVal);

          if isAbsolute then
            if not (GetTypeAtIndex(NumAllocElements).Field[ParamIndex].DataType in
              [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
              // fixed https://forums.atariage.com/topic/240919-mad-pascal/?do=findComment&comment=5422587
              Inc(ConstVal, GetVarDataSize - tmpVarDataSize_);
          //    GetDataSize( GetTypeAtIndex(NumAllocElements).Field[ParamIndex].DataType]);

        end;

end;  //CompileRecordDeclaration


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileBlock(i: TTokenIndex; BlockIdentIndex: Integer; NumParams: Integer;
  IsFunction: Boolean; FunctionResultType: TDataType; FunctionNumAllocElements: Cardinal = 0;
  FunctionAllocElementType: TDataType = TDataType.UNTYPETOK): Integer;
var
  VarOfSameType: TVariableList;
  VarPassMethod: TParameterPassingMethod;
  Param: TParamList;
  j, idx, NumVarOfSameType, VarOfSameTypeIndex, tmpVarDataSize, ParamIndex, ForwardIdentIndex,
  IdentIndex, external_libr: Integer;
  NumAllocElements, NestedNumAllocElements, NestedFunctionNumAllocElements: Cardinal;
  ConstVal: Int64;
  ImplementationUse, open_array, iocheck_old, isInterrupt_old, yes, Assignment,
  {pack,} IsNestedFunction, isAbsolute, isExternal, isForward, isVolatile, isStriped, isAsm,
  isReg, isInt, isInl, isOvr: Boolean;
  VarType: TDataType;
  VarRegister: Byte;
  NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType, NestedFunctionAllocElementType,
  NestedDataType, NestedAllocElementType, IdType: TDataType;
  Tmp, TmpResult: Word;

  external_name: TString;

  SourceFileList: array of TString;
begin

  ResetOpty;

  //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
  VarOfSameType := Default(TVariableList);

  j := 0;
  ConstVal := 0;
  VarRegister := 0;

  external_libr := 0;
  external_name := '';

  NestedDataType := TDataType.UNTYPETOK;
  NestedAllocElementType := TDataType.UNTYPETOK;
  NestedNumAllocElements := 0;
  ParamIndex := 0;

  varPassMethod := TParameterPassingMethod.UNDEFINED;

  ImplementationUse := False;

  Param := IdentifierAt(BlockIdentIndex).Param;
  isAsm := IdentifierAt(BlockIdentIndex).isAsm;
  isReg := IdentifierAt(BlockIdentIndex).isRegister;
  isInt := IdentifierAt(BlockIdentIndex).isInterrupt;
  isInl := IdentifierAt(BlockIdentIndex).isInline;
  isOvr := IdentifierAt(BlockIdentIndex).isOverload;

  isInterrupt := isInt;

  Inc(NumBlocks);
  Inc(BlockStackTop);
  BlockStack[BlockStackTop] := NumBlocks;
  IdentifierAt(BlockIdentIndex).ProcAsBlock := NumBlocks;


  GenerateLocal(BlockIdentIndex, IsFunction);

  if (BlockStack[BlockStackTop] <> 1) {and (NumParams > 0)} and IdentifierAt(BlockIdentIndex).isRecursion then
  begin

    if IdentifierAt(BlockIdentIndex).isRegister then
      Error(i, 'Calling convention directive "REGISTER" not applicable with recursion');

    if not isInl then
    begin
      asm65(#9'.ifdef @VarData');

      if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
      begin
        asm65(#9'sta :bp2');
        asm65(#9'sty :bp2+1');
      end;

      asm65('@new'#9'lda <@VarData');      // @AllocMem
      asm65(#9'sta :ztmp');
      asm65(#9'lda >@VarData');
      asm65(#9'ldy #@VarDataSize-1');
      asm65(#9'jsr @AllocMem');

      if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
      begin
        asm65(#9'lda :bp2');
        asm65(#9'ldy :bp2+1');
      end;

      asm65(#9'eif');
    end;

  end;




  if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
  begin

    //  if ParamIndex = 1 then begin
    asm65(#9'sta ' + GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[0].Name);
    asm65(#9'sty ' + GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[0].Name + '+1');

    DefineIdent(i, GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[0].Name, VARIABLE,
      TTokenKind.WORDTOK, 0, TDataType.UNTYPETOK, 0);
    IdentifierAt(NumIdent).PassMethod := TParameterPassingMethod.VARPASSING;
    IdentifierAt(NumIdent).AllocElementType := TDataType.WORDTOK;
    //  end;

    NumAllocElements := 0;

    for ParamIndex := 1 to GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).NumFields do
      if GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].ObjectVariable = False then
      begin

        if NumAllocElements > 0 then
          if NumAllocElements > 255 then
          begin
            asm65(#9'add <' + IntToStr(NumAllocElements));
            asm65(#9'pha');
            asm65(#9'tya');
            asm65(#9'adc >' + IntToStr(NumAllocElements));
            asm65(#9'tay');
            asm65(#9'pla');
          end
          else
          begin
            asm65(#9'add #' + IntToStr(NumAllocElements));
            asm65(#9'scc');
            asm65(#9'iny');
          end;

        asm65(#9'sta ' + GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].Name);
        asm65(#9'sty ' + GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].Name + '+1');


        if ParamIndex <> GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).NumFields then
        begin

          if (GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType =
            TDataType.POINTERTOK) and (GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[
            ParamIndex].NumAllocElements > 0) then
          begin

            NumAllocElements := GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[
              ParamIndex].NumAllocElements and $ffff;

            if GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].NumAllocElements shr
              16 > 0 then
              NumAllocElements := (NumAllocElements *
                (GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].NumAllocElements shr 16));

            NumAllocElements := NumAllocElements * GetDataSize(
              GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].AllocElementType);

          end
          else
            case GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType of
              TDataType.FILETOK: NumAllocElements := 12;
              TDataType.STRINGPOINTERTOK: NumAllocElements :=
                  GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].NumAllocElements;
              TDataType.RECORDTOK: NumAllocElements :=
                  ObjectRecordSize(GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field
                  [ParamIndex].NumAllocElements);
              else
                NumAllocElements :=
                  GetDataSize(GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType);

            end;

        end;

      end;

  end;   // IdentifierAt(BlockIdentIndex).ObjectIndex


  //writeln;
  // Allocate parameters as local variables of the current block if necessary
  for ParamIndex := 1 to NumParams do
  begin

    //  writeln(Param[ParamIndex].Name,':',Param[ParamIndex].DataType,'|',Param[ParamIndex].NumAllocElements and $FFFF,'/',Param[ParamIndex].NumAllocElements shr 16);

    if Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then
    begin

      if isReg and (ParamIndex in [1..3]) then
      begin
        tmpVarDataSize := GetVarDataSize;

        DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType,
          Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

        IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).isAbsolute := True;
        IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).Value := (Byte(ParamIndex) shl 24) or $80000000;

        SetVarDataSize(i, tmpVarDataSize);

      end
      else
        if Param[ParamIndex].DataType in Pointers then
          DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, 0,
            Param[ParamIndex].DataType, 0)
        else
          DefineIdent(i, Param[ParamIndex].Name, VARIABLE, TDataType.POINTERTOK, 0, Param[ParamIndex].DataType, 0);


      if (Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
      begin

        tmpVarDataSize := GetVarDataSize;

        for j := 1 to GetTypeAtIndex(Param[ParamIndex].NumAllocElements).NumFields do
        begin

          DefineIdent(i, Param[ParamIndex].Name + '.' + GetTypeAtIndex(
            Param[ParamIndex].NumAllocElements).Field[j].Name,
            VARIABLE,
            GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].DataType,
            GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].NumAllocElements,
            GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].AllocElementType, 0,
            TTokenKind.DATAORIGINOFFSET);

          IdentifierAt(NumIdent).Value := IdentifierAt(NumIdent).Value - tmpVarDataSize;
          IdentifierAt(NumIdent).PassMethod := Param[ParamIndex].PassMethod;

          if IdentifierAt(NumIdent).AllocElementType = TDataType.UNTYPETOK then
            IdentifierAt(NumIdent).AllocElementType := IdentifierAt(NumIdent).DataType;

        end;

        SetVarDataSize(i, tmpVarDataSize);

      end
      else

        if Param[ParamIndex].DataType in Pointers then
          IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).AllocElementType := Param[ParamIndex].AllocElementType
        else
          IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).AllocElementType := Param[ParamIndex].DataType;

      IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).NumAllocElements :=
        Param[ParamIndex].NumAllocElements and $FFFF;
      IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).NumAllocElements_ :=
        Param[ParamIndex].NumAllocElements shr 16;

    end
    else
    begin
      if isReg and (ParamIndex in [1..3]) then
      begin
        tmpVarDataSize := GetVarDataSize;

        DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType,
          Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

        IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).isAbsolute := True;
        IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).Value := (Byte(ParamIndex) shl 24) or $80000000;

        SetVarDataSize(i, tmpVarDataSize);

      end
      else
        DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType,
          Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      //  writeln(Param[ParamIndex].Name,',',Param[ParamIndex].DataType);

      if (Param[ParamIndex].DataType = TDataType.POINTERTOK) and
        (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
      begin    // fix issue #94

        tmpVarDataSize := GetVarDataSize;

        for j := 1 to GetTypeAtIndex(Param[ParamIndex].NumAllocElements).NumFields do
        begin

          DefineIdent(i, Param[ParamIndex].Name + '.' + GetTypeAtIndex(
            Param[ParamIndex].NumAllocElements).Field[j].Name,
            VARIABLE,
            GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].DataType,
            GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].NumAllocElements,
            GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].AllocElementType, 0,
            TTokenKind.DATAORIGINOFFSET);

          IdentifierAt(NumIdent).Value := IdentifierAt(NumIdent).Value - tmpVarDataSize;
          IdentifierAt(NumIdent).PassMethod := Param[ParamIndex].PassMethod;

          if IdentifierAt(NumIdent).AllocElementType = TDataType.UNTYPETOK then
            IdentifierAt(NumIdent).AllocElementType := IdentifierAt(NumIdent).DataType;

        end;

        SetVarDataSize(i, tmpVarDataSize);

      end
      else

        if Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
          for j := 1 to GetTypeAtIndex(Param[ParamIndex].NumAllocElements).NumFields do
          begin

            // writeln(Param[ParamIndex].Name + '.' + GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].Name,',',GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].DataType,',',GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].NumAllocElements,',',GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].AllocElementType);

            DefineIdent(i, Param[ParamIndex].Name + '.' + GetTypeAtIndex(
              Param[ParamIndex].NumAllocElements).Field[j].Name,
              VARIABLE,
              GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].DataType,
              GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].NumAllocElements,
              GetTypeAtIndex(Param[ParamIndex].NumAllocElements).Field[j].AllocElementType, 0);

            IdentifierAt(NumIdent).PassMethod := Param[ParamIndex].PassMethod;
          end;

    end;

    IdentifierAt(GetIdentIndex(Param[ParamIndex].Name)).PassMethod := Param[ParamIndex].PassMethod;
  end;


  // Allocate Result variable if the current block is a function
  if IsFunction then
  begin  //DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, 0, 0, 0);

    tmpVarDataSize := GetVarDataSize;

    //  writeln(IdentifierAt(BlockIdentIndex).name,',',FunctionResultType,',',FunctionNumAllocElements,',',FunctionAllocElementType);

    DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, FunctionNumAllocElements, FunctionAllocElementType, 0);

    if isReg and (FunctionResultType in OrdinalTypes + RealTypes) then
    begin
      IdentifierAt(NumIdent).isAbsolute := True;
      IdentifierAt(NumIdent).Value := $87000000;  // :STACKORIGIN-4 -> :TMP

      SetVarDataSize(i, tmpVarDataSize);
    end;

    if FunctionResultType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
      for j := 1 to GetTypeAtIndex(FunctionNumAllocElements).NumFields do
      begin

        DefineIdent(i, 'RESULT.' + GetTypeAtIndex(FunctionNumAllocElements).Field[j].Name,
          VARIABLE,
          GetTypeAtIndex(FunctionNumAllocElements).Field[j].DataType,
          GetTypeAtIndex(FunctionNumAllocElements).Field[j].NumAllocElements,
          GetTypeAtIndex(FunctionNumAllocElements).Field[j].AllocElementType, 0);

        //       IdentifierAt(GetIdentIndex(iname)).PassMethod := VALPASSING;
      end;

  end;


  yes := {(IdentifierAt(BlockIdentIndex).ObjectIndex > 0) or} IdentifierAt(BlockIdentIndex).isRecursion or
    IdentifierAt(BlockIdentIndex).isStdCall;

  for ParamIndex := NumParams downto 1 do
    if not ((Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING) or
      ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].NumAllocElements and $FFFF in [0, 1])) or
      ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].AllocElementType in
      [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or (Param[ParamIndex].DataType in OrdinalTypes + RealTypes)) then
    begin
      yes := True;
      Break;
    end;


  // yes:=true;


  // Load ONE parameters from the stack
  if (IdentifierAt(BlockIdentIndex).ObjectIndex = 0) then

    // TODO: This can be written shorter
    if Param[1].DataType = ENUMTOK then
    begin

      if (yes = False) and (NumParams = 1) and (GetDataSize(Param[1].AllocElementType) = 1) and
        (Param[1].PassMethod <> TParameterPassingMethod.VARPASSING) then
        asm65(#9'sta ' + Param[1].Name);
    end
    else

      if (yes = False) and (NumParams = 1) and (GetDataSize(Param[1].DataType) = 1) and
        (Param[1].PassMethod <> TParameterPassingMethod.VARPASSING) then
        asm65(#9'sta ' + Param[1].Name);




  // Load parameters from the stack
  if yes then
  begin
    for ParamIndex := 1 to NumParams do
    begin

      if IdentifierAt(BlockIdentIndex).isRecursion or IdentifierAt(BlockIdentIndex).isStdCall or (NumParams = 1) then
      begin

        if Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then
          GenerateAssignment(ASPOINTER, GetDataSize(TDataType.POINTERTOK), 0, Param[ParamIndex].Name)
        else
        begin
          if Param[ParamIndex].DataType = TDatatype.ENUMTOK then
            GenerateAssignment(ASPOINTER, GetDataSize(Param[ParamIndex].AllocElementType), 0, Param[ParamIndex].Name)
          else
            GenerateAssignment(ASPOINTER, GetDataSize(Param[ParamIndex].DataType), 0, Param[ParamIndex].Name);

        end;


        if (Param[ParamIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and
          (Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
          (Param[ParamIndex].NumAllocElements and $FFFF > 1) then      // copy arrays

          if Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
          begin

            asm65(':move');
            asm65(Param[ParamIndex].Name);
            asm65(IntToStr(RecordSize(GetIdentIndex(Param[ParamIndex].Name))));

          end
          else
            if not (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
            begin

              if Param[ParamIndex].NumAllocElements shr 16 <> 0 then
                NumAllocElements := (Param[ParamIndex].NumAllocElements and $FFFF) *
                  (Param[ParamIndex].NumAllocElements shr 16)
              else
                NumAllocElements := Param[ParamIndex].NumAllocElements;

              asm65(':move');
              asm65(Param[ParamIndex].Name);
              asm65(IntToStr(Integer(NumAllocElements * GetDataSize(Param[ParamIndex].AllocElementType))));
            end;

      end
      else
      begin

        Assignment := True;

        if (Param[ParamIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and
          (Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
          (Param[ParamIndex].NumAllocElements and $FFFF > 1) then      // copy arrays

          if Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
          begin

            Assignment := False;
            asm65(#9'dex');

          end
          else
            if not (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
            begin

              Assignment := False;
              asm65(#9'dex');

            end;

        if Assignment then
          if Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then
            GenerateAssignment(ASPOINTER, GetDataSize(TDataType.POINTERTOK), 0, Param[ParamIndex].Name)
          else
          begin

            if Param[ParamIndex].DataType = ENUMTYPE then
              GenerateAssignment(ASPOINTER, GetDataSize(Param[ParamIndex].AllocElementType), 0, Param[ParamIndex].Name)
            else
              GenerateAssignment(ASPOINTER, GetDataSize(Param[ParamIndex].DataType), 0, Param[ParamIndex].Name);

          end;
      end;

      if (Paramindex <> NumParams) then asm65(#9'jmi @main');

    end;

    asm65('@main');
  end;


  // Object variable definitions
  if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
    for ParamIndex := 1 to GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).NumFields do
    begin

      tmpVarDataSize := GetVarDataSize;

{
  writeln(GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].Name,',',
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType,',',
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].NumAllocElements,',',
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].AllocElementType);
}

      if GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType =
        TDataType.OBJECTTOK then
        Error(i, '-- under construction --');

      if GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType =
        TDataType.RECORDTOK then
        ConstVal := 0;

      if GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType in
        [TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK] then

        DefineIdent(i, GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].Name,
          VARIABLE, GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType,
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].NumAllocElements,
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].AllocElementType, 0)
      else

        DefineIdent(i, GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].Name,
          VARIABLE, TTokenKind.POINTERTOK,
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].NumAllocElements,
          GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].DataType, 0);

      IdentifierAt(NumIdent).PassMethod := TParameterPassingMethod.VARPASSING;
      IdentifierAt(NumIdent).ObjectVariable := True;

      SetVarDataSize(i, tmpVarDataSize + GetDataSize(TDataType.POINTERTOK));

      if GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[ParamIndex].ObjectVariable then
      begin
        IdentifierAt(NumIdent).Value := ConstVal + DATAORIGIN;

        Inc(ConstVal, GetDataSize(GetTypeAtIndex(IdentifierAt(BlockIdentIndex).ObjectIndex).Field[
          ParamIndex].DataType));

        SetVarDataSize(i, tmpVarDataSize);
      end;

    end;


  asm65;

  if not isAsm then        // skaczemy do poczatku bloku procedury, wazne dla zagniezdzonych procedur / funkcji
    GenerateDeclarationProlog;


  while TokenAt(i).Kind in [TTokenKind.CONSTTOK, TTokenKind.TYPETOK, TTokenKind.VARTOK,
      TTokenKind.LABELTOK, TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.PROGRAMTOK,
      TTokenKind.USESTOK, TTokenKind.LIBRARYTOK, TTokenKind.EXPORTSTOK, TTokenKind.CONSTRUCTORTOK,
      TTokenKind.DESTRUCTORTOK, TTokenKind.LINKTOK, TTokenKind.UNITBEGINTOK, TTokenKind.UNITENDTOK,
      TTokenKind.IMPLEMENTATIONTOK, TTokenKind.INITIALIZATIONTOK, TTokenKind.IOCHECKON,
      TTokenKind.IOCHECKOFF, TTokenKind.LOOPUNROLLTOK, TTokenKind.NOLOOPUNROLLTOK,
      TTokenKind.PROCALIGNTOK, TTokenKind.LOOPALIGNTOK, TTokenKind.LINKALIGNTOK, TTokenKind.INFOTOK,
      TTokenKind.WARNINGTOK, TTokenKind.ERRORTOK] do
  begin

    if TokenAt(i).Kind = TTokenKind.LINKTOK then
    begin

      if codealign.link > 0 then
      begin
        asm65(#9'.align $' + IntToHex(codealign.link, 4));
        asm65;
      end;

      asm65(#9'.link ''' + linkObj[TokenAt(i).Value] + '''');
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.LOOPUNROLLTOK then
    begin
      if Pass = TPass.CODE_GENERATION then loopunroll := True;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.NOLOOPUNROLLTOK then
    begin
      if Pass = TPass.CODE_GENERATION then loopunroll := False;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.PROCALIGNTOK then
    begin
      if Pass = TPass.CODE_GENERATION then codealign.proc := TokenAt(i).Value;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.LOOPALIGNTOK then
    begin
      if Pass = TPass.CODE_GENERATION then codealign.loop := TokenAt(i).Value;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.LINKALIGNTOK then
    begin
      if Pass = TPass.CODE_GENERATION then codealign.link := TokenAt(i).Value;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.INFOTOK then
    begin
      if Pass = TPass.CODE_GENERATION then writeln('User defined: ' + msgLists.msgUser[TokenAt(i).Value]);
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.WARNINGTOK then
    begin
      WarningUserDefined(i);
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.ERRORTOK then
    begin
      if Pass = TPass.CODE_GENERATION then Error(i, TErrorCode.UserDefined);
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.IOCHECKON then
    begin
      IOCheck := True;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.IOCHECKOFF then
    begin
      IOCheck := False;
      Inc(i, 2);
    end;


    if TokenAt(i).Kind = TTokenKind.UNITBEGINTOK then
    begin
      asm65separator;

      DefineIdent(i, TokenAt(i).GetSourceFileName, UNITTYPE, TDataType.UNTYPETOK, 0, TDataType.UNTYPETOK, 0);
      IdentifierAt(NumIdent).SourceFile := TokenAt(i).SourceLocation.SourceFile;

      //   writeln(UnitArray[TokenAt(i).UnitIndex].Name,',',IdentifierAt(NumIdent).UnitIndex,',',TokenAt(i).UnitIndex);

      asm65;
      asm65('.local'#9 + TokenAt(i).GetSourceFileName, '; UNIT');

      ActiveSourceFile := TokenAt(i).SourceLocation.SourceFile;

      CheckTok(i + 1, TTokenKind.UNITTOK);
      CheckTok(i + 2, TTokenKind.IDENTTOK);

      if TokenAt(i + 2).Name <> TokenAt(i).GetSourceFileName then
        Error(i + 2, 'Illegal unit name: ' + TokenAt(i + 2).Name);

      CheckTok(i + 3, TTokenKind.SEMICOLONTOK);

      while TokenAt(i + 4).Kind in [TTokenKind.WARNINGTOK, TTokenKind.ERRORTOK, TTokenKind.INFOTOK] do Inc(i, 2);

      CheckTok(i + 4, TTokenKind.INTERFACETOK);

      INTERFACETOK_USE := True;

      PublicSection := True;
      ImplementationUse := False;

      Inc(i, 5);
    end;


    if TokenAt(i).Kind = TTokenKind.UNITENDTOK then
    begin

      if not ImplementationUse then
        CheckTok(i, TTokenKind.IMPLEMENTATIONTOK);

      GenerateProcFuncAsmLabels(BlockIdentIndex);

      VarRegister := 0;

      asm65;
      asm65('.endl', '; UNIT ' + TokenAt(i).GetSourceFileName);

      j := NumIdent;

      while (j > 0) and (IdentifierAt(j).SourceFile.UnitIndex = ActiveSourceFile.UnitIndex) do
      begin
        // If procedure or function, delete parameters first
        if IdentifierAt(j).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
          TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
          if IdentifierAt(j).IsUnresolvedForward and (IdentifierAt(j).isExternal = False) then
            Error(i, 'Unresolved forward declaration of ' + IdentifierAt(j).Name);

        Dec(j);
      end;

      ActiveSourceFile := Common.SourceFileList.GetSourceFile(1);

      PublicSection := True;
      ImplementationUse := False;

      Inc(i);
    end;


    if TokenAt(i).Kind = TTokenKind.IMPLEMENTATIONTOK then
    begin

      INTERFACETOK_USE := False;

      PublicSection := False;
      ImplementationUse := True;

      Inc(i);
    end;


    if TokenAt(i).Kind = TTokenKind.EXPORTSTOK then
    begin

      Inc(i);

      repeat

        CheckTok(i, TTokenKind.IDENTTOK);

        if Pass = TPass.CALL_DETERMINATION then
        begin
          IdentIndex := GetIdentIndex(TokenAt(i).Name);

          if IdentIndex = 0 then
            Error(i, TErrorCode.UnknownIdentifier);

          if IdentifierAt(IdentIndex).isInline then
            Error(i, 'INLINE is not allowed to exports');


          if IdentifierAt(IdentIndex).isOverload then
          begin

            for idx := 1 to NumIdent do
              if {(IdentifierAt(idx).ProcAsBlock = IdentifierAt(IdentIndex).ProcAsBlock) and}
              (IdentifierAt(idx).Name = IdentifierAt(IdentIndex).Name) then
                AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(idx).ProcAsBlock);

          end
          else
            AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(IdentIndex).ProcAsBlock);

        end;

        Inc(i);

        if not (TokenAt(i).Kind in [TTokenKind.COMMATOK, TTokenKind.SEMICOLONTOK]) then
          CheckTok(i, TTokenKind.SEMICOLONTOK);

        if TokenAt(i).Kind = TTokenKind.COMMATOK then Inc(i);

      until TokenAt(i).Kind = TTokenKind.SEMICOLONTOK;

      Inc(i, 1);

    end;


    if (TokenAt(i).Kind = TTokenKind.INITIALIZATIONTOK) or ((PublicSection = False) and
      (TokenAt(i).Kind = TTokenKind.BEGINTOK)) then
    begin

      if not ImplementationUse then
        CheckTok(i, TTokenKind.IMPLEMENTATIONTOK);

      asm65separator;
      asm65separator(False);

      asm65('@UnitInit');

      j := CompileStatement(i + 1);
      while TokenAt(j + 1).Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

      asm65;
      asm65(#9'rts');

      i := j + 1;
    end;



    if TokenAt(i).Kind = TTokenKind.LIBRARYTOK then
    begin       // na samym poczatku listingu

      if LIBRARYTOK_USE then CheckTok(i, TTokenKind.BEGINTOK);

      CheckTok(i + 1, TTokenKind.IDENTTOK);

      LIBRARY_NAME := TokenAt(i + 1).Name;

      if (TokenAt(i + 2).Kind = TTokenKind.COLONTOK) and (TokenAt(i + 3).Kind = TTokenKind.INTNUMBERTOK) then
      begin

        CODEORIGIN_BASE := TokenAt(i + 3).Value;

        target.codeorigin := CODEORIGIN_BASE;

        Inc(i, 2);
      end;

      Inc(i);

      CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

      Inc(i, 2);

      LIBRARYTOK_USE := True;
    end;



    if TokenAt(i).Kind = TTokenKind.PROGRAMTOK then
    begin       // na samym poczatku listingu

      if PROGRAMTOK_USE then CheckTok(i, TTokenKind.BEGINTOK);

      CheckTok(i + 1, TTokenKind.IDENTTOK);

      PROGRAM_NAME := TokenAt(i + 1).Name;

      Inc(i);


      if TokenAt(i + 1).Kind = TTokenKind.OPARTOK then
      begin

        Inc(i);

        repeat
          Inc(i);
          CheckTok(i, TTokenKind.IDENTTOK);

          if TokenAt(i + 1).Kind = TTokenKind.COMMATOK then Inc(i);

        until TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK;

        CheckTok(i + 1, TTokenKind.CPARTOK);

        Inc(i);
      end;


      if (TokenAt(i + 1).Kind = TTokenKind.COLONTOK) and (TokenAt(i + 2).Kind = TTokenKind.INTNUMBERTOK) then
      begin

        CODEORIGIN_BASE := TokenAt(i + 2).Value;

        target.codeorigin := CODEORIGIN_BASE;

        Inc(i, 2);
      end;


      CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

      Inc(i, 2);

      PROGRAMTOK_USE := True;
    end;


    if TokenAt(i).Kind = TTokenKind.USESTOK then
    begin    // co najwyzej po PROGRAM

      if LIBRARYTOK_USE then
      begin

        j := i - 1;

        while TokenAt(j).Kind in [TTokenKind.SEMICOLONTOK, TTokenKind.IDENTTOK, TTokenKind.COLONTOK,
            TTokenKind.INTNUMBERTOK] do
          Dec(j);

        if TokenAt(j).Kind <> TTokenKind.LIBRARYTOK then
          CheckTok(i, TTokenKind.BEGINTOK);

      end;

      if PROGRAMTOK_USE then
      begin

        j := i - 1;

        while TokenAt(j).Kind in [TTokenKind.SEMICOLONTOK, TTokenKind.CPARTOK, TTokenKind.OPARTOK,
            TTokenKind.IDENTTOK, TTokenKind.COMMATOK, TTokenKind.COLONTOK, TTokenKind.INTNUMBERTOK] do Dec(j);

        if TokenAt(j).Kind <> TTokenKind.PROGRAMTOK then
          CheckTok(i, TTokenKind.BEGINTOK);

      end;

      if INTERFACETOK_USE then
        if TokenAt(i - 1).Kind <> TTokenKind.INTERFACETOK then
          CheckTok(i, TTokenKind.IMPLEMENTATIONTOK);

      if ImplementationUse then
        if TokenAt(i - 1).Kind <> TTokenKind.IMPLEMENTATIONTOK then
          CheckTok(i, TTokenKind.BEGINTOK);

      Inc(i);

      idx := i;

      SourceFileList := nil;
      SetLength(SourceFileList, 1);    // preliminary USES reading, we check if there are any duplicate entries

      repeat

        CheckTok(i, TTokenKind.IDENTTOK);

        for j := 0 to High(SourceFileList) - 1 do
          if SourceFileList[j] = TokenAt(i).Name then
            Error(i, 'Duplicate identifier ''' + TokenAt(i).Name + '''');

        j := High(SourceFileList);
        SourceFileList[j] := TokenAt(i).Name;
        SetLength(SourceFileList, j + 2);

        Inc(i);

        if TokenAt(i).Kind = TTokenKind.INTOK then
        begin
          CheckTok(i + 1, TTokenKind.STRINGLITERALTOK);

          Inc(i, 2);
        end;

        if not (TokenAt(i).Kind in [TTokenKind.COMMATOK, TTokenKind.SEMICOLONTOK]) then
          CheckTok(i, TTokenKind.SEMICOLONTOK);

        if TokenAt(i).Kind = TTokenKind.COMMATOK then Inc(i);

      until TokenAt(i).Kind <> TTokenKind.IDENTTOK;

      CheckTok(i, TTokenKind.SEMICOLONTOK);


      i := idx;

      SetLength(SourceFileList, 0);    //  proper reading USES

      repeat

        CheckTok(i, TTokenKind.IDENTTOK);

        yes := True;
        for j := 1 to ActiveSourceFile.Units do
          if (ActiveSourceFile.AllowedUnitNames[j] = TokenAt(i).Name) or (TokenAt(i).Name = 'SYSTEM') then
            yes := False;

        if yes then
        begin

          Inc(ActiveSourceFile.Units);

          if ActiveSourceFile.Units > MAXALLOWEDUNITS then
            Error(i, 'Out of resources, MAXALLOWEDUNITS');

          ActiveSourceFile.AllowedUnitNames[ActiveSourceFile.Units] := TokenAt(i).Name;

        end;

        Inc(i);

        if TokenAt(i).Kind = TTokenKind.INTOK then
        begin
          CheckTok(i + 1, TTokenKind.STRINGLITERALTOK);

          Inc(i, 2);
        end;

        if not (TokenAt(i).Kind in [TTokenKind.COMMATOK, TTokenKind.SEMICOLONTOK]) then
          CheckTok(i, TTokenKind.SEMICOLONTOK);

        if TokenAt(i).Kind = TTokenKind.COMMATOK then Inc(i);

      until TokenAt(i).Kind <> TTokenKind.IDENTTOK;

      CheckTok(i, TTokenKind.SEMICOLONTOK);

      Inc(i);

    end;

    // -----------------------------------------------------------------------------
    //           LABEL
    // -----------------------------------------------------------------------------

    if TokenAt(i).Kind = TTokenKind.LABELTOK then
    begin

      Inc(i);

      repeat

        CheckTok(i, TTokenKind.IDENTTOK);

        DefineIdent(i, TokenAt(i).Name, TTokenKind.LABELTOK, TDataType.UNTYPETOK, 0, TDataType.UNTYPETOK, 0);

        Inc(i);

        if TokenAt(i).Kind = TTokenKind.COMMATOK then Inc(i);

      until TokenAt(i).Kind <> TTokenKind.IDENTTOK;

      i := i + 1;
    end;  // if TTokenKind.LABELTOK

    // -----------------------------------------------------------------------------
    //           CONST
    // -----------------------------------------------------------------------------

    if TokenAt(i).Kind = TTokenKind.CONSTTOK then
    begin
      repeat

        if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
          Error(i + 1, 'Constant name expected but ' + TokenList.GetTokenSpellingAtIndex(i + 1) + ' found')
        else
          if TokenAt(i + 2).Kind = TTokenKind.EQTOK then
          begin

            j := CompileConstExpression(i + 3, ConstVal, ConstValType, TTokenKind.INTEGERTOK, False, False);

            if TokenAt(j).GetDataType in StringTypes then
            begin

              if TokenAt(j).StrLength > 255 then
                DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, TDataType.POINTERTOK, 0, TTokenKind.CHARTOK,
                  ConstVal + CODEORIGIN, TDataType.PCHARTOK)
              else
                DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, ConstValType, TokenAt(j).StrLength,
                  TDataType.CHARTOK, ConstVal + CODEORIGIN, TokenAt(j).Kind);

            end
            else
              if (ConstValType in Pointers) then
                Error(j, TErrorCode.IllegalExpression)
              else
                DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, ConstValType, 0, TDataType.UNTYPETOK,
                  ConstVal, TokenAt(j).Kind);

            i := j;
          end
          else
            if TokenAt(i + 2).Kind = TTokenKind.COLONTOK then
            begin

              open_array := False;


              if (TokenAt(i + 3).Kind = TDataType.ARRAYTOK) and (TokenAt(i + 4).Kind = TTokenKind.OFTOK) then
              begin

                j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

                if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                  Error(i, 'Only Array of ^' + InfoAboutToken(VarType) + ' supported')
                else
                  if VarType = TDataType.ENUMTOK then
                    Error(i, InfoAboutToken(VarType) + ' arrays are not supported');

                if VarType = TDataType.POINTERTOK then
                begin

                  if AllocElementType = TDataType.UNTYPETOK then
                  begin
                    NumAllocElements := 1;
                    AllocElementType := VarType;
                  end;

                end
                else
                begin
                  NumAllocElements := 1;
                  AllocElementType := VarType;
                  VarType := TDataType.POINTERTOK;
                end;

                if not (AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then open_array := True;

              end
              else
              begin

                j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

                if TokenAt(i + 3).Kind = TDataType.ARRAYTOK then
                  j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

              end;


              if (VarType in Pointers) and (NumAllocElements = 0) then
                if AllocElementType <> TDataType.CHARTOK then Error(j, TErrorCode.IllegalExpression);


              CheckTok(j + 1, TTokenKind.EQTOK);

              if TokenAt(i + 3).Kind in StringTypes then
              begin

                j := CompileConstExpression(j + 2, ConstVal, ConstValType);

                if TokenAt(i + 3).Kind = TTokenKind.PCHARTOK then
                  DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, TDataType.POINTERTOK, 0, TTokenKind.CHARTOK,
                    ConstVal + CODEORIGIN + 1, TDataType.PCHARTOK)
                else
                  DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, ConstValType, TokenAt(j).StrLength,
                    TDataType.CHARTOK, ConstVal + CODEORIGIN, TokenAt(j).Kind);

              end
              else

                if NumAllocElements > 0 then
                begin

                  DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, VarType, NumAllocElements,
                    AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE, TDataType.IDENTTOK);

                  if (IdentifierAt(NumIdent).NumAllocElements in [0, 1]) and (open_array = False) then
                    Error(i, TErrorCode.IllegalExpression)
                  else
                    if open_array then
                    begin                  // const array of type = [ ]

                      if (TokenAt(j + 2).Kind = TTokenKind.STRINGLITERALTOK) and
                        (AllocElementType = TDataType.CHARTOK) then
                      begin  // = 'string'

                        IdentifierAt(NumIdent).Value := TokenAt(j + 2).StrAddress + CODEORIGIN_BASE;
                        if VarType <> TTokenKind.STRINGPOINTERTOK then Inc(IdentifierAt(NumIdent).Value);

                        IdentifierAt(NumIdent).NumAllocElements := TokenAt(j + 2).StrLength;

                        j := j + 2;

                        NumAllocElements := 0;

                      end
                      else
                      begin
                        j := ReadDataOpenArray(j + 2, NumStaticStrChars, AllocElementType,
                          NumAllocElements, True, TokenAt(j).Kind = TTokenKind.PCHARTOK);

                        IdentifierAt(NumIdent).NumAllocElements := NumAllocElements;
                      end;

                    end
                    else
                    begin                    // const array [] of type = ( )

                      if (TokenAt(j + 2).Kind = TTokenKind.STRINGLITERALTOK) and
                        (AllocElementType = TDataType.CHARTOK) then
                      begin  // = 'string'

                        if TokenAt(j + 2).StrLength > NumAllocElements then
                          Error(j + 2, 'String length is larger than array of char length');

                        IdentifierAt(NumIdent).Value := TokenAt(j + 2).StrAddress + CODEORIGIN_BASE;
                        if VarType <> TDataType.STRINGPOINTERTOK then Inc(IdentifierAt(NumIdent).Value);

                        IdentifierAt(NumIdent).NumAllocElements := TokenAt(j + 2).StrLength;

                        j := j + 2;

                        NumAllocElements := 0;

                      end
                      else
                        j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType,
                          NumAllocElements, True, TokenAt(j).Kind = TTokenKind.PCHARTOK);

                    end;


                  if NumAllocElements shr 16 > 0 then
                    Inc(NumStaticStrChars, ((NumAllocElements and $ffff) * (NumAllocElements shr 16)) *
                      GetDataSize(AllocElementType))
                  else
                    Inc(NumStaticStrChars, NumAllocElements * GetDataSize(AllocElementType));

                end
                else
                begin
                  j := CompileConstExpression(j + 2, ConstVal, ConstValType, VarType, False);


                  if (VarType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
                    (ConstValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then ConstValType := VarType;
                  if (VarType = TDataType.SHORTREALTOK) and (ConstValType = TDataType.REALTOK) then
                    ConstValType := TDataType.SHORTREALTOK;


                  if (VarType in RealTypes) and (ConstValType in IntegerTypes) then
                  begin
                    ConstVal := FromInt64(ConstVal);
                    ConstValType := VarType;
                  end;

                  GetCommonType(i + 1, VarType, ConstValType);

                  DefineIdent(i + 1, TokenAt(i + 1).Name, CONSTANT, VarType, 0, TDataType.UNTYPETOK,
                    ConstVal, TokenAt(j).Kind);
                end;

              i := j;
            end
            else
              CheckTok(i + 2, TTokenKind.EQTOK);

        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

        Inc(i);
      until TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK;

      Inc(i);
    end;  // if TTokenKind.CONSTTOK

    // -----------------------------------------------------------------------------
    //        TYPE
    // -----------------------------------------------------------------------------

    if TokenAt(i).Kind = TTokenKind.TYPETOK then
    begin
      repeat
        if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
          Error(i + 1, 'Type name expected but ' + tokenList.GetTokenSpellingAtIndex(i + 1) + ' found')
        else
        begin

          CheckTok(i + 2, TTokenKind.EQTOK);

          if (TokenAt(i + 3).Kind = TTokenKind.ARRAYTOK) and (TokenAt(i + 4).Kind <> TTokenKind.OBRACKETTOK) then
          begin
            j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

            DefineIdent(i + 1, TokenAt(i + 1).Name, USERTYPE, VarType, NumAllocElements,
              AllocElementType, 0, TokenAt(i + 3).Kind);
            IdentifierAt(NumIdent).Pass := TPass.CALL_DETERMINATION;

          end
          else
          begin
            j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

            if TokenAt(i + 3).Kind = TTokenKind.ARRAYTOK then
              j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

            DefineIdent(i + 1, TokenAt(i + 1).Name, USERTYPE, VarType, NumAllocElements,
              AllocElementType, 0, TokenAt(i + 3).Kind);
            IdentifierAt(NumIdent).Pass := TPass.CALL_DETERMINATION;

          end;

        end;

        CheckTok(j + 1, TTokenKind.SEMICOLONTOK);

        i := j + 1;
      until TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK;

      CheckForwardResolutions;

      i := i + 1;
    end;  // if TTokenKind.TYPETOK
    // -----------------------------------------------------------------------------
    //          VAR
    // -----------------------------------------------------------------------------

    if TokenAt(i).Kind = TTokenKind.VARTOK then
    begin

      isVolatile := False;
      isStriped := False;

      NestedDataType := TDataType.UNTYPETOK;
      NestedAllocElementType := TDataType.UNTYPETOK;
      NestedNumAllocElements := 0;

      if (TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK) and (TokenAt(i + 2).Kind in
        [TTokenKind.VOLATILETOK, TTokenKind.STRIPEDTOK]) then
      begin
        CheckTok(i + 3, TTokenKind.CBRACKETTOK);

        if TokenAt(i + 2).Kind = TDataType.VOLATILETOK then
          isVolatile := True
        else
          isStriped := True;

        Inc(i, 3);
      end;

      repeat
        NumVarOfSameType := 0;
        repeat
          if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
            Error(i + 1, 'Variable name expected but ' + tokenList.GetTokenSpellingAtIndex(i + 1) + ' found')
          else
          begin
            Inc(NumVarOfSameType);

            if NumVarOfSameType > High(VarOfSameType) then
              Error(i, 'Too many formal parameters');

            VarOfSameType[NumVarOfSameType].Name := TokenAt(i + 1).Name;
          end;
          i := i + 2;
        until TokenAt(i).Kind <> TTokenKind.COMMATOK;

        CheckTok(i, TTokenKind.COLONTOK);

        // pack:=false;


        if TokenAt(i + 1).Kind = TTokenKind.PACKEDTOK then
        begin

          if (TokenAt(i + 2).Kind in [TTokenKind.ARRAYTOK, TTokenKind.RECORDTOK]) then
          begin
            Inc(i);
            // pack := true;
          end
          else
            CheckTok(i + 2, TTokenKind.RECORDTOK);

        end;


        IdType := TokenAt(i + 1).Kind;

        idx := i + 1;


        open_array := False;

        isAbsolute := False;
        isExternal := False;


        if (IdType = TDataType.ARRAYTOK) and (TokenAt(i + 2).Kind = TTokenKind.OFTOK) then
        begin      // array of type [Ordinal Types]

          i := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

          if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
            Error(i, 'Only Array of ^' + InfoAboutToken(VarType) + ' supported')
          else
            if VarType = TTokenKind.ENUMTOK then
              Error(i, InfoAboutToken(VarType) + ' arrays are not supported');

          if VarType = TDataType.POINTERTOK then
          begin

            if AllocElementType = TDataType.UNTYPETOK then
            begin
              NumAllocElements := 1;
              AllocElementType := VarType;
            end;

          end
          else
          begin
            NumAllocElements := 1;
            AllocElementType := VarType;
            VarType := TDataType.POINTERTOK;
          end;

          //if TokenAt(i + 1).Kind <> TTokenKind.EQTOK then isAbsolute := true;        // !!!!

          ConstVal := 1;

          if not (AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then open_array := True;

        end
        else
        begin

          i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

          if IdType = TDataType.ARRAYTOK then
            i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

          if (NumAllocElements = 1) or (NumAllocElements = $10001) then ConstVal := 1;

        end;


        if TokenAt(i + 1).Kind = TTokenKind.REGISTERTOK then
        begin

          if NumVarOfSameType > 1 then
            Error(i + 1, 'REGISTER can only be associated to one variable');

          isAbsolute := True;

          Inc(VarRegister, GetDataSize(VarType));

          ConstVal := (VarRegister + 3) shl 24 + 1;

          Inc(i);

        end
        else

          if TokenAt(i + 1).Kind = TTokenKind.EXTERNALTOK then
          begin

            if NumVarOfSameType > 1 then
              Error(i + 1, 'Only one variable can be initialized');

            isAbsolute := True;
            isExternal := True;

            Inc(i);

            external_libr := 0;

            if TokenAt(i + 1).Kind = TTokenKind.IDENTTOK then
            begin

              external_name := TokenAt(i + 1).Name;

              if TokenAt(i + 2).Kind = TTokenKind.STRINGLITERALTOK then
              begin
                external_libr := i + 2;

                Inc(i);
              end;

              Inc(i);
            end
            else
              if TokenAt(i + 1).Kind = TTokenKind.STRINGLITERALTOK then
              begin

                external_name := VarOfSameType[1].Name;
                external_libr := i + 1;

                Inc(i);
              end;


            ConstVal := 1;

          end
          else

            if TokenAt(i + 1).Kind = TTokenKind.ABSOLUTETOK then
            begin

              isAbsolute := True;

              if NumVarOfSameType > 1 then
                Error(i + 1, 'ABSOLUTE can only be associated to one variable');


              if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] {+ Pointers}) and (NumAllocElements = 0) then
                // brak mozliwosci identyfikacji dla takiego przypadku
                Error(i + 1, 'not possible in this case');

              Inc(i);

              varPassMethod := TParameterPassingMethod.UNDEFINED;

              if (TokenAt(i + 1).Kind = TTokenKind.IDENTTOK) and
                (IdentifierAt(GetIdentIndex(TokenAt(i + 1).Name)).Kind = TTokenKind.VARTOK) then
              begin
                ConstVal := IdentifierAt(GetIdentIndex(TokenAt(i + 1).Name)).Value - DATAORIGIN;

                varPassMethod := IdentifierAt(GetIdentIndex(TokenAt(i + 1).Name)).PassMethod;

                if (ConstVal < 0) or (ConstVal > $FFFFFF) then
                  Error(i, 'Range check error while evaluating constants (' + IntToStr(ConstVal) +
                    ' must be between 0 and ' + IntToStr($FFFFFF) + ')');


                ConstVal := -ConstVal;

                Inc(i);
              end
              else
              begin
                i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

                if VarType in Pointers then
                  GetCommonConstType(i, TTokenKind.WORDTOK, ActualParamType)
                else
                  GetCommonConstType(i, TTokenKind.CARDINALTOK, ActualParamType);

                if (ConstVal < 0) or (ConstVal > $FFFFFF) then
                  Error(i, 'Range check error while evaluating constants (' + IntToStr(ConstVal) +
                    ' must be between 0 and ' + IntToStr($FFFFFF) + ')');
              end;

              Inc(ConstVal);   // wyjatkowo, aby mozna bylo ustawic adres $0000, DefineIdent zmniejszy wartosc -1

            end;


        if IdType = TDataType.IDENTTOK then IdType := IdentifierAt(GetIdentIndex(TokenAt(idx).Name)).IdType;

        tmpVarDataSize := GetVarDataSize;    // dla ABSOLUTE, RECORD

        for VarOfSameTypeIndex := 1 to NumVarOfSameType do
        begin

          //  writeln(VarType,',',NumAllocElements and $FFFF,',',NumAllocElements shr 16,',',AllocElementType, ',',idType,',',varPassMethod,',',isAbsolute);


          if VarType = TDataType.DEREFERENCEARRAYTOK then
          begin

            VarType := TDataType.POINTERTOK;

            NestedNumAllocElements := NumAllocElements;

            IdType := TDataType.DEREFERENCEARRAYTOK;

            NumAllocElements := 1;

          end;

          if VarType = TDataType.ENUMTOK then
          begin

            DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, AllocElementType, 0,
              TDataType.UNTYPETOK, 0, IdType);

            IdentifierAt(NumIdent).DataType := TDataType.ENUMTOK;
            IdentifierAt(NumIdent).AllocElementType := AllocElementType;
            IdentifierAt(NumIdent).NumAllocElements := NumAllocElements;

          end
          else
          begin
            DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, VarType, NumAllocElements,
              AllocElementType, Ord(isAbsolute) * ConstVal, IdType);

            //    writeln('? ',VarOfSameType[VarOfSameTypeIndex].Name,',', NestedDataType,',',NestedAllocElementType,',',NestedNumAllocElements,'|',IdType);

            IdentifierAt(NumIdent).NestedDataType := NestedDataType;
            IdentifierAt(NumIdent).NestedAllocElementType := NestedAllocElementType;
            IdentifierAt(NumIdent).NestedNumAllocElements := NestedNumAllocElements;
            IdentifierAt(NumIdent).isVolatile := isVolatile;

            if varPassMethod <> TParameterPassingMethod.UNDEFINED then
              IdentifierAt(NumIdent).PassMethod := varPassMethod;


            if isStriped and (IdentifierAt(NumIdent).PassMethod <> TParameterPassingMethod.VARPASSING) then
            begin

              if NumAllocElements shr 16 > 0 then
                yes := (NumAllocElements and $FFFF) * (NumAllocElements shr 16) <= 256
              else
                yes := NumAllocElements <= 256;

              if yes then
                IdentifierAt(NumIdent).isStriped := True
              else
                WarningStripedAllowed(i);

            end;


            varPassMethod := TParameterPassingMethod.UNDEFINED;


            //    writeln(VarType, ' / ', AllocElementType ,' = ',NestedDataType, ',',NestedAllocElementType,',', hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));


            if (VarType = TDataType.POINTERTOK) and (AllocElementType = TDataType.STRINGPOINTERTOK) and
              (NestedNumAllocElements > 0) and (NumAllocElements > 1) then
            begin  // array [ ][ ] of string;


              if IdentifierAt(NumIdent).isAbsolute then
                Error(i, 'ABSOLUTE modifier is not available for this type of array');

              idx := IdentifierAt(NumIdent).Value - DATAORIGIN;

              if NumAllocElements shr 16 > 0 then
              begin

                for j := 0 to (NumAllocElements and $FFFF) * (NumAllocElements shr 16) - 1 do
                begin
                  SaveToDataSegment(idx, GetVarDataSize, TDataType.DATAORIGINOFFSET);

                  Inc(idx, 2);
                  IncVarDataSize(i, NestedNumAllocElements);
                end;

              end
              else
              begin

                for j := 0 to NumAllocElements - 1 do
                begin
                  SaveToDataSegment(idx, GetVarDataSize, TDataType.DATAORIGINOFFSET);

                  Inc(idx, 2);
                  IncVarDataSize(i, NestedNumAllocElements);
                end;

              end;

            end;

          end;


          CompileRecordDeclaration(i, VarOfSameType, tmpVarDataSize, ConstVal, VarOfSameTypeIndex,
            VarType, AllocElementType, NumAllocElements, isAbsolute, idx);  // !!! idx !!!

        end;


        if isExternal then
        begin

          IdentifierAt(NumIdent).isExternal := True;

          IdentifierAt(NumIdent).Alias := external_name;
          IdentifierAt(NumIdent).Libraries := external_libr;

        end;


        if isAbsolute and (open_array = False) then

          SetVarDataSize(i, tmpVarDataSize)

        else

          if TokenAt(i + 1).Kind = TTokenKind.EQTOK then
          begin

            if IdentifierAt(NumIdent).isStriped then
              Error(i + 1, 'Initialization for striped array not allowed');


            if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
              Error(i + 1, 'Initialization for ' + InfoAboutToken(VarType) + ' not allowed');

            if NumVarOfSameType > 1 then
              Error(i + 1, 'Only one variable can be initialized');

            Inc(i);


            if (VarType = TDataType.POINTERTOK) and (AllocElementType in
              [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then

            else
              idx := IdentifierAt(NumIdent).Value - DATAORIGIN;


            if not (VarType in Pointers) then
            begin

              IdentifierAt(NumIdent).isInitialized := True;

              i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

              if (VarType in RealTypes) and (ActualParamType = TDataType.REALTOK) then ActualParamType := VarType;

              GetCommonConstType(i, VarType, ActualParamType);

              SaveToDataSegment(idx, ConstVal, VarType);

            end
            else
            begin

              IdentifierAt(NumIdent).isInit := True;

              //   if IdentifierAt(NumIdent).NumAllocElements = 0 then
              //    Error(i + 1, 'Illegal expression');

              Inc(i);


              if TokenAt(i).Kind = TTokenKind.ADDRESSTOK then
              begin

                if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
                  Error(i + 1, TErrorCode.IdentifierExpected)
                else
                begin
                  IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

                  if IdentIndex > 0 then
                  begin

                    if (IdentifierAt(IdentIndex).Kind = CONSTANT) then
                    begin

                      if not ((IdentifierAt(IdentIndex).DataType in Pointers) and
                        (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
                        Error(i + 1, TErrorCode.CantAdrConstantExp)
                      else
                        SaveToDataSegment(idx, IdentifierAt(IdentIndex).Value - CODEORIGIN -
                          CODEORIGIN_BASE, TDataType.CODEORIGINOFFSET);

                    end
                    else
                      SaveToDataSegment(idx, IdentifierAt(IdentIndex).Value - DATAORIGIN, TDataType.DATAORIGINOFFSET);

                    VarType := TDataType.POINTERTOK;

                  end
                  else
                    Error(i + 1, TErrorCode.UnknownIdentifier);

                end;

                Inc(i);

              end
              else
                if TokenAt(i).Kind = TTokenKind.CHARLITERALTOK then
                begin

                  SaveToDataSegment(idx, 1, TTokenKind.BYTETOK);
                  SaveToDataSegment(idx + 1, TokenAt(i).Value, TTokenKind.BYTETOK);

                  VarType := TDataType.POINTERTOK;

                end
                else
                  if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) and (open_array = False) and
                    (VarType = TDataType.POINTERTOK) and (AllocElementType = TDataType.CHARTOK) then

                    SaveToDataSegment(idx, TokenAt(i).StrAddress - CODEORIGIN + 1, TTokenKind.CODEORIGINOFFSET)

                  else

{
    if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) and (open_array = false) then begin

     if (IdentifierAt(NumIdent).NumAllocElements > 0 ) and (TokenAt(i).StrLength > IdentifierAt(NumIdent).NumAllocElements) then begin
      Warning(i, StringTruncated, NumIdent);

      ParamIndex := IdentifierAt(NumIdent).NumAllocElements;
     end else
      ParamIndex := TokenAt(i).StrLength + 1;

     VarType := TDataType.STRINGPOINTERTOK;


     if (IdentifierAt(NumIdent).NumAllocElements = 0) then           // var label: pchar = ''
      SaveToDataSegment(idx, TokenAt(i).StrAddress - CODEORIGIN + 1, TDataType.CODEORIGINOFFSET)
     else begin

       if (IdType = TDataType.ARRAYTOK) and (AllocElementType = TDataType.CHARTOK) then begin      // var label: array of char = ''

        if TokenAt(i).StrLength > NumAllocElements then
               Error(i, 'string length is larger than array of char length');

         for j := 0 to IdentifierAt(NumIdent).NumAllocElements-1 do
         if j > TokenAt(i).StrLength-1 then
            SaveToDataSegment(idx + j, ord(' '), TTokenKind.CHARTOK)
         else
            SaveToDataSegment(idx + j, ord( StaticStringData[ TokenAt(i).StrAddress - CODEORIGIN + j + 1] ), TTokenKind.CHARTOK);

       end else
         for j := 0 to ParamIndex-1 do              // var label: string = ''
           SaveToDataSegment(idx + j, ord( StaticStringData[ TokenAt(i).StrAddress - CODEORIGIN + j ] ), TTokenKind.BYTETOK);

     end;

    end else
}

                    if (IdentifierAt(NumIdent).NumAllocElements in [0, 1]) and (open_array = False) then
                      Error(i, TErrorCode.IllegalExpression)
                    else
                      if open_array then
                      begin                   // array of type = [ ]

                        if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) and
                          (AllocElementType = TDataType.CHARTOK) then
                        begin    // = 'string'

                          IdentifierAt(NumIdent).Value := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
                          if VarType <> TTokenKind.STRINGPOINTERTOK then Inc(IdentifierAt(NumIdent).Value);

                          IdentifierAt(NumIdent).NumAllocElements := TokenAt(i).StrLength;

                          IdentifierAt(NumIdent).isAbsolute := True;

                          NumAllocElements := 0;

                        end
                        else
                        begin
                          i := ReadDataOpenArray(i, idx, IdentifierAt(NumIdent).AllocElementType,
                            NumAllocElements, False, TokenAt(i - 2).Kind = TTokenKind.PCHARTOK);

                          IdentifierAt(NumIdent).NumAllocElements := NumAllocElements;
                        end;

                        IncVarDataSize(i, NumAllocElements * GetDataSize(IdentifierAt(NumIdent).AllocElementType));

                      end
                      else
                      begin                    // array [] of type = ( )

                        if (TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK) and
                          (AllocElementType = TDataType.CHARTOK) then
                        begin    // = 'string'

                          if TokenAt(i).StrLength > NumAllocElements then
                            Error(i, 'string length is larger than array of char length');

                          IdentifierAt(NumIdent).Value := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
                          if VarType <> TTokenKind.STRINGPOINTERTOK then Inc(IdentifierAt(NumIdent).Value);

                          IdentifierAt(NumIdent).NumAllocElements := TokenAt(i).StrLength;

                          IdentifierAt(NumIdent).isAbsolute := True;

                          // NumAllocElements := 1;

                        end
                        else
                          i := ReadDataArray(i, idx, IdentifierAt(NumIdent).AllocElementType,
                            IdentifierAt(NumIdent).NumAllocElements or IdentifierAt(NumIdent).NumAllocElements_ shl
                            16, False, TokenAt(i - 2).Kind = TTokenKind.PCHARTOK);

                      end;

            end;

          end;

        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

        isVolatile := False;
        isStriped := False;

        if (TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK) and (TokenAt(i + 3).Kind in
          [TTokenKind.VOLATILETOK, TTokenKind.STRIPEDTOK]) then
        begin
          CheckTok(i + 4, TTokenKind.CBRACKETTOK);

          if TokenAt(i + 3).Kind = TTokenKind.VOLATILETOK then
            isVolatile := True
          else
            isStriped := True;

          Inc(i, 3);
        end;


        i := i + 1;
      until TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK;

      CheckForwardResolutions(False);                // issue #126 fixed

      i := i + 1;
    end;// if TTokenKind.VARTOK


    if TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK,
      TTokenKind.DESTRUCTORTOK] then
      if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
        Error(i + 1, 'Procedure name expected but ' + tokenList.GetTokenSpellingAtIndex(i + 1) + ' found')
      else
      begin

        IsNestedFunction := (TokenAt(i).Kind = TTokenKind.FUNCTIONTOK);


        if INTERFACETOK_USE then
          ForwardIdentIndex := 0
        else
          ForwardIdentIndex := GetIdentIndex(TokenAt(i + 1).Name);


        if (ForwardIdentIndex <> 0) and (IdentifierAt(ForwardIdentIndex).isOverload) then
        begin       // !!! dla forward; overload;

          j := i;
          FormalParameterList(j, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType,
            NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

          ForwardIdentIndex := GetIdentProc(IdentifierAt(ForwardIdentIndex).Name, ForwardIdentIndex,
            Param, ParamIndex);

        end;


        if ForwardIdentIndex <> 0 then
          if (IdentifierAt(ForwardIdentIndex).IsUnresolvedForward) and
            (IdentifierAt(ForwardIdentIndex).Block = BlockStack[BlockStackTop]) then
            if TokenAt(i).Kind <> IdentifierAt(ForwardIdentIndex).Kind then
              Error(i, 'Unresolved forward declaration of ' + IdentifierAt(ForwardIdentIndex).Name);


        if ForwardIdentIndex <> 0 then
          if not IdentifierAt(ForwardIdentIndex).IsUnresolvedForward or
            (IdentifierAt(ForwardIdentIndex).Block <> BlockStack[BlockStackTop]) or
            ((TokenAt(i).Kind = TTokenKind.PROCEDURETOK) and (IdentifierAt(ForwardIdentIndex).Kind <>
            TTokenKind.PROCEDURETOK)) or
            //   ((TokenAt(i).Kind = TTokenKind.CONSTRUCTORTOK) and (IdentifierAt(ForwardIdentIndex).Kind <> TTokenKind.CONSTRUCTORTOK)) or
            //   ((TokenAt(i).Kind = TTokenKind.DESTRUCTORTOK) and (IdentifierAt(ForwardIdentIndex).Kind <> TTokenKind.DESTRUCTORTOK)) or
            ((TokenAt(i).Kind = TTokenKind.FUNCTIONTOK) and (IdentifierAt(ForwardIdentIndex).Kind <>
            TTokenKind.FUNCTIONTOK)) then
            ForwardIdentIndex := 0;     // Found an identifier of another kind or scope, or it is already resolved


        if (TokenAt(i).Kind in [TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) and (ForwardIdentIndex = 0) then
          Error(i, 'constructors, destructors operators must be methods');


        //    writeln(ForwardIdentIndex,',',TokenAt(i).line,',',IdentifierAt(ForwardIdentIndex).isOverload,',',IdentifierAt(ForwardIdentIndex).IsUnresolvedForward,' / ',TokenAt(i).Kind = TTokenKind.PROCEDURETOK,',',  ((TokenAt(i).Kind = TTokenKind.PROCEDURETOK) and (IdentifierAt(ForwardIdentIndex).Kind <> PROC)));

        i := DefineFunction(i, ForwardIdentIndex, isForward, isInt, isInl, isOvr, IsNestedFunction,
          NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);


        // Check for a FORWARD directive (it is not a reserved word)
        if ((ForwardIdentIndex = 0) and isForward) or INTERFACETOK_USE then  // Forward declaration
        begin
          //      Inc(NumBlocks);
          //      IdentifierAt(NumIdent).ProcAsBlock := NumBlocks;
          IdentifierAt(NumIdent).IsUnresolvedForward := True;

        end
        else
        begin

          if ForwardIdentIndex = 0 then              // New declaration
          begin

            TestIdentProc(i, IdentifierAt(NumIdent).Name);

            if ((Pass = TPass.CODE_GENERATION) and (not IdentifierAt(NumIdent).IsNotDead)) then
              // Do not compile dead procedures and functions
            begin
              OutputDisabled := True;
            end;

            iocheck_old := IOCheck;
            isInterrupt_old := isInterrupt;

            j := CompileBlock(i + 1, NumIdent, IdentifierAt(NumIdent).NumParams, IsNestedFunction,
              NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

            IOCheck := iocheck_old;
            isInterrupt := isInterrupt_old;

            i := j + 1;

            GenerateReturn(IsNestedFunction, isInt, isInl, isOvr);

            if OutputDisabled then OutputDisabled := False;

          end
          else                      // Forward declaration resolution
          begin
            //  GenerateForwardResolution(ForwardIdentIndex);
            //  CompileBlock(ForwardIdentIndex);

            if ((Pass = TPass.CODE_GENERATION) and (not IdentifierAt(ForwardIdentIndex).IsNotDead)) then
              // Do not compile dead procedures and functions
            begin
              OutputDisabled := True;
            end;

            IdentifierAt(ForwardIdentIndex).Value := CodeSize;

            FormalParameterList(i, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType,
              NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

            Dec(i, 2);

            if ParamIndex > 0 then
            begin

              if IdentifierAt(ForwardIdentIndex).NumParams <> ParamIndex then
                Error(i, 'Wrong number of parameters specified for call to ' + '''' +
                  IdentifierAt(ForwardIdentIndex).Name + '''');

              //     function header "arg1" doesn't match forward : var name changes arg2 = arg3

              for ParamIndex := 1 to IdentifierAt(ForwardIdentIndex).NumParams do
                if ((IdentifierAt(ForwardIdentIndex).Param[ParamIndex].Name <> Param[ParamIndex].Name) or
                  (IdentifierAt(ForwardIdentIndex).Param[ParamIndex].DataType <> Param[ParamIndex].DataType)) then
                  Error(i, 'Function header ''' + IdentifierAt(ForwardIdentIndex).Name +
                    ''' doesn''t match forward : ' + IdentifierAt(ForwardIdentIndex).Param[ParamIndex].Name +
                    ' <> ' + Param[ParamIndex].Name);

              for ParamIndex := 1 to IdentifierAt(ForwardIdentIndex).NumParams do
                if (IdentifierAt(ForwardIdentIndex).Param[ParamIndex].PassMethod <> Param[ParamIndex].PassMethod) then
                  Error(i, 'Function header doesn''t match the previous declaration ''' +
                    IdentifierAt(ForwardIdentIndex).Name + '''');

            end;

            Tmp := 0;

            if IdentifierAt(ForwardIdentIndex).isKeep then SetModifierBit(TModifierCode.mKeep, tmp);
            if IdentifierAt(ForwardIdentIndex).isOverload then SetModifierBit(TModifierCode.mOverload, tmp);
            if IdentifierAt(ForwardIdentIndex).isAsm then SetModifierBit(TModifierCode.mAssembler, tmp);
            if IdentifierAt(ForwardIdentIndex).isRegister then SetModifierBit(TModifierCode.mRegister, tmp);
            if IdentifierAt(ForwardIdentIndex).isInterrupt then SetModifierBit(TModifierCode.mInterrupt, tmp);
            if IdentifierAt(ForwardIdentIndex).isPascal then SetModifierBit(TModifierCode.mPascal, tmp);
            if IdentifierAt(ForwardIdentIndex).isStdCall then SetModifierBit(TModifierCode.mStdCall, tmp);
            if IdentifierAt(ForwardIdentIndex).isInline then SetModifierBit(TModifierCode.mInline, tmp);

            if Tmp <> TmpResult then
              // TODO: List the difference in the modifiers
              Error(i, 'Function header doesn''t match the previous declaration ''' +
                IdentifierAt(ForwardIdentIndex).Name + '''. Different modifiers.');


            if IsNestedFunction then
              if (IdentifierAt(ForwardIdentIndex).DataType <> NestedFunctionResultType) or
                (IdentifierAt(ForwardIdentIndex).NestedFunctionNumAllocElements <> NestedFunctionNumAllocElements) or
                (IdentifierAt(ForwardIdentIndex).NestedFunctionAllocElementType <> NestedFunctionAllocElementType) then
                Error(i, 'Function header doesn''t match the previous declaration ''' +
                  IdentifierAt(ForwardIdentIndex).Name + '''');


            CheckTok(i + 2, TTokenKind.SEMICOLONTOK);

            iocheck_old := IOCheck;
            isInterrupt_old := isInterrupt;

            j := CompileBlock(i + 3, ForwardIdentIndex, IdentifierAt(ForwardIdentIndex).NumParams,
              IsNestedFunction, IdentifierAt(ForwardIdentIndex).DataType,
              IdentifierAt(ForwardIdentIndex).NestedFunctionNumAllocElements,
              IdentifierAt(ForwardIdentIndex).NestedFunctionAllocElementType);

            IOCheck := iocheck_old;
            isInterrupt := isInterrupt_old;

            i := j + 1;

            GenerateReturn(IsNestedFunction,
              IdentifierAt(ForwardIdentIndex).isInterrupt,
              IdentifierAt(ForwardIdentIndex).isInline,
              IdentifierAt(ForwardIdentIndex).isOverload
              );

            if OutputDisabled then OutputDisabled := False;

            IdentifierAt(ForwardIdentIndex).IsUnresolvedForward := False;

          end;

        end;


        CheckTok(i, TTokenKind.SEMICOLONTOK);

        Inc(i);

      end;// else
  end;// while


  OutputDisabled := (Pass = TPass.CODE_GENERATION) and (BlockStack[BlockStackTop] <> 1) and
    (not IdentifierAt(BlockIdentIndex).IsNotDead);


  // asm65('@main');

  if not isAsm then
  begin
    GenerateDeclarationEpilog;  // Make jump to block entry point

    if not (TokenAt(i - 1).Kind in [TTokenKind.PROCALIGNTOK, TTokenKind.LOOPALIGNTOK, TTokenKind.LINKALIGNTOK]) then
      if LIBRARYTOK_USE and (TokenAt(i).Kind <> TTokenKind.BEGINTOK) then

        Inc(i)

      else
        CheckTok(i, TTokenKind.BEGINTOK);

  end;


  // Initialize array origin pointers if the current block is the main program body
{
if BlockStack[BlockStackTop] = 1 then begin

  for IdentIndex := 1 to NumIdent do
    if (IdentifierAt(IdentIndex).Kind = VARIABLE) and (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) then
      begin
//      Push(IdentifierAt(IdentIndex).Value + SizeOf(Int64), ASVALUE, GetDataSize(TDataType.POINTERTOK), IdentifierAt(IdentIndex).Kind);     // Array starts immediately after the pointer to its origin
//      GenerateAssignment(IdentifierAt(IdentIndex).Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);
      asm65(#9'mwa #DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN + GetDataSize(TDataType.POINTERTOK), 4) + ' DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN , 4), '; ' + IdentifierAt(IdentIndex).Name );

      end;

end;
}


  Result := CompileStatement(i, isAsm);

  j := NumIdent;

  // Delete local identifiers and types from the tables to save space
  while (j > 0) and (IdentifierAt(j).Block = BlockStack[BlockStackTop]) do
  begin
    // If procedure or function, delete parameters first
    if IdentifierAt(j).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
      TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
      if IdentifierAt(j).IsUnresolvedForward and (IdentifierAt(j).isExternal = False) then
        Error(i, 'Unresolved forward declaration of ' + IdentifierAt(j).Name);

    Dec(j);
  end;


  // Return Result value

  if IsFunction then
  begin
    // if FunctionNumAllocElements > 0 then
    //  Push(IdentifierAt(GetIdentIndex('RESULT')).Value, ASVALUE, GetDataSize( TDataType.FunctionResultType), GetIdentIndex('RESULT'))
    // else
    //  asm65;
    asm65('@exit');

    if IdentifierAt(BlockIdentIndex).isStdCall or IdentifierAt(BlockIdentIndex).isRecursion then
    begin

      Push(IdentifierAt(GetIdentIndex('RESULT')).Value, ASPOINTER, GetDataSize(FunctionResultType),
        GetIdentIndex('RESULT'));

      asm65;

      if not isInl then
      begin
        asm65(#9'.ifdef @new');      // @FreeMem
        asm65(#9'lda <@VarData');
        asm65(#9'sta :ztmp');
        asm65(#9'lda >@VarData');
        asm65(#9'ldy #@VarDataSize-1');
        asm65(#9'jmp @FreeMem');
        asm65(#9'eif');
      end;

    end;

  end;

  if IdentifierAt(BlockIdentIndex).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
    TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
  begin

    if IdentifierAt(BlockIdentIndex).isInline then asm65(#9'.ENDM');

    GenerateProcFuncAsmLabels(BlockIdentIndex, True);

  end;

  Dec(BlockStackTop);


  if pass = TPass.CALL_DETERMINATION then
    if IdentifierAt(BlockIdentIndex).isKeep or IdentifierAt(BlockIdentIndex).isInterrupt or
      IdentifierAt(BlockIdentIndex).updateResolvedForward then
      AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(BlockIdentIndex).ProcAsBlock);


  //Result := j;

end;  //CompileBlock

// ----------------------------------------------------------------------------
// Subroutines of CompileProgram
// ----------------------------------------------------------------------------

procedure CompileResources;
var
  i, j: Integer;
  a: String;
  res: TResource;
begin

  if (High(resArray) > 0) and (target.id <> TTargetID.A8) then
  begin

    asm65;
    asm65('.local'#9'RESOURCE');

    asm65(#9'icl ''' + AnsiLowerCase(target.Name) + '\resource.asm''');

    asm65;


    for i := 0 to High(resArray) - 1 do
      if resArray[i].resStream = False then
      begin

        j := NumIdent;

        while (j > 0) and (IdentifierAt(j).SourceFile.UnitIndex = 1) do
        begin
          if IdentifierAt(j).Name = resArray[i].resName then
          begin
            resArray[i].resValue := IdentifierAt(j).Value;
            Break;
          end;
          Dec(j);
        end;

      end;


    for i := 0 to High(resArray) - 1 do
      for j := 0 to High(resArray) - 1 do
        if resArray[i].resValue < resArray[j].resValue then
        begin
          res := resArray[j];
          resArray[j] := resArray[i];
          resArray[i] := res;
        end;


    for i := 0 to High(resArray) - 1 do
      if resArray[i].resStream = False then
      begin

        a := #9 + resArray[i].resType + ' ''' + resArray[i].resFile + '''' + ' ';

        a := a + resArray[i].resFullName;

        for j := 1 to MAXPARAMS do a := a + ' ' + resArray[i].resPar[j];

        asm65(a);
      end;

    asm65('.endl');
  end;
end;

// ----------------------------------------------------------------------------


procedure CompileMemoryWord(const memory: TWordMemory; const index: Integer; var tmp: String);
var
  Value: Word;
begin
  Value := Memory[index];
  if (Value and $c000) = $8000 then
    tmp := tmp + ' <[DATAORIGIN+$' + IntToHex(Byte(Value) or Byte(memory[index + 1]) shl 8, 4) + ']'
  else
    if Value and $c000 = $4000 then
      tmp := tmp + ' >[DATAORIGIN+$' + IntToHex(Byte(memory[index - 1]) or Byte(Value) shl 8, 4) + ']'
    else
      if Value and $3000 = $2000 then
        tmp := tmp + ' <[CODEORIGIN+$' + IntToHex(Byte(Value) or Byte(memory[index + 1]) shl 8, 4) + ']'
      else
        if Value and $3000 = $1000 then
          tmp := tmp + ' >[CODEORIGIN+$' + IntToHex(Byte(memory[index - 1]) or Byte(Value) shl 8, 4) + ']'
        else
          tmp := tmp + ' $' + IntToHex(Byte(Value), 2);
end;

// ----------------------------------------------------------------------------

procedure CompileStaticData;
var
  i: Integer;
  tmp: String;
begin
  asm65;
  asm65('.macro'#9'STATICDATA');

  tmp := '';
  for i := 0 to NumStaticStrChars - 1 do
  begin

    if (i mod 24 = 0) then
    begin

      if i > 0 then asm65(tmp);

      tmp := '.by ';

    end
    else
      if (i > 0) and (i mod 8 = 0) then tmp := tmp + ' ';

    CompileMemoryWord(StaticStringData, i, tmp);
  (*
    if StaticStringData[i] and $c000 = $8000 then
      tmp := tmp + ' <[DATAORIGIN+$' + IntToHex(Byte(StaticStringData[i]) or
        Byte(StaticStringData[i + 1]) shl 8, 4) + ']'
    else
      if StaticStringData[i] and $c000 = $4000 then
        tmp := tmp + ' >[DATAORIGIN+$' + IntToHex(Byte(StaticStringData[i - 1]) or
          Byte(StaticStringData[i]) shl 8, 4) + ']'
      else
        if StaticStringData[i] and $3000 = $2000 then
          tmp := tmp + ' <[CODEORIGIN+$' + IntToHex(Byte(StaticStringData[i]) or
            Byte(StaticStringData[i + 1]) shl 8, 4) + ']'
        else
          if StaticStringData[i] and $3000 = $1000 then
            tmp := tmp + ' >[CODEORIGIN+$' + IntToHex(Byte(StaticStringData[i - 1]) or
              Byte(StaticStringData[i]) shl 8, 4) + ']'
          else
            tmp := tmp + ' $' + IntToHex(StaticStringData[i], 2);
     *)
  end;

  if tmp <> '' then asm65(tmp);

  asm65('.endm');
end;

// ----------------------------------------------------------------------------

procedure CompileDataOrigin;
var
  DataSegmentSize: Integer;
  j: Integer;
  tmp: String;
begin
  asm65;
  asm65('DATAORIGIN');

  // TODO: Issues with bobs.pas, too many bytes exported
  if DataSegmentUse then
  begin
    if Pass = TPass.CODE_GENERATION then
    begin

      // !!! I have to save everything, including 'zeros' !!! For example, for TextAtr to wor

      if LIBRARYTOK_USE then
      begin
        DataSegmentSize := GetVarDataSize;
      end
      else
      begin
        DataSegmentSize := 0;
        for j := GetVarDataSize - 1 downto 0 do
          if _DataSegment[j] <> 0 then
          begin
            DataSegmentSize := j + 1;
            Break;
          end;
      end;

      tmp := '';

      for j := 0 to DataSegmentSize - 1 do
      begin

        if (j mod 24 = 0) then
        begin
          if tmp <> '' then asm65(tmp);
          tmp := '.by';
        end;

        if (j mod 8 = 0) then tmp := tmp + ' ';

        CompileMemoryWord(_DataSegment, j, tmp);

      end;

      if tmp <> '' then asm65(tmp);

    end;

  end;


  if LIBRARYTOK_USE then
  begin

    asm65;
    asm65('PROGRAMSTACK');

  end
  else
  begin

    asm65;
    asm65('VARINITSIZE'#9'= *-DATAORIGIN');
    asm65('VARDATASIZE'#9'= ' + IntToStr(GetVarDataSize));

    asm65;
    asm65('PROGRAMSTACK'#9'= DATAORIGIN+VARDATASIZE');

  end;

  asm65;
  asm65(#9'.print ''DATA: '',DATAORIGIN,''..'',PROGRAMSTACK');

  asm65;
  asm65(#9'ert DATAORIGIN<@end,''DATA memory overlap''');
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileProgram(const pass: TPass);
var
  i, j, IdentIndex: Integer;
  tmp: String;
  yes: Boolean;
  SourceFile: TSourceFile;
begin

  WriteLn('Pass ' + IntToStr(Ord(pass)) + '.');
  Common.pass := pass;
  ResetOpty;

  common.optimize.use := False;

  SetVarDataSize(0, 0);


  tmp := '';

  IOCheck := True;


  AsmBlockIndex := 0;

  //SetLength(AsmLabels, 1);

  DefineIdent(1, 'MAIN', TTokenKind.PROCEDURETOK, TDataType.UNTYPETOK, 0, TDataType.UNTYPETOK, 0);

  GenerateProgramProlog;

  j := CompileBlock(1, NumIdent, 0, False, TDataType.UNTYPETOK);


  if TokenAt(j).Kind = TTokenKind.ENDTOK then CheckTok(j + 1, TTokenKind.DOTTOK)
  else
    if TokenAt(NumTok).Kind = TTokenKind.EOFTOK then
      Error(NumTok, 'Unexpected end of file');

  j := NumIdent;

  while (j > 0) and (IdentifierAt(j).SourceFile.UnitIndex = 1) do
  begin
    // If procedure or function, delete parameters first
    if IdentifierAt(j).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
      TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
      if (IdentifierAt(j).IsUnresolvedForward) and (IdentifierAt(j).isExternal = False) then
        Error(j, 'Unresolved forward declaration of ' + IdentifierAt(j).Name);

    Dec(j);
  end;

  StopOptimization;

  //asm65;
  asm65('@exit');
  asm65;
  asm65('@halt'#9'ldx #$00');
  asm65(#9'txs');

  if LIBRARY_USE then asm65('@regX'#9'ldx #$00');

  if target.id = TTargetID.A8 then
  begin

    if LIBRARY_USE = False then
    begin
      asm65;
      asm65(#9'.ifdef MAIN.@DEFINES.ROMOFF');
      asm65(#9'inc portb');
      asm65(#9'.fi');
    end;

    asm65;
    asm65(#9'ldy #$01');
  end;

  asm65;
  asm65(#9'rts');


{
if LIBRARY_USE = FALSE then begin

  asm65separator;

  if target.id = TTargetID.A8 then begin
    asm65;
    asm65('IOCB@COPY'#9':16 brk');
  end;

end;
}


  asm65separator;

  asm65;
  asm65('.local'#9'@DEFINES');

  for j := 1 to MAXDEFINES do
    if (Defines[j].Name <> '') and (Defines[j].Macro = '') then asm65(Defines[j].Name);

  asm65('.endl');


  asm65(#13#10'.local'#9'@RESOURCE');

  for i := 0 to High(resArray) - 1 do
  begin

    resArray[i].resStream := False;

    yes := False;
    for IdentIndex := 1 to NumIdent do
      if (resArray[i].resName = IdentifierAt(IdentIndex).Name) and (IdentifierAt(IdentIndex).Block = 1) then
      begin

        if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) then
          tmp := GetLocalName(IdentIndex, 'adr.')
        else
          tmp := GetLocalName(IdentIndex);

        //     asm65(resArray[i].resName+' = ' + tmp);
        //     asm65(resArray[i].resName+'.end');

        if resArray[i].resType = 'LIBRARY' then RCLIBRARY := True;

        resArray[i].resFullName := tmp;

        IdentifierAt(IdentIndex).Pass := Pass;

        yes := True;
        Break;
      end;


    if not yes then
      if AnsiUpperCase(resArray[i].resType) = 'SAPR' then
      begin
        asm65(resArray[i].resName);
        asm65(#9'dta a(' + resArray[i].resName + '.end-' + resArray[i].resName + '-2)');
        asm65(#9'ins ''' + resArray[i].resFile + '''');
        asm65(resArray[i].resName + '.end');
        resArray[i].resStream := True;
      end
      else

        if AnsiUpperCase(resArray[i].resType) = 'PP' then
        begin
          asm65(resArray[i].resName + #9'm@pp "''' + resArray[i].resFile + '''"');
          asm65(resArray[i].resName + '.end');
          resArray[i].resStream := True;
        end
        else

          if AnsiUpperCase(resArray[i].resType) = 'DOSFILE' then
          begin

          end
          else

            if AnsiUpperCase(resArray[i].resType) = 'RCDATA' then
            begin
              asm65(resArray[i].resName + #9'ins ''' + resArray[i].resFile + '''');
              asm65(resArray[i].resName + '.end');
              resArray[i].resStream := True;
            end
            else

              Error(NumTok, 'Resource identifier not found: Type = ' + resArray[i].resType +
                ', Name = ' + resArray[i].resName);

    //  asm65(#9+resArray[i].resType+' '''+resArray[i].resFile+''''+','+resArray[i].resName);

    //  resArray[i].resFullName := tmp;

    //  IdentifierAt(IdentIndex).Pass := Pass;
  end;

  asm65('.endl');


  asm65;
  asm65('.endl', '; MAIN');

  asm65separator;
  asm65separator(False);

  asm65;
  asm65('.macro'#9'UNITINITIALIZATION');

  for j := SourceFileList.Size downto 2 do
  begin
    SourceFile := SourceFileList.GetSourceFile(j);
    if SourceFile.IsRelevant then
    begin

      asm65;
      asm65(#9'.ifdef MAIN.' + SourceFile.Name + '.@UnitInit');
      asm65(#9'jsr MAIN.' + SourceFile.Name + '.@UnitInit');
      asm65(#9'.fi');

    end;
  end;

  asm65('.endm');

  asm65separator;

  for j := SourceFileList.Size downto 2 do
  begin
    SourceFile := SourceFileList.GetSourceFile(j);
    if SourceFile.IsRelevant then
    begin
      asm65;
      asm65(#9'ift .SIZEOF(MAIN.' + SourceFile.Name + ') > 0');
      asm65(#9'.print ''' + SourceFile.Name + ': ' + ''',MAIN.' + SourceFile.Name + ',' +
        '''..''' + ',' + 'MAIN.' + SourceFile.Name + '+.SIZEOF(MAIN.' + SourceFile.Name + ')-1');
      asm65(#9'eif');
    end;
  end;


  asm65;
  asm65('.nowarn'#9'.print ''CODE: '',CODEORIGIN,''..'',MAIN.@RESOURCE-1');

  asm65;
  asm65(#9'ift .SIZEOF(MAIN.@RESOURCE)>0');
  asm65('.nowarn'#9'.print ''RESOURCE: '',MAIN.@RESOURCE,''..'',MAIN.@RESOURCE+.SIZEOF(MAIN.@RESOURCE)-1');
  asm65(#9'eif');
  asm65;


  for i := 0 to High(resArray) - 1 do
    if resArray[i].resStream then
      asm65(#9'.print ''$R ' + resArray[i].resName + ''',' + ''' ''' + ',' + '"''' +
        resArray[i].resFile + '''"' + ',' + ''' ''' + ',MAIN.@RESOURCE.' + resArray[i].resName +
        ',' + '''..''' + ',MAIN.@RESOURCE.' + resArray[i].resName + '.end-1');

  asm65;
  asm65('@end');
  asm65;
  asm65('.nowarn'#9'.print ''VARS: '',MAIN.@RESOURCE+.SIZEOF(MAIN.@RESOURCE),''..'',@end-1');

  asm65separator;
  asm65;


  if DATA_BASE > 0 then
    asm65(#9'org $' + IntToHex(DATA_BASE, 4))
  else
  begin

    asm65(#9'?adr = *');
    asm65(#9'ift (?adr < ?old_adr) && (?old_adr - ?adr < $120)');
    asm65(#9'?adr = ?old_adr');
    asm65(#9'eif');
    asm65;
    asm65(#9'org ?adr');
    asm65(#9'?old_adr = *');

  end;

  CompileDataOrigin;

  if FastMul > 0 then
  begin

    asm65separator;

    asm65;
    asm65(#9'icl ''common\fmul.asm''', '; fast multiplication');

    asm65;
    asm65(#9'.print ''FMUL_INIT: '',fmulinit,''..'',*-1');

    asm65;
    asm65(#9'org $' + IntToHex(FastMul, 2) + '00');

    asm65;
    asm65(#9'.print ''FMUL_DATA: '',*,''..'',*+$07FF');

    asm65;
    asm65('square1_lo'#9'.ds $200');
    asm65('square1_hi'#9'.ds $200');
    asm65('square2_lo'#9'.ds $200');
    asm65('square2_hi'#9'.ds $200');

  end;

  if target.id = TTargetID.A8 then
  begin
    asm65;
    asm65(#9'run START');
  end;

  asm65separator;

  CompileStaticData;

  CompileResources;

  asm65;
  asm65(#9'end');

  flushTempBuf;      // flush TemporaryBuf

end;

procedure InitializeIdentifiers;
{$IFNDEF PAS2JS}
const
  PI_VALUE: TNumber = $40490FDB00000324; // does not fit into 53 bits Javascript double  mantissa
const
  NAN_VALUE: TNumber = $FFC00000FFC00000;
const
  INFINITY_VALUE: TNumber = $7F8000007F800000;
const
  NEGINFINITY_VALUE: TNumber = $FF800000FF800000;
{$ELSE}
  const PI_VALUE: Int64 = 3; // does not fit into 53 bits Javascript double  mantissa
  const NAN_VALUE: Int64 = $11111111;
  const INFINITY_VALUE: Int64 = $22222222;
  const NEGINFINITY_VALUE: Int64 = $33333333;
{$ENDIF}
begin

  // Initilize identifiers for predefined constants
  DefineIdent(1, 'BLOCKREAD', TDataType.FUNCTIONTOK, TDataType.INTEGERTOK, 0, TDataType.UNTYPETOK, $00000000);
  DefineIdent(1, 'BLOCKWRITE', TDataType.FUNCTIONTOK, TDataType.INTEGERTOK, 0, TDataType.UNTYPETOK, $00000000);

  DefineIdent(1, 'GETRESOURCEHANDLE', TDataType.FUNCTIONTOK, TDataType.INTEGERTOK, 0,
    TDataType.UNTYPETOK, $00000000);

  DefineIdent(1, 'NIL', CONSTANT, TDataType.POINTERTOK, 0, TDataType.UNTYPETOK, CODEORIGIN);

  DefineIdent(1, 'EOL', CONSTANT, TDataType.CHARTOK, 0, TDataType.UNTYPETOK, target.eol);

  DefineIdent(1, '__BUFFER', CONSTANT, TDataType.WORDTOK, 0, TDataType.UNTYPETOK, target.buf);

  DefineIdent(1, 'TRUE', CONSTANT, TDataType.BOOLEANTOK, 0, TDataType.UNTYPETOK, $00000001);
  DefineIdent(1, 'FALSE', CONSTANT, TDataType.BOOLEANTOK, 0, TDataType.UNTYPETOK, $00000000);

  DefineIdent(1, 'MAXINT', CONSTANT, TDataType.INTEGERTOK, 0, TDataType.UNTYPETOK, MAXINT);
  DefineIdent(1, 'MAXSMALLINT', CONSTANT, TDataType.INTEGERTOK, 0, TDataType.UNTYPETOK, MAXSMALLINT);

  DefineIdent(1, 'PI', CONSTANT, TDataType.REALTOK, 0, TDataType.UNTYPETOK, PI_VALUE);
  DefineIdent(1, 'NAN', CONSTANT, TDataType.SINGLETOK, 0, TDataType.UNTYPETOK, NAN_VALUE);
  DefineIdent(1, 'INFINITY', CONSTANT, TDataType.SINGLETOK, 0, TDataType.UNTYPETOK, INFINITY_VALUE);
  DefineIdent(1, 'NEGINFINITY', CONSTANT, TDataType.SINGLETOK, 0, TDataType.UNTYPETOK, NEGINFINITY_VALUE);
end;

// ----------------------------------------------------------------------------
//                                 Compiler Main
// ----------------------------------------------------------------------------

procedure Main(const programUnit: TSourceFile; const unitPathList: TPathList);
var
  scanner: IScanner;
  i: Integer;
begin

  Common.unitPathList := unitPathList;
  evaluationContext := TEvaluationContext.Create;
  debugger.debugger := TDebugger.Create;

  TokenList := TTokenList.Create;
  IdentifierList := TIdentifierList.Create;
  for i := 1 to MAXIDENTS do IdentifierList.AddIdentifier;

  SetLength(IFTmpPosStack, 1);

  Defines[1].Name := AnsiUpperCase(target.Name);

  {$IFNDEF PAS2JS}
  DefaultFormatSettings.DecimalSeparator := '.';
  {$ENDIF}

  TextColor(WHITE);

  Writeln('Compiling ' + programUnit.Name);

  // ----------------------------------------------------------------------------
  // Set defines for first pass;
  scanner := TScanner.Create;

  scanner.TokenizeProgram(programUnit, True);

  if NumTok = 0 then Error(1, '');

  // Add default unit 'system.pas'
  SourceFileList.AddUnit(TSourceFileType.UNIT_FILE, 'SYSTEM', FindFile('system.pas', 'unit'));

  scanner.TokenizeProgram(programUnit, False);

  // ----------------------------------------------------------------------------

  NumStaticStrCharsTmp := NumStaticStrChars;

  InitializeIdentifiers;

  // First pass: compile the program and build call graph
  NumPredefIdent := NumIdent;


  CompileProgram(TPass.CALL_DETERMINATION);


  // Visit call graph nodes and mark all procedures that are called as not dead
  OptimizeProgram(GetIdentIndex('MAIN'));


  // Second pass: compile the program and generate output (IsNotDead fields are preserved since the first pass)
  NumIdent_ := NumPredefIdent;
  ClearWordMemory(_DataSegment);

  SourceFileList.ClearAllowedUnitNames;

  NumBlocks := 0;
  BlockStackTop := 0;
  CodeSize := 0;
  CodePosStackTop := 0;
  CaseCnt := 0;
  IfCnt := 0;
  ShrShlCnt := 0;
  NumTypes := 0;
  run_func := 0;
  NumProc := 0;

  NumStaticStrChars := NumStaticStrCharsTmp;

  ResetOpty;
  optyFOR0 := '';
  optyFOR1 := '';
  optyFOR2 := '';
  optyFOR3 := '';

  LIBRARY_USE := LIBRARYTOK_USE;

  LIBRARYTOK_USE := False;
  PROGRAMTOK_USE := False;
  INTERFACETOK_USE := False;
  PublicSection := True;

  iOut := -1;
  outTmp := '';

  SetLength(OptimizeBuf, 1);

  CompileProgram(TPass.CODE_GENERATION);

end;

procedure Free;
begin

  TokenList.Free;
  TokenList := nil;

  IdentifierList.Free;
  IdentifierList := nil;

  SetLength(IFTmpPosStack, 0);
  Debugger.debugger := nil;
  evaluationContext := nil;
  unitPathList.Free;
  unitPathList := nil;
end;

end.
