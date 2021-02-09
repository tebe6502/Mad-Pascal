unit sio;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Serial Input/Ouput interface library.
* @version: 1.0.0

* @description:
* Set of useful constants, and structures to work with ATARI OS SIO procedures. 
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface

type DCB_struct = record 
(*
* @description: 
* Device Control Block structure definition
*)
    DDEVIC  :byte; // Device Id
    DUNIT   :byte; // Unit number
    DCMND   :byte; // Command
    DSTATS  :byte; // Transfer direction on Input. Status on Output
    DBUFA   :word; // Buffer address
    DTIMLO  :byte; // Timeout in seconds
    DUNUSE  :byte; // Unused
    DBYT    :word; // Data length
    DAUX1   :byte; // Auxiliary bytes
    DAUX2   :byte;
end;

const 
    _R = $40; // Read - predefined values for data transfer direction (to be set in DSTATS)
    _W = $80; // Write
    _RW = $C0; // Read and Write
    _NO = $00; // No data transfer
    JSIOINT = $E459; // SIO OS procedure vector

var 
    DCB: DCB_struct absolute $300; // Device Control Block variable
    PACTL: byte absolute $D302; // Port A Control Register
    PBCTL: byte absolute $D303; // Port A Control Register
    VPRCED:   word absolute $0202; // Peripheral Proceed IRQ vector
    VINTER:   word absolute $0204; // Peripheral interrupt IRQ vector
    sioStatus: byte absolute $303; // contains last SIO operation result, returned in DSTATS register. 1 is returned if operation was sucessfull, otherwise contains error code  

    sioResult: byte; (* @var contains last SIO operation result, returned in Y register. 1 is returned if operation was sucessfull, otherwise contains error code *)

procedure ExecSIO; assembler;
(*
* @description:
* Executes SIO operation defined by DCB block. 
* On exit it returns status of operation in sioResult and/or sioStatus.
* 1 is returned if operation was sucessfull, otherwise variable contains error code.
*)

implementation

procedure ExecSIO; assembler;
asm {
        m@call jsioint  ;jsr JSIOINT  
        sty sioResult 
    };
end;

end.
