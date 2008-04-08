@echo off
if not defined INFOPATH set INFOPATH=%~dp0..\info
set INFO=%~dp0\ginfo.exe

%INFO% %1 %2 %3 %4 %5 %6 %7 %8