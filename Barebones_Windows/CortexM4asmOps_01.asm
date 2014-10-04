@;CortexM4asmOps_01.asm wmh 2013-02-25 : ARM instruction examples taken from NXP LPC17xx manual !!identify

@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
								@; Code written using UAL can be assembled 
								@; for ARM, Thumb-2, or pre-Thumb-2 Thumb
	.thumb						@; Use thmb instructions only


.include "STM32F4_P24v04_definitions02_prob3.asm"
	
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


	.global CortexM4asmOps_test1 	@; make this function visible everywhere
	.thumb_func						@; make sure it starts in thumb mode
CortexM4asmOps_test1: 	@; asm function which decrements Cint by 2, increments Gint by 2, and shifts Dint left by 2	
	@;subtract 2 from Cint
	.extern Cint		@; tell linker where to look for Cint
	ldr r0,=Cint		@; point to Cint		
	ldr r1,[r0]			@; and get its current value
	sub r1,r1,#2		@;	and subtract 2
	str r1,[r0]			@;    then put it back

	@;add 2 to Gint
	.extern Gint		@; tell linker where to look for Gint
	ldr r0,=Gint		@; point to Gint		
	ldr r1,[r0]			@; and get its current value
	add r1,r1,#2		@;	and add 2
	str r1,[r0]			@;    then put it back

	@;shift Dint left
	.extern Dint		@; tell linker where to look for Dint
	ldr r0,=Dint		@; point to Dint		
	ldr r1,[r0]			@; and get its current value shifted left by 2
	lsr r1,r1,#1		@;  shift it left 1 bits
	str r1,[r0]			@;    then put it back
	
	bx lr				@;return to the caller
	

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
 

	.global doJump
	.thumb_func
doJump:	@;jump to address stored in table
	ldr R1,=dothings
	lsl R0,R0,#2
	add R0,R0,R1
	orr R0,R0,#1
	bx  R0
	
dothings:
do0:	.word fn0
do1:	.word fn1
do2:	.word fn2
do3:	.word fn3

	.thumb_func
fn3: 
	nop
	bx LR
	.thumb_func
fn2: 
	nop
	bx LR
	.thumb_func
fn1: 
	nop
	bx LR
	.thumb_func
fn0:
	nop
	bx LR
	
	
@;/**********CODE FOR HW 7************/

@;******Port Initializations*******
	.global init_var		@;Initialize Cathode, Anode, and Switch pins
	.thumb_func
init_var:
	.set GPIOA_BASE, 0x40020000
	.set GPIOB_BASE, 0x40020400
	.set GPIOC_BASE, 0x40020800
	.set GPIOD_BASE, 0x40020C00
	.set RCC_AHB1ENR, 0x40023830
	.set STD_OUTPIN, 0
	.set PULLUP_INPIN, 2
	
	SET_bit RCC_AHB1ENR,0					@;enable clock for GPIOA
	SET_bit RCC_AHB1ENR,1					@;		""		   GPIOB
	SET_bit RCC_AHB1ENR,2					@;      ""         GPIOC
	SET_bit RCC_AHB1ENR,3					@;      ""         GPIOD
	
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,11	@;	PC11 AN_CLK			STD_OUTPIN == 01, load 01 into PC4 location i.e. make it an output pin
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,4	@;	PB4	 AN_EN	
	PORTBIT_init STD_OUTPIN,GPIOD_BASE,2	@;	PD2	 CA_CLK
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,1	@;	PC1	 CA_EN	
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,5	@;	PC5	 CA_A/LED5-COLON/SW_11-12
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,1	@;	PB1	 CA_B/LED6-DIGIT4/SW_7-8
	PORTBIT_init STD_OUTPIN,GPIOA_BASE,1	@;	PA1	 CA_C/LED1-DIGIT2/SW_13
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,5	@;	PB5	 CA_D-/SW_1-2
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,11	@;	PB11 CA_E-AN_R/SW_3-4
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,2	@;	PC2	 CA_F/LED4-DIGIT1
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,4	@;	PC4	 CA_G/LED2-DIGIT3/SW_9-10
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,0	@;	PB0	 CA_DP/LED3-AN_G/SW_5-6
bx LR

@;*****Switch Initialization*****
	.global switch_init			
	.thumb_func
switch_init:
	SET_bit RCC_AHB1ENR,0					@;enable clock for GPIOA
	SET_bit RCC_AHB1ENR,2					@;      ""         GPIOC
	@;***Switch initializing****		
	PORTBIT_init PULLUP_INPIN,GPIOA_BASE,15	@;	PA15 SW_1-3-5-7-9-11-13/ROT_ENC B
	PORTBIT_init PULLUP_INPIN,GPIOC_BASE,8	@;	PC8	 SW_2-4-6-8-10-12/ROT_ENC A
	@;PORTBIT_init PULLUP_INPIN,GPIOC_BASE,12	@;	PC12	ROTENC_A DONT NEED
	@;PORTBIT_init PULLUP_INPIN,GPIOB_BASE,5	@;	PB5	ROTENC_B
	
	@;set initial output values - Set all switches to 1 (0 == ON)
@;	PORTBIT_write GPIOB_BASE,5,1 	@;SW_1-2
@;	PORTBIT_write GPIOB_BASE,11,1 	@;SW_3-4
@;	PORTBIT_write GPIOB_BASE,0,1 	@;SW_5-6
@;	PORTBIT_write GPIOB_BASE,1,1 	@;SW_7-8
@;	PORTBIT_write GPIOC_BASE,4,1 	@;SW_9-10
@;	PORTBIT_write GPIOC_BASE,5,1 	@;SW_11-12

@;	PORTBIT_write GPIOD_BASE, 2, 0	@;Pulse CA_CLK since writing to ports
@;	PORTBIT_write GPIOD_BASE, 2, 1
@;	PORTBIT_write GPIOC_BASE, 1,1	@;	PC1	 CA_EN
	
bx LR

@;/------anode dispatch------/
	.global displayEnab		@;void displayEnab(int pos); //put pattern on anodes to enable display "pos"
	.thumb_func
displayEnab:
	and r0,#0x03							@;restrict argument to first 4 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,displayEnab_dispatch_table		@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2
displayEnab_dispatch_table:	@;
	.word enab11 		
	.word enab21		
	.word enab31		
	.word enab41 		
	.thumb_func
enab11: ANODE_write 1,1,1,1,1,1,1,0		@;Turn on DIGIT 1
	bx lr
	.thumb_func
enab21: ANODE_write 1,1,1,1,1,1,0,1			@;Turn on DIGIT 2
	bx lr
	.thumb_func
enab31: ANODE_write 1,1,1,1,0,1,1,1			@;Turn on DIGIT 3
	bx lr
	.thumb_func
enab41: ANODE_write 1,1,1,0,1,1,1,1			@;Turn on DIGIT 4
	bx lr

@;*****END*****

.ltorg		@;Create literal pool here

@;Cathode Dispatch
	.global printHEX		@;void printHEX(int val);	//put pattern to display 'val' 0-F on cathode latch
	.thumb_func
printHEX:
	nop										@;attempt to break the table alignment provided by .align (below)
	and r0,#0x0F							@;restrict argument to first 16 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,printHEX_dispatch_table			@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
printHEX_dispatch_table:
	.word write0 @;destination address must be a .thumb_func
	.word write1 @;""
	.word write2 @;""
	.word write3 @;""
	.word write4 @;""
	.word write5 @;""
	.word write6 @;""
	.word write7 @;""
	.word write8 @;""
	.word write9 @;""
	.word writeNEGATIVE @;""
	.word writeBLANK @;""
	.word writeC @;""
	.word writeD @;""
	.word writeE @;""
	.word writeF @;""
	@;functions to populate table above and write various cathode patterns
	.global write0,write1,write2,write3,write4,write5,write6,write7,write8,write9,writeNEGATIVE,writeBLANK,writeC,writeD,writeE,writeF
	.thumb_func
write0: CATHODE_write 0,0,0,0,0,0,1,1
	bx lr
	.thumb_func
write1: CATHODE_write 1,0,0,1,1,1,1,1
	bx lr
	.thumb_func	
write2: CATHODE_write 0,0,1,0,0,1,0,1
	bx lr
	.thumb_func
write3: CATHODE_write 0,0,0,0,1,1,0,1
	bx lr
	.thumb_func
write4: CATHODE_write 1,0,0,1,1,0,0,1
	bx lr
	.thumb_func
write5: CATHODE_write 0,1,0,0,1,0,0,1
	bx lr
	.thumb_func
write6: CATHODE_write 0,1,0,0,0,0,0,1
	bx lr
	.thumb_func
write7: CATHODE_write 0,0,0,1,1,0,1,1
	bx lr
	.thumb_func
write8: CATHODE_write 0,0,0,0,0,0,0,1
	bx lr
	.thumb_func
write9: CATHODE_write 0,0,0,0,1,0,0,1
	bx lr
	.thumb_func
writeNEGATIVE: CATHODE_write 1,1,1,1,1,1,0,1			@;Displays the negative sign: CATHODE_write 0,0,0,1,0,0,0,1
	bx lr
	.thumb_func
writeBLANK: CATHODE_write 1,1,1,1,1,1,1,1					@;Displays Nothing!: 1,1,0,0,0,0,0,1
	bx lr
	.thumb_func
writeC: CATHODE_write 1,1,1,0,0,1,0,1
	bx lr
	.thumb_func
writeD: CATHODE_write 1,0,0,0,0,1,0,1
	bx lr
	.thumb_func
writeE: CATHODE_write 0,1,1,0,0,0,0,1
	bx lr
	.thumb_func
writeF: CATHODE_write 0,1,1,1,0,0,0,1
	bx lr
@;------- end of 'printHEX()'------------



@;Look-Up Table for PORTBIT write
	.global SET_CAt		@;void SET_CAt(int index);	//put pattern to display 'val' 0-F on cathode latch
	.thumb_func
SET_CAt:
	nop										@;attempt to break the table alignment provided by .align (below)
	and r3,#0x07							@;restrict argument to first 7 table entries
	lsl r3,2								@; and convert to table offset
	adr r2,SET_CAt_dispatch_table			@;	get table origin	
	ldr PC,[r2,r3]							@;	  and dispatch selected function from table
	.align 2								@;
SET_CAt_dispatch_table:
	.word write_a @;destination address must be a .thumb_func
	.word write_b @;""
	.word write_c @;""
	.word write_d @;""
	.word write_e @;""
	.word write_f @;""
	.word write_g @;""
	.word write_h @;""
	@;functions to populate table above and write various cathode patterns
	.global write_a,write_b,write_c,write_d,write_e,write_f,write_g,write_h
	.thumb_func
write_a: PORTBIT_write GPIOC_BASE, 5, 0 
	bx lr
	.thumb_func
write_b: PORTBIT_write GPIOB_BASE, 1, 0
	bx lr
	.thumb_func	
write_c: PORTBIT_write GPIOA_BASE, 1, 0
	bx lr
	.thumb_func
write_d: PORTBIT_write GPIOB_BASE, 5, 0
	bx lr
	.thumb_func
write_e: PORTBIT_write GPIOB_BASE, 11, 0
	bx lr
	.thumb_func
write_f: PORTBIT_write GPIOC_BASE, 2, 0
	bx lr
	.thumb_func
write_g: PORTBIT_write GPIOC_BASE, 4, 0
	bx lr
	.thumb_func
write_h: PORTBIT_write GPIOB_BASE, 0, 0
	bx lr
@;------- end of 'SET_CAt()'------------

@;/------anode Look-UP------/
	.global SET_ANt		@;void displayEnab(int pos); //put pattern on anodes to enable display "pos"
	.thumb_func
SET_ANt:
	and r3,#0x07							@;restrict argument to first 8 table entries
	lsl r3,2								@; and convert to table offset
	adr r2,SET_ANt_dispatch_table		@;	get table origin	
	ldr PC,[r2,r3]							@;	  and dispatch selected function from table
	.align 2
SET_ANt_dispatch_table:	@;
	.word enab4 		
	.word enab3 		
	.word enab_dummy	@;!! Used to read the colon 12:34. I could change anode pattern to fix this
	.word enab2 		
	.word enab1
	.word enab_dummy
	.word enab_dummy
	.word enab_dummy
	.thumb_func
enab_dummy:
	bx lr
	.thumb_func
enab4: PORTBIT_write GPIOB_BASE, 1, 0	@;Turn on DIGIT 4
	bx lr
	.thumb_func
enab3: 	PORTBIT_write GPIOC_BASE, 4, 0 	@;Turn on DIGIT 3
	bx lr
	.thumb_func
enab2: 	PORTBIT_write GPIOA_BASE, 1, 0	@;Turn on DIGIT 2
	bx lr
	.thumb_func
enab1: PORTBIT_write GPIOC_BASE, 2, 0	@;Turn on DIGIT 1
	bx lr

@;*****END*****


	.global DISPLAY_on		@;void DISPLAY_on(void);	//Enable anode, cathode outputs
	.thumb_func
DISPLAY_on:
	PORTBIT_write 0x40020400,4,0	@;PB4 - AN_EN
	PORTBIT_write 0x40020800,1,0	@;PC1 - CA_EN
bx lr
	
	.global DISPLAY_off		@;void DISPLAY_off(void);	//Disable anode, cathode outputs
	.thumb_func											@;Always turn display off before writing to cathode latch
DISPLAY_off:
	PORTBIT_write 0x40020400,4,1	@;PB4 - AN_EN
	PORTBIT_write 0x40020800,1,1	@;PC1 - CA_EN
bx lr
	
	
@;Problem 1A;
@; int get_sw(void);	//returns next event from switch queue or NULL if queue is empty
	@;where event = [event time : action (press/release) : switch number ]
	@;bits 31:8 -- time since startup in msecs;
	@;bit 7 -- 1=press, 0=release (debounced);
	@;bits 6:0 -- switch numbers 1-13 
	
@;NOTES:
	@;1. Assume global variable that is tracking the ms time since startup - must know location
	@;2. Assume global variable for the switch number, i.e. switch que - must know location
	@;3. Use the macros in order to get the returned switch value for event[7]


@;/****Track the amount of msec that have passed****/
	.global get_sw
	.thumb_func
get_sw:
	.extern msTicks		@;Tell compiler where to find global varible
	ldr r0, =msTicks	@;Get address of msTicks
	ldr r0, [r0]
	lsl r0, #8
	.extern sw_event
	ldr r1, =sw_event	@;Get address of sw_event
	str r0, [r1]		@;Store cur time into top 3 bytes of event (0xTTTTTTAS , Time, Action, Switch)
	
						@;Once we get the switch number and action, then OR that with the Time and then store it again
	.extern sw_num		@;sw_num == which switch to test
	ldr r0, =sw_num
	ldr r0, [r0]		@;000 0001 == sw 1; 100 0001 == sw13
						
	.extern saved_LR	@;Save the current LR into saved_LR
	ldr r3, =saved_LR	@;Get address of saved_LR
	str r14, [r3]		@;Store LR into saved LR
	
	@;bl getSWITCH		@;Returned value in R0: 1 = OFF; 0 = ON
	lsl r2, r0, #7		@;Shift Action into sw_event[7] put into r2
	ldr r0, = sw_num
	ldr r0, [r0]		@;Load switch again into r0
	orr r0, r0, r2		@;Append sw_event[7] and sw_event[6:0]
	ldr r1, =sw_event
	ldr r2, [r1] 		@;Load sw_event[]
	orr r0, r0, r2		@;Append the Time, Action, and Switch
	str r0, [r1]		@;Store switch event back	
	
	ldr r1, =saved_LR	@;Restore the LR
	ldr r1, [r1]
	mov r14, r1			
bx LR

.ltorg		@;Create literal pool here
@;/****Problem 1b: Rotary encoder****/

	.global RE_reset	@;void RE_reset();		
	.thumb_func
RE_reset:
	.extern RE_val
	ldr r1, =RE_val
	mov r2, #0			@;set RE_val back to 0
	str r2, [r1]
bx LR
.ltorg
@;When A goes from low to high transition, check B for high(++ Clockwise) or low(-- CCW)
	.global RE_position		@;int RE_position();
	.thumb_func				@;returns signed value of #phase steps left (negative) or right (positive) from reset
RE_position:		
	SWITCH_read GPIOC_BASE, 2, GPIOC_BASE, 8		@;Set PC2 = 0, then test PC8
	.extern prev_A
	ldr r1, =prev_A			@;Load address of prev_A into r1, R1 is not used in PORTBIT_read
	@;if(R0 == 0 && R1 ==1) check B
	cbz r0, 1f				@;branch to 1 forward if r0 == 0
	b exit
	1:
		ldr r2, [r1]		@;r2 = prev_A
		cmp r2, #0			@;if prev_A == 0; then exit
		IT eq
		beq exit		
		str r0, [r1]		@;!!prev_A = cur_A  Repeated code
		SWITCH_read GPIOC_BASE, 2, GPIOA_BASE, 15		@;Set PC2 = 0, then test PA15		
		cbz r0, 2f			@;if(cur_B ==0)
		mov r0, #1			@;return 1
		bx LR
	2:
		mov r0, #-1			@;return 2
		bx LR
	exit:
	str r0, [r1]			@;prev_A = cur_A
	mov r0, #0				@;return 0
	bx LR
	
	.global put_neg
	.thumb_func
put_neg:
	CATHODE_write 1,1,1,1,1,1,0,1
bx LR	


@;display: outputs 8 anode/cathode patterns to display latches at 1 kHZ refresh rate. Runs in SysTick.
@;void display_this(char * displaybuf);//inform system of display pattern location
@;where displaybuf format: { {cathodes},{anodes} } (separate subarrays of cathodes, anodes)

@;Problem 1C

	.global display_this		@;Must say CATHODE_write 1,1,1,1,1,1,1,1 before calling display this. I only set the values to 0 not 1
	.thumb_func					@;Must say ANODE_write 1,1,1,1,1,1,1,1  "  "
display_this:
	.extern disp_index
	ldr r2, =disp_index			@;Index addr. in R2
	ldr r3, [r2]			@;Index val. in R3 - initially 0
	ldr r4, =flag
	ldr r5, [r4]
	cbz r5, 1f				@;Save LR on first pass through
	adds r3, r3, #1			@;index++
	str r3, [r2]
	cmp r3, #8				@;changed from 9 to 8
	IT ge
	bge 2f					@;branch if index >=9
	ldrb r1, [r0, r3]		@;R0 holds the address of the array to display, load byte into r1
	cbz r1, CA_on			@;If byte is 0 == ON, branch to portbit write
	b display_this			@;branch back
1:
	ldr r1, =saved_LR
	str r14, [r1]
	add r5,r5,#1
	str r5, [r4]
	b display_this
CA_on:
	bl SET_CAt @;SET_CA ind1=r3
	b display_this
2:
	cmp r3, #8					
	IT eq						
	beq 3f						
	b AN_check
3:
	PORTBIT_write 0x40020C00, 2, 0	@;If index == 8; Pulse cathode
	PORTBIT_write 0x40020C00, 2, 1  @;Set ANodes to 1
	ANODE_write 1,1,1,1,1,1,1,1
	b AN_check
AN_check:
	cmp r3, #16			@;Changed from 17 to 16				
	IT eq
	beq exit1
	ldrb r1, [r0, r3]
	cbz r1, AN_on
	b display_this

AN_on:
	sub r3, r3, #11
	bl SET_ANt @;SET_AN =disp_index
	b display_this
exit1:
	PORTBIT_write 0x40020800, 11, 0		@;PC11 - AN_CLK
	PORTBIT_write 0x40020800, 11, 1		@;Pulse clock
	ldr r1, =saved_LR
	ldr r1, [r1]
	mov r14, r1
bx LR

	.global setONES
	.thumb_func
setONES:
	ANODE_write 1,1,1,1,1,1,1,1			@;Set all anodes off
	CATHODE_WRITE 1,1,1,1,1,1,1,1		@;Set all cathodes off -I included because I had extra lights flickering
bx LR

	.global doit
	.thumb_func
doit:
	mov r1, #0
	b 1f
1:	
	ldrb r2, [r0, r1]
	add r1, r1, #1
	b 1b					@;branch to local label 1 in backwards direction
bx LR

	.global pulse
	.thumb_func
pulse:
	@;PORTBIT_write 0x40020C00, 2, 0		@;Pulse CA_CLK since writing to ports
	@;PORTBIT_write 0x40020C00, 2, 1
	PORTBIT_write 0x40020800, 11, 0		@;PC11 - AN_CLK
	PORTBIT_write 0x40020800, 11, 1		@;Pulse clock
bx LR
	
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
	 