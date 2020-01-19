program JDate;

uses crt;

var
dd,mm,yyyy, Julian: smallint;
ok : boolean;

{ Julian number to date conversions - 9/10/1984
Actually, these are not Julian dates but rather just day numbers designed
for use with dates in the twentieth century. The dates are stored in a
standard integer variable and range from January 1,1900 as -32767 to
June 5, 2079 in the twenty-first century at +32767.

The advantage of using day numbers is that the number of days between
two dates is simply calculated as Date1-Date2.

A magic number to be remembered is the one used to convert from the dates
in this format into the dates used by Digital Research in products such
as CP/M Plus. To convert into DRI's format from mine, add 4279 to the
integer value. To convert back from DRI's format into mine, subtract 4279.

The algorithms used in these routines were taken from an article in
Dr Dobb's Journal and came from an ACM publication before that.
If an exact bibliography is desired, contact me on Compuserve [74206,21].

I am releasing any and all rights that I may have on these routines into
the public domain and only hope that any fixes or enhancements are
re-released to the public.

Scott Bussinger
Professional Practice Systems
112 South 131st Street
Tacoma, Wa 98444 }

procedure DtoJ(Day,Month,Year: smallint; var Julian: smallint);
{ Convert from a date to a Julian number -- January 1, 1900 = -32767 }
{ Note that much care is taken to avoid problems with inaccurate bit
representations inherent in the binary fractions of the real numbers
used as temporary variables. Thus the seemingly unnecessary use of
small fractional offsets and int() functions }
begin

if (Year=1900) and (Month<3) { Handle the first two months as a special case since the general }
then { algorithm used doesn't start until March 1, 1900 }
if Month=1
then
Julian := Day-$8000 { Compiler won't accept -32768 as a valid integer, so use the hex form }
else
Julian := Day-32737
else
begin
if Month>2
then
Month := Month-3
else
begin
Month := Month+9;
Year := Year-1
end;
Year := Year-1900;
Julian := round(-32709+Day+int(0.125+int(1461*Year+0.5)/4))+((153*Month+2) div 5);
end;

end;

procedure JtoD(Julian: smallint; var Day, Month,Year: smallint);
{ Convert from a Julian date to a calendar date }
{ Note that much care is taken to avoid problems with inaccurate bit
representations inherent in the binary fractions of the real numbers
used as temporary variables. Thus the seemingly unnecessary use of
small fractional offsets and int() functions }
var Temp: real;
begin
Temp := int(32767.5+Julian); { Convert 16 bit quantity into a real number }
if Temp<58.5
then
begin { The first two months of the twentieth century are handled as a special }
Year := 1900; { case of the general algorithm used which handles all of the rest }
if Temp<30.5
then
begin
Month := 1;
Day := round(Temp+1.0)
end
else
begin
Month := 2;
Day := round(Temp-30.0)
end
end
else
begin
Temp := int(4.0*(Temp-59.0)+3.5);
Year := trunc(Temp/1461.0+0.00034223); { 0.00034223 is about one half of the reciprocal of 1461.0 }
Day := succ(round(Temp-Year*1461) div 4);

Month := (5*Day-3) div 153;
Day := succ((5*Day-3) mod 153 div 5);
Year := Year+1900;

if Month<10
then
Month := Month+3
else
begin
Month := Month-9;
Year := succ(Year)
end;
end;

end;

function DayOfWeek(Julian: smallint): byte;
{ Return an integer representing the day of week for the date }
{ Sunday = 0, etc. }
var Temp: real;
begin
Temp := Julian+32767.0; { Convert into a real temporary variable }
Result := round(frac((Temp+1.0)/7.0)*7.0) { Essentially this is a real number version of Julian mod 7 with }
end; { an offset to make Sunday = 0 }

procedure WriteDate(Julian: smallint);
{ Write the date out to the console in long form , e.g. "Monday, September 10, 1984" }
var Day, Month, Year: smallint;
    Days, Months: String;
begin
JtoD(Julian,Day,Month,Year); { Convert into date form }

case DayOfWeek(Julian) of
 0: Days:='Sunday';
 1: Days:='Monday';
 2: Days:='Tuesday';
 3: Days:='Wednesday';
 4: Days:='Thursday';
 5: Days:='Friday';
 6: Days:='Saturday';
end;

case byte(Month) of
  1: Months:='January';
  2: Months:='February';
  3: Months:='March';
  4: Months:='April';
  5: Months:='May';
  6: Months:='June';
  7: Months:='July';
  8: Months:='August';
  9: Months:='September';
 10: Months:='October';
 11: Months:='November';
 12: Months:='December';
end;

writeln;
writeln(Days,', ',Months,' ',Day,', ',Year);
end;

begin
clrscr;
{$I-}
repeat

write('Enter Month: '); readln(mm);
write('        Day: '); readln(dd);
write('       Year: '); readln(yyyy);

ok:= (IOResult = 0);

DtoJ(dd,mm,yyyy,Julian);
WriteDate(Julian);
writeln;
until not ok;
end.
