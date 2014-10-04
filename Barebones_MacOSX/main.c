/*
Barebones Blinky example MacOSX using arm-none-eabi and ST_Link

*/


#include <stdio.h>
#include <stdint.h>


#include "stm32f4xx_conf.h"
#include "stm32f4xx.h"

volatile uint32_t time_var1, time_var2;
// Private function prototypes
void Delay(volatile uint32_t nCount);
void initialize();
void setSysTick(){
	// ---------- SysTick timer -------- //
	 /****************************************
     *SystemFrequency/1000      1ms         *
     *SystemFrequency/100000    10us        *
     *SystemFrequency/1000000   1us         *
     *****************************************/
	if (SysTick_Config(SystemCoreClock / 1000)) {
		// Capture error
		while (1){};
	}
}

int main(void) {
	setSysTick();
	initialize();

	GPIO_SetBits(GPIOD, GPIO_Pin_15);

	while(1){
        GPIO_ToggleBits(GPIOD, GPIO_Pin_15);
        Delay(1000);
	}
	return 0;
}

void initialize() {
	GPIO_InitTypeDef  GPIO_InitStructure;

	// ---------- GPIO  for LEDS -------- //
	// GPIOD Periph clock enable
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	// Configure PD12, PD13, PD14 and PD15 in output pushpull mode
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(GPIOD, &GPIO_InitStructure);

}

void SysTick_Handler(void)
{
	if (time_var1) {
		time_var1--;
	}
	time_var2++;
}

/*
 * Delay a number of systick cycles (1ms)
 */
void Delay(volatile uint32_t nCount) {
	time_var1 = nCount;
	while(time_var1){};
}

