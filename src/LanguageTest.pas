unit LanguageTest;

{$MODESWITCH NESTEDPROCVARS}

interface

procedure Test;

implementation

uses Asserts, SysUtils;

procedure Test();


   procedure TestFor;
   var
     i, j: Integer;
   begin
     j := 1;
     for i := 1 to 10 do
     begin
       AssertEquals(i, j);
       j := j + 1;
     end;
     AssertEquals(i, 10);
   end;

   procedure TestVal(const s: String; const ExpectedValue: Integer; const ExpectedCode: Integer);
   var
     ActualValue, ActualCode: Integer;
   begin
     System.Val(s, ActualValue, ActualCode);
     AssertEquals(ActualValue, ExpectedValue);
     AssertEquals(ActualCode, ExpectedCode);
   end;

   // https://www.freepascal.org/docs-html/ref/refsu69.html
   procedure TestArrayOfConst;
   type
     TListing = array[1..12] of String;
   var
     Listing: TListing;

     procedure DisplayArrayOfConst(const Args: array of const);
     var
       I: Longint;
     begin
       if High(Args) < 0 then
       begin
         Writeln('No aguments');
         exit;
       end;
       Writeln('Got ', High(Args) + 1, ' arguments :');
       for i := 0 to High(Args) do
       begin
         Write('Argument ', i, ' has type ');
         case Args[i].vtype of
           vtinteger:
             Writeln('Integer, Value :', args[i].vinteger);
           vtboolean:
             Writeln('Boolean, Value :', args[i].vboolean);
           vtchar:
             Writeln('Char, value : ', args[i].vchar);
           vtextended:
             Writeln('Extended, value : ', args[i].VExtended^);
           vtString:
             Writeln('ShortString, value :', args[i].VString^);
           vtPointer:
             Writeln('Pointer, value : ', Longint(Args[i].VPointer));
           vtPChar:
             Writeln('PChar, value : ', Args[i].VPChar);
           vtObject:
             Writeln('Object, name : ', Args[i].VObject.ClassName);
           vtClass:
             Writeln('Class reference, name :', Args[i].VClass.ClassName);
           vtAnsiString:
             Writeln('AnsiString, value :', Ansistring(Args[I].VAnsiString));
           else
             Writeln('(Unknown) : ', args[i].vtype);
         end;
       end;
     end;

     function TestVarArgs(const fmt: String; args: array of const): String;
     begin
       Result := Format(fmt, args);
     end;

   begin
     AssertEquals(TestVarArgs('%d', [1]), '1');
     DisplayArrayOfConst([1, 'String', @listing]);
   end;


   // Note: This requires {$MODESWITCH NESTEDPROCVARS}
   procedure TestFunctionPointer;
   var
     global: Integer;

     function TestFunction(const i: Integer): Boolean;
     begin
       Result := (i > global);
     end;

   type
     TFunction = function(const i: Integer): Boolean;
   var
     f: TFunction;
   begin

     Assert(TestFunction(1) = True);
     f := @TestFunction;
     global := 0;
     Assert(f(1) = True);
   end;

 begin
   TestFor;

   TestVal('1234', 1234, 0);
   TestVal('$1234', $1234, 0);

   TestArrayofConst;

   TestFunctionPointer;

 end;


end.
