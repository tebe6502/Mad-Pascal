program music;

uses crt,neo6502;


const
    C1 = 130; C1x = 138; D1 = 146; D1x = 155; E1 = 164; F1 = 174; F1x = 185; G1 = 196; G1x = 207; A1 = 220; A1x = 233; B1 = 246;
    C2 = 261; C2x = 277; D2 = 293; D2x = 311; E2 = 329; F2 = 349; F2x = 369; G2 = 391; G2x = 415; A2 = 440; A2x = 466; B2 = 493;
    C3 = 523; C3x = 554; D3 = 587; D3x = 622; E3 = 659; F3 = 698; F3x = 739; G3 = 783; G3x = 830; A3 = 880; A3x = 923; B3 = 987;
    C4 = 1046;


const
    QUEUE_LOAD = 16;
    SONGS = 4;

    f_ingame : array[0..7] of word = ( F1x, 0, C2x, 0, C1x, 0, C2x, 0 );
    l_ingame : array[0..7] of word = ( 10,2,10,2,10,2,10,2 );

    f_escape : array[0..7] of word = ( F1, 0, C2, 0, C1, 0, C2, 0 );
    l_escape : array[0..7] of word = ( 12,8,12,8,12,8,12,8 );

    ready_len = 64;
    f_ready : array[0..ready_len-1] of word = (
        C2, D2x, 0, F2x, A2, 0, C3, 0, D3x, 0, C1, 0, C3, 0, C1, 0,
        C2x, E2, 0, G2, A2x, 0, C3x, 0, E3, 0, C1x, 0, C3x, 0, C1x, 0,
        D2, D2x, 0, F2x, E2, F2, 0, G2X, F2, F2X, 0, A2, F2x, G2, 0, A2x,
        A1x, B1, C2, C2x, D2, D2x, C2, F2, A2x, A2x, 0, 0, 0, 0, 0, 0
    );
    l_ready : array[0..ready_len-1] of word = (
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    );

    title_len = 128;
    f_title : array[0..title_len-1] of word = (
        F1, 0, F2, 0, F3, 0, F2, 0, C3, 0, B2, 0, C1, 0, B1, 0,
        F1, 0, G2, 0, G3, 0, G2, 0, C3x, 0, C3, 0, C1, 0, C2, 0, 
        F1, 0, F2, 0, F3, 0, F2, 0, C3, 0, B2, 0, C1, 0, B1, 0,
        F1, 0, G2, 0, G3, 0, G2, 0, C3x, 0, C3, 0, C1, 0, C2, 0, 
        G1x, 0, C3, 0, D3x, 0, A2x, 0, C3, 0, D3x, 0, D1x, 0, G2x, 0,
        D1x, 0, A2x, 0, D3x, 0, F2x, 0, G2x, 0, A2x, 0, D3x, 0, D2x, 0,
        F1x, 0, A2x, 0, C3x, 0, G2x, 0, A2x, 0, C3x, 0, C1x, 0, C2x, 0,
        G1, 0, B2, 0, D3, 0, A2, 0, B2, 0, D3, 0, D1x, 0, D2, 0
    );
    l_title : array[0..title_len-1] of word = (
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 
        15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1
    );


    s_freq: array [0..SONGS - 1] of pointer = ( @f_ingame, @f_escape, @f_ready, @f_title);
    s_lengths: array [0..SONGS - 1] of pointer = ( @l_ingame, @l_escape, @l_ready, @l_title);
    s_len: array [0..SONGS - 1] of byte = ( 8, 8, ready_len, title_len );


var
    song,song_ptr,song_len: byte;
    note_freq: array [0..0] of word;
    note_leng: array [0..0] of word;
    

procedure feedSong();
var tick:byte;
begin
    for tick:=1 to QUEUE_LOAD do begin
        NeoQueueNote(0, note_freq[song_ptr], note_leng[song_ptr], 0, 0);
        Inc(song_ptr);
        if song_ptr = song_len then song_ptr:=0;
    end;
end;

procedure PlaySong(snum:byte);
begin
    song_len := s_len[snum];
    note_freq := s_freq[snum];
    note_leng := s_lengths[snum];
    song_ptr := 0;
    NeoMute(0);
    feedSong;
end;

begin
    song:=0;
    PlaySong(song);
    repeat
        if NeoGetQueueLen(0) < 2 then feedSong();

        if keypressed then begin    
            readkey;
            Inc(song);
            if song = SONGS then song := 0;
            PlaySong(song);

        end;
        NeoWaitForVblank;
    until false;

end.