@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
								@; Code written using UAL can be assembled 
								@; for ARM, Thumb-2, or pre-Thumb-2 Thumb
	.thumb						@; Use thumb instructions only


.include "STM32F4_P24v04_definitions.asm"
	
@; --- begin RAM allocation for variables								

	.data						@; start the _initialized_ RAM data section
@; global? initialized? variables
	
	.align 4
	.global Dint
Dint: 	.word  0xFFFFFFFF   	@; these won't actually be initialized unless we do it ourselves 
Dshort:	.hword 0xABCD       	@; this won't be global unless we make it so
Dchar: 	.byte  0x55   		    @;       
  
	.bss						@;start the uninitialized RAM data section				 
@; global uninitialized variables 
	.align	4					@;pad memory if necessary to align on word boundary for word storage 
local_bss_begin:				@;marker for start of locally defined (this sourcefile) .bss variables
	.comm	Garray,256			@;allocate 256 bytes of static storage for uninitialized global storage
	.comm	Gint,4				@;allocate word of static storage (4 bytes) for an uninitialized global int variable
	.comm	Gshort,2			@;allocate half-word of static storage (2 bytes) for an uninitialized global short int variable 
	.comm	Gchar,1				@;allocate byte of static storage (1 bytes) for an uninitialized global unsigned char variable 
@; local uninitialized variables
	.align	4					@;pad memory if necessary to align on word boundary for word storage 
	.lcomm	Larray,256			@;allocate 256 bytes of storage for an uninitialized local array
	.lcomm	Lint,4				@;allocate word of static storage (4 bytes) for an uninitialized local int variable
	.lcomm	Lshort,2			@;allocate half-word of static storage (2 bytes) for an uninitialized local short int variable 
	.lcomm	Lchar,1				@;allocate byte of static storage (1 bytes) for an uninitialized local unsigned char variable 
	.align 4					@;so end-marker is on a word boundary
local_bss_end:					@;marker for end of locally defined (this sourcefile) .bss variables

@; --- constant definitions (symbol macros -- these do not use storage)
	.equ const,0x12345678
	.equ struc,0x12345670	

	@; fancy macro example
.macro bitbandload reg addr bit
1:	ldr     \reg, = ( ((\addr) & 0xF0000000) | 0x02000000 | (((\addr) & 0x000FFFFF) << 5) | ((\bit) << 2) ) 
	b 1b						@; 'b 1b' : branch to local label '1' in the 'b'ackward direction 
								@; ('1f' would be 'f'oward) 
.endm	

	
@; --- begin code memory
	.text						@;start the code section

	.global testmacro
	.thumb_func
testmacro:
	bitbandload r0 0x00010000 21
	bitbandload r1 0x00010000 22
	bitbandload r2 0x00010000 23	
	bx lr
	
	.global CortexM4asmOps_init @; make this function visible everywhere
	.thumb_func					@; make sure it starts in thumb mode
CortexM4asmOps_init: @; initialize variables defined in this sourcefile
	@; initialize globals in .data
	ldr r0,=0xFFFFFFFF			@; initialize 'Dint'
	ldr r1,=Dint
	str r0,[r1]
	movw r0,#0xABCD				@;  initialize 'Dshort'
	ldr r1,=Dshort
	strh r0,[r1]
	mov r0,#0x55				@;  initialize 'Dchar'
	ldr r1,=Dchar
	strb r0,[r1]
	@; initialize .bss
	ldr r1,=local_bss_begin		
	ldr r3,=local_bss_end
	subs r3, r3, r1			@; length of uninitialized local .bss data section
	beq 2f					@; Skip if none
	mov r2, #0				@; value to initialize .bss with
1: 	@;!!local label which I can 'b 1b' branch backward to. Oooo, delicious. 
	strb r2, [r1],#1		@; Store zero
	subs r3, r3, #1			@; Decrement counter
	bgt 1b					@; Repeat until done
2:  @;!!local label which I can 'b 1f' branch forward to. 
	BX LR

	.global asmLDR_examples @;
	.thumb_func				@;specify that the function (defined below) uses thumb opcodes
asmLDR_examples:			@;examples using different LDR addressing and decoration 

	@;your code goes here

	bx lr					@; return to the caller

	.global asmSTR_examples @;
	.thumb_func				@;specify that the function (defined below) uses thumb opcodes
asmSTR_examples:			@;examples using different LDR addressing and decoration 

	@;your code goes here

	bx lr					@; return to the caller

	
.equ GPIOD_BASE,0x40020C00
	.global turnOnLED
	.thumb_func
turnOnLED:
	PORTBIT_write GPIOD_BASE, 15, 1
bx lr


	.global turnOffLED
	.thumb_func
turnOffLED:
	PORTBIT_write GPIOD_BASE, 15, 0
bx lr



	.global asmDelay 			@; make this function visible everywhere
	.thumb_func					@; make sure it starts in thumb mode
asmDelay:						@; short software delay
	MOVW    R3, #0xFFFF			@; r3=0x0000FFFF
	MOVT    R3, #0x0000			@; ..
delay_loop:						@; repeat here
	CBZ     R3, delay_exit		@; r3 == 0?
	SUB     R3, R3, #1			@; 	no --
	B       delay_loop			@;	  continue 
delay_exit:						@;  yes --
	BX      LR					@;    return to caller
 

 
 
 
 
 
@; --- end of code/beginning of ROM data 
@;	.rodata						@; start of read-only data section
@; code memory area containing test data for testing 'load' instructions
@; We are putting this in ROM as so it doesn't have to be initialized before using it. 
@; In real applications it can be anywere in the address space. 
	.global	ROMdata				@; global label of test target data area
	.align						@; pad memory if necessary to align on word boundary for word storage 
ROMdata:						@; start of test data area	
	.byte 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F	@;16 bytes with contents = offset from start
	.byte 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F	@;""
	.byte 0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F	@;""
	.byte 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F	@;""
	.byte 0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F	@;""
	.byte 0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F	@;""
	.byte 0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F	@;""
	.byte 0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F	@;""
	.byte 0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F	@;""
	.byte 0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9A,0x9B,0x9C,0x9D,0x9E,0x9F	@;""
	.byte 0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF	@;""
	.byte 0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF	@;""
	.byte 0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF	@;""
	.byte 0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF	@;""
	.byte 0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF	@;""
	.byte 0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF	@;""
	 