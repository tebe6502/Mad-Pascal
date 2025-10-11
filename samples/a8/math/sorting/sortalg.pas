{--Turbo Pascal 1993-----------------Mad Pascal 2016--}
{-- some sorting tests we had to do in school time  --}
{-- interesting is the fact that ripple with little --}
{-- difference matters in executing time            --}
{--                         I did the faster one ;) --}
{-- the a8 version has sme limits: if max>255 the   --}
{-- mix sort does not work - no deep look in that   --}
{-- have fun trying out to understand the code ;)   --}
{-------------------------------------------PPs 2016--}

// bubble	4m 52s
// 

uses crt,dos;

const    max=1500;

type     field=array[0..max] of word;

var      test,feld:field;
   h,h1,m,m1,s,s1,hund,j:word;
		ii:byte;

{----------------------------------------------------------------------}
procedure ausgabe(h,h1,m,m1,s,s1:word);
var       h2,m2,s2:integer;
begin
 if s1<s then begin
    s2:=60-(s-s1);
    dec(m1);
 end
 else s2:=s1-s;
 if m1<m then m2:=60-(m-m1)
 else m2:=m1-m;
 h2:=h1-h;
 writeln(h2,' h ',m2,' m ',s2,' s ');
 writeln;
end;
{----------------------------------------------------------------------}
procedure testmenge(var menge:field);

var       i:word;

begin
 randomize;
 for i:=1 to max do
     menge[i]:=random(32000);
end;
{----------------------------------------------------------------------}
procedure bubble(feld:field);

var       t:boolean;
          x,i:word;
          tausch:word;

begin

 write('Bubblesort:                           ');

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
	   
	   //writeln(x);
 end;
 gettime(h1,m1,s1,hund);
end;
{----------------------------------------------------------------------}
procedure ripple(feld:field);
var       i,j:word;
          pos:word;
    test,hold:word;

begin

 write('Ripplesort (made by R.Patschke):      ');

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
 gettime(h1,m1,s1,hund);
end;
{----------------------------------------------------------------------}
procedure einfueg(von,bis:integer;
                 var feld:field);
var       i,j,test,pos:word;

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
 gettime(h1,m1,s1,hund);
end;
{----------------------------------------------------------------------}
procedure gabler(feld:field);
var i,n,k,tausch:word;
begin

 write('Ripplesort (made by J.Gabler):        ');

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
 gettime(h1,m1,s1,hund);
end;
{----------------------------------------------------------------------}
procedure mischsort(test:field);

var      feld:field;
         dummy:boolean;
         v,i,links,rechts,lgr,rgr:word;


begin

 write('Sortieren mit Mischen:                ');

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
 gettime(h1,m1,s1,hund);
end;
{----------------------------------------------------------------------}
begin
 clrscr;

 write('Anzahl der Feldelemente: ');

 writeln(max);
 writeln;
 testmenge(test);
 for ii:=1 to 5 do begin
     case ii of
          1:bubble(test);
          2:ripple(test);
          3:gabler(test);
          4:begin
                 for j:=1 to max do feld[j]:=test[j];

                 write('Sortieren durch Einfuegen:            ');

                 gettime(h,m,s,hund);
                 einfueg(1,max,feld);
                 gettime(h1,m1,s1,hund);
            end; 
          5:mischsort(test);
     end;
     ausgabe(h,h1,m,m1,s,s1);
 end;
 writeln('Taste druecken !!!');
 repeat until keypressed;
end.
