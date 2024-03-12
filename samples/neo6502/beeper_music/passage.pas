program passage;

uses neo6502;

const
    M_1 = 3; // + 1

const
    C1 = 130; C1x = 138; D1 = 146; D1x = 155; E1 = 164; F1 = 174; F1x = 185; G1 = 196; G1x = 207; A1 = 220; A1x = 233; B1 = 246;
    C2 = 261; C2x = 277; D2 = 293; D2x = 311; E2 = 329; F2 = 349; F2x = 369; G2 = 391; G2x = 415; A2 = 440; A2x = 466; B2 = 493;
    C3 = 523; C3x = 554; D3 = 587; D3x = 622; E3 = 659; F3 = 698; F3x = 739; G3 = 783; G3x = 830; A3 = 880; A3x = 923; B3 = 987;
    C4 = 1046;

const
    N8 = 8;
    P2 = 2;

const
    freq : array[0..M_1] of word = (
        C2, G2, E2, G2
    );

    leng : array[0..M_1] of byte = (
        N8, N8, N8, N8
    );

var
    i : byte;

begin

    repeat
        if NeoGetQueueLen(0) = 0 then begin
            for i := 0 to M_1 do begin
                // NeoQueueNote(channel:byte;freq,len,slide:word;stype:byte);
                NeoQueueNote(0, freq[i], leng[i], 0, 0);
                NeoQueueNote(0, 0, P2, 0, 0);
            end;
        end;
    until false;

end.
