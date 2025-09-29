unit FileIO;
// Interfaced objects are implicitly reference counted and freed.
// Therefore there are no explicit Free method on the files.  

{$I Defines.inc}

interface

uses SysUtils, CommonTypes;

{$SCOPEDENUMS ON}

type
  TFilePath = String;
  TFolderPath = TFilePath;


  TPathList = class
  public
    constructor Create;
    procedure AddFolder(folderPath: TFolderPath);
    function FindFile(filePath: TFilePath): TFilePath;
    function GetSize: Integer;
    function ToString: String; override;
  private
  var
    paths: array of TFilePath;
  end;


type
  TFilePosition = Longint;
// https://www.freepascal.org/docs-html/rtl/system/filepos.html
type
  IFile = interface
    function GetFilePath: TFilePath;
    function GetAbsoluteFilePath: TFilePath;
    procedure Assign(filePath: TFilePath);
    procedure Close;
    procedure Erase();
    function EOF(): Boolean;
    procedure Reset(); // Open for reading, raises EInOutError
    procedure Rewrite(); // Open for writing, raises EInOutError
  end;

type
  IBinaryFile = interface(IFile)
    // https://www.freepascal.org/docs-html/rtl/system/blockread.html
    procedure BlockRead(var Buf; Count: Longint; var Result: Longint);
    // https://www.freepascal.org/docs-html/rtl/system/filepos.html
    function FilePos(): TInteger;
    procedure Read(var c: Char);
    procedure Reset(l: Longint); overload; // l = record size
    procedure Seek2(Pos: TInteger);
  end;

type
  ITextFile = interface(IFile)
    procedure Flush;
    // https://www.freepascal.org/docs-html/rtl/system/read.html
    procedure Read(var c: Char);
    procedure ReadLn(var s: String);

    function Write(s: String): ITextFile; overload;
    function Write(s: String; w: Integer): ITextFile; overload;
    function Write(i: Integer; w: Integer): ITextFile; overload;

    procedure WriteLn; overload;
    procedure WriteLn(s: String); overload;
    procedure WriteLn(s1: String; s2: String); overload;
    procedure WriteLn(s1: String; s2: String; s3: String); overload;
  end;

type
  TFileMapEntry = class
  public
  type TFileType = (TextFile, BinaryFile, Folder);

  public
    filePath: TFilePath;
    fileType: TFileType;
    content: String;
  end;

type
  TFileMap = class
  public
    constructor Create;
    function AddEntry(const filePath: TFilePath; const fileType: TFileMapEntry.TFileType): TFileMapEntry;
    function GetEntry(const filePath: TFilePath): TFileMapEntry;
    procedure RemoveEntry(const filePath: TFilePath);

  private
    entries: array of TFileMapEntry;


  end;

type
  TFileSystem = class
  public
  const
  {$IFNDEF SIMULATED_FILE_IO}
    PathDelim = DirectorySeparator;
  {$ELSE}
    PathDelim = '/';
  {$ENDIF}
    class function CreateBinaryFile: IBinaryFile; static;
    class function CreateTextFile: ITextFile; static;
    class function FileExists_(filePath: TFilePath): Boolean;
    class function FolderExists(folderPath: TFolderPath): Boolean;
    class function NormalizePath(filePath: TFilePath): String;

  {$IFDEF SIMULATED_FILE_IO}
    class function GetFileMap: TFileMap;
  {$ENDIF}

  end;

implementation

{$IFDEF SIMULATED_FILE_IO}
var
  fileMap: TFileMap;
{$ENDIF}

type
  TFile = class(TInterfacedObject, IFile)
  protected
    filePath: TFilePath;
  public
  type TFileMode = (Read, Write);
    constructor Create;
    function GetFilePath(): String;
    function GetAbsoluteFilePath(): String;
    procedure Assign(filePath: TFilePath); virtual; abstract;
    procedure Close; virtual; abstract;
    procedure Erase(); virtual; abstract;
    function EOF(): Boolean; virtual; abstract;
    procedure Reset(); virtual; abstract;  // Open for reading
    procedure Rewrite(); virtual; abstract;  // Open for writing
  end;

type
  TTextFile = class(TFile, ITextFile)

{$IFNDEF SIMULATED_FILE_IO}
  private
  type TSystemTextFile = System.TextFile;
  private
    f: TSystemTextFile;
{$ELSE}
  private
    fileMapEntry: TFileMapEntry;
  private
    fileMode: TFileMode;
  private
    filePosition: TFilePosition;
{$ENDIF}
  public
    constructor Create;
    procedure Assign(filePath: TFilePath); override;
    procedure Close; override;
    procedure Erase(); override;
    function EOF(): Boolean; override;

    procedure Flush;
    // https://www.freepascal.org/docs-html/rtl/system/read.html
    procedure Read(var c: Char);
    procedure ReadLn(var s: String);
    procedure Reset(); override;
    procedure Rewrite(); override;

    function Write(s: String): ITextFile; overload;
    function Write(s: String; w: Integer): ITextFile; overload;
    function Write(i: Integer; w: Integer): ITextFile; overload;

    procedure WriteLn; overload;
    procedure WriteLn(s: String); overload;
    procedure WriteLn(s1: String; s2: String); overload;
    procedure WriteLn(s1: String; s2: String; s3: String); overload;
  end;

type
  TBinaryFile = class(TFile, IBinaryFile)
{$IFNDEF SIMULATED_FILE_IO}
  private
  type TSystemBinaryFile = file of Char;
  private
    f: TSystemBinaryFile;
{$ELSE}
private
  fileMapEntry: TFileMapEntry;
private
  fileMode: TFileMode;
private
  filePosition: TFilePosition;
{$ENDIF}
  public
    constructor Create;
    procedure Assign(filePath: TFilePath); override;
    // https://www.freepascal.org/docs-html/rtl/system/blockread.html
    procedure BlockRead(var Buf; Count: Longint; var Result: Longint);
    procedure Close; override;
    procedure Erase(); override;
    function EOF(): Boolean; override;
    // https://www.freepascal.org/docs-html/rtl/system/filepos.html
    function FilePos(): TInteger;
    procedure Read(var c: Char);
    procedure Reset(); override; overload;
    procedure Reset(l: Longint); overload;
    procedure Rewrite(); override;
    procedure Seek2(Pos: TInteger);

  end;

{$IFDEF SIMULATED_FILE_IO}
//  {$I 'include\SIMULATED_FILE_IO\FileIO-SIMULATED_FILE_IO-Implementation.inc'}
{$ENDIF}


constructor TPathList.Create;
begin
  paths := nil;
  SetLength(paths, 0);
end;

procedure TPathList.AddFolder(folderPath: TFolderPath);
var
  i, size: Integer;
begin

  folderPath := IncludeTrailingPathDelimiter(folderPath);
  folderPath := TFileSystem.NormalizePath(folderPath);

  // Do not add duplicates.
  for i := Low(paths) to High(paths) do
  begin
    if paths[i] = folderPath then exit;
  end;

  size := GetSize;
  Inc(size);
  SetLength(paths, size);
  paths[size - 1] := IncludeTrailingPathDelimiter(folderPath);
end;

function TPathList.FindFile(filePath: TFilePath): TFilePath;
var
  i: Integer;
begin
  Result := TFileSystem.NormalizePath(filePath);
  if TFileSystem.FileExists_(Result) then Exit;

  for i := Low(paths) to High(paths) do
  begin
    Result := TFileSystem.NormalizePath(paths[i] + filePath);
    if TFileSystem.FileExists_(Result) then Exit;
  end;
  Result := '';

end;

function TPathList.GetSize: Integer;
begin
  // If the argument is an array type or an array type variable then High returns
  // the highest possible value of it's index. For dynamic arrays, it returns the
  // ame as Length -1, meaning that it reports -1 for empty arrays.
  Result := High(paths) + 1;
end;

function TPathList.ToString: String;
var
  i: Integer;
begin
  Result := '';
  for i := Low(paths) to High(paths) do
  begin
    if Result = '' then Result := paths[i]
    else
      Result := Result + ';' + paths[i];
  end;
end;

// ----------------------------------------------------------------------------
// TFile
// ----------------------------------------------------------------------------

constructor TFile.Create;
begin
  filePath := '';
end;

function TFile.GetFilePath(): String;
begin
  Result := filePath;
end;

function TFile.GetAbsoluteFilePath(): String;
begin
  Result := ExpandFileName(filePath);
end;

// ----------------------------------------------------------------------------
// TTextFile
// ----------------------------------------------------------------------------

constructor TTextFile.Create;
begin
  inherited;
  {$IFDEF SIMULATED_FILE_IO}
  Close;
  {$ENDIF}
end;

procedure TTextFile.Assign(filePath: TFilePath);
begin
  Self.filePath := filePath;
{$IFNDEF SIMULATED_FILE_IO}
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TTextFile.Close();
begin
{$IFNDEF SIMULATED_FILE_IO}
  CloseFile(f);
{$ELSE}
  fileMapEntry := nil;
  fileMode := TFileMode.Read;
  filePosition := -1;
{$ENDIF}
end;

procedure TTextFile.Erase();
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Erase(f);
{$ELSE}
  FileIO.fileMap.RemoveEntry(filePath);
{$ENDIF}

end;

function TTextFile.EOF(): Boolean;
begin
{$IFNDEF SIMULATED_FILE_IO}
  Result := System.EOF(f);
{$ELSE}
  Result := (fileMapEntry.content.length = filePosition);
{$ENDIF}

end;


procedure TTextFile.Flush();
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Flush(f);
{$ENDIF}

end;

procedure TTextFile.Read(var c: Char);
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Read(f, c);
{$ELSE}
  Assert(fileMapEntry <> nil, 'File '''+filePath+''' has no file map entry assigned.');
  Assert(fileMode = TFileMode.Read, 'File '''+filePath+''' is not opened for reading.');
  if Eof then raise EInOutError.create('End of file '''+filePath+''' reached. Cannot read position '+IntToStr(filePosition)+'.');
  c := fileMapEntry.content[filePosition];
  Inc(filePosition);
{$ENDIF}

end;

procedure TTextFile.ReadLn(var s: String);
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.ReadLn(f, s);
{$ELSE}
  Assert(false, 'Not Implemented yet');
{$ENDIF}

end;

procedure TTextFile.Reset();
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.FileMode := 0;
  System.Reset(f);
{$ELSE}
  fileMapEntry := fileMap.GetEntry(filePath);
  fileMode := TFileMode.Read;
  filePosition := 0;
{$ENDIF}

end;

procedure TTextFile.Rewrite();
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.FileMode := 1;
  System.Rewrite(f);
{$ELSE}
  fileMapEntry := fileMap.GetEntry(filePath);
  if (fileMapEntry=nil) then
  begin
     fileMapEntry := fileMap.AddEntry(filePath, TFileMapEntry.TFileType.TextFile);
  end;
  fileMode := TFileMode.Write;
  filePosition := 0;
{$ENDIF}
end;

function TTextFile.Write(s: String): ITextFile;
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Write(f, s);
{$ELSE}
  Assert(fileMapEntry <> nil, 'File '''+filePath+''' has no file map entry assigned.');
  Assert(fileMode = TFileMode.Write, 'File '''+filePath+''' is not opened for writing.');
  fileMapEntry.content := fileMapEntry.content + s;
  filePosition := filePosition + length(s);
{$ENDIF}
  Result := Self;
end;

function TTextFile.Write(s: String; w: Integer): ITextFile;
var
  sFormatted: String;
begin
  // TODO: Implement width padding using w
  sFormatted := s;
  Write(sFormatted);
  Result := Self;
end;

function TTextFile.Write(i: Integer; w: Integer): ITextFile;
var
  sFormatted: String;
begin
  sFormatted := IntToStr(i);
  Write(sFormatted, w);
  Result := Self;
end;

procedure TTextFile.WriteLn();

begin
{$IFNDEF SIMULATED_FILE_IO}
  System.WriteLn(f, '');
{$ELSE}
  Write(LineEnding);
{$ENDIF}

end;

procedure TTextFile.WriteLn(s: String); overload;
begin
  Write(s);
  WriteLn;
end;


procedure TTextFile.WriteLn(s1: String; s2: String); overload;
begin
  Write(s1);
  Write(s2);
  WriteLn;

end;

procedure TTextFile.WriteLn(s1: String; s2: String; s3: String); overload;
begin
  Write(s1);
  Write(s2);
  Write(s3);
  WriteLn;

end;

// ----------------------------------------------------------------------------
// TBinaryFile
// ----------------------------------------------------------------------------

constructor TBinaryFile.Create;
begin
  inherited;
  {$IFDEF SIMULATED_FILE_IO}
  Close;
  {$ENDIF}
end;

procedure TBinaryFile.Assign(filePath: TFilePath);
begin
  Self.filePath := filePath;
{$IFNDEF SIMULATED_FILE_IO}
  AssignFile(f, filePath);
{$ELSE}
  Close;
{$ENDIF}
end;

procedure TBinaryFile.BlockRead(var Buf; Count: Longint; var Result: Longint);
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.BlockRead(f, Buf, Count, Result);
{$ELSE}
  Assert(False, 'Not implemented yet');
{$ENDIF}
end;

procedure TBinaryFile.Close();
begin
{$IFNDEF SIMULATED_FILE_IO}
  CloseFile(f);
{$ELSE}
  fileMapEntry :=nil;
  fileMode :=TFileMode.Read;
  filePosition := -1;
{$ENDIF}

end;

function TBinaryFile.EOF(): Boolean;
begin
{$IFNDEF SIMULATED_FILE_IO}
  Result := System.EOF(f);
{$ELSE}
  Result := (fileMapEntry.content.length = filePos);
{$ENDIF}
end;

procedure TBinaryFile.Erase();
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Erase(f);
{$ELSE}
  Assert(false, 'Not implemented yet.');
{$ENDIF}

end;

function TBinaryFile.FilePos(): TInteger;
begin
{$IFNDEF SIMULATED_FILE_IO}
  Result := System.FilePos(f);
{$ELSE}
  Result := filePosition;
{$ENDIF}
end;

procedure TBinaryFile.Read(var c: Char);
begin
{$IFNDEF SIMULATED_FILE_IO}

  System.Read(f, c);
{$ELSE}
  Assert(fileMapEntry <> nil, 'File '''+filePath+''' has no file map entry assigned.');
  Assert(fileMode = TFileMode.Read, 'File '''+filePath+''' is not opened for reading.');
  if Eof then raise EInOutError.create('End of file '''+filePath+''' reached. Cannot read position '+IntToStr(filePosition)+'.');
  c := fileMapEntry.content[filePosition+1];
  // Writeln('Reading character '''+c+''' ($'+IntToHex(ord(c),2)+') at file position '+IntToStr(filePosition)+' of '''+filePath+'''.');
  Inc(filePosition);
{$ENDIF}

end;


procedure TBinaryFile.Reset(); overload;
begin
  Reset(128);
end;

procedure TBinaryFile.Reset(l: Longint); overload;
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.FileMode := 0;
  System.Reset(f, l);
{$ELSE}
  if l <>1 then raise EInOutError.create('Unsupported record size '+IntToStr(l)+' specified. Only record size 1 is supported.');
  fileMapEntry := fileMap.GetEntry(filePath);
  fileMode := TFileMode.Read;
  filePosition := 0;
{$ENDIF}

end;

procedure TBinaryFile.Rewrite();
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Rewrite(f);
{$ELSE}
  fileMapEntry := fileMap.GetEntry(filePath);
  if (fileMapEntry=nil) then
  begin
    fileMapEntry := fileMap.AddEntry(filePath, TFileMapEntry.TFileType.BinaryFile);
  end;
  fileMode := TFileMode.Write;
  filePosition := 0;
{$ENDIF}

end;

procedure TBinaryFile.Seek2(Pos: TInteger);
begin
{$IFNDEF SIMULATED_FILE_IO}
  System.Seek(f, pos);
{$ELSE}
  filePosition:=Pos;
{$ENDIF}
end;


// ----------------------------------------------------------------------------
// TFileMap
// ----------------------------------------------------------------------------

constructor TFileMap.Create;
begin
  SetLength(entries, 0);
end;

function TFileMap.AddEntry(const filePath: TFilePath; const fileType: TFileMapEntry.TFileType): TFileMapEntry;
var
  entry: TFileMapEntry;
begin
  entry := GetEntry(filePath);
  Assert(entry = nil, 'Entry with file path ''' + filePath + ''' is already in the file map.');
  entry := TFileMapEntry.Create;
  entry.filePath := filePath;
  entry.fileType := fileType;
  SetLength(entries, Length(entries) + 1);
  entries[High(entries)] := entry;
  Result := entry;
end;

function TFileMap.GetEntry(const filePath: TFilePath): TFileMapEntry;
var
  i: Integer;
begin
  Result := nil;
  if (entries <> nil) then
  begin
    for i := Low(entries) to High(entries) do
    begin
      if entries[i].filePath = filePath then
      begin
        Result := entries[i];
        exit;
      end;
    end;
  end;
end;

procedure TFileMap.RemoveEntry(const filePath: TFilePath);
var
  i: Integer;
begin
  for i := Low(entries) to High(entries) do
  begin
    if entries[i].filePath = filePath then
    begin
      Delete(entries, i, 1);
      exit;
    end;
  end;
end;

// ----------------------------------------------------------------------------
// TFileSystem
// ----------------------------------------------------------------------------
class function TFileSystem.CreateBinaryFile: IBinaryFile;
begin
  Result := TBinaryFile.Create;
end;

class function TFileSystem.CreateTextFile: ITextFile;
begin
  Result := TTextFile.Create;
end;

class function TFileSystem.FileExists_(filePath: TFilePath): Boolean;
begin
  {$IFNDEF SIMULATED_FILE_IO}
  Result := FileExists(filePath);
  {$ELSE}
  Result := fileMap.GetEntry(filePath) <> nil;
  {$ENDIF}
end;

class function TFileSystem.FolderExists(folderPath: TFolderPath): Boolean;
begin
  {$IFNDEF SIMULATED_FILE_IO}
  Result := DirectoryExists(folderPath);
  {$ELSE}
  Result := fileMap.GetEntry(filePath) <> nil;
  {$ENDIF}
end;

class function TFileSystem.NormalizePath(filePath: TFilePath): TFilePath;
begin

  Result := filePath;

  // https://github.com/tebe6502/Mad-Pascal/issues/113
  {$IFDEF UNIX}
   if Pos('\', filePath) > 0 then
   begin
    Result := StringReplace(filePath, '\', '/', [rfReplaceAll]);
   end;
  {$ENDIF}

  {$IFDEF SIMULATED_FILE_IO}
   if Pos('\', filePath) > 0 then
   begin
    Result := StringReplace(filePath, '\', '/', [rfReplaceAll]);
   end;

  Result := LowerCase(Result);
  {$ENDIF}

end;

{$IFDEF SIMULATED_FILE_IO}

class function TFileSystem.GetFileMap:  TFileMap;
begin
  Result:=FileIO.fileMap;
end;

procedure InitializeFileMap;

var
  fileMapEntry: TFileMapEntry;
begin
  fileMap := TFileMap.Create;
  fileMapEntry:=fileMap.AddEntry('Input.pas', TFileMapEntry.TFileType.TextFile);
  fileMapEntry.content := 'Program TestProgram; begin end.';
  fileMapEntry:=fileMap.AddEntry('lib'+TFileSystem.PathDelim+'system.pas', TFileMapEntry.TFileType.TextFile);
  fileMapEntry.content :=
    'unit System;' + LineEnding  +
    'interface'     + LineEnding  +
    'const M_PI_2	= pi*2;' + LineEnding  +
    'implementation' + LineEnding  +
    'initialization' + LineEnding  +
    'end.';
  fileMapEntry := fileMap.AddEntry('lib', TFileMapEntry.TFileType.Folder);
  fileMapEntry.content := 'SubFolder1;SubFolder2';
  fileMapEntry := fileMap.AddEntry('Input.bin', TFileMapEntry.TFileType.BinaryFile);
  fileMapEntry.content := '01010110101';

end;

{$ENDIF}

initialization

{$IFDEF SIMULATED_FILE_IO}
  InitializeFileMap;
{$ENDIF}

end.
