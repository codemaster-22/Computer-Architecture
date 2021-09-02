/*
 We have to prepare MMU with support for 3 level page table with following restrictions

1) The M mode code excluding the trap handler part is read, write and execute protected

solution: I will use pmpcnfg0 register and fill the pmpaddr0 to the label trap_handler and make R,W,X permission to 0 and use TOR
so that the machine mode code till the trap_handler is R,W,X protected and trap_handler part is not protected

2) one supervisor page should have dummyprocess(infinite loop) and other page should have supervisor trap_handler which demonstrates the pagemiss for first page access

solution: I will do the identical page mapping only for page containing supervisor trap_handler and I will not enter PTE for the supervisior page containing dummyprocess
thus I will get Instruction pagefault exception and for this to be handled only by supervisor trap_handler I have to do trapdelegation for this reason I will set medeleg to 0xffff

howto run: we have to follow the usual steps to set gdb for debugging.

I request the evaluvator to first check paging and afterwards check PMP protection testcases by uncommenting the line for testcases and saving it

The above description is very brief for more details follow the code I tried to explain each important statement in the code through comments 

*/

#define STACK_BASE_ADDR 0x10010900

#machinemode_code
_start:
 
   li sp, STACK_BASE_ADDR  #set sp
   la t0, mtrap_handler
   csrw mtvec, t0    #single entry exception handling 
   
   #setting medleg to 0xffff
   andi t0,t0,0
   li t0,0xffff
   csrs medeleg,t0

   #settingup pmpaddr0
   la t1, mtrap_handler
   srli t1,t1,2      #important point to note
   csrw pmpaddr0,t1

   #settingup pmpaddr1
   li t0,0xffffffffffffffff
   srli t0,t0,2
   csrw pmpaddr1,t0

   #8 BITS OF A PMP ENTRY
   # L ! ! A X W R	
   #by default 1f is pmpcfg0 1f == 0001 1111
   #setting up pmpcfg0 such that pmp0cfg  == 00001000
   
   li t0,0x17  #0x17 == 0001 0111
   csrc pmpcfg0,t0 #now pmp0cfg becomes 0000 1000 which means it has TOR and R,W,X protected
   csrr t0,pmpcfg0
   li t1,0xf00
   or t0,t1,t0
   csrw pmpcfg0,t0 #now pmp0cfg becomes 0000 1111 0000 1000
   
   
   #fill page table entries 
   # I will not do translation for 0x10010000 
   # I will do correct translation for 0x10011000 this page contain strap_handler

   
   li t0,0x10020000
   li t1, 0x4008401
   sd t1,0(t0)

   li t0, 0x10021400
   li t1, 0x4008801
   sd t1,0(t0)
   
   li t0,0x10022088
   li t1,0x400444f
   sd t1,0(t0)
   
   #procedure to edit the prev priv mode
	li      t0, 0x1800
	csrrc   zero,mstatus, t0       # clear MPP[1:0] bits
	li      t0, 0x0800
	csrs    mstatus, t0          # set mpp (previous mode) with supervisor mode

   #setting the entry point in S mode
	la  t0, smode_begin        # set up mepc with addr of S mode re-entry func. 
	csrw    mepc, t0             # writing s_mode_begin into mepc
	mret                         #exiting M mode

   .p2align 2
   _dataM :
    .word 0x1
    .word 0x2

# machine mode trap_handler
.p2align 2
mtrap_handler: 
   csrr t0,mcause
   mret


#supervisormode code starts here
smode_begin:
    #set stvec to strap_handler
    la t0,strap_handler
    csrw stvec,t0  # single entry exception handling scheme

    #set the satp register
    #I will set mode to be 8 and ASID to 0 and PPN is root page table address right shift 12
  
    #setting mode bit to 8 and ASID to 0  
    andi t0,t0,0
    addi t0,t0,8
    slli t0,t0,60
 
    #testcase for checking PMP Read protection
    #la t0,_dataM
    #lw t1,0(t0)    
 
    #testcase for checking PMP write protection
    #andi t1,t1,0
    #la t0,_dataM
    #sw t1,0(t0)

    #testcase for checking PMP execute protection
    #j _dataM

    #root pte adddress
    li t1,0x10020000
    srli t1,t1,12
    
    #setting PPNbits
    or t0,t0,t1

    #writing into satp
    csrw satp,t0

    #so paging is enabled now

 #infinite loop (dummy process)
label_1:
    andi t0,t0,0
    j label_1

.p2align 12      #address starting from 0x10011000
strap_handler:
   csrr t0,scause   #check the value of scause in t0

   #sample instructions
   andi t0,t0,0
   addi t1,t0,1
   andi t0,t0,0
   addi t1,t0,4

   sret

   

   




















