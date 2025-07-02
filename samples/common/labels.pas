program Label_Illustration;
uses crt;

label l274,Repeat_Loop,Help,Dog;

var Counter : byte;  (* This limits us to a maximum of 255 *)

begin
   Writeln('Start here and go to "help"');
   goto Help;

Dog:
   Writeln('Now go and end this silly program');
   goto l274;

Repeat_Loop:
   for Counter := 1 to 4 do Writeln('In the repeat loop');
   goto Dog;

Help:
   Writeln('This is the help section that does nothing');
   goto Repeat_Loop;

l274:
   Writeln('This is the end of this spaghetti code');

   repeat until keypressed;
end.


{ Result of execution

Start here and go to "help"
This is the help section that does nothing
In the repeat loop
In the repeat loop
In the repeat loop
In the repeat loop
Now go and end this silly program
This is the end of this spaghetti code

}