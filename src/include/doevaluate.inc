
function doEvaluate: integer;
var s: string;
    par1, par2, p1, p2: integer;
    k: integer;

// ----------------------------------------------------------------------------

  function GetParameter: integer;
  var tmp: string;
      Err, IdentTemp: integer;
  begin

     Result:=0;

     tmp := get_digit(k, s);
     if tmp <> '' then begin

      val(tmp, Result, Err);
      if Err > 0 then Error(i, 'Identifier or number expected but ''' + tmp + ''' found');

      if Result < 0 then Error(i, 'evaluation parameter is less than zero');

      exit;
     end;


     tmp := get_constant(k, s);
     if tmp <> '' then begin

      IdentTemp:=GetIdent(tmp);

      if IdentTemp > 0 then
        Result := Ident[IdentTemp].Value
      else
        Error(i, 'Identifier or number expected but ''' + tmp + ''' found');

      if Result < 0 then Error(i, 'evaluation parameter is less than zero');

      exit;
     end;

   Error(i, 'Identifier or number expected but ''' + s[k] + ''' found');
  end;

// ----------------------------------------------------------------------------

  procedure doEvaluations(_0,_1: integer);
  var p: integer;
      _s: string;
      fl: single;
begin

   _s := s;

   if _0 >= 0 then
    while _s.IndexOf(':1') >= 0 do begin
     p:=_s.IndexOf(':1');

     delete(_s, p+1, 2);
     insert(IntToStr(_0), _s, p+1);
    end;

   if _1 >= 0 then
    while _s.IndexOf(':2') >= 0 do begin
     p:=_s.IndexOf(':2');

     delete(_s, p+1, 2);
     insert(IntToStr(_1), _s, p+1);
    end;

   fl := Evaluate(_s, i);

   ConstVal:=Assign(ConstValType, fl);

   SaveData(false);

  end;

// ----------------------------------------------------------------------------


begin

  doEvaluate:=0;

  par1 := -1;
  par2 := -1;

  s := linkObj[ Tok[i + 1].Value ];

  if s <> '' then begin

   k:=1;
   omin_spacje(k, s);

   if s[k] <> '"' then begin

     par1 := GetParameter;

     omin_spacje(k, s);
     if s[k] <> ',' then Error(i, 'Syntax error, '','' expected but ''' + s[k] + ''' found');

     inc(k);
   end;

   omin_spacje(k, s);

   if s[k] <> '"' then begin

     par2 := GetParameter;

     omin_spacje(k, s);
     if s[k] <> ',' then Error(i, 'Syntax error, '','' expected but ''' + s[k] + ''' found');

     inc(k);
   end;

   omin_spacje(k, s);

   if s[k] <> '"' then Error(i, 'Syntax error, ''"'' expected but ''' + s[k] + ''' found');

   s := get_string(k, s, true);

   ActualParamType := ConstValType;

   if par1 > 0 then
    if par2 > 0 then begin

     for p2 := 0 to par2 - 1 do
      for p1 := 0 to par1 - 1 do doEvaluations(p1,p2);

     doEvaluate := par1 * par2;

    end else begin
     for p1 := 0 to par1 - 1 do doEvaluations(p1,-1);

     doEvaluate := par1;
    end;


  end;	// if s <> ''


 inc(i);

end;
