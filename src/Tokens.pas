unit Tokens;


interface

type
  TTokenKind = (
    UNTYPETOK,

    CONSTTOK,
    TYPETOK,
    VARTOK,
    PROCEDURETOK,
    FUNCTIONTOK,
    LABELTOK,
    UNITTOK,


    GETINTVECTOK,
    SETINTVECTOK,
    CASETOK,
    BEGINTOK,
    ENDTOK,
    IFTOK,
    THENTOK,
    ELSETOK,
    WHILETOK,
    DOTOK,
    REPEATTOK,
    UNTILTOK,
    FORTOK,
    TOTOK,
    DOWNTOTOK,
    ASSIGNTOK,
    WRITETOK,
    READLNTOK,
    HALTTOK,
    USESTOK,
    ARRAYTOK,
    OFTOK,
    STRINGTOK,
    INCTOK,
    DECTOK,
    ORDTOK,
    CHRTOK,
    ASMTOK,
    ABSOLUTETOK,
    BREAKTOK,
    CONTINUETOK,
    EXITTOK,
    RANGETOK,

    EQTOK,
    NETOK,
    LTTOK,
    LETOK,
    GTTOK,
    GETOK,
    LOTOK,
    HITOK,

    DOTTOK,
    COMMATOK,
    SEMICOLONTOK,
    OPARTOK,
    CPARTOK,
    DEREFERENCETOK,
    ADDRESSTOK,
    OBRACKETTOK,
    CBRACKETTOK,
    COLONTOK,

    PLUSTOK,
    MINUSTOK,
    MULTOK,
    DIVTOK,
    IDIVTOK,
    MODTOK,
    SHLTOK,
    SHRTOK,
    ORTOK,
    XORTOK,
    ANDTOK,
    NOTTOK,

    ASSIGNFILETOK,
    RESETTOK,
    REWRITETOK,
    APPENDTOK,
    BLOCKREADTOK,
    BLOCKWRITETOK,
    CLOSEFILETOK,
    GETRESOURCEHANDLETOK,
    SIZEOFRESOURCETOK,

    WRITELNTOK,
    SIZEOFTOK,
    LENGTHTOK,
    HIGHTOK,
    LOWTOK,
    INTTOK,
    FRACTOK,
    TRUNCTOK,
    ROUNDTOK,
    ODDTOK,

    PROGRAMTOK,
    LIBRARYTOK,
    EXPORTSTOK,
    EXTERNALTOK,
    INTERFACETOK,
    IMPLEMENTATIONTOK,
    INITIALIZATIONTOK,
    CONSTRUCTORTOK,
    DESTRUCTORTOK,
    OVERLOADTOK,
    ASSEMBLERTOK,
    FORWARDTOK,
    REGISTERTOK,
    INTERRUPTTOK,
    PASCALTOK,
    STDCALLTOK,
    INLINETOK,
    KEEPTOK,

    SUCCTOK,
    PREDTOK,
    PACKEDTOK,
    GOTOTOK,
    INTOK,
    VOLATILETOK,
    STRIPEDTOK,


    SETTOK,            // Size = 32 SET OF

    BYTETOK,           // Size = 1 BYTE
    WORDTOK,           // Size = 2 WORD
    CARDINALTOK,       // Size = 4 CARDINAL
    SHORTINTTOK,       // Size = 1 SHORTINT
    SMALLINTTOK,       // Size = 2 SMALLINT
    INTEGERTOK,        // Size = 4 INTEGER
    CHARTOK,           // Size = 1 CHAR
    BOOLEANTOK,        // Size = 1 BOOLEAN
    POINTERTOK,        // Size = 2 POINTER
    STRINGPOINTERTOK,  // Size = 2 POINTER to STRING
    FILETOK,           // Size = 2/12 FILE
    RECORDTOK,         // Size = 2/???
    OBJECTTOK,         // Size = 2/???
    SHORTREALTOK,      // Size = 2 SHORTREAL      Fixed-Point Q8.8
    REALTOK,           // Size = 4 REAL      Fixed-Point Q24.8
    SINGLETOK,         // Size = 4 SINGLE / FLOAT    IEEE-754 32-bit
    HALFSINGLETOK,     // Size = 2 HALFSINGLE / FLOAT16  IEEE-754 16-bit
    PCHARTOK,          // Size = 2 POINTER TO ARRAY OF CHAR
    ENUMTOK,           // Size = 1 BYTE
    PROCVARTOK,        // Size = 2
    TEXTFILETOK,       // Size = 2/12 TEXTFILE
    FORWARDTYPE,       // Size = 2

    SHORTSTRINGTOK,    // We change into STRINGTOK
    FLOATTOK,          // We change into SINGLETOK
    FLOAT16TOK,        // We change into HALFSINGLETOK
    TEXTTOK,           // We change into TEXTFILETOK

    DEREFERENCEARRAYTOK, // For ARRAY pointers


    DATAORIGINOFFSET,
    CODEORIGINOFFSET,

    IDENTTOK,
    INTNUMBERTOK,
    FRACNUMBERTOK,
    CHARLITERALTOK,
    STRINGLITERALTOK,

    EVALTOK,
    LOOPUNROLLTOK,
    NOLOOPUNROLLTOK,
    LINKTOK,
    MACRORELEASE,
    PROCALIGNTOK,
    LOOPALIGNTOK,
    LINKALIGNTOK,
    INFOTOK,
    WARNINGTOK,
    ERRORTOK,
    UNITBEGINTOK,
    UNITENDTOK,
    IOCHECKON,
    IOCHECKOFF,
    EOFTOK
    );

function GetTokenKindName(tokenKind: TTokenKind): String; // TODO Needed public?
function GetTokenSpelling(tokenKind: TTokenKind): String; // TODO Needed public?
function GetHumanReadbleTokenSpelling(tokenKind: TTokenKind): String;
function GetStandardToken(S: String): TTokenKind;

implementation

uses SysUtils;

type
  TTokenSpelling = record
    tokenKind: TTokenKind;
    spelling: String;
  end;

var
  TokenSpellings: array [Low(TTokenKind)..High(TTokenKind)] of TTokenSpelling;



procedure AddTokenSpelling(t: TTokenKind; s: String);
var
  tokenSpelling: TTokenSpelling;
begin
  tokenSpelling.TokenKind := t;
  tokenSpelling.Spelling := s;

  TokenSpellings[tokenSpelling.TokenKind] := tokenSpelling;
end;

procedure InitializeTokenSpellings;
begin
  // Token spelling definition
  AddTokenSpelling(TTokenKind.CONSTTOK, 'CONST');
  AddTokenSpelling(TTokenKind.TYPETOK, 'TYPE');
  AddTokenSpelling(TTokenKind.VARTOK, 'VAR');
  AddTokenSpelling(TTokenKind.PROCEDURETOK, 'PROCEDURE');
  AddTokenSpelling(TTokenKind.FUNCTIONTOK, 'FUNCTION');
  AddTokenSpelling(TTokenKind.OBJECTTOK, 'OBJECT');
  AddTokenSpelling(TTokenKind.PROGRAMTOK, 'PROGRAM');
  AddTokenSpelling(TTokenKind.LIBRARYTOK, 'LIBRARY');
  AddTokenSpelling(TTokenKind.EXPORTSTOK, 'EXPORTS');
  AddTokenSpelling(TTokenKind.EXTERNALTOK, 'EXTERNAL');
  AddTokenSpelling(TTokenKind.UNITTOK, 'UNIT');
  AddTokenSpelling(TTokenKind.INTERFACETOK, 'INTERFACE');
  AddTokenSpelling(TTokenKind.IMPLEMENTATIONTOK, 'IMPLEMENTATION');
  AddTokenSpelling(TTokenKind.INITIALIZATIONTOK, 'INITIALIZATION');
  AddTokenSpelling(TTokenKind.CONSTRUCTORTOK, 'CONSTRUCTOR');
  AddTokenSpelling(TTokenKind.DESTRUCTORTOK, 'DESTRUCTOR');
  AddTokenSpelling(TTokenKind.OVERLOADTOK, 'OVERLOAD');
  AddTokenSpelling(TTokenKind.ASSEMBLERTOK, 'ASSEMBLER');
  AddTokenSpelling(TTokenKind.FORWARDTOK, 'FORWARD');
  AddTokenSpelling(TTokenKind.REGISTERTOK, 'REGISTER');
  AddTokenSpelling(TTokenKind.INTERRUPTTOK, 'INTERRUPT');
  AddTokenSpelling(TTokenKind.PASCALTOK, 'PASCAL');
  AddTokenSpelling(TTokenKind.STDCALLTOK, 'STDCALL');
  AddTokenSpelling(TTokenKind.INLINETOK, 'INLINE');
  AddTokenSpelling(TTokenKind.KEEPTOK, 'KEEP');

  AddTokenSpelling(TTokenKind.ASSIGNFILETOK, 'ASSIGN');
  AddTokenSpelling(TTokenKind.RESETTOK, 'RESET');
  AddTokenSpelling(TTokenKind.REWRITETOK, 'REWRITE');
  AddTokenSpelling(TTokenKind.APPENDTOK, 'APPEND');
  AddTokenSpelling(TTokenKind.BLOCKREADTOK, 'BLOCKREAD');
  AddTokenSpelling(TTokenKind.BLOCKWRITETOK, 'BLOCKWRITE');
  AddTokenSpelling(TTokenKind.CLOSEFILETOK, 'CLOSE');

  AddTokenSpelling(TTokenKind.GETRESOURCEHANDLETOK, 'GETRESOURCEHANDLE');
  AddTokenSpelling(TTokenKind.SIZEOFRESOURCETOK, 'SIZEOFRESOURCE');


  AddTokenSpelling(TTokenKind.FILETOK, 'FILE');
  AddTokenSpelling(TTokenKind.TEXTFILETOK, 'TEXTFILE');
  AddTokenSpelling(TTokenKind.SETTOK, 'SET');
  AddTokenSpelling(TTokenKind.PACKEDTOK, 'PACKED');
  AddTokenSpelling(TTokenKind.VOLATILETOK, 'VOLATILE');
  AddTokenSpelling(TTokenKind.STRIPEDTOK, 'STRIPED');
  AddTokenSpelling(TTokenKind.LABELTOK, 'LABEL');
  AddTokenSpelling(TTokenKind.GOTOTOK, 'GOTO');
  AddTokenSpelling(TTokenKind.INTOK, 'IN');
  AddTokenSpelling(TTokenKind.RECORDTOK, 'RECORD');
  AddTokenSpelling(TTokenKind.CASETOK, 'CASE');
  AddTokenSpelling(TTokenKind.BEGINTOK, 'BEGIN');
  AddTokenSpelling(TTokenKind.ENDTOK, 'END');
  AddTokenSpelling(TTokenKind.IFTOK, 'IF');
  AddTokenSpelling(TTokenKind.THENTOK, 'THEN');
  AddTokenSpelling(TTokenKind.ELSETOK, 'ELSE');
  AddTokenSpelling(TTokenKind.WHILETOK, 'WHILE');
  AddTokenSpelling(TTokenKind.DOTOK, 'DO');
  AddTokenSpelling(TTokenKind.REPEATTOK, 'REPEAT');
  AddTokenSpelling(TTokenKind.UNTILTOK, 'UNTIL');
  AddTokenSpelling(TTokenKind.FORTOK, 'FOR');
  AddTokenSpelling(TTokenKind.TOTOK, 'TO');
  AddTokenSpelling(TTokenKind.DOWNTOTOK, 'DOWNTO');
  AddTokenSpelling(TTokenKind.ASSIGNTOK, ':=');
  AddTokenSpelling(TTokenKind.WRITETOK, 'WRITE');
  AddTokenSpelling(TTokenKind.WRITELNTOK, 'WRITELN');
  AddTokenSpelling(TTokenKind.SIZEOFTOK, 'SIZEOF');
  AddTokenSpelling(TTokenKind.LENGTHTOK, 'LENGTH');
  AddTokenSpelling(TTokenKind.HIGHTOK, 'HIGH');
  AddTokenSpelling(TTokenKind.LOWTOK, 'LOW');
  AddTokenSpelling(TTokenKind.INTTOK, 'INT');
  AddTokenSpelling(TTokenKind.FRACTOK, 'FRAC');
  AddTokenSpelling(TTokenKind.TRUNCTOK, 'TRUNC');
  AddTokenSpelling(TTokenKind.ROUNDTOK, 'ROUND');
  AddTokenSpelling(TTokenKind.ODDTOK, 'ODD');

  AddTokenSpelling(TTokenKind.READLNTOK, 'READLN');
  AddTokenSpelling(TTokenKind.HALTTOK, 'HALT');
  AddTokenSpelling(TTokenKind.BREAKTOK, 'BREAK');
  AddTokenSpelling(TTokenKind.CONTINUETOK, 'CONTINUE');
  AddTokenSpelling(TTokenKind.EXITTOK, 'EXIT');

  AddTokenSpelling(TTokenKind.SUCCTOK, 'SUCC');
  AddTokenSpelling(TTokenKind.PREDTOK, 'PRED');

  AddTokenSpelling(TTokenKind.INCTOK, 'INC');
  AddTokenSpelling(TTokenKind.DECTOK, 'DEC');
  AddTokenSpelling(TTokenKind.ORDTOK, 'ORD');
  AddTokenSpelling(TTokenKind.CHRTOK, 'CHR');
  AddTokenSpelling(TTokenKind.ASMTOK, 'ASM');
  AddTokenSpelling(TTokenKind.ABSOLUTETOK, 'ABSOLUTE');
  AddTokenSpelling(TTokenKind.USESTOK, 'USES');
  AddTokenSpelling(TTokenKind.LOTOK, 'LO');
  AddTokenSpelling(TTokenKind.HITOK, 'HI');
  AddTokenSpelling(TTokenKind.GETINTVECTOK, 'GETINTVEC');
  AddTokenSpelling(TTokenKind.SETINTVECTOK, 'SETINTVEC');
  AddTokenSpelling(TTokenKind.ARRAYTOK, 'ARRAY');
  AddTokenSpelling(TTokenKind.OFTOK, 'OF');
  AddTokenSpelling(TTokenKind.STRINGTOK, 'STRING');

  AddTokenSpelling(TTokenKind.RANGETOK, '..');

  AddTokenSpelling(TTokenKind.EQTOK, '=');
  AddTokenSpelling(TTokenKind.NETOK, '<>');
  AddTokenSpelling(TTokenKind.LTTOK, '<');
  AddTokenSpelling(TTokenKind.LETOK, '<=');
  AddTokenSpelling(TTokenKind.GTTOK, '>');
  AddTokenSpelling(TTokenKind.GETOK, '>=');

  AddTokenSpelling(TTokenKind.DOTTOK, '.');
  AddTokenSpelling(TTokenKind.COMMATOK, ',');
  AddTokenSpelling(TTokenKind.SEMICOLONTOK, ';');
  AddTokenSpelling(TTokenKind.OPARTOK, '(');
  AddTokenSpelling(TTokenKind.CPARTOK, ')');
  AddTokenSpelling(TTokenKind.DEREFERENCETOK, '^');
  AddTokenSpelling(TTokenKind.ADDRESSTOK, '@');
  AddTokenSpelling(TTokenKind.OBRACKETTOK, '[');
  AddTokenSpelling(TTokenKind.CBRACKETTOK, ']');
  AddTokenSpelling(TTokenKind.COLONTOK, ':');

  AddTokenSpelling(TTokenKind.PLUSTOK, '+');
  AddTokenSpelling(TTokenKind.MINUSTOK, '-');
  AddTokenSpelling(TTokenKind.MULTOK, '*');
  AddTokenSpelling(TTokenKind.DIVTOK, '/');
  AddTokenSpelling(TTokenKind.IDIVTOK, 'DIV');
  AddTokenSpelling(TTokenKind.MODTOK, 'MOD');
  AddTokenSpelling(TTokenKind.SHLTOK, 'SHL');
  AddTokenSpelling(TTokenKind.SHRTOK, 'SHR');
  AddTokenSpelling(TTokenKind.ORTOK, 'OR');
  AddTokenSpelling(TTokenKind.XORTOK, 'XOR');
  AddTokenSpelling(TTokenKind.ANDTOK, 'AND');
  AddTokenSpelling(TTokenKind.NOTTOK, 'NOT');

  AddTokenSpelling(TTokenKind.INTEGERTOK, 'INTEGER');
  AddTokenSpelling(TTokenKind.CARDINALTOK, 'CARDINAL');
  AddTokenSpelling(TTokenKind.SMALLINTTOK, 'SMALLINT');
  AddTokenSpelling(TTokenKind.SHORTINTTOK, 'SHORTINT');
  AddTokenSpelling(TTokenKind.WORDTOK, 'WORD');
  AddTokenSpelling(TTokenKind.BYTETOK, 'BYTE');
  AddTokenSpelling(TTokenKind.CHARTOK, 'CHAR');
  AddTokenSpelling(TTokenKind.BOOLEANTOK, 'BOOLEAN');
  AddTokenSpelling(TTokenKind.POINTERTOK, 'POINTER');
  AddTokenSpelling(TTokenKind.SHORTREALTOK, 'SHORTREAL');
  AddTokenSpelling(TTokenKind.REALTOK, 'REAL');
  AddTokenSpelling(TTokenKind.SINGLETOK, 'SINGLE');
  AddTokenSpelling(TTokenKind.HALFSINGLETOK, 'FLOAT16');
  AddTokenSpelling(TTokenKind.PCHARTOK, 'PCHAR');

  AddTokenSpelling(TTokenKind.SHORTSTRINGTOK, 'SHORTSTRING');
  AddTokenSpelling(TTokenKind.FLOATTOK, 'FLOAT');
  AddTokenSpelling(TTokenKind.TEXTTOK, 'TEXT');

end;

function GetTokenKindName(tokenKind: TTokenKind): String;
begin
  WriteStr(Result, tokenKind);
end;

function GetTokenSpelling(tokenKind: TTokenKind): String;
begin
  Result := TokenSpellings[tokenKind].Spelling;
end;

function GetHumanReadbleTokenSpelling(tokenKind: TTokenKind): String;
begin
  if (tokenKind > TTokenKind.UNTYPETOK) and (tokenKind < TTokenKind.IDENTTOK) then
    Result := GetTokenSpelling(tokenKind)
  else if tokenKind = TTokenKind.IDENTTOK then
    Result := 'identifier'
  else if (tokenKind = TTokenKind.INTNUMBERTOK) or (tokenKind = TTokenKind.FRACNUMBERTOK) then
    Result := 'number'
  else if (tokenKind = TTokenKind.CHARLITERALTOK) or (tokenKind = TTokenKind.STRINGLITERALTOK) then
    Result := 'literal'
  else if tokenKind = TTokenKind.UNITENDTOK then
    Result := 'END'
  else if tokenKind = TTokenKind.EOFTOK then
    Result := 'end of file'
  else
    Result := 'unknown token';
end;


function GetStandardToken(S: String): TTokenKind;
var
  i: TTokenKind;
begin
  Result := TTokenKind.UNTYPETOK;

  if (S = 'LONGWORD') or (S = 'DWORD') or (S = 'UINT32') then S := 'CARDINAL'
  else
  if (S = 'UINT16') then S := 'WORD'
  else
  if (S = 'LONGINT') then S := 'INTEGER';

  for i := Low(TTokenKind) to High(TTokenKind) do
    if S = TokenSpellings[i].spelling then
    begin
      Result := TokenSpellings[i].TokenKind;
      Break;
    end;
end;

procedure AssertTokenOrd(const tokenKind: TTokenKind; Value: Byte);
begin
  Assert(Ord(tokenKind) = Value, 'Token kind does not have expected value ' + IntToStr(Value) + '.');
end;

procedure AssertTokensOrd;
var
  tokenKind: TTokenKind;
var
  Value: Byte;
begin
  for tokenKind := Low(TTokenKind) to High(TTokenKind) do
  begin
    writeln('Token kind ', GetTokenKindName(tokenKind), ' = ', Ord(tokenKind), ' // ', GetTokenSpelling(tokenKind));
  end;
  // Assert order of constants that were marked as "Don't change".
  // TODO: Why? Where is this used?
  AssertTokenOrd(TTokenKind.UNTYPETOK, 0);
  AssertTokenOrd(TTokenKind.CONSTTOK, 1);
  AssertTokenOrd(TTokenKind.TYPETOK, 2);
  AssertTokenOrd(TTokenKind.VARTOK, 3);
  AssertTokenOrd(TTokenKind.PROCEDURETOK, 4);
  AssertTokenOrd(TTokenKind.FUNCTIONTOK, 5);
  AssertTokenOrd(TTokenKind.LABELTOK, 6);
  AssertTokenOrd(TTokenKind.UNITTOK, 7);

end;

initialization

  InitializeTokenSpellings;

end.
