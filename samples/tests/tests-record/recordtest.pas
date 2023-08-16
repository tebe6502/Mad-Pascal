{

Henry
42
0: 1,10,5
1: 2,12,3
2: 6,20,10
3: 10,17,5

}

uses crt;

type
  TestRecord = packed record
    ref: cardinal;

    name: string[40];

    id: array [0..3] of byte;
    offset: array [0..3] of byte;
    width: array[0..3] of byte;
  end;
  PTestRecord = ^TestRecord;

var
  test1: TestRecord;
  testPtr: PTestRecord;
  tests: Array [0..3] of PTestRecord;
  i: byte;


procedure TestIndirect(var test:TestRecord);
begin
  WriteLn('-- indirect --');
  writeln(test.name);
  writeln(test.ref);

  for i:=0 to 3 do begin
    writeln(i, ': ', test.id[i], ',', test.offset[i], ',', test.width[i]);
  end;
end;

procedure TestPointer(ptest:PTestRecord);
begin
  WriteLn('-- pointer --');
  writeln(ptest^.name);
  writeln(ptest^.ref);

  for i:=0 to 3 do begin
    writeln(i, ': ', ptest.id[i], ',', ptest.offset[i], ',', ptest.width[i]);
  end;

end;


procedure TestIndex(index: byte);
begin
  WriteLn('-- index --');
  writeln(tests[index].name);
  writeln(tests[index].ref);

  for i:=0 to 3 do begin
    writeln(i, ': ', tests[index].id[i], ',', tests[index].offset[i], ',', tests[index].width[i]);
  end;

end;


begin

  test1.name := 'Henry';
  test1.ref := 42;
  test1.id[0] := 1;
  test1.offset[0] := 10;
  test1.width[0] := 5;
  test1.id[1] := 2;
  test1.offset[1] := 12;
  test1.width[1] := 3;
  test1.id[2] := 6;
  test1.offset[2] := 20;
  test1.width[2] := 10;
  test1.id[3] := 10;
  test1.offset[3] := 17;
  test1.width[3] := 5;


  WriteLn('-- direct --');
  writeln(test1.name);
  writeln(test1.ref);
  for i:=0 to 3 do begin
    writeln(i, ': ', test1.id[i], ',', test1.offset[i], ',', test1.width[i]);
  end;

  tests[1] := @test1;

  TestIndirect(test1);
  TestPointer(tests[1]);
  TestIndex(1);


  repeat until Keypressed();
end.
