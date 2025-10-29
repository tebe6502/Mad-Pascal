
{    ###################################################################   }
{    ##                                                               ##   }
{    ##      ##    ##### #####  ##   ##  ##      ## ##  ## ##  ##     ##   }
{    ##      ##      ### ##  ## ## # ## ###     ##  ## ##  ##  ##     ##   }
{    ##      ##     ###  #####  #######  ##    ##   ####   ######     ##   }
{    ##      ##    ###   ##  ## ### ###  ##   ##    ## ##  ##  ##     ##   }
{    ##      ##### ##### ##  ## ##   ## #### ##     ##  ## ##  ##     ##   }
{    ##                                                               ##   }
{    ##   EXTREMELY FAST AND EASY TO UNDERSTAND COMPRESSION ALGORITM  ##   }
{    ##                                                               ##   }
{    ###################################################################   }
{    ##                                                               ##   }
{    ##   This unit implements the updated LZRW1/KH algoritm which    ##   }
{    ##   also implements  some RLE coding  which is usefull  when    ##   }
{    ##   compress files  containing  a lot  of consecutive  bytes    ##   }
{    ##   having the same value.   The algoritm is not as good  as    ##   }
{    ##   LZH, but can compete with Lempel-Ziff.   It's the fasted    ##   }
{    ##   one I've encountered upto now.                              ##   }
{    ##                                                               ##   }
{    ##                                                               ##   }
{    ##                                                               ##   }
{    ##                                                Kurt HAENEN    ##   }
{    ##                                                               ##   }
{    ###################################################################   }

UNIT LZRW1KH;

INTERFACE

//uses SysUtils;

type Int16 = SmallInt;

CONST
    BufferMaxSize  = 8*1024-1;
    BufferMax      = BufferMaxSize-1;
    FLAG_Copied    = $80;
    FLAG_Compress  = $40;

TYPE
    BufferIndex    = 0..BufferMax + 15; 
    BufferSize     = 0..BufferMaxSize;
       { extra bytes needed here if compression fails      *dh *}
    BufferArray    = ARRAY [BufferIndex] OF BYTE;
    BufferPtr      = ^BufferArray;


FUNCTION  Compression    (    Source,Dest    : BufferPtr;
                              SourceSize     : BufferSize   )    : BufferSize;

FUNCTION  Decompression  (    Source,Dest    : BufferPtr;
                              SourceSize     : BufferSize   )    : BufferSize;

IMPLEMENTATION

type
  HashTable      = ARRAY [0..4095] OF Int16;
  HashTabPtr     = ^Hashtable;

VAR
  Hash                     : HashTabPtr;

                             { check if this string has already been seen }
                             { in the current 4 KB window }
FUNCTION  GetMatch       (    Source         : BufferPtr;
                              X              : BufferIndex;
                              SourceSize     : BufferSize;
                              Hash           : HashTabPtr;
                          VAR Size           : WORD;
                          VAR Pos            : BufferIndex  )    : BOOLEAN;
VAR
  HashValue      : WORD;
  TmpHash        : Int16;
BEGIN
  HashValue := (40543*((((Source^[X] SHL 4) XOR Source^[X+1]) SHL 4) XOR
                                     Source^[X+2]) SHR 4) AND $0FFF;
  Result := FALSE;
  TmpHash := Hash^[HashValue];
  IF (TmpHash <> -1) and (word(X - TmpHash) < 4096) THEN BEGIN
    Pos := TmpHash;
    Size := 0;
    WHILE ((Size < 18) AND (Source^[X+Size] = Source^[Pos+Size])
                       AND (word(X+Size) < SourceSize)) DO begin
      INC(Size);
    end;
    Result := (Size >= 3)
  END;
  Hash^[HashValue] := X
END;
                                    { compress a buffer of max. 32 KB }
FUNCTION  Compression(Source, Dest : BufferPtr;
                      SourceSize   : BufferSize) :BufferSize;
VAR
  Bit,Command,Size         : WORD;
  Key                      : Word;
  X,Y,Z,Pos                : BufferIndex;
BEGIN
  FillChar(Hash^,SizeOf(Hashtable), $FF);
  
  Dest^[0] := FLAG_Compress;
  X := 0;
  Y := 3;
  Z := 1;
  Bit := 0;
  Command := 0;
  WHILE (X < SourceSize) AND (Y <= SourceSize) DO BEGIN
    IF (Bit > 15) THEN BEGIN
      Dest^[Z] := HI(Command);
      Dest^[Z+1] := LO(Command);
      Z := Y;
      Bit := 0;
      INC(Y,2)
    END;
    Size := 1;
    WHILE ((Source^[X] = Source^[X+Size]) AND (Size < $FFF)
                         AND (X+Size < SourceSize)) DO begin
              INC(Size);
    end;
    IF (Size >= 16) THEN BEGIN
      Dest^[Y] := 0;
      Dest^[Y+1] := HI(Size-16);
      Dest^[Y+2] := LO(Size-16);
      Dest^[Y+3] := Source^[X];
      INC(Y,4);
      INC(X,Size);
      Command := (Command SHL 1) + 1;
    END
    ELSE begin { not size >= 16 }
      IF (GetMatch(Source,X,SourceSize,Hash,Size,Pos)) THEN BEGIN
        Key := ((X-Pos) SHL 4) + (Size-3);
        Dest^[Y] := HI(Key);
        Dest^[Y+1] := LO(Key);
        INC(Y,2);
        INC(X,Size);
        Command := (Command SHL 1) + 1
      END
      ELSE BEGIN
        Dest^[Y] := Source^[X];
        INC(Y);
        INC(X);
        Command := Command SHL 1
      END;
    end; { size <= 16 }
    INC(Bit);
  END; { while x < sourcesize ... }
  Command := Command SHL (16-Bit);
  Dest^[Z] := HI(Command);
  Dest^[Z+1] := LO(Command);
  IF (Y > SourceSize) THEN BEGIN
    MOVE(Source^[0],Dest^[1],SourceSize);
    Dest^[0] := FLAG_Copied;
    Y := SUCC(SourceSize)
  END;
  Result := Y
END;

                                    { decompress a buffer of max 32 KB }
FUNCTION  Decompression(Source,Dest    : BufferPtr;
                        SourceSize     : BufferSize) : BufferSize;
VAR
  X,Y,Pos                  : BufferIndex;
  Command,Size,K           : WORD;
  Bit                      : BYTE;
  SaveY                    : BufferIndex; { * dh * unsafe for-loop variable Y }

BEGIN
  IF (Source^[0] = FLAG_Copied) THEN  begin
    FOR Y := 1 TO PRED(SourceSize) DO begin
      Dest^[PRED(Y)] := Source^[Y];
      SaveY := Y;
    end;
    Y := SaveY;
  end
  ELSE BEGIN
    Y := 0;
    X := 3;
    Command := (Source^[1] SHL 8) + Source^[2];
    Bit := 16;
    WHILE (X < SourceSize) DO BEGIN
      IF (Bit = 0) THEN BEGIN
        Command := (Source^[X] SHL 8) + Source^[X+1];
        Bit := 16;
        INC(X,2)
      END;
      IF ((Command AND $8000) = 0) THEN BEGIN
           Dest^[Y] := Source^[X];
           INC(X);
           INC(Y)
      END
      ELSE BEGIN  { command and $8000 }
        Pos := ((Source^[X] SHL 4)
               +(Source^[X+1] SHR 4));
        IF (Pos = 0) THEN BEGIN
          Size := (Source^[X+1] SHL 8) + Source^[X+2] + 15;
          FOR K := 0 TO Size DO begin
               Dest^[Y+K] := Source^[X+3];
          end;
          INC(X,4);
          INC(Y,Size+1)
        END
        ELSE BEGIN  { pos = 0 }
          Size := (Source^[X+1] AND $0F)+2;
          FOR K := 0 TO Size DO
               Dest^[Y+K] := Dest^[Y-Pos+K];
          INC(X,2);
          INC(Y,Size+1)
        END; { pos = 0 }
      END;  { command and $8000 }
      Command := Command SHL 1;
      DEC(Bit)
    END { while x < sourcesize }
  END;
  Result := Y
END;  { decompression }

{
  Unit "Finalization" as Delphi 2.0 would have it
}

Initialization

{$IFDEF ATARI}
 Hash:=pointer($8000);

{$ELSE}
  Hash := Nil;
  Getmem(Hash,Sizeof(Hashtable));
{$ENDIF}

END.
