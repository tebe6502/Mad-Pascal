//target.name

{$ifdef atari}
  {$i graph_atari.inc}
{$endif}
{$ifdef c64}
  {$i graph_c64.inc}
{$endif}
{$ifdef c4p}
  {$i graph_c4p.inc}
{$endif}
{$ifdef raw}
  {$i graph_raw.inc}
{$endif}
{$ifdef neo}
  {$i graph_neo.inc}
{$endif}
{$ifdef x16}
  {$i graph_x16.inc}
{$endif}
