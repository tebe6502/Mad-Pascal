# Mad-Pascal

[English Documentation](https://tebe6502.github.io/mad-pascal-en-mkdocs/) / [Polska Dokumentacja](https://tebe6502.github.io/mad-pascal-mkdocs/)

[Turbo Pascal](https://turbopascal.org/)

[Full Pascal Programming Crash Course - Basics to Advanced](https://youtu.be/6jRVhT_JotY)

## [Introduction](https://tebe6502.github.io/mad-pascal-en-mkdocs/introduction/)

**Mad-Pascal** (MP) is a 32-bit **Turbo Pascal** compiler for **Atari 8-Bit** and other **MOS 6502 CPU**-based computers. By design, it is compatible with the **Free Pascal Compiler** (FPC) (the `-MDelphi` switch should be active). This means the possibility of obtaining executable code for **Atari 8-bit**, **Windows**, and every other platform for which **FPC** exists. **Mad-Pascal** is not a port of **FPC**. It has been written based on **SUB-Pascal** (2009) and **XD-Pascal** (2010), the author of which is [Vasiliy Tereshkov](mailto:vtereshkov@mail.ru).

**MP** uses 64KB of primary memory. The class `TMemoryStream` provides access to extended memory. A program that works on **Atari 8-Bit** might have problems on **Windows** and other platforms if, for example, the pointers have not been initialized with the address of a variable. Writing via an uninitialized pointer results in an attempt to write to the address `0x0` and causes a memory protection fault.

The strengths of **MP** include the fast and convenient possibility of including inline assembly. A program using inline **ASM** only works on platforms with **MOS 6502 CPU**.

Variable allocation is static. There is no dynamic memory management. Parameters are passed to functions by value, variable, or constant.

The available features are:

* `If` `Case` `For To` `For In` `While` `Repeat` statements
* Compound statements
* `Label` `Goto` statements
* Arithmetic and boolean operators
* Procedures and functions with up to 8 parameters. The returned value of a function is assigned to a predefined `RESULT` variable
* Static local variables
* Primitive data types, all types except the `ShortReal` and `Real` types are compatible. Pointers are dereferenced as pointers to `Word`:
    * `Cardinal` `Word` `Byte` `Boolean`
    * `Integer` `SmallInt` `ShortInt`
    * `Char` `String` `PChar`
    * `Pointer` `File` `Text`
    * `ShortReal` `Real` [fixed-point](https://en.wikipedia.org/wiki/Fixed-point_arithmetic)
    * [`Float16`](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)
    * [`Single`](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) / Float
* One-dimensional and Two-dimensional arrays (with zero lower bound) of any primitive type. Arrays are treated as pointers to their origins (like in C) and can be passed to subroutines as parameters
* Predefined type `String` `[N]` which is equivalent to `array [0..N] of Char`
* `Type` aliases
* `Records`
* `Objects`
* Separate program modules (`PROGRAM`, `UNIT`, `LIBRARY`)
* Recursion

## Compile
	src\

	fpc -MDelphi -vh -O3 mp.pas

## Usage
[WUDSN and Mad-Pascal](https://forums.atariage.com/topic/348660-wudsn-mad-pascal-quick-hack-increasing-usability/)

[Mad-Pascal i Geany](http://bocianu.atari.pl/blog/madgeany)

### [Atari 8-Bit](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8)
    mp.exe filename.pas -ipath:<MadPascalPath>\lib
    mads.exe filename.a65 -x -i:<MadPascalPath>\base

BAT
```
    <MadPascalPath>\MP.exe %1 -ipath:<MadPascalPath>\lib -ipath:<MadPascalPath>\blibs

    if exist %~dp1%~n1.a65 (
	    mads.exe "%~dp1%~n1.a65" -x -i:<MadPascalPath>\base
	    if exist "%~dp1%~n1.obx" altirra "%~dp1%~n1.obx"
    )
```

### [Commodore 64](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/c64)
    mp.exe -t c64 filename.pas -ipath:<MadPascalPath>\lib
    mads.exe filename.a65 -x -i:<MadPascalPath>\base
    
### [Commodore Plus/4](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/c4plus)
    mp.exe -t c4p filename.pas -ipath:<MadPascalPath>\lib
    mads.exe filename.a65 -x -i:<MadPascalPath>\base

### [Neo6502](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/neo6502)
    mp.exe -t neo filename.pas -ipath:<MadPascalPath>\lib
    mads.exe filename.a65 -x -i:<MadPascalPath>\base

[Mad-Pascal for Neo6502](https://github.com/paulscottrobson/neo6502-firmware/wiki/Mad%E2%80%90Pascal-for-Neo6502)
    
### [RAW](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/raw)
    mp.exe -t raw filename.pas -ipath:<MadPascalPath>\lib
    mads.exe filename.a65 -x -i:<MadPascalPath>\base

---

## [Tools](tools.md)

## [Projects in Mad-Pascal](projects.md)

## [A8 Mad-Pascal Window Library](https://unfinishedbitness.info/pascal-library/)

This text-mode windowing library has window controls and modern gadgets (widgets). The gadgets allow you to build input forms that use buttons, radio buttons, input strings (with scrolled lengths and type restrictions), check boxes, progress bars, etc. This allows you to build applications with "modern" interfaces.

## [Mad-Pascal libraries](https://mads.atari8.info/library/doc/index.html)

---

## Compression / Decompression
* [LZJB](https://en.wikipedia.org/wiki/LZJB) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/lzjb.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/lzjb)
* [RDC](https://files.mpoli.fi/unpacked/software/dos/misc/mc314pc2.zip/examples/misc/rdc.c) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/rdc.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/rdc)
* [LZW](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch) -> [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/lzw)
* [LZH](https://en.wikipedia.org/wiki/LHA_(file_format)) -> [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/lzh)
* [LZRW1KH](https://sunsite.icm.edu.pl/delphi//d10free/tlzrw1.htm) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/lzrw1kh.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/lzrw1kh)

## Decompression
* [DEFLATE](https://github.com/pfusik/zlib6502) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/deflate.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/deflate)
* [APL](https://github.com/emmanuel-marty/apultra) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/aplib.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/apl)
* [LZ4](https://github.com/emmanuel-marty/lz4ultra) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/lz4.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/lz4)
* [PACKFIRE](https://github.com/tebe6502/Mad-Assembler/tree/master/examples/compression/packfire) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/packfire.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/packfire)
* [POWER PACKER](https://github.com/retrocoder68/PowerPacker) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/pp.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/pp)
* [SNAPPY](https://github.com/google/snappy/tree/main) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/snappy.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/snappy)
* [UPKR](https://github.com/pfusik/upkr6502) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/upk.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/upkr)
* [ZX0](https://github.com/einar-saukas/ZX0) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/zx0.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/zx0)
* [ZX2](https://github.com/dmsc/zx02) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/zx2.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/zx2)
* [ZX5](https://github.com/einar-saukas/ZX5) -> [unit](https://github.com/tebe6502/Mad-Pascal/blob/master/lib/zx5.pas), [sample](https://github.com/tebe6502/Mad-Pascal/tree/master/samples/a8/compression/zx5)

---

## Benchmarks

|                             |CC65 |Mad-Pascal|Millfork|
|:----------------------------|:----|:--------:|:------:|
|Sieve (less is better)       |602  |577       |579     |
|YoshPlus (higher is better)  |41933|41933     |41933   |
|Chessboard (higher is better)|76   |88        |82      |

[https://github.com/tebe6502/Mad-Pascal/blob/master/samples/benchmark.7z](https://github.com/tebe6502/Mad-Pascal/blob/master/samples/benchmark.7z)

### Floating Point

| iteration x 256             |Atari OS|FastChip|MP Single|MP Real|
|:----------------------------|:-------|:------:|:-------:|:-----:|
|add, sub, mul, div           | 232    | 118    | 64      | 99    |
|add, sub, mul, div, sin, cos | 5820   | 2915   | 3728    | 1231  |

* MP Single: IEEE754-32bit
* MP Real: Q24.8 Fixed Point

[https://github.com/tebe6502/Mad-Pascal/blob/master/samples/fp_benchmark.7z](https://github.com/tebe6502/Mad-Pascal/blob/master/samples/fp_benchmark.7z)

### Suite

![suite-animation](https://github.com/zbyti/a8-mad-pascal-bench-suite/raw/master/suite.gif)

[sources](https://github.com/zbyti/a8-mad-pascal-bench-suite)

## Links

* [HOME Page](http://mads.atari8.info/)
* [Mad-Pascal on Atari Age Forum](https://atariage.com/forums/topic/240919-mad-pascal/)
* [Games in Mad-Pascal](https://forums.atariage.com/topic/249968-games-in-mad-pascal/)
* [Mad-Pascal examples](https://forums.atariage.com/topic/243658-mad-pascal-examples/)
* [Mad-Pascal on Atari Area Forum](http://www.atari.org.pl/forum/viewtopic.php?id=13373)
* [Mad-Pascal Announcement for WUDSN](https://atariage.com/forums/topic/145386-wudsn-ide-the-free-integrated-atari-8-bit-development-plugin-for-eclipse/?do=findComment&comment=4340150)
* [Some advice](https://github.com/ilmenit/CC65-Advanced-Optimizations)
* [Programowanie w Mad-Pascal dla C+4](https://c64portal.pl/2021/02/22/programowanie-w-mad-pascal-dla-c4/)
* [Commodore Plus/4, Mad-Pascal i bitmapy](https://c64portal.pl/2021/04/10/commodore-plus-4-mad-pascal-i-bitmapy/)

## Pascal related

* [Awesome Pascal](https://github.com/Fr0sT-Brutal/awesome-pascal)
* [Demoscene samples](https://github.com/jdelauney/BZScene-Demoscene-samples)
* [Turbo Pascal vintage collection](https://github.com/torstenroeder/turbopascal)
* [Nero 5 Chess program](https://github.com/JulStrat/nero5)
* [KC Chess](https://github.com/JulStrat/kcchess)
* [FreePascal meets SDL](https://www.freepascal-meets-sdl.net/)

## YouTube

* [WUDSN IDE Tutorial](https://youtu.be/36MFqY55yR0?list=PLD57AEE018938BA5E)
* [Arcadia](https://youtu.be/cJXRhfvKeH4)
* [Flob](https://youtu.be/sH4mg0DtWTM)
* [ProHiBan (Sokoban)](https://youtu.be/4VDKaIR_moY)
* [The Hangmad](https://youtu.be/6nkBs1NJUPU)
* [gravity](https://youtu.be/xCwlX6QSn80)
* [Block Attack](https://youtu.be/2LqFITTgDPI)
* [Turbo Pascal "Sokoban"](https://youtu.be/bsQsEM3TYTA)
* [Tron +4. Mad-Pascal i C+4](https://youtu.be/a4Y2TYj1ymg)
* [Mad-Pascal Commodore Plus/4 plasma effect with TEDzakker demo music](https://youtu.be/Yg10zHR--14)
* [Dungeon Adventurer](https://youtu.be/7lLPm5MywPc)
* [Time Wizard](https://youtu.be/E12bu5whjpQ)

## Pascal compilers for the Atari XE/XL computer 

* [APX Atari Pascal](https://atariwiki.org/wiki/Wiki.jsp?page=APX%20Atari%20Pascal)
* [Kyan Pascal](https://atariwiki.org/wiki/Wiki.jsp?page=Kyan%20Pascal)
* [Draper Pascal](https://atariwiki.org/wiki/Wiki.jsp?page=Draper%20Pascal)
* [CLSN Pascal](https://atariwiki.org/wiki/attach/Pascal/CLSN_Pascal-Manual.pdf)
