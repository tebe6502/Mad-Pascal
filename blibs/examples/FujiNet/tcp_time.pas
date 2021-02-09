program tcp_time;
{$librarypath '../..'}
uses atari, crt, fn_tcp;

var FNuri: PChar = 'N:TCP://india.colorado.edu:13/'#0; // TCP time server
    b, cResult: byte;

begin
    Write('Connecting: ');
    Writeln(FNuri);
    cResult := TCP_Connect(FNuri);

    if cResult <> 1 then begin
        Writeln('Connection Error: ', cResult);
        Readkey;
        Exit;
    end;

    TCP_AttachIRQ;

    repeat
        TCP_CheckAndPoll;
        if TCP_bufferLength > 0 then begin
            b := TCP_ReadByte;
            case b of 
                10: Writeln; // LF - line feed
                else Write(char(b)) // output char
            end;
        end;
    until keypressed;

    Writeln('Closing connection...');
    TCP_DetachIRQ;
    TCP_Close;
end.
