// Draw character
procedure PutChar(ch : char; x, y : byte);
begin
  case ch of
    'A': begin
      Line(x, y, x + 2, y);
      Line(x, y + 1, x, y + 4);
      Line(x + 2, y + 1, x + 2, y + 4);
      PutPixel(x + 1, y + 2);
//       Line(x + 1, y, x, y + 4);
//       Line(x + 1, y, x + 2, y + 4);
//       PutPixel(x + 1, y + 3);
    end;
    'B': begin
      Line(x, y, x, y + 4);
      PutPixel(x + 1, y);
      PutPixel(x + 2, y + 1);
      Line(x, y + 2, x + 2, y + 2);
      PutPixel(x + 2, y + 3);
      PutPixel(x + 1, y + 4);
      PutPixel(x + 2, y + 4);            
    end;
    'C': begin
      Line(x + 1, y, x + 2, y);
      Line(x, y + 1, x, y + 3);
      Line(x + 1, y + 4, x + 2, y + 4);
    end;
    'D': begin
      Line(x, y, x, y + 4);
      PutPixel(x + 1, y);
      PutPixel(x + 1, y + 4);
      Line(x + 2, y + 1, x + 2, y + 3);
    end;
    'E': begin
      Line(x, y, x + 2, y);
      PutPixel(x, y + 1);
      Line(x, y + 2, x + 2, y + 2);
      PutPixel(x, y + 3);
      Line(x, y + 4, x + 2, y + 4);
    end;
    'F': begin
      Line(x, y, x, y + 4);
      Line(x + 1, y, x + 2, y);
      Line(x + 1, y + 2, x + 2, y + 2);      
    end;
    'G': begin
      Line(x + 1, y, x + 2, y);
      Line(x, y + 1, x, y + 3);
      Line(x + 1, y + 4, x + 2, y + 4);
      Line(x + 2, y + 2, x + 2, y + 3);
    end;
    'H': begin
      Line(x, y, x, y + 4);
      Line(x + 2, y, x + 2, y + 4);
      PutPixel(x + 1, y + 2);
    end;
    'I': begin
      Line(x, y, x, y + 4);
    end;
    'J': begin
      Line(x + 2, y, x + 2, y + 3);
      PutPixel(x + 1, y + 4);
      PutPixel(x, y + 3);
    end;
    'K': begin
      Line(x, y, x, y + 4);
      Line(x + 1, y + 1, x + 2, y);
      Line(x + 1, y + 2, x + 2, y + 4);
    end;
    'L': begin
      Line(x, y, x, y + 4);
      Line(x + 1, y + 4, x + 2, y + 4);
    end;
    'M': begin
      Line(x, y, x, y + 4);
      Line(x + 2, y, x + 2, y + 4);
      PutPixel(x + 1, y + 1);
      PutPixel(x + 1, y + 2);
    end;
    'N': begin
      Line(x, y, x, y + 4);
      Line(x + 2, y, x + 2, y + 4);
      PutPixel(x + 1, y + 1);
    end;
    'O': begin
      Rectangle(x, y, x + 2, y + 4);
    end;
    'P': begin
      Rectangle(x, y, x + 2, y + 2);
      Line(x, y + 3, x, y + 4);
      //PutPixel(x, y + 4);
    end;
    'Q': begin
      Rectangle(x, y, x + 2, y + 3);
      PutPixel(x + 2, y + 4);
    end;
    'R': begin
      Rectangle(x, y, x + 2, y + 2);
      Line(x, y + 3, x, y + 4);
      Line(x + 1, y + 3, x + 2, y + 4);
    end;
    'S': begin
      Line(x, y, x + 2, y);
      PutPixel(x, y + 1);
      Line(x, y + 2, x + 2, y + 2);
      PutPixel(x + 2, y + 3);
      Line(x, y + 4, x + 2, y + 4);
    end;
    'T': begin
      Line(x, y, x + 2, y);
      Line(x + 1, y + 1, x + 1, y + 4);
    end;
    'U': begin
      Line(x, y, x, y + 4);
      Line(x + 2, y, x + 2, y + 4);
      PutPixel(x + 1, y + 4);
    end;
    'V': begin
      Line(x, y, x, y + 3);
      Line(x + 2, y, x + 2, y + 3);
      PutPixel(x + 1, y + 4);
    end;
    'Y': begin
      Line(x, y, x + 1, y + 4);
      Line(x + 2, y, x + 1, y + 4);
    end;
    'X': begin
      Line(x, y, x + 2, y + 4);
      Line(x + 2, y, x, y + 4);
    end;
    'W': begin
      Line(x, y, x, y + 4);
      Line(x + 2, y, x + 2, y + 4);
      PutPixel(x + 1, y + 2);
      PutPixel(x + 1, y + 3);
    end;
    'Z': begin
      Line(x, y, x + 2, y);
      Line(x + 2, y + 1, x, y + 3);
      Line(x, y + 4, x + 2, y + 4);
    end;
    '1': begin
      Line(x + 2, y, x + 2, y + 4);
      Line(x + 1, y + 1, x, y + 2);
    end;
    '2': begin
      //Line(x + 1, y, x + 2, y);
      PutPixel(x + 1, y);
      PutPixel(x, y + 1);
      //PutPixel(x + 2, y + 1);
      Line(x + 2, y + 1, x, y + 3);
      Line(x, y + 4, x + 2, y + 4);
    end;
    '3': begin
      PutPixel(x + 1, y); PutPixel(x + 2, y);
      PutPixel(x, y);
      PutPixel(x + 2, y + 1);
      PutPixel(x + 2, y + 3);
      PutPixel(x + 1, y + 4); PutPixel(x + 2, y + 4);
      PutPixel(x, y + 4);
      Line(x + 1, y + 2, x + 2, y + 2);
    end;
    '4': begin
      Line(x + 2, y, x, y + 2);
      Line(x, y + 3, x + 2, y + 3);
      Line(x + 2, y + 2, x + 2, y + 4);
    end;
    '5': begin
      Line(x, y, x + 2, y);
      PutPixel(x, y + 1);
      Line(x + 1, y + 2, x + 2, y + 2);
      PutPixel(x + 2, y + 3);
      Line(x, y + 4, x + 2, y + 4);
    end;
    '6': begin
      //PutPixel(x + 1, y);
      Line(x, y + 1, x + 1, y);
      Rectangle(x, y + 2, x + 2, y + 4);
    end;
    '7': begin
      Line(x, y, x + 2, y);
      Line(x + 2, y + 1, x, y + 4);
      Line(x, y + 2, x + 2, y + 2);
    end;
    '8': begin
       Rectangle(x, y, x + 2, y + 2);
       Rectangle(x, y + 2, x + 2, y + 4);
//       PutPixel(x + 1, y);
//       PutPixel(x, y + 1);
//       PutPixel(x + 2, y + 1);
//       PutPixel(x, y + 3);
//       PutPixel(x + 2, y + 3);
//       PutPixel(x + 1, y + 4);
//       PutPixel(x + 1, y + 2);
    end;
    '9': begin
      Rectangle(x, y, x + 2, y + 2);
      Line(x + 2, y + 3, x, y + 4);
    end;
    '0': begin
      PutPixel(x + 1, y);
      Line(x, y + 1, x, y + 3);
      Line(x + 2, y + 1, x + 2, y + 3);
      PutPixel(x + 1, y + 4);
      PutPixel(x + 1, y + 2);
    end;
    '.': begin
      PutPixel(x, y + 4);
    end;
    ',': begin
      PutPixel(x + 1, y + 3);
      PutPixel(x, y + 4);
    end;
    ';': begin
      PutPixel(x + 1, y + 1);
      PutPixel(x + 1, y + 3);
      PutPixel(x, y + 4);
    end;
    ':': begin
      PutPixel(x, y + 1);
      PutPixel(x, y + 3);
    end;
    '!': begin
      Line(x, y, x, y + 2);
      PutPixel(x, y + 4);
    end;
    '?': begin
      PutPixel(x + 1, y);
      PutPixel(x, y);
      PutPixel(x + 2, y + 1);
      PutPixel(x + 1, y + 2);
      PutPixel(x + 1, y + 4);
    end;
    '(': begin
      PutPixel(x + 1, y);
      Line(x, y + 1, x, y + 3);
      PutPixel(x + 1, y + 4);
    end;
    ')': begin
      PutPixel(x + 1, y);
      Line(x + 2, y + 1, x + 2, y + 3);
      PutPixel(x + 1, y + 4);
    end;
    '%': begin
      PutPixel(x, y);
      PutPixel(x + 2, y + 4);      
      Line(x + 2, y + 1, x, y + 3);
    end;
    '+': begin
      Line(x + 1, y, x + 1, y + 4);
      Line(x, y + 2, x + 2, y + 2);
    end;
    '-': begin
      Line(x, y + 2, x + 2, y + 2);
    end;
    '*': begin
      PutPixel(x, y);
      PutPixel(x + 2, y);
      Line(x, y + 2, x + 2, y + 2);
      PutPixel(x, y + 4);
      PutPixel(x + 2, y + 4);
      PutPixel(x + 1, y + 1);
      PutPixel(x + 1, y + 3);
    end;
    '/': begin
      Line(x + 2, y, x, y + 4);
    end;
    '=': begin
      Line(x, y + 1, x + 2, y + 1);
      Line(x, y + 3, x + 2, y + 3);
    end;
    '<': begin
      Line(x, y + 2, x + 2, y);
      Line(x, y + 2, x + 2, y + 4);
    end;
    '>': begin
      Line(x, y, x + 2, y + 2);
      Line(x, y + 4, x + 2, y + 2);
    end;
    '''': begin
      Line(x + 1, y, x + 1, y + 1);
    end;
    '"': begin
      Line(x, y, x, y + 1);
      Line(x + 2, y, x + 2, y + 1);
    end;
    '\': begin
      Line(x, y, x + 2, y + 4);
    end;
    '#': begin
      Line(x, y + 1, x + 2, y + 1);
      Line(x, y + 3, x + 2, y + 3);
      Line(x, y, x, y + 4);
      Line(x + 2, y, x + 2, y + 4);
    end;
  end;
end;

// Draw text
procedure SetText(str : string; x, y : byte);
var
  i : byte;
begin
  for i := 1 to Length(str) do begin   
    PutChar(str[i], x, y);

    if (str[i] = 'I') or (str[i] = '!') then
        Inc(x, 2)
    else        
        Inc(x, 4);
  end;
end;
