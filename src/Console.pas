unit Console;

interface

{$i define.inc}
{$i Types.inc}

// https://www.freepascal.org/docs-html/rtl/crt/lightgray.html
const LightGray = 7;

// https://www.freepascal.org/docs-html/rtl/crt/lightgreen.html
const LightGreen = 10;

// https://www.freepascal.org/docs-html/rtl/crt/lightcyan.html
const LightCyan = 11;

// https://www.freepascal.org/docs-html/rtl/crt/lightred.html
const LightRed = 12;

// https://www.freepascal.org/docs-html/rtl/crt/white.html
const White = 15;

// https://www.freepascal.org/docs-html/rtl/crt/textcolor.html
procedure TextColor(Color: Byte);

// https://www.freepascal.org/docs-html/rtl/crt/normvideo.html
procedure NormVideo;

implementation

uses Crt;

procedure TextColor(color: Byte);
begin
 Crt.TextColor(color);
end;

procedure NormVideo();
begin
 Crt.Normvideo;
end;


end.
