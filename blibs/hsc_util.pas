unit hsc_util;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Hi Score Cafe Library for #FujiNet interface.
* @version: 0.9.0

* @description:
* Set of procedures to communicate with Hi Score Cafe server <https://xxl.atari.pl/hsc/> using #FujiNet interface on SIO level. <https://fujinet.online/>
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses sio,fn_sio;

const 
	APPKEYMODE_READ = 0;  // @nodoc 
    SIO_FUJICMD_READ_APPKEY = $DD;  // @nodoc 
    SIO_FUJICMD_OPEN_APPKEY = $DC;  // @nodoc 
    SIO_FUJICMD_CLOSE_APPKEY = $DB; // @nodoc 
    _R = $40;  // @nodoc 
    _W = $80;  // @nodoc 
    _NO = $00;  // @nodoc 

var cookieInfo : array [0..5] of byte = ( $c1,$b0,$ca,$fe,APPKEYMODE_READ,0);  // @nodoc 
	boardSize : word;  (* @var Number of bytes received during last HSC_Get command *)

type AOC = array [0..0] of char;  // @nodoc 

procedure HSC_MakeToken(id:word;score:cardinal;var hscToken:AOC);
(*
* @description:
* Creates request token consisting game id and score.
*
* @param: id - game id in Hi Score Cafe system
* @param: score - user score
* @param: hscToken - array of char where the Token is created
*
*)

function HSC_Send(var hscToken:AOC;var hscBuffer:AOC):byte;overload;
(*
* @description:
* Sends tokenized user result to Hi Score Cafe server. Function checks if fujinet is present,
* then checks for autorization token on SD card, and then tries to send user result to HSC.
*
* @param: hscToken - array of char where the Token is created
* @param: hscBuffer - buffer needed to create request query (80 bytes should be enough)
*
* @returns: (byte) - returns 1 when operation successful. Otherwise returns sio error code.
*)

function HSC_Send(id:word;score:cardinal;var hscBuffer:AOC):byte;overload;
(*
* @description:
* Sends user result to Hi Score Cafe server. Function checks if fujinet is present,
* then checks for autorization token on SD card, and then tries to send user result to HSC.
*
* @param: id - game id in Hi Score Cafe system
* @param: score - user score
* @param: hscBuffer - buffer needed to create request query (80 bytes should be enough)
*
* @returns: (byte) - returns 1 when operation successful. Otherwise returns sio error code.
*)

function HSC_Get_Formated(id:byte;buff:pointer):byte;overload;
(*
* @description:
* Receives screen formated hi score table for specified game, and stores it in buffer.
* Result is formated as 40 chars aligned text, in ANTIC screen codes.
* It can be directly written to screen memory.
*
* @param: id - game id in Hi Score Cafe system
* @param: buff - buffer needed to store result (400 bytes for 10 results)
*
* @returns: (byte) - returns 1 when operation successful. Otherwise returns sio error code.
*)

function HSC_Get(id:byte;buff:pointer):byte;overload;
(*
* @description:
* Receives hi score table for specified game, and stores it in buffer.
* Result is a text block, formated as JSON array, in clean ATASCII.
* It should be parsed by user before displaying.
*
* @param: id - game id in Hi Score Cafe system
* @param: buff - buffer needed to store result (much less than formated one)
*
* @returns: (byte) - returns 1 when operation successful. Otherwise returns sio error code.
*)


implementation

    
procedure HSC_MakeToken(id:word;score:cardinal;var hscToken:AOC);
var s:string[20];
	l:byte;
begin
	Str(id,s);
	l:=Length(s);
	hscToken[0]:='0';
	hscToken[1]:='0';
	move(s[1],hscToken[3-l],l);
	Str(score,s);
	l:=Length(s);
	move(s[1],hscToken[3],l);
	hscToken[3+l]:=#0;
end;

function HSC_Send(var hscToken:AOC;var hscBuffer:AOC):byte;overload;
var name:pchar;
begin
	result := 1;
	name := @hscBuffer[2];
	FN_Command(SIO_FUJICMD_OPEN_APPKEY,_W,6,0,0,word(@cookieInfo));
	if sioResult<>1 then exit(sioResult);
	FN_Command(SIO_FUJICMD_READ_APPKEY,_R,66,0,0,word(@hscBuffer));
	FN_Command(SIO_FUJICMD_CLOSE_APPKEY,_NO,0,0,0,0);
	move(hscToken,hscBuffer[1+byte(hscBuffer[0])],16);
	FN_Open(name);
	if sioResult<>1 then exit(sioResult);
	FN_ReadStatus(hscBuffer);
	if sioResult<>1 then exit(sioResult);
	FN_Close();
end;

function HSC_Send(id:word;score:cardinal;var hscBuffer:AOC):byte;overload;
var name:pchar;
	token:pchar;
begin
	result := 1;
	name := @hscBuffer[2];
	FN_Command(SIO_FUJICMD_OPEN_APPKEY,_W,6,0,0,word(@cookieInfo));
	if sioResult<>1 then exit(sioResult);
	FN_Command(SIO_FUJICMD_READ_APPKEY,_R,66,0,0,word(@hscBuffer));
	FN_Command(SIO_FUJICMD_CLOSE_APPKEY,0,0,0,0,0);
	token := @hscBuffer[1+byte(hscBuffer[0])];
	HSC_MakeToken(id,score,token);
	FN_Open(name);
	if sioResult<>1 then exit(sioResult);
	FN_ReadStatus(hscBuffer);
	if sioResult<>1 then exit(sioResult);
	FN_Close();
end;

function WaitAndParseRequest(buff:pointer):byte;
var 
	timeout:byte;
	bytesWaiting:word;
	ioStatus: FN_StatusStruct;
begin
    boardSize := 0;
    result := 1;
    timeout := 3;
    repeat 
        bytesWaiting := 0;
        FN_ReadStatus(ioStatus);
        if (ioStatus.errorCode <> 1) and (boardSize = 0) then exit(0);
        bytesWaiting := ioStatus.dataSize;
        if bytesWaiting > 0 then begin
            FN_ReadBuffer(buff, bytesWaiting);
            boardSize := boardSize + bytesWaiting;
        end;
        dec(timeout);
    until ((bytesWaiting = 0) and (boardSize <> 0)) or (timeout=0);
    if timeout=0 then result:=$ff;
end;

function HSC_Get_Formated(id:byte;buff:pointer):byte;overload;
var uri:pchar = 'N:https://atari.pl/hsc/jboard.php?x='#0#0#0#0;
	s:string[4];
begin
	Str(id,s);
	move(s[1], pointer(word(@uri)+36), byte(s[0]));
	FN_Open(uri);
	if sioResult <> 1 then exit(sioResult);
	sioResult := WaitAndParseRequest(buff);
	if sioResult <> 1 then exit(sioResult);
    FN_Close;    	
end;	

function HSC_Get(id:byte;buff:pointer):byte;overload;
var uri:pchar = 'N:https://atari.pl/hsc/jboard.php?f=J&x='#0#0#0#0;
	s:string[4];
begin
	Str(id,s);
	move(s[1], pointer(word(@uri)+40), byte(s[0]));
	FN_Open(uri);
	if sioResult <> 1 then exit(sioResult);
	sioResult := WaitAndParseRequest(buff);
	if sioResult <> 1 then exit(sioResult);
    FN_Close;    	
end;	


end.
