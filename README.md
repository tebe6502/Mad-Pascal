# Mad-Pascal
<p>
http://mads.atari8.info/
<br>
https://atariage.com/forums/topic/240919-mad-pascal/
<br>
<br>
https://atariage.com/forums/topic/145386-wudsn-ide-the-free-integrated-atari-8-bit-development-plugin-for-eclipse/?do=findComment&comment=4340150
</p>
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
<p></p>
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
<li>ShortReal Q8.8, Real Q24.8 (fixed-point)
<li>Single 32-bit (IEEE-754) [Float]
</ul>

<li>One-dimensional and Two-dimensional arrays (with zero lower bound) of any primitive type. Arrays are treated as pointers to their origins (like in C) and can be passed to subroutines as parameters.
<li>Predefined type string [N] which is equivalent to array [0..N] of Char.
<li>Type aliases.
<li>Records.
<li>Objects.
<li>Separate program <a href=http://mads.atari8.info/library/doc/index.html>modules</a>.
<li>Recursion.
</ul>

# MadStrap
http://bocianu.atari.pl/blog/madstrap
<p>
Simple Atari Mad-Pascal common project bootstrap.
<br>
Source code at: https://gitlab.com/bocianu/madstrap
</p>
  
# BLIBS
http://bocianu.atari.pl/blog/blibs
<p>
Set of custom libraries for MadPascal.
<br>
Lastest documentation always at: https://bocianu.gitlab.io/blibs/
</p>

# pasdoc
https://bocianu.atari.pl/blog/pasdoc
<p>
Custom tool for generating documentation from pascal comments in units.
<br>
Source code at: https://gitlab.com/bocianu/pasdoc
</p>

# Some advice
https://github.com/ilmenit/CC65-Advanced-Optimizations

# Benchmarks
<table style="width:100%">
  <tr>
    <th></th>
    <th>cc65</th>
    <th>Mad Pascal</th>
    <th>Millfork</th>
  </tr>
  <tr>
    <td>Sieve (less is better)</td>
    <td>602</td>
    <td>607</td>
    <td>701</td>
  </tr>
  <tr>
    <td>YoshPlus (higher is better)</td>
    <td>41933</td>
    <td>41933</td>
    <td>41867</td>
  </tr>
  <tr>
    <td>Chessboard (higher is better)</td>
    <td>76</td>
    <td>81</td>
    <td>79</td>
  </tr>  
</table>

https://github.com/zbyti/a8-mad-pascal-bench-suite
