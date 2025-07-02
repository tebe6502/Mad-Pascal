uses crt, fp;

var
     t, s: TString;

     fp0, fp1: FloatOS;

     fp2: FloatOS = ($c0,$31,$00,$00,$00,$00);

     x: integer;


begin

 x:=-31;//897;
 _itofp(x, fp2);

 _fptoa(fp2, s);

 writeln(s);


 t:='13.145'#0;

 _atofp(t, fp0);	// ascii -> fp0

 _fptoa(fp0, s);	// fp0 -> ascii

 writeln(s);


 t:='65535'#0;
 _atofp(t, fp0);	// ascii -> fp0
 t:='137'#0;
 _atofp(t, fp1);	// ascii -> fp1

 _fpdiv(fp0, fp1, fp2);	// fp0 / fp1 -> fp2
 _fptoa(fp2, s);	// fp2 -> ascii

 writeln(s);


 x:=_fptoi(fp2);
 writeln(x);




 _fpmul(fp0, fp1, fp2);	// fp0 * fp1 -> fp2
 _fptoa(fp2, s);	// fp2 -> ascii

 writeln(s);


 _fpadd(fp0, fp1, fp2);	// fp0 + fp1 -> fp2
 _fptoa(fp2, s);	// fp2 -> ascii

 writeln(s);


 _fpsub(fp0, fp1, fp2);	// fp0 - fp1 -> fp2
 _fptoa(fp2, s);	// fp2 -> ascii

 writeln(s);


 repeat until keypressed;

end.