@echo off
rem  Vivado(TM)
rem  compile.bat: a Vivado-generated XSim simulation Script
rem  Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

set PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%;D:/Vivado/Vivado/Vivado/2014.2/ids_lite/ISE/bin/nt64;D:/Vivado/Vivado/Vivado/2014.2/ids_lite/ISE/lib/nt64;D:/Vivado/Vivado/Vivado/2014.2/bin;%PATH%
set XILINX_PLANAHEAD=D:/Vivado/Vivado/Vivado/2014.2

xelab -m64 --debug typical --relax -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot TestOfMultiCycleCPU_behav --prj F:/Vivado/MultiCycleCPU/MultiCycleCPU.sim/sim_1/behav/TestOfMultiCycleCPU.prj   xil_defaultlib.TestOfMultiCycleCPU   xil_defaultlib.glbl
if errorlevel 1 (
   cmd /c exit /b %errorlevel%
)
