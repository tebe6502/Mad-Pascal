unit neo6502uext;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Neo6502 API library for UExt I/O Functions
* @version: 0.30.0

* @description:
* Set of procedures to cover Neo6502 UExt communication capabilities.
* More about Neo6502:
*
* <https://www.olimex.com/Products/Retro-Computers/Neo6502/open-source-hardware>
*
* <https://www.neo6502.com/>

*
* API documentation can be found here:
*
* <https://github.com/paulscottrobson/neo6502-firmware/wiki>

*
* It's work in progress, so please report any bugs you will find.
*
*)
interface
uses neo6502;

const

    GPIO_PINMODE_INPUT = 1;      // i/o directions
    GPIO_PINMODE_OUTPUT = 2;     //
    GPIO_PINMODE_ANALOGUE = 3;   //

    GPIO_HIGH = 1; // GPIO pin value for level HIGH
    GPIO_LOW = 0; // GPIO pin value for level LOW

    UART_PROTOCOL_8N1 = 0;

var
    I2C_dev: byte absolute N6502MSG_ADDRESS+4; // @nodoc
    I2C_reg: byte absolute N6502MSG_ADDRESS+5; // @nodoc
    I2C_val: byte absolute N6502MSG_ADDRESS+6; // @nodoc
    block_addr: word absolute N6502MSG_ADDRESS+5; // @nodoc
    block_len: word absolute N6502MSG_ADDRESS+7; // @nodoc
    uart_baudrate: cardinal absolute N6502MSG_ADDRESS+4; // @nodoc
    uart_protocol: byte absolute N6502MSG_ADDRESS+8; // @nodoc

procedure NeoUExtInitialize;
(*
* @description:
* Initialize the UExt I/O system. This resets the IO system to its default
* state, where all UEXT pins are I/O pins, inputs and enabled.
*)

procedure NeoWriteGPIO(pin,val:byte);
(*
* @description:
* This copies the value to the output latch for selected pin.
* This will only display on the output pin if it is enabled,
* and its direction is set to output.
*
* @param: pin (byte) - Neo6502 GPIO pin number (1-10)
* @param: val (byte) - value (0,1);
*
*)

function NeoReadGPIO(pin:byte):byte;
(*
* @description:
* If the pin is set to input, reads the level on pin on UEXT Params[0].
* If it is set to output this reads the output latch for UEXT port Params[0].
*
* @param: pin (byte) - Neo6502 GPIO pin number (1-10)
*
* @returns: (byte) - level on pin
*)

procedure NeoSetDirection(pin,dir:byte);
(*
* @description:
* Set the port direction for UEXT Port.
*
* @param: pin (byte) - Neo6502 GPIO pin number (1-10)
* @param: dir (byte) - port direction
*)

procedure NeoWriteI2C(dev,reg,val:byte);
(*
* @description:
* Write to I2C Device dev, Register reg, value val.
* Does not fail if device not present.
*
* @param: dev (byte) - device address
* @param: reg (byte) - register
* @param: val (byte) - value
*)

function NeoReadI2C(dev,reg:byte):byte;
(*
* @description:
* Read from I2C Device dev, Register reg.
* If the device is not present this will cause an error.
*
* @param: dev (byte) - device address
* @param: reg (byte) - register
*
* @returns: (byte) - value
*)

function NeoReadAnalog(pin:byte):integer;
(*
* @description:
* Read the analogue value on specified UEXT Pin. This has to be set to analogue type to work.
* Returns a value from 0..4095, which represents an input value of 0 to 3.3 volts.
*
* @param: pin (byte) - GPIO pin number (1-10)
*
* @returns: (byte) - value in range 0..4095
*)

function NeoCheckI2C(dev:byte):byte;
(*
* @description:
* Try to read from specified I2C Device.
* If tha data is present returns non-zero value.
*
* @param: dev (byte) - device address
*
* @returns: (byte) - non zero value for waiting data
*)

procedure NeoReadBlockI2C(dev:byte;addr,len:word);
(*
* @description:
* Try to read a block of memory from specified I2C Device.
*
* @param: dev (byte) - device address
* @param: addr (word) - target memory address
* @param: len (word) - data lenght
*)

procedure NeoWriteBlockI2C(dev:byte;addr,len:word);
(*
* @description:
* Try to write a block from memory to specified I2C Device.
*
* @param: dev (byte) - device address
* @param: addr (word) - source memory address
* @param: len (word) - data lenght
*)

procedure NeoReadBlockSPI(addr,len:word);
(*
* @description:
* Try to read a block of memory from SPI Device.
*
* @param: addr (word) - target memory address
* @param: len (word) - data lenght
*)

procedure NeoWriteBlockSPI(addr,len:word);
(*
* @description:
* Try to write a block from memory to SPI Device.
*
* @param: addr (word) - source memory address
* @param: len (word) - data lenght
*)

procedure NeoReadBlockUART(addr,len:word);
(*
* @description:
* Try to read a block of memory from the UART.
*
* @param: addr (word) - target memory address
* @param: len (word) - data lenght
*)

procedure NeoWriteBlockUART(addr,len:word);
(*
* @description:
* Try to write a block from memory to the UART.
*
* @param: addr (word) - source memory address
* @param: len (word) - data lenght
*)

procedure NeoSetupUART(baudrate:cardinal;protocol:byte);
(*
* @description:
* Set the Baud Rate and Serial Protocol for the UART interface.
* Currently only 8N1 is supported (0).
*
* @param: baudrate (cardinal) - baud rate
* @param: protocol (byte) - protocol number
*)

procedure NeoWriteByteUART(b:byte);
(*
* @description:
* Try to write a byte to the UART.
*
* @param: b (byte) - byte of data
*)

function NeoReadByteUART():byte;
(*
* @description:
* Try to read a byte from the UART.
*
* @returns: (byte) - byte of data
*)

function NeoCheckUART():byte;
(*
* @description:
* See if a byte is available in the UART input buffer.
*
* @returns: (byte) - non zero if data is available.
*)

implementation

procedure NeoUExtInitialize;
begin
    NeoSendMessage(10,1);
end;

procedure NeoWriteGPIO(pin,val:byte);
begin
    NeoMessage.params[0] := pin;
    NeoMessage.params[1] := val;
    NeoSendMessage(10,2);
end;

function NeoReadGPIO(pin:byte):byte;
begin
    NeoMessage.params[0] := pin;
    result := NeoSendMessage(10,3);
end;

procedure NeoSetDirection(pin,dir:byte);
begin
    NeoMessage.params[0] := pin;
    NeoMessage.params[1] := dir;
    NeoSendMessage(10,4);
end;

function NeoReadAnalog(pin:byte):integer;
begin
    NeoMessage.params[0] := pin;
    NeoSendMessage(10,7);
    result := wordParams[0];
end;

procedure NeoWriteI2C(dev,reg,val:byte);
begin
    I2C_dev := dev;
    I2C_reg := reg;
    I2C_val := val;
    NeoSendMessage(10,5);
end;

function NeoReadI2C(dev,reg:byte):byte;
begin
    I2C_dev := dev;
    I2C_reg := reg;
    result := NeoSendMessage(10,6);
end;

function NeoCheckI2C(dev:byte):byte;
begin
    I2C_dev := dev;
    result := NeoSendMessage(10,8);
end;

procedure NeoReadBlockI2C(dev:byte;addr,len:word);
begin
    I2C_dev := dev;
    block_addr := addr;
    block_len := len;
    NeoSendMessage(10,9);
end;

procedure NeoWriteBlockI2C(dev:byte;addr,len:word);
begin
    I2C_dev := dev;
    block_addr := addr;
    block_len := len;
    NeoSendMessage(10,10);
end;

procedure NeoReadBlockSPI(addr,len:word);
begin
    block_addr := addr;
    block_len := len;
    NeoSendMessage(10,11);
end;

procedure NeoWriteBlockSPI(addr,len:word);
begin
    block_addr := addr;
    block_len := len;
    NeoSendMessage(10,12);
end;

procedure NeoReadBlockUART(addr,len:word);
begin
    block_addr := addr;
    block_len := len;
    NeoSendMessage(10,13);
end;

procedure NeoWriteBlockUART(addr,len:word);
begin
    block_addr := addr;
    block_len := len;
    NeoSendMessage(10,14);
end;

procedure NeoSetupUART(baudrate:cardinal;protocol:byte);
begin
    uart_baudrate := baudrate;
    uart_protocol := protocol;
    NeoSendMessage(10,15);
end;

procedure NeoWriteByteUART(b:byte);
begin
    NeoMessage.params[0] := b;
    NeoSendMessage(10,16);
end;

function NeoReadByteUART():byte;
begin
    result := NeoSendMessage(10,17);
end;

function NeoCheckUART():byte;
begin
    result := NeoSendMessage(10,18);
end;

end.
