uses crt, neo6502, neo6502uext;
const 
    BLINK_PIN = 4; // pin we connect the diode to (cathode). anode goes to GND.
    
var
    state : boolean;

begin
    NeoUExtInitialize;
    NeoSetDirection(BLINK_PIN,GPIO_PINMODE_OUTPUT);
    state := true;
    repeat
        if state then NeoWriteGPIO(BLINK_PIN,GPIO_HIGH) 
            else NeoWriteGPIO(BLINK_PIN,GPIO_LOW);
        Writeln(state); 
        state := not state; // swap state
        Delay(100); // wait one sec
    until Keypressed;
end.
