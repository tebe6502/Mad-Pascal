unit MathEvaluate;

(* source: CLSN PASCAL              *)
(*            *)
(* This program will evaluate       *)
(* numeric expressions like:        *)

(* 5+6/7    sin(cos(pi))  sqrt(4*4) *)

(* Mutual recursion was necessary   *)
(* so the FORWARD clause was used   *)

interface


function evaluate(const a: String; i: Integer): Real;


implementation

uses Math, common, parser, scanner, Messages;

type
  sop = String[10];

var
  s: String;
  cix: Integer;

  TokenIndex: Integer;


  // if the names of the functions are similar then their longer versions should be placed earlier
  // arctan2 .. arctan
  fop: array[0..14] of sop = (' ', 'PI', 'RND', 'SQRT', 'SQR', 'ARCTAN2', 'COS', 'SIN', 'TAN', 'EXP',
    'LN', 'ABS', 'INT', 'POWER', 'ARCTAN');

  top: array[0..7] of sop = (' ', '*', '/', 'DIV', 'MOD', 'AND', 'SHL', 'SHR');
  seop: array[0..4] of sop = (' ', '+', '-', 'OR', 'XOR');


function simple_expression: Real; forward;


procedure skip_blanks;
begin
  while (s[cix] = ' ') do
    Inc(cix);
end;


function constant: Real;
var
  n: String;
  v1: Real;
  v, k, ln, i: Integer;
  p: Word;
  pflg: Boolean;

  IdentTemp: Integer;

begin
  n := '';
  pflg := False;

  skip_blanks;

  p := 0;


  if s[cix] = '%' then
  begin            // bin

    Inc(cix);

    while (s[cix] in ['0', '1']) do
    begin
      n := n + s[cix];

      Inc(cix);
    end;

    if length(n) = 0 then
      Error(TokenIndex, 'Invalid constant %');

    //remove leading zeros
    i := 1;
    while n[i] = '0' do Inc(i);

    ln := length(n);
    v := 0;

    //do the conversion
    for k := ln downto i do
      if n[k] = '1' then
        v := v + (1 shl (ln - k));

    v1 := v;

  end
  else


    if s[cix] = '$' then
    begin            // hex

      n := '$';
      Inc(cix);

      while (UpCase(s[cix]) in ['0'..'9', 'A'..'F']) do
      begin
        n := n + s[cix];

        Inc(cix);
      end;

      val(n, v, p);

      v1 := v;

    end
    else
    begin              // dec

      while (s[cix] in ['0'..'9']) or ((s[cix] = '.') and (not pflg)) do
      begin
        if (s[cix] = '.') then pflg := True;

        n := n + s[cix];

        Inc(cix);
      end;

      val(n, v1, p);

    end;


  if (p <> 0) then
  begin

    n := get_constant(cix, s);

    IdentTemp := GetIdent(n);

    if IdentTemp > 0 then
      v1 := Ident[IdentTemp].Value
    else
      Error(TokenIndex, 'Invalid constant "' + n + '"');

  end;


  constant := v1;
end;


function xnot(v: Real): Real;
begin
  if (v = 0) then
    xnot := 1
  else
    xnot := 0;
end;


function factor: Real;
var
  v1, v2: Real;
  ch: Char;
  op, i: Byte;


  procedure Wrong_number;
  begin

    Error(TokenIndex, 'Wrong number of parameters specified for call to "' + fop[op] + '"');

  end;

begin
  skip_blanks;

  op := 0;
  v1 := 0;
  v2 := 0;

  for i := 1 to High(fop) do
    if (op = 0) then
      if (copy(s, cix, length(fop[i])) = fop[i]) then
        op := i;

  if (op > 0) then
  begin
    cix := cix + length(fop[op]);

    skip_blanks;

    if (op in [1, 2]) and (s[cix] = '(') then
      Wrong_number;


    if (op > 2) then            // 0:' ', 1:'PI', 2:'RND'
    begin
      if (s[cix] <> '(') then
        Wrong_number;

      v1 := factor;

      if (op in [5, 13]) and (s[cix] <> ',') then    // 5:'ARCTAN2', 13:'POWER'
        Wrong_number;

      if s[cix] = ',' then
      begin

        if not (op in [5, 13]) then        // 5:'ARCTAN2', 13:'POWER'
          Wrong_number;

        Inc(cix);

        skip_blanks;

        v2 := factor;

        if s[cix] <> ')' then
          Wrong_number;

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
    end;

  end
  else
    if (s[cix] = '(') then
    begin
      Inc(cix);

      v1 := simple_expression;

      skip_blanks;

      if (s[cix] <> ',') then

        if (s[cix] = ')') then
          Inc(cix)
        else
          Error(TokenIndex, 'Parenthesis Mismatch');
    end
    else
      if (s[cix] = '-') or (s[cix] = '+') or (copy(s, cix, 3) = 'NOT') then
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
        end;
      end
      else
        v1 := constant;

  factor := v1;
end;


function term: Real;
var
  op, i: Byte;
  v1, v2: Real;

begin
  v1 := factor;

  repeat
    skip_blanks;

    op := 0;

    for i := 1 to High(top) do
      if (op = 0) then
        if (copy(s, cix, length(top[i])) = top[i]) then
          op := i;

    if (op > 0) then
    begin
      cix := cix + length(top[op]);

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

  term := v1;

end;


function simple_expression: Real;
var
  op, i: Byte;
  v1, v2: Real;

begin
  skip_blanks;

  v1 := term;

  repeat
    skip_blanks;

    op := 0;

    for i := 1 to High(seop) do
      if (op = 0) then
        if (copy(s, cix, length(seop[i])) = seop[i]) then
          op := i;

    if (op > 0) then
    begin
      cix := cix + length(seop[op]);

      v2 := term;

      case op of
        1: v1 := v1 + v2;
        2: v1 := v1 - v2;
        3: v1 := round(v1) or round(v2);
        4: v1 := round(v1) xor round(v2);
      end;
    end;

  until (op = 0);

  simple_expression := v1;
end;


function evaluate(const a: String; i: Integer): Real;
var
  k: Word;
begin

  Result := 0;

  TokenIndex := i;

  if a <> '' then
  begin

    cix := 1;

    s := a;
    for k := 1 to length(s) do
      s[k] := upcase(s[k]);

    evaluate := simple_expression;

  end;

end;


end.
