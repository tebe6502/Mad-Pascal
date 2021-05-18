{$r lang_en.rc}

const
    monsters: array [0..MONSTERS_COUNT - 1] of TString = (
        'BAT',
        'RAT',
        'LIZARD',
        'SPIDER',
        'DOG',
        'SNAKE',
        'KRONK',
        'GNOME',
        'GOBLIN',
        'ZOMBIE',
        'WARG',
        'GHOST',
        'ELF',
        'WEREWOLF',
        'WITCH',
        'ORC',
        'GARGOYLE',
        'TROLL',
        'MAGE',
        'VAMPIRE',
        'NIGHTMARE',
        'MINOTAUR',
        'CYCLOPE',
        'GIANT',
        'HYDRA',
        'DEMON',
        'MEDUSA',
        'DRAGON',
        'DEVIL',
        'PHOENIX'
     );
    weapons: array [0..WEAPONS_COUNT - 1] of TString = (
        'FORK',
        'KNIFE',
        'RAZOR',
        'DAGGER',
        'SABER',
        'LANCE',
        'JAVELIN',
        'SCIMITAR',
        'AXE',
        'SWORD' 
    );
    treasures: array [0..TREASURES_COUNT - 1] of TString = (
        'COPPER',
        'SILVER',
        'GOLD',
        'PLATINUM',
        'DIAMONDS' 
    );
    items: array [0..ITEMS_COUNT - 1] of TString = (        
        'HAMMER',
        'LANTERN',
        'KEY',
        'PLANK',
        'FOOD',
        'DRINKS',
        'BANDAGE',
        'MEDICINE',
        'PASSWORD' 
    );
    itemSymbols: array [0..ITEMS_COUNT - 2] of char = ( 'H', 'L', 'K', 'P', 'F', 'D', 'B', 'M');
    passwords: array [0..PASSWORDS_COUNT - 1] of TString = ('FISH','EGGS','BYTE','TREE','CLAN','CULT','MOON','BULB','LASH');

const
    k_YES = byte('Y');
    k_NO = byte('N');
    k_LEFT = byte('L');
    k_RIGHT = byte('R');
    k_UP = byte('U');
    k_DOWN = byte('D');
    k_FIGHT = byte('F');
    k_RANSOM = byte('B');
    k_TAKE = byte('T');
    k_LEAVE = byte('L');
    k_REST = byte('R');
    k_MOVE = byte('M');
    k_BANDAGE = byte('B');
    k_MEDKIT = byte('M');
    s_PRESS_ANY: string = 'PRESS ANY KEY';
    s_WANT_MANUAL: string = ' DO YOU WANT TO READ A MANUAL (Y/N)?';
    s_ENERGY: string = 'ENERGY'*;
    s_TREASURE: string = 'TREASURE'*;
    s_MOVES: string = 'MOVES'*;
    s_WOUNDS: string = 'WOUNDS'*;
    s_ITEMS: string = 'ITEMS'*;
    s_WEAPON: string = 'YOUR WEAPON'*;
    s_ATTACK: string = 'ATTACK'*;
    s_FOUND: string = 'YOU HAVE FOUND ';
    s_TAKE: string = 'T'*'AKE';
    s_OR: string = ' OR ';
    s_LEAVE: string = 'L'*'EAVE';
    s_FOUND_PASS: string = 'YOU''VE FOUND PASSWORD: ';
    s_REMEMBER: string = 'REMEBER IT.';
    s_LEAVE_WHAT: string = 'WHAT DO YOU WANT TO DROP?   ';
    s_DONT_HAVE: string = 'YOU DON''T HAVE ';
    s_WAIT: string = '  '#32'R'*'EST';
    s_MOVE: string = 'M'*'OVE';
    s_LEFT: string = ' '#32'L'*'EFT';
    s_RIGHT: string = 'R'*'IGHT';
    s_UP: string = 'U'*'P';
    s_DOWN: string = 'D'*'OWN';
    s_DROPPED: string = 'SO YOU DROPPED IT.';
    s_USED: string = 'YOU''VE USED ';
    s_ATTACKED: string = 'ATTACKED';
    s_DOOR_OPENED: string = 'THE DOOR IS OPEN, ENTERING.';
    s_DOOR_CLOSED: string = 'DOOR IS CLOSED, ';
    s_KEY: string = 'KEY';
    s_BYKEY: string = 'KEY';
    s_WALL: string = 'THIN WALL, ';
    s_HAMMER: string = 'HAMMER';
    s_BYHAMMER: string = 'HAMMER';
    s_ROOM_DARK: string = 'THE ROOM IS DARK,';
    s_LANTERN: string = 'LANTERN';
    s_BYLANTERN: string = 'LANTERN';
    s_ROOM_HOLE: string = 'THERE IS NO FLOOR IN THIS ROOM,';
    s_PLANK: string = 'PLANK';
    s_BYPLANK: string = 'PLANK';
    s_EXIT_PASS: string = 'YOU''VE REACHED AN EXIT. SAY PASSWORD.';
    s_EXIT_PAY: string = 'THANK YOU! GIVE ME A MONEY (100$).';
    s_EXIT_LEAVE: string = 'YOU LEFT AN OLD MANSION WITH ';
    s_EXIT_SCORE: string = ' TO SELL. SCORE=';
    s_EXIT_POOR: string = 'OUCH! YOU DON''T HAVE ENOUGH MONEY.';
    s_EXIT_FATAL: string = 'GUARDIAN CUTS YOUR HEAD OFF.';
    s_EXIT_WRONG_PASS: string = 'WRONG! PASSWORD WAS: ';
    s_BUMP: string = 'YOU HIT THE WALL';
    s_NO_PASARAN: string = 'BETTER FIND OTHER WAY.';
    s_BACK_TO_START: string = 'YOU''VE BEEN TELEPORTED TO START.';
    s_ITEM_BROKE: array [0..7] of string = (
        'HAMMER IS BROKEN, ',
        'LANTERN IS OUT OF OIL, ',
        'KEY IS RUSTED, ',
        'PLANK DECAYED, ',
        'FOOD IS ROTTEN, ',
        'DRINK DRIED OFF, ',
        'BANDAGE IS RIPPED, ',
        'MEDICINE HAS EXPIRED, '
    );
    s_BROKE: string = 'YOU''VE BROKE ';
    s_YOU_M: string = ' BY ';
    s_YOU_F: string = '';
    s_MONSTER_STR: string = 'ATTACK ';
    s_TOO_WEAK_POOR: string = 'YOU ARE TOO WEAK AND POOR';
    s_TOO_WEAK: string = 'YOU ARE TOO WEAK, YOU MUST PAY.';
    s_TOO_POOR: string = 'YOU HAVE TO FIGHT.';
    s_FIGHT: string = 'F'*'IGHT';
    s_RANSOM: string = 'B'*'RIBE';
    s_HAS_BEEN: string = ' HAS BEEN';
    s_DEFEATED_F: string = '';
    s_DEFEATED_M: string = ' DEFEATED, ';
    s_EARNED: string = 'YOU EARN ';
    s_HAS_STR: string = ' HAS ATTACK ';
    s_WANNA_USE: string = 'DO YOU WANT TO USE AN ITEM (Y/N)?';
    s_WHICH: string = 'WHICH ONE?       ';
    s_CAN_USE_ONLY: string = 'NOW YOU CAN USE ONLY ';
    s_AND: string = 'AND ';
    
    
function needPostfix(monster: byte): boolean;
begin
    result := false; 
end;

procedure ManualPage1;
begin
    lmargin:=0;
    Writeln;
    Writeln;  //                                     /
    Writeln('You have suddenly found yourself        in an old and spooky mansion.');
    Writeln('You need to get out of here.');
    Writeln;  //                                     /
    Writeln('There is only one exit and it''s guarded.The guard will let you out if you tell');
    Writeln('him the password and pay $100.');
    Writeln;  //                                     /
    Writeln('You need to collect the money (by');
    Writeln('finding the treasures) which belong to');
    Writeln('the monsters living here. You can fight them if you have less than 5 wounds');
    Writeln('and your power is greater than 0.');
    Writeln;  //                                     /
    Writeln('You can increase your energy when you');
    Writeln('find or buy food or drinks. Wounds can');
    Writeln('be healed with medicines or bandages.');
end;
    
procedure ManualPage2;
begin
    Writeln;  //                                     /
    Writeln('If you can''t fight, you need to pay');
    Writeln('the monster for letting you out.');
    Writeln;  //                                     /
    Writeln('The password can be found somewhere');
    Writeln('in the mansion. Memorise it well!');
    Writeln;  //                                     /
    Writeln;
    Writeln('The mansion is very old. Some rooms');
    Writeln('are dark, some have no floor.');
    Writeln('You can find closed doors or thin walls');
    Writeln('so make sure to collect items.');
    Writeln;  //                                     /
    Writeln('But remember - you can only carry');
    Writeln('four items and one weapon at once.');
    Writeln;  //                                     /
    Writeln('Pick always the best weapon; it depends');
    Writeln('on your attack strength and');
    Writeln('the treasures you''ve collected.');
end;
    
procedure ManualPage3;
begin
    Writeln;
    Writeln('           SYMBOLS:');
    Writeln;
    Print(char(TILE_EXIT),char(TILE_EXIT-1)); Writeln(' - exit');
    Print(char(TILE_DARK)); Writeln(' - dark room');
    Print(char(TILE_HOLE)); Writeln(' - collapsed floor');
    Print(char(TILE_DOOR_H), #32); Print(char(TILE_DOOR_V)); Writeln( ' - closed doors');
    Print(char(TILE_WALL_H), #32); Print(char(TILE_WALL_V)); Writeln( ' - thin wall');
    Writeln('H - hammer');
    Writeln('L - lantern');
    Writeln('K - key');
    Writeln('P - plank');
    Writeln('B - bandages');
    Writeln('M - medicines');
    Writeln(TILE_PLAYER,' - this is you');
    lmargin:=2;
    Writeln;
end;
