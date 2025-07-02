// FPC test speed

uses crt, sysutils;

var t: cardinal;
    i: integer;
    a: string;
    
lab: array [0..16] of string = (

      '@expandSHORT2SMALL1',
      '@expandSHORT2SMALL',
      '@expandToCARD.SHORT',
      '@expandToCARD1.SHORT',
      '@expandToCARD.SMALL',
      '@expandToCARD1.SMALL',
      '@expandToREAL',
      '@expandToREAL1',
      '@hiBYTE',
      '@hiWORD',
      '@hiCARD',
      '@movZTMP_aBX',
      '@movaBX_EAX',
      '@BYTE.MOD',
      '@YTE.DIV',
      '@imulBYTE',
      '@mulSHORTINT'
);
    

function ElfHash(const Value: string): cardinal;
var
  x: cardinal;
  i: byte;
begin
  Result := 0;
  for i := 1 to Length(Value) do
  begin
    Result := (Result shl 4) + Ord(Value[i]);
    x := Result and $F0000000;
    if (x <> 0) then
      Result := Result xor (x shr 24);
    Result := Result and (not x);
  end;
end;


procedure put(a: integer);
begin

//writeln(a);

end;


procedure test3(arg0: string);
var i: cardinal;
begin

      i:=ElfHash(arg0);
      
      case i of

       $08D58F81 : put(0) ;
       $078D58FC : put(1) ;
       $0A4BEA14 : put(2) ;
       $05F632F4 : put(3) ;
       $0A4C0C6C : put(4) ;
       $05F7F48C : put(5) ;
       $0F7B015C : put(6) ;
       $07B01501 : put(7) ;
       $06ED7EC5 : put(8) ;
       $06EEC424 : put(9) ;
       $06ED7624 : put(10); 
       $0D523E88 : put(11); 
       $053B7FA8 : put(12); 
       $0E887644 : put(13); 
       $0E882CB6 : put(14); 
       $04C03985 : put(15); 
       $09334D44 : put(16);
      
      end;

end;



procedure test2(arg0: string);
var i: cardinal;
begin

      i:=ElfHash(arg0);

      if i = $08D58F81 then put(0) else
      if i = $078D58FC then put(1) else
      if i = $0A4BEA14 then put(2) else
      if i = $05F632F4 then put(3) else
      if i = $0A4C0C6C then put(4) else
      if i = $05F7F48C then put(5) else
      if i = $0F7B015C then put(6) else
      if i = $07B01501 then put(7) else
      if i = $06ED7EC5 then put(8) else
      if i = $06EEC424 then put(9) else
      if i = $06ED7624 then put(10) else
      if i = $0D523E88 then put(11) else
      if i = $053B7FA8 then put(12) else
      if i = $0E887644 then put(13) else
      if i = $0E882CB6 then put(14) else
      if i = $04C03985 then put(15) else
      if i = $09334D44 then put(16);

end;


procedure test(arg0: string);
begin

      if arg0 = '@expandSHORT2SMALL1' then put(0) else
      if arg0 = '@expandSHORT2SMALL' then put(1) else
      if arg0 = '@expandToCARD.SHORT' then put(2) else
      if arg0 = '@expandToCARD1.SHORT' then put(3) else
      if arg0 = '@expandToCARD.SMALL' then put(4) else
      if arg0 = '@expandToCARD1.SMALL' then put(5) else
      if arg0 = '@expandToREAL' then put(6) else
      if arg0 = '@expandToREAL1' then put(7) else
      if arg0 = '@hiBYTE' then put(8) else	
      if arg0 = '@hiWORD' then put(9) else	
      if arg0 = '@hiCARD' then put(10) else	
      if arg0 = '@movZTMP_aBX' then put(11) else
      if arg0 = '@movaBX_EAX' then put(12) else	
      if arg0 = '@BYTE.MOD' then put(13) else	
      if arg0 = '@YTE.DIV' then put(14) else	
      if arg0 = '@imulBYTE' then put(15) else	
      if arg0 = '@mulSHORTINT' then put(16);	

end;



begin

//for a in lab do writeln(hexStr(ElfHash(a),8));


// ----------------------------------- test #1

t:=GetTickCount64;

for i:=0 to 1000000 do
 for a in lab do test(a);

t:=GetTickCount64-t;
writeln('standard: ',t);


// ----------------------------------- test #2

t:=GetTickCount64;

for i:=0 to 1000000 do
 for a in lab do test2(a);

t:=GetTickCount64-t;
writeln('ElfHash IF: ',t);


// ----------------------------------- test #3

t:=GetTickCount64;

for i:=0 to 1000000 do
 for a in lab do test3(a);

t:=GetTickCount64-t;
writeln('ElfHash CASE: ',t);


repeat until keypressed;

end.

{

standard: 1312
ElfHash IF: 500
ElfHash CASE: 469

}