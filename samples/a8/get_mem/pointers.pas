
{ Result of execution

My name is John Q Doe
My age is  27

}

program Pointer_Use_Example;
uses crt;

type Name  = string[20];

var  My_Name : ^Name; (* My_Name is a pointer to a string[20] *)
     My_Age  : ^integer;  (* My_Age is a pointer to an integer *)
     
begin

   GetMem(My_Name, sizeof(Name));
   GetMem(My_Age, sizeof(Integer));

   My_Name^ := 'John Q Doe';
   My_Age^ := 27;

   Writeln('My name is ',My_Name^);
   Writeln('My age is ',My_Age^:3);

   FreeMem(My_Age, sizeof(Integer));
   FreeMem(My_Name, sizeof(Name));

   repeat until keypressed;
end.
