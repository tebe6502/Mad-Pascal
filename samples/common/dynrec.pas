program A_Dynamic_Storage_Record;

uses
  crt;

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
  Temp: Person;
  Index: Byte;

begin  (* main program *)
  //   New(Self);   (* create the dynamic variable *)
  GetMem(Self, sizeof(Person));

  Self^.Name.First_Name := 'Charley';
  Self^.Name.Initial := 'Z';
  Self^.Name.Last_Name := 'Brown';

  Self^.City := 'Anywhere';
  Self^.State := 'CA';
  Self^.Zipcode := '97342';
  Self^.Birthday.Day := 17;

  Self^.Birthday.Month := 7;
  Self^.Birthday.Year := 1938;    //   (* all data for self now defined *)

  //   New(Mother);
  GetMem(Mother, sizeof(Person));
  Mother := Self;

  //   New(Father);
  GetMem(Father, sizeof(Person));

  Father^ := Mother^;
  for Index := 0 to Number_Of_Friends - 1 do
  begin
    //      New(Friend[Index]);
    GetMem(Friend[Index], sizeof(Person));

    Friend[Index]^ := Mother^;
  end;

  Temp := Friend[27]^;
  Write(Temp.Name.First_Name, ' ');
  Temp := Friend[33]^;
  Write(Temp.Name.Initial, ' ');
  Temp := Father^;
  Write(Temp.Name.Last_Name);
  Writeln;

  //   Dispose(Self);
  {  Dispose(Mother); } (* since Mother is lost, it cannot
                         be disposed of                  *)
  //   Dispose(Father);
  //   for Index := 1 to Number_Of_Friends do
  //      Dispose(Friend[Index]);

  repeat
  until keypressed;
end. (* of main program *)
{ Result of execution

Charley Z Brown

}
