unit Tokens;

interface

uses DataTypes;

// The RESERVED_... values are placeholders for compatibility with previous versions.
// This ensures the existing values are stable when new constants are defined for the existing logical blocks.
// It is important to have 100% the same output in the A65 files.
type
  TTokenKind = (
      {$I 'Tokens.inc'}
    );

function GetTokenKindName(const tokenKind: TTokenKind): String;
function GetTokenSpelling(const tokenKind: TTokenKind): String;
function GetHumanReadbleTokenSpelling(const tokenKind: TTokenKind): String;
function GetTokenDataType(const tokenKind: TTokenKind): TDataType;

function InfoAboutToken(const t: TTokenKind): String; // TODO: What's the difference to GetTokenSpelling
function InfoAboutDataType(const dataType: TDataType): String;

function GetStandardToken(const S: String): TTokenKind;




implementation

uses SysUtils, Generics.Collections;

type
  TTokenSpelling = record
    tokenKind: TTokenKind;
    spelling: String;
  end;

  TTokenSpellingArray = array [Low(TTokenKind)..High(TTokenKind)] of TTokenSpelling;

var
  TokenSpellingArray: TTokenSpellingArray;

type
  TTokenSpellingMap = TDictionary<String, TTokenKind>;

  var TokenSpellingMap : TTokenSpellingMap;

procedure AddTokenSpelling(t: TTokenKind; s: String);
var
  tokenSpelling: TTokenSpelling;
begin
  tokenSpelling.TokenKind := t;
  tokenSpelling.Spelling := s;

  TokenSpellingArray[tokenSpelling.TokenKind] := tokenSpelling;
  TokenSpellingMap.Add( s,t);
end;

procedure InitializeTokenSpellings;
begin

  TokenSpellingMap  :=TTokenSpellingMap.Create;
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
  AddTokenSpelling(TTokenKind.WITHTOK, 'WITH');
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

  // Add direct mappings for aliases
  TokenSpellingMap.Add( 'DWORD',TTokenKind.CARDINALTOK);
  TokenSpellingMap.Add( 'LONGWORD',TTokenKind.CARDINALTOK);
  TokenSpellingMap.Add( 'UINT32',TTokenKind.CARDINALTOK);
  TokenSpellingMap.Add( 'UINT16',TTokenKind.WORDTOK);
  TokenSpellingMap.Add( 'LONGINT',TTokenKind.INTEGERTOK);
end;

function GetTokenKindName(const tokenKind: TTokenKind): String;
begin
  WriteStr(Result, tokenKind);
end;

function GetTokenSpelling(const tokenKind: TTokenKind): String;
begin
  Result := TokenSpellingArray[tokenKind].Spelling;
end;

function GetHumanReadbleTokenSpelling(const tokenKind: TTokenKind): String;
begin
  if tokenKind = TTokenKind.UNTYPETOK then
    Result := 'untyped token'
  else if (tokenKind > TTokenKind.UNTYPETOK) and (tokenKind < TTokenKind.IDENTTOK) then
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

function InfoAboutToken(const t: TTokenKind): String;
begin

  case t of

    TTokenKind.EQTOK: Result := '=';
    TTokenKind.NETOK: Result := '<>';
    TTokenKind.LTTOK: Result := '<';
    TTokenKind.LETOK: Result := '<=';
    TTokenKind.GTTOK: Result := '>';
    TTokenKind.GETOK: Result := '>=';

    TTokenKind.INTOK: Result := 'IN';

    TTokenKind.DOTTOK: Result := '.';
    TTokenKind.COMMATOK: Result := ',';
    TTokenKind.SEMICOLONTOK: Result := ';';
    TTokenKind.OPARTOK: Result := '(';
    TTokenKind.CPARTOK: Result := ')';
    TTokenKind.DEREFERENCETOK: Result := '^';
    TTokenKind.ADDRESSTOK: Result := '@';
    TTokenKind.OBRACKETTOK: Result := '[';
    TTokenKind.CBRACKETTOK: Result := ']';
    TTokenKind.COLONTOK: Result := ':';
    TTokenKind.PLUSTOK: Result := '+';
    TTokenKind.MINUSTOK: Result := '-';
    TTokenKind.MULTOK: Result := '*';
    TTokenKind.DIVTOK: Result := '/';

    TTokenKind.IDIVTOK: Result := 'DIV';
    TTokenKind.MODTOK: Result := 'MOD';
    TTokenKind.SHLTOK: Result := 'SHL';
    TTokenKind.SHRTOK: Result := 'SHR';
    TTokenKind.ORTOK: Result := 'OR';
    TTokenKind.XORTOK: Result := 'XOR';
    TTokenKind.ANDTOK: Result := 'AND';
    TTokenKind.NOTTOK: Result := 'NOT';
    TTokenKind.CONSTTOK: Result := 'CONST';
    TTokenKind.TYPETOK: Result := 'TYPE';
    TTokenKind.VARTOK: Result := 'VARIABLE';
    TTokenKind.PROCEDURETOK: Result := 'PROCEDURE';
    TTokenKind.FUNCTIONTOK: Result := 'FUNCTION';
    TTokenKind.CONSTRUCTORTOK: Result := 'CONSTRUCTOR';
    TTokenKind.DESTRUCTORTOK: Result := 'DESTRUCTOR';

    TTokenKind.LABELTOK: Result := 'LABEL';
    TTokenKind.UNITTOK: Result := 'UNIT';
    TTokenKind.ENUMTOK: Result := 'ENUM';

    TTokenKind.RECORDTOK: Result := 'RECORD';
    TTokenKind.OBJECTTOK: Result := 'OBJECT';
    TTokenKind.BYTETOK: Result := 'BYTE';
    TTokenKind.SHORTINTTOK: Result := 'SHORTINT';
    TTokenKind.CHARTOK: Result := 'CHAR';
    TTokenKind.BOOLEANTOK: Result := 'BOOLEAN';
    TTokenKind.WORDTOK: Result := 'WORD';
    TTokenKind.SMALLINTTOK: Result := 'SMALLINT';
    TTokenKind.CARDINALTOK: Result := 'CARDINAL';
    TTokenKind.INTEGERTOK: Result := 'INTEGER';
    TTokenKind.POINTERTOK,
    TTokenKind.DATAORIGINOFFSET,
    TTokenKind.CODEORIGINOFFSET: Result := 'POINTER';

    TTokenKind.PROCVARTOK: Result := '<Procedure Variable>';

    TTokenKind.STRINGPOINTERTOK: Result := 'STRING';

    TTokenKind.STRINGLITERALTOK: Result := 'literal';

    TTokenKind.SHORTREALTOK: Result := 'SHORTREAL';
    TTokenKind.REALTOK: Result := 'REAL';
    TTokenKind.SINGLETOK: Result := 'SINGLE';
    TTokenKind.HALFSINGLETOK: Result := 'FLOAT16';
    TTokenKind.SETTOK: Result := 'SET';
    TTokenKind.FILETOK: Result := 'FILE';
    TTokenKind.TEXTFILETOK: Result := 'TEXTFILE';
    TTokenKind.PCHARTOK: Result := 'PCHAR';

    TTokenKind.SUBRANGETYPE: Result := 'SUBRANGE';

    TTokenKind.REGISTERTOK: Result := 'REGISTER';
    TTokenKind.PASCALTOK: Result := 'PASCAL';
    TTokenKind.STDCALLTOK: Result := 'STDCALL';
    TTokenKind.INLINETOK: Result := 'INLINE';
    TTokenKind.ASMTOK: Result := 'ASM';
    TTokenKind.INTERRUPTTOK: Result := 'INTERRUPT';

    else
      Result := 'UNTYPED'
  end;

end;


function GetStandardToken(const S: String): TTokenKind;
begin
  if not TokenSpellingMap.TryGetValue(s,Result) then Result:= TTokenKind.UNTYPETOK;
end;

procedure AssertTokenOrd(const tokenKind: TTokenKind; Value: Byte);
begin
  Assert(Ord(tokenKind) = Value, 'Token kind does not have expected value ' + IntToStr(Value) + '.');
end;

procedure AssertTokensOrd;
var
  tokenKind: TTokenKind;
begin
  for tokenKind := Low(TTokenKind) to High(TTokenKind) do
  begin
    // writeln('Token kind ', GetTokenKindName(tokenKind), ' = ', Ord(tokenKind), ' // ', GetTokenSpelling(tokenKind));
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


function GetTokenDataType(const tokenKind: TTokenKind): TDataType;
begin
  // TODO: Validate that is actually can be cast.
  Result:=TDataType(Ord(tokenKind));
end;

function InfoAboutDataType(const dataType: TDataType): String;
begin
  result:=InfoAboutToken(TTokenKind(Ord(dataType)));
end;

initialization

  InitializeTokenSpellings;
  AssertTokensOrd;

end.
