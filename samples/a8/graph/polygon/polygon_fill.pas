uses crt, graph;

var
  i : byte;

  pt: array [0..63] of word;

begin
 InitGraph(8);

 SetColor(1);

 // shape

 pt[0]:=63;
 pt[1]:=17;

 pt[2]:=78;
 pt[3]:=47;

 pt[4]:=119;
 pt[5]:=50;

 pt[6]:=80;
 pt[7]:=70;

 pt[8]:=109;
 pt[9]:=90;

 pt[10]:=60;
 pt[11]:=91;

 pt[12]:=51;
 pt[13]:=110;

 pt[14]:=45;
 pt[15]:=88;

 pt[16]:=29;
 pt[17]:=70;

 pt[18]:=59;
 pt[19]:=50;

 DrawPoly(10, pt);

 FillPoly(10, pt);

// triangle

 pt[0]:=150;
 pt[1]:=17;

 pt[2]:=198;
 pt[3]:=97;

 pt[4]:=111;
 pt[5]:=117;

 DrawPoly(3, pt);

 FillPoly(3, pt);

 repeat until keypressed;

end.
