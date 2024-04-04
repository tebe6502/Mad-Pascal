unit x16_xist_utils;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: X16 XIST library for Mad-Pascal.
* @version: 0.1.0

* @description:
* Set of procedures to cover functionality provided by:    
*
* 
* https://github.com/DoctorJWW/Xist16
*  
*
*   
* It's work in progress, please report any bugs you find.   
*   
*)

uses x16

interface

const

// #define XIST_RESOLUTION_WIDTH  320
// #define XIST_RESOLUTION_HEIGHT 240

// #define BOOL unsigned char

// #define EVER    ;;

    XIST_RANDOM_TABLE_LENGTH = 256

// #define MAX_SIGNED_INT_CHARS 12

var
    xist_random_table array [0..XIST_RANDOM_TABLE_LENGTH-1] of byte = (
        10, 60, 245, 164, 132, 46, 253, 214, 16, 200, 79, 172, 57, 117, 27, 64, 230, 160, 35, 106,
        37, 191, 194, 52, 44, 24, 151, 227, 47, 212, 182, 195, 61, 218, 189, 211, 8, 162, 187, 21,
        124, 168, 70, 137, 76, 180, 247, 254, 206, 63, 139, 252, 4, 126, 179, 240, 207, 15, 38, 85,
        25, 183, 87, 157, 107, 19, 232, 6, 186, 102, 74, 121, 32, 77, 197, 242, 219, 131, 112, 125,
        114, 45, 91, 176, 205, 150, 193, 220, 72, 246, 171, 59, 143, 101, 177, 223, 118, 43, 82, 80,
        108, 142, 226, 17, 34, 134, 123, 228, 135, 116, 159, 122, 14, 78, 169, 233, 18, 109, 250, 65,
        103, 170, 222, 213, 36, 31, 146, 221, 167, 231, 2, 174, 216, 93, 161, 95, 188, 86, 165, 42,
        111, 54, 68, 199, 140, 149, 98, 203, 90, 75, 145, 155, 55, 50, 152, 156, 39, 147, 1, 136,
        113, 88, 92, 251, 243, 185, 184, 153, 26, 244, 67, 115, 234, 9, 255, 209, 133, 22, 73, 173,
        163, 249, 204, 0, 154, 235, 97, 198, 56, 49, 130, 119, 236, 127, 239, 158, 238, 99, 62, 210,
        66, 141, 33, 104, 148, 229, 13, 20, 40, 201, 225, 30, 178, 5, 217, 94, 23, 175, 166, 84,
        51, 48, 81, 58, 208, 224, 105, 190, 71, 29, 69, 241, 96, 192, 100, 28, 83, 129, 181, 120,
        202, 196, 110, 128, 12, 89, 248, 138, 215, 144, 237, 41, 3, 7, 53, 11
    );

    start, next: longword;
    xist_seed_a, xist_seed_b, xist_rand_min, xist_rand_max: byte;
    random_counter : byte = 0;

procedure xist_wait();
(*
* @description:
* 
*
* 
* 
*)

function xist_rand(): Byte;
(*
* @description:
* 
*
* 
* 
*)


implementation


procedure xist_wait();
begin
    asm
        jsr RDTIM
        sta start
    end;
    while (start = next) do
    begin
        asm
            jsr RDTIM
            sta next
        end;
    end;
end;

function xist_rand(): Byte;
var
  range, feedback: Byte;

begin
  range := xist_rand_max - xist_rand_min + 1;
  feedback := ((xist_seed_a shr 1) xor (xist_seed_a shr 2) xor (xist_seed_a shr 3) xor (xist_seed_a shr 4)) and 1;
  xist_seed_a := (xist_seed_a shr 1) or (feedback shl 7);
  xist_seed_a := xist_seed_a xor xist_random_table[xist_seed_b];
  
  Inc(random_counter);
  if (random_counter = 255) then
    Inc(xist_seed_b);

  Result := xist_rand_min + (xist_seed_a mod range);
end;