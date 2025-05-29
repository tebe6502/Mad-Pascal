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

  TAction = (CLEANUP, COMPILE, CLEANUP_REFERENCE, COMPILE_REFERENCE, COMPARE);

  TOperation = record
    threads: Integer;
    action: TAction;
    verbose: Boolean;
    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;
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
      //WriteLn(line);

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

  procedure ProcessProgram(const FilePath: TFilePath; const operation: TOperation);
  var
    curDir: TFolderPath;
    fileName: String;
    exename: TProcessString;
    commands: array of TProcessString;
    outputString: TProcessString;
  begin
    if (operation.verbose) then
    begin
      Writeln(Format('Processing program %s with action %s and MP path %s.',
        [filePath, GetActionString(operation), operation.mpExePath]));
    end;

    curDir := ExtractFilePath(FilePath);
    fileName := ExtractFileName(FilePath);
    exename := operation.mpExePath;
    commands := ['-ipath:' + CreateAbsolutePath('lib', operation.mpFolderPath), fileName];
    if RunCommandIndir(curDir, exename, commands, outputString) then
    begin

    end
    else
    begin
      WriteLn(Format('ERROR: Cannot compile "%s".', [fileName]));
      WriteLn(Format('ERROR: Command "%s %s" failed.', [cmdLine, CommandsToString(commands)]));
      WriteLn(Format('%s', [outputString]));
      WriteLn;
    end;

  end;


  procedure ProcessProgramAtIndex(const ProgramFiles: TStringList; const index: Integer; const operation: TOperation);
  begin
    Writeln(Format('Processing program %d of %d (%d%%) with action %s.',
      [index, ProgramFiles.Count, Trunc(index / ProgramFiles.Count), GetActionString(Operation)]));
    Flush(Output);
    ProcessProgram(ProgramFiles[index - 1], operation);
    Flush(Output);
  end;

type
  TParalelData = record
    ProgramFiles: TStringList;
    operation: TOperation
  end;

  procedure ProcessProgramParallel(Index: PtrInt; Data: Pointer; Item: TMultiThreadProcItem);
  var
    parallelData: ^TParalelData;
  begin
    parallelData := Data;
    ProcessProgramAtIndex(parallelData^.ProgramFiles, Index, parallelData^.operation);

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
    WriteLn(Format('Scanning folder %s for Pascal source files.', [samplesFolderPath]));
    PascalFiles := FindAllFiles(samplesFolderPath, '*.pas', True);
    ProgramFiles := TStringList.Create;
    try
      maxFiles := High(Integer);
      maxFiles := 1;
      if maxFiles > PascalFiles.Count then  maxFiles := PascalFiles.Count;
      WriteLn(Format('Scanning %d of %d Pascal source files for programs.', [maxFiles, PascalFiles.Count]));
      for i := 1 to maxFiles do
      begin
        filePath := PascalFiles[i - 1];
        // WriteLn(Format('Scanning file %s (%d of %d)', [filePath, i, maxFiles]));
        fileType := GetFileType(filePath);
        case fileType
          of
          TFileType.UNKNOWN:
          begin
            if (verbose) then
            begin
              WriteLn(Format('WARNING: Skipping file %s with unkown file type.', [filePath]));
            end;
          end;
          TFileType.TPROGRAM: begin
            ProgramFiles.Add(filePath);
          end;
        end;
      end;
      operation.threads := 2;
      WriteLn(Format('Processing %d Pascal program with %d Threads.', [ProgramFiles.Count, operation.threads]));
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
    finally
      ProgramFiles.Free;
      PascalFiles.Free;
    end;
  end;

begin
  try
    Main;
  except
    on e: Exception do
    begin
      ShowException(e, ExceptAddr);
    end;
  end;
  Writeln('Main completed. Press any key.');
  repeat
  until keypressed;
end.
