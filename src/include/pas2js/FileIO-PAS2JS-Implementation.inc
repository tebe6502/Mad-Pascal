uses SysUtils, Messages;

function FileExists(const FileName: TFilePath; FollowLink: Boolean = True): Boolean;
begin
end;

procedure AssignFile(f: TTextFile; fName: TFilePath); overload;
begin
  ;
end;

procedure AssignFile(f: TBinaryFile; fName: TFilePath); overload;
begin
end;

procedure BlockRead(var f: TBinaryFile; var Buf; Count: Longint; var Result: Longint);
begin
end;

procedure CloseFile(f: TTextFile); overload;
begin
end;

procedure CloseFile(f: TBinaryFile); overload;
begin
end;

procedure Flush(f: TTextFile);
begin
end;


procedure Reset(f: TTextFile); overload;
begin
end;

procedure Reset(f: TBinaryFile); overload;
begin
end;

procedure Reset(var f: TBinaryFile; l: Longint); overload;
begin
end;

function FilePos(var f: TBinaryFile): TInteger;
begin
end;

procedure Seek(var f: TBinaryFile; Pos: TInteger);
begin
end;

procedure ReadLn(var F: TTextFile; Args: String);
begin
end;

procedure Read(var F: TTextFile; Args: Char);
begin
end;

procedure Read(var F: TBinaryFile; Args: Char);
begin
end;

procedure Rewrite(f: TTextFile); overload;
begin
end;

procedure Rewrite(f: TBinaryFile); overload;
begin
end;

procedure Erase(var f: TTextFile); overload;
begin
  ;
end;

procedure Erase(var f: TBinaryFile); overload;
begin
  ;
end;

function EOF(f: TTextFile): Boolean; overload;
begin
end;

function EOF(f: TBinaryFile): Boolean; overload;
begin
end;

procedure WriteLn(s: String); overload;
begin
  System.WriteLn(s);
end;


procedure WriteLn(f: TTextFile); overload;
begin
end;

procedure WriteLn(f: TTextFile; s: String); overload;
begin

end;

procedure WriteLn(f: TTextFile; s1: String; s2: String); overload;
begin
end;

procedure WriteLn(f: TTextFile; s1: String; s2: String; s3: String); overload;
begin
end;
