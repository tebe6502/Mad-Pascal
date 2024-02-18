unit neo6502;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Neo6502 API library for Mad-Pascal.
* @version: 0.1.0

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
*   <https://github.com/paulscottrobson/neo6502-firmware/wiki>
*
*   
* It's work in progress, so please report any bugs you will find.   
*   
*)

interface
const 
    N6502MSG_ADDRESS = $ff00;
    NEO_GFX_RAM = $ffff;

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
end;

type TTileMapHeader = record
    format:byte;
    width:byte;
    height:byte;
end;

var 
    NeoMessage:TN6502Message absolute N6502MSG_ADDRESS;  // structure used to communicate with neo6502 API 
    wordParams: array[0..3] of word absolute N6502MSG_ADDRESS+4; // helping structure to easliy obrain or set word parametrs
    dwordParams: array[0..1] of cardinal absolute N6502MSG_ADDRESS+4; // helping structure to easliy obrain or set cardinal parametrs
    wordxParams: array[0..2] of word absolute N6502MSG_ADDRESS+5; // @nodoc
    soundParams: TSound absolute N6502MSG_ADDRESS+4; // @nodoc  

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
procedure NeoWaitMessage;assembler;
(*
* @description:
* Waits until Message from API is returned. 
*)
procedure NeoReset;
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
function NeoIsKeyPressed(key:byte):byte;
(*
* @description:
* Return the state of keyboard key
* 
* @param: key (byte) - key to be checked
* 
* @returns: (byte) - state of key
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
procedure NeoSetChar(c:byte;data:pointer);
(*
* @description:
* Use bits 0..5 of data bytes to define a selected font character
* 
* @param: c (byte) - code of char to be defined (192-255)
* @param: data (pointer) - pointer to 7 bytes of data
*)
procedure NeoGetFunctionKeys;
(*
* @description:
* Displays the current settings of the function keys
*)
/////////////// GROUP 3 - filesystem
procedure NeoShowDir;
(*
* @description:
* Displays the storage directory.
*)
function NeoLoad(name:TString;dest:word):byte;
(*
* @description:
* Loads a named file from storage to selected address. 
*
* If the address is $FFFF the file is loaded into the graphic memory area used for sprites, tiles, images.
* 
* @param: name (TString) - name of the file with extension
* @param: dest (word) - target data address
*
* @returns: (byte) - error code is returned (if aplicable)
*)
function NeoSave(name:TString;dest,len:word):byte;
(*
* @description:
* Saves chunk of memory from defined address to a named file on storage. 
* * 
* @param: name (TString) - name of the file with extension
* @param: dest (word) - source data address
* @param: len (word) - numer of bytes to be saved
*
* @returns: (byte) - error code is returned (if aplicable)
*)
function NeoMath(func:byte):byte;
(*
* @description:
* Performs API request to math coprocessing library. Not well documented yet.
* 
* @param: func (byte) - number of function to be called
*)
procedure NeoSetColor(acol,xcol,solid,size,flip:byte);
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
* @param: id (byte) - image id (0-127 tiles, 128-191 sprites 16, 192-255, sprites 32);
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
procedure GetSpriteXY(s0:byte;var x:word;var y:word);
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
function NeoGetJoy(player:byte):byte;
(*
* @description:
* Returns controller status.
* Bits are (from zero) Left, Right, Up, Down, A, B. Active state is 1.
* 
* @param: player (byte) - player number (must be 1 for now)
*
* @returns: (byte) - controller state
*)
procedure NeoMute;
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

implementation

procedure NeoWaitMessage;assembler;
asm
   @WaitMessage 
end;

function NeoSendMessage(group,func:byte):byte;
begin
    NeoWaitMessage;
    NeoMessage.func:=func;
    NeoMessage.group:=group;
    repeat until NeoMessage.group=0;
    result:=NeoMessage.params[0];
end;

procedure NeoReset;
begin
    NeoSendMessage(1,0);
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

procedure NeoSetChar(c:byte;data:pointer);
begin
    NeoMessage.params[0]:=c;
    move(data,@NeoMessage.params[1],7);
    NeoSendMessage(2,5);
end;

procedure NeoGetFunctionKeys;
begin
    NeoSendMessage(2,8);
end;

procedure NeoShowDir;
begin
    NeoSendMessage(3,1);
end;

function NeoLoad(name:TString;dest:word):byte;
begin
    wordParams[0] := word(@name);
    wordParams[1] := dest;
    NeoSendMessage(3,2);
    NeoWaitMessage;
    result := NeoMessage.params[0];
end;

function NeoSave(name:TString;dest,len:word):byte;
begin
    wordParams[0]:=word(@name);
    wordParams[1]:=dest;
    wordParams[2]:=len;
    result := NeoSendMessage(3,3);
end;

function NeoMath(func:byte):byte;
begin
    result := NeoSendMessage(4,func);
end;

function NeoGetJoy(player:byte):byte;
begin
    result := NeoSendMessage(7,player);
end;

procedure NeoMute;
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

//////////////// 

procedure NeoSetColor(acol,xcol,solid,size,flip:byte);
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

procedure GetSpriteXY(s0:byte; var x:word;var y:word);
begin
    NeoMessage.params[0]:=s0;    
    NeoSendMessage(6,4);
    x:=wordxParams[0];
    y:=wordxParams[1];
end;

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

end.
