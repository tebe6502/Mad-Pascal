program Lots_Of_Comments;
uses crt;

begin { This is the start of the main program }

(* This is a comment that is ignored by the Pascal compiler *)
{  This is also ignored }

   Writeln('I am in Pascal school, Dad');      (* Comment *)
   Writeln('All students are always broke');   {Comment}
(*
   Writeln('Send money');
   Writeln('Send money');
    *)
   Writeln('I am really getting hungry');

   repeat until keypressed;

end. (* This is the end of the main program *)


{ Result of execution

I am in Pascal school, Dad
All students are always broke
I am really getting hungry

}
