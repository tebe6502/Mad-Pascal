program TestUnits;

{$i define.inc}

uses
  Console,
  Common,
  FileIO,
  Scanner,
  Utilities {$IFDEF PAS2JS}
     ,browserconsole
 {$ENDIF};

  procedure StartTest(Name: String);
  begin
    WriteLn('Unit Test ' + Name + ' started.');
  end;

  procedure FailTest(msg: String);
  begin
    WriteLn('ERROR: ' + msg);
  end;


  procedure EndTest(Name: String);
  begin
    WriteLn('Unit Test ' + Name + ' ended.');
  end;


  procedure TestNative(filePath: TFilePath);
  var
    f: TextFile;
    s: String;
  begin
    StartTest('TestFileNative');

    AssignFile(f, filePath);

    try
      reset(f); // Open the file for reading
      readln(f, s);
      writeln('Text read from file: ', s)

    finally
      CloseFile(f);
    end;
    EndTest('TestFileNative');
  end;

  procedure TestFileIO(filePath: TFilePath);
  var
    binFile: IBinaryFile;
  var
    c: Char;
  begin
    StartTest('TestFileIO');

    binFile := TFileSystem.CreateBinaryFile;
    binFile.Assign(filePath);
    try
      binFile.Reset;

      while not binFile.EOF do
      begin
        c := ' ';
        binFile.Read(c);
        Write(c);
        // WriteLn(IntToStr(Ord(c)));
      end;
      //      binFile.Read(c);
      binFile.Close;
    except
      FailTest('Failed with Exception.');

    end;
    EndTest('TestFileIO');
  end;

  procedure TestUnitFile;
  const
    TEST_MP_FILE_PATH = 'Test-MP.pas';
  var
    pathList: TPathList;

  begin
    StartTest('TestUnitFile');
    TestNative(TEST_MP_FILE_PATH);
    TestFileIO(TEST_MP_FILE_PATH);

    pathList := TPathList.Create;
    pathList.AddFolder('Folder1');
    pathList.AddFolder('Folder2');
    pathList.AddFolder('Folder2'+TFileSystem.PathDelim);
    Assert(pathList.GetSize() = 2);
    Assert(pathList.ToString() = 'Folder1'+TFileSystem.PathDelim +';Folder2'+TFileSystem.PathDelim );
    pathList.Free;

    EndTest('TestUnitFile');
  end;

  procedure TestUnitCommon;
  var
    filePath: String;
  begin
    ;
    StartTest('TestUnitCommon');

(* Until next pull request
    // Unit Scanner
    Program_NAME := 'TestProgram';
    NumTok := 0;
    // Kind, UnitIndex, Line, Column, Value
    AddToken(PROGRAMTOK, 1, 1, 1, 0);

    // Unit Common
    unitPathList:=TPathList.Create;
    unitPathList.AddFolder('libnone');
    filePath := '';
    try
      filePath := FindFile('TestUnit', 'unit');
    except
      on  ex: THaltException do
      begin
        Assert(ex.GetExitCode = THaltException.COMPILING_ABORTED);
      end;
    end;
    Assert(filePath <> '', 'Non-existing TestUnit found');
*)
    EndTest('TestUnitCommon');
  end;


begin
  TestUnitFile;
  TestUnitCommon;

  Writeln('Main completed.');
end.