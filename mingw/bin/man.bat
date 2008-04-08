@echo off
:: @(#) man - unix man emulator
:: Syntax:
::     man {[section] topic} | {manfile}
:: Requires:
::    * groff.exe and grotty.exe (see http://gnuwin32.sourceforge.net/packages/groff.htm)
::    * cmd.exe with extentions (tested with WinXP.sp1)
:: Limitation:
::    * Simplest command line syntax
::    * No search in multiple man dirs (ToDo:???)
::
setlocal enableextensions
setlocal

if "%1"==""    goto :usage

:: !!! For VIM Man script: not supported options
for %%x in ( a c d D f F h k K t W ) do if %1 == -%%x shift /1

if not defined MANPATH    set MANPATH=%~dp0..\man
if not defined MANSECT    set MANSECT=1 8 2 3 4 5 6 7 9 tcl n l p o
if not defined PAGER      set PAGER=less -C

set GROFF_FONT_PATH=%~dp0..\share\font
set GROFF_TMAC_PATH=%~dp0..\share\tmac
set GROFF=groff -P -c -Tlatin1 -mandoc

set LESS= --ignore-case --hilite-search --squeeze-blank-lines --CLEAR-SCREEN --no-init -z 60

set COLUMNS=96
set PATH=%~dp0

set FINDSECT=

:: Show file (not dir) in the current dir if some exists
if exist %1 if not exist %1\nul call :show %1 %~x1
if not "%2"==""    call :dosect %1 %2

::::::::::::::::::::::::::::::::::::::::::::
:findsect
set FINDSECT=1

for %%S in (%MANSECT%) do call :dosect %%S %1

call :notfound %1

::::::::::::::::::::::::::::::::::::::::::::
:: dosect - Search secttion %1 for %2
:: %1 - section character
:: %2 - topic
:dosect

::echo Searching sect %1 for %2 >&2
for %%F in ( %MANPATH%\man%1\%2.* ) do call :show %%F %%~xF

if defined FINDSECT goto :EOF

call :notfound %2(%1)

::::::::::::::::::::::::::::::::::::::::::::
:: Subroutine show - filter file through groff utility
:: %1 - file to show
:: %2 - file extention
:show
%GROFF% %1 2> nul | %PAGER% -
set found=1
goto :finish

::::::::::::::::::::::::::::::::::::::::::::
:: Subroutine usage - show usage info and exit
:usage
echo %~nx0 - search and display unix manual pages >&2
echo Usage: >&2
echo ^    %~n0 {[section] topic} ^| manfile >&2
goto :finish

::::::::::::::::::::::::::::::::::::::::::::
:: Subroutine notfound - shoe error message and exit 
:notfound
if not "%found%"=="1" echo %~n0: No man page for %1 >&2
goto :finish

:finish
::exit 0
