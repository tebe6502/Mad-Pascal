
function DoEvaluate(const evaluationContext: IEvaluationContext): Integer;
var
  s: String;
  par1, par2, p1, p2: Integer;
  k: Integer;

  // ----------------------------------------------------------------------------

  function GetParameter: Integer;
  var
    tmp: String;
    err: Integer;
    constantValue: TInteger;
  begin

    Result := 0;

    tmp := GetNumber(s, k);
    if tmp <> '' then
    begin

      val(tmp, Result, err);
      if err > 0 then Error(i, 'Identifier or number expected but ''' + tmp + ''' found');

      if Result < 0 then Error(i, 'evaluation parameter is less than zero');

      exit;
    end;


    tmp := evaluationContext.GetConstantName(s, k);
    if tmp <> '' then
    begin

      constantValue := 0;
      if evaluationContext.GetConstantValue(tmp, constantValue) then
        Result := constantValue
      else
        Error(i, 'Identifier or number expected but ''' + tmp + ''' found');

      if Result < 0 then Error(i, 'evaluation parameter is less than zero');

      exit;
    end;

    Error(i, 'Identifier or number expected but ''' + s[k] + ''' found');
  end;

  // ----------------------------------------------------------------------------

  procedure doEvaluations(_0, _1: Integer);
  var
    p: Integer;
    _s: String;
    fl: Single;
  begin

    _s := s;

    if _0 >= 0 then
      while _s.IndexOf(':1') >= 0 do
      begin
        p := _s.IndexOf(':1');

        Delete(_s, p + 1, 2);
        Insert(IntToStr(_0), _s, p + 1);
      end;

    if _1 >= 0 then
      while _s.IndexOf(':2') >= 0 do
      begin
        p := _s.IndexOf(':2');

        Delete(_s, p + 1, 2);
        Insert(IntToStr(_1), _s, p + 1);
      end;

    try
      fl := MathEvaluate.Evaluate(_s, evaluationContext);
    except
      on e: EEvaluationException do
        Error(i, 'Evaluation error at position ' + IntToStr(e.Index) + ' of expression ''' + e.expression + '''. ' + e.message);
    end;

    ConstVal := Assign(ConstValType, fl);

    SaveData(False);

  end;

  // ----------------------------------------------------------------------------

begin

  Result := 0;

  par1 := -1;
  par2 := -1;

  s := linkObj[Tok[i + 1].Value];

  if s <> '' then
  begin

    k := 1;
    SkipWhitespaces(s,k);

    if s[k] <> '"' then
    begin

      par1 := GetParameter;

      SkipWhitespaces(s,k);
      if s[k] <> ',' then Error(i, 'Syntax error, '','' expected but ''' + s[k] + ''' found');

      Inc(k);
    end;

    SkipWhitespaces(s,k);

    if s[k] <> '"' then
    begin

      par2 := GetParameter;

      SkipWhitespaces(s,k);
      if s[k] <> ',' then Error(i, 'Syntax error, '','' expected but ''' + s[k] + ''' found');

      Inc(k);
    end;

    SkipWhitespaces(s,k);

    if s[k] <> '"' then Error(i, 'Syntax error, ''"'' expected but ''' + s[k] + ''' found');

    s := GetStringUpperCase(s, k);

    ActualParamType := ConstValType;

    if par1 > 0 then
      if par2 > 0 then
      begin

        for p2 := 0 to par2 - 1 do
          for p1 := 0 to par1 - 1 do doEvaluations(p1, p2);

        Result := par1 * par2;

      end
      else
      begin
        for p1 := 0 to par1 - 1 do doEvaluations(p1, -1);

        Result := par1;
      end;

  end;  // if s <> ''


  Inc(i);

end;
