
#Problem Description: We have to handle the system calls from user mode in Supervisor mode using ecall Instruction

#Solution Description:
#Program starts in machine mode I will set mepc to begin of S mode code and set the MPP bits to 01 and go to S mode by calling mret
#In S mode I will set the sepc point to begin of U mode code and set SPP bit to 0 and go to U mode by calling sret
#In U mode I will do ecall and come to S mode in S mode trap_handler I will write some load access fault in this strap_handler and go back to machine mode 
# As Mcause value for ecall from U mode is 8 so we have to set 8th bit of medeleg register to 1 and remaining all to 0 which means 0x100
/*
howto run: we have to follow the usual steps to set gdb for debugging and then step in and observe you can see that after pushing arguments into stack and then ecall the code first goes to strap_handler and from there it goes to corresponding function and at last to _exit 
*/

_start:
      
    #setting sp
     li sp,0x10012000

    #setting mtvec
     la t0,mtrap_handler    #remember mtrap_handler should be 4 byte alligned
     csrw mtvec,t0        # we are doing single entry exception handling

    #doing trap delegation for ecall from U mode

    #first clear all bits in medeleg register
    li t0,0xffffffff
    csrc medeleg,t0
    #now set only 8th bit to 1
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
    
    #In usermode we have to handle 3 function calls
    #lets assume a0 holds the name of function and let it be 1 for bite,2 for cite,3 for kite
    #a1 holds the number of arguments

    #calling bite
    li a0,1           # 1 means bite
    li a1,3           #number of arguments
    addi sp,sp,-24    #creating space for 3 arguments
    li t0,66
    sd t0,8(sp)
    li t0,95
    sd t0,16(sp)
    li t0,10
    sd t0,24(sp)
   .p2align 2
    ecall
    nop


    #calling cite
    li a0,2           # 2 means cite
    li a1,2           #number of arguments
    addi sp,sp,-16    #creating space for 2 arguments
    li t0,67
    sd t0,8(sp)
    li t0,23
    sd t0,16(sp)
    .p2align 2
    ecall
    nop


    #calling kite
    li a0,3           # 3 means kite
    li a1,14           #number of arguments
    addi sp,sp,-112    #creating space for 14 arguments
    li t0,35
    sd t0,8(sp)
    li t0,99
    sd t0,16(sp)
    li t0,12
    sd t0,24(sp)
    li t0,13
    sd t0,32(sp)
    li t0,0
    sd t0,40(sp)
    li t0,4
    sd t0,48(sp)
    li t0,5
    sd t0,56(sp)
    li t0,9
    sd t0,64(sp)
    li t0,12
    sd t0,72(sp)
    li t0,1
    sd t0,80(sp)
    li t0,2
    sd t0,88(sp)
    li t0,2
    sd t0,96(sp)
    li t0,3
    sd t0,104(sp)
    li t0,9
    sd t0,112(sp)
    .p2align 2
    ecall
    nop



.p2align 2
strap_handler:

  li t0,1
  beq a0,t0,bite 
 
  li t0,2
  beq a0,t0,cite

  j kite
    
 bite:
   #here we can add code of the function bite and arguments are obtained using stack
   #as question specifies that it just returns to calling function so Iam writing nothing in the body of function
   addi sp,sp,24   # popping of the three arguments from stack
   j _exit
 cite:
   #here we can add code of the function cite and arguments are obtained using stack
   #as question specifies that it just returns to calling function so Iam writing nothing in the body of function
   addi sp,sp,16  # popping of the two arguments from stack
   j _exit

 kite:
   #here we can add code of the function kite and arguments are obtained using stack
   #as question specifies that it just returns to calling function so Iam writing nothing in the body of function
   addi sp,sp,112  # popping of the 14 arguments from stack
   j _exit

#exiting the smode 
_exit:
    csrr t0,sepc
    addi t0,t0,4
    csrw sepc,t0   # increment sepc by 4
    sret           # goes back to usermode

.p2align 2
mtrap_handler:

    csrr t2,mcause
    
    #So basically we came to M mode back again
    
    mret

    
    


    
    

 
   
     
