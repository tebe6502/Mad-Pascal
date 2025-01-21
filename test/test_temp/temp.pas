
        var x,y: smallint;
	    i: byte;
	
	function f_1(a,b: smallint): byte;
	begin
	 Result:=1;
	end;	    
	    
        begin
	    x:=5;
	    i:=1;
            while (x > 0) and (f_1(x-1,y) = i) do dec(x);
        end.
        