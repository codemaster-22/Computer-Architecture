
#Problem Description: Switch from M mode to S mode to U mode and then from U mode to S mode to M mode

#Solution Description:
#Program starts in machine mode I will set mepc to begin of S mode code and set the MPP bits to 01 and go to S mode by calling mret
#In S mode I will set the sepc point to begin of U mode code and set SPP bit to 0 and go to U mode by calling sret
#In U mode I will do ecall and come to S mode in S mode trap_handler I will write some load access fault in this strap_handler and go back to machine mode 
#Note that we have to do trap_delegation for ecall to be directed to S mode from U mode instead to M mode from U mode
# As Mcause value for ecall from U mode is 8 so we have to set 8th bit of medeleg register to 1 and remaining all to 0 which means 0x100
/*
howto run: we have to follow the usual steps to set gdb for debugging and check priv mode by using command info reg priv
 
*/


_start:
      
    #setting sp
     li sp,0x10012000

    #setting mtvec
     la t0,mtrap_handler    #remember mtrap_handler should be 4 byte alligned
     csrw mtvec,t0        # we are doing single entry exception handling

    #doing trap delegation for ecall from U mode
    li t0,0x100
    csrs medeleg,t0  # sets 8th bit because 0x100 == 100000000

    #Clear MPP bits in mstatus register   
    li t0,0x1800
    csrc mstatus,t0
 
    #set 11th bit in mstatus
    li t0,0x800
    csrs mstatus,t0 

    #set mepc point to smode_begin
    la t0,smode_begin
    csrw mepc,t0
    
    #exiting mmode
    mret

#Supervisor mode code starts here

smode_begin:
    
    #setting stvec
    la t0,strap_handler  #remember strap_handler should be 4 byte alligned
    csrw stvec,t0      # we are doing single entry exception handling

    #setting SPP bit in sstaus register to 0 which is 8th bit
    li t0,0x100
    csrc sstatus,t0

    #setting sepc point to umode_begin
    la t0,umode_begin
    csrw sepc,t0

    #exiting S mode
    sret

#User mode code starts here

umode_begin:

    #passing some random argument to ecall
    andi a0,a0,0
    addi a0,a0,8
    
    #doing ecall and it will take to higher privelge mode as we have set 8 th bit of medeleg to 1
    #so it will go to supervisormode
    ecall

.p2align 2
strap_handler:
    csrr t1,scause  #storing mcause value in t1 register
    
    #generating load access fault
    li t0,0x100
    lw t0,1(t1)     # not 4 byte alligned address as we are loading word address should be 4 byte alligned
    #so above will cause trap and we switch to m mode

    sret 

.p2align 2
mtrap_handler:

    csrr t2,mcause
    
    #So basically we came to M mode back again
    
    mret

    
    


    
    

 
   
     
