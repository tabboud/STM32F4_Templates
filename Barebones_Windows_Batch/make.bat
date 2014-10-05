REM Make batch script for STM32F4-Discovery 
set objdir=%CD%\obj
set build=%CD%\build
set Include_Paths=-I%CD%\Libraries\CMSIS\STM32F4xx -I%CD%\Libraries\CMSIS\Include -I%CD%\Libraries\STM32F4xx_StdPeriph_Driver\inc -I%CD%
set LIB_PATH=-L%CD%\Libraries\STM32F4xx_StdPeriph_Driver

REM Create build and obj dir
mkdir build
mkdir obj

REM compile asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o aDemo.o CortexM4asmOps_01.asm

REM compiling C
arm-none-eabi-gcc %Include_Paths%  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps startup_stm32f4xx.c -o cStartup.o
arm-none-eabi-gcc %Include_Paths%  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps system_stm32f4xx.c -o cSys32.o
arm-none-eabi-gcc %Include_Paths%  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps main.c -o cMain.o

REM build stdPeriph Library in order to link it
REM comment out here and in clean to not have to compile peripheral library every time
cd %CD%\Libraries\STM32F4xx_StdPeriph_Driver
call buildLibrary.bat
cd %~p0

REM linking
arm-none-eabi-gcc %LIB_PATH% -nostartfiles -g -Wl,--no-gc-sections -Wl,-Map,ch.map -Wl,-T stm32_flash.ld -och.elf cStartup.o cMain.o cSys32.o -lgcc -lstdperiph

REM hex file
arm-none-eabi-objcopy -O ihex ch.elf ch.hex

REM AXF file
copy ch.elf ch.AXF

REM list file
REM arm-none-eabi-objdump -S  ch.axf >ch.lst

REM Move files
move %CD%\*.o %objdir%
move %CD%\*.hex %build%
move %CD%\*.elf %build%
pause

