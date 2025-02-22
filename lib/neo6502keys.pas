unit neo6502keys;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Neo6502 library for reading keyboard state using hid scancodes
* @version: 0.30.0

* @description:
* Set of constans and helpers for reading Neo6502 keyboard, using hid scancodes.
* More about Neo6502:
*
* <https://www.olimex.com/Products/Retro-Computers/Neo6502/open-source-hardware>
*
* <https://www.neo6502.com/>

*
* API documentation can be found here:
*
* <https://github.com/paulscottrobson/neo6502-firmware/wiki>

*
* It's work in progress, so please report any bugs you will find.
*
*)
interface
uses neo6502;
{$i hid_keycodes.inc}

type TKey = record
(*
* @description:
* Structure used to store information about last pressed key
*)
    code:byte;
    ctrl:boolean;
    shift:boolean;
    alt:boolean;
    meta:boolean;
end;

procedure ReadKeyboard(var ukey:TKey);
(*
* @description:
* It reads status of all keys and returns code of last key pressed and state of modifier keys (Shift, Alt, Ctrl)
*
* @param: ukey (TKey) - key data structure to which the result will be written
*
*)
function IsKeyDown(ukey:TKey):boolean;
(*
* @description:
* Returns the state of the particular key with required modifiers.
*
* Example:  IsKeyDown(KEY_S,MOD_CTRL or MOD_SHIFT);
*
* @param: ukey (TKey) - key data structure containing keycode and expected modifiers.
*
* @returns: (boolean) - returns true if key is down with required modifier keys
*)
implementation

function IsKeyDown(ukey:TKey):boolean;
var m:byte;
begin
    result:=true;
    if NeoIsKeyPressed(ukey.code)=0 then exit(false);
    m := NeoMessage.params[1];
    if ((m and MOD_CTRL) <> 0) <> ukey.ctrl then exit(false);
    if ((m and MOD_SHIFT) <> 0) <> ukey.shift then exit(false);
    if ((m and MOD_ALT) <> 0) <> ukey.alt then exit(false);
    if ((m and MOD_META) <> 0) <> ukey.meta then exit(false);
end;

procedure ReadKeyboard(var ukey:TKey);
var b,m: byte;
begin
    ukey.code := 0;
    for b:=KEY_MIN_CODE to KEY_MAX_CODE do if NeoIsKeyPressed(b)<>0 then ukey.code := b;
    m := NeoMessage.params[1];
    ukey.ctrl := (m and MOD_CTRL) <> 0;
    ukey.shift := (m and MOD_SHIFT) <> 0;
    ukey.alt := (m and MOD_ALT) <> 0;
    ukey.meta := (m and MOD_META) <> 0;
end;


end.