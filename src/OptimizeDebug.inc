  // JAC!
var
  BreakPointDebugCount: Integer = 2016;
  BreakPointASM65Count: Integer = 590;

var
  DebugCount: Integer;
  ASM65Count: Integer;


var
  BreakpointDebugCountHit: Boolean;
  BreakpointASM65CountHit: Boolean;

function OptimizeBufToString: String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(OptimizeBuf) - 1 do Result := Result + OptimizeBuf[i] + '/';
end;

function TemporaryBufToString: String;
var
  i: Integer;
begin
  Result := '';
  {$IFDEF MP175}
  for i := 0 to TemporaryBufIndex - 1 do Result := Result + TemporaryBuf[i] + '/';
  {$ELSE}
  for i := 0 to iOut - 1 do Result := Result + TemporaryBuf[i] + '/';
  {$ENDIF}
end;


procedure LogTrace(const message: String);
begin
  WriteLn(StdErr, message);
end;

procedure DebugCall(const Name: String; const message: String = '');
var
  l, s: String;
begin
  if BreakPointDebugCount <= 0 then exit;

  Inc(DebugCount);
  l := '';    // Because of line differences between versions
  {$IFDEF MP175}
  if optimize.SourceFile <> nil then l := Format('%s:%d', [optimize.SourceFile.Name, optimize.line]);
  {$ELSE}
  if Common.optimize.unitIndex <> 0 then
    l := Format('%s:%d', [UnitName[Common.optimize.unitIndex].Name, Common.optimize.line]);
  {$ENDIF}

  s := Format('Debug: %s: Call %d with ''%s''. (optyA=''%s'', optyY=''%s'', optyBP2=''%s'', SourceLocation:%s)',
    [Name, DebugCount, message, _optyA, optyY, optyBP2, l]);
  LogTrace(s);
  if DebugCount = BreakPointDebugCount then
  begin
    BreakpointDebugCountHit := True;
  end;
end;


procedure LogState(const a: String = ''; const comment: String = '');
begin

  if BreakPointDebugCount <= 0 then exit;
  Inc(ASM65Count);
  LogTrace(Format('asm65(%d, ''%s'', ''%s'' )', [ASM65Count, a, comment]));
  if ASM65Count = BreakPointASM65Count then
  begin
    BreakpointASM65CountHit := True;
  end;
end;
// ----------------------------------------------------------------------------


function ExitTrick(const optRoutine: String; const i: Integer; const fileName: String;
  lineNumber: String; const currentRoutine: String): Boolean;
begin
  Result := False;
  lineNumber := ''; // TODO
  if BreakpointDebugCountHit then
  begin
    DebugCall('ExitTrick', Format('%s(%d) in %s at %s:%s', [optRoutine, i, currentRoutine, fileName, lineNumber]));
  end;
end;


procedure LogStringArray(const Name: String; const stringArray: TStringArray);
var
  l, i: Integer;
begin
  l := High(stringArray);
  LogTrace(Format('High(%s)=%d', [Name, l]));
  for i := 0 to l do LogTrace(Format('%s[%d]=%s', [Name, i, stringArray[i]]));
end;

procedure LogOptimizeBuf();
begin
  LogStringArray('OptimizeBuf', OptimizeBuf);
end;
