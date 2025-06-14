program MakeMadPascal;

// Idea: https://wiki.freepascal.org/Parallel_procedures

{$I Defines.inc}
{$ScopedEnums ON}

uses
  Windows,
  Crt,
  Classes,
  Utilities,
  FileIO,
  Math,
  FileUtil,
  LazFileUtils,
  Process,
  MTProcs,
  SysUtils,
  CustApp;

const
  MAX_FILES = 10;

type
  TFileType = (UNKNOWN, TPROGRAM, TUNIT, TINCLUDE);

  TAction = (CLEANUP, COMPILE, CLEANUP_REFERENCE, COMPILE_REFERENCE, COMPARE);

  TStatus = (OK, ERROR);

  TFileResult = record
    filePath: TFilePath;
    status: TStatus;
    logMessages: TStringList;
  end;

  TFileResultArray = array of TFileResult;

  TOperation = class
    threads: Integer;
    action: TAction;
    verbose: Boolean;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;
    results: TFileResultArray;
    logMessages: TStringList;
    diffFilePaths: TStringList;

    constructor Create(action: TAction);
    destructor Free;
    function GetActionString(): String;
    function WriteLog(folderPath: TFolderPath): TFilePath;
  end;


  TOptions = record
    allFiles: Boolean;
    allThreads: Boolean;

    compileReference: Boolean;
    compile: Boolean;
    compare: Boolean;

    openResults: Boolean;
    waitForKey: Boolean;

    verbose: Boolean;
  end;

var
  options: TOptions;
  cs: TRTLCriticalSection;
  startTickCount: QWord;
  endTickCount: QWord;
  seconds: QWord;
  minutes: QWord;

  function AppendPath(basePath: TFolderPath; path1: String; path2: String = ''; path3: String = '';
    path4: String = ''): TFilePath;
  begin
    Result := CreateAbsolutePath(path1, basePath);
    if path2 <> '' then  Result := CreateAbsolutePath(path2, Result);
    if path3 <> '' then  Result := CreateAbsolutePath(path3, Result);
    if path4 <> '' then  Result := CreateAbsolutePath(path4, Result);
    Result := SetDirSeparators(Result);
  end;

  procedure Log(const message: String); overload;
  begin
    EnterCriticalSection(cs);
    WriteLn(message);
    LeaveCriticalSection(cs);
  end;

  procedure Log(var fileResult: TFileResult; const message: String); overload;
  begin
    if (fileResult.logMessages = nil) then
    begin
      fileResult.logMessages := TStringList.Create;

    end;
    if (message.StartsWith('ERROR:')) then fileResult.status := TStatus.ERROR;
    fileResult.logMessages.Add(message);
  end;

  constructor TOperation.Create(action: TAction);
  begin
    self.action := action;
    logMessages := TStringList.Create;
    diffFilePaths := TStringList.Create;
  end;

  destructor TOperation.Free;
  begin
    logMessages.Free;
    diffFilePaths.Free;
  end;


  function TOperation.GetActionString(): String;
  begin
    WriteStr(Result, action);
  end;

  function TOperation.WriteLog(folderPath: TFolderPath): TFilePath;
  var
    filePath: TFilePath;
  begin
    Result := '';
    filePath := AppendPath(folderPath, 'MakeMadPascal-' + GetActionString + '.log');
    if logMessages.Count = 0 then
    begin
      DeleteFile(filePath);
    end
    else
    begin

      try

        logMessages.SaveToFile(filePath);
        Result := filePath;
      except
        on e: EFCreateError do
        begin
          Log(Format('ERROR: Cannot save %s.', [filePath]));
        end;
      end;

    end;

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

  function RunExecutable(title: String; curDir: TFolderPath; exename: TProcessString;
    commands: array of TProcessString; var fileResult: TFileResult): Boolean;
  var
    outputString: TProcessString;
  begin
    if RunCommandIndir(curDir, exename, commands, outputString) then
    begin
      Result := True;
    end
    else
    begin
      Log(fileResult, format('ERROR: Cannot run "%s".', [title]));
      Log(fileResult, Format('ERROR: Command "%s %s" failed.', [cmdLine, CommandsToString(commands)]));
      Log(fileResult, Format('%s', [outputString]));
      Log(fileResult, '');
      Result := False;
    end;
  end;

  function RunMadPascal(const operation: TOperation; curDir: TFolderPath; fileName: String;
    a65FileName: String; var fileResult: TFileResult): Boolean;
  var
    exename: TProcessString;
    commands: array of TProcessString;
  begin
    exename := operation.mpExePath;
    commands := ['-ipath:' + CreateAbsolutePath('lib', operation.mpFolderPath), '-o:' + a65FileName, fileName];
    Result := RunExecutable(fileName, curDir, exename, commands, fileResult);
  end;

  function LoadTextFile(const filePath: TfilePath; stringList: TStringList; var fileResult: TFileResult): Boolean;
  begin
    Result := False;
    try
      if FileExists(filePath) then
      begin
        stringList.LoadFromFile(filePath);
        Result := True;
      end
      else
      begin
        Log(fileResult, Format('ERROR: File %s does not exist.', [filePath]));
      end;
    except
      on E: EFOpenError do
        Log(fileResult, Format('ERROR: File %s cannot be opened.', [filePath]));
    end;

  end;

  function CompareA65File(curDir: TFolderPath; a65FileName, a65ReferenceFileName: String;
    operation: TOperation; var fileResult: TFileResult): Boolean;
  const
    MAX_DIFFS = 5;
  var
    a65FilePath, a65ReferenceFilePath: TFilePath;
    Lines, ReferenceLines: TStringList;
    i, j, diffs: Integer;
    line, referenceLine: String;
    diffFileLines: TStringList;
    diffFilePath: TFilePath;
  begin
    Result := True;
    Lines := TStringList.Create;
    ReferenceLines := TStringList.Create;

    try

      a65FilePath :=
        CreateAbsolutePath(a65FileName, curDir);
      a65ReferenceFilePath := CreateAbsolutePath(a65ReferenceFileName, curDir);
      diffFilePath := ChangeFileExt(a65FilePath, '.WinMerge');

      if LoadTextFile(a65FilePath, Lines, fileResult) and LoadTextFile(
        a65ReferenceFilePath, ReferenceLines, fileResult) then
      else
      begin
        exit(False);
      end;

      if (Lines.Count < 3) then
      begin
        Log(fileResult, Format('ERROR: %s', [a65FilePath]));
        Log(fileResult, 'ERROR: Not enough lines in output.');
        EXIT(False);
      end;

      // Skip the first 2 lines with the compiler version output.
      diffs := 0;
      i := 3;
      j := 3;
      while (i <= Lines.Count) and (j <= ReferenceLines.Count) do
      begin
        // Find next non-empty line
        line := Lines[i - 1];
        // TODO: PMCNTL  = $D01D is temporary    // or (line = 'PMCNTL'#9'= $D01D')
        while (i < Lines.Count) and ((line = '')) do
        begin
          Inc(i);
          line := Lines[i - 1];
        end;

        // Find next non-empty line
        referenceLine := ReferenceLines[j - 1];
        while (j < ReferenceLines.Count) and (referenceLine = '') do
        begin
          Inc(j);
          referenceLine := ReferenceLines[j - 1];
        end;

        if (line <> referenceLine) then
        begin
          if Result then
          begin

            Result := False;
            Log(fileResult, Format('ERROR: %s', [diffFilePath]));
          end;

          Log(fileResult, Format('%d: %-40s %-40s ', [i, LeftStr(line, 40), LeftStr(referenceLine, 40)]));
          Inc(diffs);

          if (diffs > MAX_DIFFS) then break;
        end;
        Inc(i);
        Inc(j);
      end;

    finally
      if Result then
      begin
        DeleteFile(diffFilePath);
      end
      else
      begin
        diffFileLines := TStringList.Create;

        diffFileLines.add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
        diffFileLines.add('<project>');
        diffFileLines.add('   <paths>');
        diffFileLines.add(Format('      <left>%s</left>', [a65FilePath]));
        diffFileLines.add(Format('      <right>%s</right>', [a65ReferenceFilePath]));
        diffFileLines.add('      <filter>*.*</filter>');
        diffFileLines.add('      <subfolders>0</subfolders>');
        diffFileLines.add('      <left-readonly>0</left-readonly>');
        diffFileLines.add('      <right-readonly>0</right-readonly>');
        diffFileLines.add('   </paths>');
        diffFileLines.add('</project>');
        diffFileLines.SaveToFile(diffFilePath);
        diffFileLines.Free;
        operation.diffFilePaths.Add(diffFilePath);

      end;
      ReferenceLines.Free;
      Lines.Free;
    end;

  end;

  function ProcessProgram(const FilePath: TFilePath; var operation: TOperation; var fileResult: TFileResult): Boolean;
  var
    curDir: TFolderPath;
    fileName: String;
    a65BaseFileName: String;
    a65FileName: String;
    a65ReferenceFileName: String;
  begin
    fileResult.filePath := filePath;
    fileResult.status := TStatus.OK;
    Result := False;

    if (operation.verbose) then
    begin
      Log(Format('Processing program %s with action %s and MP path %s.',
        [filePath, operation.GetActionString(), operation.mpExePath]));
    end;

    curDir := ExtractFilePath(FilePath);
    fileName := ExtractFileName(FilePath);
    a65BaseFileName := ChangeFileExt(fileName, '');
    a65FileName := a65BaseFileName + '.a65';
    a65ReferenceFileName := a65BaseFileName + '-Reference.a65';

    case operation.action
      of
      TAction.COMPILE:

      begin
        Result := RunMadPascal(operation, curDir, fileName, a65FileName, fileResult);
      end;

      TAction.COMPILE_REFERENCE:
      begin
        Result := RunMadPascal(operation, curDir, fileName, a65ReferenceFileName, fileResult);
      end;

      TAction.COMPARE:
      begin
        Result := CompareA65File(curDir, a65FileName, a65ReferenceFileName, operation, fileResult);

      end;
      else
        Assert(False, 'Unsupported action ' + operation.GetActionString());
    end;

  end;


  function ProcessProgramAtIndex(const ProgramFiles: TStringList; const index: Integer;
  var operation: TOperation): Boolean;
  begin
    Log(Format('Processing program %d of %d (%d%%) with action %s: %s',
      [index, ProgramFiles.Count, Trunc(index * 100 / ProgramFiles.Count), Operation.GetActionString(),
      ExtractFileName(ProgramFiles[index - 1])]));
    Result := ProcessProgram(ProgramFiles[index - 1], operation, operation.results[index - 1]);
  end;

type
  TParallelData = record
    ProgramFiles: TStringList;
    operation: TOperation;
    fileResults: TFileResultArray;
    errorOccurred: Boolean;
  end;

  procedure ProcessProgramParallel(Index: PtrInt; Data: Pointer; Item: TMultiThreadProcItem);
  var
    parallelData: ^TParallelData;
  begin
    parallelData := Data;
    // if not parallelData.errorOccurred then
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
    parallelData: TParallelData;
    operationLog: TStringList;
  begin
    SetLength(operation.results, ProgramFiles.Count);

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

    // Create / delete operation log file
    for i := Low(operation.results) to High(operation.results) do
    begin
      case operation.results[i].status of
        TStatus.ERROR:
        begin
          operation.logMessages.Add(Format('ERROR: Errors while processing %s', [operation.results[i].filePath]));
           operation.logMessages.AddStrings(operation.results[i].logMessages);
        end;
      end;
    end;
  end;

  procedure GetNextParam(var i: Integer; var Value: String);
  begin
    Inc(i);
    if i <= ParamCount then Value := ParamStr(i)
    else
      Value := '';
  end;

  procedure Main;
  {$IFDEF Windows}
       const MP_BIN_FOLDER = 'windows';
       const MP_EXE = 'mp.exe';
  {$ELSE}
  const
    MP_BIN_FOLDER = 'macosx_aarch64';
  const
    MP_EXE = 'mp';
  {$ENDIF}
  var
    // application: TCustomApplication;
    maxFiles: Integer;
    p: String;
    i: Integer;
    operation: TOperation;
    operationResultFilePath: TFilePath;

    referenceMPFolderPath: TFolderPath;
    referenceMPExePath: TFilePath;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;

    threads: Integer;

    PascalFiles: TStringList;
    inputFolderPath: TFolderPath;
    inputFilePattern: String;
    filePath: TFilePath;
    fileType: TFileType;
    ProgramFiles: TStringList;
    fileResult: TFileResult;

    x: Integer;
  begin

    referenceMPFolderPath := '';
    referenceMPExePath := '';
    mpFolderPath := '';
    mpExePath := '';
    inputFolderPath := '';
    inputFilePattern := '';
    i := 1;
    while i <= ParamCount do
    begin
      p := ParamStr(i);
      if p = '-referenceMPFolderPath' then GetNextParam(i, referenceMPFolderPath);
      if p = '-referenceMPExePath' then GetNextParam(i, referenceMPExePath);
      if p = '-mpFolderPath' then GetNextParam(i, mpFolderPath);
      if p = '-mpExePath' then GetNextParam(i, mpExePath);
      if p = '-inputFolderPath' then GetNextParam(i, inputFolderPath);
      if p = '-inputFilePattern' then GetNextParam(i, inputFilePattern);
      if p = '-allFiles' then options.allFiles := True;
      if p = '-allThreads' then options.allThreads := True;
      if p = '-openResults' then options.openResults := True;
      if p = '-waitForKey' then options.waitForKey := True;
      if p = '-compileReference' then options.compileReference := True;
      if p = '-compile' then options.compile := True;
      if p = '-compare' then options.compare := True;
      if p = '-verbose' then options.verbose := True;
      Inc(i);
      // application:=  TCustomApplication.Create;
      // Application.Initialize;
      // Application.Run;
    end;



    // Use defaults, if not parameters were specified.
    if mpFolderPath = '' then mpFolderPath := ExtractFileDir(ExtractFileDir(ParamStr(0)));
    if mpExePath = '' then mpExePath := AppendPath(mpFolderPath, 'src', MP_EXE);

    if referenceMPFolderPath = '' then  referenceMPFolderPath := mpFolderPath + '-origin';
    if referenceMPExePath = '' then referenceMPExePath :=
        AppendPath(referenceMPFolderPath, 'bin', MP_BIN_FOLDER, MP_EXE);
    if inputFolderPath = '' then  inputFolderPath := AppendPath(mpFolderPath, 'samples');

    Log(Format('Reference MP Folder Path: %s', [referenceMPFolderPath]));
    Log(Format('Reference MP Exe Path   : %s', [referenceMPExePath]));

    Log(Format('MP Folder Path          : %s', [mpFolderPath]));
    Log(Format('MP Exe Path             : %s', [mpExePath]));


    Log(Format('Input Folder Path       : %s', [inputFolderPath]));
    Log(Format('Input File Pattern      : %s', [inputFilePattern]));

    Log(Format('Scanning input folder %s for Pascal source files.', [inputFolderPath]));
    PascalFiles := FindAllFiles(inputFolderPath, '*.pas', True);
    ProgramFiles := TStringList.Create;
    try

      maxFiles := MAX_FILES;
      if (options.allFiles) then maxFiles := High(Integer);
      if maxFiles > PascalFiles.Count then  maxFiles := PascalFiles.Count;

      Log(Format('Scanning %d Pascal source files for programs.', [PascalFiles.Count]));
      for i := 1 to PascalFiles.Count do
      begin
        filePath := PascalFiles[i - 1];
        if inputFilePattern <> '' then
        begin
          x := filePath.IndexOf(inputFilePattern);
          if x < 0 then Continue;
        end;
        // Log(Format('Scanning file %s (%d of %d)', [filePath, i, maxFiles]));
        fileType := GetFileType(filePath);
        case fileType
          of
          TFileType.UNKNOWN:
          begin
            if (options.verbose) then
            begin
              Log(Format('WARNING: Skipping file %s with unkown file type.', [filePath]));
            end;
          end;
          TFileType.TPROGRAM: begin
            ProgramFiles.Add(filePath);
            if ProgramFiles.Count >= maxFiles then break;
          end;
        end;
      end;



      if (options.AllThreads) then
      begin
        threads := TThread.ProcessorCount - 1;
      end
      else
      begin
        threads := 1;
      end;

      Log(Format('Processing %d Pascal programs with %d Threads.', [ProgramFiles.Count, threads]));
      if (options.compileReference) then
      begin
        operation := TOperation.Create(TAction.COMPILE_REFERENCE);
        operation.threads := threads;
        operation.verbose := options.verbose;
        operation.mpFolderPath := referenceMPFolderPath;
        operation.mpExePath := referenceMPExePath;
        ProcessPrograms(ProgramFiles, operation);
        operation.WriteLog(inputFolderPath);
        operation.Free;
      end;

      if (options.compile) then
      begin
        operation := TOperation.Create(TAction.COMPILE);
        operation.threads := threads;
        operation.verbose := options.verbose;
        operation.mpFolderPath := mpFolderPath;
        operation.mpExePath := mpExePath;
        ProcessPrograms(ProgramFiles, operation);
        operation.WriteLog(inputFolderPath);
        operation.Free;

      end;


      if (options.compare) then
      begin
        operation := TOperation.Create(TAction.COMPARE);
        operation.threads := 1;
        operation.verbose := options.verbose;
        operation.mpFolderPath := '';
        operation.mpExePath := '';

        ProcessPrograms(ProgramFiles, operation);

        if (operation.diffFilePaths.Count = 0) then
        begin
          Log('All generated .A65 files are identical.');
        end
        else
        begin
          operation.logMessages.Add(Format('Found %d different files.', [operation.diffFilePaths.Count]));
          operation.logMessages.AddStrings(operation.diffFilePaths);
        end;

        operationResultFilePath := operation.WriteLog(inputFolderPath);

        if (options.openResults and (operationResultFilePath <> '')) then
        begin
          fileResult := Default(TFileResult);
          fileResult.filePath := 'All';
          RunExecutable('Result File', '', 'CMD.EXE', ['/C', operationResultFilePath], fileResult);
          if operation.diffFilePaths.Count > 0 then
          begin
            RunExecutable('WinMerge', '', 'CMD.EXE', ['/C', operation.diffFilePaths[0]], fileResult);
          end;
        end;

        operation.Free;

      end;

    finally
      ProgramFiles.Free;
      PascalFiles.Free;

    end;
  end;

begin
  {$IFDEF WINDOWS}
   if Windows.GetFileType(Windows.GetStdHandle(STD_OUTPUT_HANDLE)) = Windows.FILE_TYPE_PIPE then
   begin
    System.Assign(Output, ''); FileMode:=1; System.Rewrite(Output);
   end;
  {$ENDIF}

  options := Default(TOptions);
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
  minutes := Trunc(seconds / 60);
  seconds := seconds - minutes * 60;
  Log(Format('Main completed after %d minutes, %d seconds.', [minutes, seconds]));
  if (options.waitForKey) then
  begin
    Log('Press any key.');
    repeat
    until keypressed;
  end;
  DoneCriticalSection(cs);
end.
