
var
  ASM65Count: Integer;
  ASM65CountBreakPoint: Integer = 0;  // Set as required
  ASM65CountBreakPointHit: Boolean;

  DebugCallCount: Integer;
  DebugCallCountBreakPoint: Integer = 0; // Set as required
  DebugCallCountBreakPointHit: Boolean;


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
  for i := 0 to TemporaryBufIndex - 1 do Result := Result + TemporaryBuf[i] + '/';
end;


procedure LogTrace(const message: String);
begin
  if (ASM65CountBreakPoint > 0) or (DebugCallCountBreakPoint > 0) then
  begin
    {$IFNDEF PAS2JS}
    WriteLn(StdErr, message);
    {$ELSE}
    WriteLn(message);
    {$ENDIF}
  end;
end;

procedure DebugCall(const Name: String; const message: String = '');
var
  l, s: String;
begin
  if DebugCallCountBreakPoint <= 0 then exit;

  Inc(DebugCallCount);
  l := '';    // Because of line differences between versions
  {$IFDEF MP175_TEST}
  if optimize.SourceFile <> nil then l := Format('%s:%d', [optimize.SourceFile.Name, optimize.line]);
  {$ELSE}
  if Common.optimize.unitIndex <> 0 then
    l := Format('%s:%d', [UnitName[Common.optimize.unitIndex].Name, Common.optimize.line]);
  {$ENDIF}

  s := Format('Debug: %s: Call %d with ''%s''. (optyA=''%s'', optyY=''%s'', optyBP2=''%s'', SourceLocation:%s)',
    [Name, DebugCallCount, message, optyA, optyY, optyBP2, l]);
  LogTrace(s);
  if DebugCallCount = DebugCallCountBreakPoint then
  begin
    DebugCallCountBreakPointHit := True;
  end;
end;


procedure LogASM65(const a: String = ''; const comment: String = '');
begin

  if DebugCallCountBreakPoint <= 0 then exit;
  Inc(ASM65Count);
  LogTrace(Format('asm65(%d, ''%s'', ''%s'' )', [ASM65Count, a, comment]));
  if ASM65Count = ASM65CountBreakPoint then
  begin
    ASM65CountBreakPointHit := True;
  end;
end;
// ----------------------------------------------------------------------------


// Log all optimization hits atfer debug calls were activted.
function ExitTrick(const optRoutine: String; const i: Integer; const fileName: String;
  lineNumber: String; const currentRoutine: String): Boolean;
begin
  Result := False;
  lineNumber := ''; // TODO are differnt in src/origin, so ignore for now
  if DebugCallCountBreakPointHit then
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
