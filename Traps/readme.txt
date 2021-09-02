
For debugging the programs following commands has to be run in gdb

(gdb) target remote localhost:3333

(gdb) load ./Traps.elf

(gdb) c
  
The program completely executes and I have set an ebreak in source code it stops there

I have stored the mepc & mcause values in stack
Traps I have handled in order are:
1) store access fault
2) load access fault
3) store address misalligned
4) load address misalligned
5) Instruction access fault

So they will be Stored in reverse order and with mepc value bottom and mcause value above it for each trap
these values can be checked in gdb as follows:
first get the value of sp
and then find the content of address present in sp using command x   address
increment it by 8 to find the next element of stack

the debugging I have done in gdb is shown below for reference:

(gdb) info reg sp     # find the value of sp
sp             0x0000000010010fb0       268505008  

(gdb) x 268505008     # finding the memory of 0(sp) which contains mepc value stored when instruction access fault has occurred
0x10010fb0:     0xfffffffc
(gdb) x 268505016     # finding memory of 8(sp) which contains mcause value stored when instruction access fault has occurred
0x10010fb8:     0x00000001      # mcause value is 1 

(gdb) x 268505024     # finding memory of 16(sp) which contains mepc value stored when load address misalligned has occurred
0x10010fc0:     0x10010028
(gdb) x 268505032     # finding memory of 24(sp) which contains mcause value stored when load address misalligned has occurred
0x10010fc8:     0x00000004      # mcause value is 4

(gdb) x 268505040     # finding memory of 32(sp) which contains mepc value stored when store address misalligned has occurred 
0x10010fd0:     0x10010024
(gdb) x 268505048     # finding memory of 40(sp) which contains mcause value stored when store address misalligned has occurred
0x10010fd8:     0x00000006      # mcause value is 6

(gdb) x 268505056     # finding memory of 48(sp) which contains mepc value stored when load access fault has occurred
0x10010fe0:     0x1001001e
(gdb) x 268505064     # finding memory of 56(sp) which contains mcause value stored when load access fault has occurred
0x10010fe8:     0x00000005      # mcause value is 5

(gdb) x 268505072     # finding memory of 64(sp) which contains mepc value stored when store access fault has occurred
0x10010ff0:     0x1001001a
(gdb) x 268505080     # finding memory of 72(sp) which contains mcause value stored when store access fault has occurred
0x10010ff8:     0x00000007     # mcause value is 7

