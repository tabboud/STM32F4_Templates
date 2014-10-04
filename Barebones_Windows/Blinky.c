/*----------------------------------------------------------------------------
 * Name:    Blinky.c
 * Purpose: LED Flasher
 * Note(s): 
 *----------------------------------------------------------------------------*/

#include <stdio.h>
#include "stm32f4xx.h"
#include "stm32f4xx_conf.h" //This is included by stm32f4xx.h


int EXTI0Flag = 0 ;

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


void init(){
  GPIO_InitTypeDef  GPIO_InitStructure;

  // ---------- GPIO  for LEDS -------- //
  // GPIOD Periph clock enable
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

  // Configure PD12, PD13, PD14 and PD15 in output pushpull mode
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOD, &GPIO_InitStructure);


  // ---------- GPIO  for BTN -------- //
  NVIC_InitTypeDef NVIC_InitStructure;
  EXTI_InitTypeDef EXTI_InitStructure;

  /* Enable GPIOA clock */
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
  /* Enable SYSCFG clock */
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE);
  /* Configure PA0 pin as input floating */
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN; //Load parameters into GPIO data structure
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
  GPIO_Init(GPIOA, &GPIO_InitStructure); //Pass structure to GPIO initialization function
  /* Connect EXTI Line0 to PA0 pin */
  SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOA, EXTI_PinSource0);
  /* Configure EXTI Line0 */
  EXTI_InitStructure.EXTI_Line = EXTI_Line0; //Load parameters into EXTI data structure
  EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;
  EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Rising; 
  EXTI_InitStructure.EXTI_LineCmd = ENABLE;
  EXTI_Init(&EXTI_InitStructure); //Pass structure to EXTI initialization function
  /* Enable and set EXTI Line0 Interrupt to the lowest priority */
  NVIC_InitStructure.NVIC_IRQChannel = EXTI0_IRQn; //Load parameters into NVIC data structure
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0x01;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x01;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure); //Pass structure to NVIC initialization function
}


/*----------------------------------------------------------------------------
  MAIN function
 *----------------------------------------------------------------------------*/
int main (void) {

  SystemCoreClockUpdate();                      /* Get Core Clock Frequency   */
  if (SysTick_Config(SystemCoreClock / 1000)) { /* SysTick 1 msec interrupts  */
    while (1);                                  /* Capture error              */
  }

  init();

  GPIO_SetBits(GPIOD, GPIO_Pin_13);

  while(1){}

  

  return 0;
}


void EXTI0_IRQHandler(void) {
  //Clear the EXTI pending bits
  NVIC_ClearPendingIRQ(EXTI0_IRQn);
  EXTI->PR|=(1<<0);
  //Make sure the Button is really pressed
  if ((GPIOA->IDR & (1<<0)))
    GPIO_ToggleBits(GPIOD, GPIO_Pin_13);
}



#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{ 
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

  /* Infinite loop */
  while (1)
  {
  }
}
#endif

