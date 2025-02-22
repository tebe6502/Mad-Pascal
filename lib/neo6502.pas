unit neo6502;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Neo6502 API library for Mad-Pascal.
* @version: 0.40.0

* @description:
* Set of procedures to cover API functionality provided by:
*
* <https://www.olimex.com/Products/Retro-Computers/Neo6502/open-source-hardware>
*
* <https://www.neo6502.com/>
*
*
* API documentation can be found here:
*
* <https://github.com/paulscottrobson/neo6502-firmware/wiki>
*
*
* It's work in progress, so please report any bugs you will find.
*
*)

interface
const
    N6502MSG_ADDRESS = $ff00;
    NEO_GFX_RAM = $ffff;

    FI_PrintDir = 1;  // @nodoc
    FI_LoadFile = 2;  // @nodoc
    FI_SaveFile = 3;  // @nodoc
    FI_OpenFile = 4;  // @nodoc
    FI_CloseFile = 5;  // @nodoc
    FI_SeekPos = 6;  // @nodoc
    FI_TellPos = 7;  // @nodoc
    FI_ReadData = 8;  // @nodoc
    FI_WriteData = 9;  // @nodoc
    FI_GetSize = 10;  // @nodoc
    FI_SetSize = 11;  // @nodoc
    FI_Rename = 12;  // @nodoc
    FI_Delete = 13;  // @nodoc
    FI_NewDir = 14;  // @nodoc
    FI_ChangeDir = 15;  // @nodoc
    FI_StatFile = 16;  // @nodoc
    FI_OpenDir = 17;  // @nodoc
    FI_ReadDir = 18;  // @nodoc
    FI_CloseDir = 19;  // @nodoc
    FI_CopyFile = 20;  // @nodoc
    FI_SetAttr = 21;  // @nodoc

    FI_PrintDirWildcard = 32;      // @nodoc

    OPEN_MODE_RO = 0; // opens the file for read-only access;
    OPEN_MODE_WO = 1; // opens the file for write-only access;
    OPEN_MODE_RW = 2; // opens the file for read-write access;
    OPEN_MODE_NEW = 3; // creates the file if it doesn’t already exist, truncates it if it does, and opens the file for read-write access.

    FI_ATTR_DIRECTORY = 1; // mask for directory attribute
    FI_ATTR_SYSTEM = 2; // mask for system attribute
    FI_ATTR_ARCHIVE = 4; // mask for archive attribute
    FI_ATTR_READONLY = 8; // mask for read only attribute
    FI_ATTR_HIDDEN = 16; // mask for hidden attribute

    MEM_6502 = 0;       // 6502 ram offset
    MEM_VRAM = $800000; // Video ram offset for blitter addresing
    MEM_GFX = $900000;  // Graphics ram (tiles/sprites) offset for blitter addresing

    BLTACT_COPY = 0;     // Blitter action: copy
    BLTACT_MASK = 1;     // Blitter action: copycopy, but only where src is not the transparent value.
    BLTACT_SOLID = 2;    // Blitter action: set target to constant solid value, but only where src is not the transparent value.

    BLTFORM_BYTE = 0;     // Blitter data format: bytes. Supported for both source and target.
    BLTFORM_PAIRS = 1;    // Blitter data format: pairs of 4-bit values (nibbles). Source only.
    BLTFORM_1BPP = 2;     // Blitter data format: 8 single-bit values. Source only.
    BLTFORM_UPPER4 = 3;   // Blitter data format: high nibble. Target only.
    BLTFORM_LOWER4 = 4;   // Blitter data format: low nibble. Target only.

type TN6502Message = record
(*
* @description:
* Structure used to prepare API message
*)
    group:byte;
    func:byte;
    error:byte;
    status:byte;
    params:array[0..7] of byte;
end;

type TSound = record
(*
* @description:
* Structure used to store note parameters
*)
    channel:byte;
    freq:word;
    len:word;
    slide:word;
    stype:byte;
    vol:byte;
end;

type TTileMapHeader = record
    format:byte;
    width:byte;
    height:byte;
end;

type TBlitBlock = record
    address: cardinal;
    stride: word;
    format: byte;
    transparent: byte;
    solid: byte;
    height: byte;
    width: word;
end;

var
    NeoMessage:TN6502Message absolute N6502MSG_ADDRESS;  // structure used to communicate with neo6502 API
    wordParams: array[0..3] of word absolute N6502MSG_ADDRESS+4; // helping structure to easliy obrain or set word parametrs
    dwordParams: array[0..1] of cardinal absolute N6502MSG_ADDRESS+4; // helping structure to easliy obrain or set cardinal parametrs
    wordxParams: array[0..2] of word absolute N6502MSG_ADDRESS+5; // @nodoc
    soundParams: TSound absolute N6502MSG_ADDRESS+4; // @nodoc
    FI_openfilename: word absolute N6502MSG_ADDRESS+5; // @nodoc
    FI_filename: word absolute N6502MSG_ADDRESS+4; // @nodoc
    FI_filename2: word absolute N6502MSG_ADDRESS+6; // @nodoc
    FI_dirSize: cardinal absolute N6502MSG_ADDRESS+6; // @nodoc
    FI_dirAttr: byte absolute N6502MSG_ADDRESS+10; // @nodoc
    FI_statSize: cardinal absolute N6502MSG_ADDRESS+4; // @nodoc
    FI_statAttr: byte absolute N6502MSG_ADDRESS+8; // @nodoc
    FI_channel: byte absolute N6502MSG_ADDRESS+4; // @nodoc
    FI_offset: cardinal absolute N6502MSG_ADDRESS+5; // @nodoc
    FI_address: word absolute N6502MSG_ADDRESS+5; // @nodoc
    FI_length: word absolute N6502MSG_ADDRESS+7; // @nodoc
    neoMouseX: word absolute N6502MSG_ADDRESS+4; // @nodoc
    neoMouseY: word absolute N6502MSG_ADDRESS+6; // @nodoc
    neoMouseButtons: byte absolute N6502MSG_ADDRESS+8; // @nodoc
    neoMouseWheel: byte absolute N6502MSG_ADDRESS+9; // @nodoc

function NeoSendMessage(group,func:byte):byte;
(*
* @description:
* Sends structure stored in NeoMessage, to Neo6502 API
*
* @param: group (byte) - API command group
* @param: func (byte) - API function within the group
*
* @returns: (byte) - Parameter0 is returned directly. All remaining returned params are avaliable via NeoMessage record
*)
procedure NeoWaitMessage;inline;assembler;
(*
* @description:
* Waits until Message from API is returned.
*)

/////////////// GROUP 1 - system

procedure NeoSubReset;
(*
* @description:
* Resets the messaging system and its components. Should not normally be used.
*)
function NeoGetVblanks:cardinal;
(*
* @description:
* Return the number of vblanks since power on. This isupdated at the start of the vblank period.
*
* @returns: (cardinal) - number of vblanks
*)
procedure NeoWaitForVblank;
(*
* @description:
* Wait for new vblank.
*)
function NeoGetTimer:cardinal;
(*
* @description:
* Get the value of the 100Hz system timer.
*
* @returns: (cardinal) - system timer
*)
procedure NeoExecuteBasic;
(*
* @description:
* Execute BASIC
*)
procedure NeoCredits;
(*
* @description:
* Prints the list of people involved, stored in Flash to save memory.
*)
function NeoCheckSerial:byte;
(*
* @description:
* Check the serial port to see if there is a data transmission. This is done automatically in Key Read.
*
* @returns: (byte) - serial state
*)
procedure NeoSetLocale(lang:string[2]);
(*
* @description:
* Sets the specified locale code (EN.FR,GE...)
*
* @param: name (string[2]) - name of locale in upper-case ASCII
*)
procedure NeoReset;
(*
* @description:
* System Reset. This is a full hardware reset. It resets the RP2040 using the Watchdog timer, and this also resets the 65C02.
*)
procedure NeoMOS(cmd:pointer);
(*
* @description:
* Do a MOS command (a '* command') these are specified in the Wiki as they will be steadily expanded.
*
* @param: cmd (pointer) - pointer to command string
*)
procedure NeoWriteDebug(c:byte);
(*
* @description:
* Writes a single character to the debug port (the UART on the Pico, or stderr on the emulator). This allows maximum flexibility.
*
* @param: c (byte) - byte to be written
*)

/////////////// GROUP 2 - console

function NeoIsKeyPressed(key:byte):byte;
(*
* @description:
* Return the state of keyboard key
*
* @param: key (byte) - key to be checked
*
* @returns: (byte) - state of key
*)

procedure NeoSetChar(c:byte;data:pointer);
(*
* @description:
* Use bits 0..5 of data bytes to define a selected font character
*
* @param: c (byte) - code of char to be defined (192-255)
* @param: data (pointer) - pointer to 7 bytes of data
*)

procedure NeoDefineHotkey(keynum:byte;txt:pointer);
(*
* @description:
* Define the function key F1..F10 ($01..$0A) specified as keynum
* to emit the length-prefixed string stored at the memory location
* specified in txt. F11 and F12 cannot currently be defined.
*
* @param: keynum (byte) - Number of function key (1-10)
* @param: txt (pointer) - pointer to the length-prefixed string to be emited on the key press
*)

procedure NeoShowHotkeys;
(*
* @description:
* Displays the current settings of the function keys
*)

procedure NeoGetScreenSize(var height:byte;var width:byte);
(*
* @description:
* Returns the console size in characters.
*
* @param: height (byte) - height of the screen
* @param: width (byte) - width of the screen
*
* @returns: (byte) - state of key
*)

procedure NeoSetTextColor(foreground,background:byte);
(*
* @description:
* Returns the console size in characters.
*
* @param: foreground (byte) - foreground color
* @param: background (byte) - background color
*)

procedure NeoGetCursorPos(var x:byte;var y:byte);
(*
* @description:
* Returns cursor position
*
* @param: x (byte) - horizontal position
* @param: y (byte) - vertical position
*)

procedure NeoClearRegion(x0,y0,x1,y1:byte);
(*
* @description:
* Erase all characters within the specified rectangular region.
*
* @param: x0,y0 (byte) - starting point coordinates
* @param: x1,y1 (byte) - ending point coordinates
*)

procedure NeoCursorInverse;
(*
* @description:
* Toggles the cursor colour between normal and inverse (swaps FG and BG colors).
*)

///////////////////////////////////////////////// GROUP 3 - filesystem


procedure NeoShowDir;
(*
* @description:
* Displays the storage directory.
*)
function NeoLoad(name:TString;dest:word):boolean;
(*
* @description:
* Loads a named file from storage to selected address.
*
* If the address is $FFFF the file is loaded into the graphic memory area used for sprites, tiles, images.
*
* @param: name (TString) - name of the file with extension
* @param: dest (word) - target data address
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoSave(name:TString;dest,len:word):boolean;
(*
* @description:
* Saves chunk of memory from defined address to a named file on storage.
* *
* @param: name (TString) - name of the file with extension
* @param: dest (word) - source data address
* @param: len (word) - numer of bytes to be saved
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoOpenFile(channel:byte;name:pointer;openmode:byte):boolean;
(*
* @description:
* Opens a file into a specific channel. Modes 0 to 2 will fail if the file does not already exist.
* If the channel is already open, the call fails. Opening the same file more than once on
* different channels has undefined behaviour and is not recommended.
*
* @param: channel (byte) - channel number (0-255)
* @param: name (pointer) - pointer to length prefixed string containing file name
* @param: openmode (byte) - open mode. See constants above.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoCloseFile(channel:byte):boolean;
(*
* @description:
* Closes a particular channel.
*
* @param: channel (byte) - channel number (0-255)
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoSeekPos(channel:byte;pos:cardinal):boolean;
(*
* @description:
* Seeks the file opened on a particular channel to a location.
* You can seek beyond the end of a file to extend the file. Whether the
* file size changes when the seek happens or when you perform the write
* is undefined.
*
* @param: channel (byte) - channel number (0-255)
* @param: pos (cardinal) - file location
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoTellPos(channel:byte):cardinal;
(*
* @description:
* Returns the current seek location for the file opened on a particular channel.
*
* @param: channel (byte) - channel number (0-255)
*
* @returns: (cardinal) - file location.
*)
function NeoReadFile(channel:byte;addr:word;len:word):word;
(*
* @description:
* Reads data from an opened file.
* Data is read from the current seek position, which is advanced after the read.
*
* @param: channel (byte) - channel number (0-255)
* @param: addr (word) - points to the destination in memory, or $FFFF to write to graphics memory
* @param: len (word) - amount of data to read
*
* @returns: (word) - returns the amount of data actually read
*)
function NeoWriteFile(channel:byte;addr:word;len:word):word;
(*
* @description:
* Writes data to an opened file.
* Data is written to the current seek position, which is advanced after the write.
*
* @param: channel (byte) - channel number (0-255)
* @param: addr (word) - points to the source of data in memory
* @param: len (word) - amount of data to write
*
* @returns: (word) - returns the amount of data actually written
*)
function NeoGetFileSize(channel:byte):cardinal;
(*
* @description:
* Returns the current size of an opened file
*
* This call should be used on open files and takes into account any
* buffered data which has not yet been written to disk. As a result it
* may return a different size to the NeoStatFile described below.
*
* @param: channel (byte) - channel number (0-255)
*
* @returns: (cardinal) - file size
*)
function NeoSetFileSize(channel:byte;size:cardinal):boolean;
(*
* @description:
* Extends or truncates an opened file to a particular size.
*
* @param: channel (byte) - channel number (0-255)
* @param: size (cardinal) - the new size of the file.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoRenameFile(fin,fout:pointer):boolean;
(*
* @description:
* Renames a file.
*
* @param: fin (pointer) - pointer to length-prefixed string for the old name
* @param: fout (pointer) - pointer to length-prefixed string for the new name
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoDeleteFile(fin:pointer):boolean;
(*
* @description:
* Deletes a file or directory.
*
* @param: fin (pointer) - pointer to length-prefixed filename string.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoCreateDirectory(fin:pointer):boolean;
(*
* @description:
* Creates a new directory.
*
* @param: fin (pointer) - pointer to length-prefixed path string.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoChangeDirectory(fin:pointer):boolean;
(*
* @description:
* Changes the current working directory.
*
* @param: fin (pointer) - pointer to length-prefixed path string.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoStatFile(fin:pointer;var size:cardinal;var attr:byte):boolean;
(*
* @description:
* Retrieves information about a file by name and returns it by referenced variables.
*
* If the file is open for writing, this may not return the correct size due
* to buffered data not having been flushed to disk.
*
* File attributes are a bitfield as follows:
* 0 - directory
* 1 - system
* 2 - archive
* 3 - read only
* 4 - hidden
*
* @param: fin (pointer) - pointer to length-prefixed path string.
* @param: size (cardinal) - reference to size variable.
* @param: attr (byte) - reference to attribute variable.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoOpenDirectory(fin:pointer):boolean;
(*
* @description:
* Opens a directory for enumeration.
* Only one directory at a time may be opened. If a directory is already
* open when this call is made, it is automatically closed; however, an
* open directory may make it impossible to delete the directory, so closing
* the directory after use is good practice.
*
* @param: fin (pointer) - pointer to length-prefixed path string.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoReadDirectory(var fname:string;var size:cardinal;var attr:byte):boolean;
(*
* @description:
* Reads an item from the currently open directory.
* This call fails if there are no more items to read.
*
* @param: fname (pointer) - reference to filename string that gets updated.
* @param: size (cardinal) - reference to size variable.
* @param: attr (byte) - reference to attribute variable.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoCloseDirectory:boolean;
(*
* @description:
* Closes any directory opened by Open Directory.
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoCopyFile(fin,fout:pointer):boolean;
(*
* @description:
* Copies a file.
*
* @param: fin (pointer) - pointer to length-prefixed string for the old name
* @param: fout (pointer) - pointer to length-prefixed string for the new name
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
function NeoSetAttr(fin:pointer;var attr:byte):boolean;
(*
* @description:
* Sets file/directory attributes.
*
* File attributes are a bitfield as follows:
* 0 - directory (cannot be changed)
* 1 - system
* 2 - archive
* 3 - read only
* 4 - hidden
*
* @param: fin (pointer) - pointer to length-prefixed path string.
* @param: attr (byte) - file attribute
*
* @returns: (boolean) - true on success. On false error code is returned in NeoMessage.error
*)
procedure NeoSearchDir(var searchstring:string);
(*
* @description:
* Prints a filtered file listing of the current directory to the console. On input:
*
* @param: searchString (string) - length-prefixed searchstring
*)

//////////////////////////////////////////////////////////////////////////////

function NeoDoMath(func:byte):byte;
(*
* @description:
* Performs API request to math coprocessing library. Not well documented yet.
*
* @param: func (byte) - number of function to be called
*)

//////////////////////////////////////////////////////////////////////////////

procedure NeoSetDefaults(acol,xcol,solid,size,flip:byte);
(*
* @description:
* Sets colour for upcoming drawing operations.
*
* @param: acol (byte) - value that will be ANDED with current colour
* @param: xcol (byte) - value that will be XORED with current colour
* @param: solid (byte) - solid flag (0=empty, 1=solid)
* @param: size (byte) - dimension (for text)
* @param: flip (byte) - flip flag for tiles (0=none, 1=horizontal, 2=vertical, 3=both)
*
*)
procedure NeoDrawLine(x0,y0,x1,y1:word);
(*
* @description:
* Draws a line.
*
* @param: x0 (word) - first x coordinate
* @param: y0 (word) - first y coordinate
* @param: x1 (word) - second x coordinate
* @param: y1 (word) - second y coordinate
*
*)
procedure NeoDrawRect(x0,y0,x1,y1:word);
(*
* @description:
* Draws a rectangle.
*
* @param: x0 (word) - first x coordinate
* @param: y0 (word) - first y coordinate
* @param: x1 (word) - second x coordinate
* @param: y1 (word) - second y coordinate
*
*)
procedure NeoDrawEllipse(x0,y0,x1,y1:word);
(*
* @description:
* Draws ellipse.
*
* @param: x0 (word) - first x coordinate
* @param: y0 (word) - first y coordinate
* @param: x1 (word) - second x coordinate
* @param: y1 (word) - second y coordinate
*
*)
procedure NeoDrawPixel(x0,y0:word);
(*
* @description:
* Draws single pixel.
*
* @param: x0 (word) - x coordinate
* @param: y0 (word) - y coordinate
*)
procedure NeoWritePixel(x0,y0:word;c:byte);
(*
* @description:
* Draws single pixel.
*
* @param: x0 (word) - x coordinate
* @param: y0 (word) - y coordinate
* @param: c (byte) - color index
*)
procedure NeoDrawString(x0,y0:word;var s:string);
(*
* @description:
* Prints e string at the specified location.
*
* @param: x0 (word) - x coordinate
* @param: y0 (word) - y coordinate
* @param: s (string) - string to be printed
*)
procedure NeoDrawImage(x0,y0:word;id:byte);
(*
* @description:
* Puts an image from the graphic memory to desired location.
*
* @param: x0 (word) - x coordinate
* @param: y0 (word) - y coordinate
* @param: id (byte) - image id (0-127 tiles, 128-191 sprites 16, 192-255 sprites 32);
*)
procedure NeoDrawTileMap(x0,y0,x1,y1:word);
(*
* @description:
* Draws current tilemap on desired area.
*
* @param: x0 (word) - first x coordinate
* @param: y0 (word) - first y coordinate
* @param: x1 (word) - second x coordinate
* @param: y1 (word) - second y coordinate
*
*)
procedure NeoSetPalette(col,r,g,b:byte);
(*
* @description:
* Changes color in system pallette.
*
* @param: col (byte) - color number to be changed
* @param: r (byte) - red component
* @param: g (byte) - green component
* @param: b (byte) - blue component
*
*)
procedure NeoGetPalette(col:byte;var r:byte;var g:byte;var b:byte);
(*
* @description:
* Returns selected color rgb components from system pallette.
*
* @param: col (byte) - color number to be returned
* @param: r (byte) - reference to red component
* @param: g (byte) - reference to green component
* @param: b (byte) - reference to blue component
*
*)
function NeoGetPixel(x,y:word):byte;
(*
* @description:
* Reads pixel. Sets error if out of range.
*
* @param: x (word) - x coordinate
* @param: y (word) - y coordinate
*
* @returns: (byte) - returned pixel value
*)
procedure NeoResetPalette;
(*
* @description:
* Resets system palette to default.
*)
procedure NeoSelectTileMap(mem,xoffset,yoffset:word);
(*
* @description:
* Sets the current tilemap.
*
* @param: mem (word) - address in 6502 memory of Tilemap definition (header needed)
* @param: xoffset (word) - left offset in pixels
* @param: yoffset (word) - top offser in pixels
*)
function NeoGetSpritePixel(x,y:word):byte;
(*
* @description:
* Reads pixel from sprite layer. (0-15, 0 = transparency) Sets error if out of range.
*
* @param: x (word) - x coordinate
* @param: y (word) - y coordinate
*
* @returns: (byte) - returned pixel value
*)
procedure NeoSetColor(col:byte);
(*
* @description:
* Sets colour for upcoming drawing operations.
*
* @param: col (byte) - value that will be XORED with current colour
*)
procedure NeoSetSolidFlag(flag:byte);
(*
* @description:
* Sets the solid flag, which indicates either solid fill (for
* shapes) or solid background (for images and fonts)
*
* @param: flag (byte) - 0 empty / 1 solid
*)
procedure NeoSetDrawSize(size:byte);
(*
* @description:
* Sets the drawing scale for images and fonts
*
* @param: size (byte) - drawing size
*)
procedure NeoSetFlip(flip:byte);
(*
* @description:
* Sets the flip bits for drawing images. Bit 0 set causes a horizontal flip,
* bit 1 set causes a vertical flip.
*
* @param: flip (byte) - flip byte
*)

////////////////////////////////////////////////////////  SPRITES

procedure NeoResetSprites;
(*
* @description:
* Resets the sprite system.
*)
procedure NeoUpdateSprite(s0:byte;x,y:word;image,flip,anchor:byte);
(*
* @description:
* Updates selected sprite.
* To not update a value set its byte values to $80 (or $8080 for a coordinate).
*
* The coordinates cannot be set independently. Sprite 0 is the turtle sprite.
*
* @param: s0 (byte) - sprite number
* @param: x (word) - x position
* @param: y (word) - y position
* @param: image (byte) - image (bits 0-5: sprite number, bit 6 indicated big sprite 32),
* @param: flip (byte) - flip flag (0=none, 1=horizontal, 2=vertical, 3=both)
* @param: anchor (byte) - sets anchor point
*
* Anchor points:
*
*
*  7 | 8 | 9
*
* ---+---+---
*
*  4 |0/5| 6
*
* ---+---+---
*
*  1 | 2 | 3
*
*)
procedure NeoHideSprite(s0:byte);
(*
* @description:
* Hide the sprite.
*
* @param: s0 (byte) - sprite number
*)
function NeoInRange(s0,s1,range:byte):byte;
(*
* @description:
* Returns not zero value if the distance between the centres of the sprites is less or equal range value.
*
* @param: s0 (byte) - first sprite number
* @param: s1 (byte) - second sprite number
* @param: range (byte) - collision distance range
*
* @returns: (byte) - not zero if collided
*)
procedure NeoGetSpriteXY(s0:byte; var x:word;var y:word);
(*
* @description:
* Returns coordinates of the selected sprite. Coordinates are returned in referenced variabled.
*
* @param: s0 (byte) - sprite number
* @param: x (word) - variable that gets x coordinate
* @param: y (word) - variable that gets y coordinate
*
* @returns: (byte) - not zero if collided
*)
function NeoGetJoy:byte;overload;
(*
* @description:
* Returns base controller status.
*
* Bits are (from zero) Left, Right, Up, Down, A, B. Active state is 1.
*
* @returns: (byte) - controller state
*)
function NeoGetJoyCount:byte;
(*
* @description:
* returns the number of game controllers plugged in to the USB
* This does not include the keyboard based controller, only physical controller hardware.
*
* @returns: (byte) - controllers number
*)
function NeoGetJoy(player:byte):byte;overload;
(*
* @description:
* Returns specific controller status. Controller 0 is the keyboard
* controller, Controllers 1 upwards are those physical USB devices.
* This returns a 32 bit value in Params[0..3] which currently is compatible
* with function 1, but allows for expansion.
*
* Bits are (from zero) Left, Right, Up, Down, A, B. Active state is 1.
*
* @param: player (byte) - player number (must be 1 for now)
*
* @returns: (byte) - controller state
*)

procedure NeoMute;overload;
(*
* @description:
* Resets the sound system.
*)
procedure NeoMute(channel:byte);overload;
(*
* @description:
* Resets selected sound channel.
*
* @param: channel (byte) - channel number
*)
procedure NeoBeep;
(*
* @description:
* Plays the startup beep.
*)
procedure NeoQueueNote(channel:byte;freq,len,slide:word;stype:byte);
(*
* @description:
* Queues a sound to be played.
*
* @param: channel (byte) - channel number
* @param: freq (word) - tone frequency
* @param: len (word) - not length (in cs)
* @param: slide (word) - slide change per cs
* @param: stype (byte) - sound type (beeper=0 - nothing else currently supported)
*)
procedure NeoQueueNoteX(channel:byte;freq,len,slide:word;wave:byte;vol:byte);
(*
* @description:
* Queues a sound to be played.
*
* @param: channel (byte) - channel number
* @param: freq (word) - tone frequency
* @param: len (word) - not length (in cs)
* @param: slide (word) - slide change per cs
* @param: wave (byte) - sound wave type (0 - square, 1 - white noise)
* @param: vol (byte) - sound volume
*)
function NeoGetChannels:byte;
(*
* @description:
* Returns the number of available sound channels
*
* @returns: (byte) - number of channels
*)
procedure NeoSoundFx(channel,num:byte);
(*
* @description:
* Play sound effect immediately clearing queue.
*
* @param: channel (byte) - channel number
* @param: num (byte) - effect number
*)
function NeoGetQueueLen(channel:byte):byte;
(*
* @description:
* Return the number of notes outstanding on channel before silence, including any current playing note.
*
* @param: channel (byte) - channel number
*
* @returns: (byte) - number of notes
*)
procedure TurtleInit(s0:byte);
(*
* @description:
* Initialise the turtle graphics sytem using selected sprite, don’t show it.
*
* @param: s0 (byte) - sprite number
*)
procedure TurtleRight(deg:word);
(*
* @description:
* Turn the turtle right by selected number of degrees. Show if hidden.
*
* @param: sprite (word) - angle in degrees
*)
procedure TurtleMove(dist:word;col:byte;drawing:byte);
(*
* @description:
* Move the turtle forward by selected number of steps.
*
* @param: dist (word) - distance in steps
* @param: col (byte) - ink colour
* @param: drawing (byte) - pen position flag (0=up, 1=down)
*)
procedure TurtleHide;
(*
* @description:
* Hides the turtle.
*)
procedure TurtleHome;
(*
* @description:
* Move the turtle to the home position (pointing up in the centre).
*)
procedure NeoSetCursorXY(x,y:word);
(*
* @description:
* Positions the display cursor at x,y.
*
* @param: x (word) - x coordinate
* @param: y (word) - y coordinate
*)
procedure NeoShowCursor(show:byte);
(*
* @description:
* Shows or hides the mouse cursor.
*
* @param: show (byte) - 0 hide / 1 show
*)
procedure NeoReadMouse;
(*
* @description:
* Returns the mouse position (screen pixel, unsigned) in neoMouseX, neoMouseY
* buttonstate in neoMouseButton (button 1 is 0x1, 2 0x2 etc., set when pressed),
* scrollwheelstate in neoMouseWheel as uint8 which changes according to scrolls.
*
*)
function NeoIsMousePresent:boolean;
(*
* @description:
* returns true if mouse is plugged and detected.
*
* @returns: (boolean) - true if mouse available
*)

procedure NeoSelectCursor(shape:byte);
(*
* @description:
* Select a mouse cursor from predefined shapes.
*
* @param: shape (byte) - shape number
*)

function NeoBlitterBusy:boolean;
(*
* @description:
* used to check availability and transfer completion.
*
* @returns: (boolean) - true if the blitter/DMA system is currently transferring data,
*)

procedure NeoBlitterCopy(src:cardinal;dst:cardinal;len:word);
(*
* @description:
* Copy the block of memory. Allows transfer of data in between 6502 RAM, Video RAM and Graphics RAM.
*
* The upper 8 bits of the address are : 6502 RAM ($00xxxx) VideoRAM ($8xxxxx) Graphics RAM($90xxxx).
*
* Sets error flag if the transfer is not possible (e.g. illegal write addresses).
*
* @param: src (cardinal) - source data address
* @param: dst (cardinal) - target data address
* @param: len (word) - data length in bytes
*
*)
procedure NeoBlitterXCopy(action:byte;src,dest:pointer);
(*
* @description:
* Copy a source rectangular area to a destination rectangular area.
* It's oriented toward copying graphics data, but can be used as a more general-purpose memory mover.
* The source and target areas may be different formats, and the copy will convert the data on the fly.
*
* The upper 8 bits of the address are : 6502 RAM ($00xxxx) VideoRAM ($8xxxxx) Graphics RAM($90xxxx).
*
* @param: action (byte) - blit action
* @param: src (pointer) - pointer to source rectangle data block (TBlitBlock)
* @param: dst (pointer) - pointer to target rectangle data block (TBlitBlock)
*
*
* For more info check neo6502 API Reference: https://www.neo6502.com/reference/api-listing/#group-12-blitter
*)
procedure NeoBlitImage(action:byte;src:pointer;x,y:word;format:byte);
(*
* @description:
* Blits an image from memory onto the screen. The image will be clipped, so it's safe to blit partly (or fully) offscreen-images.
*
* @param: action (byte) - blit action
* @param: src (pointer) - pointer to source rectangle data block (TBlitBlock)
* @param: x (word) - x pixel coordinate on screen
* @param: y (word) - y pixel coordinate on screen
* @param: format (byte) - destination format, determines how framebuffer will be written
*
* For more info check neo6502 API Reference: https://www.neo6502.com/reference/api-listing/#group-12-blitter
*)

procedure NeoInitEditor;
(*
* @description:
* Initialises the editor
*
*)

procedure NeoReenterEditor;
(*
* @description:
* Re-enters the system editor. Returns the function required for call out,
* the editors sort of ’call backs’ - see editor specification
*
*)


implementation

procedure NeoWaitMessage;inline;assembler;
asm
   @WaitMessage
end;

function NeoSendMessage(group,func:byte):byte;
begin
    NeoWaitMessage;
    NeoMessage.func:=func;
    NeoMessage.group:=group;
    result := NeoMessage.params[0];
end;

//////////////////////////////////
////////////////////////////////////////     1 - SYSTEM
//////////////////////////////////

procedure NeoSubReset;
begin
    NeoSendMessage(1,0);
end;

function NeoGetTimer:cardinal;
begin
    NeoSendMessage(1,1);
    result := dwordParams[0];
end;

function NeoIsKeyPressed(key:byte):byte;
begin
    NeoMessage.params[0]:=key;
    result := NeoSendMessage(1,2);
end;

procedure NeoExecuteBasic;
begin
    NeoSendMessage(1,3);
end;

procedure NeoCredits;
begin
    NeoSendMessage(1,4);
end;

function NeoCheckSerial:byte;
begin
    result := NeoSendMessage(1,5);
end;

procedure NeoSetLocale(lang:string[2]);
begin
    NeoMessage.params[0]:=byte(lang[1]);
    NeoMessage.params[1]:=byte(lang[2]);
    NeoSendMessage(1,6);
end;

procedure NeoReset;
begin
    NeoSendMessage(1,7);
end;

procedure NeoMOS(cmd:pointer);
begin
    wordParams[0] := word(cmd);
    NeoSendMessage(1,8);
end;

procedure NeoWriteDebug(c:byte);
begin
    NeoMessage.params[0]:=c;
    NeoSendMessage(1,10);
end;

//////////////////////////////////
////////////////////////////////////////     2 - CONSOLE
//////////////////////////////////

procedure NeoSetChar(c:byte;data:pointer);
begin
    NeoMessage.params[0]:=c;
    move(data,@NeoMessage.params[1],7);
    NeoSendMessage(2,5);
end;

procedure NeoDefineHotkey(keynum:byte;txt:pointer);
begin
    NeoMessage.params[0] := keynum;
    wordParams[0] := word(txt);
    NeoSendMessage(2,4);
end;

procedure NeoShowHotkeys;
begin
    NeoSendMessage(2,8);
end;

procedure NeoGetScreenSize(var height:byte;var width:byte);
begin
    NeoSendMessage(2,9);
    NeoWaitMessage;
    height := NeoMessage.params[0];
    width := NeoMessage.params[1];
end;


procedure NeoGetCursorPos(var x:byte;var y:byte);
begin
    NeoSendMessage(2,13);
    NeoWaitMessage;
    x := NeoMessage.params[0];
    y := NeoMessage.params[1];
end;

procedure NeoClearRegion(x0,y0,x1,y1:byte);
begin
    NeoMessage.params[0] := x0;
    NeoMessage.params[1] := y0;
    NeoMessage.params[2] := x1;
    NeoMessage.params[3] := y1;
    NeoSendMessage(2,14);
end;


procedure NeoSetTextColor(foreground,background:byte);
begin
    NeoMessage.params[0] := foreground;
    NeoMessage.params[1] := background;
    NeoSendMessage(2,15);
end;

procedure NeoCursorInverse;
begin
    NeoSendMessage(2,16);
end;

//////////////////////////////////
////////////////////////////////////////     3 - FILE I/O
//////////////////////////////////

function FileIO(fn:byte):boolean;
begin
    NeoSendMessage(3,fn);
    result := NeoMessage.error = 0;
end;

procedure NeoShowDir;
begin
    NeoSendMessage(3,FI_PrintDir);
end;

function NeoLoad(name:TString;dest:word):boolean;
begin
    FI_filename := word(@name);
    wordParams[1] := dest;
    result := FileIO(FI_LoadFile);
end;

function NeoSave(name:TString;dest,len:word):boolean;
begin
    FI_filename := word(@name);
    wordParams[1] := dest;
    wordParams[2] := len;
    result := FileIO(FI_SaveFile);
end;

function NeoOpenFile(channel:byte;name:pointer;openmode:byte):boolean;
begin
    FI_channel := channel;
    FI_openfilename := word(name);
    NeoMessage.params[3] := openmode;
    result := FileIO(FI_OpenFile);
end;

function NeoCloseFile(channel:byte):boolean;
begin
    FI_channel := channel;
    result := FileIO(FI_CloseFile);
end;

function NeoSeekPos(channel:byte;pos:cardinal):boolean;
begin
    FI_channel := channel;
    FI_offset := pos;
    result := FileIO(FI_SeekPos);
end;

function NeoTellPos(channel:byte):cardinal;
begin
    result:=0;
    FI_channel := channel;
    if FileIO(FI_TellPos) then result := FI_offset;
end;

function NeoReadFile(channel:byte;addr:word;len:word):word;
begin
    result:=0;
    FI_channel := channel;
    FI_address := addr;
    FI_length := len;
    if FileIO(FI_ReadData) then result := FI_length;
end;

function NeoWriteFile(channel:byte;addr:word;len:word):word;
begin
    result:=0;
    FI_channel := channel;
    FI_address := addr;
    FI_length := len;
    if FileIO(FI_WriteData) then result := FI_length;
end;

function NeoGetFileSize(channel:byte):cardinal;
begin
    result:=0;
    FI_channel := channel;
    if FileIO(FI_GetSize) then result := FI_offset;
end;

function NeoSetFileSize(channel:byte;size:cardinal):boolean;
begin
    FI_channel := channel;
    FI_offset := size;
    result := FileIO(FI_GetSize);
end;

function NeoRenameFile(fin,fout:pointer):boolean;
begin
    FI_filename := word(fin);
    FI_filename2 := word(fout);
    result := FileIO(FI_Rename);
end;

function NeoDeleteFile(fin:pointer):boolean;
begin
    FI_filename := word(fin);
    result := FileIO(FI_Delete);
end;

function NeoCreateDirectory(fin:pointer):boolean;
begin
    FI_filename := word(fin);
    result := FileIO(FI_NewDir);
end;

function NeoChangeDirectory(fin:pointer):boolean;
begin
    FI_filename := word(fin);
    result := FileIO(FI_ChangeDir);
end;

function NeoStatFile(fin:pointer;var size:cardinal;var attr:byte):boolean;
begin
    FI_filename := word(fin);
    result := FileIO(FI_StatFile);
    if result then begin
        size:=FI_statSize;
        attr:=FI_statAttr;
    end;
end;

function NeoOpenDirectory(fin:pointer):boolean;
begin
    FI_filename := word(fin);
    result := FileIO(FI_OpenDir);
end;

function NeoReadDirectory(var fname:string;var size:cardinal;var attr:byte):boolean;
begin
    FI_filename := word(@fname);
    result := FileIO(FI_ReadDir);
    if result then begin
        size:=FI_dirSize;
        attr:=FI_dirAttr;
    end;
end;

function NeoCloseDirectory:boolean;
begin
    result := FileIO(FI_CloseDir);
end;

function NeoCopyFile(fin,fout:pointer):boolean;
begin
    FI_filename := word(fin);
    FI_filename2 := word(fout);
    result := FileIO(FI_CopyFile);
end;

function NeoSetAttr(fin:pointer;var attr:byte):boolean;
begin
    FI_filename := word(fin);
    NeoMessage.params[2]:=attr;
    result := FileIO(FI_SetAttr);
end;


procedure NeoSearchDir(var searchstring:string);
begin
    wordParams[0] := word(@searchstring);
    NeoSendMessage(3,FI_PrintDirWildcard);
end;

//////////////////////////////////
////////////////////////////////////////     4 - MATH
//////////////////////////////////

function NeoDoMath(func:byte):byte;
begin
    result := NeoSendMessage(4,func);
end;

//////////////////////////////////
////////////////////////////////////////     5 - GRAPHICS
//////////////////////////////////

procedure NeoSetDefaults(acol,xcol,solid,size,flip:byte);
begin
    NeoMessage.params[0]:=acol;
    NeoMessage.params[1]:=xcol;
    NeoMessage.params[2]:=solid;
    NeoMessage.params[3]:=size;
    NeoMessage.params[4]:=flip;
    NeoSendMessage(5,1);
end;

procedure NeoDrawLine(x0,y0,x1,y1:word);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    wordParams[2]:=x1;
    wordParams[3]:=y1;
    NeoSendMessage(5,2);
end;

procedure NeoDrawRect(x0,y0,x1,y1:word);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    wordParams[2]:=x1;
    wordParams[3]:=y1;
    NeoSendMessage(5,3);
end;

procedure NeoDrawEllipse(x0,y0,x1,y1:word);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    wordParams[2]:=x1;
    wordParams[3]:=y1;
    NeoSendMessage(5,4);
end;

procedure NeoDrawPixel(x0,y0:word);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    NeoSendMessage(5,5);
end;

procedure NeoDrawString(x0,y0:word;var s:string);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    wordParams[2]:=word(@s);
    NeoSendMessage(5,6);
end;

procedure NeoDrawImage(x0,y0:word;id:byte);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    NeoMessage.params[4]:=id;
    NeoSendMessage(5,7);
end;

procedure NeoDrawTileMap(x0,y0,x1,y1:word);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    wordParams[2]:=x1;
    wordParams[3]:=y1;
    NeoSendMessage(5,8);
end;

procedure NeoSetPalette(col,r,g,b:byte);
begin
    NeoMessage.params[0]:=col;
    NeoMessage.params[1]:=r;
    NeoMessage.params[2]:=g;
    NeoMessage.params[3]:=b;
    NeoSendMessage(5,32);
end;

function NeoGetPixel(x,y:word):byte;
begin
    wordParams[0]:=x;
    wordParams[1]:=y;
    result := NeoSendMessage(5,33);
end;

procedure NeoResetPalette;
begin
    NeoSendMessage(5,34);
end;

procedure NeoSelectTileMap(mem,xoffset,yoffset:word);
begin
    wordParams[0]:=mem;
    wordParams[1]:=xoffset;
    wordParams[2]:=yoffset;
    NeoSendMessage(5,35);
end;

function NeoGetSpritePixel(x,y:word):byte;
begin
    wordParams[0]:=x;
    wordParams[1]:=y;
    result := NeoSendMessage(5,36);
end;


function NeoGetVblanks:cardinal;
begin
    NeoSendMessage(5,37);
    result := dwordParams[0];
end;

procedure NeoWaitForVblank;
    var vbcount0:byte;
begin
    NeoSendMessage(5,37);
    vbcount0 := NeoMessage.params[0];
    repeat NeoSendMessage(5,37) until vbcount0 <> NeoMessage.params[0];
end;

procedure NeoGetPalette(col:byte;var r:byte;var g:byte;var b:byte);
begin
    NeoMessage.params[0]:=col;
    NeoSendMessage(5,38);
    r:=NeoMessage.params[1];
    g:=NeoMessage.params[2];
    b:=NeoMessage.params[3];
end;

procedure NeoWritePixel(x0,y0:word;c:byte);
begin
    wordParams[0]:=x0;
    wordParams[1]:=y0;
    NeoMessage.params[4]:=c;
    NeoSendMessage(5,39);
end;

procedure NeoSetColor(col:byte);
begin
    NeoMessage.params[0]:=col;
    NeoSendMessage(5,64);
end;

procedure NeoSetSolidFlag(flag:byte);
begin
    NeoMessage.params[0]:=flag;
    NeoSendMessage(5,65);
end;

procedure NeoSetDrawSize(size:byte);
begin
    NeoMessage.params[0]:=size;
    NeoSendMessage(5,66);
end;

procedure NeoSetFlip(flip:byte);
begin
    NeoMessage.params[0]:=flip;
    NeoSendMessage(5,67);
end;

//////////////////////////////////
////////////////////////////////////////     6 - SPRITES
//////////////////////////////////

procedure NeoResetSprites;
begin
    NeoSendMessage(6,1);
end;

procedure NeoUpdateSprite(s0:byte;x,y:word;image,flip,anchor:byte);
begin
    NeoMessage.params[0]:=s0;
    wordxParams[0]:=x;
    wordxParams[1]:=y;
    NeoMessage.params[5]:=image;
    NeoMessage.params[6]:=flip;
    NeoMessage.params[7]:=anchor;
    NeoSendMessage(6,2);
end;

procedure NeoHideSprite(s0:byte);
begin
    NeoMessage.params[0]:=s0;
    NeoSendMessage(6,3);
end;

function NeoInRange(s0,s1,range:byte):byte; // not zero if dist <= range (dist mesaured from sprite centres);
begin
    NeoMessage.params[0]:=s0;
    NeoMessage.params[1]:=s1;
    NeoMessage.params[2]:=range;
    result := NeoSendMessage(6,4);
end;

procedure NeoGetSpriteXY(s0:byte; var x:word;var y:word);
begin
    NeoMessage.params[0]:=s0;
    NeoSendMessage(6,5);
    x:=wordxParams[0];
    y:=wordxParams[1];
end;

//////////////////////////////////
////////////////////////////////////////     7 - CONTROLLERS
//////////////////////////////////

function NeoGetJoy:byte;overload;
begin
    result := NeoSendMessage(7,1);
end;

function NeoGetJoyCount:byte;
begin
    result := NeoSendMessage(7,2);
end;

function NeoGetJoy(player:byte):byte;overload;
begin
    NeoMessage.params[0] := player;
    result := NeoSendMessage(7,3);
end;

//////////////////////////////////
////////////////////////////////////////     8 - SOUND
//////////////////////////////////

procedure NeoMute;overload;
begin
    NeoSendMessage(8,1);
end;

procedure NeoMute(channel:byte);overload;
begin
    NeoMessage.params[0] := channel;
    NeoSendMessage(8,2);
end;

procedure NeoBeep;
begin
    NeoSendMessage(8,3);
end;

procedure NeoQueueNote(channel:byte;freq,len,slide:word;stype:byte);
begin
    soundParams.channel := channel;
    soundParams.freq := freq;
    soundParams.len := len;
    soundParams.slide := slide;
    soundParams.stype := stype;
    NeoSendMessage(8,4);
end;

procedure NeoSoundFx(channel,num:byte);
begin
    NeoMessage.params[0] := channel;
    NeoMessage.params[1] := num;
    NeoSendMessage(8,5);
end;

function NeoGetQueueLen(channel:byte):byte;
begin
    NeoMessage.params[0] := channel;
    result := NeoSendMessage(8,6);
end;

procedure NeoQueueNoteX(channel:byte;freq,len,slide:word;wave:byte;vol:byte);
begin
    soundParams.channel := channel;
    soundParams.freq := freq;
    soundParams.len := len;
    soundParams.slide := slide;
    soundParams.stype := wave;
    soundParams.vol := vol;
    NeoSendMessage(8,7);
end;

function NeoGetChannels:byte;
begin
    result := NeoSendMessage(8,8);
end;


//////////////////////////////////
////////////////////////////////////////     9 - TURTLE
//////////////////////////////////

procedure TurtleInit(s0:byte);
begin
    NeoMessage.params[0]:=s0;
    NeoSendMessage(9,1);
end;

procedure TurtleRight(deg:word);
begin
    wordParams[0]:=deg;
    NeoSendMessage(9,2);
end;

procedure TurtleMove(dist:word;col:byte;drawing:byte);
begin
    wordParams[0]:=dist;
    NeoMessage.params[2]:=col;
    NeoMessage.params[3]:=drawing;
    NeoSendMessage(9,3);
end;

procedure TurtleHide;
begin
    NeoSendMessage(9,4);
end;

procedure TurtleHome;
begin
    NeoSendMessage(9,5);
end;

//////////////////////////////////
////////////////////////////////////////     11 - MOUSE
//////////////////////////////////

procedure NeoSetCursorXY(x,y:word);
begin
    wordParams[0]:=x;
    wordParams[1]:=y;
    NeoSendMessage(11,1);
end;

procedure NeoShowCursor(show:byte);
begin
    NeoMessage.params[0]:=show;
    NeoSendMessage(11,2);
end;

procedure NeoReadMouse;
begin
    NeoSendMessage(11,3);
end;

function NeoIsMousePresent:boolean;
begin
    result := NeoSendMessage(11,4) <> 0;
end;

procedure NeoSelectCursor(shape:byte);
begin
    NeoMessage.params[0]:=shape;
    NeoSendMessage(11,5);
end;

//////////////////////////////////
////////////////////////////////////////     12 - BLITTER
//////////////////////////////////

function NeoBlitterBusy:boolean;
begin
    result := NeoSendMessage(12,1) <> 0;
end;

procedure NeoBlitterCopy(src:cardinal;dst:cardinal;len:word);
begin
    NeoMessage.params[0]:= src shr 16;
    wordxParams[0] := src and $ffff;
    NeoMessage.params[3] := dst shr 16;
    wordParams[2] := dst and $ffff;
    wordParams[3] := len;
    NeoSendMessage(12,2);
end;

procedure NeoBlitterXCopy(action:byte;src,dest:pointer);
begin
    wordxParams[0] := word(src);
    wordxParams[1] := word(dest);
    NeoMessage.params[0] := action;
    NeoSendMessage(12,3);
end;

procedure NeoBlitImage(action:byte;src:pointer;x,y:word;format:byte);
begin
    NeoMessage.params[0] := action;
    wordxParams[0] := word(src);
    wordxParams[1] := x;
    wordxParams[2] := y;
    NeoMessage.params[7] := format;
    NeoSendMessage(12,4);
end;

//////////////////////////////////
////////////////////////////////////////     12 - Editor Functions
//////////////////////////////////

procedure NeoInitEditor;
begin
    NeoSendMessage(13,1);
end;

procedure NeoReenterEditor;
begin
    NeoSendMessage(13,2);
end;

end.
