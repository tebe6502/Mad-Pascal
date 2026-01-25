unit OptimizerTypes;

interface

type
  TListingIndex = Integer;
  TListing = array [0..1023] of String;

type
  TOptimizerFunction = function(i: TListingIndex): Boolean;

type
  TOptimizerStep = record
    Name: String;
    OptimizerFunction: TOptimizerFunction;
  end;

type
  TOptimizerStepArray = array of TOptimizerStep;


type
  TOptimizerStepList = class
  public
    function IsEmpty: Boolean;
    procedure AddOptimizerStep(const Name: String; const OptimizerFunction: TOptimizerFunction);
    function Optimize(const i: TListingIndex): Boolean;
  private
  var
    OptimizerStepArray: TOptimizerStepArray;
  end;



implementation


function TOptimizerStepList.IsEmpty: Boolean;
begin
  Result := (OptimizerStepArray = nil);

end;

procedure TOptimizerStepList.AddOptimizerStep(const Name: String; const OptimizerFunction: TOptimizerFunction);
var
  i: Integer;
  OptimizerStep: TOptimizerStep;
begin

  OptimizerStep.Name := Name;
  OptimizerStep.OptimizerFunction := OptimizerFunction;
  i := Length(OptimizerStepArray);
  SetLength(OptimizerStepArray, i + 1);
  OptimizerStepArray[i] := OptimizerStep;

end;

function TOptimizerStepList.Optimize(const i: TListingIndex): Boolean;
var
  j: Integer;
begin
  for j := 0 to Length(OptimizerStepArray)-1 do
  begin
    if OptimizerStepArray[j].OptimizerFunction(i) = False then
    begin
      Exit(False);
    end;
  end;
  Result := True;

end;

end.
