program pmax_flash;

uses crt, pm_detect, pm_flash;

// type
//     page_array = array [0..511] of LongWord;
var
    present: Boolean = false;
    flash_data1: LongWord = 0;
    flash_data2: LongWord = 0;
    s_pokey: String = '';
    version: String = '';
    i: Word;
    // page_buffer: page_array;
    page_buffer: array[0..1023] of LongWord;
    pagesize: Word;

function convert_bool(value: Boolean): String;
begin
    if value then result:= 'Yes'
    else result:= 'No';    
end;

begin
{$IFDEF DEBUG}
    present:= true;
{$ELSE}
    present:= PMAX_Detect;
{$ENDIF}
    if present then
        begin
            PMAX_EnableConfig(true);
            case PMAX_GetPokeys of
                1: s_pokey:='Mono';
                2: s_pokey:='Stereo';
                4: s_pokey:='Quad';
            end;
            version:= PMAX_GetCoreVersion;
            writeln('Core: ', version); 
            writeln('Pokeys: ', s_pokey);
            writeln('SID: ', convert_bool(PMAX_isSIDPresent));
            writeln('PSG: ', convert_bool(PMAX_isPSGPresent));
            writeln('Covox: ', convert_bool(PMAX_isCovoxPresent));
            writeln('Sample: ', convert_bool(PMAX_isSamplePresent));
            writeln('Flash: ', convert_bool(PMAX_isFlashPresent));
            writeln('----------');
            writeln('Config:');
	        flash_data1 := PMAX_ReadFlash(0,0);
	        flash_data2 := PMAX_ReadFlash(1,0);
            write('Data:');
	        write(HexStr(flash_data1,8));
            write(':');
	        write(HexStr(flash_data2,8));
            writeln('');
            case version[6] of
                '8':    begin   // flash M04
                            pagesize:= 512;
                        end;
                '6':    begin   // flash M16
                            pagesize:= 1024;
                        end;
                '4':    begin   // flash M04
                            pagesize:= 512;
                        end;
                else
                    pagesize:=512;
            end;
            // GetMem(page_buffer, pagesize * 4);
            writeln('Backing up page');
            for i := 0 to pagesize - 1  do
            begin
                page_buffer[i] := PMAX_ReadFlash(i,0);
            end;
            writeln('Backing up page DONE');

            writeln('Erasing page');
            PMAX_WriteProtect(False);
            PMAX_ErasePage(0);
            writeln('Erasing page DONE');

            writeln('Write defaults');
            PMAX_WriteFlash(0,0,$050C5511);
            PMAX_WriteFlash(1,0,$FF00FA31);
            writeln('Write defaults DONE');

            writeln('Write backed up stuff');
            for i := 2 to pagesize - 1  do
            begin
                PMAX_WriteFlash(i,0,page_buffer[i]);
            end;
            PMAX_WriteProtect(True);
            writeln('Write backed up stuff DONE');
            PMAX_EnableConfig(false);
            // FreeMem(page_buffer, pagesize * 4);
        end
        else begin
            writeln(' PokeyMAX not found. ');
        end;
        repeat until keypressed;
end.
