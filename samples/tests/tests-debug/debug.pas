program A_Dynamic_Storage_Record;

const
  Number_Of_Friends = 50;

type
  Full_Name = record
    First_Name: String[12];
    Initial: Char;
    Last_Name: String[15];
  end;

  Date = record
    Day: Byte;
    Month: Byte;
    Year: Integer;
  end;

  Person_Id = ^Person;

  Person = record
    Name: Full_Name;
    City: String[15];
    State: String[2];
    Zipcode: String[5];
    Birthday: Date;
  end;

var
  Friend: array[0..Number_Of_Friends] of Person_Id;
  Self, Mother, Father: Person_Id;
  Index: Byte;

begin  (* main program *)
  for Index := 0 to Number_Of_Friends - 1 do
  begin
    Friend[Index]^ := Mother^;
  end;

  
end.
