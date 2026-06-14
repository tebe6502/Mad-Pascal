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
    FilePath: TFilePath;
    FileType: TFileType;
    RequiredLibraryFolders: TStringList;

    constructor Create(FilePath: TFilePath);
    destructor Free;
  end;

  TAction = (CLEANUP, COMPILE, CLEANUP_REFERENCE, COMPILE_REFERENCE,
    COMPARE, CLEANUP_RESULTS);

  TStatus = (OK, ERROR);

  TFileResult = record
    FilePath: TFilePath;
    Status: TStatus;
    LogMessages: TStringList;
  end;

  TFileResultArray = array of TFileResult;



  TOperation = class
    Threads: Integer;
    Action: TAction;
    Verbose: Boolean;

    MPFolderPath: TFolderPath;
    MPExePath: TFilePath;

    ReferenceMPFolderPath: TFolderPath;
    ReferenceMPExePath: TFilePath;

    Results: TFileResultArray;
    LogMessages: TStringList;
    DiffFilePaths: TStringList;
    class function GetActionString(const Action: TAction): String; overload;
    class function GetLogFilePath(const FolderPath: TFolderPath; const Action: TAction): TFilePath; overload;

    constructor Create(const Action: TAction);
    destructor Free;
    function GetActionString(): String; overload;
    function GetLogFilePath(const FolderPath: TFolderPath): TFilePath; overload;
    function WriteLog(const FolderPath: TFolderPath): Boolean;
  end;


  TOptions = record
    AllFiles: Boolean;
    AllThreads: Boolean;

    CLEANUP: Boolean;
    COMPILE: Boolean;

    CleanupReference: Boolean;
    CompileReference: Boolean;

    COMPARE: Boolean;

    OpenResults: Boolean;
    CleanupResults: Boolean;

    WaitForKey: Boolean;

    Verbose: Boolean;
  end;

var
  Options: TOptions;
  CS: TRTLCriticalSection;
  StartTickCount: QWord;
  EndTickCount: QWord;
  Duration: QWord;
  Seconds: QWord;
  Minutes: QWord;

  function AppendPath(BasePath: TFolderPath; Path1: String; Path2: String = ''; Path3: String = '';
    Path4: String = ''): TFilePath;
  begin
    Result := CreateAbsolutePath(Path1, BasePath);
    if Path2 <> '' then  Result := CreateAbsolutePath(Path2, Result);
    if Path3 <> '' then  Result := CreateAbsolutePath(Path3, Result);
    if Path4 <> '' then  Result := CreateAbsolutePath(Path4, Result);
    Result := SetDirSeparators(Result);
  end;

  procedure MakeAbsolutePath(var FilePath: TFilePath);
  begin
    if FilePath <> '' then FilePath := ExpandFileName(FilePath);
  end;

  procedure Log(const Message: String); overload;
  begin
    EnterCriticalSection(CS);
    WriteLn(stdout, Message);
    LeaveCriticalSection(CS);
  end;

  procedure Log(var FileResult: TFileResult; const Message: String); overload;
  begin
    if (FileResult.LogMessages = nil) then
    begin
      FileResult.LogMessages := TStringList.Create;
    end;
    if (Message.StartsWith('ERROR:')) then FileResult.Status := TStatus.ERROR;
    FileResult.LogMessages.Add(Message);
  end;


  constructor TFileInfo.Create(FilePath: TFilePath);
  begin
    self.FilePath := FilePath;
    FileType := TFileType.UNKNOWN;
    RequiredLibraryFolders := TStringList.Create;
  end;

  destructor TFileInfo.Free;
  begin
    RequiredLibraryFolders.Free;
    RequiredLibraryFolders := nil;
  end;

  class function TOperation.GetActionString(const Action: TAction): String; overload;
  begin
    WriteStr(Result, Action);
  end;

  class function TOperation.GetLogFilePath(const FolderPath: TFolderPath; const Action: TAction): TFilePath;
  begin
    Result := AppendPath(FolderPath, 'MakeMadPascal-' + GetActionString(Action) + '.log');
  end;

  constructor TOperation.Create(const Action: TAction);
  begin
    self.Action := Action;
    LogMessages := TStringList.Create;
    DiffFilePaths := TStringList.Create;
  end;

  destructor TOperation.Free;
  begin
    LogMessages.Free;
    DiffFilePaths.Free;
  end;


  function TOperation.GetActionString(): String; overload;
  begin
    WriteStr(Result, Action);
  end;

  function TOperation.GetLogFilePath(const FolderPath: TFolderPath): TFilePath;
  begin
    Result := GetLogFilePath(FolderPath, Action);
  end;

  function TOperation.WriteLog(const FolderPath: TFolderPath): Boolean;
  var
    FilePath: TFilePath;
  begin
    Result := FALSE;
    FilePath := GetLogFilePath(FolderPath);
    if LogMessages.Count = 0 then
    begin
      if FileExists(FilePath) then
      begin
        DeleteFile(FilePath);
      end;
    end
    else
    begin

      try

        LogMessages.SaveToFile(FilePath);
        Result := TRUE;
      except
        on e: EFCreateError do
        begin
          Log(Format('ERROR: Cannot save %s.', [FilePath]));
        end;
      end;

    end;

  end;

  function LoadTextFile(const FilePath: TFilePath; StringList: TStringList; var FileResult: TFileResult): Boolean;
  begin
    Result := FALSE;
    try
      if FileExists(FilePath) then
      begin
        StringList.LoadFromFile(FilePath);
        Result := TRUE;
      end
      else
      begin
        Log(FileResult, Format('ERROR: File %s does not exist.', [FilePath]));
      end;
    except
      on e: EFOpenError do
        Log(FileResult, Format('ERROR: File %s cannot be opened.', [FilePath]));
    end;

  end;

  // Parameter for line "line" must be uppercase.
  // Parameter for line "lib" must be lowercase
  procedure CheckForLibrary(const Line: String; Lib: String; var FileInfo: TFileInfo);
  begin
    // {$librarypath 'blibs'}
    if pos('{$LIBRARYPATH ''' + UpperCase(Lib) + '''', Line) > 0 then
    begin
      FileInfo.RequiredLibraryFolders.Add(Lib);
    end;
  end;

  function GetFileInfo(FilePath: TFilePath): TFileInfo;
  var
    PasFile: TextFile;
    Done: Boolean;
    Line: String;
  begin

    try
      AssignFile(PasFile, FilePath);
      Reset(PasFile);
      Result := TFileInfo.Create(FilePath);

      Done := FALSE;
      while not Done and not EOF(PasFile) do
      begin
        ReadLn(PasFile, Line);
        Line := UpperCase(Line);
        CheckForLibrary(Line, 'blibs', Result);
        CheckForLibrary(Line, 'dlibs', Result);
        if (Result.FileType = TFileType.UNKNOWN) and (pos('PROGRAM ', Line) > 0) then
        begin
          Result.FileType := TFileType.TPROGRAM;
        end;
        if (Result.FileType = TFileType.UNKNOWN) and (pos('UNIT ', Line) > 0) then
        begin
          Result.FileType := TFileType.TUNIT;
        end;

        if Result.FileType = TFileType.UNKNOWN then
        begin
          if (pos('USES ', Line) > 0) then
          begin

            begin
              Result.FileType := TFileType.TPROGRAM;
            end;
            Done := TRUE;
          end;
          if (pos('PROCEDURE ', Line) > 0) or (pos('FUNCTION ', Line) > 0) then
          begin
            Result.FileType := TFileType.TINCLUDE;
            Done := TRUE;
          end;
        end;

        if (pos('BEGIN ', Line) > 0) then
        begin
          Done := TRUE;
        end;
        //Log(line);

      end;
      CloseFile(PasFile);

    except
      on  EInOutError do
        Result.FileType := TFileType.ERROR;
    end;

  end;


  function CLEANUP(CurDir: TFolderPath; A65FileName: String; var FileResult: TFileResult): Boolean;
  var
    FilePath: TFilePath;
  begin

    FilePath := AppendPath(CurDir, A65FileName);
    if FileExists(FilePath) then
    begin
      Result := DeleteFile(AppendPath(CurDir, A65FileName));
      if not Result then
      begin
        Log(FileResult, Format('ERROR: Cannot delete "%s".', [FilePath]));
      end;
    end
    else
      Result := TRUE;
  end;

  function CommandsToString(Commands: array of TProcessString): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(Commands) do
    begin
      if i > 1 then Result := Result + ' ';
      Result := Result + Commands[i - 1];
    end;
  end;

  function RunExecutable(Title: String; CurDir: TFolderPath; ExeName: TProcessString;
    Commands: array of TProcessString; var FileResult: TFileResult): Boolean;
  var
    OutputString: TProcessString;
    ErrorString: String;
  begin
    Result := FALSE;
    try
      Result := RunCommandIndir(CurDir, ExeName, Commands, OutputString);
    except
      on e: EProcess do
        ErrorString := e.Message;
    end;

    if not Result then
    begin
      Log(FileResult, Format('ERROR: Cannot run executable "%s" for "%s" in folder "%s".',
        [ExeName, Title, CurDir]));
      Log(FileResult, Format('ERROR: Command "%s %s" failed.', [ExeName, CommandsToString(Commands)]));
      if ErrorString <> '' then  Log(FileResult, Format('%s', [ErrorString]));
      Result := FALSE;
    end;
    if OutputString <> '' then Log(FileResult, Format('%s', [OutputString]));
    Log(FileResult, '');
  end;

  function RunMadPascal(const Operation: TOperation; CurDir: TFolderPath; FileName: String;
    A65FileName: String; var FileResult: TFileResult): Boolean;
  var
    MPFolderPath: TFolderPath;
    MPExePath: TFilePath;
    FileInfo: TFileInfo;
    ExeName: TProcessString;
    parameters: TStringList;
    processParameters: array of TProcessString;
    i: Integer;
  begin

    case Operation.Action of
      TAction.COMPILE:
      begin
        MPFolderPath := Operation.MPFolderPath;
        MPExePath := Operation.MPExePath;
      end;
      TAction.COMPILE_REFERENCE:
      begin
        MPFolderPath := Operation.ReferenceMPFolderPath;
        MPExePath := Operation.ReferenceMPExePath;
      end;
      else
        Assert(FALSE, 'Invalid action');
    end;

    FileInfo := GetFileInfo(AppendPath(CurDir, FileName));
    if FileInfo.FileType = TFileType.TPROGRAM then
    begin
      ExeName := MPExePath;
      parameters := TStringList.Create;


      parameters.Add('-ipath:' + AppendPath(MPFolderPath, 'lib'));
      for i := 0 to FileInfo.RequiredLibraryFolders.Count - 1 do
      begin
        parameters.Add('-ipath:' + AppendPath(MPFolderPath, FileInfo.RequiredLibraryFolders[i]));
      end;

      // TODO: Pass platform from outside
      if CurDir.ToLower.Contains('c64') then
      begin
        parameters.Add('-target:c64');
      end;
      if CurDir.ToLower.Contains('vic-20') then
      begin
        // TODO parameters.add('-target:raw');
      end;

      parameters.Add('-o:' + A65FileName);
      parameters.Add(FileName);

      processParameters := nil;
      SetLength(processParameters, parameters.Count);
      for i := 0 to parameters.Count - 1 do
      begin
        processParameters[i] := parameters[i];
      end;

      Result := RunExecutable(FileName, CurDir, ExeName, processParameters, FileResult);
      parameters.Free;
    end;
    FileInfo.Free;
  end;

  function IsSampleFile(const FilePath: TFilePath; PathSuffix: TFilePath): Boolean;
  begin
    SetDirSeparators(PathSuffix);
    Result := FilePath.EndsWith(PathSuffix);
  end;


type
  TFileResultMessages = class
    suffix: String;
    Messages: TStringArray;

    constructor Create(const suffix: String);
    procedure AddMessage(const Message: String);
  end;


  constructor TFileResultMessages.Create(const suffix: String);
  begin
    self.suffix := suffix;
    Messages := nil;
  end;

  procedure TFileResultMessages.AddMessage(const Message: String);
  begin
    SetLength(Messages, Length(Messages) + 1);
    Messages[Length(Messages) - 1] := Message;
  end;

  // Check if file result log contains all expected messages.
  procedure CheckSampleFileWithMessages(const CurDir: TFolderPath; const FileName: String;
  const A65FileName: String; const fileResultMessages: TFileResultMessages; var FileResult: TFileResult;
  var Result: Boolean);
  var

    Message: String;
    foundMessages: TStringList;
    logMessage: String;
    a65FilePath: TFilePath;
  begin

    if IsSampleFile(AppendPath(CurDir, FileName), fileResultMessages.suffix) then
    begin
      foundMessages := TStringList.Create;
      for Message in fileResultMessages.Messages do
      begin
        for logMessage in FileResult.LogMessages do
        begin

          if logMessage.Contains(Message) then
          begin
            foundMessages.Add('INFO: The log contains the expected message "' + Message + '".');
          end;

        end;
      end;

      if Length(fileResultMessages.Messages) = foundMessages.Count then
      begin
        Log(FileResult, 'INFO: The log for ' + FileName + ' contains all ' +
          IntToStr(Length(fileResultMessages.Messages)) + ' expected messages.');
        Log(FileResult, '--------------------------------------------------------------');
        Log(FileResult, '');

        Result := TRUE;
        a65FilePath := AppendPath(CurDir, A65FileName);
        foundMessages.Insert(0, '');
        foundMessages.Insert(0, 'Compiling "' + FileName + '" failed as expected."');
        foundMessages.SaveToFile(a65FilePath);
      end;
      foundMessages.Free;
    end;
  end;

  // Some source files can intionally not be compiled with MP and erros are expected.
  function RunMadPascalFiltered(const Operation: TOperation; const CurDir: TFolderPath;
  const FileName: String; const A65FileName: String; var FileResult: TFileResult): Boolean;
  var
    fileResultMessages: array[1..6] of TFileResultMessages;

    i: Integer;
  begin
    Result := RunMadPascal(Operation, CurDir, FileName, A65FileName, FileResult);
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

      for i := 1 to Length(fileResultMessages) do
      begin
        CheckSampleFileWithMessages(CurDir, FileName, A65FileName, fileResultMessages[i], FileResult, Result);
        fileResultMessages[i].Free;
      end;
    end;
  end;

  function CompareA65File(CurDir: TFolderPath; A65FileName, a65ReferenceFileName: String;
    MPFolderPath, mpReferenceFolderPath: TFolderPath; diffFileName: String; Operation: TOperation;
  var FileResult: TFileResult): Boolean;
  const
    MAX_DIFFS = 5;
  var
    a65FilePath, a65ReferenceFilePath: TFilePath;
    Lines, ReferenceLines: TStringList;
    i, j, diffs: Integer;
    Line, referenceLine: String;
    diffFileLines: TStringList;
    diffFilePath: TFilePath;
  begin
    Result := TRUE;
    Lines := TStringList.Create;
    ReferenceLines := TStringList.Create;

    a65FilePath := AppendPath(CurDir, A65FileName);
    a65ReferenceFilePath := AppendPath(CurDir, a65ReferenceFileName);
    diffFilePath := AppendPath(CurDir, diffFileName);

    try

      if LoadTextFile(a65FilePath, Lines, FileResult) and LoadTextFile(
        a65ReferenceFilePath, ReferenceLines, FileResult) then
      else
      begin
        exit(FALSE);
      end;

      if (Lines.Count < 3) then
      begin
        Log(FileResult, Format('ERROR: %s', [a65FilePath]));
        Log(FileResult, 'ERROR: There are not enough lines in the output file.');
        exit(FALSE);
      end;

      // Skip the first 2 lines with the compiler version output.
      diffs := 0;
      i := 3;
      j := 3;
      while (i <= Lines.Count) and (j <= ReferenceLines.Count) do
      begin
        // Find next non-empty line
        Line := Lines[i - 1];
        // TODO: PMCNTL  = $D01D is temporary    // or (line = 'PMCNTL'#9'= $D01D')
        while (i < Lines.Count) and ((Line = '')) do
        begin
          Inc(i);
          Line := Lines[i - 1];
        end;

        // Normalize lines with absolute paths
        // Example: .link 'C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal-origin\lib\pp\unpp.obx'
        if pos('.link', Line) > 0 then
        begin
          Line := StringReplace(Line, MPFolderPath, mpReferenceFolderPath, [rfReplaceAll]);
        end;

        // Find next non-empty line
        referenceLine := ReferenceLines[j - 1];
        while (j < ReferenceLines.Count) and (referenceLine = '') do
        begin
          Inc(j);
          referenceLine := ReferenceLines[j - 1];
        end;

        if (Line <> referenceLine) then
        begin
          if Result then
          begin

            Result := FALSE;
            Log(FileResult, Format('ERROR: %s', [diffFilePath]));
          end;

          Log(FileResult, Format('%d: %-40s %-40s ', [i, LeftStr(Line, 40), LeftStr(referenceLine, 40)]));
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

        diffFileLines.Add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
        diffFileLines.Add('<project>');
        diffFileLines.Add('   <paths>');
        diffFileLines.Add(Format('      <left>%s</left>', [a65FilePath]));
        diffFileLines.Add(Format('      <right>%s</right>', [a65ReferenceFilePath]));
        diffFileLines.Add('      <filter>*.*</filter>');
        diffFileLines.Add('      <subfolders>0</subfolders>');
        diffFileLines.Add('      <left-readonly>0</left-readonly>');
        diffFileLines.Add('      <right-readonly>0</right-readonly>');
        diffFileLines.Add('   </paths>');
        diffFileLines.Add('</project>');
        diffFileLines.SaveToFile(diffFilePath);
        diffFileLines.Free;
        Operation.DiffFilePaths.Add(diffFilePath);

      end;
      ReferenceLines.Free;
      Lines.Free;
    end;

  end;

  function ProcessProgram(const FilePath: TFilePath; var Operation: TOperation; var FileResult: TFileResult): Boolean;
  var
    CurDir: TFolderPath;
    FileName: String;
    a65BaseFileName: String;
    A65FileName: String;
    a65ReferenceFileName: String;
    diffFileName: String;
  begin
    FileResult.FilePath := FilePath;
    FileResult.Status := TStatus.OK;
    Result := FALSE;

    if (Operation.Verbose) then
    begin
      Log(Format('Processing program %s with action %s and MP path %s.',
        [FilePath, Operation.GetActionString(), Operation.MPExePath]));
    end;

    CurDir := ExtractFilePath(FilePath);
    FileName := ExtractFileName(FilePath);
    a65BaseFileName := ChangeFileExt(FileName, '');
    A65FileName := a65BaseFileName + '.a65';
    a65ReferenceFileName := a65BaseFileName + '-Reference.a65';
    diffFileName := a65BaseFileName + '.WinMerge';

    case Operation.Action
      of

      TAction.CLEANUP:
      begin
        Result := CLEANUP(CurDir, A65FileName, FileResult);
      end;

      TAction.COMPILE:
      begin
        Result := RunMadPascalFiltered(Operation, CurDir, FileName, A65FileName, FileResult);
      end;

      TAction.CLEANUP_REFERENCE:
      begin
        Result := CLEANUP(CurDir, a65ReferenceFileName, FileResult);
      end;

      TAction.COMPILE_REFERENCE:
      begin
        Result := RunMadPascalFiltered(Operation, CurDir, FileName, a65ReferenceFileName, FileResult);
      end;

      TAction.CLEANUP_RESULTS:
      begin
        Result := CLEANUP(CurDir, diffFileName, FileResult);
      end;

      TAction.COMPARE:
      begin
        Result := CompareA65File(CurDir, A65FileName, a65ReferenceFileName, Operation.MPFolderPath,
          Operation.ReferenceMPFolderPath, diffFileName, Operation, FileResult);

      end;
      else
        Assert(FALSE, 'Unsupported action ' + Operation.GetActionString());
    end;

  end;


  function ProcessProgramAtIndex(const ProgramFiles: TStringList; const index: Integer;
  var Operation: TOperation): Boolean;
  begin
    Log(Format('Processing program %d of %d (%d%%) with action %s: %s',
      [index, ProgramFiles.Count, Trunc(index * 100 / ProgramFiles.Count), Operation.GetActionString(),
      ExtractFileName(ProgramFiles[index - 1])]));
    Result := ProcessProgram(ProgramFiles[index - 1], Operation, Operation.Results[index - 1]);
  end;

type
  TParallelData = record
    ProgramFiles: TStringList;
    Operation: TOperation;
    FileResults: TFileResultArray;
    ErrorOccurred: Boolean;
  end;

  {$WARN 5024 off : Parameter "Item" not used}
  procedure ProcessProgramParallel(index: PtrInt; Data: Pointer; Item: TMultiThreadProcItem);
  var
    parallelData: ^TParallelData;
  begin
    parallelData := Data;
    // if not parallelData.errorOccurred then
    begin
      if not ProcessProgramAtIndex(parallelData^.ProgramFiles, index, parallelData^.Operation) then
      begin
        parallelData.ErrorOccurred := TRUE;
      end;
    end;
  end;
  {$WARN 5024 on}

  procedure ProcessPrograms(ProgramFiles: TStringList; Operation: TOperation);
  var
    StartTickCount: QWord;
    EndTickCount: QWord;
    Seconds: QWord;
    secondsunit: String;
    secondsPerFile: QWord;
    secondsPerFileUnit: String;

    i: Integer;
    parallelData: TParallelData;
  begin

    if ProgramFiles.Count = 0 then exit;

    StartTickCount := GetTickCount64;

    SetLength(Operation.Results, ProgramFiles.Count);

    if Operation.Threads = 1 then
    begin
      for i := 1 to ProgramFiles.Count do
      begin
        ProcessProgramAtIndex(ProgramFiles, i, Operation);
      end;
    end
    else
    begin
      parallelData.ProgramFiles := ProgramFiles;
      parallelData.Operation := Operation;
      parallelData.ErrorOccurred := FALSE;
      // address, startindex, endindex, optional data, numberOfThreads
      ProcThreadPool.DoParallel(@ProcessProgramParallel, 1, ProgramFiles.Count,
        Addr(parallelData), Operation.Threads);

    end;

    // Create / delete operation log file
    for i := Low(Operation.Results) to High(Operation.Results) do
    begin
      if Operation.Results[i].Status = TStatus.ERROR then
      begin
        Operation.LogMessages.Add(Format('ERROR: Errors while processing %s',
          [Operation.Results[i].FilePath]));
        Operation.LogMessages.AddStrings(Operation.Results[i].LogMessages);
      end;
    end;

    EndTickCount := GetTickCount64;
    Seconds := Trunc((EndTickCount - StartTickCount) + 999 / 1000);
    secondsunit := 'seconds';
    if Seconds = 1 then secondsunit := 'second';
    secondsPerFile := Trunc(Seconds / ProgramFiles.Count);
    secondsPerFileUnit := 'seconds';
    if secondsPerFile = 1 then secondsPerFileUnit := 'second';
    Operation.LogMessages.Insert(0, Format('INFO: Operation %s for %d files completed in %d %s (%d %s/file).',
      [Operation.GetActionString(), ProgramFiles.Count, Seconds, secondsunit, secondsPerFile, secondsPerFileUnit]));
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
    MP_REFERENCE_BIN_FOLDER = 'windows';

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

    Operation: TOperation;
    operationResultFilePath: TFilePath;
    operationResultFileExists: Boolean;

    ReferenceMPFolderPath: TFolderPath;
    ReferenceMPExePath: TFilePath;
    MPFolderPath: TFolderPath;
    MPExePath: TFilePath;

    Threads: Integer;

    PascalFiles: TStringList;
    inputFolderPath: TFolderPath;
    inputFilePattern: String;
    inputFilePatterns: TStringList;
    FilePath: TFilePath;
    FileInfo: TFileInfo;
    ProgramFiles: TStringList;
    FileResult: TFileResult;
  begin

    ReferenceMPFolderPath := '';
    ReferenceMPExePath := '';
    MPFolderPath := '';
    MPExePath := '';
    inputFolderPath := '';
    inputFilePatterns := TStringList.Create;
    i := 1;
    while i <= ParamCount do
    begin
      p := ParamStr(i);
      if p = '-referenceMPFolderPath' then GetNextParam(i, ReferenceMPFolderPath);
      if p = '-referenceMPExePath' then GetNextParam(i, ReferenceMPExePath);
      if p = '-mpFolderPath' then GetNextParam(i, MPFolderPath);
      if p = '-mpExePath' then GetNextParam(i, MPExePath);
      if p = '-inputFolderPath' then GetNextParam(i, inputFolderPath);
      if p = '-inputFilePattern' then
      begin
        inputFilePattern := '';
        GetNextParam(i, inputFilePattern);
        SetDirSeparators(inputFilePattern);
        inputFilePatterns.Add(inputFilePattern);
      end;
      if p = '-allFiles' then Options.AllFiles := TRUE;
      if p = '-allThreads' then Options.AllThreads := TRUE;
      if p = '-cleanup' then Options.CLEANUP := TRUE;
      if p = '-compile' then Options.COMPILE := TRUE;
      if p = '-cleanupReference' then Options.CleanupReference := TRUE;
      if p = '-compileReference' then Options.CompileReference := TRUE;
      if p = '-compare' then Options.COMPARE := TRUE;
      if p = '-openResults' then Options.OpenResults := TRUE;
      if p = '-cleanupResults' then Options.CleanupResults := TRUE;
      if p = '-waitForKey' then Options.WaitForKey := TRUE;
      if p = '-verbose' then Options.Verbose := TRUE;
      Inc(i);
      // application:=  TCustomApplication.Create;
      // Application.Initialize;
      // Application.Run;
    end;



    // Use defaults, if not parameters were specified.
    MakeAbsolutePath(MPFolderPath);

    if MPFolderPath = '' then MPFolderPath :=
        ExtractFileDir(ExtractFileDir(ParamStr(0)));
    if MPExePath = '' then MPExePath :=
        AppendPath(MPFolderPath, 'bin', MP_BIN_FOLDER, MP_EXE);

    if ReferenceMPFolderPath = '' then ReferenceMPFolderPath := MPFolderPath;
    if ReferenceMPExePath = '' then ReferenceMPExePath :=
        AppendPath(MPFolderPath, 'bin', MP_REFERENCE_BIN_FOLDER, MP_EXE);

    if inputFolderPath = '' then  inputFolderPath := AppendPath(MPFolderPath, 'samples');

    MakeAbsolutePath(MPFolderPath);
    MakeAbsolutePath(MPExePath);
    MakeAbsolutePath(ReferenceMPExePath);
    MakeAbsolutePath(inputFolderPath);

    Log(Format('MP Folder Path          : %s', [MPFolderPath]));
    Log(Format('MP Exe Path             : %s', [MPExePath]));

    Log(Format('Reference MP Folder Path: %s', [ReferenceMPFolderPath]));
    Log(Format('Reference MP Exe Path   : %s', [ReferenceMPExePath]));

    Log(Format('Input Folder Path       : %s', [inputFolderPath]));
    Log(Format('Input File Pattern      : %s', [inputFilePattern]));

    Log(Format('Scanning input folder %s for Pascal source files.', [inputFolderPath]));
    PascalFiles := FindAllFiles(inputFolderPath, '*.pas', TRUE);
    ProgramFiles := TStringList.Create;
    try

      maxFiles := MAX_FILES;
      if (Options.AllFiles) then maxFiles := High(Integer);
      if maxFiles > PascalFiles.Count then  maxFiles := PascalFiles.Count;

      Log(Format('Scanning %d Pascal source files for programs.', [PascalFiles.Count]));
      for i := 1 to PascalFiles.Count do
      begin
        FilePath := PascalFiles[i - 1];

        // Maching any of the specified patterns?
        if inputFilePatterns.Count > 0 then
        begin
          found := FALSE;
          j := 1;
          while (j <= inputFilePatterns.Count) and not found do
          begin
            found := ContainsText(FilePath, inputFilePatterns[j - 1]);
            Inc(j);
          end;
          if not found then Continue;
        end;

        // Log(Format('Scanning file %s (%d of %d)', [filePath, i, maxFiles]));
        FileInfo := GetFileInfo(FilePath);
        case FileInfo.FileType
          of
          TFileType.UNKNOWN:
          begin
            if (Options.Verbose) then
            begin
              Log(Format('WARNING: Skipping file %s with unkown file type.', [FilePath]));
            end;
          end;
          TFileType.TPROGRAM: begin
            ProgramFiles.Add(FilePath);
            if ProgramFiles.Count >= maxFiles then break;
          end;
          else
        end;
        FileInfo.Free;
      end;

      if (ProgramFiles.Count = 0) then
      begin
        Log('No matching files found.');
        exit;
      end;


      if (Options.AllThreads) then
      begin
        {$IFDEF DARWIN}
        threads:=7;
        {$ELSE}
        Threads := TThread.ProcessorCount - 1;
        {$ENDIF}
      end
      else
      begin
        Threads := 1;
      end;

      Log(Format('Processing %s with %s.', [GetCountText(ProgramFiles.Count, 'Pascal program', 'Pascal programs'),
        GetCountText(Threads, 'thread', 'threads')]));


      if (Options.CLEANUP) then
      begin
        Operation := TOperation.Create(TAction.CLEANUP);
        Operation.Threads := Threads;
        Operation.Verbose := Options.Verbose;
        ProcessPrograms(ProgramFiles, Operation);
        Operation.WriteLog(inputFolderPath);
        Operation.Free;
      end;

      if (Options.COMPILE) then
      begin
        Operation := TOperation.Create(TAction.COMPILE);
        Operation.Threads := Threads;
        Operation.Verbose := Options.Verbose;
        Operation.MPFolderPath := MPFolderPath;
        Operation.MPExePath := MPExePath;
        if not DirectoryExists(Operation.MPFolderPath) then
        begin
          Log(Format('ERROR: MP folder %s does not exist.', [Operation.MPFolderPath]));
          exit;
        end;
        if not FileExists(Operation.MPExePath) then
        begin
          Log(Format('ERROR: MP executable %s does not exist.', [Operation.MPExePath]));
          exit;
        end;
        ProcessPrograms(ProgramFiles, Operation);
        Operation.WriteLog(inputFolderPath);
        Operation.Free;

      end;


      if (Options.CleanupReference) then
      begin
        Operation := TOperation.Create(TAction.CLEANUP_REFERENCE);
        Operation.Threads := Threads;
        Operation.Verbose := Options.Verbose;
        ProcessPrograms(ProgramFiles, Operation);
        Operation.WriteLog(inputFolderPath);
        Operation.Free;
      end;

      if (Options.CompileReference) then
      begin
        Operation := TOperation.Create(TAction.COMPILE_REFERENCE);
        Operation.Threads := Threads;
        Operation.Verbose := Options.Verbose;
        Operation.ReferenceMPFolderPath := ReferenceMPFolderPath;
        Operation.ReferenceMPExePath := ReferenceMPExePath;
        if not DirectoryExists(Operation.ReferenceMPFolderPath) then
        begin
          Log(Format('ERROR: Reference MP folder %s does not exist.', [Operation.ReferenceMPFolderPath]));
          exit;
        end;
        if not FileExists(Operation.ReferenceMPExePath) then
        begin
          Log(Format('ERROR: Reference MP executable %s does not exist.', [Operation.ReferenceMPExePath]));
          exit;
        end;

        ProcessPrograms(ProgramFiles, Operation);
        Operation.WriteLog(inputFolderPath);
        Operation.Free;
      end;

      if (Options.COMPARE) then
      begin
        Operation := TOperation.Create(TAction.COMPARE);
        Operation.Threads := 1;
        Operation.Verbose := Options.Verbose;

        // Path are required to normalize the comparison inputs.
        Operation.MPFolderPath := MPFolderPath;
        Operation.MPExePath := MPExePath;
        Operation.ReferenceMPFolderPath := ReferenceMPFolderPath;
        Operation.ReferenceMPExePath := ReferenceMPExePath;

        ProcessPrograms(ProgramFiles, Operation);

        if (Operation.DiffFilePaths.Count = 0) then
        begin
          Log('All generated .A65 files are identical.');
        end
        else
        begin
          Operation.LogMessages.Add(Format('Found %s.',
            [GetCountText(Operation.DiffFilePaths.Count, 'different file', 'different files')]));
          Operation.LogMessages.AddStrings(Operation.DiffFilePaths);
        end;

        operationResultFilePath := Operation.GetLogFilePath(inputFolderPath);
        operationResultFileExists := Operation.WriteLog(inputFolderPath);

        if (Options.OpenResults and operationResultFileExists) then
        begin
          FileResult := Default(TFileResult);
          FileResult.FilePath := 'All';
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

        Operation.Free;

      end;

      if (Options.CleanupResults) then
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

  Options := Default(TOptions);
  InitCriticalSection(CS);
  StartTickCount := GetTickCount64;
  try
    Main;
  except
    on e: Exception do
    begin
      ShowException(e, ExceptAddr);
    end;
  end;
  EndTickCount := GetTickCount64;
  Duration := Max(EndTickCount - StartTickCount, 1);
  Seconds := Trunc(Duration / 1000);
  Minutes := Trunc(Seconds / 60);
  Seconds := Seconds - Minutes * 60;
  Log(Format('Main completed after %d minutes, %d seconds.', [Minutes, Seconds]));
  if (Options.WaitForKey) then
  begin
    Log('Press any key.');
    repeat
    until keypressed;
  end;
  DoneCriticalSection(CS);
end.
