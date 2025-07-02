
{*********************************************************************
* UNLZW2.PAS - This program performs LZW decompression on the data   *
*   from the input file and writes the expanded, original data to    *
*   the output file. It uses the same coding scheme as LZW2.PAS      *
*                                                                    *
* To run : UNLZW <infile> <outfile>                                  *
*                                                                    *
*   IMPORTANT: The BuildString function is recursive. As such, it    *
*   can use a lot of stack space depending on how deep it must go to *
*   expand compression codes back into strings. Be sure to use the   *
*   $M switch when compiling to make your stack larger than normal.  *
*   Note: Reducing MAXENTRIES also reduces the max. recursion depth. *
*                                                                    *
* Author  : David Reid, The Cobb Group                               *
* Last Revised : 12-31-91                                            *
* Free Pascal, Mad Pascal: 2024-05-18                                *
*********************************************************************}

USES Dos,Crt;

CONST
                             {* This defines the string table size. *}
  LZWENTRIES = 2500;//8192;         {* You can change LZWENTRIES to 512,   *}
                             {* 1024, 2048, or 4096 as you see fit. *}
  MAXENTRIES = 256+LZWENTRIES;
  MAXSTRLEN = 1024;          {* Determines the size of workstr[]    *}

  EXIT_FAILURE = 1;               {* Error level return value       *}


{$IFDEF ATARI}
  IO_OK = 1;
{$ELSE}
  IO_OK = 0;
{$ENDIF}

{*----TYPE DEFINITIONS----------------------------------------------*}

TYPE
  RULEtag = RECORD           {* This structure holds one LZW string *}
                             {* table entry. It contains the prefix *}
    Prefix : smallint;       {* character, the suffix character,    *}
    Suffix : smallint;       {* and the linked-list pointer to the  *}
    Next   : smallint;       {* next table entry that starts with   *}
    END;                     {* the same prefix as this one does.   *}

  WorkStrType = ARRAY[0..MAXSTRLEN-1] OF Char; {* Hold expanded strs*}

  PtrType = RECORD           {* Define a pointer record             *}
    Offset  : Word;          {*   so we can access the individual   *}
    Segment : Word           {*   pointer elements for pointer      *}
    END;                     {*   arithmetic.                       *}

  CharPtr = ^Char;

{*----GLOBAL VARIABLES----------------------------------------------*}

VAR
  XInMask  : Word = $0000;        {* Points to next bit in xbitbuff *}
  XBitBuff : Word = 0;            {* Holds residual output bits     *}
  OutLength: Word = 0;            {* Counter for bytes output       *}
  InLength : Word = 0;            {* Counter for bytes input        *}

  Rules   : ARRAY[0..MAXENTRIES-1] OF ^RULEtag; {* The string table *}
  Bitmask : word;            {* Controls size of input characters   *}
  Entries : smallint;        {* Number of entries in string table   *}
  InFile  : FILE;            {* Input file                          *}
  OutFile : FILE;            {* Output file                         *}
  WorkStr : WorkStrType;     {* Holds expanded strings              *}

{ Init - Checks command-line arguments, opens files, and displays an }
{   informational prompt.                                            }

PROCEDURE Init;
BEGIN
  IF (ParamCount <>  2 ) THEN
    BEGIN
      WriteLn('syntax: ULZW2 <infile> <outfile>');
      Halt(EXIT_FAILURE)
    END;
  {$I-}
  Assign(InFile, ParamStr(1));
  Reset(InFile,1);
  {$I+}
  IF IOResult <> IO_OK THEN
    BEGIN
      WriteLn('Error opening input file ', ParamStr(1));
      Halt(EXIT_FAILURE)
    END;
  {$I-}
  Assign(OutFile, ParamStr(2));
  Rewrite(OutFile,1);
  {$I+}
  IF IOResult <> IO_OK THEN
    BEGIN
      WriteLn('Error opening output file ', ParamStr(2));
      Halt(EXIT_FAILURE)
    END;
  WriteLn('Decompressing ...')
END;

{ Term - Closes files and displays file sizes.                       }

PROCEDURE Term;
BEGIN
  Close(InFile);
  Close(OutFile);
  WriteLn('Input file length : ',InLength:7);
  WriteLn('Output file length: ',OutLength:7);
END;

{ Output - Writes the expanded sequence of character in OutBuff to   }
{   the output file and updates outlength accordingly.               }

PROCEDURE Output(BuffLen: smallint);
BEGIN
  BlockWrite(OutFile,WorkStr,BuffLen);
  Inc(OutLength,BuffLen)
END;

{ Input - Reads a 9, 10, 11, 12, or 13 bit code from the input file. }
{   Stores any residual bits in the global variable xbitbuff. The    }
{   global variable xinmask keeps track of the residual bits. The    }
{   local variable xoutmask walks down the bits in xbitbuff and helps}
{   transfer them to rval. The starting value for xoutmask comes     }
{   from the global variable Bitmask.                                }

FUNCTION Input: smallint;
VAR
  RVal     : Word;
  XOutMask : Word;
  Ascii    : Boolean;
BEGIN
  IF XInMask = 0 THEN BEGIN
    IF Eof(InFile) THEN BEGIN
      Input := -1;
      Exit
      END;
    BlockRead(InFile,XBitBuff,1);
    XInMask := $0080;
    Inc(InLength)
    END;
  {*----Read first bit: ASCII value or string table index?--------*}
  IF (XBitBuff AND XInMask) <> 0 THEN BEGIN
    Ascii := FALSE;
    XOutMask := Bitmask;
    RVal := $ffff
    END
  ELSE BEGIN
    Ascii := TRUE;
    XOutMask := $080;
    XInMask := XInMask SHR 1;
    RVal := 0
    END;
  WHILE XOutMask <> 0 DO BEGIN
    IF XInMask = 0 THEN BEGIN
      IF Eof(InFile) THEN BEGIN
        Input := -1;
        Exit
        END;
      BlockRead(InFile,XBitBuff,1);
      XInMask := $0080;
      Inc(InLength)
    END;
    IF (XBitBuff AND XInMask) <> 0 THEN RVal := RVal OR XOutMask
    ELSE
      IF NOT Ascii THEN RVal := RVal XOR XOutMask;
    XInMask := XInMask SHR 1;
    XOutMask := XOutMask SHR 1
    END;
  IF Ascii THEN
    Input := RVal
  ELSE
    Input := 255 - RVal
END;

{ InitTable - Initializes the first 256 string table entries and     *
{   sets the globals Bitmask and Entries to their starting values.   }

PROCEDURE InitTable;
VAR
  RULE    : ^RULEtag;

BEGIN

  FOR Entries := 0 TO 255 DO BEGIN
    RULE:=Rules[Entries];

    RULE.Prefix := -1;
    RULE.Suffix := Entries;
    RULE.Next := -1;
  END;
    
  Bitmask := 2;
  Entries := 256
END;

{ BuildString - Expands compression codes into the original strings. *
{ THIS PROCEDURE IS RECURSIVE! Make sure your stack can handle it.   }

PROCEDURE BuildString(RuleNum: smallint; Str: CharPtr; VAR BuffLen: word);
VAR
  Position : Word;
  GenPtr   : CharPtr;
BEGIN

  Position := 0;
  
  IF Rules[RuleNum].Prefix >= 0 THEN BEGIN
    BuildString(Rules[RuleNum].Prefix, Str, BuffLen);

    Inc(Position,BuffLen);
    GenPtr := Str;

    inc(GenPtr, Position);    
    //PtrType(GenPtr).Offset := PtrType(GenPtr).Offset + Position;

    BuildString(Rules[RuleNum].Suffix, GenPtr, BuffLen);   
    Inc(BuffLen,Position)
    END
  ELSE BEGIN
    Str^ := Chr(Rules[RuleNum].Suffix);
    BuffLen := 1;
    END;
    
END;

{ AddEntry - Adds a Prefix-Suffix pair to the table. Shifts Bitmask  *
{   left one bit if this entry pushes us past the 512, 1024, 2048,   *
{   or 4096 entry threshold.                                         }

PROCEDURE AddEntry(Prefix,Suffix: smallint);
VAR
  RULE_Entries, RULE_Prefix   : ^RULEtag;  

BEGIN

  RULE_Entries:=Rules[Entries];
  RULE_Prefix:=Rules[Prefix];

  {*----Add Prefix/Suffix pair to the table----------------------*}
  RULE_Entries.Prefix := Prefix;
  RULE_Entries.Suffix := Suffix;

  {*----Update the table's linked list---------------------------*}
  RULE_Entries.Next := RULE_Prefix.Next;
  RULE_Prefix.Next := Entries;

  {*----Check for time to shift bitmask--------------------------*}
  Inc(Entries);
  IF word(Entries - 255) >= Bitmask THEN
      Bitmask := Bitmask SHL 1;
END;

{ Decompress - Decompresses the file. The outer while loop repeats   *
{   each time the table fills up (adaptive reset). The inner while   *
{   loop repeats for each character in the input file.               }

PROCEDURE Decompress;
VAR
  BuffLen   : Word;
  Prefix    : smallint;
  Suffix    : smallint;
  GenPtr    : CharPtr;
  
  I: word;
BEGIN

  FOR I:=0 TO High(Rules) DO
   GetMem(Rules[I], sizeof(RULEtag));
   

  Prefix  := 0;
  BuffLen := 0;
  
  WHILE Prefix <> -1 DO BEGIN
    InitTable;
    Prefix := Input;

    {*----Stay in this loop until string table fills up---------*}
    WHILE ((Entries < MAXENTRIES-1) AND (Prefix <> -1)) DO BEGIN
      GenPtr := @WorkStr;
      BuildString(Prefix, GenPtr, BuffLen);
      
      Output(BuffLen);
      Suffix := Input;
      IF Suffix = -1 THEN Exit;
      GenPtr := @WorkStr;

      IF (Suffix < Entries) THEN {* Code is in table          *}
        BuildString(Suffix, GenPtr, BuffLen)
      ELSE             {* Handle code not yet in table        *}
        BuildString(Prefix, GenPtr, BuffLen);
	
      AddEntry(Prefix,Ord(WorkStr[0]));
      Prefix := Suffix;
    END;

      {*----Output last character sequence before resetting-------*}
    IF Prefix <> -1 THEN BEGIN
      GenPtr := @WorkStr;
      BuildString(Prefix,GenPtr,BuffLen);
      Output(BuffLen)
    END;
      
  END;
    
END;

BEGIN

  Init;
  Decompress;
  Term;

END.
