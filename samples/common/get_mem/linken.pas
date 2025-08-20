
program LinkEcho(intput,output);

uses crt;

type
   ElementPointer = ^Element;

   Element = record
                Number : Integer;
                Next : ElementPointer;
             end;

var
   FirstElement : ElementPointer;
   CurrentElement : ElementPointer;
   Number : Integer;

(* Main Program *)
begin

   clrscr;

   (* Initialize the list and its pointers. *)
   GetMem(FirstElement, sizeof(Element));
   FirstElement^.Next := Nil;
   CurrentElement := FirstElement;

   (* Fill the linked list *)
   repeat
      write('Enter number or 0 to exit:');
      readln(Number);
      writeln;

      if Number > 0 then
      begin

         (* Add each number to the list, then add an element. *)
         CurrentElement^.Number := Number;
         GetMem(CurrentElement^.Next, sizeof(Element));
         CurrentElement := CurrentElement^.Next;
         CurrentElement^.Next := Nil;

      end;
   until Number <= 0;

   (* Write the linked list back out *)
   if CurrentElement<>FirstElement then
   begin
      CurrentElement:=FirstElement;
      while CurrentElement^.Next <> Nil do
      begin
         writeln(CurrentElement^.Number);
         CurrentElement:= CurrentElement^.Next
      end (* while loop *)
   end; (* if *)

 repeat until keypressed;

end.
