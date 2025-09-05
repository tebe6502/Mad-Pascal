program Encapsulation_1;

uses crt;

type
   Box = object
      _length : integer;
      width  : integer;
      constructor Init(len, wid : integer);
      procedure Set_Data(len, wid : integer);
      function Get_Area : integer;
   end;

   constructor Box.Init(len, wid : integer);
   begin
      _length := len;
      width := wid;
   end;

   procedure Box.Set_Data(len, wid : integer);
   begin
      _length := len;
      width := wid;
   end;

   function Box.Get_Area : integer;
   begin
      Result := _length * width;
   end;

var Small, Medium, Large : Box;

begin

   Small.Init(8,8);
   Medium.Init(10,12);
   Large.Init(15,20);

   WriteLn('The area of the small box is ',Small.Get_Area);
   WriteLn('The area of the medium box is ',Medium.Get_Area);
   WriteLn('The area of the large box is ',Large.Get_Area);

   repeat until keypressed;
end.


{ Result of execution

The area of the small box is 64
The area of the medium box is 120
The area of the large box is 300

}