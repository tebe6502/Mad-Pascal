program solitario;
(*
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*)

{$ifdef ATARI}
uses crt, atari, efast;
{$else}
uses crt;
{$endif}
const
   Version = 'v1.7';

{$ifdef ATARI}
   CharNumero : array[0..12] of Char = ( 'A'*,'2'*,'3'*,'4'*,'5'*,'6'*,
                                         '7'*,'8'*,'9'*,'0'*,'J'*,'Q'*,'K'*);
   CharPinta : array[0..3] of Char = (#128, #224, #144, #251);
   CaracterBarra = '|';
   BordeSuperior = #17#18#18#18#5;
   BordeContinuo = #1#18#18#18#4;
   BordeInferior = #26#18#18#18#3;
   AtrasCarta = #148#148#148;
   BordeMedio = '|   |';
   VentanaPreguntaSup = #17#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#5;
   VentanaPreguntaInf = #26#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#18#3;
{$else}
{$ifdef MSDOS}
   CharNumero : array[0..12] of Char = 'A234567890JQK';
   CharPinta : array[0..3] of Char = (#3, #4, #5, #6);
   CaracterBarra = #179;
   BordeSuperior = #218#196#196#196#191;
   BordeContinuo = #195#196#196#196#180;
   BordeInferior = #192#196#196#196#217;
   VentanaPreguntaSup = #218#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#191;
   VentanaPreguntaInf = #192#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#196#217;
   BordeMedio = CaracterBarra + '   ' + CaracterBarra;
   AtrasCarta = #176#176#176;
{$else}
   CharNumero : array[0..12] of Char = ( 'A','2','3','4','5','6',
                                         '7','8','9','0','J','Q','K');
   CharPinta : array[0..3] of Char = ('H', 'S', 'd', 'c');
   CaracterBarra = '|';
   BordeSuperior = ',---,';
   BordeContinuo = '|---|';
   BordeInferior = '''---''';
   BordeMedio = '|   |';
   AtrasCarta = '###';
   VentanaPreguntaSup = ',------------------,';
   VentanaPreguntaInf = '''------------------''';
{$endif}
{$endif}

   NumeroColumnas = 7;
var
   { Las cartas que estan en cada columna }
   CartasMesa    : array[0..NumeroColumnas,0..51] of byte;
   { El numero de cartas en cada columna }
   CartasEnMesa  : array[0..NumeroColumnas+1] of byte;
   { Define si la carta esta volteada o no }
   CartaVolteada : array[0..NumeroColumnas,0..51] of boolean;
   CartasArriba  : array[0..3] of shortint;
   CartasMazo    : array[0..51] of byte;
   CartasEnMazo  : byte;
   CartasMazo2   : array[0..51] of byte;
   CartasEnMazo2 : byte;
   CartasMano    : array[0..52] of byte;
   CartasEnMano  : byte;
   CartasVistas  : byte;
   CartasVistasAntes   : byte;
   SeleccionaMesa      : boolean;
   CartaSeleccionada   : byte;
   ColumnaSeleccionada : byte;
   AnteriorCarta       : byte;
   AnteriorColumna     : byte;
   ColumnaMano         : byte;
   FinDelJuego         : boolean;

{$ifdef MSDOS}
procedure CursorOn;
begin
end;

procedure CursorOff;
begin
end;
{$endif}

procedure Inverse;
begin
{$ifdef ATARI}
   TextAttr := $80;
{$else}
   TextColor(Blue);
   TextBackground(White);
{$endif}
end;

procedure GameScr;
begin
   CursorOff;
{$ifdef ATARI}
   TextAttr := $00;
   lmargin := 0;
{$else}
   TextColor(LightGray);
   TextBackground(Blue);
{$endif}
   ClrScr;
end;

procedure NormalScr;
begin
   CursorOn;
{$ifdef ATARI}
   TextAttr := $00;
   lmargin := 2;
{$else}
   TextColor(LightGray);
   TextBackground(Black);
{$endif}
   ClrScr;
end;

procedure Normal;
begin
{$ifdef ATARI}
   TextAttr := $00;
{$else}
   TextColor(LightGray);
   TextBackground(Blue);
{$endif}
end;

procedure DibujaBordeSuperior(EsPrimera: boolean );
begin
   if (EsPrimera) then
       write(BordeSuperior)
   else
       write(BordeContinuo);
end;

procedure DibujaBorde(x, y: byte; EsPrimera: boolean );
var
    i: byte;
begin
   gotoxy(x,y);
   DibujaBordeSuperior(EsPrimera);

   for i:=1 to 3 do
   begin
       Inc(y);
       gotoxy(x,y);
       write(BordeMedio);
   end;
   Inc(y);
   gotoxy(x,y);
   write(BordeInferior);
   Normal;
end;

procedure DibujaCarta(x,y,Carta:byte ; EsPrimera:boolean );
   var i,Numero,Pinta:byte;
begin
   DibujaBorde(x, y, EsPrimera);
   Inverse;
   Inc(x);
   Inc(y);
   for i:=y to y+2 do
   begin
      gotoxy(x,i);
      write('   ');
   end;
   Numero:=Carta mod 13;
   Pinta:=Carta div 13;
{$ifndef ATARI}
   if (Pinta=2) or (Pinta=3) then
      TextColor(Black)
   else
      TextColor(Red);
{$endif}
   if(Numero=9) then               { Es un 10 !! }
   begin
      gotoxy(x,y);
      write('10');
      Inc(x);
      gotoxy(x,y+2);
      write('10');
   end else
   begin
      gotoxy(x,y);
      write( CharNumero[Numero] );
      Inc(x,2);
      gotoxy(x,y+2);
      write( CharNumero[Numero] );
      Dec(x);
   end;
   gotoxy(x,y+1);
   write( CharPinta[Pinta] );
   Normal;
end;

procedure DibujaCartaChica(x,y,Carta:byte ; EsPrimera:boolean );
   var Numero,Pinta:byte;
begin
   gotoxy(x,y);
   DibujaBordeSuperior(EsPrimera);
   Numero:=Carta mod 13;
   Pinta:=Carta div 13;
{$ifndef ATARI}
   if (Pinta=2) or (Pinta=3) then
      TextColor(LightGray)
   else
      TextColor(LightRed);
{$else}
   TextAttr := $80;
{$endif}
   if(Numero=9) then { Es un 10 !! }
   begin
      gotoxy(x+1,y);
      write('1');
   end;
   gotoxy(x+2,y);
   write( CharNumero[Numero] );
   write( CharPinta[Pinta] );
   Normal;
end;

procedure DibujaCartaAtras(x,y:byte; EsPrimera:boolean);
   var i:byte;
begin
   DibujaBorde(x, y, EsPrimera);
   Inc(x);
   for i:=y+1 to y+3 do
   begin
      gotoxy(x,i);
      write(AtrasCarta);
   end;
end;

procedure DibujaCartaChicaAtras(x,y:byte ; EsPrimera:boolean );
begin
   gotoxy(x,y);
   DibujaBordeSuperior(EsPrimera);
{   gotoxy(x,y+1);
    write(#124#160#160#160#124);
   }
end;

procedure DibujaHueco(x,y:byte);
begin
   DibujaBorde(x, y, True);
end;

procedure DibujaCartaMesa(Columna,Carta:byte);
   var posx,posy:byte;
       primera  :boolean;
begin
   posx:=(Columna Shl 2) + Columna;
   posx:=posx-4;

   posy:=Carta;
   primera:=(Carta=1);
   if(Carta=0) then
      DibujaHueco(posx,posy+1)
   else if(Carta=CartasEnMesa[Columna]) then
   begin
      if(CartaVolteada[Columna,Carta - 1]) then
         DibujaCarta(posx,posy,CartasMesa[Columna,Carta - 1],primera)
      else
         DibujaCartaAtras(posx,posy,primera);
   end else
   begin
      if(CartaVolteada[Columna,Carta - 1]) then
         DibujaCartaChica(posx,posy,CartasMesa[Columna,Carta - 1],primera)
      else
         DibujaCartaChicaAtras(posx,posy,primera);
   end;
end;

procedure MuestraCartasColumna(col: byte);
   var j, n, posx: byte;
begin
   posx:=(col Shl 2) + col;
   posx:=posx-4;
   n:=CartasEnMesa[col];
   if n=0 then
   begin
      DibujaHueco(posx,1);
      n := 1;
   end
   else
      for j:=1 to n do
         DibujaCartaMesa(col,j);

   for j:=5 + n to 19 do
   begin
     gotoxy(posx,j);
     write('     ');
   end;
end;

procedure MuestraCartasColumnaSeleccionada;
begin
   MuestraCartasColumna(ColumnaSeleccionada);
end;

procedure MuestraCartasArriba;
   var i, x: byte;
begin
   { Y luego, las cartas que ya se han sacado... }
   x := 20;
   for i:=0 to 3 do
   begin
      if (CartasArriba[i]=-1) then
         DibujaHueco(x,20)
      else
         DibujaCarta(x,20,CartasArriba[i],True);
      Inc(x, 5);
   end;
end;

procedure MuestraCartasMazo;
   var i:byte;
begin
   { Dibuja el mazo inicial }
   if (CartasEnMazo>0) then
      DibujaCartaAtras(1,20,True)
   else
      DibujaHueco(1,20);

   { Dibuja el mazo final }
   for i:=20 to 24 do
   begin
      gotoxy(7,i);
      write('             ');
   end;

   if (CartasEnMazo2>0) then
   begin
      for i:=0 to CartasVistas-1 do
         DibujaCarta(7+i*3,20,CartasMazo2[CartasEnMazo2-CartasVistas+i],True);
   end
   else
      DibujaHueco(7,20);
end;

procedure MuestraCartasMesa;
   var i: byte;
begin
   clrscr;
   { Primero, las cartas en la mesa }
   for i:=1 to NumeroColumnas do
      MuestraCartasColumna(i);

   MuestraCartasArriba;
   MuestraCartasMazo;
end;

procedure MuestraCartasMano;
begin
   { Dibuja la primera carta en la mano, si es que hay alguna }
   if (CartasEnMano>0) then
   begin
      DibujaCarta(35,15,CartasMano[0],True);
      gotoxy(36,14);
      write(CartasEnMano, ' C');
   end;
end;

procedure BorraCartasMano;
   var i:byte;
begin
   for i:=14 to 19 do
   begin
      gotoxy(36,i);
      write('    ');
   end;
   MuestraCartasColumna(NumeroColumnas);
end;

procedure DibujaSeleccionada(Columna,Carta: byte; Color: boolean);
begin
   if Color then
      Inverse;
   if (Columna <= NumeroColumnas) then
      DibujaCartaMesa(Columna,Carta)
   else
   begin
      if (CartasEnMazo2>0) then
         DibujaCarta(4+CartasVistas*3,20,CartasMazo2[CartasEnMazo2-1],True)
      else
         DibujaHueco(7,20);
   end;
   Normal;
end;

procedure AyudaDelJuego;
begin
   GameScr;
   {        .........|..........|.........|.........| }
   writeln;
   write('           ');
   Inverse;
   writeln(' Solitario!  ', Version, ' ');
   Normal;

   writeln;
   Inverse;
   writeln('Normal Movements:');
   Normal;
   writeln;
   writeln(' Arrows: Selects a card to pick.');
   writeln(' RETURN: Takes the selected card (and');
   writeln('         all cards bellow) in the hand.');
   writeln(' ESC:    Exits the game.');
   writeln(' SPACE:  Deals three more cards.');
   writeln(' TAB:    Place the selected cart in the');
   writeln('         solved pile (foundations).');
   writeln;
   Inverse;
   writeln('Movements with cards in hand:');
   Normal;
   writeln;
   writeln(' Arrows: Selects spot to place cards.');
   writeln(' RETURN: Put the cards in hand into the');
   writeln('         selected spot.');
   writeln(' ESC:    Return cards in hand to the');
   writeln('         original place.');
   writeln;
   write('      ');
   Inverse;
   write(' Press any key to continue ');
   Normal;
   ReadKey;
end;

function PreguntaSalida: boolean;
var
    c : char;
begin
    gotoxy(10,10);
    write(VentanaPreguntaSup);
    gotoxy(10,11);
    write( CaracterBarra, ' Quit Game (Y/N)? ', CaracterBarra);
    gotoxy(10,12);
    write(VentanaPreguntaInf);
    c := ReadKey;
    if (c = 'y') or (c = 'Y') then
{$ifdef ATARI}
        Result := True
    else
        Result := False;
{$else}
        PreguntaSalida := True
    else
        PreguntaSalida := False;
{$endif}
end;

{ La logica del juego viene a continuacion }
procedure ReparteCartas;
var
   i, t: byte;
begin
   { Si no quedan cartas en el mazo, las da vuelta }

   if(CartasEnMazo=0) then
   begin
      if(CartasEnMazo2>0) then
         for i:=0 to CartasEnMazo2-1 do
            CartasMazo[i]:=CartasMazo2[CartasEnMazo2-i-1];
      CartasEnMazo:=CartasEnMazo2;
      CartasEnMazo2:=0;
   end
   else
   begin
      { Ahora, extrae 3 cartas del mazo inicial al final }

      t:=3; { Numero de cartas a extraer }

      if(CartasEnMazo<t) then  { Si no hay tantas cartas, extrae todas }
      t:=CartasEnMazo;

      for i:=1 to t do
      begin
         CartasEnMazo:=CartasEnMazo-1;
         CartasMazo2[CartasEnMazo2]:=CartasMazo[CartasEnMazo];
         CartasEnMazo2:=CartasEnMazo2+1;
      end;

      CartasVistas:=t;

   end;

   MuestraCartasMazo;

   { Ahora, espera una jugada... }
   CartaSeleccionada:=1;
   SeleccionaMesa:=False;                 { Selecciona cartas del mazo }
   ColumnaSeleccionada:=NumeroColumnas+1;
end;

{ Programa principal }
var
   i,j,t : byte;
   c : char;
   Carta,Pinta,Numero : byte;
   Carta2,Pinta2,Numero2 : byte;
begin
   AyudaDelJuego;

   for i:=0 to 51 do
      CartasMazo[i]:=i;    { LLena el mazo de cartas }
   for i:=1 to NumeroColumnas do
      CartasEnMesa[i]:=0;
   for i:=0 to 3 do
      CartasArriba[i]:=-1;

   Randomize;

   for i:=0 to 51 do      { Revuelve las cartas }
   begin
      j:=random(51);                   { Elije una al azar }
      t:=CartasMazo[i];
      CartasMazo[i]:=CartasMazo[j];    { Y la cambia por otra }
      CartasMazo[j]:=t;
   end;

   CartasEnMazo:=52;
   CartasEnMazo2:=0;
   CartasVistas:=0;
   CartasEnMano:=0;

   MuestraCartasMesa;

   for i:=1 to NumeroColumnas do
   begin
      for j:=i to NumeroColumnas do
      begin                 { Reparte las cartas en la mesa, de a 1 }
         t:=CartasEnMesa[j];
         CartasEnMesa[j]:=t + 1;
         CartasEnMazo:=CartasEnMazo-1;
         CartasMesa[j,t]:=CartasMazo[CartasEnMazo];
         if i = j then
            CartaVolteada[j,t]:=True   { Solo la ultima es visible... }
         else
            CartaVolteada[j,t]:=False;
         MuestraCartasColumna(j);
      end;
   end;

   { Aqui comienza el loop principal del juego }
   ReparteCartas;

   repeat

      { Guarda la seleccion en la anterior }
      AnteriorColumna:=ColumnaSeleccionada;
      AnteriorCarta:=CartaSeleccionada;
      { Dibuja la nueva Seleccionada }
      DibujaSeleccionada(ColumnaSeleccionada,CartaSeleccionada,True);

      c:=ReadKey;

      { Borra la seleccionada antes }
      DibujaSeleccionada(AnteriorColumna,AnteriorCarta,False);

      case c of
         '-', #28, 'H'  :
         begin
            if CartaSeleccionada > 1 then
               CartaSeleccionada:=CartaSeleccionada-1;
         end;
         '=', #29, 'P'  :
         begin
            if SeleccionaMesa then
               CartaSeleccionada:=CartaSeleccionada+1;
         end;
         '*', #31, 'M'  :
         begin
            ColumnaSeleccionada:=ColumnaSeleccionada+1;
            if (ColumnaSeleccionada=(NumeroColumnas+1)) then
               SeleccionaMesa:=False
            else
            begin
               if(ColumnaSeleccionada=(NumeroColumnas+2)) then
                  ColumnaSeleccionada:=1;
               SeleccionaMesa:=True;
            end;
         end;
         '+', #30, 'K'  :
         begin
            ColumnaSeleccionada:=ColumnaSeleccionada-1;
            if (ColumnaSeleccionada=0) then
            begin
               ColumnaSeleccionada:=NumeroColumnas+1;
               SeleccionaMesa:=False;
            end else
               SeleccionaMesa:=True;
         end;
         #155, #13      :
         begin
            { La tecla Enter puede hacer distintas cosas... }

            if (CartasEnMano=0) and (CartaSeleccionada>0) and (SeleccionaMesa) then

               { Puede voltear una carta... }
               if (not CartaVolteada[ColumnaSeleccionada,CartaSeleccionada - 1]) then
               begin
                  CartaVolteada[ColumnaSeleccionada,CartaSeleccionada - 1]:=True;
                  MuestraCartasColumnaSeleccionada;
               end else
               begin
                  { Y puede tomar las cartas en la mano }
                  CartasEnMano:=CartasEnMesa[ColumnaSeleccionada]-CartaSeleccionada+1;
                  for i:=0 to CartasEnMano-1 do
                     CartasMano[i]:=CartasMesa[ColumnaSeleccionada,i + CartaSeleccionada - 1];
                  ColumnaMano:=ColumnaSeleccionada;
                  CartasEnMesa[ColumnaSeleccionada]:=CartaSeleccionada-1;
                  { Redraw }
                  MuestraCartasColumnaSeleccionada;
                  MuestraCartasMano;
               end
            else if (CartasEnMano=0) and (not SeleccionaMesa) and (CartasEnMazo2>0) then
                  { Ademas, puede tomar una carta desde el mazo... }
            begin
               CartasEnMazo2:=CartasEnMazo2-1;
               Carta:=CartasMazo2[CartasEnMazo2];
               CartasVistasAntes:=CartasVistas;
               CartasVistas:=CartasVistas-1;
               if (CartasVistas<1) then
                  CartasVistas:=1;
               CartasEnMano:=1;
               CartasMano[0]:=Carta;
               ColumnaMano:=0;
               { Redraw }
               MuestraCartasMazo;
               MuestraCartasMano;
            end
            else if (CartasEnMano>0) and SeleccionaMesa then
               { Tambien, la tecla Enter suelta las cartas en la mano }
            begin
               Carta:=CartasMano[0];
               Pinta:=Carta div 13;
               Numero:=Carta mod 13;
               if (Numero=12) and (CartaSeleccionada=0) then
               begin
                  for i:=0 to CartasEnMano-1 do
                  begin
                     CartasMesa[ColumnaSeleccionada,i]:=CartasMano[i];
                     CartaVolteada[ColumnaSeleccionada,i]:=True;
                  end;
                  CartasEnMesa[ColumnaSeleccionada]:=CartasEnMano;
                  CartasEnMano:=0;
                  { Redraw }
                  AnteriorCarta := 1;
                  MuestraCartasColumnaSeleccionada;
                  BorraCartasMano;
               end
               else if (Numero<>12) and (CartaSeleccionada<>0) then
               begin
                  Carta2:=CartasMesa[ColumnaSeleccionada,CartaSeleccionada - 1];
                  Pinta2:=Carta2 div 13;
                  Numero2:=Carta2 mod 13;
                  if ((Numero2-1)=Numero) and ((Pinta2 div 2)<>(Pinta div 2)) then
                     { Si tienen numero seguido y distinto color... }
                  begin
                     for i:=0 to CartasEnMano-1 do
                     begin
                        CartasMesa[ColumnaSeleccionada,i+CartaSeleccionada]:=CartasMano[i];
                        CartaVolteada[ColumnaSeleccionada,i+CartaSeleccionada]:=True;
                     end;
                     CartasEnMesa[ColumnaSeleccionada]:=CartasEnMano+CartaSeleccionada;
                     CartasEnMano:=0;
                     { Redraw }
                     MuestraCartasColumnaSeleccionada;
                     BorraCartasMano;
                  end;
               end;
            end;
         end;
         #127,#255, 'R' :
         begin
            { La tecla INS lleva la carta hacia arriba... }
            if CartasEnMano = 0 then
               if (SeleccionaMesa) then
               begin
                  if (CartasEnMesa[ColumnaSeleccionada]>0) and
                  (CartaVolteada[ColumnaSeleccionada,CartaSeleccionada - 1]) then
                  begin
                     Carta:=CartasMesa[ColumnaSeleccionada,CartaSeleccionada - 1];
                     Pinta:=Carta div 13;
                     Numero:=Carta mod 13;
                     { Puede llevar una carta hacia arriba ... }
                     if (((Numero=0) and (CartasArriba[Pinta]=-1)) or
                        ((CartasArriba[Pinta]+1 = Carta) and (Numero>0)) ) and
                        (CartasEnMesa[ColumnaSeleccionada]=CartaSeleccionada) then
                     begin
                        CartasArriba[Pinta]:=Carta;
                        CartasEnMesa[ColumnaSeleccionada]:=CartasEnMesa[ColumnaSeleccionada]-1;
                        { Redraw }
                        MuestraCartasColumnaSeleccionada;
                        MuestraCartasArriba;
                     end;
                  end;
               end else
               begin
                  Carta:=CartasMazo2[CartasEnMazo2-1];
                  Numero:=Carta mod 13;
                  Pinta:=Carta div 13;
                  if ((Numero=0) and (CartasArriba[Pinta]=-1)) or
                     ((CartasArriba[Pinta]+1 = Carta) and (Numero>0)) then
                  begin
                     CartasEnMazo2:=CartasEnMazo2-1;
                     CartasVistasAntes:=CartasVistas;
                     CartasVistas:=CartasVistas-1;
                     if (CartasVistas<1) then
                        CartasVistas:=1;
                     CartasArriba[Pinta]:=Carta;
                     MuestraCartasMazo;
                     MuestraCartasArriba;
                  end;
               end;
         end;
         #27       :
         begin
            { Y la tecla Escape suelta las cartas de la mano... }
            if CartasEnMano>0 then
            begin
               if ColumnaMano>0 then
               begin
                  CartaSeleccionada:=CartasEnMesa[ColumnaMano];
                  for i:=0 to CartasEnMano-1 do
                  begin
                     CartasMesa[ColumnaMano,i+CartaSeleccionada]:=CartasMano[i];
                     CartaVolteada[ColumnaMano,i+CartaSeleccionada]:=True;
                  end;
                  CartasEnMesa[ColumnaMano]:=CartasEnMano+CartaSeleccionada;
                  CartasEnMano:=0;
                  ColumnaSeleccionada:=ColumnaMano;
                  SeleccionaMesa:=True;
                  { Redraw }
                  MuestraCartasColumnaSeleccionada;
                  BorraCartasMano;
                  { Fixes redraw if selected column was the same as the returned column }
                  if AnteriorColumna = ColumnaSeleccionada then
                     AnteriorCarta := CartasEnMesa[ColumnaSeleccionada];
               end else
               begin
                  CartasMazo2[CartasEnMazo2]:=CartasMano[0];
                  CartasEnMazo2:=CartasEnMazo2+1;
                  CartasVistas:=CartasVistasAntes;
                  CartasEnMano:=0;
                  { Redraw }
                  MuestraCartasMazo;
                  BorraCartasMano;
               end;
            end
            else
               if not PreguntaSalida then
               begin
                  MuestraCartasMesa;
                  MuestraCartasMano;
               end
               else
                  Break;
         end;
         ' '       :
         begin
            if CartasEnMano = 0 then
               ReparteCartas;
         end;
      end;


      if (CartasEnMano=0) and (SeleccionaMesa) then { Si estoy eligiendo cartas normalmente }
      begin
         { Verifica que no seleccione una carta inexistente }
         if (CartaSeleccionada>CartasEnMesa[ColumnaSeleccionada]) then
            CartaSeleccionada:=CartasEnMesa[ColumnaSeleccionada];
         { Ahora, calcula si la carta es visible o es la mas alta}
         while ( (CartaSeleccionada<CartasEnMesa[ColumnaSeleccionada]) and
             ( not CartaVolteada[ColumnaSeleccionada,CartaSeleccionada - 1]) ) do
            CartaSeleccionada:=CartaSeleccionada+1;
      end
      else if SeleccionaMesa then { Si estoy buscando donde dejar las de la mano }
         CartaSeleccionada:=CartasEnMesa[ColumnaSeleccionada];

      { Ve si el juego ha terminado }
      FinDelJuego:=True;
      for i:=0 to 3 do
         if (CartasArriba[i]<>(i*13+12)) then
            FinDelJuego:=False;

   until FinDelJuego;

   NormalScr;

   if FinDelJuego then
   begin
     writeln('At last someone won this Solitario!!!');
     writeln('  Congratulations!  ');
   end;

   writeln;

   writeln('Thanks for playing Solitario!!!');

end.
