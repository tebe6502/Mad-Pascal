// Preliminary class

unit Optimizer;


interface

uses CompilerTypes, CommonIO, Targets;

type
  IOptimizer = interface

    procedure Initialize(const Target: TTarget; const AsmBlockArray: TAsmBlockArray;
      const AsmBlockArrayHigh: Integer; const Writer: IWriter);

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
function CreateDefaultOptimizer(LogWriter: IWriter = nil): IOptimizer;


implementation

uses SysUtils, Optimize, OptimizeTemporary;

type
  TDummyOptimizer = class(TInterfacedObject, IOptimizer)

  public
    constructor Create;

    procedure Initialize(const Target: TTarget;
  const AsmBlockArray: TAsmBlockArray; const AsmBlockArrayHigh: Integer; const Writer: IWriter);

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

procedure TDummyOptimizer.Initialize(const Target: TTarget;
  const AsmBlockArray: TAsmBlockArray; const AsmBlockArrayHigh: Integer; const Writer: IWriter);
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
    constructor Create(LogWriter: IWriter);

    procedure Initialize(const Target: TTarget;
  const AsmBlockArray: TAsmBlockArray; const AsmBlockArrayHigh: Integer; const Writer: IWriter);

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
    LogWriter: IWriter;

  end;

constructor TOptimizer.Create(LogWriter: IWriter);
begin
  Self.LogWriter := LogWriter;
end;

procedure TOptimizer.Initialize(const Target: TTarget;
  const AsmBlockArray: TAsmBlockArray; const AsmBlockArrayHigh: Integer; const Writer: IWriter);
var
  i: Integer;
  OptimizeTemporary: IOptimizeTemporary;
begin
  if (LogWriter <> nil) then
  begin
    LogWriter.WriteLn(Format('Initialize(AsmBlockArray=[%d..%d])', [Low(AsmBlockArray), AsmBlockArrayHigh]));
    for i := Low(AsmBlockArray) to AsmBlockArrayHigh do
    begin
      LogWriter.WriteLn(Format('AsmBlockArray[%d]=''%s'')', [i, AsmBlockArray[i]]));
    end;
  end;
  OptimizeTemporary := TOptimizeTemporary.Create;
  OptimizeTemporary.Initialize(AsmBlockArray, Writer);
  Optimize.Initialize(Target, OptimizeTemporary);
end;

procedure TOptimizer.StartOptimization(SourceLocation: TSourceLocation);
begin
  Assert(SourceLocation.SourceFile <> nil, 'SourceLocation.SourceFile must not be nil.');
  if (LogWriter <> nil) then
  begin
    LogWriter.WriteLn(Format('StartOptimization(SourceLocation=%s)', [SourceLocationToString(SourceLocation)]));
  end;

  Optimize.StartOptimization(SourceLocation);
end;

// Re/Set temporary variables for register optimizations.
procedure TOptimizer.ResetOpty;
begin
  if (LogWriter <> nil) then
  begin
    LogWriter.WriteLn('ResetOpty()');
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
  if (LogWriter <> nil) then
  begin
    LogWriter.WriteLn(Format('AssembleLine(Line=''%s'', Comment=''%s'', OptimizeCode=%s, CodeSize=%d, IsInterrupt=%s)',
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

function CreateDefaultOptimizer(LogWriter: IWriter = nil): IOptimizer;
begin
  Result := TOptimizer.Create(LogWriter);
end;


end.
