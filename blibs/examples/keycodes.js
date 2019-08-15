let CRT_keycode = [];

for (i=0;i<256;i++) {
    CRT_keycode[i] = '#$ff';
}

CRT_keycode[63]= 'a';
CRT_keycode[21]= 'b';
CRT_keycode[18]= 'c';
CRT_keycode[58]= 'd';
CRT_keycode[42]= 'e';
CRT_keycode[56]= 'f';
CRT_keycode[61]= 'g';
CRT_keycode[57]= 'h';
CRT_keycode[13]= 'i';
CRT_keycode[1] = 'j';
CRT_keycode[5] = 'k';
CRT_keycode[0] = 'l';
CRT_keycode[37]= 'm';
CRT_keycode[35]= 'n';
CRT_keycode[8] = 'o';
CRT_keycode[10]= 'p';
CRT_keycode[47]= 'q';
CRT_keycode[40]= 'r';
CRT_keycode[62]= 's';
CRT_keycode[45]= 't';
CRT_keycode[11]= 'u';
CRT_keycode[16]= 'v';
CRT_keycode[46]= 'w';
CRT_keycode[22]= 'x';
CRT_keycode[43]= 'y';
CRT_keycode[23]= 'z';

CRT_keycode[127]= 'A';
CRT_keycode[85] = 'B';
CRT_keycode[82] = 'C';
CRT_keycode[122]= 'D';
CRT_keycode[106]= 'E';
CRT_keycode[120]= 'F';
CRT_keycode[125]= 'G';
CRT_keycode[121]= 'H';
CRT_keycode[77] = 'I';
CRT_keycode[65] = 'J';
CRT_keycode[69] = 'K';
CRT_keycode[64] = 'L';
CRT_keycode[101]= 'M';
CRT_keycode[99] = 'N';
CRT_keycode[72] = 'O';
CRT_keycode[74] = 'P';
CRT_keycode[111]= 'Q';
CRT_keycode[104]= 'R';
CRT_keycode[126]= 'S';
CRT_keycode[109]= 'T';
CRT_keycode[75] = 'U';
CRT_keycode[80] = 'V';
CRT_keycode[110]= 'W';
CRT_keycode[86] = 'X';
CRT_keycode[107]= 'Y';
CRT_keycode[87] = 'Z';
CRT_keycode[97] = ';';

CRT_keycode[33]= ' ';
CRT_keycode[2]= ';';
CRT_keycode[2+64]= ':';
CRT_keycode[6]= '+';
CRT_keycode[6+64]= '\\';
CRT_keycode[7]= '*';
CRT_keycode[7+64]= '^';
CRT_keycode[14]= '-';
CRT_keycode[14+64]= '_';
CRT_keycode[15]= '=';
CRT_keycode[15+64]= '|';
CRT_keycode[32]= ',';
CRT_keycode[32+64]= '[';
CRT_keycode[34]= '.';
CRT_keycode[34+64]= ']';
CRT_keycode[38]= '/';
CRT_keycode[38+64]= '?';

CRT_keycode[31]= '1';
CRT_keycode[31+64]= '!';
CRT_keycode[30]= '2';
CRT_keycode[30+64]= '"';
CRT_keycode[26]= '3';
CRT_keycode[26+64]= '#';
CRT_keycode[24]= '4';
CRT_keycode[24+64]= '$';
CRT_keycode[29]= '5';
CRT_keycode[29+64]= '%';
CRT_keycode[27]= '6';
CRT_keycode[27+64]= '&';
CRT_keycode[51]= '7';
CRT_keycode[51+64]= "'";
CRT_keycode[53]= '8';
CRT_keycode[53+64]= '@';
CRT_keycode[48]= '9';
CRT_keycode[48+64]= '(';
CRT_keycode[50]= '0';
CRT_keycode[50+64]= ')';
CRT_keycode[54]= '<';
CRT_keycode[54]= '>';

CRT_keycode[52] = 'CHAR_BACKSPACE';
CRT_keycode[12] = 'CHAR_RETURN';
CRT_keycode[60] = 'CHAR_CAPS';
CRT_keycode[39] = 'CHAR_INVERSE';
CRT_keycode[44] = 'CHAR_TAB';
CRT_keycode[28] = 'CHAR_ESCAPE';

let str = ''
for (i=0;i<256;i++) {
    str += CRT_keycode[i].length === 1 ? `'${CRT_keycode[i]}'` : CRT_keycode[i];
    str += ', ';
    if (i %16 == 15) {
        str += "\n";
    }
}


console.log(str);
