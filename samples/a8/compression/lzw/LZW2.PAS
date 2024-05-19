
{*********************************************************************
* LZW2.PAS This program performs LZW compression on the input file   *
*   and writes the compressed data to the output file. It uses a     *
*   more efficient coding scheme than LZW.PAS from the Oct/Nov 1991  *
*   issue of ITP.                                                    *
* To run: LZW2 <infile> <outfile>                                    *
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

{*----GLOBAL VARIABLES----------------------------------------------*}

VAR 
  XOutMask : Word = $0080;        {* Points to next bit in xbitbuff *}
  XBitBuff : Word = 0;            {* Holds residual output bits     *}
  OutLength: Word = 0;            {* Counter for bytes output       *}
  InLength : Word = 0;            {* Counter for bytes input        *}

  Rules   : ARRAY[0..MAXENTRIES-1] OF ^RULEtag; {* The string table *}
  Bitmask : word;            {* Controls size of input characters   *}
  Entries : word;            {* Number of entries in string table   *}

  InFile  : FILE;            {* Input file                          *}
  OutFile : FILE;            {* Output file                         *}


PROCEDURE FlushOutput; FORWARD;

{ Init - Checks command-line arguments, opens files, and displays an }
{ informational prompt.                                            }

PROCEDURE Init;
BEGIN

  IF (ParamCount <>  2 ) THEN BEGIN
    WriteLn('syntax: LZW2 <infile> <outfile>');
    Halt(EXIT_FAILURE)
  END;
  {$I-}
  Assign(InFile, ParamStr(1));
  Reset(InFile,1);
  {$I+}
  IF IOResult <> IO_OK THEN BEGIN
    WriteLn('Error opening input file ', ParamStr(1));
    Halt(EXIT_FAILURE)
  END;
  {$I-}
  Assign(OutFile, ParamStr(2));
  Rewrite(OutFile,1);
  {$I+}
  IF IOResult <> IO_OK THEN BEGIN
    WriteLn('Error opening output file ', ParamStr(2));
    Halt(EXIT_FAILURE)
  END;
  
  WriteLn('Compressing ...');
  
END;


{ Term - Flushes any residual bits out to the output file, closes    }
{   the files, and displays the file sizes and compression percent.  }

PROCEDURE Term;
BEGIN

  FlushOutput;
  Close(InFile);
  Close(OutFile);
  WriteLn('Input file length : ',InLength:7);
  WriteLn('Output file length: ',OutLength:7);
  WriteLn('        Compressed: ',(100 - 100 * (outlength/inlength)):8:2,'%');

END;


{ Input - Reads one character from the input file and increments the }
{ global counter inlength.                                         }

FUNCTION Input: smallint;
VAR
  Rval: Byte;
  
 BEGIN

  IF NOT Eof(InFile) THEN BEGIN
    BlockRead(InFile,Rval,1);
    Inc(InLength);
    Input := Rval
    END
  ELSE
    Input := -1;
    
 END;


{ Output - Writes a 9, 10, 11, 12, or 13 bit code to the output file.}
{ Stores any residual bits in the global variable xbitbuff. The    }
{   global variable xoutmask keeps track of the residual bits. The   }
{   local variable xinmask walks down the bits in newbits and helps  }
{   transfer them to xbitbuff. The starting value for xinmask comes  }
{   from the global variable Bitmask.                                }

PROCEDURE Output(NewBits: smallint); 
VAR
  XinMask : Word;

BEGIN

  IF NewBits > 255 THEN BEGIN
    XinMask := Bitmask;
    NewBits := 255 - NewBits;
    END
  ELSE
    XinMask := $0100;

  WHILE XinMask <> 0 DO BEGIN

    IF (NewBits AND XinMask) <> 0 THEN
      XBitBuff := XBitBuff OR XOutMask;

    XinMask := XinMask SHR 1;
    XOutMask := XOutMask SHR 1;

    IF XOutMask = 0 THEN BEGIN
      BlockWrite(OutFile,XBitBuff,1);
      XBitBuff := 0;
      XOutMask := $0080;
      Inc(OutLength)
    END;
      
  END;

END;


{ FlushOut - Forces all residual bits in xbitbuff to be written to   }
{   the output file.                                                 }

PROCEDURE FlushOutput;
BEGIN

  IF XOutMask < $0080 THEN BEGIN
    BlockWrite(OutFile,XBitBuff,1);
    Inc(OutLength)
  END;

  XBitBuff := 0;
  XOutMask := $0080;

END;


{ InitTable - Initializes the first 256 string table entries and     }
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
  Entries := 256;
  
 END;

{ IsInTable - Searches for the specified Prefix-Suffix pair in the   }
{ string table. If found, the pair's position in the table is      }
{   assigned to RuleNum. Returns TRUE if the pair is found or FALSE  }
{   if it isn't found.                                               }

FUNCTION IsInTable(Prefix,Suffix:smallint; VAR RuleNum:smallint): Boolean;
VAR
  I : smallint;

BEGIN

  I := Prefix;
  
  WHILE I <> -1 DO
    IF (Rules[I].Prefix = Prefix) AND (Rules[I].Suffix = Suffix) THEN
      BEGIN
        RuleNum := I;
        IsInTable := TRUE;
        Exit
      END
    ELSE 
      I := Rules[I].Next;

  IsInTable := FALSE;
  
END;

{ AddEntry - Adds a Prefix-Suffix pair to the table. Shifts Bitmask  }
{   left one bit if necessitated by number of entries.               }

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
  IF word(Entries - 255) > Bitmask THEN
      Bitmask := Bitmask SHL 1;
      
END;

{ Compress - Compresses the file. The outer while loop repeats each  }
{   time the table fills up (adaptive reset). The inner while loop   }
{   repeats for each character in the input file.                    }

PROCEDURE Compress; 
VAR
  Prefix    : smallint;
  Suffix    : smallint;
  NewPrefix : smallint;
  
  I: word;

BEGIN

  FOR I:=0 TO High(Rules) DO
   GetMem(Rules[I], sizeof(RULEtag));
   

  Prefix := Input;

  WHILE Prefix <> -1 DO BEGIN
    InitTable;

    WHILE (Entries < MAXENTRIES) AND (Prefix <> -1) DO BEGIN
      Suffix := Input;

      IF IsInTable(Prefix, Suffix, NewPrefix) THEN
          Prefix := NewPrefix
      ELSE BEGIN
        Output(Prefix);
        AddEntry(Prefix, Suffix);
        Prefix := Suffix
      END;
      
    END;
    
  END;
  
END;


BEGIN

  Init;
  Compress;
  Term;
  
END.
