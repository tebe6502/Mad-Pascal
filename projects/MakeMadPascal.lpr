program MakeMadPascal;

// Idea: https://wiki.freepascal.org/Parallel_procedures


{$I Defines.inc}
{$ScopedEnums ON}

uses
  {$IFDEF DARWIN}

  {$ENDIF}{$IFDEF WINDOWS}
  Windows,
  {$ENDIF}{$IFDEF UNIX}
  cthreads, cmem,
  {$ENDIF}
  Crt,
  Classes,
  Utilities,
  FileIO,
  Math,
  FileUtil,
  LazFileUtils,
  Process,
  MTProcs,
  strutils,
  SysUtils,
  CustApp;

const
  MAX_FILES = 10;

type
  TFileType = (UNKNOWN, ERROR, TPROGRAM, TUNIT, TINCLUDE);

  TFileInfo = class
    filePath: TFilePath;
    fileType: TFileType;
    requiredLibraryFolders: TStringList;

    constructor Create(filePath: TfilePath);
    destructor Free;
  end;

  TAction = (CLEANUP, COMPILE, CLEANUP_REFERENCE, COMPILE_REFERENCE,
    COMPARE, CLEANUP_RESULTS);

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

    ReferenceMPFolderPath: TFolderPath;
    ReferenceMPExePath: TFilePath;

    results: TFileResultArray;
    logMessages: TStringList;
    diffFilePaths: TStringList;
    class function GetActionString(const action: TAction): String; overload;
    class function GetLogFilePath(const folderPath: TFolderPath; const action: TAction): TFilePath; overload;

    constructor Create(const action: TAction);
    destructor Free;
    function GetActionString(): String; overload;
    function GetLogFilePath(const folderPath: TFolderPath): TFilePath; overload;
    function WriteLog(const folderPath: TFolderPath): Boolean;
  end;


  TOptions = record
    allFiles: Boolean;
    allThreads: Boolean;

    cleanup: Boolean;
    compile: Boolean;

    cleanupReference: Boolean;
    compileReference: Boolean;

    compare: Boolean;

    openResults: Boolean;
    cleanupResults: Boolean;

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

  procedure MakeAbsolutePath(var filePath: TFilePath);
  begin
    if filePath <> '' then filePath := ExpandFileName(filePath);
  end;

  procedure Log(const message: String); overload;
  begin
    EnterCriticalSection(cs);
    WriteLn(stdout, message);
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


  constructor TFileInfo.Create(filePath: TFilePath);
  begin
    self.filePath := filePath;
    fileType := TFileType.Unknown;
    requiredLibraryFolders := TStringList.Create;
  end;

  destructor TFileInfo.Free;
  begin
    requiredLibraryFolders.Free;
    requiredLibraryFolders := nil;
  end;

  class function TOperation.GetActionString(const action: TAction): String; overload;
  begin
    WriteStr(Result, action);
  end;

  class function TOperation.GetLogFilePath(const folderPath: TFolderPath; const action: TAction): TFilePath;
  begin
    Result := AppendPath(folderPath, 'MakeMadPascal-' + GetActionString(action) + '.log');
  end;

  constructor TOperation.Create(const action: TAction);
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


  function TOperation.GetActionString(): String; overload;
  begin
    WriteStr(Result, action);
  end;

  function TOperation.GetLogFilePath(const folderPath: TFolderPath): TFilePath;
  begin
    Result := GetLogFilePath(folderPath, action);
  end;

  function TOperation.WriteLog(const folderPath: TFolderPath): Boolean;
  var
    filePath: TFilePath;
  begin
    Result := False;
    filePath := GetLogFilePath(folderPath);
    if logMessages.Count = 0 then
    begin
      if FileExists(filePath) then
      begin
        DeleteFile(filePath);
      end;
    end
    else
    begin

      try

        logMessages.SaveToFile(filePath);
        Result := True;
      except
        on e: EFCreateError do
        begin
          Log(Format('ERROR: Cannot save %s.', [filePath]));
        end;
      end;

    end;

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

  // Parameter for line "line" must be uppercase.
  // Parameter for line "lib" must be lowercase
  procedure CheckForLibrary(const line: String; lib: String; var fileInfo: TFileInfo);
  begin
    // {$librarypath 'blibs'}
    if pos('{$LIBRARYPATH ''' + UpperCase(lib) + '''', line) > 0 then
    begin
      fileInfo.requiredLibraryFolders.Add(lib);
    end;
  end;

  function GetFileInfo(FilePath: TFilePath): TFileInfo;
  var
    pasFile: TextFile;
    done: Boolean;
    line: String;
  begin

    try
      AssignFile(pasFile, FilePath);
      Reset(pasFile);
      Result := TFileInfo.Create(filePath);

      done := False;
      while not done and not EOF(pasFile) do
      begin
        ReadLn(pasFile, line);
        line := UpperCase(line);
        CheckForLibrary(line, 'blibs', Result);
        CheckForLibrary(line, 'dlibs', Result);
        if (Result.fileType = TFileType.UNKNOWN) and (Pos('PROGRAM ', line) > 0) then
        begin
          Result.fileType := TFileType.TPROGRAM;
        end;
        if (Result.fileType = TFileType.UNKNOWN) and (Pos('UNIT ', line) > 0) then
        begin
          Result.fileType := TFileType.TUNIT;
        end;

        if Result.fileType = TFileType.UNKNOWN then
        begin
          if (Pos('USES ', line) > 0) then
          begin

            begin
              Result.fileType := TFileType.TPROGRAM;
            end;
            done := True;
          end;
          if (Pos('PROCEDURE ', line) > 0) or (Pos('FUNCTION ', line) > 0) then
          begin
            Result.fileType := TFileType.TINCLUDE;
            done := True;
          end;
        end;

        if (Pos('BEGIN ', line) > 0) then
        begin
          done := True;
        end;
        //Log(line);

      end;
      CloseFile(pasFile);

    except
      on  EInOutError do
        Result.fileType := TFileType.ERROR;
    end;

  end;


  function Cleanup(curDir: TFolderPath; a65FileName: String; var fileResult: TFileResult): Boolean;
  var
    filePath: TFilePath;
  begin

    filePath := AppendPath(curDir, a65FileName);
    if FileExists(filePath) then
    begin
      Result := DeleteFile(AppendPath(curDir, a65FileName));
      if not Result then
      begin
        Log(fileResult, format('ERROR: Cannot delete "%s".', [filePath]));
      end;
    end
    else
      Result := True;
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
    errorString: String;
  begin
    Result := False;
    try
      Result := RunCommandIndir(curDir, exename, commands, outputString);
    except
      on e: EProcess do
        errorString := e.Message;
    end;

    if not Result then
    begin
      Log(fileResult, format('ERROR: Cannot run executable "%s" for "%s" in folder "%s".',
        [exename, title, curDir]));
      Log(fileResult, Format('ERROR: Command "%s %s" failed.', [exename, CommandsToString(commands)]));
      if errorString <> '' then  Log(fileResult, Format('%s', [errorString]));
      if outputString <> '' then Log(fileResult, Format('%s', [outputString]));
      Log(fileResult, '');
      Result := False;
    end;
  end;

  function RunMadPascal(const operation: TOperation; curDir: TFolderPath; fileName: String;
    a65FileName: String; var fileResult: TFileResult): Boolean;
  var
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;
    fileInfo: TFileInfo;
    exename: TProcessString;
    parameters: TStringList;
    processParameters: array of TProcessString;
    i: Integer;
  begin

    case operation.action of
      TAction.COMPILE:
      begin
        mpFolderPath := operation.mpFolderPath;
        mpExePath := operation.mpExePath;
      end;
      TAction.COMPILE_REFERENCE:
      begin
        mpFolderPath := operation.ReferencempFolderPath;
        mpExePath := operation.ReferencempExePath;
      end;
      else
        Assert(False, 'Invalid action');
    end;

    fileInfo := GetFileInfo(AppendPath(curDir, fileName));
    if fileInfo.fileType = TFileType.TPROGRAM then
    begin
      exename := mpExePath;
      parameters := TStringList.Create;


      parameters.add('-ipath:' + AppendPath(mpFolderPath, 'lib'));
      for i := 0 to fileInfo.requiredLibraryFolders.Count - 1 do
      begin
        parameters.add('-ipath:' + AppendPath(mpFolderPath, fileInfo.requiredLibraryFolders[i]));
      end;

      // TODO: Pass platform from outside
      if curDir.ToLower.Contains('c64') then
      begin
        parameters.add('-target:c64');
      end;
      if curDir.ToLower.Contains('vic-20') then
      begin
        // TODO parameters.add('-target:raw');
      end;

      parameters.add('-o:' + a65FileName);
      parameters.add(fileName);

      processParameters := nil;
      SetLength(processParameters, parameters.Count);
      for i := 0 to parameters.Count - 1 do
      begin
        processParameters[i] := parameters[i];
      end;

      Result := RunExecutable(fileName, curDir, exename, processParameters, fileResult);
      parameters.Free;
    end;
    fileInfo.Free;
  end;

  function IsSampleFile(const filePath: TFilePath; pathSuffix: TFilePath): Boolean;
  begin
    SetDirSeparators(pathSuffix);
    Result := filePath.EndsWith(pathSuffix);
  end;


type
  TFileResultMessages = class
    suffix: String;
    Messages: TStringArray;

    constructor Create(const suffix: String);
    procedure AddMessage(const message: String);
  end;


  constructor TFileResultMessages.Create(const suffix: String);
  begin
    self.suffix := suffix;
    Messages := nil;
  end;

  procedure TFileResultMessages.AddMessage(const message: String);
  begin
    SetLength(Messages, Length(Messages) + 1);
    Messages[Length(Messages) - 1] := message;
  end;

  // Check if file result log contains all expected messages.
  procedure CheckSampleFileWithMessages(const curDir: TFolderPath; const fileName: String;
  const a65FileName: String; const fileResultMessages: TFileResultMessages; var fileResult: TFileResult;
  var Result: Boolean);
  var

    message: String;
    foundMessages: TStringList;
    logMessage: String;
    a65FilePath: TFilePath;
  begin

    if IsSampleFile(AppendPath(curDir, fileName), fileResultMessages.suffix) then
    begin
      foundMessages := TStringList.Create;
      for message in fileResultMessages.Messages do
      begin
        for logMessage in fileResult.logMessages do
        begin

          if logMessage.Contains(message) then
          begin
            foundMessages.add('INFO: The log contains the expected message "' + message + '".');
          end;

        end;
      end;

      if Length(fileResultMessages.Messages) = foundMessages.Count then
      begin
        log(fileResult, 'INFO: The log for ' + fileName + ' contains all ' +
          IntToStr(Length(fileResultMessages.Messages)) + ' expected messages.');
        log(fileResult, '--------------------------------------------------------------');
        log(fileResult, '');

        Result := True;
        a65FilePath := AppendPath(curDir, a65FileName);
        foundMessages.Insert(0, '');
        foundMessages.Insert(0, 'Compiling "' + fileName + '" failed as expected."');
        foundMessages.SaveToFile(a65FilePath);
      end;
      foundMessages.Free;
    end;
  end;

  // Some source files can intionally not be compiled with MP and erros are expected.
  function RunMadPascalFiltered(const operation: TOperation; const curDir: TFolderPath;
  const fileName: String; const a65FileName: String; var fileResult: TFileResult): Boolean;
  var

    fileResultMessages: array[1..6] of TFileResultMessages;

    i: Integer;
  begin
    Result := RunMadPascal(operation, curDir, fileName, a65FileName, fileResult);
    if not Result then
    begin

      fileResultMessages[1] := TFileResultMessages.Create('samples\common\math\ElfHash\elf_test.pas');
      fileResultMessages[1].AddMessage('Error: Expected BYTE, SHORTINT, CHAR, or BOOLEAN as CASE selector');

      fileResultMessages[2] := TFileResultMessages.Create('samples\tests\tests-basic\directives.pas');
      fileResultMessages[2].AddMessage('User defined: Some info');
      fileResultMessages[2].AddMessage('Warning: User defined: Some warning');
      fileResultMessages[2].AddMessage('Error: User defined: Some error');


      fileResultMessages[3] := TFileResultMessages.Create('samples\tests\tests-basic\const-var-scope.pas');
      fileResultMessages[3].AddMessage('Identifier N is already defined');

      fileResultMessages[4] := TFileResultMessages.Create('samples\tests\tests-basic\negative-index-range.pas');
      // TODO: Adapt when error IDs are available in origin

      // fileResultMessages[4].AddMessage('Error: E81 - ArrayLowerBoundNotZero: Array lower bound is not zero');
      fileResultMessages[4].AddMessage('ArrayLowerBoundNotZero: Array lower bound is not zero');

      fileResultMessages[5] := TFileResultMessages.Create(
        'samples\tests\tests-medium\array-with-char-index.pas');
      fileResultMessages[5].AddMessage(
        //  'Error: E80 - ArrayLowerBoundNotInteger: Array lower bound must be an integer value');
        'ArrayLowerBoundNotInteger: Array lower bound must be an integer value');

      fileResultMessages[6] := TFileResultMessages.Create('samples\common\dynrec.pas');
      fileResultMessages[6].AddMessage(
        'Incompatible types: got "^PERSON" expected "PERSON"');

      for i := 1 to length(fileResultMessages) do
      begin
        CheckSampleFileWithMessages(curDir, fileName, a65FileName, fileResultMessages[i], fileResult, Result);
        fileResultMessages[i].Free;
      end;
    end;
  end;

  function CompareA65File(curDir: TFolderPath; a65FileName, a65ReferenceFileName: String;
    mpFolderPath, mpReferenceFolderPath: TFolderPath; diffFileName: String; operation: TOperation;
  var fileResult: TFileResult): Boolean;
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

    a65FilePath := AppendPath(curDir, a65FileName);
    a65ReferenceFilePath := AppendPath(curDir, a65ReferenceFileName);
    diffFilePath := AppendPath(curDir, diffFileName);

    try

      if LoadTextFile(a65FilePath, Lines, fileResult) and LoadTextFile(
        a65ReferenceFilePath, ReferenceLines, fileResult) then
      else
      begin
        exit(False);
      end;

      if (Lines.Count < 3) then
      begin
        Log(fileResult, Format('ERROR: %s', [a65FilePath]));
        Log(fileResult, 'ERROR: There are not enough lines in the output file.');
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

        // Normalize lines with absolute paths
        // Example: .link 'C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal-origin\lib\pp\unpp.obx'
        if Pos('.link', line) > 0 then
        begin
          line := StringReplace(line, mpFolderPath, mpReferenceFolderPath, [rfReplaceAll]);
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
    diffFileName: String;
  begin
    fileResult.filePath := filePath;
    fileResult.status := TStatus.OK;
    Result := False;

    if (operation.verbose) then
    begin
      Log(Format('Processing program %s with action %s and MP path %s.', [filePath,
        operation.GetActionString(), operation.mpExePath]));
    end;

    curDir := ExtractFilePath(FilePath);
    fileName := ExtractFileName(FilePath);
    a65BaseFileName := ChangeFileExt(fileName, '');
    a65FileName := a65BaseFileName + '.a65';
    a65ReferenceFileName := a65BaseFileName + '-Reference.a65';
    diffFileName := a65BaseFileName + '.WinMerge';

    case operation.action
      of

      TAction.CLEANUP:
      begin
        Result := Cleanup(curDir, a65FileName, fileResult);
      end;

      TAction.COMPILE:
      begin
        Result := RunMadPascalFiltered(operation, curDir, fileName, a65FileName, fileResult);
      end;

      TAction.CLEANUP_REFERENCE:
      begin
        Result := Cleanup(curDir, a65ReferenceFileName, fileResult);
      end;

      TAction.COMPILE_REFERENCE:
      begin
        Result := RunMadPascalFiltered(operation, curDir, fileName, a65ReferenceFileName, fileResult);
      end;

      TAction.CLEANUP_RESULTS:
      begin
        Result := Cleanup(curDir, diffFileName, fileResult);
      end;

      TAction.COMPARE:
      begin
        Result := CompareA65File(curDir, a65FileName, a65ReferenceFileName, operation.mpFolderPath,
          operation.ReferenceMpFolderPath, diffFileName, operation, fileResult);

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
    startTickCount: QWord;
    endTickCount: QWord;
    seconds: QWord;
    secondsunit: String;
    secondsPerFile: QWord;
    secondsPerFileUnit: String;

    i: Integer;
    parallelData: TParallelData;
  begin
    startTickCount := GetTickCount64;

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
      ProcThreadPool.DoParallel(@ProcessProgramParallel, 1, ProgramFiles.Count,
        Addr(parallelData), operation.threads);

    end;

    // Create / delete operation log file
    for i := Low(operation.results) to High(operation.results) do
    begin
      if operation.results[i].status = TStatus.ERROR then
      begin
        operation.logMessages.Add(Format('ERROR: Errors while processing %s',
          [operation.results[i].filePath]));
        operation.logMessages.AddStrings(operation.results[i].logMessages);
      end;
    end;

    endTickCount := GetTickCount64;
    seconds := trunc((endTickCount - startTickCount) + 999 / 1000);
    secondsUnit := 'seconds';
    if seconds = 1 then secondsUnit := 'second';
    secondsPerFile := trunc(seconds / ProgramFiles.Count);
    secondsPerFileUnit := 'seconds';
    if secondsPerFile = 1 then secondsPerFileUnit := 'second';
    operation.logMessages.Insert(0, Format('INFO: Operation %s for %d files completed in %d %s (%d %s/file).',
      [operation.GetActionString(), ProgramFiles.Count, seconds, secondsUnit, secondsPerFile, secondsPerFileUnit]));
  end;

  procedure GetNextParam(var i: Integer; var Value: String);
  begin
    Inc(i);
    if i <= ParamCount then Value := ParamStr(i)
    else
      Value := '';
  end;

  function GetCountText(Count: Cardinal; singular: String; plural: String): String;
  begin
    if Count = 1 then
    begin
      Result := Format('%d %s', [Count, singular]);
    end
    else
    begin
      Result := Format('%d %s', [Count, plural]);
    end;
  end;

  procedure Main;
  const
    MP_REFERENCE_FOLDER = 'master';

    {$IFDEF DARWIN}
  const
    MP_BIN_FOLDER = 'macosx_aarch64';
  const
    MP_EXE = 'mp';
    {$ENDIF}
    {$IFDEF WINDOWS}
       const MP_BIN_FOLDER = 'windows_x86_64';
       const MP_EXE = 'mp.exe';
    {$ENDIF}
  var
    // application: TCustomApplication;
    maxFiles: Integer;
    p: String;
    i: Integer;

    j: Integer;
    found: Boolean;

    operation: TOperation;
    operationResultFilePath: TFilePath;
    operationResultFileExists: Boolean;

    referenceMPFolderPath: TFolderPath;
    referenceMPExePath: TFilePath;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;

    threads: Integer;

    PascalFiles: TStringList;
    inputFolderPath: TFolderPath;
    inputFilePattern: String;
    inputFilePatterns: TStringList;
    filePath: TFilePath;
    fileInfo: TFileInfo;
    ProgramFiles: TStringList;
    fileResult: TFileResult;
  begin

    referenceMPFolderPath := '';
    referenceMPExePath := '';
    mpFolderPath := '';
    mpExePath := '';
    inputFolderPath := '';
    inputFilePatterns := TStringList.Create;
    i := 1;
    while i <= ParamCount do
    begin
      p := ParamStr(i);
      if p = '-referenceMPFolderPath' then GetNextParam(i, referenceMPFolderPath);
      if p = '-referenceMPExePath' then GetNextParam(i, referenceMPExePath);
      if p = '-mpFolderPath' then GetNextParam(i, mpFolderPath);
      if p = '-mpExePath' then GetNextParam(i, mpExePath);
      if p = '-inputFolderPath' then GetNextParam(i, inputFolderPath);
      if p = '-inputFilePattern' then
      begin
        inputFilePattern := '';
        GetNextParam(i, inputFilePattern);
        SetDirSeparators(inputFilePattern);
        inputFilePatterns.Add(inputFilePattern);
      end;
      if p = '-allFiles' then options.allFiles := True;
      if p = '-allThreads' then options.allThreads := True;
      if p = '-cleanup' then options.cleanup := True;
      if p = '-compile' then options.compile := True;
      if p = '-cleanupReference' then options.cleanupReference := True;
      if p = '-compileReference' then options.compileReference := True;
      if p = '-compare' then options.compare := True;
      if p = '-openResults' then options.openResults := True;
      if p = '-cleanupResults' then options.cleanupResults := True;
      if p = '-waitForKey' then options.waitForKey := True;
      if p = '-verbose' then options.verbose := True;
      Inc(i);
      // application:=  TCustomApplication.Create;
      // Application.Initialize;
      // Application.Run;
    end;



    // Use defaults, if not parameters were specified.
    MakeAbsolutePath(mpFolderPath);

    if mpFolderPath = '' then mpFolderPath :=
        ExtractFileDir(ExtractFileDir(ParamStr(0)));
    if mpExePath = '' then mpExePath :=
        AppendPath(mpFolderPath, 'bin', MP_BIN_FOLDER, MP_EXE);

    if referenceMPFolderPath = '' then referenceMPFolderPath := mpFolderPath;
    if referenceMPExePath = '' then referenceMPExePath :=
        AppendPath(mpFolderPath, 'bin', MP_BIN_FOLDER, MP_REFERENCE_FOLDER, MP_EXE);

    if inputFolderPath = '' then  inputFolderPath := AppendPath(mpFolderPath, 'samples');

    MakeAbsolutePath(mpFolderPath);
    MakeAbsolutePath(mpExePath);
    MakeAbsolutePath(referenceMPExePath);
    MakeAbsolutePath(inputFolderPath);

    Log(Format('MP Folder Path          : %s', [mpFolderPath]));
    Log(Format('MP Exe Path             : %s', [mpExePath]));

    Log(Format('Reference MP Folder Path: %s', [referenceMPFolderPath]));
    Log(Format('Reference MP Exe Path   : %s', [referenceMPExePath]));

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

        // Maching any of the specified patterns?
        if inputFilePatterns.Count > 0 then
        begin
          found := False;
          j := 1;
          while (j <= inputFilePatterns.Count) and not found do
          begin
            found := ContainsText(filePath, inputFilePatterns[j - 1]);
            Inc(j);
          end;
          if not found then Continue;
        end;

        // Log(Format('Scanning file %s (%d of %d)', [filePath, i, maxFiles]));
        fileInfo := GetFileInfo(filePath);
        case fileInfo.fileType
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
          else
        end;
        fileInfo.Free;
      end;



      if (options.AllThreads) then
      begin
        {$IFDEF DARWIN}
        threads:=7;
        {$ELSE}
        threads := TThread.ProcessorCount - 1;
        {$ENDIF}
      end
      else
      begin
        threads := 1;
      end;

      Log(Format('Processing %s with %s.', [GetCountText(ProgramFiles.Count, 'Pascal program', 'Pascal programs'),
        GetCountText(threads, 'thread', 'threads')]));


      if (options.cleanup) then
      begin
        operation := TOperation.Create(TAction.CLEANUP);
        operation.threads := threads;
        operation.verbose := options.verbose;
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
        if not DirectoryExists(operation.mpFolderPath) then
        begin
          Log(Format('ERROR: MP folder %s does not exist.', [operation.mpFolderPath]));
          exit;
        end;
        if not FileExists(operation.mpExePath) then
        begin
          Log(Format('ERROR: MP executable %s does not exist.', [operation.mpExePath]));
          exit;
        end;
        ProcessPrograms(ProgramFiles, operation);
        operation.WriteLog(inputFolderPath);
        operation.Free;

      end;


      if (options.cleanupReference) then
      begin
        operation := TOperation.Create(TAction.CLEANUP_REFERENCE);
        operation.threads := threads;
        operation.verbose := options.verbose;
        ProcessPrograms(ProgramFiles, operation);
        operation.WriteLog(inputFolderPath);
        operation.Free;
      end;

      if (options.compileReference) then
      begin
        operation := TOperation.Create(TAction.COMPILE_REFERENCE);
        operation.threads := threads;
        operation.verbose := options.verbose;
        operation.referenceMPFolderPath := referenceMPFolderPath;
        operation.referenceMPExePath := referenceMPExePath;
        if not DirectoryExists(operation.referenceMPFolderPath) then
        begin
          Log(Format('ERROR: Reference MP folder %s does not exist.', [operation.referenceMPFolderPath]));
          exit;
        end;
        if not FileExists(operation.referenceMPExePath) then
        begin
          Log(Format('ERROR: Reference MP executable %s does not exist.', [operation.referenceMPExePath]));
          exit;
        end;

        ProcessPrograms(ProgramFiles, operation);
        operation.WriteLog(inputFolderPath);
        operation.Free;
      end;

      if (options.compare) then
      begin
        operation := TOperation.Create(TAction.COMPARE);
        operation.threads := 1;
        operation.verbose := options.verbose;

        // Path are required to normalize the comparison inputs.
        operation.mpFolderPath := mpFolderPath;
        operation.mpExePath := mpExePath;
        operation.referenceMPFolderPath := referenceMPFolderPath;
        operation.referenceMPExePath := referenceMPExePath;

        ProcessPrograms(ProgramFiles, operation);

        if (operation.diffFilePaths.Count = 0) then
        begin
          Log('All generated .A65 files are identical.');
        end
        else
        begin
          operation.logMessages.Add(Format('Found %s.',
            [GetCountText(operation.diffFilePaths.Count, 'different file', 'different files')]));
          operation.logMessages.AddStrings(operation.diffFilePaths);
        end;

        operationResultFilePath := operation.GetLogFilePath(inputFolderPath);
        operationResultFileExists := operation.WriteLog(inputFolderPath);

        if (options.openResults and operationResultFileExists) then
        begin
          fileResult := Default(TFileResult);
          fileResult.filePath := 'All';
          {$IFDEF DARWIN}
          RunExecutable('Result Files', '', 'open',
            [inputFolderPath],fileResult);
          {$ENDIF}
          {$IFDEF WINDOWS}
          RunExecutable('Result File', '', 'CMD.EXE',
            ['/C', operationResultFilePath], fileResult);
          if operation.diffFilePaths.Count > 0 then
          begin
            RunExecutable('WinMerge', '', 'CMD.EXE',
              ['/C', operation.diffFilePaths[0]], fileResult);
          end;
          {$ENDIF}
        end;

        operation.Free;

      end;

      if (options.cleanupResults) then
      begin
        DeleteFile(TOperation.GetLogFilePath(inputFolderPath, TAction.COMPILE));
        DeleteFile(TOperation.GetLogFilePath(inputFolderPath, TAction.COMPILE_REFERENCE));
        DeleteFile(TOperation.GetLogFilePath(inputFolderPath, TAction.COMPARE));
      end;

    finally
      ProgramFiles.Free;
      PascalFiles.Free;
      inputFilePatterns.Free;
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
