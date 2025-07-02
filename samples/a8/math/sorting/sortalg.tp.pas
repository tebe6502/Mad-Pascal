program sort;

uses crt,dos;

const    max=2000;

type     field=array[1..max] of integer;

var      test,feld:field;
   h,h1,m,m1,s,s1,hund,hund1:word;
               j,i:integer;

{----------------------------------------------------------------------}
procedure ausgabe(h,h1,m,m1,s,s1,hund,hund1:word);
var       h2,m2,s2,hund2:longint;
begin
 if hund1<hund then begin
    hund2:=100-(hund-hund1);
    dec(s1);
 end
 else hund2:=hund1-hund;
 if s1<s then begin
    s2:=60-(s-s1);
    dec(m1);
 end
 else s2:=s1-s;
 if m1<m then m2:=60-(m-m1)
 else m2:=m1-m;
 h2:=h1-h;
 writeln('                         ',h2,' h ',m2,' m ',s2,' s ',hund2,'/100s');
 writeln;
end;
{----------------------------------------------------------------------}
procedure testmenge(var menge:field);

var       i:integer;

begin
 randomize;
 for i:=1 to max do
     menge[i]:=random(65535);
end;
{----------------------------------------------------------------------}
procedure bubble(feld:field);

var       t:boolean;
          x,i:integer;
          tausch:integer;

begin
 textcolor(yellow);
 writeln('Bubblesort:');
 textcolor(white);
 gettime(h,m,s,hund);
 t:=true;
 x:=max;
 while t=true do begin
       dec(x);
       for i:=1 to x do
              if feld[i]>feld[i+1] then begin
              tausch:=feld[i];
              feld[i]:=feld[i+1];
              feld[i+1]:=tausch;
              t:=true;
           end
           else if x=2 then t:=false;
 end;
 gettime(h1,m1,s1,hund1);
end;
{----------------------------------------------------------------------}
procedure ripple(feld:field);
var       i,j:integer;
          pos:integer;
    test,hold:integer;

begin
 textcolor(yellow);
 writeln('Ripplesort (made by R.Patschke):');
 textcolor(white);
 gettime(h,m,s,hund);
 for i:=1 to max-1 do begin
     test:=feld[i];
     hold:=test;
     pos:=i;
     for j:=i+1 to max do
         if feld[j]<test then begin
            test:=feld[j];
            pos:=j;
         end;
     feld[i]:=test;
     feld[pos]:=hold;
 end;
 gettime(h1,m1,s1,hund1);
end;
{----------------------------------------------------------------------}
procedure einfueg(von,bis:longint;
                 var feld:field);
var       i,j,test,pos:integer;
begin
 for i:=von to bis-1 do begin;
     test:=feld[i];
     pos:=i;
     for j:=i+1 to bis do
         if feld[j]<test then begin
            test:=feld[j];
            pos:=j;
         end;
     for j:=pos-1 downto i do feld[j+1]:=feld[j];
     feld[i]:=test;
 end;
 gettime(h1,m1,s1,hund1);
end;
{----------------------------------------------------------------------}
procedure gabler(feld:field);
var i,n,k,tausch:integer;
begin
 textcolor(yellow);
 writeln('Ripplesort (made by J.Gabler):');
 textcolor(white);
 gettime(h,m,s,hund);
 for i:=1 to max-1 do begin
     n:=i;
     for k:=i+1 to max do
         if feld[n]>feld[k] then n:=k;
     if n>i then begin
        tausch:=feld[i];
        feld[i]:=feld[n];
        feld[n]:=tausch;
     end;
 end;
 gettime(h1,m1,s1,hund1);
end;
{----------------------------------------------------------------------}
procedure mischsort(test:field);

var      feld:field;
         dummy:boolean;
         v,i,links,rechts,lgr,rgr:longint;


begin
 textcolor(yellow);
 writeln('Sortieren mit Mischen:');
 textcolor(white);
 gettime(h,m,s,hund);
 lgr:=max div 2;
 rgr:=lgr+1;
 einfueg(1,lgr,test);
 einfueg(rgr,max,test);
 i:=1;
 links:=i;
 rechts:=rgr;
 dummy:=false;
 repeat
       if test[links]<test[rechts] then begin
          feld[i]:=test[links];
          inc(i);
          inc(links);
          if links=rgr then begin
             for v:=rechts to max do begin
                 feld[i]:=test[v];
                 inc(i);
             end;
             dummy:=true;
          end;
       end
       else begin
          feld[i]:=test[rechts];
          inc(i);
          inc(rechts);
          if rechts>max then begin
             for v:=links to rgr do begin
                 feld[i]:=test[v];
                 inc(i);
             end;
             dummy:=true;
          end;
       end;
 until dummy=true;
 gettime(h1,m1,s1,hund1);
end;
{----------------------------------------------------------------------}
begin
 clrscr;
 textcolor(lightred);
 write('Anzahl der Feldelemente: ');
 textcolor(lightblue);
 writeln(max);
 writeln;
 testmenge(test);
 for i:=1 to 5 do begin
     case i of
          1:bubble(test);
          2:ripple(test);
          3:gabler(test);
          4:begin
                 for j:=1 to max do feld[j]:=test[j];
                 textcolor(yellow);
                 writeln('Sortieren durch EinfÅgen:');
                 textcolor(white);
                 gettime(h,m,s,hund);
                 einfueg(1,max,feld);
                 gettime(h1,m1,s1,hund1);
            end; 
          5:mischsort(test);
     end;
     ausgabe(h,h1,m,m1,s,s1,hund,hund1);
 end;
 textcolor(lightgreen);
 writeln('Taste drÅcken !!!');
 repeat until keypressed;
end.
