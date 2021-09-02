/*
 We have to create MMU with size>10kb and there are two modules in the software 
 1) Machine module only accessible in machine mode
 2) Supervisor module accessible in both machine & supervisor mode

Solution:

 Do PMP for machine module by appropriately setting(set X bit to 0)pmp0cfg and setting pmpaddr0 to start of software module
 and set pmpaddr1 to 0xffffffff and also allow R,W,X permission in pmp1cfg

 for creating MMU with size>10kb I am creating a superpage
 this is achieved by building only 2 level pagetable 

I request the evaluvator to first check paging and afterwards check PMP protection testcases by uncommenting the line for testcases and saving it

The above is just a brief idea of my solution for further details please follow the code , I tried to comment for every important step

How to run: All the steps to run gdb on terminal is same except in the second terminal while setting the address range we have to set it to 0x10010000:0x4f0000

more detailly , the command in the second terminal should be "$(which spike) --rbb-port=9824 -m0x10010000:0x4f0000 bootload.elf $(which pk)" without quotes.


 */


#define STACK_BASE_ADDR 0x10010900

machine_module:
  
   li sp, STACK_BASE_ADDR  #set sp
   la t0, mtrap_handler
   csrw mtvec, t0    #single entry exception handling 
   

   #settingup pmpaddr0
   la t1, supervisor_module
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
   # I will do identical pagemapping and only 2 level pagetable using sv39 mode
    
   #base address of page table is 2^21 byte alligned
   li t0, 0x10200000
   li t1, 0x4100001
   sd t1,0(t0)

   li t0, 0x10400400
   li t1,0x400004f
   sd t1,0(t0)

   #procedure to edit the prev priv mode
	li      t0, 0x1800
	csrrc   zero,mstatus, t0       # clear MPP[1:0] bits
	li      t0, 0x0800
	csrs    mstatus, t0          # set mpp (previous mode) with supervisor mode

   #setting the entry point in S mode
	la  t0, supervisor_module    # set up mepc with addr of S mode re-entry func. 
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

.p2align 2
supervisor_module:

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
    li t1,0x10200000
    srli t1,t1,12
    
    #setting PPNbits
    or t0,t0,t1

    #writing into satp
    csrw satp,t0

    #so paging is enabled now

   #sample instructions
   andi t0,t0,0
   addi t1,t0,1
   andi t0,t0,0
   addi t1,t0,4




   

