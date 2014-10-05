/*
Barebones Blinky example using arm-none-eabi
on Windows (w/ Makefile)
*/


#include <stdio.h>
#include <stdint.h>

#include "stm32f4xx.h"


volatile uint32_t msTicks;                      /* counts 1ms timeTicks       */
/*----------------------------------------------------------------------------
  SysTick_Handler
 *----------------------------------------------------------------------------*/
void SysTick_Handler(void) {
	msTicks++;
}

/*----------------------------------------------------------------------------
  delays number of Systicks (happens every 1 ms)
 *----------------------------------------------------------------------------*/
static void Delay(__IO uint32_t dlyTicks){                                              
  uint32_t curTicks = msTicks;
  while ((msTicks - curTicks) < dlyTicks);
}

void setSysTick(){
	// ---------- SysTick timer -------- //
	 /****************************************
     *SystemFrequency/1000      1ms         *
     *SystemFrequency/100000    10us        *
     *SystemFrequency/1000000   1us         *
     *****************************************/
	if (SysTick_Config(SystemCoreClock / 1000)) {
		while (1){};	// Capture error	
	}
}

void init_GPIO(){
	GPIO_InitTypeDef  GPIO_InitStructure;

	// GPIOD Periph clock enable
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	// Configure PD12 and PD15 in output pushpull mode
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12 | GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(GPIOD, &GPIO_InitStructure);
}

int main(void) {
	setSysTick();
	init_GPIO();

	while(1){
        GPIO_ToggleBits(GPIOD, GPIO_Pin_12 | GPIO_Pin_15);
        Delay(1000);		// Wait 1 sec.
	}
	return 0;
}

