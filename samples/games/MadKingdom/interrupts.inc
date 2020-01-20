procedure IngameDli; interrupt;
begin
    asm { phr };
    _bgcolr:=dliColbg[dliCounter];
    _c1colr:=dliCol1[dliCounter];
    Inc(dliCounter);
    if dliCounter=1 then begin      // status bar 1
        _sizep0 := 0;
        _sizep1 := 0;
        _sizep2 := 0;
        _sizep3 := 0;
        _pcolr0 := $10;
        _pcolr1 := $50;
        _pcolr2 := $90;
        _hposp0 := 48;
        _hposp1 := 80;
        _hposp2 := 112;
    end;
    if dliCounter=2 then begin      // status bar 1
        asm { sta _wsync };
        _pcolr0 := $20;
        _pcolr1 := $e0;
        _pcolr2 := $b0;
    end;
    if dliCounter=3 then begin      // faces
        _pcolr0 := cursorColor;
        _pcolr1 := cursorColor;
        _pcolr2 := cursorColor;
        _hposp0 := cursorX;
        _hposp1 := cursorX + 30;
        _hposp2 := cursorX;
        _sizep2 := 3;
    end;
    if dliCounter=5 then begin      // sentences and yes/no
        _pcolr0 := 0;
        _pcolr1 := 0;
        _pcolr2 := 0;
        x := YESNO_X_POS;
        _hposp0 := x;
        Inc(x,16);
        _hposp1 := x;
        Inc(x,16);
        _hposp2 := x;
        Inc(x,16);
        _hposp3 := x;
        _sizep0 := 1;
        _sizep1 := 1;
        _sizep2 := 1;
        _sizep3 := 1;
    end;
    asm { plr };
end;

procedure TitleDli; interrupt;
begin
    asm { phr };
    Inc(dliCounter);
    if dliCounter=1 then begin      // crown colours
        _wsync:=1;
        _bgcolr := $f6;
        _c1colr := $fa;
        _c2colr := $ff;
        asm { :19 sta _wsync };
        _c2colr := $fc;
        asm { sta _wsync };
        _c2colr := $ff;
        asm { sta _wsync };
        _c2colr := $fc;
        asm { :4 sta _wsync };
        _c1colr := $f8;
        asm { :2 sta _wsync };
        _bgcolr := $f4;
        asm { :5 sta _wsync };
        _c2colr := $ff;
        asm { sta _wsync };
        _c2colr := $fa;
    end;
    if dliCounter=2 then begin      // vex regis colours
        _wsync:=1;
        _bgcolr := $84;
        _c1colr := $88;
        _c2colr := $8c;
        asm { :14 sta _wsync };
        _c2colr := $9f;
        asm { :8 sta _wsync };
        _c2colr := $9d;
        asm { :6 sta _wsync };
        _c2colr := $9a;
    end;
    if dliCounter=3 then begin      // text colours
        _bgcolr := $0;
        asm { :3 sta _wsync };
        _c1colr := $a;
        asm { :2 sta _wsync };
        _c1colr := $c;
        asm { :2 sta _wsync };
        _c1colr := $f;
        asm { :2 sta _wsync };
        _c1colr := titleTextColor;
    end;

    asm { plr };
end;

procedure VBlank; interrupt;
begin
    msx.Play;
    dliCounter := 0;

    if screenMode = SCREEN_TITLE then begin
        if titleWait > 0 then Dec(titleWait)
        else begin
            if titleTextColor<$f then Inc(titleTextColor);           // fade in
            if titleTextColor=$f then begin     // if shown - wait some time
                titleTextColor:=$1f;
                titleWait:=500;
            end else if titleTextColor>$10 then Dec(titleTextColor); // fade out
            if titleTextColor=$10 then begin    // if hidden - change Page
                titleTextColor:=$0;
                titleWait:=10;
                titlePage := (titlePage + 1) mod 3;
                showTitlePage(titlePage);
            end;
        end;
    end;

    if screenMode = SCREEN_INGAME then begin
        if cursorBlink then begin               // blink cursor
            cursorColor := peek(20) shl 4;
            cursorColor := cursorColor shr 5;
            cursorColor := cursorColor or COLOR_NEUTRAL;
        end;
    end;
    asm { jmp $E462 };
end;

