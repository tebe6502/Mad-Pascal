unit Utilities;

{$I Defines.inc}

interface

uses SysUtils;

type
  TExitCode = Longint;

type
  TEnvironment = class
    class function GetParameterCount(): Longint;
    class function GetParameterString(const i: Longint): String;
    class function GetParameterStringUpperCase(const i: Longint): String;
  end;

type
  THaltException = class(Exception)

  const
    // No errors occurred, the output files were created correctly
    OK: TExitCode = 0;
    // Errors occurred, and compiling was aborted
    COMPILING_ABORTED: TExitCode = 2;
    // Wrong parameters were specified, and compiling was not started
    COMPILING_NOT_STARTED: TExitCode = 3;

  private
    exitCode: TExitCode;

  public
    constructor Create(exitCode: TExitCode);
    function GetExitCode: TExitCode;
  end;

// Replaces https://www.freepascal.org/docs-html/rtl/system/halt.html
procedure RaiseHaltException(errnum: Longint);

{$IFDEF PAS2JS}
  {$I 'include\pas2js\Utilities-PAS2JS-Interface.inc'}
{$ELSE}

{$ENDIF}

implementation

class function TEnvironment.GetParameterCount(): Longint;
begin
{$IFNDEF SIMULATED_COMMAND_LINE}
  Result := ParamCount;
{$ELSE}
  Result := 4;
{$ENDIF}
end;

class function TEnvironment.GetParameterString(const i: Longint): String;
begin
   {$IFNDEF SIMULATED_COMMAND_LINE}
  Result := ParamStr(i);
   {$ELSE}
  case i of
    1: Result := 'Input.pas';
    2: Result := '-ipath:lib';
    3: Result := '-o:Output.a65';
    4: Result := '-diag';
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
  raise THaltException.Create(errnum);
end;

{$IFDEF PAS2JS}
  {$I 'include\pas2js\Utilities-PAS2JS-Implementation.inc'}
{$ELSE}

{$ENDIF}

end.
