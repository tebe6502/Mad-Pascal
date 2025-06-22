{
  Example for calling from Pascal to a linked, relocateable assembler routine and back.
  Requires "test.asm" to be assembled using "mads test.asm"

  Output:

11
347
321785

}


uses crt;


{ External assembler procedure called from Pascal. }
procedure prc(a,b,c: integer); external;


{ Pascal procedure called from assembler as external procdure. }
procedure print(value: dword); keep; register;
begin

 writeln(value);

end;


{$link 'test.obx'}	// link PRC procedure


begin

 prc(11, 347, 321785);

 repeat until keypressed;

end.
