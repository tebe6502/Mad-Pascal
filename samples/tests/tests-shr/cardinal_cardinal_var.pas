// 12AB9

uses crt;

var
	a, b, v: cardinal;


function shr1(var a: cardinal): byte;
begin
 Result := a shr 1;
end;

function shr2(var a: cardinal): byte;
begin
 Result := a shr 2;
end;

function shr3(var a: cardinal): byte;
begin
 Result := a shr 3;
end;

function shr4(var a: cardinal): byte;
begin
 Result := a shr 4;
end;


function shr26(var a: cardinal): byte;
begin
 Result := a shr 26;
end;

function shr27(var a: cardinal): byte;
begin
 Result := a shr 27;
end;

function shr28(var a: cardinal): byte;
begin
 Result := a shr 28;
end;

function shr29(var a: cardinal): byte;
begin
 Result := a shr 29;
end;

function shr30(var a: cardinal): byte;
begin
 Result := a shr 30;
end;

function shr31(var a: cardinal): byte;
begin
 Result := a shr 31;
end;


begin
	b:=$f7813Fa5;

	a := shr1(b);
	inc(v, a);

	a := shr2(b);
	inc(v, a);

	a := shr3(b);
	inc(v, a);

	a := shr4(b);
	inc(v, a);
{
	a := shr5(b);
 	inc(v, a);

	a := shr6(b);
 	inc(v, a);

	a := shr7(b);
 	inc(v, a);

	a := shr8(b);
 	inc(v, a);

	a := shr9(b);
 	inc(v, a);

	a := shr10(b);
 	inc(v, a);

	a := shr11(b);
 	inc(v, a);

	a := shr12(b);
 	inc(v, a);

	a := shr13(b);
 	inc(v, a);

	a := shr14(b);
 	inc(v, a);

	a := shr15(b);
 	inc(v, a);

	a := shr16(b);
 	inc(v, a);

	a := shr17(b);
 	inc(v, a);

	a := shr18(b);
 	inc(v, a);

	a := shr19(b);
 	inc(v, a);

	a := shr20(b);
 	inc(v, a);

	a := shr21(b);
 	inc(v, a);

	a := shr22(b);
 	inc(v, a);

	a := shr23(b);
 	inc(v, a);

	a := shr24(b);
 	inc(v, a);

	a := shr25(b);
 	inc(v, a);
}
	a := shr26(b);
 	inc(v, a);

	a := shr27(b);
 	inc(v, a);

	a := shr28(b);
 	inc(v, a);

	a := shr29(b);
 	inc(v, a);

	a := shr30(b);
	inc(v, a);

	a := shr31(b);
	inc(v, a);

	writeln(hexStr(v,8));

repeat until keypressed;

end.