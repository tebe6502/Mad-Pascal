// Preliminary class

unit Optimizer;


interface

uses CompilerTypes, FileIO, Targets;

type
  IOptimizer = interface

    procedure Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray; const aTarget: TTarget);

    procedure StartOptimization(SourceLocation: TSourceLocation);

    // Re/Set temporary variables for register optimizations.
    procedure ResetOpty;
    procedure SetOptyY(const Value: TString);
    function GetOptyBP2(): TString;
    procedure SetOptyBP2(const Value: TString);

    procedure AssembleLine(const Line: String; const Comment: String; const OptimizeCode: Boolean;
      const CodeSize: Integer; const IsInterrupt: Boolean);

    function IsAssemblyBufferEmpty: Boolean;

    procedure Finalize;

  end;

// Dummy optimizier for pass 1
function CreateDummyOptimizer: IOptimizer;

// Default optimizer for pass 2
function CreateDefaultOptimizer(logFile: ITextFile = nil): IOptimizer;

implementation

uses SysUtils, Optimize;

type
  TDummyOptimizer = class(TInterfacedObject, IOptimizer)

  public
    constructor Create;

    procedure Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray; const aTarget: TTarget);

    procedure StartOptimization(SourceLocation: TSourceLocation);

    // Re/Set temporary variables for register optimizations.
    procedure ResetOpty;
    procedure SetOptyY(const Value: TString);
    function GetOptyBP2(): TString;
    procedure SetOptyBP2(const Value: TString);

    procedure AssembleLine(const Line: String; const Comment: String; const OptimizeCode: Boolean;
      const CodeSize: Integer; const IsInterrupt: Boolean);

    function IsAssemblyBufferEmpty: Boolean;

    procedure Finalize;

  private

  end;

constructor TDummyOptimizer.Create;
begin
end;

procedure TDummyOptimizer.Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray;
  const aTarget: TTarget);
begin
end;

procedure TDummyOptimizer.StartOptimization(SourceLocation: TSourceLocation);
begin
end;

procedure TDummyOptimizer.ResetOpty;
begin
end;

procedure TDummyOptimizer.SetOptyY(const Value: TString);
begin
end;


function TDummyOptimizer.GetOptyBP2(): TString;
begin
  Result := '';
end;

procedure TDummyOptimizer.SetOptyBP2(const Value: TString);
begin

end;

procedure TDummyOptimizer.AssembleLine(const Line: String; const Comment: String;
  const OptimizeCode: Boolean; const CodeSize: Integer; const IsInterrupt: Boolean);
begin

end;

function TDummyOptimizer.IsAssemblyBufferEmpty: Boolean;
begin
  Result := True;
end;

procedure TDummyOptimizer.Finalize;
begin
end;


type
  TOptimizer = class(TInterfacedObject, IOptimizer)

  public
    constructor Create(LogFile: ITextFile);

    procedure Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray; const aTarget: TTarget);

    procedure StartOptimization(SourceLocation: TSourceLocation);

    // Re/Set temporary variables for register optimizations.
    procedure ResetOpty;
    procedure SetOptyY(const Value: TString);
    function GetOptyBP2(): TString;
    procedure SetOptyBP2(const Value: TString);

    procedure AssembleLine(const Line: String; const Comment: String; const OptimizeCode: Boolean;
      const CodeSize: Integer; const IsInterrupt: Boolean);

    function IsAssemblyBufferEmpty: Boolean;

    procedure Finalize;

  private
    LogFile: ITextFile;

  end;

constructor TOptimizer.Create(LogFile: ITextFile);
begin
  Self.logFile := LogFile;
end;

procedure TOptimizer.Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray;
  const aTarget: TTarget);
begin
  Optimize.Initialize(aOutFile, aAsmBlockArray, aTarget);
end;

procedure TOptimizer.StartOptimization(SourceLocation: TSourceLocation);
begin
  if (logFile <> nil) then
  begin
    LogFile.WriteLn(Format('StartOptimization(SourceLocation=%s)', [SourceLocationToString(SourceLocation)]));
  end;

  Optimize.StartOptimization(SourceLocation);
end;

// Re/Set temporary varitbles for register optimizations.
procedure TOptimizer.ResetOpty;
begin
  if (logFile <> nil) then
  begin
    LogFile.WriteLn('ResetOpty()');
  end;

  Optimize.ResetOpty;
end;

procedure TOptimizer.SetOptyY(const Value: TString);
begin
  Optimize.SetOptyY(Value);
end;


function TOptimizer.GetOptyBP2(): TString;
begin
  Result := Optimize.GetOptyBP2();
end;

procedure TOptimizer.SetOptyBP2(const Value: TString);
begin
  Optimize.SetOptyBP2(Value);
end;

procedure TOptimizer.AssembleLine(const Line: String; const Comment: String; const OptimizeCode: Boolean;
  const CodeSize: Integer; const IsInterrupt: Boolean);
begin
  if (LogFile <> nil) then
  begin
    LogFile.WriteLn(Format('AssembleLine(Line=''%s'', Comment=''%s'', OptimizeCode=%s, CodeSize=%d, IsInterrupt=%s)',
      [Line, Comment, BoolToStr(OptimizeCode, True), CodeSize, BoolToStr(IsInterrupt, True)]));
  end;
  Optimize.ASM65Internal(Line, Comment, OptimizeCode, CodeSize, IsInterrupt);
end;

function TOptimizer.IsAssemblyBufferEmpty: Boolean;
begin
  Result := Optimize.IsASM65BufferEmpty;
end;

procedure TOptimizer.Finalize;
begin
  Optimize.Finalize;
end;



function CreateDummyOptimizer: IOptimizer;
begin
  Result := TDummyOptimizer.Create;
end;

function CreateDefaultOptimizer(LogFile: ITextFile = nil): IOptimizer;
begin
  Result := TOptimizer.Create(LogFile);
end;


end.
