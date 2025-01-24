unit xbios;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: xBios handlers
* @version: 0.1.1
* @description:
* Handful of useful procedures to fiddle with Atari IO (disk) using xBios. 
* For more informations about xBios - look here: <https://xxl.atari.pl/>.
* 
* Known limitations of xBios:
* 
* - New files cannot be created.
* 
* - Existing files cannot be extended in length.
* 
* - New directories cannot be created programatically.
* 
* 
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)

interface
type TxBiosConfig = record
(*
* @description: 
* Structured type used to store and represent xBios configuration file. 
*)
    version: byte; // upper nibble is major version number, lower is lower ;)
    autorun: array [0..10] of char; // name of autorun file (default 'XAUTORUN')
    xBiosAddress: byte; // MSB of xBios memory address (default $800)
    bufferAddress: byte; // MSB of buffer memory address (default $700)
    initAd: word; // INITAD vector address (default $02e2)
    runAd: word; // RUNAD vector address (default $02e0)
    aosv: word; // I/O module adress (at run AtariOS; default xSIOV)
    aosv_reloc: word; // relocate AtariOS I/O module variables
    portb: byte; // PORTB value at start (default $ff)
    nmien: byte; // NMIEN value at start (default $40)
    irqen: byte; // IRQEN value at start (default $c0)
end;

var xBiosIOresult: byte = 0; (* @var contains result of last IO operation ( 0 = OK, 1 = KO ) *)
    xBiosIOerror: byte = 0;  (* @var contains register X value after last error (for debuging purposes) *)
    xBiosDirEntryIndex: byte = 0; (* @var contains index of last directory entry, after using xBiosFindEntry or xBiosGetEntry *)
    xBiosDirEntryStatus: byte = 0; (* @var contains status of last directory entry, after using xBiosGetEntry *)
    xBiosDirEntrySector: word = 0; (* @var contains starting sector of found directory entry, after using xBiosFindEntry *)

const 
xBIOS_ADDRESS = $800; // Change this value if you are using xbios at non-default location
xBIOS_VERSION              = xBIOS_ADDRESS + $02; // location of version number in memory
xBIOS_RENAME_ENTRY         = xBIOS_ADDRESS + $03; // original xBios procedures vectors
xBIOS_LOAD_FILE            = xBIOS_ADDRESS + $06;
xBIOS_OPEN_FILE            = xBIOS_ADDRESS + $09;
xBIOS_LOAD_DATA            = xBIOS_ADDRESS + $0c;
xBIOS_WRITE_DATA           = xBIOS_ADDRESS + $0f;
xBIOS_OPEN_CURRENT_DIR     = xBIOS_ADDRESS + $12;
xBIOS_GET_BYTE             = xBIOS_ADDRESS + $15;
xBIOS_PUT_BYTE             = xBIOS_ADDRESS + $18;
xBIOS_FLUSH_BUFFER         = xBIOS_ADDRESS + $1b;
xBIOS_SET_LENGTH           = xBIOS_ADDRESS + $1e;
xBIOS_SET_INIAD            = xBIOS_ADDRESS + $21;
xBIOS_SET_FILE_OFFSET      = xBIOS_ADDRESS + $24;
xBIOS_SET_RUNAD            = xBIOS_ADDRESS + $27;
xBIOS_SET_DEFAULT_DEVICE   = xBIOS_ADDRESS + $2a;
xBIOS_OPEN_DIR             = xBIOS_ADDRESS + $2d;
xBIOS_LOAD_BINARY_FILE     = xBIOS_ADDRESS + $30;
xBIOS_OPEN_DEFAULT_DIR     = xBIOS_ADDRESS + $33;
xBIOS_SET_DEVICE           = xBIOS_ADDRESS + $36;
xBIOS_RELOCATE_BUFFER      = xBIOS_ADDRESS + $39;
xBIOS_GET_ENTRY            = xBIOS_ADDRESS + $3c;
xBIOS_OPEN_DEFAULT_FILE    = xBIOS_ADDRESS + $3f;
xBIOS_READ_SECTOR          = xBIOS_ADDRESS + $42;
xBIOS_FIND_ENTRY           = xBIOS_ADDRESS + $45;
xBIOS_SET_BUFFER_SIZE      = xBIOS_ADDRESS + $48;

var
xDIRSIZE        : byte absolute xBIOS_ADDRESS + $3e5; // current directory size in sectors (1 byte)
xSPEED          : byte absolute xBIOS_ADDRESS + $3e6; // STD SPEED
xHSPEED         : byte absolute xBIOS_ADDRESS + $3e7; // ULTRA SPEED
xIRQEN          : byte absolute xBIOS_ADDRESS + $3e8; // User IRQ (1 byte)
xAUDCTL         : byte absolute xBIOS_ADDRESS + $3e9; // AUDCTL
xFILE           : word absolute xBIOS_ADDRESS + $3ea; // File handle (2 bytes)
xDIR            : word absolute xBIOS_ADDRESS + $3ec; // Root directory handle (2 bytes)
xIOV            : word absolute xBIOS_ADDRESS + $3ee; // I/O module entry (2 bytes)
xBUFFERH        : byte absolute xBIOS_ADDRESS + $3f0; // Buffer adr hi byte (1 byte)
xBUFSIZE        : byte absolute xBIOS_ADDRESS + $3f1; // Buffer size lo byte $100-SIZE (1 byte)
xDAUX3          : byte absolute xBIOS_ADDRESS + $3f2; // Buffer offset (1 byte)
xSEGMENT        : word absolute xBIOS_ADDRESS + $3f3; // Bytes to go in binary file segment (2 bytes)
xNOTE           : word absolute xBIOS_ADDRESS + $3f5; // File pointer (2 lower bytes)
xNOTEH          : byte absolute xBIOS_ADDRESS + $3f7; // File pointer (highest byte)
xDEVICE         : byte absolute xBIOS_ADDRESS + $3fc; // Device ID
xDCMD           : byte absolute xBIOS_ADDRESS + $3fd; // CMD (1 byte)
xDAUX1          : byte absolute xBIOS_ADDRESS + $3fe; // Sector lo byte (1 byte)
xDAUX2          : byte absolute xBIOS_ADDRESS + $3ff; // Sector hi byte (1 byte)

function xBiosCheck:byte;
(*
* @description:
* Checks for the presence of xBios in memory. Looks at address defined as xBiosAddress. 
*
* @returns: (byte) - returns 0 for no xBios loaded,  
*                    if xBios is present - returns two nibbles of xBios version 
*)
procedure xBiosRenameEntry(var filename:TString); assembler;
(*
* @description:
* This function allows you to rename a file or directory. 
* There is no limit to the characters used in the filename apart from that they must fit 
* a case insensitive “8.3” format without the dot. If your filename is not 8 characters long, 
* pad it out with spaces.
* 
* @param: filename - string containing both names, source and destination, padded with spaces. 
* Must be 22 characters long.
* 
* example: filename := 'INFILE  TXTOUTFILE TXT';
*)
procedure xBiosLoadFile(var filename:TString); assembler;
(*
* @description:
* Loads and runs the file, INIT and RUN headers are supported. 
* In the case the file does not have a defined block RUN will be launched from the beginning of the first block.
* 
* @param: filename - string containing file name (8.3 format without dot) padded with spaces. 
* Must be 11 characters long.
* 
* example: filename := 'INFILE  TXT';
*)
procedure xBiosOpenFile(var filename:TString); assembler;
(*
* @description:
* Opens a file in order to carry out subsequent IO operations.
* 
* @param: filename - string containing file name (8.3 format without dot) padded with spaces. 
* Must be 11 characters long.
* 
* example: filename := 'INFILE  TXT';
*)
procedure xBiosLoadData(dest: pointer); assembler;
(*
* @description:
* Loads data from file to a specified destination address. You can set the file offset (xBiosSetFileOffset) 
* and the amount of data to be loaded (xBiosSetLength). If you do not define these values, 
* data will be loaded from the current position of the file pointer to the end of the file.
* 
* @param: dest - data destination pointer. 
*)
procedure xBiosLoadLz4Data(dest: pointer); assembler;
(*
* @description:
* Loads and decompres data from compressed lz4 file to a specified destination address. 
* Based on xxl & fox routine from here: <https://xxl.atari.pl/lz4-decompressor/>
* 
* @param: dest - data destination pointer. 
*)
procedure xBiosWriteData(src: pointer); assembler;
(*
* @description:
* Saves data from memory to a file, starting from the current position in the file. You can set the file 
* pointer offset current (xBiosSetFileOffset) and the amount of data to be saved (xBiosSetLength). 
* If you do not define these values, data from the current file position to the end of the file is written to the file.
* 
* @param: src - pointer to source of data.  
*)
procedure xBiosOpenCurrentDir; assembler;
(*
* @description:
* Opens the current directory.  
* 
*)
function  xBiosGetByte:byte; assembler;
(*
* @description:
* Reads one byte from opened file.
* 
* @returns: (byte) - byte readed from file   
*)
procedure xBiosPutByte(b:byte); assembler;
(*
* @description:
* Writes one byte into opened file.
* 
* @param: b - byte to be written into file   
*)
procedure xBiosFlushBuffer; assembler;
(*
* @description:
* All write operations are cached, use this to flush the buffer to the current file.
*)
procedure xBiosSetLength(len: word); assembler;
(*
* @description:
* Defines the amount of data to process while reading or writing.
* 
* @param: len - amount of data
*)
procedure xBiosSetInitAd(adr: word); assembler;
(*
* @description:
* Allows you to change the init address vector INITAD ($2E2) for loaded binary files.
* 
* @param: adr - new address vector for INITAD
*)
procedure xBiosSetFileOffset(pos: cardinal); assembler;
(*
* @description:
* Sets the current read/write position in the current file with a value stored in parameter. 
* This item is calculated relative to the beginning of the file. In DOS speak, the operation is called "POINT".
* You can only move this pointer forward. 
* 
* @param: pos - new position in the current file
*)
procedure xBiosSetRunAd(adr: word); assembler;
(*
* @description:
* Allows you to change the run address vector RUNAD ($2E0) for loaded binary files.
* 
* @param: adr - new address vector for RUNAD
*)
procedure xBiosSetDefaultDevice; assembler;
(*
* @description:
* Restores the standard IO device.
*)
procedure xBiosOpenDir(var filename:TString); assembler;
(*
* @description:
* Allows you to change the current directory.
* 
* @param: filename - string containing directory name (8.3 format without dot) padded with spaces. 
* Must be 11 characters long.
* 
* example: filename := 'SUBDIR     ';
*)
procedure xBiosLoadBinaryFile; assembler;
(*
* @description:
* Loads and runs the binary file from the current read/write position. INIT and RUN headers are supported.
*)
procedure xBiosOpenDefaultDir; assembler;
(*
* @description:
* Opens the default directory.
*)
procedure xBiosSetDevice(dev: word); assembler;
(*
* @description:
* Changes the IO device.
* 
* @param: dev - device address
*)
procedure xBiosRelocateBuffer(adr: word;c:byte); assembler;
(*
* @description:
* Changes address of IO buffer. If c = 1, the relocation can be carried out 
* even during IO. The data will not be lost. If c = 0, buffer contents will not be copied to a new location.
* 
* @param: adr - new buffer address
* @param: c - dynamic relocation flag
*)
procedure xBiosGetEntry; assembler;
(*
* @description:
* Gets another entry in the directory. The xBiosDirEntryIndex returns the index to the filename or folder 
* (byte of buffer address is stored in the variable xBUFFERH). The xBiosDirEntryStatus is set with the status. 
* The xBiosIOresult is set to 1 when the end of the directory is found.
*)
procedure xBiosOpenDefaultFile; assembler;
(*
* @description:
* Opens the default file. The function does not search the directory, the file handle is derived from the variable 'xFILE'.
*)
procedure xBiosReadSector(sector: word); assembler;
(*
* @description:
* Loads an sector into a buffer.
* 
* @param: sector - sector number 
*)
procedure xBiosFindEntry(var filename:TString); assembler;
(*
* @description:
* This function allows you to find the specified directory entry. The xBiosDirEntryIndex returns the index to the filename or folder 
* (byte of buffer address is stored in the variable xBUFFERH). The xBiosDirEntrySector returns starting sector number of found entry. 
* If an entry is not found, the xBiosIOresult is set to 1.
* 
* @param: filename - string containing file name (8.3 format without dot) padded with spaces. 
* Must be 11 characters long.
* 
* example: filename := 'INFILE  TXT';
*)
procedure xBiosSetBufferSize(size: byte); assembler;
(*
* @description:
* This feature allows you to set the buffer size for IO operations. 
* Buffer Size is also stored in the variable xBUFSIZE in bytes format. 
*)
function DosGetEntryName:TString;
(*
* @description:
* Reads and returns last directory entry name. Can be invoked only after xBiosGetEntry or xBiosFindEntry.
* 
* @returns: (string) - returns last directory entry name  
*)
procedure DosReadEntryName(ptr: pointer);overload;
(*
* @description:
* Reads and stores last directory entry name at provided memory address. Can be invoked only after xBiosGetEntry or xBiosFindEntry.
* 
* @param: ptr - pointer to memory location where entry name should be stored. 
*)
procedure DosReadEntryName(var s: TString);overload;
(*
* @description:
* Reads and stores last directory entry name in string provided. Can be invoked only after xBiosGetEntry or xBiosFindEntry.
* 
* @param: s - string where entry name should be stored. 
*)
function DosHasEntryExt(ext: TString):boolean;
(*
* @description:
* Checks if last entry extension matches extension provided as an parameter.
* 
* @param: ext - string containing file extension (3 characters long). 
* 
* @returns: (boolean) - returns true if extension matches param.  
*)
function DosGetEntrySize:word;
(*
* @description:
* Reads and returns last directory entry size (in sectors). Can be invoked only after xBiosGetEntry or xBiosFindEntry.
* 
* @returns: (word) - returns number of sectors occupied by last directory entry,  
*)
function DosGetEntrySector:word;
(*
* @description:
* Returns first sector occupied by last directory entry. Can be invoked after xBiosGetEntry.
* 
* @returns: (word) - returns starting sector number of last directory entry,  
*)
function DosGetEntryStatus:byte;
(*
* @description:
* Reads and returns last directory entry status byte. Can be invoked after xBiosFindEntry.
* 
* @returns: (byte) - returns status byte of found directory entry
*)
function DosIsDir(status: byte):boolean;
(*
* @description:
* Interprets directory entry status byte, returning true if entry is an directory.
* 
* @returns: (boolean) - returns true if status describes directory entry  
*)
function DosIsFile(status: byte):boolean;
(*
* @description:
* Interprets directory entry status byte, returning true if entry is an file.
* 
* @returns: (boolean) - returns true if status describes file entry  
*)
function DosIsDeleted(status: byte):boolean;
(*
* @description:
* Interprets directory entry status byte, returning true if entry has been deleted.
* 
* @returns: (boolean) - returns true if status describes deleted entry  
*)
function DosIsLocked(status: byte):boolean;
(*
* @description:
* Interprets directory entry status byte, returning true if entry has been locked.
* 
* @returns: (boolean) - returns true if status describes locked entry  
*)
function DosIsOpened(status: byte):boolean;
(*
* @description:
* Interprets directory entry status byte, returning true if entry has been opened for writing.
* 
* @returns: (boolean) - returns true if status describes opened entry  
*)
function DosFileExists(var filename:TString):boolean;
(*
* @description:
* Checks if file exists in current directory.
* 
* @param: filename - string containing file name (8.3 format without dot) padded with spaces. 
* Must be 11 characters long.
* 
* @returns: (boolean) - returns true if file exists  
*)
function DosDirExists(var filename:TString):boolean;
(*
* @description:
* Checks if subdirectory exists in current directory.
* 
* @param: filename - string containing directory name (8.3 format without dot) padded with spaces. 
* Must be 11 characters long.
* 
* @returns: (boolean) - returns true if directory exists  
*)
function formatFilename(s:TString; showExt:boolean):TString;
(*
* @description:
* Formats xBIOS filenames into common dos, dot separated format.
* 
* @param: s - string containing file name (8.3 format without dot) padded with spaces. 
* @param: showExt - defines if you want to show file extension in output string
* 
* @returns: (string) - returns formated file name with or without extension
*)

implementation

function xBiosCheck:byte;
var cs:word;
begin
    cs:=dPeek(xBIOS_ADDRESS);
    if (char(Lo(cs))='x') and (char(Hi(cs))='B') then 
      result := peek(xBIOS_VERSION)
    else result := 0;
end;

procedure xBiosRenameEntry(var filename:TString); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy filename
    ldx filename+1
    iny
    sne
    inx
    jsr xBIOS_RENAME_ENTRY
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosLoadFile(var filename:TString); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy filename
    ldx filename+1
    iny
    sne
    inx
    jsr xBIOS_LOAD_FILE
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosOpenFile(var filename:TString); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy filename
    ldx filename+1
    iny
    sne
    inx
    jsr xBIOS_OPEN_FILE
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosLoadData(dest: pointer); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy dest
    ldx dest+1
    jsr xBIOS_LOAD_DATA
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosLoadLz4Data(dest: pointer); assembler;
asm {
.LOCAL

                  mwa dest xdest
unlz4
                  jsr    xBIOS_GET_BYTE                  ; length of literals
                  sta    token
               :4 lsr
                  beq    read_offset                     ; there is no literal
                  cmp    #$0f
                  jsr    getlength
literals          jsr    xBIOS_GET_BYTE
                  jsr    store
                  bne    literals
read_offset       jsr    xBIOS_GET_BYTE
                  tay
                  sec
                  eor    #$ff
                  adc    xdest
                  sta    src
                  tya
                  php
                  jsr    xBIOS_GET_BYTE
                  plp
                  bne    not_done
                  tay
                  beq    unlz4_done
not_done          eor    #$ff
                  adc    xdest+1
                  sta    src+1
                  ; c=1
                  lda    #$ff
token             equ    *-1
                  and    #$0f
                  adc    #$03                            ; 3+1=4
                  cmp    #$13
                  jsr    getLength

@                 lda    $ffff
src               equ    *-2
                  inw    src
                  jsr    store
                  bne    @-
                  beq    unlz4                           ; zawsze
store             sta    $ffff
xdest              equ    *-2
                  inw    xdest
                  dec    lenL
                  bne    unlz4_done
                  dec    lenH
unlz4_done        rts
getLength_next    jsr    xBIOS_GET_BYTE
                  tay
                  clc
                  adc    #$00
lenL              equ    *-1
                  bcc    @+
                  inc    lenH
@                 iny
getLength         sta    lenL
                  beq    getLength_next
                  tay
                  beq    @+
                  inc    lenH
@                 rts
lenH              .byte    $00
.ENDL
};
end;

procedure xBiosWriteData(src: pointer); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy src
    ldx src+1
    jsr xBIOS_WRITE_DATA 
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosOpenCurrentDir; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_OPEN_CURRENT_DIR
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

function xBiosGetByte:byte; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_GET_BYTE  
    sta result
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosPutByte(b:byte); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    lda b
    jsr xBIOS_PUT_BYTE  
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosFlushBuffer; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_FLUSH_BUFFER
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosSetLength(len: word); assembler;
asm {
    txa:pha
    ldy len
    ldx len+1
    jsr xBIOS_SET_LENGTH
    pla:tax
};
end;

procedure xBiosSetInitAd(adr: word); assembler;
asm {
    txa:pha
    ldy adr
    ldx adr+1
    jsr xBIOS_SET_INIAD 
    pla:tax
};
end;

procedure xBiosSetFileOffset(pos: cardinal); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy pos
    ldx pos+1
    lda pos+2
    jsr xBIOS_SET_FILE_OFFSET 
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosSetRunAd(adr: word); assembler;
asm {
    txa:pha
    ldy adr
    ldx adr+1
    jsr xBIOS_SET_RUNAD  
    pla:tax
};
end;

procedure xBiosSetDefaultDevice; assembler;
asm {
    txa:pha
    jsr xBIOS_SET_DEFAULT_DEVICE   
    pla:tax
};
end;

procedure xBiosOpenDir(var filename:TString); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy filename
    ldx filename+1
    iny
    sne
    inx
    jsr xBIOS_OPEN_DIR 
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosLoadBinaryFile; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_LOAD_BINARY_FILE  
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosOpenDefaultDir; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_OPEN_DEFAULT_DIR  
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosSetDevice(dev: word); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy dev
    ldx dev+1
    jsr xBIOS_SET_DEVICE  
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosRelocateBuffer(adr: word;c:byte); assembler;
asm {
    txa:pha
    ldx adr+1
    clc
    lda c
    seq
    sec
    jsr xBIOS_SET_DEVICE  
@   pla:tax
};
end;

procedure xBiosGetEntry; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_GET_ENTRY  
    stx xBiosDirEntryIndex
    sta xBiosDirEntryStatus
    bcc @+
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosOpenDefaultFile; assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    jsr xBIOS_OPEN_DEFAULT_FILE  
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosReadSector(sector: word); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy sector
    lda sector+1
    jsr xBIOS_READ_SECTOR 
    bcc @+
    stx xBiosIOerror
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosFindEntry(var filename: TString); assembler;
asm {
    txa:pha
    mva #0 xBiosIOresult
    sta xBiosIOerror
    ldy filename
    ldx filename+1
    iny
    sne
    inx
    jsr xBIOS_FIND_ENTRY   
    stx xBiosDirEntryIndex
    sta xBiosDirEntrySector+1
    sty xBiosDirEntrySector
    bcc @+
    mva #1 xBiosIOresult 
@   pla:tax
};
end;

procedure xBiosSetBufferSize(size: byte); assembler;
asm {
    txa:pha
    lda #$ff
    sub size
    add #1
    jsr xBIOS_SET_BUFFER_SIZE 
    pla:tax
};
end;

// ************************************ DOS RELATED ROUTINES

procedure DosReadEntryName(ptr: pointer);overload;
begin
    move(pointer(xBufferH*256+xBiosDirEntryIndex),ptr,11);
end;

procedure DosReadEntryName(var s: TString);overload;
begin
    s[0]:=char(11);
    move(pointer(xBufferH*256+xBiosDirEntryIndex),@s[1],11);
end;

function DosGetEntryName:TString;
begin
    result[0]:=char(11);
    move(pointer(xBufferH*256+xBiosDirEntryIndex),@result[1],11);
end;

function formatFilename(s:TString; showExt:boolean):TString;
var i,o:byte;

procedure moveIO(iend:byte);
begin
    repeat
        if s[i] <> ' ' then begin
            result[o]:=s[i];
            inc(i);
            inc(o);
        end else inc(i)
    until i > iend;
end;

begin
    i:=1;
    o:=1;
    moveIO(8);
    if showExt and (s[i]<>' ') then begin
        result[o]:='.';
        inc(o);
        moveIO(11);
    end;
    result[0]:=char(o-1);
end;

function DosHasEntryExt(ext: TString):boolean;
var mem:word;
    i:byte;
begin
    result := true;
    mem := xBufferH * $100 + xBiosDirEntryIndex + 7;
    for i:=1 to 3 do 
      if ext[i]<>char(peek(mem+i)) then result:=false;
end;

function DosGetEntrySize:word;
begin
    result := Dpeek(xBufferH * $100 + xBiosDirEntryIndex - 4);
end;

function DosGetEntrySector:word;
begin
    result := Dpeek(xBufferH * $100 + xBiosDirEntryIndex - 2);
end;

function DosGetEntryStatus:byte;
begin
    result := Peek(xBufferH * $100 + xBiosDirEntryIndex - 5);
end;

function DosIsDir(status: byte):boolean;
begin
    result := status and %00010000 <> 0;
end;

function DosIsFile(status: byte):boolean;
begin
    result := status and %01000000 <> 0;
end;

function DosIsDeleted(status: byte):boolean;
begin
    result := status and %10000000 <> 0;
end;

function DosIsLocked(status: byte):boolean;
begin
    result := status and %00100000 <> 0;
end;

function DosIsOpened(status: byte):boolean;
begin
    result := status and %00000001 <> 0;
end;

function DosFileExists(var filename:TString):boolean;
begin
    xBiosFindEntry(filename);
    result := (xBiosIOresult = 0) and DosIsFile(DosGetEntryStatus);
end;

function DosDirExists(var filename:TString):boolean;
begin
    xBiosFindEntry(filename);
    result := (xBiosIOresult = 0) and DosIsDir(DosGetEntryStatus);
end;

end.
