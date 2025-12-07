//target.name

{$ifdef atari}
  {$i sysutils_atari.inc}
{$endif}
{$ifdef c64}
  {$i sysutils_c64.inc}
{$endif}
{$ifdef c4p}
  {$i sysutils_c4p.inc}
{$endif}
{$ifdef raw}
  {$i sysutils_raw.inc}
{$endif}
{$ifdef neo}
  {$i sysutils_neo.inc}
{$endif}
{$ifdef x16}
  {$i sysutils_x16.inc}
{$endif}