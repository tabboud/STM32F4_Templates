/* linkBlinkySTM32F4_01.ld wmh 2013-02-03 : linker script adapted to STM32F4 */
/* LINKSimpleLPC1768_01.ld wmh 2011-11-10 linker script for NXP LPC1768 */
/* adapted from http://embeddedfreak.wordpress.com/2009/08/09/cortex-m3-blinky-in-assembly/  */
/* Simple linker script for Cortex-M3 */

/*
 * Define the supported output formats - elf32-littlearm is the
 *  default
 */
OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")


OUTPUT_ARCH(arm)				/* Define the target architecture */
ENTRY(Reset_Handler) 			/* Define the system entry point */
SECTIONS 						/* Define the memory layout for the board */
{
	.flash 0x08000000 :			/* to agree what STLINK shows us for the STM32F4 */
	{
		KEEP(*(.cs3.interrupt_vector));			/* collect .cs3.interrupt_vector section here */
		*(.text .text.*);						/* Collect the executable parts here */
		*(.rodata .rodata.*);					/* Collect the const variables here */				 
		__sidata = .;							/* end marker */
	}

 /* set areas for initialized and uninitialized data */
	.data_at_ram 0x20000000: AT (LOADADDR(.flash) + SIZEOF(.flash))
	{
		__sdata = .;
		*(.data .data.*);						/* initialized data here */
		__edata = .;							/* end marker */ 
		__sbss = .;
			*(.bss .bss.*);						/* global variables without initial value here  */
		__ebss = .;


	}

 /* Set __cs3_stack to point the end of RAM memory */
	__cs3_stack = 0x20000000 + (128 * 1024);		/* to agree with Keil simulator which has 0x20000000 - 0x20001FFF mapped as r/w */	
}

