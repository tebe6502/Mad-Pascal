unit Utilities;

interface

{$i define.inc}
{$i Types.inc}

type
  TEnvironment = class
    class function GetParameterCount(): Longint;
    class function GetParameterString(const i: Longint): String;
    class function GetParameterStringUpperCase(const i: Longint): String;
  end;

type
  THaltException = class
  type TExitCode = Longint;

  const
    OK: TExitCode = 0;
    // No errors occurred, the output files were created correctly
  const
    COMPILING_ABORTED: TExitCode = 2;     // Errors occurred, and compiling was aborted
  const
    COMPILING_NOT_STARTED: TExitCode = 3;
    // Wrong parameters were specified, and compiling was not started

  private
    exitCode: Longint;

  public
    constructor Create(exitCode: Longint);
    function GetExitCode: Longint;
  end;

// Replaces https://www.freepascal.org/docs-html/rtl/system/halt.html
procedure RaiseHaltException(errnum: Longint = 0);

{$IFDEF PAS2JS}
  {$I 'include\pas2js\Utilities-PAS2JS-Interface.inc'}
{$ELSE}

{$ENDIF}

implementation

uses SysUtils;

class function TEnvironment.GetParameterCount(): Longint;
begin
{$IFNDEF PAS2JS}
   Result:=ParamCount;
{$ELSE}
  Result := 3;
{$ENDIF}
end;

class function TEnvironment.GetParameterString(const i: Longint): String;
begin
   {$IFNDEF PAS2JS}
      Result:=ParamStr(i);
   {$ELSE}
  case i of
    1: Result := 'Input.pas';
    2: Result := '-i:lib';
    3: Result := '-o:Output.a65';
  end;
   {$ENDIF}
end;

class function TEnvironment.GetParameterStringUpperCase(const i: Longint): String;
begin
  Result := AnsiUpperCase(GetParameterString(i));
end;

// ----------------------------------------------------------------------------

constructor THaltException.Create(exitCode: Longint);
begin
  Self.exitCode := exitCode;
end;

function THaltException.GetExitCode: Longint;
begin
  Result := exitCode;
end;

procedure RaiseHaltException(errnum: Longint);
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

{$ENDIF}

end.
