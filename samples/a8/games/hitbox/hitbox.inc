
   if f = 0 then begin

     drawBox(b1, 0);
     drawBox(b2, 2);

     case v of
         joy_up: dec(b1.y);
       joy_down: inc(b1.y);
       joy_left: dec(b1.x);
      joy_right: inc(b1.x);
     end;

     drawBox(b1, 1);

   end else begin

     drawBox(b1, 1);
     drawBox(b2, 0);

     case v of
         joy_up: dec(b2.y);
       joy_down: inc(b2.y);
       joy_left: dec(b2.x);
      joy_right: inc(b2.x);
     end;

     drawBox(b2, 2);

   end;
