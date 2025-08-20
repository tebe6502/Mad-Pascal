uses crt, atari;

const
    txtmem = $a000;

    dlist: array of byte =
    [
    DL_LMS + DL_MODE_2,
    lo(txtmem), hi(txtmem),
    
    DL_MODE_2,
    DL_MODE_2,
    DL_MODE_2,
    DL_MODE_2,
    DL_MODE_2,
    DL_MODE_2,
    DL_MODE_2,
    
    $41,lo(word(@dlist)),hi(word(@dlist))
    ];


begin

 sdlstl := word(@dlist);
 
 savmsc := txtmem;
 
 writeln('Hello');
 
 repeat until keypressed;

end.