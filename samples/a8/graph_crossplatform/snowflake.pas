// Koch Snowflake
//
// See https://en.wikipedia.org/wiki/Koch_snowflake

// Float16  186 ticks
// Real     197 ticks
// Single   237 ticks

program snowflake;

uses
  Crt,
  graph,
  SysUtils;

const FLOAT_TYPES : array of String = [
{$IFDEF Float16}
'Float16',
{$ENDIF}
'Real',
'Single' ];

var
  gd, gm: Smallint;

  ticks: Cardinal;

{$IFDEF Float16}
procedure CreateKochSnowflake_Float16;
type
  TFloat = Float16;
{$I snowflake.inc}
{$ENDIF}

procedure CreateKochSnowflake_Real;
type
  TFloat = Real;
{$I snowflake.inc}

procedure CreateKochSnowflake_Single;
type
  TFloat = Single;
{$I snowflake.inc}

var floatType: String;
begin

  for floatType in FLOAT_TYPES do
  begin

  gd := D8bit;
  gm := m640x480;

  InitGraph(gd, gm, '');

  ticks := GetTickCount;

  {$IFDEF Float16}
  if floatType = 'Float16' then CreateKochSnowflake_Float16;
  {$ENDIF}
  if floatType = 'Real'    then CreateKochSnowflake_Real;
  if floatType = 'Single'  then CreateKochSnowflake_Single;

  ticks := GetTickCount - ticks;

  repeat
  until keypressed;

  WriteLn('Koch Snowflake with type ''',floatType,''' required ', ticks,' ticks.');
  end;

  while True do ;

end.