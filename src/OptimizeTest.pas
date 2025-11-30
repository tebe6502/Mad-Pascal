unit OptimizeTest;


interface


procedure Test;


implementation

uses SysUtils, CompilerTypes, FileIO, Common, Optimize;

type
  TDummyTextFile = class(TInterfacedObject, ITextFile)
  public
    constructor Create;

    function GetFilePath: TFilePath;
    function GetAbsoluteFilePath: TFilePath;

    procedure Assign(const filePath: TFilePath);
    procedure Close;
    procedure Erase();
    function EOF(): Boolean;

    procedure Flush;
    // https://www.freepascal.org/docs-html/rtl/system/read.html
    procedure Read(var c: Char);
    procedure ReadLn(var s: String);
    procedure Reset();
    procedure Rewrite();

    function Write(s: String): ITextFile; overload;
    function Write(s: String; w: Integer): ITextFile; overload;
    function Write(i: Integer; w: Integer): ITextFile; overload;

    procedure WriteLn; overload;
    procedure WriteLn(s: String); overload;
    procedure WriteLn(s1: String; s2: String); overload;
    procedure WriteLn(s1: String; s2: String; s3: String); overload;

    function GetLines: TStringArray;

  private
  var
    lineArray: TStringArray;
  end;


constructor TDummyTextFile.Create;
begin
end;

function TDummyTextFile.GetFilePath: TFilePath;
begin
  Result := 'DummyFilePath';
end;

function TDummyTextFile.GetAbsoluteFilePath: TFilePath;
begin
  Result := 'AbsoluteDummyFilePath';
end;

procedure TDummyTextFile.Assign(const filePath: TFilePath);
begin

end;

procedure TDummyTextFile.Close;
begin

end;

procedure TDummyTextFile.Erase();
begin
  Assert(False);
end;

function TDummyTextFile.EOF(): Boolean;
begin
  Assert(False);
end;

procedure TDummyTextFile.Flush;
begin

end;


procedure TDummyTextFile.Read(var c: Char);
begin

end;

procedure TDummyTextFile.ReadLn(var s: String);
begin

end;

procedure TDummyTextFile.Reset();
begin

end;

procedure TDummyTextFile.Rewrite();
begin
  SetLength(lineArray, 0);
end;

function TDummyTextFile.Write(s: String): ITextFile; overload;
begin
  Assert(False, s);
end;

function TDummyTextFile.Write(s: String; w: Integer): ITextFile; overload;
begin
  Assert(False);
end;

function TDummyTextFile.Write(i: Integer; w: Integer): ITextFile; overload;
begin
  Assert(False);
end;

procedure TDummyTextFile.WriteLn; overload;
begin
end;

procedure TDummyTextFile.WriteLn(s: String); overload;
var
  l: Integer;
begin
  l := High(lineArray) + 1;
  SetLength(lineArray, l + 1);
  lineArray[l] := s;
end;

procedure TDummyTextFile.WriteLn(s1: String; s2: String); overload;
begin
  Assert(False);
end;

procedure TDummyTextFile.WriteLn(s1: String; s2: String; s3: String); overload;
begin
  Assert(False);
end;

function TDummyTextFile.GetLines: TStringArray;
begin
  Result := lineArray;
end;

procedure Test;
var
  SourceLocation: TSourceLocation;
  DummyTextFile: TDummyTextFile;
  lineArray: TStringArray;
begin
  Optimize.Initialize;
  Optimize.ResetForTmp;
  Optimize.ResetOpty;
  sourceLocation := Default(TSourceLocation);
  dummyTextFile := TDummyTextFile.Create;
  Common.OutFile := DummyTextFile;
  Optimize.StartOptimization(sourceLocation);
  asm65(#9'inx', '');
  asm65(#9'mva P :STACKORIGIN,x', '');
  asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x', '');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x', '');
  asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x', '');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x', '');
  asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x', '');
  asm65(#9'lda :STACKORIGIN,x', '');
  asm65(#9'sta :STACKORIGIN,x', '');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x', '');
  asm65(#9'asl :STACKORIGIN,x', '');
  asm65(#9'rol @', '');
  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x', '');
  asm65(#9'lda :STACKORIGIN,x', '');
  asm65(#9'sta :STACKORIGIN,x', '');
  asm65(#9'lda :STACKORIGIN,x', '');
  asm65(#9'add MONSTER', '');
  asm65(#9'sta :TMP', '');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x', '');
  asm65(#9'adc MONSTER+1', '');
  asm65(#9'sta :TMP+1', '');
  asm65(#9'ldy #$00', '');
  asm65(#9'lda (:TMP);,y', '');
  asm65(#9'sta :bp2', '');
  asm65(#9'iny', '');
  asm65(#9'lda (:TMP);,y', '');
  asm65(#9'sta :bp2+1', '');
  asm65(#9'ldy #$00', '');
  asm65(#9'lda (:bp2);,y', '');
  asm65(#9'sta :STACKORIGIN,x', '');
  asm65(#9'inx', '');
  asm65(#9'mva #$02 :STACKORIGIN,x', '');
  asm65(#9'jsr addAL_CL', '');
  asm65(#9'dex', '');
  asm65(#9'lda :STACKORIGIN-1,x', '');
  asm65(#9'add #$00', '');
  asm65(#9'tay', '');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x', '');
  asm65(#9'adc #$00', '');
  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x', '');
  asm65(#9'lda adr.MONSTER,y', '');
  asm65(#9'sta :bp2', '');
  asm65(#9'lda adr.MONSTER+1,y', '');
  asm65(#9'sta :bp2+1', '');
  asm65(#9'ldy #$00', '');
  asm65(#9'lda :STACKORIGIN,x', '');
  asm65(#9'sta (:bp2);,y', '');
  asm65(#9'dex', '');
  asm65(#9'dex', '');
  asm65('', '');
  StopOptimization;
  Optimize.FlushTemporaryBuf;

  lineArray := DummyTextFile.GetLines;

end;

end.
