unit cardlib;
interface
uses sysutils;
{$I defines.inc}

var
    kingdom: kingdomT;
    card: cardT;
    table: array[0..3] of word;

procedure InitHand;
procedure InitKingdom;

function NullTermToString(ptr: word): string;
function GetString (idx: byte): string;
function GetYear: byte;
function GetSeason: byte;
function PullCard(cardType: byte): word;
procedure ProcessCard(choice: byte);
procedure IncTime;
procedure NewTable(cardType: byte);
procedure PickCard(tablePos: byte);
procedure ReadCard(index: word);
procedure ChangeAndKeepAboveZero(value: smallIntPtr; amount: smallint; icon: byte);
function GetResourceChangeAmount(min, max: smallInt):smallInt;
procedure showRandomEvent;
procedure checkEnding;

implementation
var
        deck : deckT absolute CARDS_ADDRESS;
        cardAddress: word;
        hand : array [0..USER_DECK_SIZE] of byte;
        handIndex : word;

        strings : array [0..0] of word absolute STRINGS_ADDRESS;
        i,t,r : byte;
        sum: smallint;
        resourceChange : resourceChangeT;


// ************************************************ UTILS

function NullTermToString(ptr: word): string;
begin
    //Result:='                                                      ';
    Result[0] := Char(0);
    while Peek(ptr) <> 0 do begin
        Inc(Result[0]);
        Result[byte(Result[0])] := char(Peek(ptr));
        Inc(ptr);
    end;
    //Result[0]:=Char(10);
end;

function GetString(idx: byte): string;
begin
    Result := NullTermToString(strings[idx]);
end;

// ************************************************ HAND / TABLE

procedure InitHand;
begin
    FillChar(@hand, USER_DECK_SIZE, 255);
    for i:=0 to USER_DECK_SIZE-1 do begin
        repeat
            r := Random(USER_DECK_SIZE);
            if hand[r]=255 then begin
                hand[r] := i;
            end;

        until hand[r]=i;
    end;
    handIndex := 0;
end;

// ************************************************ CARD

function readResourceRow(changeFlags: byte;flag: byte;resPtr: pointer; offset:byte; size: byte): byte;
begin
    Result := 0;
    if (changeFlags AND flag) <> 0 then begin
        Move(pointer(word(cardAddress) + offset), resptr, size);
        Result := size;
    end;
end;

function readResourceChange(changeFlags: byte;resChange: pointer;offset : byte):byte;
begin
    Result := offset;
    FillChar(@resourceChange, SizeOf(resourceChange), 0);
    Inc(Result,readResourceRow(changeFlags, FLAG_MONEY, @resourceChange.moneyMin, Result, 4));
    Inc(Result,readResourceRow(changeFlags, FLAG_POPULATION, @resourceChange.populationMin, Result, 4));
    Inc(Result,readResourceRow(changeFlags, FLAG_ARMY, @resourceChange.armyMin, Result, 4));
    Inc(Result,readResourceRow(changeFlags, FLAG_HEALTH, @resourceChange.healthMin, Result, 2));
    Inc(Result,readResourceRow(changeFlags, FLAG_HAPPINES, @resourceChange.happinesMin, Result, 2));
    Inc(Result,readResourceRow(changeFlags, FLAG_CHURCH, @resourceChange.churchMin, Result, 2));
    Dec(Result,offset);
    Move(@resourceChange, resChange, SizeOf(resourceChange));
end;

function readRequirements(count: byte; reqPtr: pointer; offset: byte): byte;
begin
    Result:=0;
    FillChar(@reqPtr, SizeOf(requirementT) * REQ_MAX_NUM, 0);
    while count > 0 do begin
        Move(pointer(word(cardAddress) + offset + Result), pointer(word(reqPtr) + Result), sizeOf(requirementT));
        Inc(Result, sizeOf(requirementT));
        Dec(count);
    end;
end;

procedure readCardData;
var offset: byte;
begin
    Move(pointer(cardAddress), @card.cardtype, CARD_HEADER_DATA_SIZE);         // read header and process txt data
    card.imgPtr := Dpeek(card.actorPtr);

    offset := CARD_HEADER_DATA_SIZE;

    card.changeYesFlags := Peek(word(cardAddress) + offset);           // read resource change 4 yes
    Inc(offset);
    Inc(offset,readResourceChange(card.changeYesFlags, @card.resourceYes, offset));

    card.changeNoFlags := Peek(word(cardAddress) + offset);            // read reqource change 4 no
    Inc(offset);
    Inc(offset,readResourceChange(card.changeNoFlags, @card.resourceNo, offset));

    card.reqCount := Peek(word(cardAddress) + offset);                 // read requirements
    Inc(offset);
    Inc(offset,readRequirements(card.reqCount, @card.requirement1, offset));
end;

function CheckRequirement(req: requirementT): boolean;
var checkVal: smallInt;
begin
    Result := true;
    case req.required of
        1: checkVal := kingdom.resources.money;
        2: checkVal := kingdom.resources.population;
        3: checkVal := kingdom.resources.army;
        4: checkVal := kingdom.resources.health;
        5: checkVal := kingdom.resources.happines;
        6: checkVal := kingdom.resources.church;
        7: checkVal := GetYear;
    else
        Result := false;
    end;
    if Result then begin
        case req.how of
            0: Result := (checkVal = req.amount);
            1: Result := (checkVal > req.amount);
            2: Result := (checkVal < req.amount);
            3: Result := (checkVal >= req.amount);
            4: Result := (checkVal <= req.amount);
        else
            Result := false;
        end;
    end;
end;

function IsCardValid(cardType: byte): boolean;
begin
    Result := true;
    if card.reqCount > 0 then begin
        Result := CheckRequirement(card.requirement1);
    end;
    if Result = true and (card.reqCount > 1) then begin
        Result := CheckRequirement(card.requirement2);
    end;
end;

procedure ReadCard(index: word);
begin
    cardAddress := deck[index];
    ReadCardData;
end;

function PullCard(cardType: byte): word;
begin
    repeat
        Result := hand[handIndex];
        Inc(handIndex);
        if handIndex = USER_DECK_SIZE then InitHand;
        ReadCard(Result);
    until isCardValid(cardType);
end;

procedure NewTable(cardType: byte);
begin
    for t:=0 to 3 do
        table[t] := PullCard(cardType);
end;

procedure PickCard(tablePos: byte);
begin
    ReadCard(table[tablePos]);
    table[tablePos]:= EMPTY_TABLE_SLOT;
end;

// ************************************************ KINGDOM

procedure InitKingdom;
begin
    kingdom.kingdomName := getString(10);
    kingdom.kingAlive := true;
    kingdom.time := 0;
    kingdom.resources.money := 1000;
    kingdom.resources.population := 1000;
    kingdom.resources.army := 50;
    kingdom.resources.health := 100;
    kingdom.resources.happines := 50;
    kingdom.resources.church := 50;
    kingdom.tax := 10;
    kingdom.salary := 1;
    kingdom.ending := 0;
    kingdom.child := -1;
end;

procedure setEnding(ending:byte);
begin
        kingdom.kingAlive:=false;
        kingdom.ending:=ending;
end;

procedure checkEnding;
begin
    if kingdom.resources.money<=0 then setEnding(33);
    if kingdom.resources.health<=0 then setEnding(34);
    if kingdom.resources.happines<=0 then setEnding(35);
    if kingdom.resources.army<=0 then setEnding(51);
end;

// ************************************************ CHANGE RESOURCES

procedure InsertChar(ch: char); overload;
begin
    Inc(kingdom.income[0]);
    kingdom.income[byte(kingdom.income[0])] := ch;
end;

procedure ShowChange(icon: char; amount: smallint);
begin
    InsertChar(icon);
    InsertChar(char(ICON_DELIMITER));
    if amount>0 then InsertChar('+');
    kingdom.income := Concat(kingdom.income, IntToStr(amount));
    InsertChar(' ');
end;

procedure ChangeAndKeepAboveZero(value: smallIntPtr; amount: smallint; icon: byte);
begin
    sum := value^ + amount;
    if sum < 0 then sum := 0;
    value^ := sum;
    ShowChange(Char(icon), amount);
end;

procedure ChangeAndKeepInHundred(value: shortIntPtr; amount: smallint; icon: byte);
begin
    sum := value^ + amount;
    if sum < 0 then sum := 0;
    if sum > 100 then sum := 100;
    value^ := sum;
    ShowChange(Char(icon), amount);
end;

function GetResourceChangeAmount(min, max: smallInt):smallInt;
begin
    Result := 0;
    if (min <> 0) or (max <> 0) then
        if min = max then // constant amount
            Result := min
        else              // range amount
            if min<max then
                Result := min + Random(smallint(1+max-min))
            else
                Result := max + Random(smallint(1+min-max))
end;

procedure showRandomEvent;
var event:byte;
    amount:smallInt;
    amount2:smallInt;
begin
    event:=Random(20);
    case event of
        1 : begin                       // spadek
            amount:=GetResourceChangeAmount(200,400);
            Writeln(GetString(39),amount,char(ICON_MONEY));
            ChangeAndKeepAboveZero(@kingdom.resources.money, amount, ICON_MONEY);
        end;
        2 : begin                       // wydatki
            amount:=GetResourceChangeAmount(-50,-100);
            Writeln(GetString(40),amount,char(ICON_MONEY));
            ChangeAndKeepAboveZero(@kingdom.resources.money, amount, ICON_MONEY);
        end;
        3 : begin                       // boom urodzen
            amount:=GetResourceChangeAmount(20,50);
            Writeln(GetString(41),amount,char(ICON_POPULATION));
            ChangeAndKeepAboveZero(@kingdom.resources.population, amount, ICON_POPULATION);
        end;
        4 : begin                       // czarna ospa
            amount:=GetResourceChangeAmount(-100,-300);
            Writeln(GetString(42),amount,char(ICON_POPULATION));
            ChangeAndKeepAboveZero(@kingdom.resources.population, amount, ICON_POPULATION);
        end;
        5 : begin                       // prorok
            amount:=GetResourceChangeAmount(10,20);
            Writeln(GetString(43),amount,char(ICON_CHURCH));
            ChangeAndKeepInHundred(@kingdom.resources.church, amount, ICON_CHURCH);
        end;
        6 : begin                       // inkwizycja
            amount:=GetResourceChangeAmount(-10,-20);
            Writeln(GetString(44),amount,char(ICON_CHURCH));
            ChangeAndKeepInHundred(@kingdom.resources.church, amount, ICON_CHURCH);
        end;
        7 : begin                       // nowe szlaki
            amount:=GetResourceChangeAmount(100,300);
            amount2:=GetResourceChangeAmount(50,200);
            Writeln(GetString(45),amount,char(ICON_MONEY),' ',amount2,char(ICON_POPULATION));
            ChangeAndKeepAboveZero(@kingdom.resources.money, amount, ICON_MONEY);
            ChangeAndKeepAboveZero(@kingdom.resources.population, amount2, ICON_POPULATION);
        end;
        8 : begin                       // dezercja
            amount:=GetResourceChangeAmount(-10,-20);
            Writeln(GetString(46),amount,char(ICON_ARMY));
            ChangeAndKeepAboveZero(@kingdom.resources.army, amount, ICON_ARMY);
        end;
        9 : begin                       // slub
            if kingdom.child=-1 then begin
                kingdom.child:=0;
                amount:=GetResourceChangeAmount(5,10);
                Writeln(GetString(47),amount,char(ICON_HAPPINES));
                ChangeAndKeepInHundred(@kingdom.resources.happines, amount, ICON_HAPPINES);
            end else Writeln(Space(17),'brak');
        end;
        10 : begin                      // dziecko
            if kingdom.child>-1 then begin
                Inc(kingdom.child);
                amount:=GetResourceChangeAmount(5,10);
                Writeln(GetString(48),amount,char(ICON_HAPPINES));
                ChangeAndKeepInHundred(@kingdom.resources.happines, amount, ICON_HAPPINES);
            end else  Writeln(Space(17),'brak');
        end;
        11 : begin                      // choroba
            amount:=GetResourceChangeAmount(-5,-20);
            Writeln(GetString(49),amount,char(ICON_HEALTH));
            ChangeAndKeepInHundred(@kingdom.resources.health, amount, ICON_HEALTH);
        end;
        12 : begin                      // leczenie
            amount:=GetResourceChangeAmount(5,20);
            Writeln(GetString(50),amount,char(ICON_HEALTH));
            ChangeAndKeepInHundred(@kingdom.resources.health, amount, ICON_HEALTH);
        end;

        else Writeln(Space(17),'brak');
    end;
end;

// ************************************************ PROCESS CARD

procedure ProcesResourceInt(min, max: smallInt; value: smallIntPtr; icon: byte);
var amount: smallint;
begin
    amount := GetResourceChangeAmount(min, max);
    if amount <> 0 then
        ChangeAndKeepAboveZero(value, amount, icon);
end;

procedure ProcesResourceByte(min, max: smallInt; value: shortIntPtr; icon: byte);
var amount: smallint;
begin
    amount := GetResourceChangeAmount(min, max);
    if amount <> 0 then
        changeAndKeepInHundred(value, amount, icon);
end;

procedure ProcessResourceCard(choice: byte);
begin
    kingdom.income := '';
    if choice = CHOICE_NO Then
        resourceChange := card.resourceNo
    else
        resourceChange := card.resourceYes;
    // money
    ProcesResourceInt(resourceChange.moneyMin, resourceChange.moneyMax, @kingdom.resources.money, ICON_MONEY);
    // population
    ProcesResourceInt(resourceChange.populationMin, resourceChange.populationMax, @kingdom.resources.population, ICON_POPULATION);
    // army
    ProcesResourceInt(resourceChange.armyMin, resourceChange.armyMax, @kingdom.resources.army, ICON_ARMY);
    // health
    ProcesResourceByte(resourceChange.healthMin, resourceChange.healthMax, @kingdom.resources.health, ICON_HEALTH);
    // happines
    ProcesResourceByte(resourceChange.happinesMin, resourceChange.happinesMax, @kingdom.resources.happines, ICON_HAPPINES);
    // church
    ProcesResourceByte(resourceChange.churchMin, resourceChange.churchMax, @kingdom.resources.church, ICON_CHURCH);
end;

procedure ProcessCard(choice: byte); // 1:YES 0:NO
begin
    case card.cardtype of
        0: ProcessResourceCard(choice);
    end;
end;

// ************************************************ TIME

function GetYear: byte;
begin
    Result := ( kingdom.time div 4 ) + 1;
end;

function GetSeason: byte;
begin
    Result := kingdom.time mod 4;
end;

procedure IncTime;
begin
    Inc(kingdom.time);
    changeAndKeepInHundred(@kingdom.resources.health, -1, ICON_HEALTH);
end;

end.

