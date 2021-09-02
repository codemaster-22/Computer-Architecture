#define mtime  0x200bff8
#define mtimecmp 0x2004000

_start:

    andi t4,t4,0                   #setting t4 to 0
  
    # setting mtip bit to 0 by keeping large value in mtimecmp

    li t6,mtimecmp  # t6 has mtimecmp reg location
    andi t3,t3,0
    addi t3,t3,-1 #reg t6 set to -1 
    sd t3, 0(t6) # just increment the mtimecmp

    lui sp, 0x10011                #setting sp


    la t1, vectoredtrap_entry      # loading address of vectoredtrap_entry in t1
    csrw mtvec,t1 		   # writing mtvec with t1 value(vectoredtrap_entry)
    li t1, 0x1  		   #setting lsb to 1
    csrs mtvec,t1 		   #enabling vector based interrupt

    # Initialization Done 
    # Setting delta Value

    lui t3, 0x50000
    addi t3, t3, 999               # t3 contains delta Value
    
    li t5,mtimecmp
    li t1,mtime
    ld t2,0(t1)                    # t2 contains content of mtime
    add t3,t2,t3                   # t3 = mtime + delta
    sd  t3,0(t5)                   # store mtime + delta in mtimecmp

    # Enable Interrupt MIE bit in mstatus and MTIE bit in mie
    
    li t0,0x8
    csrrs zero,mstatus,t0          #It enables MIE bit (3rd bit)in mstatus  (0 based Index)
    li t0,0x80
    csrrs zero,mie,t0              # It enables MTIE bit(7th bit)in mie

    
    loop : 
        j loop                     # Infinite Loop

.p2align 2
vectoredtrap_entry:     # vtrap_entry has a nop to make sure, handlers are 4 byte aligned 
j u_sw_int_handler
nop
j s_sw_int_handler
nop
j h_sw_int_handler
nop
j m_sw_int_handler
nop
j u_ti_int_handler
nop
j s_ti_int_handler
nop
j h_ti_int_handler
nop
j m_ti_int_handler    # mcause value corresponds to 7
nop                 
j u_ex_int_handler
nop
j s_ex_int_handler
nop
j h_exint_handler
nop
j m_ex_int_handler
nop




u_sw_int_handler:
j loop

s_sw_int_handler:
j loop

h_sw_int_handler:
j loop

m_sw_int_handler:
j loop

u_ti_int_handler:
j loop

s_ti_int_handler:
j loop

h_ti_int_handler:
j loop

m_ti_int_handler:
        
        addi t4,t4,1                   # register t4 stores how many times timer Interrupt had happened
        

	lui t3, 0x50000
        addi t3, t3, 999               # t3 contains delta Value
    
        li t5,mtimecmp
        li t1,mtime
        ld t2,0(t1)                    # t2 contains content of mtime
        add t3,t2,t3                   # t3 = mtime + delta
        sd  t3,0(t5)                   # store mtime + delta in mtimecmp
        li t0,0x8
        csrrs zero,mstatus,t0          # enabling mie bit in mstatus again so that we can generate one more timer Interupt
	j loop

u_ex_int_handler:
j loop

s_ex_int_handler:
j loop

h_exint_handler:
j loop

m_ex_int_handler:
j loop


      
    



 
