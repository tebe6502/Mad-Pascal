program Enumerated_Types;

uses crt;

type Days = (Mon,Tue,Wed,Thu,Fri,Sat,Sun);
     Time_Of_Day = (Morning,Afternoon,Evening,Night);

var  Day              : Days;
     Time             : Time_Of_Day;
     Regular_Rate     : real;
     Evening_Premium  : real;
     Night_Premium    : real;
     Weekend_Premium  : real;
     Total_Pay        : real;

begin  (* main program *)
   Writeln('Pay rate table':33);
   Writeln;
   Write('  DAY        Morning  Afternoon');
   Writeln('  Evening    Night');
   Writeln;

   Regular_Rate := 12.00;     (* This is the normal pay rate *)
   Evening_Premium := 1.10;   (* 10 percent extra for working late *)
   Night_Premium := 1.33;     (* 33 percent extra for graveyard *)
   Weekend_Premium := 1.25;   (* 25 percent extra for weekends *)

   for Day := Mon to Sun do begin
      case Day of
        Mon : Write('Monday   ');
        Tue : Write('Tuesday  ');
        Wed : Write('Wednesday');
        Thu : Write('Thursday ');
        Fri : Write('Friday   ');
        Sat : Write('Saturday ');
        Sun : Write('Sunday   ');
      end;  (* of case statement *)

      for Time := Morning to Night do begin
         case Time of
           Morning   : Total_Pay := Regular_Rate;
           Afternoon : Total_Pay := Regular_Rate;
           Evening   : Total_Pay := Regular_Rate * Evening_Premium;
           Night     : Total_Pay := Regular_Rate * Night_Premium;
         end;  (* of case statement *)

         case Day of
           Sat : Total_Pay := Total_Pay * Weekend_Premium;
           Sun : Total_Pay := Total_Pay * Weekend_Premium;
         end;  (* of case statement *)

         Write(Total_Pay:10:2);
      end;  (* of "for Time" loop *)
      Writeln;

   end; (* of "for Day" loop *)


 repeat until keypressed;

end.  (* of main program *)


{ Result of execution

                    Pay rate table

 DAY          Morning  Afternoon   Evening     Night

 Monday        12.00     12.00      13.20      15.96
 Tuesday       12.00     12.00      13.20      15.96
 Wednesday     12.00     12.00      13.20      15.96
 Thursday      12.00     12.00      13.20      15.96
 Friday        12.00     12.00      13.20      15.96
 Saturday      15.00     15.00      16.50      19.95
 Sunday        15.00     15.00      16.50      19.95

}
