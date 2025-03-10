program TestLanguage;

uses SysUtils;

type ITextFile = interface
end;

type TTextFile = class(TInterfacedObject, ITextFile)
  public
        constructor Create;
end;

type TFileSystem = class
  public
        class function CreateTextFile: ITextFile; static;
end;


//
// TTextFile
//
constructor TTextFile.Create;
begin
  Inherited;
end;

class function TFileSystem.CreateTextFile:ITextFile;

begin
  Result:=TTextFile.Create;
end;


procedure TestTextFile;
var textFile: ITextFile;
begin
  textFile:=TFileSystem.CreateTextFile;
  // Interfaced objects are implicitly reference counted and freed.
end;

// https://en.wikipedia.org/wiki/Single-precision_floating-point_format
procedure TestRound(fl : Single);
var i : LongInt; // 32 bit
var j : LongInt; // 32 bit
begin
  i:=Round(fl*256);  // Round Next Even
    j:=LongInt(fl);

  Writeln(fl,' i=',i:11 ,' ',IntToHex(i,8),' j=',j:11,' ',IntToHex(j,8));
end;


procedure TestRoundAll();
begin

  TestRound(1);
  TestRound(2);
  TestRound(4);
  TestRound(8);

  TestRound(-1);
  TestRound(-2);
  TestRound(-4);
  TestRound(-8);

  TestRound(0.1);
  TestRound(0.5);
  TestRound(1.5);
  TestRound(1.9);

  TestRound(-0.1);
  TestRound(-0.5);
  TestRound(-1.1);
  TestRound(-1.5);
  TestRound(-1.9);

end;

begin
  TestRoundAll;
  TestTextFile;
end.


