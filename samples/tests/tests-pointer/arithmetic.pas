{
  Expected result:

8657
8657
2 3

8657
8657
2 3

}

uses crt;

var
  a: array [0..1] of Byte = (2, 3);
  p: ^Byte = @a;

begin
  WriteLn(Word(@a));
  WriteLn(Word(@a[0]));
  WriteLn(a[0], ' ', a[1]);
  WriteLn;
  WriteLn(Word(p));
  WriteLn(Word(Pointer(p)));
  WriteLn(Byte((Pointer(p)+0)^), ' ', Byte((Pointer(p)+1)^));    // (1)

  repeat until keypressed;

end.
