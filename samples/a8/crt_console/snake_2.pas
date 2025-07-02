// https://forums.atariage.com/topic/243658-mad-pascal-examples/?do=findComment&comment=5133808

program snake;
uses atari, crt, joystick;

const
    BOARD_SIZE = 24 * 40;
    TAIL_MAX = 1023;
    BORDER = ord(' '*~);
    FOOD = ord('+'~);
    BODY = ord('O'~);
    DEAD = ord('@'~);

var
    tail: array [0..TAIL_MAX] of integer;
    headPos, headPtr, clearPtr, tailLength:word;
    b, speed, field, input:byte;
    dir: shortInt;
    gameover: boolean;

procedure DrawSnake;
begin
    b := BODY;
    if gameover then b := DEAD;
    Poke(headPos,b);
end;

procedure PutFood;
var foodPos: word;
begin
    repeat
        foodPos := savmsc + Random(BOARD_SIZE);
    until Peek(foodPos) = 0;
    Poke(foodPos, FOOD);
end;

procedure ClearTail;
var offset: word;
begin
    offset := 0;
    headPtr := (headPtr + 1) and TAIL_MAX;
    tail[headPtr] := headPos;
    if headPtr < clearPtr then offset := TAIL_MAX + 1;
    if headPtr + offset - clearPtr >= tailLength then begin
        if tail[clearPtr] <> tail[headPtr] then Poke(tail[clearPtr],0);
        clearPtr := (clearPtr + 1) and TAIL_MAX;
    end;
end;

procedure DrawBorder;inline;
begin
    for b:=0 to 39 do begin
        poke(savmsc + b, BORDER);
        poke(savmsc + 23*40 + b, BORDER);
        if b<23 then begin
            poke(savmsc + b * 40, BORDER);
            poke(savmsc + b * 40 + 39, BORDER);
        end;
    end;
end;

procedure InitSnake;inline;
begin
    headPos := savmsc + 20 + (12 * 40); // initial position mid screen (20,12)
    dir := 0;
    headPtr := 0;
    clearPtr := 0;
    tailLength := 5;
    speed := 8;
    tail[0] := headPos;
    gameover := false;
end;

procedure InitGame;inline;
begin
    Randomize;
    InitSnake;
    CursorOff;
    ClrScr;
    DrawBorder;
    DrawSnake;
    PutFood;
end;

function GetInput:byte;
begin
    result := joy_none;
    for b := 0 to speed do begin
        if stick0 <> joy_none then result := stick0;
        Pause;
    end;
end;

begin
    repeat
        InitGame;
        repeat input := GetInput until input <> joy_none; // wait for joy input to start

        repeat
            if (input = joy_left) and (dir <> 1) then dir := -1;
            if (input = joy_right) and (dir <> -1) then dir := 1;
            if (input = joy_up) and (dir <> 40) then dir := -40;
            if (input = joy_down) and (dir <> -40) then dir := 40;

            headPos := headPos + dir;
            ClearTail;
            field := Peek(headPos);

            case (field) of
                FOOD: begin // hit food
                    PutFood;
                    Inc(tailLength);
                end;
                0: // empty field - do nothing ;
                else gameover := true; // hit antyhing else
            end;

            DrawSnake;
            input := GetInput;
        until gameover;

        Readkey; // wait for any key to restart
    until false;
end.
