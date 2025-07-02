// https://bitbucket.org/paul_nicholls/pas6502/src/master/uTests.pas

uses
  crt;
  
var
  x,y   : Byte;
  i, count : Word;
 
//---------------------------- 
function test1 : Boolean;
var
  a,b : Word;
begin
  a := 4;
  Result := (a < word(10));
end; 
//---------------------------- 
function test2 : Boolean;
var
  a,b : Word;
begin
  a := 5;
  Result := (a <= word(5));
end;
//----------------------------   
function test3 : Boolean;
var
  a,b : Word;
begin
  a := 5;
  Result := (a = word(5));
end;
//---------------------------- 
function test4 : Boolean;
var
  a,b : Word;
begin
  a := 20;
  b := 19;
  Result := b < a;
end;
//---------------------------- 
function test5 : Boolean;
var
  a,b : Word;
begin
  a := 20;
  b := 20;
  Result := a <= b;
end;
//---------------------------- 
function test6 : Boolean;
var
  a,b : Word;
begin
  a := 30;
  b := 19;
  Result := a > b;
end;
//---------------------------- 
function test7 : Boolean;
var
  a,b : Word;
begin
  a := 30;
  b := 30;
  Result := a >= b;
end;
//---------------------------- 
function test8 : Boolean;
var
  a,b : Word;
begin
  a := 30;
  b := 30;
  Result := a = b;
end;
//---------------------------- 
function test9 : Boolean;
var
  a : Word;
  b : Byte;
begin
  a := 30;
  b := 30;
  Result := a = b;
end;
//---------------------------- 
function test10 : Boolean;
var
  a : Word;
  b : Byte;
begin
  a := 30;
  b := 31;
  Result := a <> b;
end;
//---------------------------- 
function test11 : Boolean;
var
  a : integer;
begin
  a := $123456;
  Result := (a and $00ff00) = $003400;
end;
//---------------------------- 
function test12 : Boolean;
var
  a : integer;
begin
  a := $123456;
  Result := (a and $ffff00) = $123400;
end;
//---------------------------- 
function test13 : Boolean;
var
  a : integer;
begin
  a := $123456;
  Result := ((a and $00f000) shr 12) = $3;
end;
//---------------------------- 
function test14 : Boolean;
var
  a,b : ShortInt;
begin
  a := -9;
  b :=9;
  Result := a * b = -81;
end;
//---------------------------- 
function test15 : Boolean;
var
  a,b : Word;
begin
  a := 35000;
  b := 85;
  Result := (a div b) = 411;
end;
//---------------------------- 
function test16 : Boolean;
var
  a,b : Word;
begin
  a := 35000;
  b := 85;
  Result := (a mod b) = 65;
end;
//---------------------------- 
function test17 : Boolean;
var
  a,b : ShortInt;
  c,m : Integer;
begin
  a := 9;
  b := -18;
  m := 6;
  c := (a*a - b*b);
  Result := (c mod m) = -3;
end;
//---------------------------- 
function test18 : Boolean;
var
  a, b: byte;
begin
  a := 1;
  b := 1;
  Result := (a + b - 3) < 0;
end;

//----------------------------
//       main code
//----------------------------
  
procedure doTest(v : Boolean);
var
  r   : Byte;
begin
  r := ord(v);
  
  // draw test number, draw test result 
  writeln(count, '  ', v);

  count := count + 1;

end;


begin
  clrscr;

  x := 0;
  y := 0;
  count := 1;
  
  doTest(test1);    
  doTest(test2);    
  doTest(test3); 
  doTest(test4);    
  doTest(test5);    
  doTest(test6);
  doTest(test7);
  doTest(test8);
  doTest(test9);
  doTest(test10);
  doTest(test11);
  doTest(test12);
  doTest(test13);
  doTest(test14);
  doTest(test15);
  doTest(test16);
  doTest(test17);
  doTest(test18);

  repeat until keypressed;   
  
end.
