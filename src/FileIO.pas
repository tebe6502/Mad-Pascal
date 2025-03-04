// Working version. Only used currently to satisfy the USES already.
unit FileIO;

interface

{$i define.inc}
{$i Types.inc}

type TFilePath = string;
type TFilePosition = LongInt;


type TFile = class
  protected filePath: TFilePath;
  public
        constructor Create;
	procedure Assign2(filePath: TFilePath); Virtual; Abstract; 
	procedure Close2; Virtual; Abstract; 
	procedure Erase2(); Virtual; Abstract;
        function EOF2():Boolean; Virtual; Abstract;
	procedure Reset2(); Virtual; Abstract;  // Open for reading
	procedure Rewrite2(); Virtual; Abstract;  // Open for writing
end;

type TTextFile2 = class(TFile)
{$IFNDEF PAS2JS}
  private
        type TTextFile = TextFile;
  private
        f    : TTextFile;
{$ENDIF}
  public
        constructor Create;
  	procedure Assign2(filePath: TFilePath); override; 
	procedure Close2; override; 
	procedure Erase2(); override; 
        function EOF2():Boolean; override; 

	procedure Flush2;
	// https://www.freepascal.org/docs-html/rtl/system/read.html
	procedure Read2( var Args: Char);
	procedure ReadLn2( var Args: String);
	procedure Reset2(); override;
	procedure Rewrite2(); override;

        function Write2(s:string): TTextFile2; overload;
        function Write2(s:string; w: Integer): TTextFile2; overload;
        function Write2(i:Integer; w: Integer): TTextFile2; overload;

	procedure WriteLn2; overload;
        procedure WriteLn2(s:string); overload;
        procedure WriteLn2(s1:string; s2:string); overload;
        procedure WriteLn2(s1:string; s2:string; s3: string); overload;
end;

type TBinaryFile2 = class(TFile)
{$IFNDEF PAS2JS}
  private
        type TBinaryFile = file of char;
  private
        f: TBinaryFile;
{$ENDIF}
  public
        constructor Create;
  	procedure Assign2(filePath: TFilePath); override; 
  	// https://www.freepascal.org/docs-html/rtl/system/blockread.html
	procedure BlockRead2(var Buf; count: LongInt; var Result: LongInt );
	procedure Close2; override;
	procedure Erase2(); override; 
        function EOF2():Boolean; override;
	// https://www.freepascal.org/docs-html/rtl/system/filepos.html
	function FilePos2( ):Int64;
        procedure Read2(var Args: Char); 
	procedure Reset2(); override; overload;
	procedure Reset2(l: LongInt); overload;
	procedure Rewrite2(); override;
	procedure Seek2(Pos: Int64 );
	
end;

implementation

{$IFDEF PAS2JS}
//  {$I 'include\pas2js\FileIO-PAS2JS-Implementation.inc'}
{$ENDIF}

//
// TFile
//
constructor TFile.Create;
begin
  filePath:='';
end;


//
// TTextFile
//
constructor TTextFile2.Create;
begin
  Inherited;
end;
        
procedure TTextFile2.Assign2(filePath: TFilePath); 
begin
  Self.filePath:=filePath;
  WriteLn('TODO: Assignining TTextFile2 '+filePath);
{$IFNDEF PAS2JS}
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TTextFile2.Close2(); 
begin
  WriteLn('TODO: Closing TTextFile2 '+filePath);
{$IFNDEF PAS2JS}
  CloseFile(f);
{$ENDIF}

end;

procedure TTextFile2.Erase2();
begin
{$IFNDEF PAS2JS}
  Erase(f);
{$ENDIF}

end;

function TTextFile2.EOF2():Boolean;
begin
{$IFNDEF PAS2JS}
  Result:=EOF(f);
{$ENDIF}

end;


procedure TTextFile2.Flush2(); 
begin
{$IFNDEF PAS2JS}
  Flush(f);
{$ENDIF}

end;

procedure TTextFile2.Read2(var Args: Char);
begin
{$IFNDEF PAS2JS}
  Read(f, Args);
{$ENDIF}

end;

procedure TTextFile2.ReadLn2(var Args: String);
begin
{$IFNDEF PAS2JS}
  ReadLn(f, Args);
{$ENDIF}

end;

procedure TTextFile2.Reset2();
begin
{$IFNDEF PAS2JS}
  Reset(f);
{$ENDIF}

end;

procedure TTextFile2.Rewrite2();
begin
{$IFNDEF PAS2JS}
  Rewrite(f);
{$ENDIF}

end;

function TTextFile2.Write2(s:string): TTextFile2;
begin
{$IFNDEF PAS2JS}
  Write(f, s);
{$ENDIF}
end;

function TTextFile2.Write2(s:string; w: Integer): TTextFile2;
begin
{$IFNDEF PAS2JS}
  Write(f, s);
{$ENDIF}
end;

function TTextFile2.Write2(i:Integer; w: Integer): TTextFile2;
begin
{$IFNDEF PAS2JS}
  Write(f, i);
{$ENDIF}

end;

procedure TTextFile2.WriteLn2();
begin
{$IFNDEF PAS2JS}
 WriteLn(f, '');
{$ENDIF}

end;

procedure TTextFile2.WriteLn2(s:string); overload;
begin
{$IFNDEF PAS2JS}
 WriteLn(f, s);
{$ENDIF}

end;

procedure TTextFile2.WriteLn2( s1:string; s2:string); overload;
begin
{$IFNDEF PAS2JS}
 WriteLn(f, s1, s2);
{$ENDIF}

end;

procedure TTextFile2.WriteLn2(s1:string; s2:string; s3: string); overload;
begin
{$IFNDEF PAS2JS}
 WriteLn(f, s1, s2, s3);
{$ENDIF}

end;

//
// TBinaryFile
//
constructor TBinaryFile2.Create;
begin
  Inherited;
end;

procedure TBinaryFile2.Assign2(filePath: TFilePath); 
begin
  Self.filePath:=filePath;
{$IFNDEF PAS2JS}

  // WriteLn('TODO: Assignining TBinaryFile2 '+filePath);
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TBinaryFile2.BlockRead2(var Buf; Count: LongInt; var Result: LongInt );
begin
{$IFNDEF PAS2JS}
  BlockRead( f, Buf, Count,  Result );
{$ENDIF}
end;

procedure TBinaryFile2.Close2(); 
begin
{$IFNDEF PAS2JS}

  // WriteLn('TODO: Closing TBinaryFile2 '+filePath);
  CloseFile(f);
{$ENDIF}

end;

function TBinaryFile2.EOF2():Boolean; 
begin
{$IFNDEF PAS2JS}
  Result := EOF(f);
{$ENDIF}
end;

procedure TBinaryFile2.Erase2(); 
begin
{$IFNDEF PAS2JS}
  Erase(f);
{$ENDIF}

end;

function TBinaryFile2.FilePos2( ):Int64;
begin
{$IFNDEF PAS2JS}
  Result :=  FilePos(f);
{$ENDIF}
end;

procedure TBinaryFile2.Read2(var Args: Char);
begin
{$IFNDEF PAS2JS}

  Read(f, Args);
{$ENDIF}

end;


procedure TBinaryFile2.Reset2(); overload;
begin
{$IFNDEF PAS2JS}

  // WriteLn('TODO: Reset2 TBinaryFile2 '+filePath);
  Reset(f);
{$ENDIF}
end;

procedure TBinaryFile2.Reset2(l: LongInt); overload;
begin
{$IFNDEF PAS2JS}

  // WriteLn('TODO: Reset2 TBinaryFile2 '+filePath);
  Reset(f,l);
{$ENDIF}
 
end;

procedure TBinaryFile2.Rewrite2();
begin
{$IFNDEF PAS2JS}
  Rewrite(f);
{$ENDIF}
 
end;

procedure TBinaryFile2.Seek2(Pos: Int64 );
begin
{$IFNDEF PAS2JS}
  Seek(f, pos);
{$ENDIF}
end;

end.
