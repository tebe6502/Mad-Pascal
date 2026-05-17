
type TConfig = record
    currentTheme:byte;
    sioAudio:byte;
    consoleEveryTab:byte;
end;

type TUser = record
    id: cardinal;
    nick: string[12];
    key: string[8];
end;

type TState = record
    activeTab: byte;
    tabCount: byte;
    lastLine: array[0..4] of cardinal;
    unreadTab: array[0..4] of byte;
    xcur: array[0..4] of byte;
    ycur: array[0..4] of byte;
end;

type TStatus = record
    tabCount: byte;
    forceTabOpen: byte;
    lastLine: array[0..4] of cardinal;
    name0:string[16];
    name1:string[16];
    name2:string[16];
    name3:string[16];
    name4:string[16];
end;    