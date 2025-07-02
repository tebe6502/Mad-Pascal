{

Hello There
Woah there!!!
Hello There

}


program Test;

uses crt;

// Make the Types the type corresponds to a function signature
type
  TFuncNoArgsString = function(): String;
  TFuncOneArgsString = function(x: string): string;

  TWord = word;


  var b,h: byte;


// Example functions
function Hello: String; stdcall;
begin
  Result := 'Hello There';
end;

function Woah(G: String): String; stdcall;
begin
  Result := concat('Woah ',G);
end;

// Overloaded function takes the two types of function
// pointers created above
procedure Take(f: TFuncNoArgsString); overload;
begin
  WriteLn(f());
end;

procedure Take(f: TFuncOneArgsString); overload;
begin
  WriteLn(f('there!!!'));
end;


var
  ptr: Pointer;

begin
  // the "@" symbol turns the variable into a pointer.
  // This must be done in order pass a function as a
  // parameter.  This also demonstrates that pascal
  // keeps track of the pointer type so the overloading works!

  Take(@Hello);
  Take(@Woah);

  // Now put a function in an untyped pointer
  ptr := @Hello;

  // Type the pointer and call it all at the same time

  WriteLn( TFuncNoArgsString(ptr) );

 repeat until keypressed;

end.
