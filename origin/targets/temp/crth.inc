//target.name

{$ifdef atari}
  {$i crth_atari.inc}
{$endif}
{$ifdef c64}
  {$i crth_c64.inc}
{$endif}
{$ifdef c4p}
  {$i crth_c4p.inc}
{$endif}
{$ifdef raw}
  {$i crth_raw.inc}
{$endif}
{$ifdef neo}
  {$i crth_neo.inc}
{$endif}
{$ifdef x16}
  {$i crth_x16.inc}
{$endif}

