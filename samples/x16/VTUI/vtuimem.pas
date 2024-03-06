uses x16_vtui, x16, crt;

var
    key: char;
    cX, cY, oldX, oldY: Byte;


procedure moveMem;
begin
    vtuiGotoXY(oldX,oldY);
    vtuiRestoreRect(7,7,$0100,$80);
    vtuiGotoXY(cX,cY);
    vtuiSaveRect(7,7,$0100,$80);
    vtuigotoxy(cX,cY);
    vtuiRestoreRect(7,7,$0000,$80);

    oldX:=cX;
    oldY:=cY;
end;

begin
  vtuiInit;
//   vtuiSetScreen(vtui_mode_80x60);
  cX:=0; cY:=0;
  oldX:=0; oldY:=0;

    vtuigotoxy(cX,cY);
    vtuiSaveRect(7,7,$0000,$80);
    vtuigotoxy(cX,cY);
    vtuiFillBox(' ',7,7, BLUE shl 4 + BLUE);
    vtuigotoxy(cX,cY);
    vtuiSaveRect(7,7,$0100,$80);
    vtuigotoxy(70,50);
    vtuiRestoreRect(7,7,$0000,$80);
    vtuigotoxy(cX,cY);
    vtuiRestoreRect(7,7,$0000,$80);

    repeat
        key:=#0;
        if keypressed then key:=readkey; 
        case key of
            'A','a': begin
                if cX > 0 then Dec(cX);        
            end;
            'D','d': begin
                if cX < 73 then Inc(cX);
            end;
            'W','w': begin
                if cY > 0 then Dec(cY);
            end;
            'S', 's': begin
                if cY < 53 then Inc(cY);
            end;
        end;
        If (key<>#0) and (key<>X16_KEY_ESC) then moveMem;
        gotoxy(0,59);
        write(cX,' ', cY);
        pause;
    until key=X16_KEY_ESC
end.