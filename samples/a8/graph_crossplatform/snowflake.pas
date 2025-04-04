// Koch Snowflake
// https://en.wikipedia.org/wiki/Koch_snowflake

// float16	186
// real		197
// single	237


uses crt, graph, sysutils,
     snowflake_unit_real in 'snowflake_unit_real.pas',
     snowflake_unit_single in 'snowflake_unit_single.pas';

procedure WaitForKey;
begin
  repeat 
  until KeyPressed;
  ReadKey;
  repeat 
  until not KeyPressed;
end;

procedure Snowflake;

const FLOAT_TYPES : array of String = [
{$IFDEF FLOAT16} // TODO does not work yet
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
    {$IFDEF Float16}
    if floatType = 'Float16' then snowflake_unit_float16.CreateKochSnowflake;
    {$ENDIF}
    if floatType = 'Real'    then snowflake_unit_real.CreateKochSnowflake;
    if floatType = 'Single'  then snowflake_unit_single.CreateKochSnowflake;
  
    ticks := GetTickCount - ticks;
  
    WaitForKey;
  
    WriteLn('Koch Snowflake with type ''',floatType,'''.');
    Writeln('Time required: ', ticks,' ticks');
    WriteLn('Press any key to continue.');
    WaitForKey;

  end;
  
 end;

begin
Snowflake;
end.

