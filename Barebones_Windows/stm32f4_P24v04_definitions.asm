@;Macros tailored to the P24 expansion board


.macro SET_bit addr, bit		@;Set bit to 1 of [addr](which is given by addr)
	ldr r2, =\addr				@;Move address value into r2: 0x40023830
	ldr r1, [r2]				@;Load the value of addr into r1
	orr r1, r1, #1<<\bit		@;Set the bit by shifting a 1 to the position
	str r1, [r2]				@;Store back value
.endm

@;****Definitions for GPIO Port Initializations****
.equ MODER,0x00				@;__IO uint32_t MODER;    /*!< GPIO port mode register,              
.equ OTYPER,0x04			@;__IO uint32_t OTYPER;   /*!< GPIO port output type register,       
.equ OSPEEDR,0x08			@;__IO uint32_t OSPEEDR;  /*!< GPIO port output speed register,      
.equ PUPDR,0x0C				@;__IO uint32_t PUPDR;    /*!< GPIO port pull-up/pull-down register, 
.equ IDR,0x10				@;__IO uint32_t IDR;      /*!< GPIO port input data register,        
.equ ODR,0x14				@;__IO uint32_t ODR;      /*!< GPIO port output data register,       
.equ BSRRL,0x18				@;__IO uint16_t BSRRL;    /*!< GPIO port bit set/reset low register, 
.equ BSRRH,0x1A				@;__IO uint16_t BSRRH;    /*!< GPIO port bit set/reset high register,
.equ LCKR,0x1C				@;__IO uint32_t LCKR;     /*!< GPIO port configuration lock register,
.equ AFR1,0x20				@;__IO uint32_t AFR[2];   /*!< GPIO alternate function registers,    
.equ AFR2,0x24				@;__IO uint32_t AFR[2];   /*!< GPIO alternate function registers,    
@;STD_OUTPIN 	 ==	0
@;STD_INPIN 	 ==	1
@;PULLUP_INPIN 	 == 2
.macro PORTBIT_init mode, base, pin		
	.ifeq \mode-0						@;mode == STD_OUTPIN
		ldr r2, =\base					@;Load in the GPIOx_BASE
		ldr r1, [r2, #MODER]			@;Load contents of base into R1
		bic r1, r1, #3<<(\pin<<1)		@;Clear specified bits 
		str r1, [r2, #MODER]			@;GPIOx->MODER (32)
		ldr r1, [r2, #MODER]			@;
		orr r1, r1, #1<<(\pin<<1)		@;Set the mode == OUTPUT
		str r1, [r2, #MODER] 
	
		ldr r1, [r2, #OTYPER]			@;GPIOx->OTYPER: (16)	
		bic r1, r1, #1<<\pin			@;set pin to 0 == output Push-Pull(reset state)
		str r1, [r2, #OTYPER]			
		
		ldr r1, [r2, #OSPEEDR]			@;GPIOx->OSPEEDR: (32) 
		bic r1, r1, #3<<(\pin<<1)		@;clear bits
		str r1, [r2, #OSPEEDR]
		ldr r1, [r2, #OSPEEDR]			
		orr r1,(2 << (2*\pin))			@;Set speed to 50Mhz (fast speed)
		str r1, [r2, #OSPEEDR]
			
		ldr r1, [r2, #PUPDR]			@;GPIOx->PUPDR: (32)
		bic r1, r1, #3<<(\pin<<1)		@;Clear bits
		str r1, [r2, #PUPDR]
		ldr r1, [r2, #PUPDR]
		orr r1, r1, #1<<(\pin<<1)		@;set to 01 == Pull up
		str r1, [r2, #PUPDR]			@;end PUPDR 
		.else
			.ifeq \mode-1						@;mode == STD_INPIN
				ldr r2, =\base					@;Load in the GPIOx_BASE
				ldr r1, [r2, #MODER]			
				bic r1, r1, #3<<(\pin<<1)		@;Clear bits: Sets to Input
				str r1, [r2, #MODER]
				
				ldr r1, [r2, #OSPEEDR]			@;OSPEEDR   
				bic r1, r1, #3<<(\pin<<1)		
				str r1, [r2, #OSPEEDR]
				ldr r1, [r2, #OSPEEDR]			
				orr r1,(2 << (2*\pin))			@;Set speed to 50Mhz (fast speed)
				str r1, [r2, #OSPEEDR]				
				
				ldr r1, [r2, #PUPDR]			@;PUPDR
				bic r1, r1, #3<<(\pin<<1)		@;Clear: No Pull Up
				str r1, [r2, #PUPDR]			
				.else
					.ifeq \mode-2					@;mode == PULLUP_INPIN
						ldr r2, =\base				@;Load in the GPIOx_BASE
						ldr r1, [r2, #MODER]			
						bic r1, r1, #3<<(\pin<<1)	@;Clear bits: Sets to Input
						str r1, [r2, #MODER]
						
						ldr r1, [r2, #OSPEEDR]			@;OSPEEDR   
						bic r1, r1, #3<<(\pin<<1)		
						str r1, [r2, #OSPEEDR]
						ldr r1, [r2, #OSPEEDR]			
						orr r1,(2 << (2*\pin))			@;Set speed to 50Mhz (fast speed)
						str r1, [r2, #OSPEEDR]
						
						ldr r1, [r2, #PUPDR]
						bic r1, r1, #3<<(\pin<<1)	@;Clear bits: no pull-up
						str r1, [r2, #PUPDR]
						ldr r1, [r2, #PUPDR]
						orr r1, r1, #1<<(\pin<<1)	@;Set bits: Enable Pull-Up
						str r1, [r2, #PUPDR]		
					.endif
			.endif
	.endif
.endm


.macro PORTBIT_write base, pin, val
	ldr r2, =\base				@;Load in the GPIOx_BASE address
	.if (\val == 1)			
		mov r1, #1<<\pin		@;Write to lower 16 bits of BSSR to set the bit
	.else	
		mov r1, #1<<(\pin +16)	@;Write to upper 16 bits of BSSR to clear the bit
	.endif	
	str r1, [r2, #24]			@;Store into the BSRR
.endm


.macro PORTBIT_read base, pin
	ldr r2, =\base
	ldr r0, [r2, #IDR]		@;Get GPIOx->IDR
	ands r0, r0, #1<<\pin	@;Get just the pin value
	mov r0, r0, lsr #\pin	@;Move pin value 0 or 1 into R0 to return
.endm

@;*****Places a 0/1 pattern on P24 Display Cathodes*****
.macro CATHODE_write a,b,c,d,e,f,g,dp
	PORTBIT_write GPIOC_BASE,5,\a			@;	19_PC5	PC5/CA_A/LED5-COLON	
	PORTBIT_write GPIOB_BASE,1,\b			@;	21_PB1	PB1/CA_B/LED6-DIGIT4
	PORTBIT_write GPIOA_BASE,1,\c			@;	11_PA1	PA1/CA_C/LED1-DIGIT2 
	PORTBIT_write GPIOB_BASE,5,\d			@;	76_PB5	PB5/CA_D-            
	PORTBIT_write GPIOB_BASE,11,\e			@;	35_PB11	PB11/CA_E-AN_R        
	PORTBIT_write GPIOC_BASE,2,\f			@;	10_PC2	PC2/CA_F/LED4-DIGIT1 
	PORTBIT_write GPIOC_BASE,4,\g			@;	20_PC4	PC4/CA_G/LED2-DIGIT3 
	PORTBIT_write GPIOB_BASE,0,\dp			@;	22_PB0	PB0/CA_DP/LED3-AN_G  
	PORTBIT_write GPIOD_BASE,2,0			@;	84_PD2	PD2/CA_CLK	-- clock pattern into latch
	PORTBIT_write GPIOD_BASE,2,1			@;	84_PD2	PD2/CA_CLK      
.endm

@;*****Places 0/1 pattern on P24 display anodes
.macro ANODE_write a,R,G,D4,D3,P,D2,D1
	PORTBIT_write 0x40020800, 5, \P		@;PC5  - Colon
	PORTBIT_write 0x40020800, 2, \D1	@;PC2  - DIGIT1
	PORTBIT_write 0x40020000, 1, \D2	@;PA1  - DIGIT2
	PORTBIT_write 0x40020800, 4, \D3	@;PC4  - DIGIT3
	PORTBIT_write 0x40020400, 1, \D4	@;PB1  - DIGIT4
	PORTBIT_write 0x40020400, 0, \G		@;PB0  - AN_G
	PORTBIT_write 0x40020400, 11,\R		@;PB11 - AN_R
	PORTBIT_write 0x40020400, 5, \a		@;PB5  - CA_D-  Not used
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


/* reference -- anode and cathode port pin identifications for P24v04r16

*** outputs ***
19_PC5	PC5/CA_A/LED5-COLON
21_PB1	PB1/CA_B/LED6-DIGIT4
11_PA1	PA1/CA_C/LED1-DIGIT2
76_PB5	PB5/CA_D-
35_PB11	PB11/CA_E-AN_R
10_PC2	PC2/CA_F/LED4-DIGIT1
20_PC4	PC4/CA_G/LED2-DIGIT3
22_PB0	PB0/CA_DP/LED3-AN_G

84_PD2	PD2/CA_CLK
07_PC1	PC1/CA_EN

88_PC11	PC11/AN_CLK
75_PB4	PB4/AN_EN

*** inputs ***
90_PA15	PA15/SW_1-3-5-7-9-11-13-ROT_ENC-B
95_PC8	PC8/SW_2-4-6-8-10-12-ROT_ENC-A

*/


