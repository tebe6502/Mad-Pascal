program Virtual_1;

{ ******************** class definitions **********************}

type
   Vehicle = object
      Wheels : integer;
      Weight : real;
      constructor Init(In_Wheels : integer; In_Weight : real);
      procedure Message;
   end;


   Car = object(Vehicle)
      Passenger_Load : integer;
      constructor Init(In_Wheels : integer;
                       In_Weight : real;
                       People    : integer);
      procedure Message;
   end;


   Truck = Object(Vehicle)
      Passenger_Load : integer;
      Payload        : real;
      constructor Init(People : integer;
                       Max_Load : real;
                       In_Wheels : integer;
                       In_Weight : real);
      procedure Message;
   end;

{ ********************* class implementations ******************** }

   constructor Vehicle.Init(In_Wheels : integer; In_Weight : real);
   begin
      Wheels := In_Wheels;
      Weight := In_Weight;
   end;

   procedure Vehicle.Message;
   begin
      WriteLn('This message is from the vehicle.');
   end;



   constructor Car.Init(In_Wheels : integer;
                        In_Weight : real;
                        People    : integer);
   begin
      Wheels := In_Wheels;
      Weight := In_Weight;
      Passenger_Load := People;
   end;

   procedure Car.Message;
   begin
      WriteLn('This message is from the car.');
   end;



   constructor Truck.Init(People : integer;
                          Max_Load : real;
                          In_Wheels : integer;
                          In_Weight : real);
   begin
      Passenger_Load := People;
      Payload := Max_Load;
      Wheels := In_Wheels;
      Weight := In_Weight;
   end;

   procedure Truck.Message;
   begin
      WriteLn('This message is from the truck.');
   end;



   procedure Output_A_Message(VAR Machine : Vehicle);
   begin
      Write('This is from Output_A_message; ');
      Machine.Message;
   end;


{ ************************ main program ************************** }

var Unicycle : Vehicle;
    Sedan    : Car;
    Semi     : Truck;

begin

   Unicycle.Init(1, 12.0);
   Sedan.Init(4, 2100.0, 5);
   Semi.Init(1, 25000.0, 18, 5000.0);

   WriteLn;
   Unicycle.Message;
   Sedan.Message;
   Semi.Message;

   WriteLn;
   Output_A_Message(Unicycle);
   Output_A_Message(Sedan);
   Output_A_Message(Semi);

end.


{ Result of execution

This message is from the vehicle.
This message is from the car.
This message is from the truck.

This is from Output_A_Message; This message is from the vehicle.
This is from Output_A_Message; This message is from the vehicle.
This is from Output_A_Message; This message is from the vehicle.

}