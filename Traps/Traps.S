_start:	
	lui sp, 0x10011 
	la t0, trap_entry   # load temp register t0 with trap_entry
	csrw mtvec,t0       # write mtvec with t0 value. This will set mtvec to trap_entry
                            # As it is singly entry exceptional handling we need not set last two bits 0 explicitly
                            # because trap_entry is multiple of 4 so last two bits are 00 
        addi x17,x0,0
        addi  x15,x0,0      # x15 = 0
        addi x15,x15,-4     # x15 = -4
        sw x17, 0(x15)      # trying to access invalid memory address -4 and it is 4 byte alligned so it is store access fault       
        lw x17, 0(x15)      # trying to access invalid memory address -4 and it is 4 byte alligned so it is load access fault
        
        addi x15,x15,6      # x15 is 2 which is not multiple of 4
        sw   x17,0(x15)     # trying to access memory from address which is not multiple of 4 (meaning not 4 byte alligned) Store address misalligned
        lw   x17,0(x15)     # trying to access memory from address which is not multiple of 4 (meaning not 4 byte alligned) Load address misalligned
        
        addi x1,x0,-3      # x1 = -3
        jalr x0,0(x1)      # trying to jump to invalid address so it is instruction access fault
EBreak:
        ebreak
        j _start

trap_handler:
	csrr t1,mepc        
	sd t1,32*8(sp)     # storing mepc value in stack
	addi t1,t1,4 
	csrw mepc,t1       # changing mepc to mepc + 4  because we are sure that lw,sw is 4 byte alligned and to go to next instruction we have to increment by 4
	csrr t1,mcause     
	sd t1,33*8(sp)     # storing mcause value in stack
	ret

.p2align 2
trap_entry:     
	addi sp, sp, -34*8  # 34 is used because we save 32 registers and mcause,mepc values and pop of the 32 registers then from the stack
	 #x0 is always 0  so we need not write into it explicitly
	sd x1, 1*8(sp)
	sd x2, 2*8(sp)
	sd x3, 3*8(sp)
	sd x4, 4*8(sp)
	sd x5, 5*8(sp)
	sd x6, 6*8(sp)
	sd x7, 7*8(sp)
	sd x8, 8*8(sp)
	sd x9, 9*8(sp)
	sd x10, 10*8(sp)
	sd x11, 11*8(sp)
	sd x12, 12*8(sp)
	sd x13, 13*8(sp)
	sd x14, 14*8(sp)
	sd x15, 15*8(sp)
	sd x16, 16*8(sp)
	sd x17, 17*8(sp)
	sd x18, 18*8(sp)
	sd x19, 19*8(sp)
	sd x20, 20*8(sp)
	sd x21, 21*8(sp)
	sd x22, 22*8(sp)
	sd x23, 23*8(sp)
	sd x24, 24*8(sp)
	sd x25, 25*8(sp)
	sd x26, 26*8(sp)
	sd x27, 27*8(sp)
	sd x28, 28*8(sp)
	sd x29, 29*8(sp)
	sd x30, 30*8(sp)
	sd x31, 31*8(sp)

	jal trap_handler

	ld x1, 1*8(sp)
	ld x2, 2*8(sp)
	ld x3, 3*8(sp)
	ld x4, 4*8(sp)
	ld x5, 5*8(sp)
	ld x6, 6*8(sp)
	ld x7, 7*8(sp)
	ld x8, 8*8(sp)
	ld x9, 9*8(sp)
	ld x10, 10*8(sp)
	ld x11, 11*8(sp)
	ld x12, 12*8(sp)
	ld x13, 13*8(sp)
	ld x14, 14*8(sp)
	ld x15, 15*8(sp)
	ld x16, 16*8(sp)
	ld x17, 17*8(sp)
	ld x18, 18*8(sp)
	ld x19, 19*8(sp)
	ld x20, 20*8(sp)
	ld x21, 21*8(sp)
	ld x22, 22*8(sp)
	ld x23, 23*8(sp)
	ld x24, 24*8(sp)
	ld x25, 25*8(sp)
	ld x26, 26*8(sp)
	ld x27, 27*8(sp)
	ld x28, 28*8(sp)
	ld x29, 29*8(sp)
	ld x30, 30*8(sp)
	ld x31, 31*8(sp)

	addi sp, sp, 32*8   # popping of 32 registers
        # 0(sp) contains mepc and 8(sp) contains mcause value
        
        addi sp,sp,-16
        sd   t0,0(sp)
        sd   t1,8(sp)
        csrr t0,mcause
        addi t1,x0,1
        beq t0,t1,label_
        beq t0,x0,label_      
        ld  t0,0(sp)
        ld  t1,8(sp)
        addi sp,sp,16
        mret
    label_:    # when it is instruction access fault or instruction address misalligne I'm performing ebreak
        
        ld  t0,0(sp)
        ld  t1,8(sp)
        addi sp,sp,16
        j EBreak    






