program jcq;
uses atari, crt, rmt;
const
    CHARSET_ADDRESS = $6000;
    CHARSET_ADDRESS_PL = $6400;
    RMT_PLAYER_ADDRESS = $7000;
    RMT_MODULE_ADDRESS = $7800;
    
{$r resources.rc}
{$i bigtxt.inc}

const
    CYTRYNOWKA = 0;
    DRES = 1;
    SZLUGI = 2;
    NUMERJESSICA = 3;
    WPIERDOL = 4;
    SOLUX = 5;
    KLUCZYKI = 6;
    HARNAS = 7;
    SHOT = 8;
    SZCZOTKA = 9;
    BILET = 10;
    MAJTY = 11;
    REKLAMOWKA = 12;
    CZEKAJ = 13;
    ZDJECIEMJ = 14;

    ITEMSNUM = 16;

var
    items: array [0..ITEMSNUM] of byte;
    i, gameover, loc: byte;
    c: char;
    msx: TRMT;

procedure vbl;interrupt;
begin
asm { phr ; store registers };
    msx.Play;
asm {
    plr ; restore registers
    jmp $E462 ; jump to system VBL handler
    };
end;

procedure Lokalizacja(s:string);
begin
    Writeln('Lokalizacja: ',s);
    Writeln;
end;

procedure Any;
begin
    Writeln;
    Writeln('NACISNIJ SPACJE...'*);
    ReadKey;
end;

procedure InitGame;
begin
    chbas:=Hi(CHARSET_ADDRESS);
    for i:=0 to ITEMSNUM do items[i]:=0;
    gameover:=0;
end;

procedure TitleScreen;
begin
    ClrScr;
    putString(2,2,'JASKINIA');
    putString(22,8,'CITY');
    putString(7,14,'QUEST');
    Gotoxy(9,21);
    Write('PARA-GRA NIETOWARZYSKA');
    Gotoxy(2,24);
    Write('Kod:bocianu  Msx:LiSU  GRAWITACJA 2019');
    Readkey;
end;

procedure GameOverScreen;
begin
    ClrScr;
    chbas:=Hi(CHARSET_ADDRESS);
    putString(0,6,'GAMEOVER');
    Gotoxy(17,14);
    if gameover = 1 then Writeln('Wygra$e%!')
        else Writeln('Przegrales');
    Readkey;
end;        

begin
    msx.player := pointer(RMT_PLAYER_ADDRESS);
    msx.modul := pointer(RMT_MODULE_ADDRESS);
    msx.Init(0);
    SetIntVec(iVBL,@vbl);
    CursorOff;
    lmargin:=0;
    color2:=0;

    repeat 
        InitGame;
        TitleScreen;
        loc:=0;  
     
        repeat 
            ClrScr;
            case loc of
                0: begin
                    Lokalizacja('chata Twojej starej');
                    Writeln('Obudziles sie rano bez polskich liter');
                    Writeln('i zupelnie zdezorientowany postanowiles');
                    Writeln('poszukac zaginionych znakow');
                    Writeln('diakrytycznych.');
                    Writeln;
                    Writeln('A'*,' - wyjdz z chaty');
                    c:=ReadKey;
                    loc:=1;
                end;
                1: begin
                    Lokalizacja('przedblocze');
                    Writeln('Przed blokiem troche pizga i lekko');
                    Writeln('zalatuje nadciagajaca wiosna.');
                    Writeln('Psie gowna wystawiaja spod sniegu');
                    Writeln('swoje smutne, brunatne oblicza.');
                    Writeln;
                    Writeln('Rozgladasz sie wokol, ale nigdzie nie');
                    Writeln('ma zaginionych ogonkow. Za to nieopodal');
                    Writeln('pobliskiej zabki, w miejscu gdzie stal');
                    Writeln('kiedys passat sasiada, widac wejscie do');
                    Writeln('tajemniczej jaskini.');
                    
                    Writeln;
                    Writeln('A'*,' - idz do miasta');
                    Writeln('B'*,' - idz do jaskini');
                    Writeln('C'*,' - idz do zabki');
                    c:=ReadKey;
                    if c='a' then loc:=2;
                    if c='b' then loc:=3;
                    if c='c' then loc:=4;
                end;
                2: begin
                    Lokalizacja('osiedle, przystanek');
                    Writeln('Na przystanku - jak zazwyczaj - spi pan');
                    Writeln('Mirek zul. Czuc od niego won pizma');
                    Writeln('i cytrynowki lubelskiej.');
                    Writeln;
                    if items[DRES]=0 then Writeln('A'*,' - obudz pana Mirka');
                    Writeln('B'*,' - czekaj na autobus');
                    Writeln('C'*,' - idz pod blok');
                    c:=ReadKey;
                    if (c='a') and (items[DRES]=0) then begin
                        if items[CYTRYNOWKA]>0 then loc:=6
                        else begin
                            Writeln;
                            Writeln('Pan Mirek nawet nie drgnie.');
                            Writeln('Moze potrzebny jest jakis argument?');
                            Any;
                        end;
                    end;
                    if c='b' then loc:=5;
                    if c='c' then loc:=1;
                    
                end;
                3: begin
                    Lokalizacja('jaskinia, wejscie');
                    if items[SOLUX] = 0 then begin
                        Writeln('W jaskini jest ciemno jak w lisiej...');
                        Writeln('norze. Boisz sie isc dalej, bo od');
                        Writeln('dziecka przerazala Cie ciemnosc.');
                        Any;
                        loc:=1;
                    end else begin
                        Writeln('Rozswietliles ciemnosc lampa solux.');
                        Writeln('W jednym kacie jaskini widzisz stara,');
                        Writeln('okuta zelazem skrzynie, w drugim');
                        Writeln('stoi zakurzony passat, sasiada.');
                        Writeln('Pewnie nie zauwazyl i zaparkowal tam');
                        Writeln('gdzie zwykle.');
                        Writeln;
                        Writeln('A'*,' - otworz skrzynie');
                        Writeln('B'*,' - otworz passata');
                        Writeln('C'*,' - wyjdz z jaskini');
                        c:=ReadKey;
                        if c='a' then loc:=15;
                        if c='b' then loc:=16;
                        if c='c' then loc:=1;
                    end;
                end;
                4: begin
                    Lokalizacja('sklep zabka');
                    Writeln('Za lada stoi pani Jessica i spod');
                    Writeln('namalowanych gruba kreska brwi,');
                    Writeln('spoglada tesknie na rzad puszek');
                    Writeln('piwa marki Harnas.');
                    Writeln;
                    Writeln('A'*,' - wyjdz bez slowa');
                    if items[NUMERJESSICA]=0 then Writeln('B'*,' - poderwij Jessice');
                    if items[SZLUGI]=0 then Writeln('C'*,' - kup szlugi');
                    if items[CYTRYNOWKA]=0 then Writeln('D'*,' - kup cytrynowke');
                    if items[HARNAS]=0 then Writeln('E'*,' - kup Harnasia');
                    c:=ReadKey;
                    if c='a' then loc:=1;
                    if (c='b') and (items[NUMERJESSICA]=0) then begin
                        if items[DRES]>0 then loc:=7
                        else begin
                            Writeln;
                            Writeln('W takim stroju??');
                            Writeln('Jessica ma jednak pewne standardy...');
                            Any;
                        end;
                    end;
                    if c='c' then items[SZLUGI]:=1;
                    if c='d' then items[CYTRYNOWKA]:=1;
                    if c='e' then items[HARNAS]:=1;
                end;
                5: begin
                    Lokalizacja('autobus linii 96');
                    Writeln('W autobusie jak to w autobusie.');
                    Writeln('Troche wali pasazerem, a troche');
                    Writeln('starymi biletami.');
                    Writeln;
                    Writeln('A'*,' - wysiadz na rynku');
                    Writeln('B'*,' - wysiadz na basenie');
                    Writeln('C'*,' - wysiadz na dworcu');
                    Writeln('D'*,' - wysiadz na osiedlu');
                    c:=ReadKey;
                    if c='a' then loc:=8;
                    if c='b' then loc:=9;
                    if c='c' then loc:=10;
                    if c='d' then loc:=2;
                end;
                6: begin // mirek pobudka
                    Lokalizacja('osiedle, przystanek');
                    Writeln('Pan Miroslaw wyczuwa cytrynowke');
                    Writeln('z odleglosci ponad 6 metrow.');
                    Writeln('Gdy tylko zblizyles sie do lawki,');
                    Writeln('usiadl i z godnoscia pozwolil sie');
                    Writeln('poczestowac.');
                    Writeln('Po wspolnej degustacji, pan Mirek');
                    Writeln('w ramach wdziecznosci oddaje Ci swoj');
                    Writeln('ulubiony dres marki PUNA i ponownie');
                    Writeln('zapada w drzemke...');
                    items[DRES]:=1;
                    loc:=2;
                    Any;
                end;
                7: begin // podryw jessica
                    Lokalizacja('sklep zabka');
                    Writeln('Odziany w gustowny dres, cmokasz');
                    Writeln('zalotnie i zagadujesz, zgrywajac');
                    Writeln('bystrzaka.');
                    Writeln('Wniebowzieta Jessica daje Ci swoj');
                    Writeln('numer telefonu.');
                    items[NUMERJESSICA]:=1;
                    loc:=4;
                    Any;
                end;
                8: begin // rynek 
                    Lokalizacja('rynek miejski');
                    Writeln('Niezbyt piekny jest rynek o tej porze');
                    Writeln('roku. Snuje sie tu kilku smutnych');
                    Writeln('typow w koszulkach miejscowego klubu.');
                    Writeln('Ewidentnie szukaja zaczepki.');
                    Writeln('W oddali widac klub SALOMON i wejscie');
                    Writeln('do parku jordanowskiego.');
                    Writeln('Na drugim koncu rynku widzisz budynek');
                    Writeln('hotelu HUTNIK.');
                    Writeln;
                    Writeln('A'*,' - wsiadz do autobusu');
                    Writeln('B'*,' - zaczep typkow');
                    Writeln('C'*,' - idz do SALOMONA');
                    Writeln('D'*,' - idz do parku');
                    Writeln('E'*,' - idz do HUTNIKA');
                    c:=ReadKey;
                    if c='a' then loc:=5;
                    if c='b' then loc:=11;
                    if c='c' then loc:=12;
                    if c='d' then loc:=13;
                    if c='e' then loc:=14;
                end;
                9: // basen
                    begin
                        Lokalizacja('basen miejski');
                        Writeln('Basen jest nieczynny o tej porze roku.');
                        Writeln('Rozgladasz sie po okolicy i widzisz');
                        if items[MAJTY]=0 then Writeln('stare kapielowki, oraz');
                        Writeln('pusty basen, na ktorego dnie, wsrod');
                        Writeln('poskrecanych kabli lezy stara latarka.');
                        Writeln;
                        if items[MAJTY]=0 then Writeln('A'*,' - wez kapielowki');
                        Writeln('B'*,' - wez latarke');
                        Writeln('C'*,' - nasikaj do basenu');
                        Writeln('D'*,' - wsiadz do autobusu');
                        c:=ReadKey;
                        if c='a' then items[MAJTY]:=1;
                        if c='b' then begin
                            Writeln;
                            Writeln('Kable podejrzanie iskrza.');
                            Writeln('Musisz jakos wylaczyc prad.');
                            Any;
                        end;
                        if c='c' then begin
                            Writeln;
                            Writeln('Sikanie na kable pod napieciem');
                            Writeln('to nie byl najlepszy pomysl tego');
                            Writeln('dnia. Ostatnie co czujesz to ogromny');
                            Writeln('bol krocza. Padasz zemdlony...');
                            Writeln('To koniec Twojej przygody.');
                            gameover:=2;
                            Any;
                        end;
                        if c='d' then loc:=5;
                    end;
                10: // dworzec
                    begin
                        Lokalizacja('dworzec kolejowy');
                        Writeln('Dworzec nie jest specjalnie piekny.');
                        Writeln('Troche smierdzi tutaj pociagiem,');
                        Writeln('chociaz moze to tez byc zapach uryny.');
                        Writeln('Kasa biletowa jest czynna.');
                        Writeln;
                        if items[BILET] = 0 then Writeln('A'*,' - kup bilet do Suprasla');
                        Writeln('B'*,' - wsiadz do pociagu');
                        Writeln('C'*,' - wroc do autobusu');
                        c:=ReadKey;
                        if c='a' then items[BILET]:=1;
                        if c='b' then begin
                            Writeln;
                            if items[BILET]=0 then begin
                                Writeln('Za jazde bez biletu, konduktor');
                                Writeln('wyrzuca Cie z pociagu w Walbrzychu.');
                                Writeln('Pomimo szeroko zakrojonych poszukiwan,');
                                Writeln('do ktorych udaje Ci sie namowic lokalna');
                                Writeln('spolecznosc, nie udaje Ci sie odnalezc');
                                Writeln('zadnych polskich liter...');
                                Writeln('To koniec Twojej przygody');
                                gameover:=2;
                                Any;
                            end else begin
                                Writeln('Pojechales do Suprasla.');
                                Writeln('Pomimo szeroko zakrojonych poszukiwan,');
                                Writeln('do ktorych udaje Ci sie namowic lokalna');
                                Writeln('spolecznosc, nie udaje Ci sie odnalezc');
                                Writeln('zadnych polskich liter...');
                                Writeln('To juz koniec Twojej przygody');
                                gameover:=2;
                                Any;
                            end;
                        end;
                        if c='c' then loc:=5
                    end;
                11: // typy na rynku
                    begin
                        Lokalizacja('typy na rynku');
                        Writeln('Trafiles na herszta bandy - Sebastiana,');
                        Writeln('zwanego tez mrocznym ksieciem wpierdolu.');
                        Writeln;
                        if items[SZLUGI]>0 then begin
                            Writeln('Seba skroil Ci szlugi i zostawil Cie');
                            Writeln('we wzglednym spokoju...');
                            items[SZLUGI]:=0;
                            loc:=8;
                            Any;
                        end else begin
                            if items[WPIERDOL]=0 then begin
                                Writeln('Niestety, nie miales szlugow');
                                Writeln('i obskoczyles srogi wpierdol od');
                                Writeln('Seby i jego ziomow.');
                                Writeln('Nie byl to najlepszy pomysl, bo');
                                Writeln('ze zlamanym nosem nigdy nie bylo ci');
                                Writeln('do twarzy...');
                                items[WPIERDOL]:=1;
                                loc:=8;
                                Any;
                            end else begin
                                Writeln('- To znowu ty ziomus???');
                                Writeln('Szczerze zdziwiony Seba wydziela Ci');
                                Writeln('kolejnego zasluzonego liscia.');
                                Writeln('BENC!');
                                Writeln('zapada ciemnosc...');
                                Writeln('powoli tracisz przytomnosc...');
                                Writeln('to juz koniec Twojej przygody.');
                                gameover:=2;
                                Any;
                            end;
                        end;
                    end;
                12: // SALOMON
                    begin
                        Lokalizacja('klub SALOMON');
                        Writeln('Klub SALOMON to centrum kulturalne');
                        Writeln('tego miasta. Niejeden juz tu nalal');
                        Writeln('z proznego i niejeden jeszcze naleje.');
                        Writeln;
                        Writeln('Za barem stoi Twoj ziomek z lat');
                        Writeln('szkolnych, Slawek. Znany erotoman');
                        Writeln('gawedziarz.');
                        Writeln;
                        Writeln('A'*,' - dziabnij shota');
                        Writeln('B'*,' - rozmawiaj ze Slawkiem');
                        Writeln('C'*,' - idz na rynek');
                        Writeln('D'*,' - idz do toalety');
                        c:=ReadKey;
                        if c='a' then begin
                            items[SHOT]:=items[SHOT]+1;
                            Writeln;
                            if items[SHOT]<5 then begin
                                Writeln('Mniam! Doskonala kompozycja smakow.');
                                Any;
                            end else begin
                                Writeln('O jeden shot za duzo. Padasz zemdlony');
                                Writeln('na ryj. Swiat slodko odplywa w dal.');
                                Writeln('Niestety, to juz koniec Twej przygody.');
                                gameover:=2;
                                Any;
                            end;
                        end;
                        if c='b' then begin
                            Writeln;
                            if items[NUMERJESSICA] <> 0 then begin
                                Writeln('Pogadaliscie, o dupeczkach. Dales');
                                Writeln('Slawkowi numer Jessiki, a on w ramach');
                                Writeln('rewanzu podarowal Ci znaleziony');
                                Writeln('w kiblu kluczyk do samochodu.');
                                items[KLUCZYKI]:=1;
                                items[NUMERJESSICA]:=0;
                            end else begin
                                Writeln('Pogadaliscie, jak zwykle o dupeczkach.');
                                Writeln('Nie dowiedziales sie nic nowego.');
                                Writeln('Zapytales tez o polskie litery, ale ');
                                Writeln('Slawek chyba nie zakumal o co biega.');
                            end;
                            Any;
                        end;
                        if c='c' then loc:=8;
                        if c='d' then loc:=17;
                    end;
                13: // park
                    begin
                        Lokalizacja('park Jordanowski');
                        Writeln('W parku jest brudno i mokro.');
                        Writeln('Spacerujesz omijajac psie kupy');
                        Writeln('i probujesz nie wdepnac w nic');
                        Writeln('podejrzanego.');
                        if items[REKLAMOWKA]=0 then begin
                            Writeln('Widzisz wiszaca na drzewie');
                            Writeln('reklamowke z lidla');
                        end;
                        Writeln;
                        if items[REKLAMOWKA]=0 then Writeln('A'*,' - wez reklamowke');
                        Writeln('B'*,' - wroc do autobusu');
                        c:=ReadKey;
                        if c='a' then begin
                            Writeln;
                            if items[SZCZOTKA]=0 then begin
                                Writeln('Za wysoko, nie siegniesz...');
                                Any;
                            end else begin
                                Writeln('Wspinasz sie na palce i siegasz');
                                Writeln('szczotka z kibla. Reklamowka spada.');
                                Writeln('Zagladasz do srodka i znajdujesz');
                                Writeln('pusta butelke po winie i paragon.');
                                items[REKLAMOWKA]:=1;
                                Any;
                            end;
                        end;
                        if c='b' then loc:=5;
                    end;
                14: // HUTNIK
                    begin
                        Lokalizacja('hotel HUTNIK');
                        Writeln('W recepcji hotelu pracuje Twoja');
                        Writeln('sasiadka pani Jadwiga, zona wlasciciela');
                        Writeln('passata');
                        if (items[WPIERDOL]<>0) and (items[SOLUX]=0) then begin
                            Writeln('Pani Jadwiga jest przerazona Twoim');
                            Writeln('zlamanym nosem. Zabiera Cie na pogotowie.');
                            loc:=18;
                            Any;
                        end else begin
                            Writeln;
                            Writeln('A'*,' - zapytaj o passata');
                            Writeln('B'*,' - zapytaj o polskie litery');
                            Writeln('C'*,' - idz na rynek');
                            c:=ReadKey;
                            Writeln;
                            if c='a' then begin
                                Writeln('Pani Jadwiga posmutniala');
                                Writeln('i powiedziala Ci, ze jej maz');
                                Writeln('kilka dni temu zgubil kluczyki.');
                                Writeln('Co za pech...');
                                Any;
                            end;
                            if c='b' then begin
                                Writeln('Pani Jadwiga patrzy na Ciebie');
                                Writeln('podejrzliwym wzrokiem...');
                                Writeln('Chyba nic nie wie, albo udaje.');
                                Any;
                            end;
                            if c='c' then loc:=8;
                        end;                        
                    
                    end;
                15: // SKRZYNIA
                    begin
                        Lokalizacja('jaskinia, skrzynia');
                        Writeln('Probujesz podwazyc zmurszale wieko.');
                        Writeln('Niestety, skrzynia nie chce ustapic');
                        Writeln('nawet na milimetr. Przydalby sie jakis');
                        Writeln('lom, albo chociaz trotyl...');
                        Any;
                        loc:=3;
                    end;
                16: // PASSAT
                    begin
                        Lokalizacja('jaskinia, passat sasiada');
                        if items[KLUCZYKI] = 0 then begin
                            Writeln('Probujesz wszystkie klamki, ale');
                            Writeln('niestety - passat jest zamkniety na');
                            Writeln('glucho. Zagladasz do srodka przez');
                            Writeln('szybe, ale oprocz paru pustych puszek');
                            Writeln('Harnasia, nie widac tam nic ciekawego.');
                            Any;
                            loc:=3;
                        end else begin
                            chbas:=Hi(CHARSET_ADDRESS_PL);
                            Writeln('Wsadzasz kluczyk do drzwi... pasuje!');
                            Writeln('Otwierasz je delikatnie i zagl',char(1),'dasz do');
                            Writeln(char($13),'rodka pojazdu. W schowku na r',char($5),'kawiczki');
                            Writeln('znajdujesz zaginione polskie litery!!!');
                            Writeln;
                            Writeln('HURRA! Tw',char($f),'j dzie',char($e),' nie poszed',char($c),' na marne.');
                            Writeln('Od dzi',char($13),', od rana do wieczora, mo',char($1a),'esz');
                            Writeln('za',char($1a),char($f),char($c),'ca',char($3),' g',char($5),char($13),'l',char(1),' ja',char($18),char($e),'!');
                            Writeln;
                            Writeln('GRATULACJE!!!');
                            Any;
                            gameover:=1;
                        end;
                    end;
                17: // TOALETA
                    begin
                        Lokalizacja('SALOMON - toaleta');
                        Writeln('W kibelku nieco zionie fekaliami.');
                        Writeln('Woda w pisuarze slodko szemrze,');
                        Writeln('a kapiacy kran wesolo wystukuje rytm.');
                        if items[SZCZOTKA]=0 then begin
                            Writeln('Obok toalety stoi stara szczotka do');
                            Writeln('klopa, ociekajaca brudem.');
                        end;
                        Writeln('Przegladasz sie w lustrze');
                        if items[WPIERDOL]=0 then Writeln('Calkiem niezle z Ciebie ciacho')
                        else Writeln('Twoj zlamany nos nie wyglada dobrze.');
                        Writeln;
                        Writeln('A'*,' - wyjdz do baru');
                        Writeln('B'*,' - oddaj honorowo mocz');
                        if items[SZCZOTKA]=0 then Writeln('C'*,' - wez szczotke');
                        c:=ReadKey;
                        if c='a' then loc:=12;
                        if c='b' then begin
                            Writeln;
                            Writeln('...ciur ciur ciur...');
                            Any;
                        end;
                        if c='c' then items[SZCZOTKA]:=1;
                    end;
                18: // POGOTOWIE
                    begin
                        Lokalizacja('pogotowie SOR');
                        Writeln('Siedzicie z pania Jadwiga na izbie');
                        Writeln('przyjec. Widziales juz lepsze przyjecia.');
                        Writeln('Oprocz Ciebie czeka tutaj jeszcze kilka');
                        Writeln('innych osob, w tym mama Jessiki,');
                        Writeln('pan dewiant Horacy z czwartego,');
                        Writeln('oraz bracia Bolec z twojego liceum.');
                        Writeln;
                        Writeln('A'*,' - cierpliwie czekaj');
                        Writeln('B'*,' - zrob awanture');
                        Writeln('C'*,' - rozmawiaj z mama Jessiki');
                        Writeln('D'*,' - rozmawiaj z Horacym');
                        Writeln('E'*,' - rozmawiaj z Bolcami');
                        c:=ReadKey;
                        Writeln;
                        if c='a' then begin
                            if items[CZEKAJ]<5 then begin
                                items[CZEKAJ]:=items[CZEKAJ]+1;
                                Writeln('Czekasz kolejna godzine... i nic');
                                Any;
                            end else begin
                                Writeln('Po pieciu godzinach czekania trafia');
                                Writeln('Cie szlag i wracasz na rynek...');
                                loc:=8;
                                Any;
                            end;
                        end;
                        if c='b' then begin
                            Writeln('Zaczynasz klac na czym swiat stoi');
                            Writeln('i w koncu ktos sie Toba zainteresowal.');
                            Writeln('Pielegniarz zabiera Cie do gabinetu.');
                            loc:=19;
                            Any;
                        end;
                        if c='c' then begin
                            Writeln('Mama Jessiki opowiada Ci o swojej');
                            Writeln('pieknej corce, i o jej adoratorach.');
                            Writeln('Pytasz o polskie litery, ale chyba');
                            Writeln('nie doslyszala.');
                            Any;
                        end;
                        if c='d' then begin
                            Writeln('Horacy jak zwykle opowiada jakies');
                            Writeln('straszne bezecenstwa. Chyba nie ma');
                            Writeln('sensu pytac go o polskie znaki...');
                            if (items[MAJTY]<>0) and (items[ZDJECIEMJ]=0) then begin
                                Writeln('Zagadujesz go o majty znalezione na');
                                Writeln('basenie. Chetnie wymienia ja na');
                                Writeln('zdjecie Majkela Dzeksona.');
                                Writeln('Z autografem!');
                                items[ZDJECIEMJ]:=1;
                            end;
                            Any;
                        end;
                        if c='e' then begin
                            Writeln('Bracia Bolec chichocza jak debile.');
                            Writeln('Nic madrego sie od nich nie dowiesz.');
                            Any;
                        end;
                        
                    end;
                19: // gabinet lekarza
                    begin
                        Lokalizacja('gabinet lekarza');
                        Writeln('Pan doktor opatruje Twoj nos.');
                        Writeln('Troche szczypi, ale won antyseptykow');
                        Writeln('lagodzi nieprzyjemne odczucia.');
                        if items[SOLUX]=0 then begin
                                Writeln('Na stole widzisz lampe SOLUX.');
                        end;
                        Writeln('Na polce w szafie lezy morfina');
                        Writeln;
                        if items[SOLUX]=0 then Writeln('A'*,' - ukradnij lampe');
                        Writeln('B'*,' - ukradnij morfine');
                        Writeln('C'*,' - wroc do miasta');
                        c:=ReadKey;
                        Writeln;
                        if c='a' then begin
                            Writeln('Uff... udalo sie!');
                            items[SOLUX]:=1;
                            Any;
                        end;
                        if c='b' then begin
                            Writeln('Oj!');
                            Writeln('Zostales przylapany.');
                            Writeln('Lekarz zabiera Cie na komisariat');
                            Writeln('gdzie zostajesz zamkniety na dolku.');
                            Writeln('Twoja przygoda dobiegla konca...');
                            gameover:=2;
                            Any;
                        end;
                        if c='c' then loc:=8;
                    end;
            end;
        until gameover<>0;
        GameOverScreen;
    until false;
end.
