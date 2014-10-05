REM This builds the standard peripheral library. Link it with -lstdperiph in the main batch file
set Include_Paths=-I%CD%\..\CMSIS\STM32F4xx -I%CD%\..\CMSIS\Include -I%CD%\inc -I%CD%\..\..
set CFLAGS=-g -O0 -Wall -mlittle-endian -mthumb -mthumb-interwork -mcpu=cortex-m4 -msoft-float -ffreestanding -nostdlib

REM compile all *.c to *.o
cd %CD%\src
FOR %%i IN (*.*) DO arm-none-eabi-gcc %CFLAGS% %Include_Paths% -c -o %%~ni.o %%~ni.c
cd ..

REM Create the static library file
arm-none-eabi-ar -r libstdperiph.a %CD%\src\*.o
