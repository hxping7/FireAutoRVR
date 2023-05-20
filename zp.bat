@echo off
setlocal enabledelayedexpansion

call config.bat

rem 方向
set JDDI=%~1
rem 角度值
set JD=%~2
rem 等待时间
set SLETEPTIME=(!JD!/30)*6000

mode %ZPCOM%:%SETZPCOMPARA%

	rem 后退360度
	if "%JDDI%"=="go" (
		echo "转盘正前进，请等待"
		set HEX360=go!JD!.bin
	)else (
		echo "转盘正后退，请等待"
		set HEX360=back!JD!.bin
	)

	copy driver\!HEX360! \\.\!ZPCOM! /b
	
	sleep_s %SLETEPTIME%
	
	if "%JDDI%"=="go" (
		echo 转盘已前进!JD!度
	)else (
		echo 转盘已后退!JD!度
	)

	
exit /b 0