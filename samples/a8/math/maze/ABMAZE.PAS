(*****************************************************************************
Aldous-Broder algorithm for maze generation.

https://github.com/DosWorld/abmaze/

******************************************************************************

MIT No Attribution

Copyright 2023 Viacheslav Komenda

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*****************************************************************************)
PROGRAM ABMaze;

uses crt, atari;

CONST
CELL_VISITED = ' '; (* cell is visited *)
CELL_UNVISIT = '#'; (* cell is not visited *)

(* maze dimension *)
WIDTH  = 36;
HEIGHT = 18;
STEP   = 2;

VAR     maze : ARRAY[0..HEIGHT, 0..WIDTH] OF CHAR;

PROCEDURE ClearMaze;
BEGIN
        FillByte(maze, SizeOf(maze), ord(CELL_UNVISIT));
END;

PROCEDURE WriteMaze(xs, ys : smallint);
VAR     x, y : smallint;
BEGIN
        Write('+');
        FOR x := 0 TO WIDTH DO Write('-');
        WriteLn('+');
        FOR y := 0 TO HEIGHT DO BEGIN
                Write('|');
                FOR x := 0 TO WIDTH DO BEGIN
                        IF (x = xs) AND (y = ys) THEN
			
				write('o'*)

                        ELSE Write(maze[y][x]);
                END;
                WriteLn('|');
        END;
        Write('+');
        FOR x := 0 TO WIDTH DO Write('-');
        WriteLn('+');
END;

FUNCTION CheckBounds(x, y : smallint) : BOOLEAN;
BEGIN
        CheckBounds := (x >= 0) AND (x <= WIDTH) AND (y >= 0) AND (y <= HEIGHT);
END;

PROCEDURE GenerateMaze;
VAR     x, y, dx, dy, i  : smallint;
        unvisited, total : smallint;
        isUnVis          : BOOLEAN;
        enough           : smallint;
        d                : CHAR;
BEGIN
        total := (WIDTH * HEIGHT) SHR 1;

        (* Initial point *)
        x := Random((WIDTH + 1) SHR 1) SHL 1;
        y := Random((HEIGHT + 1) SHR 1) SHL 1;
        maze[y][x] := CELL_VISITED;

        unvisited := total;
        enough := 5 * total DIV 10; (* enough visit 50% of maze *)
        WHILE unvisited > enough DO BEGIN
                (* One step *)
                CASE byte(Random(4)) OF
                0: BEGIN dx := 0;  dy := -1; d := '^'; END; (* UP *)
                1: BEGIN dx := 1;  dy := 0;  d := '>'; END; (* RIGHT *)
                2: BEGIN dx := 0;  dy := 1;  d := 'V'; END; (* DOWN *)
                3: BEGIN dx := -1; dy := 0;  d := '<'; END; (* LEFT *)
                END;
                IF NOT CheckBounds(x + dx * STEP, y + dy * STEP) THEN CONTINUE;
                isUnVis := maze[y + dy * STEP][x + dx * STEP] = CELL_UNVISIT;
                FOR i := 1 TO STEP DO BEGIN
                        INC(x, dx);
                        INC(y, dy);
                        IF isUnVis THEN maze[y][x] := CELL_VISITED;
                END;
                IF isUnVis THEN DEC(unvisited);
                (* Visualization *)
		GotoXY(1,1);

                Writeln('ALDOUS-BRODER MAZE');

                WriteLn(unvisited, '/', enough, ':', total
                        , ' ', 'x:', x:4
                        , ' ', 'y:', y:4
                        , ' ', 'direction: ', d
                        , '   ');

                WriteMaze(x, y);
        END;
END;

BEGIN
	lmargin := 0;
	
        Randomize;

	clrscr;
	
        ClearMaze;
        GenerateMaze;

	repeat until keypressed;
END.
