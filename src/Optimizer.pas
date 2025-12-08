// Preliminary class

unit Optimizer;


interface

uses CompilerTypes, FileIO, Targets;

type
  IOptimizer = interface

    procedure Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray; const aTarget: TTarget);

    procedure StartOptimization(SourceLocation: TSourceLocation);

    // Re/Set temporary varitables for register optimizations.
    procedure ResetOpty;
    procedure SetOptyY(const Value: TString);
    function GetOptyBP2(): TString;
    procedure SetOptyBP2(const Value: TString);

    procedure ASM65Internal(const a: String; const comment: String; const optimizeCode: Boolean;
      const CodeSize: Integer; const IsInterrupt: Boolean);

    function IsASM65BufferEmpty: Boolean;

    procedure Finalize;

  end;

// Dummy optimizier for pass 1
function CreateDummyOptimizer: IOptimizer;

// Default optimizer for pass 2
function CreateDefaultOptimizer: IOptimizer;

implementation

uses Optimize;

type
  TDummyOptimizer = class(TInterfacedObject, IOptimizer)

  public
    constructor Create;

    procedure Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray; const aTarget: TTarget);

    procedure StartOptimization(SourceLocation: TSourceLocation);

    // Re/Set temporary varitables for register optimizations.
    procedure ResetOpty;
    procedure SetOptyY(const Value: TString);
    function GetOptyBP2(): TString;
    procedure SetOptyBP2(const Value: TString);

    procedure ASM65Internal(const a: String; const comment: String; const optimizeCode: Boolean;
      const CodeSize: Integer; const IsInterrupt: Boolean);

    function IsASM65BufferEmpty: Boolean;

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

end;

procedure TDummyOptimizer.SetOptyBP2(const Value: TString);
begin

end;

procedure TDummyOptimizer.ASM65Internal(const A: String; const Comment: String;
  const OptimizeCode: Boolean; const CodeSize: Integer; const IsInterrupt: Boolean);
begin

end;

function TDummyOptimizer.IsASM65BufferEmpty: Boolean;
begin
  Result := True;
end;

procedure TDummyOptimizer.Finalize;
begin
end;


type
  TOptimizer = class(TInterfacedObject, IOptimizer)

  public
    constructor Create;

    procedure Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray; const aTarget: TTarget);

    procedure StartOptimization(SourceLocation: TSourceLocation);

    // Re/Set temporary varitables for register optimizations.
    procedure ResetOpty;
    procedure SetOptyY(const Value: TString);
    function GetOptyBP2(): TString;
    procedure SetOptyBP2(const Value: TString);

    procedure ASM65Internal(const a: String; const comment: String; const optimizeCode: Boolean;
      const CodeSize: Integer; const IsInterrupt: Boolean);

    function IsASM65BufferEmpty: Boolean;

    procedure Finalize;

  private

  end;

constructor TOptimizer.Create;
begin
end;

procedure TOptimizer.Initialize(const aOutFile: ITextFile; const aAsmBlockArray: TAsmBlockArray;
  const aTarget: TTarget);
begin
  Optimize.Initialize(aOutFile, aAsmBlockArray, aTarget);
end;

procedure TOptimizer.StartOptimization(SourceLocation: TSourceLocation);
begin
  Optimize.StartOptimization(SourceLocation);
end;

// Re/Set temporary varitables for register optimizations.
procedure TOptimizer.ResetOpty;
begin
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

procedure TOptimizer.ASM65Internal(const A: String; const Comment: String; const OptimizeCode: Boolean;
  const CodeSize: Integer; const IsInterrupt: Boolean);
begin
  Optimize.ASM65Internal(A, Comment, OptimizeCode, CodeSize, IsInterrupt);
end;

function TOptimizer.IsASM65BufferEmpty: Boolean;
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

function CreateDefaultOptimizer: IOptimizer;
begin
  Result := TOptimizer.Create;
end;


end.
