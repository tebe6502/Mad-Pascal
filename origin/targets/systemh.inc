//target.name

{$ifdef atari}
  {$i systemh_atari.inc}
{$endif}
{$ifdef c64}
  {$i systemh_c64.inc}
{$endif}
{$ifdef c4p}
  {$i systemh_c4p.inc}
{$endif}
{$ifdef raw}
  {$i systemh_raw.inc}
{$endif}
{$ifdef neo}
  {$i systemh_neo.inc}
{$endif}  
{$ifdef x16}
  {$i systemh_x16.inc}
{$endif}