unit MathEvaluate;

(* Source: CLSN PASCAL                                              *)
(* This program will evaluate numeric expressions like:             *)
(* 5+6/7    sin(cos(pi))  sqrt(4*4)                                 *)
(* Mutual recursion is necessary, hence the FORWARD clause is used. *)

interface

uses SysUtils;

{$i define.inc}
{$i Types.inc}

type
  TEvaluationResult = Single;

type
  EEValuationException = class(Exception)
  private
    _expression: String;
    _index: Integer;
  public
    constructor Create(const msg: String);
    property Expression: String read _expression;
    property Index: Integer read _index;
  end;

type
  IEvaluationContext = interface
    function GetConstantName(const expression: String; var index: Integer): String;
    function GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  end;


function Evaluate(const expression: String; const evaluationContext: IEvaluationContext): TEvaluationResult;


implementation

uses Math;

type
  TOperator = String;

var
  evaluationContext: IEvaluationContext;
  s: String;
  cix: Integer;

  // If the names of the functions are similar then their longer versions should be placed earlier.
  // Example:_ arctan2 .. arctan
  fop: array[0..14] of TOperator = (' ', 'PI', 'RND', 'SQRT', 'SQR', 'ARCTAN2', 'COS', 'SIN',
    'TAN', 'EXP', 'LN', 'ABS', 'INT', 'POWER', 'ARCTAN');

  top: array[0..7] of TOperator = (' ', '*', '/', 'DIV', 'MOD', 'AND', 'SHL', 'SHR');
  seop: array[0..4] of TOperator = (' ', '+', '-', 'OR', 'XOR');



constructor EEValuationException.Create(const msg: String);
begin
  inherited Create(msg);
  _expression := MathEvaluate.s;
  _index := MathEvaluate.cix;
end;

procedure RaiseError(const msg: String);
begin
  raise  EEValuationException.Create(msg);
end;

function SimpleExpression: TEvaluationResult; forward;

procedure SkipBlanks;
begin
  while (s[cix] = ' ') do
    Inc(cix);
end;

function Constant: TEvaluationResult;
var
  n: String;
  i, v, k, ln: Integer;
{$IFNDEF PAS2JS}
  v1: TEvaluationResult;
{$ELSE}
    v1: ValReal; // For PAS2JS, should also work for FPC and be used a return value there,  see Test-70287.pas
{$ENDIF}
  p: Integer;
  pflg: Boolean;
  constantValue: Int64;
begin
  n := '';
  pflg := False;

  SkipBlanks;

  p := 0;


  if s[cix] = '%' then // binary
  begin

    Inc(cix);

    while (s[cix] in ['0', '1']) do
    begin
      n := n + s[cix];

      Inc(cix);
    end;

    if Length(n) = 0 then
      RaiseError('Invalid constant %');

    // Remove leading zeros
    i := 1;
    while n[i] = '0' do Inc(i);

    ln := Length(n);
    v := 0;

    // Do the conversion
    for k := ln downto i do
      if n[k] = '1' then
        v := v + (1 shl (ln - k));

    v1 := v;

  end
  else


  if s[cix] = '$' then // hexadecimal
  begin

    n := '$';
    Inc(cix);

    while (UpCase(s[cix]) in ['0'..'9', 'A'..'F']) do
    begin
      n := n + s[cix];

      Inc(cix);
    end;

    //  If the conversion isn't successful, then the parameter p (Code) contains
    //  the index of the character in S which prevented the conversion
    Val(n, v, p);

    v1 := v;

  end
  else
  begin              // decimal

    while (s[cix] in ['0'..'9']) or ((s[cix] = '.') and (not pflg)) do
    begin
      if (s[cix] = '.') then pflg := True;

      n := n + s[cix];

      Inc(cix);
    end;

    Val(n, v1, p);

  end;


  if (p <> 0) then
  begin

    n := evaluationContext.GetConstantName(s, cix);
    if n <> '' then
    begin
      constantValue := 0;
      if evaluationContext.GetConstantValue(n, constantValue) then
        v1 := constantValue
      else
        RaiseError('Invalid constant "' + n + '"');

    end;
  end;


  constant := v1;
end;


function XNot(v: TEvaluationResult): TEvaluationResult;
begin
  if (v = 0) then
    Result := 1
  else
    Result := 0;
end;


function Factor: TEvaluationResult;
var
  v1, v2: TEvaluationResult;
  ch: Char;
  op, i: Byte;


  procedure RaiseWrongNumberOfParametersError;
  begin

    RaiseError('Wrong number of parameters specified for call to "' + fop[op] + '"');

  end;

begin
  SkipBlanks;

  op := 0;
  v1 := 0;
  v2 := 0;

  for i := 1 to High(fop) do
    if (op = 0) then
      if (Copy(s, cix, Length(fop[i])) = fop[i]) then
        op := i;

  if (op > 0) then
  begin
    cix := cix + Length(fop[op]);

    SkipBlanks;

    if (op in [1, 2]) and (s[cix] = '(') then
      RaiseWrongNumberOfParametersError;


    if (op > 2) then            // 0:' ', 1:'PI', 2:'RND'
    begin
      if (s[cix] <> '(') then
        RaiseWrongNumberOfParametersError;

      v1 := factor;

      if (op in [5, 13]) and (s[cix] <> ',') then    // 5:'ARCTAN2', 13:'POWER'
        RaiseWrongNumberOfParametersError;

      if s[cix] = ',' then
      begin

        if not (op in [5, 13]) then        // 5:'ARCTAN2', 13:'POWER'
          RaiseWrongNumberOfParametersError;

        Inc(cix);

        SkipBlanks;

        v2 := factor;

        if s[cix] <> ')' then
          RaiseWrongNumberOfParametersError;

        Inc(cix);

      end;

    end;


    case op of
      1: v1 := pi;
      2: v1 := Random;
      3: v1 := sqrt(v1);
      4: v1 := sqr(v1);
      5: v1 := arctan2(v1, v2);
      6: v1 := cos(v1);
      7: v1 := sin(v1);
      8: v1 := sin(v1) / cos(v1);
      9: v1 := exp(v1);
      10: v1 := ln(v1);
      11: v1 := abs(v1);
      12: v1 := int(v1);
      13: v1 := power(v1, v2);
      14: v1 := arctan(v1);
      else
        Assert(False, 'Invalid operator code ' + IntToStr(op) + '.');
    end;

  end
  else
  if (s[cix] = '(') then
  begin
    Inc(cix);

    v1 := SimpleExpression;

    SkipBlanks;

    if (s[cix] <> ',') then

      if (s[cix] = ')') then
        Inc(cix)
      else
        RaiseError('Parenthesis Mismatch');
  end
  else
  if (s[cix] = '-') or (s[cix] = '+') or (Copy(s, cix, 3) = 'NOT') then
  begin
    ch := s[cix];

    if (ch = 'N') then
      cix := cix + 3
    else
      Inc(cix);

    case ch of
      '+': v1 := factor;
      '-': v1 := -factor;
      'N': v1 := xnot(factor);
       else
        Assert(False, 'Invalid case');
    end;
  end
  else
    v1 := constant;

  Result := v1;
end;


function Term: TEvaluationResult;
var
  op, i: Byte;
  v1, v2: TEvaluationResult;

begin
  v1 := factor;

  repeat
    SkipBlanks;

    op := 0;

    for i := 1 to High(top) do
      if (op = 0) then
        if (Copy(s, cix, Length(top[i])) = top[i]) then
          op := i;

    if (op > 0) then
    begin
      cix := cix + Length(top[op]);

      v2 := factor;

      case op of
        1: v1 := v1 * v2;
        2: v1 := v1 / v2;
        3: v1 := round(v1) div round(v2);
        4: v1 := round(v1) mod round(v2);
        5: v1 := round(v1) and round(v2);
        6: v1 := round(v1) shl round(v2);
        7: v1 := round(v1) shr round(v2);
      end;
    end;

  until (op = 0);

  Result := v1;

end;


function SimpleExpression: TEvaluationResult;
var
  op, i: Byte;
  v1, v2: TEvaluationResult;

begin
  SkipBlanks;

  v1 := term;

  repeat
    SkipBlanks;

    op := 0;

    for i := 1 to High(seop) do
      if (op = 0) then
        if (Copy(s, cix, Length(seop[i])) = seop[i]) then
          op := i;

    if (op > 0) then
    begin
      cix := cix + Length(seop[op]);

      v2 := term;

      case op of
        1: v1 := v1 + v2;
        2: v1 := v1 - v2;
        3: v1 := round(v1) or round(v2);
        4: v1 := round(v1) xor round(v2);
      end;
    end;

  until (op = 0);

  Result := v1;
end;


function Evaluate(const expression: String; const evaluationContext: IEvaluationContext): TEvaluationResult;
{$IFNDEF UPCASE_STRING}
var i: Integer;
{$ENDIF}
begin

  if expression = '' then
    Result := 0
  else
  begin

    // Set the global variables for the unit.
    MathEvaluate.evaluationContext := evaluationContext;
    {$IFDEF UPCASE_STRING}
    MathEvaluate.s := UpCase(expression);
    {$ELSE}
    // Currently there is only UpCase(Char) in PAS2JS
    MathEvaluate.s := expression;
    for i:=1 to Length(MathEvaluate.s) do  MathEvaluate.s[i]:=UpCase( MathEvaluate.s[i] );
    {$ENDIF}
    MathEvaluate.cix := 1;
    Result := SimpleExpression;
  end;
end;

end.
