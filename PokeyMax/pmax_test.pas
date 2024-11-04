program pmax_test;

uses crt, pm_detect, pm_flash;

var
    present: Boolean = false;
    s_pokey: String = '';
    flash_data1: LongWord;
    flash_data2: LongWord;

function convert_bool(value: Boolean): String;
begin
    if value then result:= 'Yes'
    else result:= 'No';    
end;

begin
    present:= PMAX_Detect;
    if present then
    begin
        PMAX_EnableConfig(true);
        case PMAX_GetPokeys of
            1: s_pokey:='Mono';
            2: s_pokey:='Stereo';
            4: s_pokey:='Quad';
        end;

        writeln('Core: ', PMAX_GetCoreVersion); 
        // writeln('Pokeys: ', PMAX_GetPokeys);
        writeln('Pokeys: ', s_pokey);
        writeln('SID: ', convert_bool(PMAX_isSIDPresent));
        writeln('PSG: ', convert_bool(PMAX_isPSGPresent));
        writeln('Covox: ', convert_bool(PMAX_isCovoxPresent));
        writeln('Sample: ', convert_bool(PMAX_isSamplePresent));
        writeln('Flash: ', convert_bool(PMAX_isFlashPresent));
        writeln('----------');
        PMAX_EnableConfig(false);
    end
    else begin
        writeln(' PokeyMAX not found. ');
    end;
    repeat until keypressed;
end.