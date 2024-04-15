program evaluate;

(* source: CLSN PASCAL              *)
(*				    *)
(* This program will evaluate       *)
(* numeric expressions like:        *)

(* 5+6/7    sin(cos(pi))  sqrt(4*4) *)

(* Mutual recursion was necessary   *)
(* so the FORWARD clause was used   *)

uses crt, math;

type
  sop=string[8];

var
    s: string;
  cix: byte;

  fop: array[0..13] of sop = (' ','PI','SQRT','SQR','ARCTAN','COS','SIN','TAN','RND','EXP','LN','ABS','INT','POW');
  top: array[0..7] of sop=(' ','*','/','DIV','MOD','AND','SHL','SHR');
  seop: array[0..4] of sop=(' ','+','-','OR','XOR');


procedure error(s: string);
begin
  writeln(s);

  repeat until keypressed;
  halt;
end;


function simple_expression: real; forward;


procedure skip_blanks;
begin
  while (s[cix]=' ') do
    inc(cix);
end;


function constant: real;
var
     n: string;
    v1: real;
    p: byte;
  pflg: boolean;

begin
  n:=''; pflg:=false;

  skip_blanks;

  while ((s[cix]>='0') and (s[cix]<='9')) or ((s[cix]='.') and (not pflg)) do
    begin
      if (s[cix]='.') then
        pflg:=true;

      n:=concat(n, s[cix]); inc(cix);
    end;

  val(n,v1,p);

  if (p<>0) then
    error('Invalid constant');


  constant:=v1;
end;


function xnot(v: real): real;
begin
  if (v=0) then
    xnot:=1
  else
    xnot:=0;
end;


function factor: real;
var
       v1, v2: real;
       ch: char;
    op, i: byte;

begin
  skip_blanks;

  op:=0;

  for i:=1 to High(fop) do
    if (op=0) then
      if (copy(s,cix,length(fop[i])) = fop[i]) then
        op:=i;

  if (op>0) then
    begin
      cix:=cix+length(fop[op]);

      skip_blanks;

      if (op>1) then
        begin
          if (s[cix] <> '(') then
            error('Error in function syntax');

          v1:=factor;
	  
	  if (op=13) and (s[cix] <> ',') then
	     error('Wrong number of parameters');
	  
	  if s[cix] = ',' then begin
	   inc(cix);
	   
	   skip_blanks;
	   
	   v2:=factor;
	   
	   if s[cix] <> ')' then 
	     error('Wrong number of parameters');
	     
	   inc(cix);  
	   
	  end;
	  
        end;


      case op of
        1: v1:=pi;
        2: v1:=sqrt(v1);
        3: v1:=sqr(v1);
        4: v1:=arctan(v1);
        5: v1:=cos(v1);
        6: v1:=sin(v1);
        7: v1:=sin(v1)/cos(v1);
	8: v1:=Random;
        9: v1:=exp(v1);
       10: v1:=ln(v1);
       11: v1:=abs(v1);
       12: v1:=int(v1);
       13: v1:=power(v1,v2);
      end;
    end
  else
    if (s[cix]='(') then
      begin
        inc(cix);

        v1:=simple_expression;

        skip_blanks;
	
	if (s[cix] <> ',') then

        if (s[cix]=')') then
          inc(cix)
        else
          error('Parenthesis Mismatch');
      end
    else
      if (s[cix] = '-') or (s[cix] = '+') or (copy(s,cix,3)='NOT') then
        begin
          ch:=s[cix];

          if (ch='N') then
            cix:=cix+3
          else
            inc(cix);

          case ch of
            '+': v1:=factor;
            '-': v1:=-factor;
            'N': v1:=xnot(factor);
          end;
        end
     else
        v1:=constant;

  factor:=v1;
end;


function term: real;
var
   op,i: byte;
  v1,v2: real;

begin
  v1:=factor;

  repeat
    skip_blanks;

    op:=0;

    for i:=1 to High(top) do
      if (op=0) then
        if (copy(s,cix,length(top[i])) = top[i]) then
          op:=i;

    if (op>0) then
      begin
        cix:=cix+length(top[op]);

        v2:=factor;

        case op of
          1: v1:=v1*v2;
          2: v1:=v1/v2;
          3: v1:=round(v1) div round(v2);
          4: v1:=round(v1) mod round(v2);
          5: v1:=round(v1) and round(v2);
          6: v1:=round(v1) shl round(v2);
          7: v1:=round(v1) shr round(v2);
        end;
      end;

  until (op=0);

  term:=v1;

end;


function simple_expression: real;
var
  op,i: byte;
  v1,v2: real;

begin
  skip_blanks;

  v1:=term;

  repeat
    skip_blanks;

    op:=0;

    for i:=1 to High(seop) do
      if (op=0) then
        if (copy(s,cix,length(seop[i])) = seop[i]) then
          op:=i;

    if (op>0) then
      begin
        cix:=cix+length(seop[op]);

        v2:=term;

        case op of
          1: v1:=v1+v2;
          2: v1:=v1-v2;
          3: v1:=round(v1) or round(v2);
          4: v1:=round(v1) xor round(v2);
        end;
      end;

  until (op=0);

  simple_expression:=v1;
end;


function evaluate: real;
var
  k: byte;

begin
  cix:=1;

  for k:=1 to length(s) do
    s[k]:=upcase(s[k]);

  evaluate:=simple_expression;
end;


procedure start;
var
  v: real;

begin
  repeat
    writeln('Enter an expression');
    write('>');
    readln(s);

    if (s<>'') then
      begin
        v:=evaluate;

        writeln(s,'=',v:0:8);
        writeln;

      end;

  until (s='');
end;


begin
  clrscr;

  start;
end.
