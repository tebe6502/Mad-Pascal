  // JAC!
var
  DebugCount: Integer;


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


var
  BreakpointHit: Boolean;

procedure DebugCall(const Name: String; const message: String = '');
var
  l, s: String;
begin
  Inc(DebugCount);
  l := '';
  if optimize.SourceFile <> nil then l := Format('%s:%d', [optimize.SourceFile.Name, optimize.line]);
  s := Format('Debug: %s: Call %d with ''%s''. (optyA=''%s'', optyY=''%s'', optyBP2=''%s'', SourceLocation:%s)',
    [Name, DebugCount, message, _optyA, optyY, optyBP2, l]);
  WriteLn(StdErr, s);
  if DebugCount = BreakPointDebugCount then
  begin
    BreakpointHit := True;
  end;
end;

function ExitTrick(const i: Integer; const fileName: String; const lineNumber: String;
  const currentRoutine: String): Boolean;
begin
  Result := False;
  if BreakpointHit then
  begin
    DebugCall('ExitTrick', Format('i=%d in %s at %s:%s', [i, currentRoutine, fileName, lineNumber]));
  end;
end;

