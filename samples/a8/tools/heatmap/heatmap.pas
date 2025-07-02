Program Heatmap;

Uses atari, crt, cio, stringUtils, graph, sysutils;

Const
    RECORD_BUFFER = $8000;                   // Buffer for records
    TEXT_BUFFER = $9000;                     // Buffer for CIO

Var
    Code                 : byte;             // Result of String → Integer conversion
    rec                  : string;           // Record contents

    freeChannel          : byte;             // Number of first free channel found
    filename             : string[16];       // File name entered by user

    tableComment         : string;           // DIF file table comment (not used)
    ColComment           : string;           // DIF file column comment (not used)
    RowComment           : string;           // DIF file row comment (not used)
    DataComment          : string;           // DIF file data comment (not used)

    numRows              : integer;          // Number of rows in DIF file
    numCols              : integer;          // Number of columns in DIF file
    commaPos             : byte;             // Position of comma in record (typically 2)
    valueString          : string[10];       // Value as string

    dataSize             : word;             // dimension of data in DIF file
    recordCounter        : word;
    recordsSkipped       : word;             // How many records were skipped due to incorrect format (string)
    dataMax              : integer;          // Data table max value
    dataMin              : integer;          // Data table min value

    rowIter              : byte;             // Iterators
    colIter              : byte;

    inputRange           : integer;          // Range of values in DIF file

    xMargin              : byte;             // Margins of heatmap - used for centering
    yMargin              : byte;

    data                 : array[0..40,0..40] of integer;                                 // Array with data for analysis
    colorsTab            : array[0..14] of byte = (7,8,9,10,11,12,13,14,15,1,2,3,4,5,6);  // Array with rearranged color order

    CH                   : byte absolute $02fc;   // Last pressed key
    key                  : char;                  // Pascal's key var
    CIOResult            : byte;                  // CIO last result

    userExits            : boolean = false;       // User exit flag



procedure clearKeys;
(*
* @description:
* Clear last pressed keys
*)
begin
     CH := $ff; key := #0;
end;


function getString(maxChars: byte): Tstring;
(*
* @description:
* Get text record and returns as Tstring. Equivalent in Atari BASIC: INPUT VAR$
*
* @param: (byte) maxChars - max number of chars to process
* @returns: (Tstring) - Record contents.
*)
var
     cnt  : byte;
     path  : Tstring;
     isAnother: boolean;
     success: boolean;

begin

     success := false;

     While Not success do begin

          Writeln('Enter filename (eg. D:FILENAME.DIF).');
          Writeln('Enter * for list of supported files');
          Writeln('in current directory.');
          Writeln('Press '+'BREAK'*' to exit to DOS');
          Writeln;

          asm {

               iccmd    = $0342
               icbufa   = $0344
               icbufl   = $0348

               lda #<TEXT_BUFFER
               ldy #>TEXT_BUFFER
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
               sty CIOResult;
          };

          if CIOResult = 128 then begin
               Writeln ('Break pressed. Aborting.');
               Halt;
          end;

          // Check if user requests directory

          if Peek(TEXT_BUFFER) = Ord('*') then begin

               Writeln('Reading directory.');
               Writeln;

               Opn(freeChannel,6,0,'D:*.DIF');

               isAnother := true;

               while isAnother do begin
                    rec := RGet(freeChannel, pointer(RECORD_BUFFER));
                    if rec[1] = ' ' then begin Writeln(rec); end else begin isAnother:=false; end;
               end;

               Cls(freeChannel);
               Writeln;

               clearKeys;

          end else begin

               success := true;

          end;

     end;

     // Check if user forgot to enter device

     if (Peek(TEXT_BUFFER) <> Ord('D')) And (Peek(TEXT_BUFFER+1) <> Ord(':')) Then begin
          path := 'D:';
     end else begin
          path := '';
     end;

     // Counter

     cnt := 0;

     // Move result record to result variable

     While Peek(TEXT_BUFFER + cnt) <> $9b do begin
          path := Concat(path, Chr(Peek(TEXT_BUFFER + cnt)));
          Inc(cnt);
     end;

     Result := path;
end;


procedure OpenFile;
(*
* @description:
* Get file name from user, open it and check if it is correct DIF file
*)
var
     success: boolean;
begin
     // Find first free IOCB

     freeChannel := FindFirstFreeChannel;

     // Check for error

     if freeChannel = 161 then begin
          Writeln ('Too many open disk files. Aborting');
          Halt;
     end;

     // Channel must be divided by 16

     freeChannel := freeChannel shr 4;

     // Get filename

     success := false;

     clearKeys;

     While Not success do begin

          filename := getString(16);

          // Open found channel for reading

          Opn(freeChannel,4,0,filename);

          // Check if file was successfully open

          If IOResult <> 1 then begin
               Writeln ('File not found.');
               Writeln;
               Cls(freeChannel);
          end else begin
               success := true;
          end;


     end;

     // Check for correct header

     rec := RGet(freeChannel, pointer(RECORD_BUFFER));

     If rec <> 'TABLE' then begin
          Writeln ('This is not a DIF file. Aborting');
          Cls(freeChannel);
          Halt;
     end;
end;


function ConvertValue(rec: Tstring): integer;
(*
* @description:
* Convert DIF record to Integer
*
* @param: (Tstring) rec - record
* @returns: (Integer) - value as integer.
*)
begin

     commaPos := strPos(',', rec);
     valueString := strRight(rec, Length(rec)-commaPos);
     Val(valueString, Result, Code);

end;


procedure ParseTable;
(*
* @description:
* Parse opened file
*)
begin
     Writeln;
     Writeln ('Parsing file.');
     Writeln ('Looking for table definition.');

     RSkip(freeChannel, pointer(RECORD_BUFFER));                   // 0,1
     tableComment := RGet(freeChannel, pointer(RECORD_BUFFER));    // Comment

     // Get number of columns

     rec := RGet(freeChannel, pointer(RECORD_BUFFER));
     if rec <> 'VECTORS' then begin
          Writeln ('Columns info missing. Aborting.');
          Cls(freeChannel);
          Halt;
     end;

     rec := RGet(freeChannel, pointer(RECORD_BUFFER));              // Row data

     numRows := ConvertValue(rec);

     RowComment := RGet(freeChannel, pointer(RECORD_BUFFER));       // Comment

     Writeln('Number of rows: ', numRows);

     If numRows > 40 then begin
          Writeln ('Max number of rows: 40. Aborting.');
          Cls(freeChannel);
          Halt;
     end;

     // Get number of rows

     rec := RGet(freeChannel, pointer(RECORD_BUFFER));
     if rec <> 'TUPLES' then begin
          Writeln ('Rows info missing. Aborting.');
          Cls(freeChannel);
          Halt;
     end;

     rec := RGet(freeChannel, pointer(RECORD_BUFFER));

     numCols := ConvertValue(rec);

     ColComment := RGet(freeChannel, pointer(RECORD_BUFFER));       // Comment

     Writeln('Number of columns: ', numCols);

     If numRows > 40 then begin
          Writeln ('Max number of rows: 40. Aborting.');
          Cls(freeChannel);
          Halt;
     end;

     // Find data

     rec := RGet(freeChannel, pointer(RECORD_BUFFER));
     if rec <> 'DATA' then begin
          Writeln ('Data info missing. Aborting.');
          Cls(freeChannel);
          Halt;
     end;

     Writeln('Data found. Parsing records.');
     Writeln;
     Writeln;

     CursorOff;

     RSkip(freeChannel, pointer(RECORD_BUFFER));              // 0,0
     DataComment := RGet(freeChannel, pointer(RECORD_BUFFER));      // Comment
     RSkip(freeChannel, pointer(RECORD_BUFFER));              // -1,0

     dataSize := numCols * numRows;

     recordCounter := 1;
     recordsSkipped := 0;

     For colIter := 0 to numRows-1 do begin

          RSkip(freeChannel, pointer(RECORD_BUFFER)); // BOT

          For rowIter := 0 to numCols-1 do begin

               Write(#28'Record ', recordCounter); Writeln(' of ', dataSize);

               rec := RGet(freeChannel, pointer(RECORD_BUFFER));

               if rec[1] = '1' then begin
                    data[colIter,rowIter] := 0;
                    Inc(recordsSkipped);
               end else begin
                    data[colIter,rowIter] := ConvertValue(rec);
               end;

               Inc(recordCounter);

               RSkip(freeChannel, pointer(RECORD_BUFFER)); // V

          end;

          RSkip(freeChannel, pointer(RECORD_BUFFER)); // -1,0

     end;

     Writeln ('Data parsed and loaded.');

     // Close channel

     Cls(freeChannel);

     if recordsSkipped > 0 then Writeln('Number of string fields skipped: ', recordsSkipped);

     CursorOn;

end;


procedure CalculateHeatmap;
(*
* @description:
* Calculate minimum and maximum values, normalize data
*)
begin

     // Find min, max value

     Writeln ('Looking for minimum and maximum.');

     dataMax := -2147483648;
     dataMin := 2147483647;

     for rowIter := 0 to numRows-1 do begin

          for colIter := 0 to numCols-1 do begin

               if data[rowIter, colIter] > dataMax then begin
                    dataMax := data[rowIter, colIter];
               end;
               if data[rowIter, colIter] < dataMin then begin
                    dataMin := data[rowIter, colIter];
               end;

          end;

     end;

     Write ('Max: ', dataMax); Writeln (' Min: ', dataMin);
     Writeln;

     If (dataMax > 14) or (dataMin < 0) then begin

          Writeln ('Data need normalisation.');

          // Min-max normalization

          Writeln ('Attempting to normalise the data.');
          Writeln ('Please wait.');

          // Do normalize

          inputRange := dataMax - dataMin;

          for rowIter := 0 to numRows-1 do begin

               for colIter := 0 to numCols-1 do begin

                    // output = output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start)

                    data[rowIter, colIter] := Round((14 / inputRange) * (data[rowIter, colIter] - dataMin));

               end;

          end;

     end;

     Writeln ('Normalisation complete.');
     Writeln ('Press any key to display as heatmap.');

     Repeat Until Keypressed;

     clearKeys;

end;


procedure DisplayHeatmap;
(*
* @description:
* Display data in Graphics 11 mode
*)
begin

     // Display as bitmap

     Initgraph(11);

     // Center on screen - X axis

     xMargin := (80 - numCols) div 2;

     // Center on screen - Y axis

     yMargin := (80 - numRows) div 2;

     for rowIter := 0 to numRows-1 do begin

          for colIter := 0 to numCols-1 do begin

               SetColor(colorsTab[data[rowIter,colIter]]);
               PutPixel(colIter+xMargin, yMargin);
               PutPixel(colIter+xMargin, yMargin+1);
               PutPixel(colIter+xMargin, yMargin+2);
               PutPixel(colIter+xMargin, yMargin+3);

          end;

          yMargin := yMargin + 4;
     end;



     Repeat Until Keypressed;

     clearKeys; Pause(1);

end;


begin

     Writeln;
     Writeln ('Heatmap 0.5 by dely/Blowjobb 2021');
     Writeln ('http://www.atari.org.pl');
     Writeln;

     Repeat

          OpenFile;
          ParseTable;
          CalculateHeatmap;
          DisplayHeatmap;

     Until userExits;

     Halt;

end.
