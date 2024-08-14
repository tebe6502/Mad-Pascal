unit fn_sio;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: SIO library for #FujiNet interface.
* @version: 0.9.5

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

type FN_HostSlot = array[0..31] of char;
(*
* @description:
* Character string used to store a single host name
*)

type FN_HostSlots = array[0..7] of FN_HostSlot;
(*
* @description:
* List of all host slots (FN_HostSlot objects)
*)

type FN_DeviceSlot = record
(*
* @description:
* Structure describing a single device slot
*)
    hostSlot: byte;
    mode: byte;
    filename: array[0..35] of char;
end;

type FN_DeviceSlots = array[0..7, 0..sizeof(FN_DeviceSlot) - 1] of char;
(*
* @description:
* List of all device slots (FN_DeviceSlot objects)
*)

const
    FN_MOUNT_READ = 0;
    FN_MOUNT_WRITE = 1;

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

function FN_Command(cmd, dstats:byte;dbyt: word;aux1, aux2:byte; dbufa: word):byte;
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
* 
* @returns: (byte) - sio operation result (1 for success)
*)

procedure FN_GetHostSlots(buf: pointer);
(*
* @description:
* Retrieves a list of hosts
*
* @param: buf - pointer to an FN_HostSlots object
*)

procedure FN_GetDeviceSlots(buf: pointer);
(*
* @description:
* Retrieves a list of device slots
*
* @param: buf - pointer to an FN_DeviceSlots object
*)

procedure FN_MountHost(hs: byte);
(*
* @description:
* Mounts host with a given number
*
* @param: hs - host slot number (byte)
*)

procedure FN_UnmountHost(hs: byte);
(*
* @description:
* Unmounts host with a given number
*
* @param: hs - host slot number (byte)
*)

procedure FN_OpenDirectory(hs: byte; buf: pointer; diropt: byte);
(*
* @description:
* Opens directory for reading
*
* @param: hs - host slot number (byte)
* @param: buf - pointer to the null-terminated path
* @param: diropt - directory options (byte)
*)

procedure FN_CloseDirectory(hs: byte);
(*
* @description:
* Closes a previously opened directory
*
* @param: hs - host slot number (byte)
*)

procedure FN_ReadDirectory(maxlen: byte; hs: byte; buf: pointer);
(*
* @description:
* Reads a directory entry into `buf`
*
* @param: maxlen - maximum length of retrieved data (byte)
* @param: hs - host slot number (byte)
* @param: buf - pointer to the null-terminated path
*)

function FN_GetDirectoryPosition : word;
(*
* @description:
* Gets the current directory stream position
*
* @returns: (word) - position
*)

procedure FN_SetDirectoryPosition(pos: word);
(*
* @description:
* Sets directory stream position
*
* @param: pos - position (word)
*)

procedure FN_SetDeviceFilename(ds, hs, mode: byte; buf: pointer);
(*
* @description:
* Sets filename for mounting
*
* @param: ds - disk slot number (byte)
* @param: hs - host slot number (byte)
* @param: mode - mounting mode: (FN_MOUNT_READ|FN_MOUNT_WRITE) (byte)
* @param: buf - pointer to the null-terminated path
*)

procedure FN_MountDiskImage(slot, mode: byte);
(*
* @description:
* Mounts disk image already set using FN_SetDeviceFilename
*
* @param: slot - disk slot number (byte)
* @param: mode - mounting mode: (FN_MOUNT_READ|FN_MOUNT_WRITE) (byte)
*)

procedure FN_UnmountDiskImage(slot: byte);
(*
* @description:
* Unmounts disk image specified by `slot`
*
* @param: slot - slot number (byte)
*)

implementation

function FN_Command(cmd, dstats:byte;dbyt: word;aux1, aux2:byte; dbufa: word):byte;
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
    result:=DCB.DSTATS;
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

procedure FN_GetHostSlots(buf: pointer);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f4;
    DCB.DSTATS := _R;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := $0f;
    DCB.DBYT := sizeof(FN_HostSlots);
    ExecSIO;
end;

procedure FN_GetDeviceSlots(buf: pointer);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f2;
    DCB.DSTATS := _R;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := $0f;
    DCB.DBYT := 8 * sizeof(FN_DeviceSlot);
    DCB.DAUX1 := 0;
    ExecSIO;
end;

procedure FN_MountHost(hs: byte);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f9;
    DCB.DSTATS := _NO;
    DCB.DTIMLO := $0f;
    DCB.DBYT := 0;
    DCB.DAUX1 := hs;
    DCB.DAUX2 := 0;
    ExecSIO;
end;

procedure FN_UnmountHost(hs: byte);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $e6;
    DCB.DSTATS := _NO;
    DCB.DTIMLO := $0f;
    DCB.DBYT := 0;
    DCB.DAUX1 := hs;
    DCB.DAUX2 := 0;
    ExecSIO;
end;

procedure FN_OpenDirectory(hs: byte; buf: pointer; diropt: byte);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f7;
    DCB.DSTATS := _W;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := $0f;
    DCB.DBYT := 256;
    DCB.DAUX1 := hs;
    DCB.DAUX2 := diropt;
    ExecSIO;
end;

procedure FN_ReadDirectory(maxlen: byte; hs: byte; buf: pointer);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f6;
    DCB.DSTATS := _R;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := $0f;
    DCB.DBYT := maxlen;
    DCB.DAUX1 := maxlen;
    DCB.DAUX2 := hs;
    ExecSIO;
end;

function FN_GetDirectoryPosition : word;
var pos : word;
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $e5;
    DCB.DSTATS := _R;
    DCB.DBUFA := word(@pos);
    DCB.DTIMLO := $0f;
    DCB.DBYT := 2;
    DCB.DAUX1 := 0;
    DCB.DAUX2 := 0;
    ExecSIO;
    result := pos;
end;

procedure FN_SetDirectoryPosition(pos: word);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $e4;
    DCB.DSTATS := _NO;
    DCB.DTIMLO := $0f;
    DCB.DBYT := 0;
    DCB.DAUX1 := lo(pos);
    DCB.DAUX2 := hi(pos);
    ExecSIO;
end;

procedure FN_CloseDirectory(hs: byte);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f5;
    DCB.DSTATS := _NO;
    DCB.DTIMLO := $0f;
    DCB.DBYT := 0;
    DCB.DAUX1 := hs;
    DCB.DAUX2 := 0;
    ExecSIO;
end;

procedure FN_SetDeviceFilename(ds, hs, mode: byte; buf: pointer);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $e2;
    DCB.DSTATS := _W;
    DCB.DBUFA := word(buf);
    DCB.DTIMLO := $0f;
    DCB.DBYT := 256;
    DCB.DAUX1 := ds;
    DCB.DAUX2 := mode + 16 * hs;
    ExecSIO;
end;

procedure FN_MountDiskImage(slot: byte; mode: byte);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $f8;
    DCB.DSTATS := _NO;
    DCB.DBUFA := 0;
    DCB.DTIMLO := $0f;
    DCB.DBYT := 0;
    DCB.DAUX1 := slot;
    DCB.DAUX2 := mode + 1;
    ExecSIO;
end;

procedure FN_UnmountDiskImage(slot: byte);
begin
    DCB.DDEVIC := $70;
    DCB.dunit := 1;
    DCB.DCMND := $e9;
    DCB.DSTATS := _NO;
    DCB.DBUFA := word(@slot);
    DCB.DTIMLO := $0f;
    DCB.DBYT := 0;
    DCB.DAUX1 := $ff;
    DCB.DAUX2 := 0;
    ExecSIO;
end;

end.
