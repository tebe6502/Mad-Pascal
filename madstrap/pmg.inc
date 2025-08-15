var 
    player0: array [0..7] of byte = (
        %00000000,
        %00000000,
        %00000000,
        %00011000,
        %00011000,
        %00000000,
        %00000000,
        %00000000
    );

    player1: array of byte = [
        %00000000,
        %00000000,
        %00011000,
        %00111100,
        %00111100,
        %00011000,
        %00000000,
        %00000000
    ];

    player2: array of byte = [
        %00000000,
        %00011000,
        %00111100,
        %01111110,
        %01111110,
        %00111100,
        %00011000,
        %00000000
    ];

    player3: array of byte = [
        %00011000,
        %00111100,
        %01111110,
        %11111111,
        %11111111,
        %01111110,
        %00111100,
        %00011000
    ];

    players: array of pointer = [ @player0, @player1, @player2, @player3 ];
    player: ^Tplayer;
    pframe: byte;
    hposp: array [0..3] of byte absolute $d000;
    //hposm: array [0..3] of byte absolute $d004;
    pcolr: array [0..3] of byte absolute $02C0;
    sinx: array of byte = [ {$EVAL 128, "(sin((:1*PI*2.0)/128.0)*35+40)"} ];    
    
procedure PMGInit;
begin
    pmbase := Hi(PMG_ADDRESS);
    gprior := %00110001;
    gractl := %00000011;
    sdmctl := %00101110;
    FillByte(pointer(PMG_ADDRESS+$180),$280,0);
end;

procedure DrawPlayer(pnum: byte);
var 
    pptr,fptr: pointer;
    
begin
    fptr := players[pnum];
    pptr := pointer(PMG_ADDRESS+$200+(pnum shl 7));
    player.angle := (pframe + (pnum shl 3)) and 127;
    player.y := 24 + sinx[player.angle];
    player.x := 84 + sinx[(player.angle+32) and 127];    
    fillbyte(pptr+24, 96, 0); // clear player
    move(fptr,pptr+player.y,8); // draw player
    hposp[pnum] := player.x;
    pcolr[pnum] := (pframe shr 2) + (pnum shl 2);
end;


procedure PMGDraw;
var p: byte;
begin
    for p:=0 to 3 do DrawPlayer(p);
    inc(pframe);
end;