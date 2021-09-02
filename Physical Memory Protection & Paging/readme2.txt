/*
 We have to prepare MMU with support for 3 level page table with following restrictions

1) The M mode code excluding the trap handler part is read, write and execute protected

solution: I will use pmpcnfg0 register and fill the pmpaddr0 to the label trap_handler and make R,W,X permission to 0 and use TOR
so that the machine mode code till the trap_handler is R,W,X protected and trap_handler part is not protected

2) one supervisor page should have dummyprocess(infinite loop) and other page should have supervisor trap_handler which demonstrates the pagemiss for first page access

solution: I will do the identical page mapping only for page containing supervisor trap_handler and I will not enter PTE for the supervisior page containing dummyprocess
thus I will get Instruction pagefault exception and for this to be handled only by supervisor trap_handler I have to do trapdelegation for this reason I will set medeleg to 0xffff

Here I am doing page translations for the address from 0x10011000 to 0x10011fff and this contains supervisor trap_handler code and that infinite loop code is in range 0x10010000 to 0x10010fff , so 
after satp is enabled when we try to access instruction of this loop we will get a instruction page fault and we(pc) will go to supervisor traphandler and the page which contains this is properly translated so we don't get any further instruction page fault wile accessing instructions at supervisor trap handler   

howto run: we have to follow the usual steps to set gdb for debugging.
please make sure that start address of virtual address is 0x10010000.

I request the evaluvator to first check paging and afterwards check PMP protection testcases by uncommenting the line for testcases and saving it

The above description is very brief for more details follow the code I tried to explain each important statement in the code through comments 

*/

