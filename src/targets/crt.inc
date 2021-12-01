//target.name

{$ifdef atari}
  {$i crt_atari.inc}
{$endif}
{$ifdef c64}
  {$i crt_c64.inc}
{$endif}
{$ifdef c4p}
  {$i crt_c4p.inc}
{$endif}
{$ifdef raw}
  {$i crt_raw.inc}
{$endif}
