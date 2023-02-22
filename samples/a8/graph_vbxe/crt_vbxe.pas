uses crt, vbxe;


begin

if VBXE.GraphResult <> VBXE.grOK then begin
 writeln('VBXE not detected');
 halt;
end;


TextColor($36);
TextBackground($18);

write('VBXE');

write(CH_CURS_RIGHT);

TextColor($0c);
TextBackground($68);

writeln('present');



repeat until keypressed;

end.