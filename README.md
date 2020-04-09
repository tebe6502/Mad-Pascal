# Mad-Pascal http://mads.atari8.info/
<p>
<tt>Usage:</tt>
<br>
mp.exe filename.pas
<br>
mads.exe filename.a65 -x -i:base
</p>

<hr>

Mad-Pascal (MP) is a 32-bit Turbo Pascal compiler for Atari XE/XL. By design, it is compatible with the Free Pascal Compiler (FPC) (the -MDelphi switch should be active), which means the possibility of obtaining executable code for XE/XL, PC and every other platform for which FPC exists. MP is not a port of FPC; it has been written based on of SUB-Pascal (2009), XD-Pascal (2010), the author of which is Vasiliy Tereshkov (https://github.com/vtereshkov).
</p>

<p>
A program that works on Atari might have problems on PC if, for example, the pointers have not been initialized with the address of a variable and the program attempts to write to the address $0000 (memory protection fault). The strengths of MP include fast and convenient possibility of inclusion of inline assembly. A program using inline ASM does not work on platforms other than XE/XL. MP uses 64KB of primary memory; TMemoryStream provides usage of extended memory.
</p>
Variable allocation is static; there is no dynamic memory management. Parameters are passed to functions by value, variable or constant.
<p>
The available features are:
</p>
<ul>
<li>If, Case, For, While, Repeat statements.
<li>Compound statements.
<li>Label, Goto statements.
<li>Arithmetic and boolean operators.
<li>Procedures and functions with up to 8 parameters. Returned value of a function is assigned to a predefined RESULT variable.
<li>Static local variables.
<li>Primitive data types (all types except the ShortReal/Real type are compatible. Pointers are dereferenced as pointers to Word):
<ul>
<li>Cardinal, Word, Byte, Boolean
<li>Char, String, PChar
<li>Integer, SmallInt, ShortInt
<li>Pointer, File
<li>ShortReal, Real (fixed-point)
<li>Single (IEEE-754) [Float]
</ul>

<li>One-dimensional and Two-dimensional arrays (with zero lower bound) of any primitive type. Arrays are treated as pointers to their origins (like in C) and can be passed to subroutines as parameters.
<li>Predefined type string [N] which is equivalent to array [0..N] of Char.
<li>Type aliases.
<li>Records.
<li>Objects.
<li>Separate program modules.
<li>Recursion.
</ul>

# BLIBS http://bocianu.atari.pl/blog/blibs
<p>
Set of custom libraries for MadPascal.
<br>
Lastest documentation always at: https://bocianu.gitlab.io/blibs/
</p>

# PASDOC https://bocianu.atari.pl/blog/pasdoc
<p>
Custom tool for generating documentation from pascal comments in units.
<br>
Source code at: https://gitlab.com/bocianu/pasdoc
</p>
