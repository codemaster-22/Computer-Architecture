The program has to be checked by loading .elf file in gdb and then we have to do step in(si)

I have intialized t4 to 0 initially and in machine timer interupt handler I am incrementing t4 by 1

So info reg t4 gives number of timer interupts that are happened

I have chosen an appropriate delta value such that in timer interupt handler I am incrementing mtimecmp val by delta 
which makes mip bit 0 again and I am enabling mie bit of mstatus register again so that I can handle one more timer interupt(nested)

Remaining all parts of the program is straight forward

Intialize mtimecmp to 0xfffffff initially and set mtip bit 0
then initialize mtvec and make it vectored 
then set mtimecmp = mtime+delta
Enable MTIE bit of mie and MIE bit of mstatus
then wait in infinite loop for interupt 
and if interupt happens check mcause value it will be 7
I have already explained in starting para's what I am doing in interupt handler
