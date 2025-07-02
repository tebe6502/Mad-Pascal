unit snowflake_unit_float16;

interface

procedure CreateKochSnowflake;

implementation

uses graph;

type
  TFloat = Float16;

{$I snowflake_unit.inc}

end.
