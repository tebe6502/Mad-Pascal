uses crt;

const
	width = 40;
	height = 30;
	
	scr = $bc40;

var
	tab: array of word = [ {$eval HEIGHT, "scr + :1 * WIDTH" }  ];

	v: word;

begin

 for v in tab do writeln(v);

 repeat until keypressed;

end.