program MakeMadPascal;

{$I Defines.inc}
{$ScopedEnums ON}

uses
  Crt,
  Common,
  CommonTypes,
  CompilerTypes,
  Classes,
  Datatypes,
  FileIO,
  MathEvaluate,
  Messages,
  Optimize,
  Tokens,
  Utilities,
  FileUtil,
  LazFileUtils,
  StringUtilities,
  SysUtils;

type
  TFileType = (UNKNOWN, TPROGRAM, TUNIT, TINCLUDE);

  TAction = (CLEANUP, COMPILE, CLEANUP_REFERENCE, COMPILE_REFERENCE, COMPARE);

  TOperation = record
    action: TAction;
    verbose: Boolean;
    mpPath: TFilePath;
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

  procedure ProcessProgram(FilePath: TFilePath; operation: TOperation);
  var
    actionString: String;
  begin
    WriteStr(actionString, operation.action);
    if (operation.verbose) then
    begin
      Writeln(Format('Processing program %s with action %s and MP path %s.', [filePath, actionString, operation.mpPath]));
    end;
  end;

  procedure ProcessPrograms(ProgramFiles: TStringList; operation: TOperation);
  var
    i: Integer;
  begin
    for i := 1 to ProgramFiles.Count do
    begin
      ProcessProgram(ProgramFiles[i - 1], operation);
    end;

  end;


  procedure Main;

  var
    maxFiles: Integer;
    PascalFiles: TStringList;
    samplesFolderPath: TFolderPath;
    filePath: TFilePath;
    fileType: TFileType;
    ProgramFiles: TStringList;
    operation: TOperation;

    wudsnFolderPath: TFolderPath;
    referenceMPExePath: TFilePath;

    mpFolderPath: TFolderPath;
    mpExePath: TFilePath;

  begin
    wudsnFolderPath := GetEnvironmentVariable('WUDSN_TOOLS_FOLDER');
    referenceMPExePath := CreateAbsolutePath('PAS\MP\bin\windows\mp.exe', wudsnFolderPath);
    mpFolderPath := 'C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal';
    mpExePath := CreateAbsolutePath('src\mp.exe', mpFolderPath);
    samplesFolderPath:=  CreateAbsolutePath('samples', mpFolderPath);

    WriteLn(Format('Scanning folder %s for Pascal source files.', [samplesFolderPath]));
    PascalFiles := FindAllFiles(samplesFolderPath, '*.pas', True);
    ProgramFiles := TStringList.Create;
    try

      maxFiles := High(Integer);
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
            // WriteLn(Format('Skipping file %s with unkown file type.', [filePath]));
          end;

          TFileType.TPROGRAM:
          begin
            ProgramFiles.Add(filePath);
          end;

        end;

      end;

      WriteLn(Format('%d Pascal program files found.', [ProgramFiles.Count]));

            operation.action := TAction.COMPILE_REFERENCE;
      operation.verbose := true;
      operation.mpPath := referenceMPExePath;
      ProcessPrograms(ProgramFiles, operation) ;

      operation.action := TAction.COMPILE;
      operation.verbose := False;
      operation.mpPath := mpExePath;
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
