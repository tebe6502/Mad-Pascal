unit Utilities;

interface

{$i define.inc}
{$i Types.inc}

type THaltException = class
  private
    exitCode: LongInt;

  public
    constructor Create(exitCode: LongInt);
    function GetExitCode: LongInt;    
end;

// Replaces https://www.freepascal.org/docs-html/rtl/system/halt.html
procedure RaiseHaltException( errnum: LongInt = 0 );

{$IFDEF PAS2JS}
  {$I 'include\pas2js\Utilities-PAS2JS-Interface.inc'}
{$ELSE}
  procedure MoveSingle(i: Integer; s: Single);
{$ENDIF}

implementation

constructor THaltException.Create(exitCode: LongInt);
begin
  Self.exitCode := exitCode;
end;

function THaltException.GetExitCode: LongInt;
begin
  Result := exitCode;
end;

procedure RaiseHaltException( errnum: LongInt );
begin
{$IFDEF PAS2JS}
  raise THaltException.Create(errnum);
{$ELSE}
  halt(errnum);
{$ENDIF}

end;

{$IFDEF PAS2JS}
  {$I 'include\pas2js\Utilities-PAS2JS-Implementation.inc'}
{$ELSE}

procedure MoveSingle(i: Integer; s: Single);
begin
end;
 
{$ENDIF}

end.
