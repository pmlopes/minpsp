@echo off
set PATH=%~dp0;%PATH%
%~dp0make 2>&1 %1 %2 %3 %4 %5 | %~dp0sed -e "s/\([^:]*\):\([0-9][0-9]*\)\(.*\)/\1 (\2) \3/"
