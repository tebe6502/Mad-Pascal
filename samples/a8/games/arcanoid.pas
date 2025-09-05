uses crt, joystick;

const
	SCREEN_SIZE = 40;
	PADDLE_SIZE = 6;
	PADDLE_Y = 20;
	BRICK = 29;
	PADDLE = 213;
	BALL = 84;
	
	COLOR1 = $2C5;
	COLOR2 = $2C6;
	CDTMV3 = $21C;
	ATTRACT = $4D;	

var
// Global variables

	video_ptr: ^byte;
	total_bricks, ball_x, ball_y: byte;
	paddle_pos: byte = 0;
	ball_dx, ball_dy: shortint;
	lives: byte = 6;

	RND: byte absolute $D20A;


procedure set_colors;
begin
	POKE(COLOR1,$FF);	// font color
	POKE(COLOR2,0);		// background color
end;


procedure draw_bricks;
begin
  fillchar(video_ptr, 4*SCREEN_SIZE, BRICK);
end;


procedure draw_paddle;
var s: ^byte;
begin 

 s:=pointer(word(video_ptr)+PADDLE_Y*40 - 1 + paddle_pos);
 
 s^:=0;
 inc(s);

 fillchar(s, PADDLE_SIZE, PADDLE);

 inc(s, PADDLE_SIZE);
 
 s^:=0;

end;


procedure win;
begin
 write('Win!');
 repeat until false;
end;


procedure next_life;
var i: byte;
    s: ^byte;
const
    dx : array [0..1] of shortint = (1,-1);
begin

  dec(lives);
  if lives=0 then begin
      write('Game over');
      repeat until false;
  end;
  
// show available balls
  s:=pointer(word(video_ptr)+(PADDLE_Y+2)*40); 
  fillchar(s, lives, BALL);
  
  inc(s, lives); 
  s^:=0;

// set_ball_position

  ball_x:=paddle_pos+3;
  ball_y:=18;
  ball_dy:=-1;
  ball_dx:=dx[RND and 1];
end;


procedure move_ball;
var s: ^byte;
begin
  // remove ball
  s:=pointer(word(video_ptr)+ball_y*40+ball_x);
  s^:=0;
  
  // bounce ball on the top of the screen
  if (ball_y=0) then ball_dy := 1 else
   if (ball_y=PADDLE_Y-1) then begin	// ball on the line of the paddle
    // hit the paddle?
    if (ball_x>=paddle_pos) and (ball_x<paddle_pos+PADDLE_SIZE) then
        ball_dy := -1
    else begin	// ball missed the paddle
      next_life;
      exit;
    end;

   end;
  
  // bounce the ball on the borders
  if (ball_x=0) then
      ball_dx := 1
  else if (ball_x=SCREEN_SIZE-1) then
      ball_dx := -1;

  // change the ball position
  inc(ball_x, ball_dx);
  inc(ball_y, ball_dy);  

  // ball hit the brick
  s:=pointer(word(video_ptr)+ball_y*40+ball_x);

  if (s^=BRICK) then begin
   dec(total_bricks);
   if total_bricks=0 then win;

   ball_dy := -ball_dy;      
  end;
   
  // draw ball
  s^:=BALL;
end;


begin

 clrscr;

 video_ptr := pointer(dpeek(88));
 
 set_colors;
 draw_bricks;
 
 paddle_pos:=(SCREEN_SIZE-PADDLE_SIZE) shr 1;
 next_life;

 repeat 
 
    // wait a moment and read the joystick state after that 
    POKE(CDTMV3,3);
    while (PEEK(CDTMV3))<>0 do ;
    POKE(ATTRACT,0); // Disable Attract mode
    
    case joy_1 of
      joy_left: if paddle_pos>0 then dec(paddle_pos);
     joy_right: if paddle_pos<SCREEN_SIZE-PADDLE_SIZE then inc(paddle_pos);
    end;

    draw_paddle;
    move_ball;
  
 until false;

end.


