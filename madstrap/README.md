# MadStrap

Simple Atari Mad-Pascal common project bootstrap.

Designed to speed up project development startup, providing starting set of useful optional features:

- constants defined in separate file (const.inc)
- type definitions in separate file (types.inc)
- external resource loading (RMT, ASM, strings)
- external library path definition ([blibs](https://gitlab.com/bocianu/blibs) as default)
- custom user defined charset loading
- user defined display list in separate file (dlist.asm)
- custom vertical blank interrupt
- custom display list interrupt
- interrupt routines declared in separate file (interrupts.inc)

You just download, rename, and uncomment all features you might need in your project.
