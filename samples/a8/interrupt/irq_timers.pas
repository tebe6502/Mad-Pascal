uses crt;

var old_irq: pointer;


procedure irq; assembler; interrupt;
asm

cn lda #$0f
 sta colbak

 eor #$0f
 sta cn+1

 pla

end;


begin

 GetIntVec(iTIM2, old_irq);

 SetIntVec(iTIM2, @irq, 0, 28);


 writeln('Press any key to exit');

 repeat until keypressed;

 SetIntVec(iTIM2, old_irq);

end.