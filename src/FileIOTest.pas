// Working directory must be the project directory

unit FileIOTest;

{$I Defines.inc}


interface

procedure Test;

implementation

uses
  Assembler,
  Asserts,
  FileIO,
  SysUtils,
  UnitTests;

procedure Test;

  procedure TestNativeIO(filePath: TFilePath);
  var
    f: TextFile;
    s: String;
  begin
    StartTest('TestFileNativeIO');

    AssignFile(f, filePath);

    try
      reset(f); // Open the file for reading
      readln(f, s);
      writeln('First line of text read from file: ', s)

    finally
      CloseFile(f);
    end;
    EndTest('TestFileNativeIO');
  end;

  procedure TestFileIO(filePath: TFilePath);
  var
    binFile: IBinaryFile;
    cachedBinFile: IBinaryFile;
  var
    c1, c2: Char;
  begin

    binFile := TFileSystem.CreateBinaryFile(False);
    binFile.Assign(filePath);

    cachedBinFile := TFileSystem.CreateBinaryFile(True);
    cachedBinFile.Assign(filePath);
    try
      binFile.Reset(1);
      cachedBinFile.Reset(1);

      AssertEquals(binFile.GetFileSize, cachedBinFile.GetFileSize);
      while not binFile.EOF do
      begin
        if cachedBinFile.EOF then FailTest('End of cached file reached.');
        c1 := ' ';
        binFile.Read(c1);
        // Write(c1); // Uncomment to verify output on screen

        c2 := ' ';
        cachedBinFile.Read(c2);
        if (c1 <> c2) then FailTest('Read "' + c2 + '" from cached file instead of "' + c1 + '".');

        // WriteLn(IntToStr(Ord(c)));
      end;
      if not cachedBinFile.EOF then FailTest('End of cached file not reached.');

      binFile.Close;
      cachedBinFile.Close;
    except
      FailTest('Failed with Exception.');

    end;

  end;

const
  TEST_MP_FILE_PATH = '..' + DirectorySeparator + 'src' + DirectorySeparator + 'tests' +
    DirectorySeparator + 'TestMP.pas';
var
  pathList: TPathList;
begin
  StartTest('TestUnitFileIO');
  TestNativeIO(TEST_MP_FILE_PATH);
  TestFileIO(TEST_MP_FILE_PATH);

  pathList := TPathList.Create;
  pathList.AddFolder('Folder1');
  pathList.AddFolder('Folder2');
  pathList.AddFolder('Folder2' + TFileSystem.PathDelim);
  Assert(pathList.GetSize() = 2);
  Assert(pathList.ToString() = 'Folder1' + TFileSystem.PathDelim + ';Folder2' + TFileSystem.PathDelim);
  pathList.Free;

  AssertEquals(SysUtils.ExtractFileName(''), '');
  AssertEquals(SysUtils.ExtractFileName('ABC.'), 'ABC.');
  AssertEquals(SysUtils.ExtractFileName('ABC.xyz'), 'ABC.xyz');
  AssertEquals(SysUtils.ExtractFileName('/a/b/ABC.xyz'), 'ABC.xyz');
  AssertEquals(SysUtils.ExtractFileName('\a\b\ABC.xyz'), 'ABC.xyz');
  AssertEquals(SysUtils.ExtractFileName('\a\b\c/d/ABC.xyz'), 'ABC.xyz');

  EndTest('TestUnitFileIO');
end;

end.
