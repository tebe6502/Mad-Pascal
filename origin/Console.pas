unit Console;

{$i Defines.inc}

interface


// https://www.freepascal.org/docs-html/rtl/crt/lightgray.html
const
  LightGray = 7;

// https://www.freepascal.org/docs-html/rtl/crt/lightgreen.html
const
  LightGreen = 10;

// https://www.freepascal.org/docs-html/rtl/crt/lightcyan.html
const
  LightCyan = 11;

// https://www.freepascal.org/docs-html/rtl/crt/lightred.html
const
  LightRed = 12;

// https://www.freepascal.org/docs-html/rtl/crt/white.html
const
  White = 15;

// https://www.freepascal.org/docs-html/rtl/crt/textcolor.html
procedure TextColor(Color: Byte);

// https://www.freepascal.org/docs-html/rtl/crt/normvideo.html
procedure NormVideo;

procedure WaitForKeyPressed;

implementation

{$IFNDEF PAS2JS}
uses Crt;

{$ENDIF}


procedure TextColor(color: Byte);
begin
 {$IFNDEF PAS2JS}
  Crt.TextColor(color);
 {$ENDIF}
end;

procedure NormVideo;
begin
 {$IFNDEF PAS2JS}
  Crt.Normvideo;
 {$ENDIF}
end;

procedure WaitForKeyPressed;
begin
 {$IFNDEF PAS2JS}
  repeat
  until KeyPressed;
 {$ENDIF}
end;

end.
