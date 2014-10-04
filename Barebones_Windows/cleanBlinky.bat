REM cleanBlinky.bat wmh 2013-01-29 : cleans intermediate compiler results and output
set path=.\;C:\_software_installs\yagarto\bin;C:\_software_installs\yagarto\yagarto-tools-20100703\bin;
set obj=%CD%\obj
set build=%CD%\build

REM deleting
rmdir /S /Q %CD%\obj
rmdir /S /Q %CD%\build
del *.AXF
del *.dep
del *.map
del *.i
del *.s
del *.lst

REM Deletes the Library build
REM cd %CD%\Libraries\STM32F4xx_StdPeriph_Driver
REM call cleanLibrary.bat

pause
