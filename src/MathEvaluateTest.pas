unit MathEvaluateTest;

interface

procedure Test;

implementation

uses Classes, CommonTypes, MathEvaluate, SysUtils;

type
  TTestEvaluationContext = class(TInterfacedObject, IEvaluationContext)
  public
    constructor Create;
    function GetConstantName(const expression: String; var index: Integer): String;
    function GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  end;

constructor TTestEvaluationContext.Create;
begin
end;

function TTestEvaluationContext.GetConstantName(const expression: String; var index: Integer): String;
const
  EXAMPLE = 'EXAMPLE';
begin
  if (Copy(expression, index, Length(EXAMPLE)) = EXAMPLE) then
  begin
    Result := EXAMPLE;
    Inc(index, Length(EXAMPLE));
  end;
end;

function TTestEvaluationContext.GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
begin
  if constantName = 'EXAMPLE' then
  begin
    constantValue := 1;
    Result := True;
  end
  else
  begin
    constantValue := 0;
    Result := False;
  end;
end;

procedure Test;


  procedure AssertValue(const expression: String; expectedValue: TEvaluationResult);
  var
    evaluationContext: IEvaluationContext;
    actualValue: TEvaluationResult;
  begin
    evaluationContext := TTestEvaluationContext.Create;
    actualValue := MathEvaluate.Evaluate(expression, evaluationContext);
    Assert(actualValue = expectedValue,
      'Expression ''' + expression + ''' was evaluated to value ' + FloatToStr(actualValue) +
      ' instead of ' + FloatToStr(expectedValue) + '.');
  end;

  procedure AssertException(const expression: String; expectedIndex: Integer; expectedMessage: String);
  var
    evaluationContext: IEvaluationContext;
  begin
    evaluationContext := TTestEvaluationContext.Create;
    try
      MathEvaluate.Evaluate(expression, evaluationContext);
      Assert(False, 'Expected exception ''' + expectedMessage + ''' for expression ''' +
        expression + ''' not raised.');
    except
      on ex: EEvaluationException do
      begin
        Assert(ex.Message = expectedMessage, 'Expected exception ''' + expectedMessage +
            ''' for expression ''' + expression + ''' raised with different text ''' + ex.Message + '''.');
        Assert(ex.Index = expectedIndex, 'Expected exception ''' + expectedMessage +
            ''' for expression ''' + expression + ''' raised with different index ' +
          IntToStr(ex.Index) + ' instead of ' + IntToStr(expectedIndex) + '.');

      end;
    end;

  end;

begin

  AssertValue('', 0);
  AssertValue('(1+2)*3+1+100/10', 20);
  AssertValue('$1234+$2345', $1234 + $2345);
  AssertValue('%111011010', $1da);   // There is no binary in Delphi

  AssertException('(', 2, 'Parenthesis Mismatch');
end;

end.
