// VBXE bitmap mode + TextOut

// 2: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.
// 3: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.
// 4: pixel mode 640x192/16 colors (hires)

uses crt, s2;

{$define romoff}

const
    s = 'The quick brown fox jums over the lazy dog: 1,2,3,4,5,6,7,8!';

var     
    y: byte;
    ch: char;
    

procedure print(fs: byte);
var i: byte;
begin

 Font.Style := fs;
 
 Position(0,y);
  
 for i:=1 to length(s) do begin
  Font.Color:=y*16+i shr 2;
  TextOut(s[i]);
 end;
 
 inc(y,16);

end;
    

begin

SetGraphMode(3);

print(fsNormal);
print(fsUnderline);
print(fsInverse);
print(fsInverse + fsUnderline);

print(fsProportional);
print(fsProportional + fsUnderline);
print(fsProportional + fsInverse);
print(fsProportional + fsInverse + fsUnderline);

print(fsProportional + fsCondensed);
print(fsProportional + fsCondensed + fsUnderline);
print(fsProportional + fsCondensed + fsInverse);
print(fsProportional + fsCondensed + fsInverse + fsUnderline);

repeat until keypressed;

CloseGraph;

end.