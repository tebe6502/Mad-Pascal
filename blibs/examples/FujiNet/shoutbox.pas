program udp_shoutbox;
{$librarypath '../..'}
uses atari, crt, fn_sio, sio, b_crt;

const 
    BUFSIZE = 200;
    RETRIES = 50;
    SCREEN_WIDTH = 40;
    SCREEN_HEIGHT = 20;
    SCR_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;    
    STATUS_OFFSET = SCREEN_WIDTH * (SCREEN_HEIGHT);    
    INPUT_OFFSET = SCREEN_WIDTH * (SCREEN_HEIGHT + 1);   
    INPUT_LIMIT = 160; 
    CURSOR = byte('_'~);

type headerT = record
    head1:byte;
    command:char;
    param1:byte;
    param2:byte;
    head2:byte;
end;

type bufStringT = string[BUFSIZE];

label end_program;

var FNuri: string[50] = 'N:UDP://fujinet.pl:6502/';
    header: headerT;
    datagram, recv_buffer, msg, welcome: bufStringT;
    status: array [0..3] of byte;
    bytesWaiting: word;
    connected: boolean;
    i: byte;
    lastLine: byte;
    inputCursor: byte;
    users_count: byte;
    nick: TString;
    dataFlag:byte;
    VPRCED:word absolute $0202;
    PACTL:byte absolute $D302;
    oldHandler:word;
    
// ************************************************** NETWORK ROUTINES

procedure DataFlagHandler:interrupt;assembler;
asm {
    lda #$01
    sta dataFlag
    pla
    ;lda $D20A       // debug - change border color to see if it was launched
    ;sta 712
};
end;

function ReadData:boolean;
begin
    result := false;
    if dataFlag = 1 then begin
        FN_ReadStatus(status);
        bytesWaiting := status[0];
        if bytesWaiting > 0 then begin
            FN_ReadBuffer(@recv_buffer[1], bytesWaiting); 
            recv_buffer[0] := char(bytesWaiting);
            dataFlag := 0;
            Exit(true);
        end;
    end;
end;

function WaitForData:boolean;
var retry:byte;
begin
    result := false;
    retry := RETRIES;
    repeat
        Pause(20);
        if ReadData then Exit(true);
        Dec(retry);
    until retry = 0; 
end;

procedure SetDatagramHeader(cmd: char;param: word);
var i:byte;
begin
    header.command := cmd;
    header.param1 := Lo(param);
    header.param2 := Hi(param);
    i := SizeOf(headerT);
    move(@header, @datagram[1], i);
    move(@msg[1], @datagram[i + 1], byte(msg[0]));
    i := i + byte(msg[0]);
    datagram[0] := char(i);
end;

procedure SendDatagram(cmd: char; param:word);
begin
    SetDatagramHeader(cmd, param);
    FN_WriteBuffer(@datagram[1], byte(datagram[0]));
end;

procedure GetStatus;
begin
    msg:='';
    SendDatagram('S', 0);
end;

procedure SendPing;
begin
    msg:='';
    SendDatagram('P', 0);
end;

procedure SendMessage;
begin
    SendDatagram('M', 0);
end;

procedure SendCommand;
begin
    SendDatagram('C', 0);
end;

procedure SetName;
begin
    SendDatagram('A', 0);
end;

// ************************************************** GUI ROUTINES

procedure ShowStatus;
var i:byte;
begin
    FillChar(pointer(savmsc + STATUS_OFFSET), SCREEN_WIDTH, 0);
    GotoXY(2,21);
    Write(nick);
    Write(':');
    GotoXY(31,21);
    Write('users: ');
    Write(users_count);
    for i:=0 to 39 do poke(savmsc + STATUS_OFFSET + i, peek(savmsc + STATUS_OFFSET + i) or 128)
end;

procedure WriteLine(ptr: pointer; len, line: byte);
var inOffset,outOffset: word;
begin
    inOffset := word(ptr);
    outOffset := savmsc + line * SCREEN_WIDTH;
    while (len > 0) do begin
        Poke(outOffset, Atascii2Antic(Peek(inOffset)));
        Inc(outOffset);
        Inc(inOffset);
        Dec(len)
    end;
end;

procedure ScrollUp(lines: byte);
var offset: word;
begin
    offset := lines * SCREEN_WIDTH;
    Move(pointer(savmsc + offset), pointer(savmsc), SCR_SIZE - offset);
    FillByte(pointer(savmsc + SCR_SIZE - offset), offset, 0);
end;

procedure WriteToConsole(txt:string);
var lines,len,scroll:byte;
begin
    len := byte(txt[0]);
    lines := 1;
    while (len > SCREEN_WIDTH) do begin
        Inc(lines);
        Dec(len, SCREEN_WIDTH);
    end;
    if (lastLine + lines) > SCREEN_HEIGHT then begin
        scroll := lastLine + lines - SCREEN_HEIGHT;
        ScrollUp(scroll);
        Dec(LastLine, scroll);
    end;
    Writeline(@txt[1], byte(txt[0]), LastLine);
    Inc(LastLine,lines);
end;

procedure ClearInput;
begin
    FillByte(pointer(savmsc + INPUT_OFFSET), INPUT_LIMIT, 0);
    inputCursor := 0;
    Poke(savmsc + INPUT_OFFSET, CURSOR);
end;

procedure ProcessInput(var s:string);
begin
    if s[1] = '/' then SendCommand
    else SendMessage;
end;

procedure ProcessKey(c: char);
var inputVram:word;
begin
    inputVram := savmsc + INPUT_OFFSET;
    if c = CH_DEL then begin
        if inputCursor > 0 then begin
            Poke(inputVram + inputCursor - 1, 0);
            Dec(inputCursor);
            Poke(inputVram + inputCursor, byte(CURSOR));
            Poke(inputVram + inputCursor + 1, CURSOR);
        end;
        exit;
    end;
    if c = CH_ENTER then begin
        if inputCursor > 0 then begin
            Move(pointer(inputVram), @msg[1], inputCursor);
            msg[0] := char(inputCursor);
            msg:=Antic2Atascii(msg);
            ProcessInput(msg);
            ClearInput;
        end;
        exit;
    end;
    if inputCursor < INPUT_LIMIT then begin
        Poke(inputVram + inputCursor, Atascii2Antic(byte(c)));
        Inc(inputCursor);
        Poke(inputVram + inputCursor, CURSOR);
    end;
end;

// ************************************************** DATA PARSING ROUTINES

function ParseHeader:boolean;
begin
    result := true;
    move(@recv_buffer[1],@header,SizeOf(headerT));
    if (header.head1 <> byte('<')) or (header.head2 <> byte('>')) then result := false;
    if result then begin
        recv_buffer[0] := char(byte(recv_buffer[0]) - SizeOf(headerT));
        move(@recv_buffer[1 + SizeOf(headerT)], @recv_buffer[1], byte(recv_buffer[0]));
    end; 
end;

procedure ParseStatus;
begin
    users_count := header.param2;
    ShowStatus;
end;

procedure ProcessReceived;
begin
    if ParseHeader then begin
        case header.command of
            'M': WriteToConsole(recv_buffer);
            'A': begin
                    move(@recv_buffer, @nick, byte(recv_buffer[0]) + 1);
                    ShowStatus;
                 end;
            'S': ParseStatus;
            'P': SendPing;
            'X': begin
                    connected := false;
                    WriteToConsole(recv_buffer);
                    Pause(50);
                 end;
        end;
    end;
end;

// ************************************************** 
// ************************************************** MAIN PROGRAM
// ************************************************** 

begin
    PACTL := PACTL or 1;
    // set Interrupt
    asm { sei};
    oldHandler := VPRCED;
    VPRCED := word(@DataFlagHandler);
    asm { cli};


    // init variables
    header.head1 := ord('<');
    header.head2 := ord('>');
    connected := false;
    lastLine := 0;
    
    // connect
    Write('Connecting: '); Writeln(FNuri);
    FN_Open(FNuri);
    GetStatus;
    if WaitForData and ParseHeader then begin
        if header.command = 'S' then begin
            users_count := header.param2; // get user_count
            move(@recv_buffer, @welcome, byte(recv_buffer[0]) + 1);
            if header.param1 = 0 then begin // check if IP/port already authorized
                Write('What is your name: ');
                Readln(msg);
                SetName;
            end;
            connected := true;
        end;
    end else Writeln('Connection timeout :(');
    if not connected then goto end_program; // skip if error connecting
    
    // init screen
    lmargin := 0;
    CursorOff;
    ClrScr;
    
    Writeln; // weird crt gotoxy fix
    Writeln;
    Writeln;
    Writeln;
    
    WriteToConsole(welcome);

    // main communication loop
    repeat
        pause;
        if ReadData then ProcessReceived;
        if keypressed then processKey(Readkey);
    until not connected;
    
    CursorOn;
    lmargin := 2;
    ClrScr;

end_program: // clean up and leave

    Writeln('Closing connection...');
    FN_Close;
    asm { sei};
    VPRCED := oldHandler;
    asm { cli};

end.
