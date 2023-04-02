program Linked_List_Example;
uses crt;

type Next_Pointer = ^Full_Name;

     Full_Name = record
       First_Name : string[12];
       Initial    : char;
       Last_Name  : string[15];
       Next       : Next_Pointer;
     end;

var  Start_Of_List : Next_Pointer;
     Place_In_List : Next_Pointer;
     Temp_Place    : Next_Pointer;
     Index         : integer;

begin  (* main program *)
                       (* generate the first name in the list *)
//   New(Place_In_List);

   GetMem(Place_In_List, sizeof(Full_Name));

   Start_Of_List := Place_In_List;

   Place_In_List^.First_Name := 'John';
   Place_In_List^.Initial := 'Q';
   Place_In_List^.Last_Name := 'Doe';
   Place_In_List^.Next := nil;

                       (* generate another name in the list *)
   Temp_Place := Place_In_List;

//   New(Place_In_List);
   GetMem(Place_In_List, sizeof(Full_Name));

   Temp_Place^.Next := Place_In_List;
   Place_In_List^.First_Name := 'Mary';
   Place_In_List^.Initial := 'R';
   Place_In_List^.Last_Name := 'Johnson';
   Place_In_List^.Next := nil;

                  (* add 10 more names to complete the list *)
   for Index := 1 to 10 do begin
      Temp_Place := Place_In_List;

//      New(Place_In_List);
      GetMem(Place_In_List, sizeof(Full_Name));

      Temp_Place^.Next := Place_In_List;
      Place_In_List^.First_Name := 'William';
      Place_In_List^.Initial := 'S';
      Place_In_List^.Last_Name := 'Jones';
      Place_In_List^.Next := nil;
   end;

                   (* display the list on the video monitor *)
   Place_In_List := Start_Of_List;
   repeat
      Write(Place_In_List^.First_Name);
      Write(' ',Place_In_List^.Initial);
      Writeln(' ',Place_In_List^.Last_Name);
      Temp_Place := Place_In_List;
      Place_In_List := Place_In_List^.Next;
   until Temp_Place^.Next = nil;

   repeat until keypressed;

end.  (* of main program *)


{ Result of execution

John Q Doe
Mary R Johnson
William S Jones
William S Jones
William S Jones
William S Jones
William S Jones
William S Jones
William S Jones
William S Jones
William S Jones
William S Jones

}
