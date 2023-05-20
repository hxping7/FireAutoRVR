@echo off
setlocal enabledelayedexpansion

call config.bat
 
    set ATTVAL=%~1
    echo 设置ATT值为%ATTVAL% 
    @echo att-0%ATTVAL%.00 >!ATTCOM1!
    @echo att-0%ATTVAL%.00 >!ATTCOM2!
exit /b 0

