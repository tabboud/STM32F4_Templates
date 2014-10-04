REM cleanBlinky.bat wmh 2013-01-29 : cleans intermediate compiler results and output
set path=.\;C:\_software_installs\yagarto\bin;C:\_software_installs\yagarto\yagarto-tools-20100703\bin;
set obj=%CD%\obj
set build=%CD%\build

REM deleting
del %obj%\*.o
del %build%\*.elf
del %build%\*.hex
del *.AXF
del *.dep
del *.map
del *.i
del *.s
del *.lst

REM Deletes the Library build
cd %CD%\Libraries\STM32F4xx_StdPeriph_Driver
call cleanLibrary.bat

pause
