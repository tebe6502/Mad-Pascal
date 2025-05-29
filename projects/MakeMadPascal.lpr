program MakeMadPascal;

// Idea: https://wiki.freepascal.org/Parallel_procedures

{$I Defines.inc}
{$ScopedEnums ON}

uses
  Crt,
  Classes,
  Utilities,
  FileIO,
  Math,
  FileUtil,
  LazFileUtils,
  Process,
  MTProcs,
  SysUtils;

type
  TFileType = (UNKNOWN, TPROGRAM, TUNIT, TINCLUDE);

  TAction = (CLEANUP, COMPILE, COMPILE_AND_COMPARE, CLEANUP_REFERENCE, COMPILE_REFERENCE, COMPARE);

  TOperation = record
    threads: Integer;
    action: TAction;
    verbose: Boolean;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;
  end;


var
  cs: TRTLCriticalSection;
  startTickCount: QWord;
  endTickCount: QWord;
  seconds: QWord;

  procedure Log(const message: String);
  begin
    EnterCriticalSection(cs);
    WriteLn(message);
    LeaveCriticalSection(cs);
  end;

  function GetFileType(FilePath: TFilePath): TFileType;

  var
    fileType: TFileType;
    pasFile: TextFile;
    Line: String;
  begin
    AssignFile(pasFile, FilePath);
    Reset(pasFile);
    fileType := TFileType.UNKNOWN;
    while (fileType = TFileType.UNKNOWN) and not EOF(pasFile) do
    begin
      ReadLn(pasFile, Line);
      Line := UpperCase(line);
      if (Pos('PROGRAM ', line) > 0) or (Pos('USES ', line) > 0) then
      begin
        fileType := TFileType.TPROGRAM;
      end;
      if (Pos('UNIT ', line) > 0) then
      begin
        fileType := TFileType.TUNIT;
      end;
      if (Pos('PROCEDURE ', line) > 0) or (Pos('FUNCTION ', line) > 0) then
      begin
        fileType := TFileType.TINCLUDE;
      end;
      //Log(line);

    end;
    CloseFile(pasFile);
    Result := FileType;
  end;


  function CommandsToString(commands: array of TProcessString): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(commands) do
    begin
      if i > 1 then Result := Result + ' ';
      Result := Result + commands[i - 1];
    end;
  end;

  function GetActionString(const operation: TOperation): String;
  begin
    WriteStr(Result, operation.action);
  end;



  function RunExecutable(title: String; curDir: TFolderPath; exename: TProcessString;
    commands: array of TProcessString): Boolean;
  var
    outputString: TProcessString;
  begin
    if RunCommandIndir(curDir, exename, commands, outputString) then
    begin
      Result := True;
    end
    else
    begin
      Log(Format('ERROR: Cannot compile "%s".', [title]));
      Log(Format('ERROR: Command "%s %s" failed.', [cmdLine, CommandsToString(commands)]));
      Log(Format('%s', [outputString]));
      Log('');
      Result := False;
    end;
  end;

  function RunMadPascal(const operation: TOperation; curDir: TFolderPath; fileName: String;
    a65FileName: String): Boolean;
  var
    exename: TProcessString;
    commands: array of TProcessString;
  begin
    exename := operation.mpExePath;
    commands := ['-ipath:' + CreateAbsolutePath('lib', operation.mpFolderPath), '-o:' + a65FileName, fileName];
    Result := RunExecutable(fileName, curDir, exename, commands);
  end;

  function ProcessProgram(const FilePath: TFilePath; const operation: TOperation): Boolean;
  var
    curDir: TFolderPath;
    fileName: String;
    a65FileName: String;

  begin
    if (operation.verbose) then
    begin
      Log(Format('Processing program %s with action %s and MP path %s.', [filePath,
        GetActionString(operation), operation.mpExePath]));
    end;

    curDir := ExtractFilePath(FilePath);
    fileName := ExtractFileName(FilePath);
    a65FileName := ChangeFileExt(fileName, '');
    case operation.action
      of
      TAction.COMPILE:
      begin
      end;

      TAction.COMPILE_AND_COMPARE:
      begin
      end;

      TAction.COMPILE_REFERENCE:
      begin
        a65FileName := a65FileName + '-Reference';
      end;

      TAction.COMPARE:
      begin
        exit(false);
        Assert(False, 'Unsupported action ' + GetActionString(operation));
      end;
      else
        Assert(False, 'Unsupported action ' + GetActionString(operation));
    end;
    a65FileName := a65FileName + '.a65';
    result:=RunMadPascal(operation, curDir, fileName, a65FileName);

  end;


  function ProcessProgramAtIndex(const ProgramFiles: TStringList; const index: Integer;
  const operation: TOperation): Boolean;
  begin
    Log(Format('Processing program %d of %d (%d%%) with action %s: %s',
      [index, ProgramFiles.Count, Trunc(index * 100 / ProgramFiles.Count), GetActionString(Operation),
      ExtractFileName(ProgramFiles[index - 1])]));
    Result := ProcessProgram(ProgramFiles[index - 1], operation);
  end;

type
  TParalelData = record
    ProgramFiles: TStringList;
    operation: TOperation;
    errorOccurred: Boolean;
  end;

  procedure ProcessProgramParallel(Index: PtrInt; Data: Pointer; Item: TMultiThreadProcItem);
  var
    parallelData: ^TParalelData;
  begin
    parallelData := Data;
    if not parallelData.errorOccurred then
    begin
      if not ProcessProgramAtIndex(parallelData^.ProgramFiles, Index, parallelData^.operation) then
      begin
        parallelData.errorOccurred := True;
      end;
    end;
  end;




  procedure ProcessPrograms(ProgramFiles: TStringList; operation: TOperation);
  var
    i: Integer;
    parallelData: TParalelData;
  begin
    if operation.threads = 1 then
    begin
      for i := 1 to ProgramFiles.Count do
      begin
        ProcessProgramAtIndex(ProgramFiles, i, operation);
      end;
    end
    else
    begin
      parallelData.ProgramFiles := ProgramFiles;
      parallelData.operation := operation;
      parallelData.errorOccurred := False;
      // address, startindex, endindex, optional data, numberOfThreads
      ProcThreadPool.DoParallel(@ProcessProgramParallel, 1, ProgramFiles.Count, Addr(parallelData), operation.threads);

    end;

  end;

  procedure Main;
  var
    verbose: Boolean;
    maxFiles: Integer;
    i: Integer;
    PascalFiles: TStringList;
    samplesFolderPath: TFolderPath;
    filePath: TFilePath;
    fileType: TFileType;
    ProgramFiles: TStringList;
    operation: TOperation;
    wudsnFolderPath: TFolderPath;
    referenceMPFolderPath: TFolderPath;
    referenceMPExePath: TFilePath;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;
  begin
    verbose := False;

    wudsnFolderPath := GetEnvironmentVariable('WUDSN_TOOLS_FOLDER');
    referenceMPFolderPath := CreateAbsolutePath('PAS\MP', wudsnFolderPath);
    referenceMPExePath := CreateAbsolutePath('bin\windows\mp.exe', referenceMPFolderPath);
    mpFolderPath := 'C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal';
    mpExePath := CreateAbsolutePath('src\mp.exe', mpFolderPath);
    samplesFolderPath := CreateAbsolutePath('samples', mpFolderPath);
    Log(Format('Scanning folder %s for Pascal source files.', [samplesFolderPath]));
    PascalFiles := FindAllFiles(samplesFolderPath, '*.pas', True);
    ProgramFiles := TStringList.Create;
    try
      maxFiles := High(Integer);
      maxFiles := 10;
      if maxFiles > PascalFiles.Count then  maxFiles := PascalFiles.Count;
      Log(Format('Scanning %d of %d Pascal source files for programs.', [maxFiles, PascalFiles.Count]));
      for i := 1 to maxFiles do
      begin
        filePath := PascalFiles[i - 1];
        // Log(Format('Scanning file %s (%d of %d)', [filePath, i, maxFiles]));
        fileType := GetFileType(filePath);
        case fileType
          of
          TFileType.UNKNOWN:
          begin
            if (verbose) then
            begin
              Log(Format('WARNING: Skipping file %s with unkown file type.', [filePath]));
            end;
          end;
          TFileType.TPROGRAM: begin
            ProgramFiles.Add(filePath);
          end;
        end;
      end;
      operation.threads := TThread.ProcessorCount - 1;
      Log(Format('Processing %d Pascal program with %d Threads.', [ProgramFiles.Count, operation.threads]));
      operation.action := TAction.COMPILE_REFERENCE;
      operation.verbose := verbose;
      operation.mpFolderPath := referenceMPFolderPath;
      operation.mpExePath := referenceMPExePath;
      ProcessPrograms(ProgramFiles, operation);

      operation.action := TAction.COMPILE;
      operation.verbose := verbose;
      operation.mpFolderPath := mpFolderPath;
      operation.mpExePath := mpExePath;
      ProcessPrograms(ProgramFiles, operation);

      operation.action := TAction.COMPARE;
      operation.verbose := verbose;
      operation.mpFolderPath := '';
      operation.mpExePath := '';
      ProcessPrograms(ProgramFiles, operation);

    finally
      ProgramFiles.Free;
      PascalFiles.Free;
    end;
  end;

begin
  InitCriticalSection(cs);
  startTickCount := GetTickCount64;
  try
    Main;
  except
    on e: Exception do
    begin
      ShowException(e, ExceptAddr);
    end;
  end;
  endTickCount := GetTickCount64;
  seconds := trunc((endTickCount - startTickCount) / 1000);
  Log(Format('Main completed after %d seconds. Press any key.', [seconds]));
  repeat
  until keypressed;
  DoneCriticalSection(cs);
end.
