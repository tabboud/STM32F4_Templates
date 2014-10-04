
@;Remains the same
.macro SET_bit addr, bit		@;Set bit to 1 of [addr](which is given by addr)
	ldr r2, =\addr				@;Move address value into r2: 0x40023830
	ldr r1, [r2]				@;Load the value of addr into r1
	orr r1, r1, #1<<\bit		@;Set the bit by shifting a 1 to the position
	str r1, [r2]				@;Store back value
.endm


@;STD_OUTPIN 	 ==	0
@;STD_INPIN 	 ==	1
@;PULLUP_INPIN 	 == 2
.macro PORTBIT_init val, base, pin		
	ldr r2, =\base						@;Load in the GPIOx_BASE
	ldr r1, [r2]						@;Load contents of base into R1
	bic r1, r1, #3<<(\pin<<1)			@;MODER:  Clear specified bits 
	str r1, [r2]			
	.ifeq \val-0						@;If val is zero run this portion == STD_OUTPIN
		ldr r1, [r2]					@;MODER (32):
		orr r1, r1, #1<<(\pin<<1)		@;Set to 0x01 == Output mode
		str r1, [r2]
		ldr r1, [r2, #4]				@;OTYPER: (16)	
		bic r1, r1, #1<<\pin			@;set pin to 0 == output push-pull(reset state)
		str r1, [r2, #4]				@;end otyper
		ldr r1, [r2, #8]				@;OSPEEDR: (32) (set to 2Mhz == x0) I leave them as 00 since you would have to set the 1 for 10
		bic r1, r1, #3<<(\pin<<1)		@;clear bits
		str r1, [r2, #8]				@;end OSPEEDR
		ldr r1, [r2, #12]				@;PUPDR: (32)
		bic r1, r1, #3<<(\pin<<1)
		str r1, [r2, #12]
		ldr r1, [r2, #12]
		orr r1, r1, #1<<(\pin<<1)		@;set to 01 == Pull up
		str r1, [r2, #12]				@;end PUPDR 
	.else
		ldr r1, [r2, #8]				@;OSPEEDR   (Dont do the OTYPER for input)
		bic r1, r1, #3<<(\pin<<1)		@;In the LED_init(), the OSPEEDR is set to 50Mhz, which corresponds to setting OSPEEDR to 0x3, but following the code it sets it to 0x2, which is not 50Mhz it is 2Mhz
		str r1, [r2, #8]				@;Set to 00 == 2Mhz //Can also set to 10
		ldr r1, [r2, #12]				@;PUPDR
		bic r1, r1, #3<<(\pin<<1)
		str r1, [r2, #12]				@;Store value for PUPDR; This is all thats done for STD_INPIN
		.ifeq \val-2					@;Run this if \val-2 = 0; PULLUP_INPIN
			ldr r1, [r2, #12]
			orr r1, r1, #1<<(\pin<<1)
			str r1, [r2, #12]		
		.endif
	.endif
.endm


.macro PORTBIT_write base, pin, val
	ldr r2, =\base			@;Load in the GPIOx_BASE address
	.if (\val == 1)
		mov r1, #1<<\pin	@;Set pin
	.else	
		mov r1, #1<<(\pin +16)	@;Reset pin
	.endif	
	str r1, [r2, #24]		@;Store into the BSRR
.endm


.macro PORTBIT_read base, pin
	ldr r2, =\base
	ldr r0, [r2, #16]		@;Get GPIOx->IDR
	ands r0, r0, #1<<\pin	@;Get just the pin value
	mov r0, r0, lsr #\pin	@;Move pin value 0 or 1 into R0 to return
.endm


@;GPIOA = 0x40020000
@;GPIOB = 0x40020400
@;GPIOC = 0x40020800
@;GPIOD = 0x40020C00

.macro CATHODE_write a,b,c,d,e,f,g,dp
	movw	r2, #0x800
	movt	r2, #0x4002					@;GPIOC	== PC5: CA_A
	.ifeq \a-0							
		mov.w r1, #0x200000				
	.else
		mov.w r1, #0x20					
	.endif
	str r1, [r2, #24]					@;Store into BSRR
	movw	r2, #0x400
	movt	r2, #0x4002					@;PB1: CA_B
	.ifeq \b-0							
		mov.w r1, #0x20000				
	.else
		mov.w r1, #0x2					
	.endif
	str r1, [r2, #24]
	movw	r2, #0x0	
	movt	r2, #0x4002					@;PA1: CA_C
	.ifeq \c-0							
		mov.w r1, #0x20000				@;Reset
	.else
		mov.w r1, #0x2					@;Set
	.endif
	str r1, [r2, #24]
	movw	r2, #0x400	
	movt	r2, #0x4002					@;PB5: CA_D
	.ifeq \d-0							
		mov.w r1, #0x200000				
	.else
		mov.w r1, #0x20
	.endif
	str r1, [r2, #24]
	movw	r2, #0x400	
	movt	r2, #0x4002					@;PB11: CA_E
	.ifeq \e-0							
		mov.w r1, #0x8000000				
	.else
		mov.w r1, #0x800
	.endif
	str r1, [r2, #24]
	movw	r2, #0x800	
	movt	r2, #0x4002					@;PC2: CA_F
	.ifeq \f-0							
		mov.w r1, #0x40000				
	.else
		mov.w r1, #0x4
	.endif
	str r1, [r2, #24]
	movw	r2, #0x800	
	movt	r2, #0x4002					@;PC4: CA_G
	.ifeq \g-0							
		mov.w r1, #0x100000				
	.else
		mov.w r1, #0x10
	.endif
	str r1, [r2, #24]
	movw	r2, #0x400	
	movt	r2, #0x4002					@;PB0: CA_DP
	.ifeq \dp-0							
		mov.w r1, #0x10000				
	.else
		mov.w r1, #0x1
	.endif
	str r1, [r2, #24]
	movw	r2, #0xC00	
	movt	r2, #0x4002					@;PD2: CA_CLK
	mov.w r1, #0x40000					@;Pulse to 0 to send bits to latch
	str r1, [r2, #24]				
	mov.w r1, #0x4						@;Set clock back to 1
	str r1, [r2, #24]
.endm

@;GPIOA = 0x40020000
@;GPIOB = 0x40020400
@;GPIOC = 0x40020800
@;GPIOD = 0x40020C00
@;Changed the Port pins/values
.macro ANODE_write a,b,c,d,e,h,f,g
	PORTBIT_write 0x40020800, 5, \h		@;PC5  - Colon
	PORTBIT_write 0x40020800, 2, \g		@;PC2  - DIGIT1
	PORTBIT_write 0x40020000, 1, \f		@;PA1  - DIGIT2
	PORTBIT_write 0x40020800, 4, \e		@;PC4  - DIGIT3
	PORTBIT_write 0x40020400, 1, \d		@;PB1  - DIGIT4
	PORTBIT_write 0x40020400, 0, \c		@;PB0  - AN_G
	PORTBIT_write 0x40020400, 11,\b		@;PB11 - AN_R
	PORTBIT_write 0x40020400, 5, \a		@;PB5  - CA_D-
	
	PORTBIT_write 0x40020800, 11, 0		@;PC11 - AN_CLK
	PORTBIT_write 0x40020800, 11, 1		@;Pulse clock
.endm


.macro SWITCH_read base1, pin1, base2, pin2
	ANODE_write 1,1,1,1,1,1,1,1			@;Set all anodes off
	CATHODE_WRITE 1,1,1,1,1,1,1,1		@;Set all cathodes off -I included because I had extra lights flickering
	PORTBIT_write \base1, \pin1, 0		@;Set STD_OUTPINS to 0, in order to test
	PORTBIT_write 0x40020C00, 2, 0		@;Pulse CA_CLK since writing to ports
	PORTBIT_write 0x40020C00, 2, 1
	PORTBIT_read \base2, \pin2			@;Read from PULLUP_INPIN to see if on
	PORTBIT_write \base1, \pin1, 1		@;Set STD_OUTPIN back to 1
	PORTBIT_write 0x40020C00, 2, 0		@;Pulse CA_CLK since writing to ports
	PORTBIT_write 0x40020C00, 2, 1
.endm





