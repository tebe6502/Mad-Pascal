{$r lang_pl.rc}

const
    monsters: array [0..MONSTERS_COUNT - 1] of TString = (
        'NIETOPERZ', // 0
        'SZCZUR',
        'JASZCZUR',
        'PAJ'#2'K',
        'PIES',
        'W'#2#21,
        'KRONK',
        'SKRZAT',
        'GOBLIN',
        'ZOOMBIE',
        'WARG',     // 10
        'DUCH',
        'ELF',
        'WILKO'#12'AK',
        'CZAROWNICA',
        'ORK',
        'GARGOYLA',
        'TROLL',
        'CZAROWNIK',
        'WAMPIR',
        'UPI'#15'R', // 20
        'MINOTAUR',
        'CYKLOP',
        'GIGANT',
        'HYDRA',
        'DEMON',
        'MEDUZA',
        'SMOK',
        'DIABE'#12,
        'FENIKS'
    );
    weapons: array [0..WEAPONS_COUNT - 1] of TString = (
        'WIDELEC',
        'SCYZORYK',
        'FINK'#11,
        'SZTYLET',
        'SZPAD'#11,
        'LANC'#11,
        'OSZCZEP',
        'SZABL'#11,
        'TOP'#15'R',
        'MIECZ' 
    );
    treasures: array [0..TREASURES_COUNT - 1] of TString = (
        'BR'#2'Z',
        'SREBRO',
        'Z'#12'OTO',
        'PLATYN'#11,
        'DIAMENTY' 
    );
    items: array [0..ITEMS_COUNT - 1] of TString = (        
        'M'#12'OTEK',
        'KAGANEK',
        'KLUCZ',
        'DESK'#11,
        'PROWIANT',
        'NAPOJE',
        'BANDA'#21,
        #12'UBKI',
        'HAS'#12'O' 
    );
    itemSymbols: array [0..ITEMS_COUNT - 2] of char = ( 'M', 'G', 'K', 'D', 'P', 'N', 'B', 'L');
    passwords: array [0..PASSWORDS_COUNT - 1] of TString = ('RYBA','JAJO','BAJT','TRZY','KLAN','KREW','MYSZ','KLOC','BICZ');

const
    k_YES = byte('T');
    k_NO = byte('N');
    k_LEFT = byte('L');
    k_RIGHT = byte('P');
    k_UP = byte('G');
    k_DOWN = byte('D');
    k_FIGHT = byte('W');
    k_RANSOM = byte('O');
    k_TAKE = byte('B');
    k_LEAVE = byte('Z');
    k_REST = byte('C');
    k_MOVE = byte('R');
    k_BANDAGE = byte('B');
    k_MEDKIT = byte('L');
    s_PRESS_ANY: string = 'NACI'#9'NIJ DOWOLNY KLAWISZ';
    s_WANT_MANUAL: string = '   CZY CHCESZ INSTRUKCJE ? (T/N)';
    s_ENERGY: string = 'ENERGIA'*;
    s_TREASURE: string = 'SKARBY'*;
    s_MOVES: string = 'RUCHY'*;
    s_WOUNDS: string = 'RANY'*;
    s_ITEMS: string = 'OBIEKTY'*;
    s_WEAPON: string = 'JAK'*#130' BRO'*#142' MASZ'*;
    s_ATTACK: string = 'SI'*#140'A'*;
    s_FOUND: string = 'ZNALAZ'#12'E'#9' ';
    s_TAKE: string = 'B'*'IERZESZ';
    s_OR: string = ' CZY ';
    s_LEAVE: string = 'Z'*'OSTAWIASZ';
    s_FOUND_PASS: string = 'ZNALAZ'#12'E'#9' HAS'#12'O, BRZMI ONO ';
    s_REMEMBER: string = 'ZAPAMI'#11'TAJ JE.';
    s_LEAVE_WHAT: string = 'CO CHCESZ ZOSTAWI'#96' ?       ';
    s_DONT_HAVE: string = 'NIE MASZ ';
    s_WAIT: string = 'C'*'ZEKANIE';
    s_MOVE: string = 'R'*'UCH';
    s_LEFT: string = 'L'*'EWO';
    s_RIGHT: string = 'P'*'RAWO';
    s_UP: string = 'G'*#15'RA';
    s_DOWN: string = 'D'*#15#12;
    s_DROPPED: string = 'WI'#11'C WYRZUCI'#12'E'#9'.';
    s_USED: string = 'U'#21'Y'#12'E'#9' ';
    s_ATTACKED: string = 'ZAATAKOWA'#12;
    s_DOOR_OPENED: string = 'OTWARTE DRZWI, PRZECHODZISZ.';
    s_DOOR_CLOSED: string = 'ZAMKNI'#11'TE DRZWI, ';
    s_KEY: string = 'KLUCZ';
    s_BYKEY: string = 'KLUCZA';
    s_WALL: string = 'CIENKA '#9'CIANKA, ';
    s_HAMMER: string = 'M'#12'OTEK';
    s_BYHAMMER: string = 'M'#12'OTKA';
    s_ROOM_DARK: string = 'W POKOJU JEST CIEMNO,';
    s_LANTERN: string = 'KAGANEK';
    s_BYLANTERN: string = 'KAGANKA';
    s_ROOM_HOLE: string = 'W POKOJU NIE MA POD'#12'OGI,';
    s_PLANK: string = 'DESK'#11;
    s_BYPLANK: string = 'DESKI';
    s_EXIT_PASS: string = 'OSI'#2'GN'#2#12'E'#9' WYJ'#9'CIE, PODAJ HAS'#12'O.';
    s_EXIT_PAY: string = 'DZI'#11'KUJ'#11', TERAZ PROSZ'#11' ZAP'#12'ACI'#96;
    s_EXIT_LEAVE: string = 'OPU'#9'CI'#12'E'#9' STARY DOM. WYNIOS'#12'E'#9' ';
    s_EXIT_SCORE: string = ' NA PAMI'#2'TK'#11'. WYNIK=';
    s_EXIT_POOR: string = 'OO! MASZ ZA MA'#12'O PIENI'#11'DZY.';
    s_EXIT_FATAL: string = 'STRA'#21'NIK UCINA CI G'#12'OW'#11'.';
    s_EXIT_WRONG_PASS: string = #6'LE! HAS'#12'EM BY'#12'O ';
    s_BUMP: string = 'MUR, UDERZY'#12'E'#9' SI'#11' W NOS.';
    s_NO_PASARAN: string = 'T'#11'DY NIE PRZEJDZIESZ.';
    s_BACK_TO_START: string = 'ZOSTA'#12'E'#9' PRZENIESIONY NA START.';
    s_ITEM_BROKE: array [0..7] of string = ( 
        'M'#12'OTEK SI'#11' Z'#12'AMA'#12', ',
        'W KAGANKU SKO'#14'CZY'#12'A SI'#11' OLIWA, ',
        'KLUCZ JEST OD FORTEPIANU, ',
        'W DESCE S'#2' KORNIKI, ',
        'PROWIANT ZEPSU'#12' SI'#11', ',
        'NAP'#15'J JEST ST'#11'CH'#12'Y, ',
        'BANDA'#21' PODAR'#12' SI'#11', ',
        #12'UBKI Z'#12'AMA'#12'Y SI'#11', '
    );
    s_BROKE: string = 'Z'#12'AMA'#12'E'#9' ';
    s_YOU_M: string = ' CI'#11' ';
    s_YOU_F: string = 'A CI'#11' ';
    s_MONSTER_STR: string = 'SI'#12'A ';
    s_TOO_WEAK_POOR: string = 'JESTE'#9' ZA S'#12'ABY I NIE MASZ Z'#12'OTA';
    s_TOO_WEAK: string = 'JESTE'#9' ZA S'#12'ABY, P'#12'A'#96' OKUP';
    s_TOO_POOR: string = 'BRAK Z'#12'OTA, MUSISZ WALCZY'#96'.';
    s_FIGHT: string = 'W'*'ALKA';
    s_RANSOM: string = 'O'*'KUP';
    s_HAS_BEEN: string = ' ZOSTA'#12;
    s_DEFEATED_F: string = 'A POKONANA, ';
    s_DEFEATED_M: string = ' POKONANY, ';
    s_EARNED: string = 'ZDOBY'#12'E'#9' ';
    s_HAS_STR: string = ' MA SI'#12#11' ';
    s_WANNA_USE: string = 'CHCESZ U'#21'YC JAKIEGO'#9' OBIEKTU (T/N)?';
    s_WHICH: string = 'KT'#15'REGO ?      ';
    s_CAN_USE_ONLY: string = 'TERAZ MO'#21'ESZ U'#21'Y'#96' TYLKO ';
    s_AND: string = 'I ';
    
    
function needPostfix(monster: byte): boolean;
begin
    result := (monster = 14) or (monster = 16) or (monster = 26) or (monster = 24);
end;

procedure ManualPage1;
begin
    Writeln;
    Writeln;
    Writeln(' Znalaz'#123'e'#10' si'#20' nagle w starym domu,   z kt'#16'rego musisz si'#20' wydosta'#22'.');
    Writeln('Jest tu tylko jedno wyj'#10'cie i jest    ono strze'#21'one. Stra'#21'nik wypu'#10'ci ci'#20',');
    Writeln('je'#10'li podasz has'#123'o i zap'#123'acisz 100 $.');
    Writeln;
    Writeln(' Musisz zbiera',#22,' pieni',#8,'dze (w formie');
    Writeln('skarb'#16'w), kt'#16're s'#8' w'#123'asno'#10'ci'#8' potwo-  r'#16'w zamieszkuj'#8'cych dom. Mo'#21'esz z');
    Writeln('nimi walczy'#22', je'#10'li masz mniej ni'#21'    5 ran i si'#123''#20' wi'#20'ksz'#8' od zera.');
    Writeln;
    Writeln(' Mo'#21'esz zwi'#20'kszy'#22' swoj'#8' energi'#20', gdy  znajdziesz lub kupisz prowiant lub');
    Writeln('napoje. Rany mo'#21'esz leczy'#22' '#123'ubkami    lub banda'#21'ami.');
end;
    
procedure ManualPage2;
begin
    Writeln;
    Writeln(' Je'#21'eli nie mo'#21'esz walczy'#22', to musisz zap'#123'aci'#22' potworowi za wypuszczenie.');
    Writeln;
    Writeln(' Has'#123'o znajdziesz w domu. Musisz je   dobrze zapami'#20'ta'#22'.');
    Writeln;
    Writeln;
    Writeln(' Dom jest bardzo stary. W niekt'#16'rych  pokojach jest ciemno, w innych nie');
    Writeln('ma pod'#123'ogi. Mo',#21,'esz tak'#21'e napotka'#22'');
    Writeln('zamkni'#20'te drzwi lub cienkie '#10'cianki.');
    Writeln('Dlatego zbieraj napotkane przedmioty, ale pami'#20'taj, '#21'e mo'#21'esz jednocze'#10'nie');
    Writeln('nie'#10#22' tylko cztery przedmioty i jed-  n'#8' bro'#13'. Wybieraj zawsze najlepsz'#8'');
    Writeln('bro'#13'; zale'#21'y od tego twoja si'#123'a oraz  wielko'#10#22' zdobywanych skarb'#16'w.');
end;
    
procedure ManualPage3;
begin
    Writeln;
    Writeln('           SKR'#15'TY:');
    Writeln;
    Print(char(TILE_EXIT),char(TILE_EXIT-1)); Writeln(' - wyj'#10'cie');
    Print(char(TILE_DARK)); Writeln(' - ciemno');
    Print(char(TILE_HOLE)); Writeln(' - brak pod'#123'ogi');
    Print(char(TILE_DOOR_H), #32); Print(char(TILE_DOOR_V)); Writeln( ' - zamkni'#20'te drzwi');
    Print(char(TILE_WALL_H), #32); Print(char(TILE_WALL_V)); Writeln( ' - cienka '#10'cianka');
    Writeln('M - m'#123'otek');
    Writeln('G - kaganek');
    Writeln('K - klucz');
    Writeln('D - deska');
    Writeln('B - banda'#21'e');
    Writeln('L - '#123'ubki');
    Writeln(TILE_PLAYER,' - a to jeste'#10' TY');
end;
