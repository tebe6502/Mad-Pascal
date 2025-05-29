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

type
  TFileType = (UNKNOWN, TPROGRAM, TUNIT, TINCLUDE);

  TAction = (CLEANUP, COMPILE, CLEANUP_REFERENCE, COMPILE_REFERENCE, COMPARE);

  TOperation = record
    threads: Integer;
    action: TAction;
    verbose: Boolean;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;
    diffFilePaths: TStringList;
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
      Log(Format('ERROR: Cannot run "%s".', [title]));
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

  function CompareA65File(curDir: TFolderPath; a65FileName, a65ReferenceFileName: String;
    operation: TOperation): Boolean;
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
      Lines.LoadFromFile(a65FilePath);
      ReferenceLines.LoadFromFile(a65ReferenceFilePath);

      if (Lines.Count < 3) then
      begin
        Log(Format('ERROR: %s', [a65FilePath]));
        Log('ERROR: Not enough lines in output.');
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
        // TODO: PMCNTL  = $D01D is temporary
        while (i < Lines.Count) and ((line = '') or (line = 'PMCNTL'#9'= $D01D')) do
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
            Log(Format('ERROR: %s', [diffFilePath]));
          end;

          Log(Format('%d: %-40s %-40s ', [i, LeftStr(line, 40), LeftStr(referenceLine, 40)]));
          Inc(diffs);

          if (diffs > MAX_DIFFS) then exit;
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

  function ProcessProgram(const FilePath: TFilePath; operation: TOperation): Boolean;
  var
    curDir: TFolderPath;
    fileName: String;
    a65BaseFileName: String;
    a65FileName: String;
    a65ReferenceFileName: String;
  begin
    Result := False;

    if (operation.verbose) then
    begin
      Log(Format('Processing program %s with action %s and MP path %s.',
        [filePath, GetActionString(operation), operation.mpExePath]));
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
        Result := RunMadPascal(operation, curDir, fileName, a65FileName);
      end;

      TAction.COMPILE_REFERENCE:
      begin
        Result := RunMadPascal(operation, curDir, fileName, a65ReferenceFileName);
      end;

      TAction.COMPARE:
      begin
        Result := CompareA65File(curDir, a65FileName, a65ReferenceFileName, operation);

      end;
      else
        Assert(False, 'Unsupported action ' + GetActionString(operation));
    end;

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
    application: TCustomApplication;
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

    diffFilesListFilePath: TFilePath;
  begin
    //   application:=  TCustomApplication.Create;
    //    Application.Initialize;
    //   Application.Run;

    verbose := False;

    // TODO: Make these command line parameters.
    wudsnFolderPath := GetEnvironmentVariable('WUDSN_TOOLS_FOLDER');
    referenceMPFolderPath := CreateAbsolutePath('PAS\MP', wudsnFolderPath);
    referenceMPExePath := CreateAbsolutePath('bin\windows\mp.exe', referenceMPFolderPath);

    mpFolderPath := 'C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal';
    mpExePath := CreateAbsolutePath('src\mp.exe', mpFolderPath);

    samplesFolderPath := CreateAbsolutePath('samples', mpFolderPath);
    diffFilesListFilePath := CreateAbsolutePath('WinMerge.txt', samplesFolderPath);
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
      operation.threads := 1; // TODO
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

      operation.threads := 1;
      operation.action := TAction.COMPARE;
      operation.verbose := verbose;
      operation.mpFolderPath := '';
      operation.mpExePath := '';
      operation.diffFilePaths := TStringList.Create;
      ProcessPrograms(ProgramFiles, operation);
      if (operation.diffFilePaths.Count = 0) then
      begin
        Log('All files are identical.');
        DeleteFile(diffFilesListFilePath);
      end
      else
      begin
        Log(Format('Found %d different files.', [operation.diffFilePaths.Count]));
        Log(Format('WinMerge file list is stored in %s.', [diffFilesListFilePath]));
        operation.diffFilePaths.SaveToFile(diffFilesListFilePath);
        RunExecutable('File List', '', 'CMD.EXE', ['/C', diffFilesListFilePath]);
        RunExecutable('WinMerge', '', 'CMD.EXE', ['/C', operation.diffFilePaths[0]]);
      end;
      operation.diffFilePaths.Free;

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
  // repeat  until keypressed;
  DoneCriticalSection(cs);
end.
