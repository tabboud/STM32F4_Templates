REM FIX THE MULTI .bat file issue
REM  makeSTM32F4Blinky.bat wmh 2013-02-26 : compile STM32F4DISCOVERY LED demo and .asm opcode demo 
REM !!optional -L and -l switches allow linking to Cortex M4 library functions for divide, etc. 
set path=.\;C:\yagarto_gcc472\bin;
set objdir=%CD%\obj
set build=%CD%\build
set Include_Paths=-I%CD%\Libraries\CMSIS\STM32F4xx -I%CD%\Libraries\CMSIS\Include -I%CD%\Libraries\STM32F4xx_StdPeriph_Driver\inc -I%CD%
set LIB_PATH=-L%CD%\Libraries\STM32F4xx_StdPeriph_Driver

REM Create build and obj dir
mkdir build
mkdir obj

REM assemble with '-g' omitted where we want to hide things in the AXF
REM arm-none-eabi-as -g -mcpu=cortex-m4 -o aDemo.o CortexM4asmOps_01.asm
REM arm-none-eabi-as -g -mcpu=cortex-m4 -o aStartup.o SimpleStartSTM32F4_01.asm

REM compiling C
arm-none-eabi-gcc %Include_Paths%  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps startup_stm32f4xx.c -o cStartup.o
arm-none-eabi-gcc %Include_Paths%  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps system_stm32f4xx.c -o cSys32.o
arm-none-eabi-gcc %Include_Paths%  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps Blinky.c -o cMain.o

REM build stdPeriph Library in order to link it
REM comment out here and in clean to not have to compile peripheral library every time
cd %CD%\Libraries\STM32F4xx_StdPeriph_Driver
REM call buildLibrary.bat
cd %~p0

REM linking
REM arm-none-eabi-gcc %LIB_PATH% -nostartfiles -g -Wl,--no-gc-sections -Wl,-Map,Blinky.map -Wl,-T linkBlinkySTM32F4_01.ld -oBlinky.elf aStartup2.o cMain.o cSys32.o -lgcc -lstdperiph
arm-none-eabi-gcc %LIB_PATH% -nostartfiles -g -Wl,--no-gc-sections -Wl,-Map,Blinky.map -Wl,-T stm32_flash.ld -oBlinky.elf cStartup.o cMain.o cSys32.o -lgcc -lstdperiph

REM hex file
arm-none-eabi-objcopy -O ihex Blinky.elf Blinky.hex

REM AXF file
copy Blinky.elf Blinky.AXF

REM list file
REM arm-none-eabi-objdump -S  Blinky.axf >Blinky.lst

@echo off
REM Move files
move %CD%\*.o %objdir%
move %CD%\*.hex %build%
move %CD%\*.elf %build%
pause

