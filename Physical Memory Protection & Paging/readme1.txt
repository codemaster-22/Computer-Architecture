

/**

 We have to create MMU with size>10kb and there are two modules in the software 
 1) Machine module only accessible in machine mode
 2) Supervisor module accessible in both machine & supervisor mode

Solution:

 Do PMP for machine module by appropriately setting(set X bit to 0)pmp0cfg and setting pmpaddr0 to start of software module
 and set pmpaddr1 to 0xffffffff and also allow R,W,X permission in pmp1cfg

 for creating MMU with size>10kb I am creating a superpage
 this is achieved by building only 2 level pagetable 

 Base address of level1 Pagetable is 0x10200000
 Base address of level2 Pagetable corresponding is 0x10400000
 and coresponding caluculations are done and entries are filled appropriately

I request the evaluvator to first check paging and afterwards check PMP protection testcases by uncommenting the line for testcases and saving it

The above is just a brief idea of my solution for further details please follow the code , I tried to comment for every important step

How to run: All the steps to run gdb on terminal is same except in the second terminal while setting the address range we have to set it to 0x10010000:0x4f0000

more detailly , the command in the second terminal should be "$(which spike) --rbb-port=9824 -m0x10010000:0x4f0000 bootload.elf $(which pk)" without quotes.


 **/

