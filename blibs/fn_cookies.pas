unit fn_cookies;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: #FujiNet library for using APPKEY storage build in #FujiNet device. 
* @version: 0.1.0

* @description:
* This library provides an easy interface to store so called APPKEYS or cookies on SD card
* of your fujinet device.
* 
* Those tiny data blobs can be used by applications to store some data, like configuration, keys,
* tokens on the device itself. 
* 
* They are not public, and persistent on your device, until you will remove them manually from your SD card.
* 
* Maximum size of single cookie is 64 bytes.
* 
* <https://fujinet.online/>
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses sio, fn_sio;

const 
    MAX_COOKIE_SIZE = 64; 

    APPKEYMODE_READ = 0;    // @nodoc 
    APPKEYMODE_WRITE = 1;   // @nodoc 
    APPKEYMODE_INVALID = 2; // @nodoc 

    SIO_FUJICMD_WRITE_APPKEY = $DE; // @nodoc 
    SIO_FUJICMD_READ_APPKEY = $DD;  // @nodoc 
    SIO_FUJICMD_OPEN_APPKEY = $DC;  // @nodoc 
    SIO_FUJICMD_CLOSE_APPKEY = $DB; // @nodoc 

type TCookieFrame = record
(*
* @description: 
* Structure used to retrieve cookie from storage
*)
    len: word;
    body: array [0..MAX_COOKIE_SIZE-1] of byte;
end;

type TCookieInfo = record
(*
* @description: 
* Structure used to set cookie info in Open Command
*)
    creator: word;
    app: byte;
    key: byte;
    mode: byte;
    reserved: byte;
end;

var
    cookie: TCookieFrame; // variable containing returned cookie frame
    cInfo: TCookieInfo;   // info variable passed on every open command

procedure InitCookie(creator: word; app, key: byte);
(*
* @description:
* Inits cookie storage params, and sets unique filename based on provided ID_keys.
* Must be called at least once, before any Set or Get command is issued.
*
* @param: (word) creator - creator ID number
* @param: (byte) app - application ID number
* @param: (byte) key - key ID number
*
*)
function SetCookie(val: pointer; vlength: word):byte;
(*
* @description:
* Stores new cookie value.
*
* @param: (pointer) val - value to be stored 
* @param: (word) vlength - length of data in bytes (max. 64)
*
* @returns: (byte) - sio operation result
*)
function GetCookie(val: pointer):byte;
(*
* @description:
* Restores cookie value from device, to buffer.
* 
* Size of received data is returned in cookie.len field.
*
* @param: (pointer) val - pointer to receive buffer
*
* @returns: (byte) - sio operation result
*)

implementation

var oldTimeout: byte;

procedure InitCookie(creator: word; app, key: byte);
begin
    cInfo.creator := creator;
    cInfo.app := app;
    cInfo.key := key;
end;

function OpenCookie(mode: byte):byte;
begin
    cInfo.mode := mode;
    oldTimeout := FN_timeout;
    FN_timeout := 1;
    FN_Command(SIO_FUJICMD_OPEN_APPKEY, _W, SizeOf(TCookieInfo), 0, 0, word(@cInfo));
    result := sioResult;
end;

function CloseCookie:byte;
begin
    FN_Command(SIO_FUJICMD_CLOSE_APPKEY, _NO, 0, 0, 0, 0);
    result := sioResult;
    FN_timeout := oldTimeout;
end;

function SetCookie(val: pointer; vlength: word):byte;
begin
    if vlength > MAX_COOKIE_SIZE then vlength := MAX_COOKIE_SIZE;
    OpenCookie(APPKEYMODE_WRITE);
    Move(val, @cookie.body, vlength);
    FN_Command(SIO_FUJICMD_WRITE_APPKEY , _W, MAX_COOKIE_SIZE, lo(vlength), hi(vlength), word(@cookie.body));
    result := sioResult;
    CloseCookie;
end;

function GetCookie(val: pointer):byte;
begin
    OpenCookie(APPKEYMODE_READ);
    FN_Command(SIO_FUJICMD_READ_APPKEY, _R, SizeOf(TCookieFrame), 0, 0, word(@cookie));
    result := sioResult;
    Move(@cookie.body, val, cookie.len);
    CloseCookie;
end;

end.
