
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

