program text_scroll_big;
uses crt, neo6502;
const 
    LineWidth =   53;
    CharWidth =   7;

var 
    txt: pchar = '                                                      '+
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '+
    'Donec eget neque ut urna accumsan bibendum nec ut diam. '+
    'Nullam lobortis, urna at consectetur tincidunt, mauris purus malesuada tortor, '+
    'a ultrices enim dolor et diam. Ut elementum, nisl sit amet tristique ornare, '+
    'tellus erat tempor dui, vitae tincidunt ipsum turpis quis urna. '+
    'Proin condimentum, ipsum sit amet varius egestas, nisl justo accumsan eros, '+
    'ac ultrices odio diam sit amet lacus. Praesent felis nisl, euismod quis pretium vel, '+
    'consequat sollicitudin justo. Sed sit amet dictum erat, eget interdum odio. '+
    'Aliquam in neque in odio mattis accumsan nec at libero. Morbi lobortis sapien '+
    'vel quam malesuada finibus. Etiam at euismod nisi.'#0;
    s: string[LineWidth+2];
    stringOffset: word;
    byteOffset: byte;

procedure GetStringSlice;
begin
    move(@txt[stringOffset],s[1],LineWidth+2);
end;

begin
    NeoSetDefaults(0,127,1,1,0);
    stringOffset := 0;
    byteOffset := 0;
    SetLength(s,LineWidth+2);
    GetStringSlice;
    repeat
        NeoWaitForVblank;
        NeoDrawString(0-byteOffset, 0, s);
        Inc(byteOffset);
        if byteOffset=CharWidth then begin
            byteOffset := 0;
            Inc(stringOffset);
            if (s[1]=#0) then begin
                stringOffset := 0;
                byteOffset := 0;
            end;
            GetStringSlice;
        end;
    until Keypressed;
end.
