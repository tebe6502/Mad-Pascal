{

11
347
321785

}


uses crt;


procedure prc(a,b,c: integer); external;


procedure print(value: dword); keep; register;
begin

 writeln(value);

end;


{$link test.obx}	// link PRC procedure


begin

 prc(11, 347, 321785);

 repeat until keypressed;

end.
