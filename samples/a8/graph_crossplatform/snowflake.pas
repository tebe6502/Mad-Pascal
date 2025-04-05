// Koch Snowflake
// https://en.wikipedia.org/wiki/Koch_snowflake

// For every supported data type, a separate unit with the same code is used.
// Float16	186 ticks
// Real		197 ticks
// Single	237 ticks

//FPC does not have Float16
{$IFNDEF FPC}
{$DEFINE HAS_FLOAT16}
{$ENDIF}

uses crt, graph, sysutils,
     {$IFDEF HAS_FLOAT16}
     snowflake_unit_float16 in 'snowflake_unit_float16.pas',
     {$ENDIF}
     snowflake_unit_real in 'snowflake_unit_real.pas',
     snowflake_unit_single in 'snowflake_unit_single.pas';

procedure Snowflake;

const FLOAT_TYPES : array of String = [
{$IFDEF HAS_FLOAT16}
'Float16',
{$ENDIF}
'Real',
'Single' ];

var gd, gm: SmallInt;
var ticks: Cardinal;
var i: Byte;
var floatType: String;
begin

  for i:=Low(FLOAT_TYPES) to High(FLOAT_TYPES) do
  begin

    gd := D8bit;
    gm := m640x480;
  
    InitGraph(gd, gm, '');
  
    ticks := GetTickCount;
    
    floatType:=FLOAT_TYPES[i];
    {$IFDEF HAS_FLOAT16}
    if floatType = 'Float16' then snowflake_unit_float16.CreateKochSnowflake;
    {$ENDIF}
    if floatType = 'Real'    then snowflake_unit_real.CreateKochSnowflake;
    if floatType = 'Single'  then snowflake_unit_single.CreateKochSnowflake;
  
    ticks := GetTickCount - ticks;
  
    ReadKey;
  
    WriteLn('Koch Snowflake with type ''',floatType,'''.');
    Writeln('Time required: ', ticks,' ticks');
    WriteLn('Press any key to continue.');
    ReadKey;

  end;
  
 end;

begin
Snowflake;
end.

