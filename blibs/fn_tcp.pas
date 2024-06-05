unit fn_tcp;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: #FujiNet interface TCP communication library.
* @version: 0.7.2

* @description:
* This library provides an easy interface to estabilish TCP connection, and transfer data both directions.
*
* It allows you to use SIO interrupts, to read data from SIO only on device request. 
*
* It uses 256 bytes circular buffer located in your MadPascal DATA block. 
*
* <https://fujinet.online/>
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses sio, fn_sio;

Const 
    TCP_BUFF_SIZE = 256;            // receive buffer size @nodoc
    TCP_FREE_READ_TRESHOLD = 64;    // how much free space is needed to fetch new data from sio @nodoc
    TCP_CONNECTED = 1;              // status connected 
    TCP_DISCONNECTED = 0;           // status disconnected

var
    TCP_status: FN_StatusStruct;    (* @var Status operation result data. Structure defined in fn_sio module. *)
    TCP_bytesWaiting: word;         (* @var Number of bytes waiting in network device *)
    TCP_bufferLength: word;         (* @var Number of bytes in receive buffer *)
    TCP_dataFlag: byte;             (* @var This byte is updated by SIO interrupt. 1 is set here if there is incoming data. *)
    TCP_oldIRQHandler: word;
    TCP_bufferReadHead: byte;       
    TCP_bufferWriteHead: byte;
    TCP_buffer: array [0..TCP_BUFF_SIZE - 1] Of byte;

procedure TCP_AttachIRQ;
(*
* @description:
* Attaches interrupt handler, to update TCP_dataFlag byte on incoming data connection. 
*
* This interrupt sets 1 into TCP_dataFlag variable. If you want to be informed on next packet, 
* you need to reset it to zero manualy (probably after data fetch). 
*)

procedure TCP_DetachIRQ;
(*
* @description:
* Removes custom SIO interrupt handler. Do not call this procedure without TCP_AttachIRQ before.
*)

function TCP_Connect(var tcp_uri:PChar):byte;overload;
(*
* @description:
* Opens #FujiNet connection to remote host, at selected port using declared protocol.
*
* @param: tcp_uri - #FujiNet N: device connection string: N[x]:&lt;PROTO&gt;://&lt;PATH&gt;[:PORT]/
*
*
* The N: Device spec can be found here: 
* 
* <https://github.com/FujiNetWIFI/atariwifi/wiki/Using-the-N%3A-Device#the-n-devicespec>
*
*)

function TCP_Connect(var tcp_uri: PChar; aux1,aux2: byte):byte;overload;
(*
* @description:
* Opens #FujiNet connection to remote host, at selected port using declared protocol.
*
* @param: tcp_uri - #FujiNet N: device connection string: N[x]:&lt;PROTO&gt;://&lt;PATH&gt;[:PORT]/
* @param: aux1 - additional param passed to DCB
* @param: aux2 - additional param passed to DCB 
* 
* The N: Device spec can be found here: 
* 
* <https://github.com/FujiNetWIFI/atariwifi/wiki/Using-the-N%3A-Device#the-n-devicespec>
*
*)

function TCP_GetStatus:byte;
(*
* @description:
* Reads network device status and stores information in TCP_status variable.
*)

function TCP_SIORead:word;
(*
* @description:
* Performs data fetch from SIO device (N:) to free space in local TCP buffer. 
*
* If amount of SIO data is bigger than available space in buffer, only part of the data is received. 
* To fetch rest of it you need to release some buffer space, by calling TCP_ReadByte or TCP_ReadBuffer procedure.
* And then call TCP_SIORead again... and again... 
*)

function TCP_ReadByte: byte;
(*
* @description:
* Reads one byte from TCP receive buffer (if available). It also frees one byte in buffer for future SIOReads.
*
* Always check if there is at least one byte available in buffer (TCP_bufferLength > 0). 
* If you will call this function on empty buffer, returned value is unpredictable.
*
* @returns: (byte) - value from buffer
*)

function TCP_ReadBuffer(buf: pointer; len: word): word;
(*
* @description:
* Reads block of bytes from TCP receive buffer. It also frees space in buffer for future SIOReads.
*
* If amount of data available in buffer is smaller then desired (len), only available part is received.
* Function will return exact number of received/freed bytes.
*
* @param: buf - pointer of buffer to store the incoming data 
* @param: len - data length (in bytes)
*
* @returns: (word) - number of bytes received.
*)

function TCP_CheckAndPoll:word;
(*
* @description:
* This function performs check if there is any incoming data available. 
* If there is and we have free space in receive buffer, it reads biggest possible chunk of data from SIO to our TCP buffer.
* After operation it returns amount of data added to buffer, and updates value of TCP_bufferLength.
*
* Also TCP_dataFlag is set to 0 after every succesful poll.
*
*
* This function should be called periodicaly to retrieve incoming data, and process it when it shows up in buffer.
*
* @returns: (word) - number of bytes received.
*)

procedure TCP_SendString(var s:string);
(*
* @description:
* Sends string using existing connection. 
*
* @param: s - the string to be sent 
*)

procedure TCP_SendBuffer(buf: pointer;len: word);
(*
* @description:
* Sends data buffer using already opened connection. 
*
* @param: buf - pointer to starting address of data 
* @param: len - data length (in bytes)
*)

procedure TCP_Close;
(*
* @description:
* Closes #FujiNet network connection.
*)

function TCP_WaitForData(timeout:word):byte;
(*
* @description:
* Waits for declared time (in frames) for incoming data.
* 
* @returns: (byte) - return sioStatus for success, and $ff for timeout
*)

procedure TCP_ClearBuffer;
(*
* @description:
* Clears TCP data buffer.
*)
implementation

procedure TCP_DataFlagHandler; interrupt; assembler;
asm {
    lda #$01
    sta TCP_dataFlag
    pla
};
end;

procedure TCP_ClearBuffer;
begin
    TCP_bytesWaiting := 0;
    TCP_bufferReadHead := 0;
    TCP_bufferWriteHead := 0;
    TCP_bufferLength := 0;
end;

procedure TCP_AttachIRQ;
begin
    PACTL := PACTL or 1;
    asm { sei};
    TCP_oldIRQHandler := VPRCED;
    VPRCED := word(@TCP_DataFlagHandler);
    asm { cli};
end;

procedure TCP_DetachIRQ;
begin
    asm { sei};
    VPRCED := TCP_oldIRQHandler;
    asm { cli};
end;

function TCP_Connect(var tcp_uri:PChar):byte;overload;
begin
    TCP_ClearBuffer;
    FN_Open(tcp_uri);
    result := sioStatus;
end;

function TCP_Connect(var tcp_uri: PChar; aux1,aux2: byte):byte;overload;
begin
    TCP_ClearBuffer;
    FN_Open(tcp_uri, aux1, aux2);
    result := sioStatus;
end;

function TCP_GetStatus:byte;
begin
    FN_ReadStatus(TCP_status);
    result := sioStatus;
    if sioStatus = 1 then 
        TCP_bytesWaiting := TCP_status.dataSize;  
end;

function TCP_SIORead:word;
var endHead:word;
Begin
    result := TCP_BUFF_SIZE - TCP_bufferLength;
    if TCP_bytesWaiting < result Then result := TCP_bytesWaiting;
    endHead := TCP_bufferWriteHead + result;
    if endHead > TCP_BUFF_SIZE then begin  // do I have to wrap buffer?
        FN_ReadBuffer(pointer(word(@TCP_buffer) + TCP_bufferWriteHead), TCP_BUFF_SIZE - TCP_bufferWriteHead); //read first half
        FN_ReadBuffer(@TCP_buffer, endHead - TCP_BUFF_SIZE); //read second half
    end else begin
        FN_ReadBuffer(pointer(word(@TCP_buffer) + TCP_bufferWriteHead), result); // read at once
    end;
    //if sioStatus = 1 then begin
        Dec(TCP_bytesWaiting, result);
        Inc(TCP_bufferWriteHead, result);
        Inc(TCP_bufferLength, result);
    //end else result := 0;
End;

function TCP_ReadByte: byte;
begin
    if TCP_bufferLength > 0 then begin
        result := TCP_buffer[TCP_bufferReadHead];
        Inc(TCP_bufferReadHead);
        Dec(TCP_bufferLength);
    end;
end;

function TCP_ReadBuffer(buf: pointer; len: word): word;
begin
    if len > TCP_bufferLength then len := TCP_bufferLength;
    if len > 0 then begin
        Move(pointer(word(@TCP_buffer) + TCP_bufferWriteHead), buf, len);
        Inc(TCP_bufferReadHead, len);
        Dec(TCP_bufferLength, len);
    end;
    result := len;
end;

procedure TCP_SendString(var s:string);
var ptr:pointer;
Begin
    ptr := @s;
    Inc(ptr);
    FN_WriteBuffer(ptr, byte(s[0]));
End;

procedure TCP_SendBuffer(buf: pointer;len: word);
begin
    FN_WriteBuffer(buf, len);
end;

function TCP_WaitForData(timeout:word):byte;
begin
    repeat
        pause;
        dec(timeout);
        if timeout = 0 then exit($ff);
    until TCP_dataFlag = 1;
    if TCP_dataFlag = 1 then begin
        TCP_GetStatus;
        TCP_DataFlag := 0;
        result := sioStatus;
    end else result := $ff;
end;

function TCP_CheckAndPoll:word;
var TCP_bufFree: word;
begin
    result := 0;
    if (TCP_dataFlag = 1) and (TCP_bytesWaiting = 0) then begin
        TCP_GetStatus;
        TCP_dataFlag := 0;
    end;
    
    if TCP_bytesWaiting > 0 then begin
        TCP_bufFree := TCP_BUFF_SIZE - TCP_bufferLength;
        if (TCP_bytesWaiting <= TCP_bufFree) or (TCP_bufFree > TCP_FREE_READ_TRESHOLD) then begin
            result := TCP_SIORead;
        end;
    end;
end;

procedure TCP_Close;
begin
    FN_Close;
end;

end.
