uses x16_vtui, x16, crt;

const
  HS = 7;
var
  i: byte;
  s,line: string;
  
  cb:TBorder;

begin
  // cb.topLeft:=$7f;
  // cb.topRight:=$7f;
  // cb.bottomLeft:=$7f;
  // cb.bottomRight:=$7f;
  // cb.hor:=$7f;
  // cb.ver:=$7f;

  cb.topLeft:=$f0;
  cb.topRight:=$ee;
  cb.bottomLeft:=$ed;
  cb.bottomRight:=$fd;
  cb.hor:=$c0;
  cb.ver:=$c2;

  vtuiInit;
  vtuiSetScreen(vtui_mode_80x60);
  vtuiClrScr($66, BLUE shl 4 + WHITE);
  vtuiGotoXY(0,0);
  vtuiBorder(3, 80, 60, BLUE shl 4 + WHITE);
  vtuiGotoXY(2,4);
  vtuiHLine($3D, 28, BLUE shl 4 + WHITE);
  vtuiGotoXY(50,4);
  vtuiHLine($3D, 28, BLUE shl 4 + WHITE);
  vtuiGotoXY(31,2);
  vtuiBorder(3, 18, 5, BLUE shl 4 + YELLOW);
  vtuiGotoXY(32,3);
  vtuiFillBox(' ', 16, 3, BLUE shl 4 + WHITE);
  vtuiGotoXY(34,4);
  vtuiPrint('VTUI LIBRARY', BLUE shl 4 + LIGHT_GREEN, PETSCII_TRUE);

  vtuiGotoXY(3,9);
  vtuiBorder(2, 40, 13, WHITE shl 4 + RED);
  vtuiGotoXY(4,10);
  vtuiFillBox(' ', 38, 11, WHITE shl 4 + RED);
  vtuiGotoXY(19,9);
  vtuiPrint(' WINDOWS ', WHITE shl 4 + RED, PETSCII_TRUE);
  vtuiGotoXY(4,10);
  vtuiPrint('WINDOWS ARE EASLY CREATED BY USING', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,11);
  vtuiPrint('FILL-BOX AND BORDER. VERA IS FAST', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,12);
  vtuiPrint('ENOUGH TO JUST USE FILL-BOX TO CREATE', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,13);
  vtuiPrint('SHADOWS AROUND WINDOWS.', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,15);
  vtuiPrint('6 DIFFERENT BORDER TYPES ARE SUPPORTED', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,16);
  vtuiPrint('IF NECESSARY, BORDERS CAN BE CREATED', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,17);
  vtuiPrint('MANUALLY BY USING HLINE AND VLINE', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,19);
  vtuiPrint('WINDOW NAMES AND OTHER DETAILS CAN BE', WHITE shl 4 + BLACK, PETSCII_TRUE);
  vtuiGotoXY(4,20);
  vtuiPrint('ADDED MANUALLY AFTER BORDER IS DRAWN.', WHITE shl 4 + BLACK, PETSCII_TRUE);
  // shadow
  vtuiGotoXY(4,22);
  vtuiHLine($66, 40, BLACK shl 4 + GREY);
  vtuiGotoXY(43,10);
  vtuiVLine($66, 13, BLACK shl 4 + GREY);

  //borders
  for i:=0 to 5 do begin
    vtuiGotoXY(47,8+(i*HS));
    vtuiBorder(i, 30, 5, ORANGE shl 4 + LIGHT_GREY);
    vtuiGotoXY(48,9+(i*HS));
    vtuiFillBox(' ', 28, 3, ORANGE shl 4 + LIGHT_GREY);
    vtuiGotoXY(50,10+(i*HS));
    Str(i,s);
    line:=Concat('BORDER MODE ',s);
    vtuiPrint(line, (ORANGE shl 4) + LIGHT_GREY, PETSCII_TRUE);

      // shadow
    vtuiGotoXY(48,13+(i*HS));
    vtuiHLine($66, 30, BLACK shl 4 + GREY);
    vtuiGotoXY(77,9+(i*HS));
    vtuiVLine($66, 5, BLACK shl 4 + GREY);
  end;

    vtuiGotoXY(47,8+(6*HS));
    vtuiBorder(cb, 30, 5, ORANGE shl 4 + LIGHT_GREY);
    vtuiGotoXY(48,9+(6*HS));
    vtuiFillBox(' ', 28, 3, ORANGE shl 4 + LIGHT_GREY);
    vtuiGotoXY(50,10+(6*HS));
    vtuiPrint('BORDER MODE 6', (ORANGE shl 4) + LIGHT_GREY, PETSCII_TRUE);

    // vtuiGotoXY(48,13+(6*HS));
    // vtuiHLine($66, 30, BLACK shl 4 + GREY);
    // vtuiGotoXY(77,9+(6*HS));
    // vtuiVLine($66, 5, BLACK shl 4 + GREY);

  vtuiGotoXY(3,25);
  vtuiBorder(5, 40, 25, CYAN shl 4 + BLACK);
  vtuiGotoXY(4,26);
  vtuiFillBox(' ', 38, 23, BLACK shl 4 + CYAN);
  vtuiGotoXY(10,25);
  vtuiPrint(' FUNCTIONS OF THE LIBRARY ', CYAN shl 4 + BLACK, PETSCII_TRUE);

  vtuiGotoXY(5,27);
  vtuiPrint('* VTUIINIT', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,28);
  vtuiPrint('* VTUISETSCREEN', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,29);
  vtuiPrint('* VTUISETBANK', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,30);
  vtuiPrint('* VTUISETSTRIDE', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,31);
  vtuiPrint('* VTUIPETSCII2SCR', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,32);
  vtuiPrint('* VTUISCR2PETSCII', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,33);
  vtuiPrint('* VTUICLRSCR', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,34);
  vtuiPrint('* VTUIGOTOXY', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,35);
  vtuiPrint('* VTUIPRINT', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,36);
  vtuiPrint('* VTUIHLINE', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,37);
  vtuiPrint('* VTUIVLINE', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,38);
  vtuiPrint('* VTUIBORDER', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,39);
  vtuiPrint('* VTUIFILLBOX', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,40);
  vtuiPrint('* VTUISAVERECT', BLACK shl 4 + CYAN, PETSCII_TRUE);
  vtuiGotoXY(5,41);
  vtuiPrint('* VTUIRESTORERECT', BLACK shl 4 + CYAN, PETSCII_TRUE);








  vtuiGotoXY(4,55);
  vtuiFillBox(' ', 72, 3, BLUE shl 4 + WHITE);
  vtuiGotoXY(7, 56);
  vtuiPrint('VISIT HTTPS://GITHUB.COM/JIMMYDANSBO/VTUILIB/ FOR MORE INFORMATION', BLUE shl 4 + WHITE, PETSCII_TRUE);
  
  repeat until keypressed;
end.