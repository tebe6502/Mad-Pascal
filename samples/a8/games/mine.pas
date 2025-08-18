(*

 https://www.youtube.com/watch?v=8UJNQt8DAWE

 https://github.com/tsoding/mine


  key          description
 --------------------------------
 w,a,s,d      Move cursor around
 SPACE        Open cell
 f            Flag/unflag cell
 r            Restart
 q            Quit

 P            Peek behind closed cells (DEBUG)

*)

//
//  FPC (MadPascal) version by Tomasz Biela ( 18.08.2025 )
//

program mine;

uses crt
{$IFDEF ATARI}
,efast
{$ENDIF}
;

//{$define DEBUG}

const
   HardcodedFieldRows = 10;
   HardcodedFieldCols = 10;
   HardcodedBombsPercentage = 17;

type
   Cell = (Empty, Bomb);
   State = (Closed, Open, Flagged);

   TMessage = string[31];

   Field = record
      Generated: Boolean;
      Cells: array [0..HardcodedFieldRows-1, 0..HardcodedFieldCols-1] of byte;
      States: array [0..HardcodedFieldRows-1, 0..HardcodedFieldCols-1] of byte;
      Rows: byte;
      Cols: byte;
      CursorRow: byte;
      CursorCol: byte;
      {$ifdef DEBUG}
      Peek: Boolean;
      {$endif}
   end;

   YornKeep = (KeepNone = 0, KeepYes = 1, KeepNo = 2, KeepBoth = 3);


var
   MainField: Field;
   Cmd: Char;
   Quit: Boolean;


   function IsVictory(var Field: Field): Boolean;
   var
      Row, Col: byte;
   begin
      with Field do
         for Row := 0 to Rows-1 do
            for Col := 0 to Cols-1 do
               case State(States[Row][Col]) of
                  Open:            if Cells[Row][Col] <> ord(Empty) then Exit(False);
                  Closed, Flagged: if Cells[Row][Col] <> ord(Bomb)  then Exit(False);
               end;
      IsVictory := True;
   end;

   procedure FlagAtCursor(var Field: Field);
   begin
      with Field do
         case State(States[CursorRow][CursorCol]) of
            Closed:  States[CursorRow][CursorCol] := ord(Flagged);
            Flagged: States[CursorRow][CursorCol] := ord(Closed);
         end
   end;

   procedure RandomCell(var Field: Field; var Row, Col: byte);
   begin
      Row := Random(Field.Rows);
      Col := Random(Field.Cols);
   end;

   function IsAroundCursor(var Field: Field; Row, Col: byte): Boolean;
   var
      DRow, DCol: shortint;
   begin
      for DRow := -1 to 1 do
         for DCol := -1 to 1 do
            if (byte(Field.CursorRow + DRow) = Row) and (byte(Field.CursorCol + DCol) = Col) then
               Exit(True);
      IsAroundCursor := False;
   end;

   procedure FieldRandomize(var Field: Field; BombsPercentage: byte);
   var
      Index, BombsCount: byte;
      Row, Col: byte;
   begin
      with Field do
      begin
         for Row := 0 to Rows - 1 do
            for Col := 0 to Cols - 1 do
               Cells[Row][Col] := ord(Empty);
         if BombsPercentage > 100 then BombsPercentage := 100;
         BombsCount := (Rows*Cols*BombsPercentage + 99) div 100;
         for Index := 1 to BombsCount do
         begin
            { TODO: prevent this loop going indefinitely }
            repeat
               RandomCell(Field, Row, Col)
            until (Cells[Row][Col] <> ord(Bomb)) and not IsAroundCursor(Field, Row, Col);
            Cells[Row][Col] := ord(Bomb);
         end;
      end;
   end;

   function FieldContains(var Field: Field; Row, Col: byte): Boolean;
   begin
      FieldContains := (0 <= Row) and (Row < Field.Rows) and (0 <= Col) and (Col < Field.Cols);
   end;

   function CountNborBombs(var Field: Field; Row, Col: byte): byte;
   var
      DRow, DCol: shortint;
   begin
      Result := 0;
      with Field do
         for DRow := -1 to 1 do
            for DCol := -1 to 1 do
               if (DRow <> 0) or (DCol <> 0) then
                  if FieldContains(Field, Row + DRow, Col + DCol) then
                     if Cells[byte(Row + DRow)][byte(Col + DCol)] = ord(Bomb) then
                        Inc(Result);
   end;

   function CountNborFlags(var Field: Field; Row, Col: byte): byte;
   var
      DRow, DCol: shortint;
   begin
      Result := 0;
      with Field do
         for DRow := -1 to 1 do
            for DCol := -1 to 1 do
               if (DRow <> 0) or (DCol <> 0) then
                  if FieldContains(Field, Row + DRow, Col + DCol) then
                     if States[byte(Row + DRow)][byte(Col + DCol)] = ord(Flagged) then
                        Inc(Result);
   end;

   function OpenAt(var Field: Field; Row, Col: byte): Boolean;
   var
      DRow, DCol: shortint;
   begin
      with Field do
      begin
         if not Generated then
         begin
            FieldRandomize(Field, HardcodedBombsPercentage);
            Generated := True;
         end;

         States[Row][Col] := ord(Open);

         if CountNborBombs(Field, Row, Col) = CountNborFlags(Field, Row, Col) then
            for DRow := -1 to 1 do
               for DCol := -1 to 1 do
                  if FieldContains(Field, DRow + Row, DCol + Col) then
                     if States[byte(DRow + Row)][byte(DCol + Col)] = ord(Closed) then
                        if OpenAt(Field, DRow + Row, DCol + Col) then
                           Exit(True);

         OpenAt := Cells[Row][Col] = ord(Bomb);
      end
   end;

   function OpenAtCursor(var Field: Field): Boolean;
   begin
      OpenAtCursor := OpenAt(Field, Field.CursorRow, Field.CursorCol);
   end;

   procedure FlagAllBombs(var Field: Field);
   var
       Row, Col: byte;
   begin
      with Field do
         for Row := 0 to Rows - 1 do
            for Col := 0 to Cols - 1 do
               if Cells[Row][Col] = ord(Bomb) then
                  States[Row][Col] := ord(Flagged);
   end;

   procedure OpenAllBombs(var Field: Field);
   var
      Row, Col: byte;
   begin
      with Field do
         for Row := 0 to Rows - 1 do
            for Col := 0 to Cols - 1 do
               if Cells[Row][Col] = ord(Bomb) then
                  States[Row][Col] := ord(Open);
   end;

   procedure FieldReset(var Field: Field; Rows, Cols: byte);
   var
      Row, Col: byte;
   begin
      Field.Generated := False;
      Field.CursorRow := 0;
      Field.CursorCol := 0;
      Field.Rows := Rows;
      Field.Cols := Cols;
      for Row := 0 to Rows - 1 do
          for Col := 0 to Cols - 1 do
             Field.States[Row][Col] := ord(Closed);
      {$ifdef DEBUG}
      Field.Peek := False;
      {$endif}
   end;

   function IsAtCursor(var Field: Field; Row, Col: byte): Boolean;
   begin
      IsAtCursor := (Field.CursorRow = Row) and (Field.CursorCol = Col);
   end;

   procedure FieldDisplay(var Field: Field);
   var
      Row, Col, Nbors: byte;
   begin
      with Field do
         for Row := 0 to Rows-1 do
         begin
            for Col := 0 to Cols-1 do
            begin
               if IsAtCursor(Field, Row, Col) then Write('[') else Write(' ');
               {$ifdef DEBUG}
               if Peek then
                   case Cell(Cells[Row][Col]) of
                       Bomb: Write('@');
                       Empty: begin
                           Nbors := CountNborBombs(Field, Row, Col);
                           if Nbors > 0 then Write(Nbors) else Write(' ');
                       end;
                   end
               else
               {$endif}
               case State(States[Row][Col]) of
                  Open: case Cell(Cells[Row][Col]) of
                           Bomb: Write('@');
                           Empty: begin
                                     Nbors := CountNborBombs(Field, Row, Col);
                                     if Nbors > 0 then Write(Nbors) else Write(' ');
                                  end;
                        end;
                  Closed: Write('.');
                  Flagged: Write('%');
               end;
               if IsAtCursor(Field, Row, Col) then Write(']') else Write(' ');
            end;
            WriteLn;
         end;
   end;

   procedure MoveUp(var Field: Field);
   begin
      with Field do if CursorRow > 0 then Dec(CursorRow);
   end;

   procedure MoveDown(var Field: Field);
   begin
      with Field do if CursorRow < byte(Rows-1) then Inc(CursorRow);
   end;

   procedure MoveLeft(var Field: Field);
   begin
      with Field do if CursorCol > 0 then Dec(CursorCol);
   end;

   procedure MoveRight(var Field: Field);
   begin
      with Field do if CursorCol < byte(Cols-1) then Inc(CursorCol);
   end;


   procedure FieldRedisplay(var Field: Field);
   begin
      clrscr;

      FieldDisplay(Field);
   end;


   function YorN(Question: TMessage; Kep: YornKeep): Boolean;
   var
      Answer: Char;
   begin
      Write(Question, ' [y/n] ');
      while True do
      begin

         repeat until keypressed;
         Answer:=readkey;

         case Answer of
            'y', 'Y':
               begin
                  if (ord(Kep) and 1) = 1
                  then WriteLn('y') else clrscr;

                  Exit(True);
               end;
            'n', 'N':
               begin
                  if ((ord(Kep) shr 1) and 1) = 1
                  then WriteLn('n') else clrscr;

                  Exit(False);
               end;
         end;
      end;
   end;


   function StateAtCursor(var Field: Field): State;
   begin
      with Field do Result := State(States[CursorRow][CursorCol]);
   end;


begin
   Randomize;

   FieldReset(MainField, HardcodedFieldRows, HardcodedFieldCols);
   FieldRedisplay(MainField);

   Quit := False;
   while not Quit do
   begin

      repeat until keypressed;
      Cmd:=Readkey;

      case Cmd of
         'w': begin
                 MoveUp(MainField);
                 FieldRedisplay(MainField);
              end;
         's': begin
                 MoveDown(MainField);
                 FieldRedisplay(MainField);
              end;
         'a': begin
                 MoveLeft(MainField);
                 FieldRedisplay(MainField);
              end;
         'd': begin
                 MoveRight(MainField);
                 FieldRedisplay(MainField);
              end;

         'f': if MainField.Generated then begin
                 FlagAtCursor(MainField);
                 FieldRedisplay(MainField);
              end;

         'r': if YorN('Restart?', KeepYes) then
              begin
                 FieldReset(MainField, HardcodedFieldRows, HardcodedFieldCols);
                 FieldRedisplay(MainField);
              end;

         {TODO: interpret ^C as request to quit}
         'q', Chr(27): Quit := YorN('Quit?', KeepYes);

         {$ifdef DEBUG}
         'p':   if MainField.Generated then begin

                  MainField.Peek := not MainField.Peek;
                  FieldRedisplay(MainField);

		end;
         {$endif}

         ' ': begin

		 if (StateAtCursor(MainField) = Flagged) then
		  if YorN('Really open flagged cell?', KeepNone) then

		  with MainField do States[CursorRow][CursorCol] := ord(Open)

		  else
		    FieldRedisplay(MainField);


                 if (StateAtCursor(MainField) <> Flagged) then
                    if OpenAtCursor(MainField) then
                    begin
                       {TODO: indicate which bomb caused the explosion}
                       OpenAllBombs(MainField);
                       FieldRedisplay(MainField);
                       if YorN('You Died! Restart?', KeepBoth) then
                       begin
                          FieldReset(MainField, HardcodedFieldRows, HardcodedFieldCols);
                          FieldRedisplay(MainField);
                       end
                       else Quit := True;
                    end
                    else
                    begin
                       if IsVictory(MainField) then
                       begin
                          FlagAllBombs(MainField);
                          FieldRedisplay(MainField);
                          if YorN('You Won! Restart?', KeepBoth) then
                          begin
                             FieldReset(MainField, HardcodedFieldRows, HardcodedFieldCols);
                             FieldRedisplay(MainField);
                          end
                          else Quit := True
                       end
                       else FieldRedisplay(MainField);
                    end
              end;

      end;
   end;

end.
