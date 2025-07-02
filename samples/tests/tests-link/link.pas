{

0
11
347
321785

}


uses crt;


procedure prc(a,b,c: integer); external;


procedure print(a: dword); register;
begin

 writeln(a);

end;


{$link test.obx}



begin

 print(0);

 prc(11, 347, 321785);

 repeat until keypressed;

end.
