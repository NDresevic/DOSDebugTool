# DOS Debug Tool
DOS debug tool intended to facilitate solving problems in DOS programs using TSR.
It has the following functionalities with listed commands.
- `domaci1.com -start` starts debug TSR program, giving following features
- Listing values of registers ax, bx, cx, dx, si, di and listing values on the stack (top-most 6).
The displayed values are constantly on the screen, where key `F5` shifts between the display of the values of the general
purpose registers and the stack display. The displayed values are also refreshed only when pressing the `F5` key.
- `domaci1.com -peek aabb ccdd` displays value (byte) located on given address in memory, [aabb:ccdd], in base 16 where 
aabb represents the segment and ccdd the offset
- `domaci1.com -poke byte aabb ccdd ee` change value (byte) located on given address in memory, [aabb:ccdd], in base 16 where 
aabb represents the segment and ccdd the offset, and ee is the new value written to the given address
- Shift the position of the displayed values on the screen by one character using keys: `F1` shift left, `F2` shift right, `F3` shift up
and `F4` shift down 
- Showing current time in format `HH:MM:SS`
- `domaci1.com -stop` stops TSR

> DOS as an operating system is not reentrant, so to solve this problem, special flags are set to indicate if there is 
an active system call. Testing these flags gives information whether or not it is safe to make the second 
system call. For better understanding take a look at http://www.plantation-productions.com/Webster/www.artofasm.com/DOS/ch18/CH18-3.html#HEADING3-4
