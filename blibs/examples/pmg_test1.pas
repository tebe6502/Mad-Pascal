program pmg_test1;
{$librarypath '../'}
uses atari, crt, b_pmg, joystick;

const 
Frame0: array [0..15] of byte = (
%01011010,
%00111100,
%01101010,
%01111110,
%01000000,
%00111100,
%00011000,
%01010010,
%11010011,
%11000011,
%10000001,
%11000011,
%00111100,
%01100110,
%01100110,
%11100111
);
Frame1: array [0..15] of byte = (
%01011010,
%00111100,
%01101010,
%01111110,
%01000000,
%00111101,
%00011011,
%01101101,
%11110100,
%11100100,
%11001000,
%11011101,
%00001111,
%01100011,
%11000000,
%01100000
);
Frame2: array [0..15] of byte = (
%01011010,          
%00111100,
%01101010,
%01111110,
%01000000,
%00111100,
%00011100,
%00101000,
%01010011,
%01011111,
%00100000,
%00111100,
%11111010,
%11110110,
%10000110,
%00000111
);
Frame3: array [0..15] of byte = (
%01011010,
%00111100,
%01101010,
%01111110,
%01000000,
%00111100,
%00011100,
%00111010,
%01011010,
%01011100,
%01101101,
%01110011,
%00101110,
%00110100,
%00110010,
%00011000
);
Frame4: array [0..15] of byte = (
%10110100,
%01111000,
%11010100,
%11111101,
%11000001,
%01111011,
%00111011,
%01101010,
%11110100,
%11000100,
%11001000,
%00011101,
%00101111,
%11110011,
%11100000,
%10000000
);
runframes: array[0..3] of pointer = (@Frame1, @Frame3, @Frame2, @Frame3); 

PMGBASE = $6000;
JUMP_FORCE = 60;

var frame:byte=0;
    fspeed:byte=6;
    fcount:byte=0;
    floor:byte=80;
    y:byte=80;
    sy:smallInt=0;
    cy:byte;
    fly:boolean = false;
    jump:boolean = false;
    jumpforce:byte = 0;
begin

    PMG_Init(Hi(PMGBASE));
    PMG_Clear;
    PMG_hpos0:=60;
    PMG_pcolr0_S:=$b4;
    color2:=$70;
    repeat
        fillbyte(pointer(PMGBASE+510+y),2,0);
        fillbyte(pointer(PMGBASE+528+y),2,0);
        if not fly then move(runframes[frame],pointer(PMGBASE+512+y),16)
        else move(Frame4,pointer(PMGBASE+512+y),16);
        inc(fcount);
        if fcount>=fspeed then begin
            fcount:=0;
            inc(frame);
            if frame=4 then frame:=0;
        end;
        
        if not fly and not jump and (strig0 = 0) then begin
            jump:=true;
            jumpforce:=10;
        end;
        
        if not fly and jump and (strig0 = 0) and (jumpforce<JUMP_FORCE) then begin
            inc(jumpforce,2);
        end;
                
        if not fly and jump and (strig0 = 1) then begin
            jump:=false;
            fly:=true;
            sy:=-jumpforce;
        end;
        
        if sy>0 then begin
            cy:=cy+abs(sy);
            y:=y+(cy shr 5);
            if (y>=floor) then begin
                sy:=0; 
                cy:=0;
                fly:=false;
            end else begin
                cy:=cy and %11111;
                inc(sy);
            end;
        end;
        
        if sy<0 then begin
            cy:=cy+abs(sy);
            y:=y-(cy shr 5);
            cy:=cy and %11111;
            inc(sy);
            if sy=0 then sy:=1;
        end;
        
        pause;
    until KeyPressed;
    

    Readkey;
end.
