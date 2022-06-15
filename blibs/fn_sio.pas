unit fn_sio;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: SIO library for #FujiNet interface.
* @version: 0.9.4

* @description:
* Set of procedures to communicate with #FujiNet interface on SIO level. <https://fujinet.online/>
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses sio;

type FN_StatusStruct = record  
(*
* @description: 
* Structure used to store Status Command result
*)
    dataSize: word;
    connected: byte;  
    errorCode: byte;
end;

var FN_timeout: byte = 5; // default timeout value

procedure FN_Open(var fn_uri:PChar);overload;
(*
* @description:
* Opens connection to remote host at selected port using declared protocol.
*
* @param: fn_uri - #FujiNet N: device connection string: N[x]:&lt;PROTO&gt;://&lt;PATH&gt;[:PORT]/
*
*
* The N: Device spec can be found here: 
* 
* <https://github.com/FujiNetWIFI/atariwifi/wiki/Using-the-N%3A-Device#the-n-devicespec>
*
*)

procedure FN_Open(var fn_uri:PChar; aux1, aux2: byte);overload;
(*
* @description:
* Opens connection to remote host at selected port using declared protocol.
*
* @param: fn_uri - #FujiNet N: device connection string: N[x]:&lt;PROTO&gt;://&lt;PATH&gt;[:PORT]/
* @param: aux1 - additional param passed to DCB
* @param: aux2 - additional param passed to DCB 
*
* The N: Device spec can be found here: 
* 
* <https://github.com/FujiNetWIFI/atariwifi/wiki/Using-the-N%3A-Device#the-n-devicespec>
*
*)

procedure FN_nlogin(user, pass:pointer);

procedure FN_WriteBuffer(buf: pointer; len: word);
(*
* @description:
* Writes (sends) data from memory to network device.
*
* @param: buf - pointer to starting address of data 
* @param: len - data length (in bytes)
*)

procedure FN_ReadBuffer(buf: pointer;len: word);
(*
* @description:
* Reads (receives) data from network device.
*
* @param: buf - pointer of buffer to store the incoming data 
* @param: len - data length (in bytes)
*)

procedure FN_ReadStatus(status: pointer);
(*
* @description:
* Reads network device status and stores information in provided memory location.
*
* @param: buf - pointer of buffer to store returned status information 
*)

procedure FN_Close;
(*
* @description:
* Closes network connection.
*)

procedure FN_Command(cmd, dstats:byte;dbyt: word;aux1, aux2:byte; dbufa: word);
(*
* @description:
* Sends SIO command to #FN device
*
* @param: cmd - DCB.DCMND byte
* @param: dstats - DCB.STATS byte
* @param: dbyt - DCB.DBYT word
* @param: aux1 - DCB.DAUX1 byte
* @param: aux2 - DCB.DAUX2 byte
* @param: dbufa - DCB.DBUFA word
*
*)

implementation

procedure FN_Command(cmd, dstats:byte;dbyt: word;aux1, aux2:byte; dbufa: word);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := cmd;
    DCB.DSTATS := dstats;
    DCB.DBUFA := dbufa;
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := dbyt;
    DCB.DAUX1 := aux1;    
    DCB.DAUX2 := aux2;   
    ExecSIO;
end;


procedure FN_Open(var fn_uri:PChar);overload;
begin
    PACTL := PACTL or 1;
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := byte('O');
    DCB.DSTATS := _W;
    DCB.DBUFA := word(@fn_uri);
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := 256;
    DCB.DAUX1 := 4;    
    DCB.DAUX2 := 0;   
    ExecSIO;
end;

procedure FN_Open(var fn_uri:PChar; aux1, aux2: byte);overload;
begin
    PACTL := PACTL or 1;
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := byte('O');
    DCB.DSTATS := _W;
    DCB.DBUFA := word(@fn_uri);
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := 256;
    DCB.DAUX1 := aux1;    
    DCB.DAUX2 := aux2;   
    ExecSIO;
end;

procedure FN_WriteBuffer(buf: pointer;len: word);
begin
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := byte('W');
    DCB.DSTATS := _W;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := len;
    DCB.DAUX1 := Lo(len);    
    DCB.DAUX2 := Hi(len);    
    ExecSIO;    
end;

procedure FN_nlogin(user, pass:pointer);
begin
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := $FD;
    DCB.DSTATS := _W;
    DCB.DBUFA := word(@user);
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := 256;
    DCB.DAUX1 := 0;    
    DCB.DAUX2 := 0;    
    ExecSIO;    
    DCB.DCMND := $FE;
    DCB.DSTATS := _W;   
    DCB.DBUFA := word(@pass);
    ExecSIO;    
end;

procedure FN_ReadBuffer(buf: pointer;len: word);
begin
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := byte('R');
    DCB.DSTATS := _R;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := len;
    DCB.DAUX1 := Lo(len);    
    DCB.DAUX2 := Hi(len);    
    ExecSIO;    
end;

procedure FN_ReadStatus(status: pointer);
begin
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := byte('S');
    DCB.DSTATS := _R;
    DCB.DBUFA := word(status);
    DCB.DTIMLO := FN_timeout;
    DCB.DBYT := 4;
    DCB.DAUX1 := 0;    
    DCB.DAUX2 := 0;    
    ExecSIO;    
end;

procedure FN_Close;
begin
    DCB.DDEVIC := $71;
    DCB.dunit := 1;
    DCB.DCMND := byte('C');
    DCB.DSTATS := _NO;
    DCB.DBUFA := 0;
    DCB.DTIMLO := FN_timeout;
    DCB.DAUX1 := 0;    
    DCB.DAUX2 := 0;   
    ExecSIO;
end;

end.
