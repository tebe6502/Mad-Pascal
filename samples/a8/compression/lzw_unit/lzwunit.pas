
UNIT LZWUnit;

{ Ryan Lanctot							      }
{ LZWUnit - Defines the LZWObj object to compress and uncompress      }
{           files using the LZW compression algorithm                 }
{ If you would like to create a file with a copy of the string        }
{ table LZWUnit used to compress the input file just define the       }
{ Debugging value in the next line                                    }
 
// {Define Debugging}
 
{ ========================= } INTERFACE { =========================== }
 
USES Dos,Crt;
 
CONST
  MaxTableEntries = 3000;               {Set size of string code table}
TYPE
  TableBytes = (Prefix,Suffix,Link);
  
  LZWObj = OBJECT
    InF,OutF       : FILE;
    CodeTbl        : ARRAY[0..MaxTableEntries,Prefix..Link] OF smallint;
    HitTbl         : ARRAY[0..MaxTableEntries] OF smallint;
    PrefixCandidate: smallint;
    SuffixCandidate: smallint;
    TableFull      : Boolean;
    TableTop       : smallint;
    CONSTRUCTOR Init;
    FUNCTION ManageTbl: smallint; 
    PROCEDURE InsertEntry; 
    FUNCTION InputUnCompValue: Byte; 
    FUNCTION InputCompValue: smallint; 
    PROCEDURE OutputUnCompValue(B: Byte); 
    PROCEDURE OutputCompValue(I: smallint); 
    PROCEDURE CompressFile(InFile,OutFile : PathStr);
    FUNCTION ExpandValue(InputValue : smallint; Output : Boolean): smallint; 
    PROCEDURE UnCompressFile(InFile,OutFile : PathStr);
    DESTRUCTOR CompressDone;
  END;

{ ====================== } IMPLEMENTATION { ========================= }
 
 
CONSTRUCTOR LZWObj.Init; {--------------------------------------------}
{  Initializes the string code table with the atomic values           }
{    and the table management values TableFull, TableTop, HitTbl[]    }
{  HitTbl is an array that contains the head pointer for linked       }
{    lists (yes multiple lists) of compression code to facilitate     }
{    faster lookup of PrefixCandidate-SuffixCandidate pairs.          }
{  If HitTbl[Prefix value] = 0 then no P-S entries with the Prefix    }
{    value have been added to the string table. If                    }
{    HitTbl[Prefix value] <> 0, it contains the entry number of the   }
{    first element in the string table with that Prefix value         }
{  The CodeTbl[X,Link] element will contain a 0 if the string table   }
{    does not have any other entries that start with the prefix in    }
{    CodeTbl[X,Prefix], otherwise CodeTbl[X,Link] points to the next  }
{    entry with a matching PrefixCandidate value                      }
{---------------------------------------------------------------------}
 
VAR I : smallint;
BEGIN
  TableFull := FALSE;
  TableTop := 255;
  FOR I := 0 TO MaxTableEntries DO BEGIN
    HitTbl[I] := 0;
    CodeTbl[I, Link] := 0;
    IF I > 255 THEN BEGIN
      CodeTbl[I, Prefix] := 0;
      CodeTbl[I, Suffix] := 0
      END
    ELSE BEGIN
      CodeTbl[I, Prefix] := -1;
      CodeTbl[I, Suffix] := I
      END
    END
  END; 
 
 
PROCEDURE LZWObj.InsertEntry; {---------------------------------------}
{ Insert PrefixCandidate-SuffixCandidate into the next available      }
{   entry in the table                                                }
{---------------------------------------------------------------------}
 
BEGIN
  CodeTbl[TableTop, Prefix] := PrefixCandidate;
  CodeTbl[TableTop, Suffix] := SuffixCandidate;
  IF TableTop = MaxTableEntries THEN TableFull := TRUE;
END;
 
 
FUNCTION LZWObj.ManageTbl: smallint; {=================================}
{  ManageTbl searches the Table for PrefixCandidate-SuffixCandidate   }
{    pairs of characters/codes. If the pair is not in the string      }
{    table, it adds them and updates the linked list (See INIT)       }
{    If the pair is found, it returns the entry number for the pair.  }
{=====================================================================}
 
VAR
  Found,                {Character pair Found}
  EndOfLinks : Boolean; {End of linked list found while searching list}
  CurPtr : smallint;     {Current element number in string table       }
BEGIN
 
  Found := FALSE;       {Initialize values}
  EndOfLinks := FALSE;
 
  IF HitTbl[PrefixCandidate] <> 0 THEN BEGIN {Entries exist for Prefix}
    CurPtr := HitTbl[PrefixCandidate];  {Trace list starting at head  }
    REPEAT
      IF (CodeTbl[CurPtr,Prefix] = PrefixCandidate) AND
         (CodeTbl[CurPtr,Suffix] = SuffixCandidate) THEN
         Found := TRUE
      ELSE                                    {Not found              }
        IF CodeTbl[CurPtr,Link] <> 0 THEN     {Check if at end of list}
          CurPtr := CodeTbl[CurPtr,Link]      {Get next element to chk}
        ELSE
          EndOfLinks := TRUE                  {End of list            }
      UNTIL Found OR EndOfLinks
    END;
 
  IF Found THEN                               {If pair found          }
    Result := CurPtr                          {  return element #     }
  ELSE BEGIN                                  {otherwise, add to table}
    IF NOT TableFull THEN BEGIN
      Inc(TableTop);
      LZWObj.InsertEntry;
      IF HitTbl[PrefixCandidate] = 0 THEN     {Adjust links           }
        HitTbl[PrefixCandidate] := TableTop
      ELSE
        CodeTbl[CurPtr,Link] := TableTop
      END;
    Result := -1;                             {Not found signal       }
    END;
  END;

{---------------------------------------------------------------------}
{ The next four methods provide input and output for file i/o         }
{---------------------------------------------------------------------}
 
FUNCTION LZWObj.InputUnCompValue: Byte;
BEGIN
  BlockRead(InF, Result, 1);
  END;
 
FUNCTION LZWObj.InputCompValue: smallint;
BEGIN
  BlockRead(InF, Result, 2);
  END;
 
PROCEDURE LZWObj.OutputUnCompValue(B: Byte);
BEGIN
  BlockWrite(OutF, B, 1)
  END;
 
PROCEDURE LZWObj.OutputCompValue(I: smallint);
BEGIN
  BlockWrite(OutF, I, 2)
  END;


PROCEDURE LZWObj.CompressFile(InFile,OutFile : PathStr); {------------}
{  CompressFile manages all the compression tasks                     }
{---------------------------------------------------------------------}
 
VAR
  Ctr : integer;           {Counter for onscreen display              }
  FoundCode : smallint;    {Used to manage results from ManageTbl code}
BEGIN
 
  Assign(InF,InFile);      {Open input file as 1 byte/record file     }
  Reset(InF,1);
  Assign(OutF,OutFile);    {Open output file as a 2 byte/record file  }
  Rewrite(OutF,1);         {  because we write out smallints          }
 
  Ctr := 0;
 
  PrefixCandidate := LZWObj.InputUnCompValue;
 
  REPEAT
 
    Inc(Ctr);                          {Manage counter display}
    IF (Ctr AND 127) = 127 THEN BEGIN
      GotoXY(10,10);
      Write(Ctr);
      END;
 
    SuffixCandidate := LZWObj.InputUnCompValue;
 
    FoundCode := LZWObj.ManageTbl;             {Search table for P-S pair}
 
    IF FoundCode >= 0 THEN                     {If pair found            }
      PrefixCandidate := FoundCode             {  go look for next pair  }
    ELSE BEGIN
      LZWObj.OutputCompValue(PrefixCandidate); {otherwise, output Prefix }
      PrefixCandidate := SuffixCandidate       {  and reset for next pair}
      END
    UNTIL Eof(InF);
  LZWObj.OutputCompValue(PrefixCandidate);     {Write last character out }
 
  END;

 
FUNCTION LZWObj.ExpandValue(InputValue : smallint; Output:Boolean) : smallint;
{  ExpandValue expands compression codes. Note, if the prefix value   }
{    retrieved in KPrefix is another compression code, ExpandValue    }
{    will recursively call itself until KPrefix is an extended ASCII  }
{    character.                                                       }
{                                                                     }
{  Input:                                                             }
{    InputValue is the value to expand                                }
{    Output turns on/off writing of expanded characters to            }
{      file so you can retrieve (without writing) the first ASCIi     }
{      character at the head of the compressed character chain. This  }
{      becomes necessary when you must fill in the Suffix value in    }
{      string table for adjacent Prefix pointers.                     }
{  Output:                                                            }
{    Returns the character at the head of compressed byte chain when  }
{      you pass it a compressed byte. If you pass it an ASCII         }
{      character, it returns that character. This made coding simpler }
{---------------------------------------------------------------------}
 
VAR
  KPrefix, KSuffix, KReturned : smallint;
 
 BEGIN
  IF InputValue > 255 THEN BEGIN                 {Is compressed value?}
    KPrefix := CodeTbl[InputValue,Prefix];       {Yes, get table entry}
    KSuffix := CodeTbl[InputValue,Suffix];
    IF KPrefix > 255 THEN                        {If prefix is a      }
      KReturned := LZWObj.ExpandValue(KPrefix,Output)   { compressed char    }
    ELSE BEGIN                                   { recursively call   }
      KReturned := KPrefix;                      { ExpandValue        }
      IF Output THEN LZWObj.OutputUnCompValue(KPrefix)  {otherwise, set head }
                                                 { value and output   }
                                                 { uncompressed bytes }
      END;                                       { to file if Output  }
                                                 { set TRUE           }
    IF Output THEN LZWObj.OutputUnCompValue(KSuffix)
    END
  ELSE
    KReturned := InputValue; {Return ASCII value if passed ASCII value}
 
  Result := KReturned
  END;
 
 
PROCEDURE LZWObj.UnCompressFile(InFile,OutFile : PathStr); {----------}
{ UnCompresFile manages all aspects of uncompressing files            }
{---------------------------------------------------------------------}
 
VAR
  Ctr : integer;                   {Onscreen info                     }
  Found : smallint;                {Returned from ManageTbl routine   }
  Dummy, SuffixCopy, I :smallint;
 
BEGIN
  Assign(InF,InFile);            {Open input file to read smallints   }
  Reset(InF,1);
  Assign(OutF,OutFile);          {Open output file to write characters}
  Rewrite(OutF,1);

  Ctr := 0;

  PrefixCandidate := LZWObj.InputCompValue;
 
  REPEAT
 
    Inc(Ctr);                               {Manage onscreen display  }
    IF (Ctr AND 127) = 127 THEN BEGIN
      GotoXY(10,10);
      Write(Ctr)
      END;
 
 
    IF PrefixCandidate < 256 THEN           {Output an ASCII character}
      LZWObj.OutputUnCompValue(PrefixCandidate);
 
    SuffixCandidate := LZWObj.InputCompValue;
 
    IF SuffixCandidate > 255 THEN BEGIN     {Compressed character?    }
 
      SuffixCopy := SuffixCandidate;   {Save just in case we expand it}
 
      {Handle special case when you need to expand an entry that you  }
      { have not yet added to table                                   }
 
      IF smallint(TableTop + 1) = SuffixCandidate THEN BEGIN
        SuffixCandidate := LZWObj.ExpandValue(PrefixCandidate,FALSE);
        Found := LZWObj.ManageTbl;
        SuffixCandidate := SuffixCopy;
        Dummy := LZWObj.ExpandValue(SuffixCandidate,TRUE);
        END
      ELSE BEGIN
        SuffixCandidate := LZWObj.ExpandValue(SuffixCandidate,TRUE); {Normal }
        Found := LZWObj.ManageTbl;                                   {expand }
        SuffixCandidate := SuffixCopy
        END
      END
    ELSE
      Found := LZWObj.ManageTbl;
      
    PrefixCandidate := SuffixCandidate;
    UNTIL Eof(InF);
 
  IF PrefixCandidate < 256 THEN                   {Output last character if  }
    LZWObj.OutputUnCompValue(PrefixCandidate)     { not a compressed code    }
 
  END;
 
DESTRUCTOR LZWObj.CompressDone; {-------------------------------------}
{ CompressDone closes the files.                                      }
{---------------------------------------------------------------------}
 
BEGIN
  Close(InF);
  Close(OutF)
  END;
 
 
END.
