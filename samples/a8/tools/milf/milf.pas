program MILF;

uses atari, crt;

const

     { SIO direction }

     SIO_READ        = $40;
     SIO_WRITE       = $80;
     SIO_NONE        = $00;
     SIO_READ_WRITE  = $c0;
     
     { SIO commands }
     
     FORMAT_DISK     = $21;
     FORMAT_SINGLE   = $21;
     FORMAT_ENHANCED = $22;
     READ_PERCOM     = $4e;
     WRITE_PERCOM    = $4f;
     PUT_SECTOR      = $50;
     READ_SECTOR     = $52;
     READ_STATUS     = $53;
     
     { Used memory locations }
     
     PERCOM_BUFFER_MEM   = $600;
     COPY_BUFFER_MEM     = $6000;
     LOG_BUFFER          = $6200;
     
     { Log constants }
     
     LOG_READ_ERROR      = 114;
     LOG_READ_SUCCESS    = 111;
     LOG_WRITE_ERROR     = 119;
     EOL                 = $9b;
     
     { I/O locations }
     
     DDEVIC	          = $0300;
     DUNIT 	          = $0301;
     DCOMND	          = $0302;
     DSTATS	          = $0303;
     DBUFLO	          = $0304;
     DBUFHI	          = $0305;
     DTIMLO	          = $0306;
     DUNUSE	          = $0307;
     DBYTLO	          = $0308;
     DBYTHI	          = $0309;
     DAUX1 	          = $030a;
     DAUX2 	          = $030b;
     
     { Percom blocks }
     
     SSSD                : array[0..11] of byte = (40,2,0,18,0,0,0,128,0,0,0,0);
     SSED                : array[0..11] of byte = (40,2,0,26,0,4,0,128,0,0,0,0);
     SSDD                : array[0..11] of byte = (40,2,0,18,0,4,1,  0,0,0,0,0);
     DSDD                : array[0..11] of byte = (40,2,0,18,1,4,1,  0,0,0,0,0);
     DSQD                : array[0..11] of byte = (80,2,0,18,1,4,1,  0,0,0,0,0);
     

var
     percomBlock                   : array[0..11] of byte;
     CH                            : byte absolute $02fc;
     result                        : word; 
     SIOresult                     : byte;
     CIOresult                     : byte;
     tmpBool                       : boolean;
     tmpByte                       : byte;
     tmpByte2                      : byte;
     tmpWord                       : word;
     tmpString                     : string[17];
     tmpString2                    : string[17];
     key                           : char;
     f                             : file;
     Code                          : byte;
     cursor_y                      : byte;
     
     requestedSectors              : word;
     requestedSectorSize           : word;
     
     source_drive                  : byte;
     dest_drive                    : byte;
     selected_drive                : byte;
     source_drive_not_configurable : boolean;
     dest_drive_not_configurable   : boolean;
     
     bytes_per_sector_source       : word;
     bytes_per_sector_dest         : word;
     bytes_per_sector              : word;
     number_of_sectors             : word;
          
     current_sector                : word;
     sector_index                  : word;
     
     sectors_to_read               : word;
               
     start_sector                  : integer;
     end_sector                    : integer;

procedure getString(maxChars: byte);
     begin
          asm {
          
               iccmd    = $0342
               icbufa   = $0344
               icbufl   = $0348

               lda #<COPY_BUFFER_MEM
               ldy #>COPY_BUFFER_MEM
               ldx #$00
               sta icbufa,x
               tya
               sta icbufa+1,x
               lda maxChars
               sta icbufl,x
               lda #$00
               sta icbufl+1,x
               lda #$05
               sta iccmd,x
               jsr $E456
               
               sty CIOresult
          
          };
     end;
     

procedure exec_sio(sunit: byte; command: byte; direction: byte; timeout: byte; buffer: word; size: word; aux: word);
     var 
          bl, bh, al, ah, sl, sh: byte;
     begin
          bl := Lo(buffer);
          bh := Hi(buffer);
          al := Lo(aux);
          ah := Hi(aux);
          sl := Lo(size);
          sh := Hi(size);
          
          asm {
               lda  #$31
               sta  DDEVIC
               lda  sunit
               sta  DUNIT
               lda  command
               sta  DCOMND
               lda  al
               sta  DAUX1
               lda  ah
               sta  DAUX2
               lda  direction
               sta  DSTATS
               lda  bl
               sta  DBUFLO
               lda  bh
               sta  DBUFHI
               lda  timeout
               sta  DTIMLO
               lda  sl
               sta  DBYTLO
               lda  sh
               sta  DBYTHI
               jsr  $E459
               
               sty  SIOresult
          };

     end;



procedure exitToDOS;
     begin
          asm {
               jmp ($a)
               rts
          };
     end;



procedure coldStart;
     begin
          asm {
               jmp $e477;
               rts
          };
     end;



function breakPressed:boolean;
     begin
          if CIOResult = 128 then 
               result := true
          else 
               result := false;
     end;
     


procedure clearKeys;
     begin
          CH := $ff; key := #0;
     end;
     
     
     
procedure pressKey;
     begin
     
          clearKeys;
          Delay(2);
     
          Writeln;
          Writeln('Press key...');
          Writeln;
          repeat until keypressed;
          
     end;
     
     

procedure clearBuffer;
     begin
          fillbyte(pointer(COPY_BUFFER_MEM), 512, 0);
     end;
     
   
   
procedure clearLogBuffer;
     begin
          fillbyte(pointer(LOG_BUFFER), 20160, 0);
     end;
     
   
   
procedure clearPercomBuffer;
     begin
          fillbyte(pointer(PERCOM_BUFFER_MEM), 14, 0);
     end;
     


procedure parseInput(numberOfBytesToRead: byte);
     begin

          tmpString := '';
          
          for tmpByte := 0 to numberOfBytesToRead do begin
               if Peek(COPY_BUFFER_MEM + tmpByte) <> $9b then begin
                    tmpString := Concat(tmpString, Chr(Peek(COPY_BUFFER_MEM + tmpByte)));
               end else begin
                    break;
               end;
          end;
          
     end;



function GetBit(Value: Byte; Index: Byte): Boolean;
     begin
          Result := ((Value shr Index) and 1) = 1;
     end;



procedure readPercom(drive: byte; silent: boolean);
     begin
     
          {$i-}
     
          number_of_sectors := 0;

          clearPercomBuffer;
          
          { Read status }
     
          exec_sio(drive, READ_STATUS, SIO_READ, 7, PERCOM_BUFFER_MEM, 4, 0);
          
          { for tmpByte := 0 to 7 do begin }
               { Write(GetBit(Peek(PERCOM_BUFFER_MEM),tmpByte), ', '); }
          { end; }
          
          
          { Read dummy sector }
          { exec_sio(drive, READ_SECTOR, SIO_READ, 7, COPY_BUFFER_MEM, 128, 1); }
          
          { Read Percom }
          exec_sio(drive, READ_PERCOM, SIO_READ, 7, PERCOM_BUFFER_MEM, 12, 0);
          
          case SIOresult of
          
               138: Writeln('Drive does not respond.');
               139: begin
                         if not silent then begin
                              Writeln('Drive does not support PERCOM.');
                              Writeln('Probably Atari 810 or Atari 1050.');
                              Writeln('Trying to detect density...');
                         end;
                         exec_sio(drive, READ_SECTOR, SIO_READ, $7, PERCOM_BUFFER_MEM, 128, 721);
                         if SIOresult = 1 then begin
                              number_of_sectors := 1040;
                              bytes_per_sector := 128;
                         end else begin
                              number_of_sectors := 720;
                              bytes_per_sector := 128;
                         end;
                         if not silent then begin
                              if drive = 1 then begin
                                   bytes_per_sector_source := bytes_per_sector;
                                   writeln (number_of_sectors, ' sectors of ', bytes_per_sector_source, ' bytes.');
                              end else begin
                                   bytes_per_sector_dest := bytes_per_sector;
                                   writeln (number_of_sectors, ' sectors of ', bytes_per_sector_dest, ' bytes.');
                              end;
                         end;
                         SIOresult := 1;
                         if drive = 1 then 
                              source_drive_not_configurable := true
                         else 
                              dest_drive_not_configurable := true;
                    end
               
               else begin
               
                    for tmpByte := 0 to 11 do begin
                         tmpWord := PERCOM_BUFFER_MEM + tmpByte;
                         percomBlock[tmpByte] := Peek(tmpWord);
                    end;
                    
                    number_of_sectors := percomBlock[0] * (percomBlock[2] * $100 + percomBlock[3]);
                    number_of_sectors := number_of_sectors * (percomBlock[4] + 1);
                    bytes_per_sector := percomBlock[6] * $100 + percomBlock[7];
                    
                    if drive = 1 then source_drive_not_configurable := false
                    else dest_drive_not_configurable := false;
                    
                    if not silent then begin
                         if drive = 1 then begin
                              bytes_per_sector_source := bytes_per_sector;
                              writeln (number_of_sectors, ' sectors of ', bytes_per_sector, ' bytes.');
                         end else begin
                              bytes_per_sector_dest  := bytes_per_sector;
                              writeln (number_of_sectors, ' sectors of ', bytes_per_sector, ' bytes.');
                         end;
                    end else begin
                         if drive = 1 then begin
                              bytes_per_sector_source  := bytes_per_sector;
                         end else begin
                              bytes_per_sector_dest  := bytes_per_sector;
                         end;
                    end;
               end;
          end;
          
          {$i+}
          
     end;



procedure errorMessage(err: byte);
     begin
          Str(err, tmpString);
          write('Status: ');
          if err > $7f then begin
               writeln('error ', tmpString); 
          end else writeln('OK');
     end;



procedure writeMenu;
     begin
     
          writeln;
     
          Str(source_drive, tmpString);
          writeln ('Current source drive: D', tmpString);
          readPercom(source_drive, false);
          Writeln ('-------------------------------------');
          if dest_drive < 255 then begin
               Str(dest_drive, tmpString2);
               writeln ('Current destination drive: D', tmpString2);
               readPercom(dest_drive, false);
          end else begin
               Writeln ('Destination drive not set');
          end;
          
          writeln;
          writeln ('R'*' - Read drive configuration');
          writeln ('W'*' - Write drive configuration');
          writeln ('F'*' - Format drive');
          writeln ('D'*' - Set source, destination drives');
          writeln ('X'*' - Exchange source and destination');
          writeln ('C'*' - Copy sectors');
          writeln;
          writeln ('Q'*' - Exit to DOS');
          writeln ('B'*' - Cold start');
          writeln;
          
     end;



procedure swapDrives;
     begin
     
          if (dest_drive = 255) or (source_drive = 255) then begin
          
               Writeln ('One of drives is not set.');
               Writeln ('Can not exchange. ');
               
          end else begin
          
               tmpByte := source_drive;
               source_drive := dest_drive;
               dest_drive := tmpByte;
               
               tmpBool := source_drive_not_configurable;
               source_drive_not_configurable := dest_drive_not_configurable;
               dest_drive_not_configurable := tmpBool;
               
               tmpWord := bytes_per_sector_source;
               bytes_per_sector_source := bytes_per_sector_dest;
               bytes_per_sector_dest := tmpWord;
               
               Writeln ('Drive were swapped.');
          
          end;
          
          pressKey;
          
          writeMenu;
          
     end;
     

     
label formatSel, notPercom, exitFormat;
procedure format;
     begin
          
          clearKeys;
          
          Delay(10);
          
          
          Writeln ('S - Source drive');
          Writeln ('D - Destination drive');
          
          formatSel:
          if keypressed then begin key := ReadKey end else goto formatSel;
          
          case key of
               'S', 's': begin tmpByte2 := source_drive; tmpWord := bytes_per_sector_source end;
               'D', 'd': begin tmpByte2 := dest_drive; tmpWord := bytes_per_sector_dest end;
               #27     : goto exitFormat;
               else goto formatSel;
          end;
     
          clearKeys;
          Delay(2);
     
          if ((tmpByte2 = source_drive) and source_drive_not_configurable) or ((tmpByte2 = dest_drive) and dest_drive_not_configurable) then begin
          
               Writeln;
               Writeln('This drive is not configurable');
               Writeln('Only ','S'*' - 90 KB, ','E'*' - 130 KB');
               Writeln('densities are available.');
               
               notPercom:
               if keypressed then begin key := ReadKey end else goto notPercom;
               
               case key of
                    'S', 's': begin writeln; writeln('Formatting disk.'); exec_sio(tmpByte2, FORMAT_SINGLE, SIO_READ, $40, COPY_BUFFER_MEM, 128, 1); end;
                    'E', 'e': begin writeln; writeln('Formatting disk.'); exec_sio(tmpByte2, FORMAT_ENHANCED, SIO_READ, $40, COPY_BUFFER_MEM, 128, 1); end;
                    #27     : goto exitFormat;
                    else goto notPercom;
               end;
               
          end else begin
               writeln;
               writeln('Formatting disk.');
               exec_sio(tmpByte2, FORMAT_DISK, SIO_READ, $40, COPY_BUFFER_MEM, tmpWord, 1);
          end;

          errorMessage(SIOresult);
          
          exitFormat:
          
          pressKey;
          
          writeMenu;
     end;



label driveSelectionSource;
procedure changeDrives;
const
          tmpArr: array[0..1] of string[11] = ('source', 'destination');

     var 
          tmpByte3: byte;
     begin
     
          clearKeys;
          Delay(2);
          
          tmpByte3 := 0;
          
          while tmpByte3 < 2 do begin
          
               Writeln;
               Writeln('Select ', tmpArr[tmpByte3], ' drive number (1-8)');
               
               driveSelectionSource:
               
               if keypressed then key := ReadKey else goto driveSelectionSource;
               
               if key = #27 then Break;
               
               selected_drive := byte(key)-48;
               
               if (selected_drive < 1) or (selected_drive > 8) then begin
                    Writeln;
                    Writeln('Select ', tmpArr[tmpByte3], ' drive number (1-8)');
                    goto driveSelectionSource;
               end;
               
               readPercom(selected_drive, true);
               
               if SIOresult > 127 then begin
                    Writeln;
                    Writeln ('Select ', tmpArr[tmpByte3], ' drive number (1-8)');
                    goto driveSelectionSource;
               end;
               
               if tmpByte3 = 0 then begin
                    source_drive := selected_drive
               end else begin 
                    if selected_drive = source_drive then begin
                         Writeln;
                         Writeln ('Destination drive number must be '); 
                         Writeln ('different than source number.');
                         Writeln;
                         Writeln ('Select ', tmpArr[tmpByte3], ' drive number (1-8)');
                         goto driveSelectionSource;
                    end;
                    dest_drive := selected_drive;
               end;
               
               clearKeys;
               Delay(50);
               
               inc(tmpByte3);
          
          end;
         
          writeMenu;
          
     end;



label percomSel, writePercomSelDrive, writePercomAbort;
procedure writePercom;
     begin

          clearKeys;
          
          Delay(10);
          
          Writeln ('S - Source drive');
          Writeln ('D - Destination drive');
          
          writePercomSelDrive:
          
          if keypressed then begin key := ReadKey end else goto writePercomSelDrive;
          
          case key of
               'S', 's': begin 
                              tmpByte2 := source_drive; 
                              if source_drive_not_configurable then begin
                                   Writeln('This drive is not configurable.');
                                   Writeln('Press any key.');
                                   repeat until keypressed;
                                   goto writePercomAbort;
                              end;
                         end;
               'D', 'd': begin 
                              tmpByte2 := dest_drive;
                              if source_drive_not_configurable then begin
                                   Writeln('This drive is not configurable.');
                                   Writeln('Press any key.');
                                   repeat until keypressed;
                                   goto writePercomAbort;
                              end;
                         end;
               #27     : goto writePercomAbort;
               else goto writePercomSelDrive;
          end;
          
          clearKeys;
          Delay(10);
     
          writeln;
          writeln ('Select drive configuration:');
          writeln ('1 - SS SD  (90 KB)');
          writeln ('2 - SS ED (130 KB)');
          writeln ('3 - SS DD (180 KB)');
          writeln ('4 - DS DD (360 KB)');
          writeln ('5 - DS QD (720 KB)');
          
          percomSel:
          
          if keypressed then key := ReadKey;

          case key of
               '1': begin
                         for tmpByte := 0 to 11 do begin
                              tmpWord := PERCOM_BUFFER_MEM + tmpByte;
                              Poke(tmpWord, SSSD[tmpByte]);
                         end;
                         requestedSectorSize := 128;
                         requestedSectors := 720;
                    end;
               '2': begin
                         for tmpByte := 0 to 11 do begin
                              tmpWord := PERCOM_BUFFER_MEM + tmpByte;
                              Poke(tmpWord, SSED[tmpByte]);
                         end;
                         requestedSectorSize := 128;
                         requestedSectors := 1040;
                    end;
               '3': begin
                         for tmpByte := 0 to 11 do begin
                              tmpWord := PERCOM_BUFFER_MEM + tmpByte;
                              Poke(tmpWord, SSDD[tmpByte]);
                         end;
                         requestedSectorSize := 256;
                         requestedSectors := 720;
                    end;
               '4': begin
                         for tmpByte := 0 to 11 do begin
                              tmpWord := PERCOM_BUFFER_MEM + tmpByte;
                              Poke(tmpWord, DSDD[tmpByte]);
                         end;
                         requestedSectorSize := 256;
                         requestedSectors := 1440;
                    end;
               '5': begin
                         for tmpByte := 0 to 11 do begin
                              tmpWord := PERCOM_BUFFER_MEM + tmpByte;
                              Poke(tmpWord, DSQD[tmpByte]);
                         end;
                         requestedSectorSize := 256;
                         requestedSectors := 2880;
                    end;
               #27: goto writePercomAbort;
               else goto percomSel;
          end;
     
          { exec_sio(tmpByte2, WRITE_PERCOM, SIO_WRITE, 7, PERCOM_BUFFER_MEM, 12, 0); }
          exec_sio(tmpByte2, WRITE_PERCOM, SIO_WRITE, 7, PERCOM_BUFFER_MEM, 12, 0);

          Writeln;
          errorMessage(SIOresult);
          
          if SIOresult = 1 then begin
               readPercom(tmpByte2, true);
               if (requestedSectors = number_of_sectors) and (requestedSectorSize = bytes_per_sector) then begin
                    Writeln('Configuration confirmed');
               end else begin
                    Writeln('Warning. Drive may not support that');
                    Writeln('configuration. Proceed with caution!');
               end;
          end;
          
          pressKey;
          
          writePercomAbort:
          
          writeMenu;
          
     end;
     


label copyErrorKey;
function copyError(SIOresultC: byte; current_sector: word; operation: byte) : byte;
     var c: string;
     begin
          if operation = 1 then c := 'reading'
          else c:= 'writing';
          
          Writeln;
          Writeln;
          Writeln('Error ', SIOresultC, ' ', c, ' sector ', current_sector, '.');
          Writeln('A'*' - Abort, ','R'*' - Retry, ','S'*' - Skip,');
          
          if operation = 1 then begin
               Writeln ('W'*' - write buffer and continue.');
          end;

          Writeln;

          clearKeys;
          Delay(2);
          
          copyErrorKey:
          
          if keypressed then begin key := ReadKey end else goto copyErrorKey;
          
          case key of
               'A', 'a': Result := 1;
               'R', 'r': Result := 2;
               'S', 's': Result := 3;
               'W', 'w': Result := 4;
               else goto copyErrorKey;
          end;

     end;



label writeLogDriveDialog, writeLogExit;
procedure writeLog(logFileSize: word);
     var logFileBuffer: pointer;
     begin
     
          {$i-}
     
          logFileBuffer := pointer(LOG_BUFFER);
          logFileSize := logFileSize * 7;
     
          writeLogDriveDialog:
     
               clearKeys;
               clearBuffer;
               
               writeln;
               writeln('Enter filename with drive number.');
               writeln('Eg. D1:LOGFILE.LOG');

               getString(16);
                    
               if breakPressed then begin
                    Writeln ('Break key pressed, aborting');
                    Goto writeLogExit;
               end;
               
               parseInput(16);
               
               if (Ord(tmpString[2]) < 48) or (Ord(tmpString[2]) > 57) then goto writeLogDriveDialog;
               
          Assign(f, tmpString);
          Rewrite(f,1);
          Blockwrite(f, logFileBuffer, logFileSize);
          
          Writeln;

          if ioresult > 127 then
               Writeln ('Error ', ioresult)
          else
               Writeln ('File saved');
          
          close(f);
          
          {$i+}
          
          writeLogExit:
     
     end;
     


procedure putToLog(info: byte);
     var
          sector_number: string[4];
          sector_data: string[7];
          space_number: byte;
     begin
     
          if sectors_to_read < 2881 then begin
               Str(current_sector, sector_number);
               space_number := 4 - Length(sector_number);
               sector_data := Concat(Space(space_number), sector_number);
               sector_data := Concat(sector_data, Chr(58));
               sector_data := Concat(sector_data, Chr(info));
               sector_data := Concat(sector_data, Chr(EOL));
               move(sector_data[1], pointer(LOG_BUFFER + sector_index), 7);
               sector_index := sector_index + 7;
          end;
          
     end;

     
     
label sectorSize, startSector, endSector, logFileDialog, copyExit;
procedure copy;
     var
          current_sector_write: word;
          destination: word;
     begin
     
          if dest_drive = 255 then begin
               Writeln ('Destination drive not set.');
               pressKey;
               goto copyExit;
          end;
          
          if bytes_per_sector_source <> bytes_per_sector_dest then begin
               Writeln('Sector size in destination drive do ');
               Writeln('not match sector size in source ');
               Writeln('drive. Are you sure (Y/N)?');

               clearKeys;
               
               sectorSize:
          
               if keypressed then begin key := ReadKey end else goto sectorSize;
               
               case key of
                    'Y', 'y': goto startSector;
                    'N', 'n': goto copyExit;
                    else goto sectorSize;
               end;
               
          end;
          
          startSector:
          
               clearKeys;
               clearBuffer;
               
               writeln('Start sector:');
               getString(6);

               if breakPressed then begin
                    Writeln ('Break key pressed, aborting');
                    Goto copyExit;
               end;
               
               parseInput(5);
               
               Val(tmpString, start_sector, Code);
          
               if Code > 0 then goto startSector;
               
               if start_sector >= number_of_sectors then begin
                    writeln ('Start sector is greater than total');
                    writeln ('number of sectors.');
                    goto startSector;
               end;
               
               if start_sector < 1 then begin
                    writeln ('Lowest sector number is 1');
                    goto startSector;
               end;
          
          endSector:
          
               clearKeys;
               clearBuffer;
               
               writeln('End sector:');
               getString(6);
               
               if breakPressed then begin
                    Writeln ('Break key pressed, aborting');
                    Goto copyExit;
               end;
               
               parseInput(5);
               
               val(tmpString, end_sector, Code);
          
               if Code > 0 then goto endSector;
               
               if end_sector > number_of_sectors then begin
                    writeln ('End sector is greater than total ');
                    writeln ('number of sectors.');
                    goto endSector;
               end;

               if end_sector < start_sector then begin
                    writeln ('End sector is lesser than start');
                    writeln ('sector.');
                    goto endSector;
               end;

          sectors_to_read := end_sector - start_sector + 1;
   
          writeln('Copying ', sectors_to_read, ' sectors.');
          
          clearBuffer;
          
          current_sector := start_sector;
          current_sector_write := start_sector;
          
          destination := COPY_BUFFER_MEM;
          
          CursorOff;
          clearLogBuffer;
          sector_index := 0;
          
          Writeln;
          
          while current_sector <= end_sector do begin
          
               clearBuffer;
               
               cursor_y := WhereY;
               GotoXY(3, cursor_y);
               Write('Reading and writing sector #', current_sector);
               
               if current_sector < 4 then begin
                    exec_sio(source_drive, READ_SECTOR, SIO_READ, $7, destination, 128, current_sector);
                    if SIOresult > 127 then begin
                         putToLog(LOG_READ_ERROR);
                         case copyError(SIOresult, current_sector, 1) of
                              1: break;
                              2: continue;
                              3: Inc(current_sector);
                         end;
                    end else begin
                         putToLog(LOG_READ_SUCCESS);
                    end;
                    exec_sio(dest_drive, PUT_SECTOR, SIO_WRITE, $7, destination, 128, current_sector);
                    if SIOresult > 127 then begin
                         putToLog(LOG_WRITE_ERROR);
                         case copyError(SIOresult, current_sector, 2) of
                              1: break;
                              2: continue;
                              3: Inc(current_sector);
                         end;
                    end;
               end else begin
                    exec_sio(source_drive, READ_SECTOR, SIO_READ, $7, destination, bytes_per_sector, current_sector);
                    if SIOresult > 127 then begin
                         putToLog(LOG_READ_ERROR);
                         case copyError(SIOresult, current_sector, 1) of
                              1: break;
                              2: continue;
                              3: Inc(current_sector);
                         end;
                    end else begin
                         putToLog(LOG_READ_SUCCESS);
                    end;
                    exec_sio(dest_drive, PUT_SECTOR, SIO_WRITE, $7, destination, bytes_per_sector, current_sector);
                    if SIOresult > 127 then begin
                         putToLog(LOG_WRITE_ERROR);
                         case copyError(SIOresult, current_sector, 2) of
                              1: break;
                              2: continue;
                              3: Inc(current_sector);
                         end;
                    end;
               end;
               
               inc(current_sector);
               
          end;
               
          CursorOn;
               
          Writeln;
          Writeln;
          Writeln ('Copy finished.');
          
          if sectors_to_read < 2881 then begin
          
               Writeln;
               Writeln ('Write log file to disk? (Y/N)');
               
               clearKeys;
                    
               logFileDialog:
          
                    if keypressed then key := ReadKey else goto logFileDialog;
                    
                    case key of
                         'Y', 'y': writeLog(sectors_to_read);
                         'N', 'n': goto copyExit;
                         else goto logFileDialog;
                    end;
          end;
          
          pressKey;

          copyExit:
               
          writeMenu;
          
     end;



label start, menu;
begin

     start:
     
     source_drive := 1;
     dest_drive := 255;
     
     source_drive_not_configurable := true;
     dest_drive_not_configurable := true;
     
     ClrScr;
     clearPercomBuffer;
    
     writeln ('MILF 0.7 - dely/bjb 2020');
     writeln;
     
     writeMenu;
     
     menu:

     if keypressed then key := ReadKey;
     
     case key of
          'R', 'r' : writeMenu;
          'W', 'w' : writePercom;
          'F', 'f' : format;
          'D', 'd' : changeDrives;
          'C', 'c' : copy;
          'X', 'x' : swapDrives;
          'Q', 'q' : exitToDOS;
          'B', 'b' : coldStart;
          else begin Goto menu; end;
     end;

     clearKeys;
     
     goto menu;

end.