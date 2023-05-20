@echo off
setlocal enabledelayedexpansion

set path=%path%;bin;bin/GnuWin32/bin;bin/iperf;bin/UnxUpdates

call config.bat

set ATT=%~1

echo ATT=%ATT%

set myrand=%time:~0,2%%time:~3,2%%time:~6,2%
rem 移除空格
set myrand=%myrand: =%
set PRE=TH
set IPERFLOG=throughput
set thlogname1=log/!PRE!_!IPERFLOG!-!myrand!.log
set thlogname2=log/!PRE!_2_!IPERFLOG!-!myrand!.log
set thput=./result/th.log
set thput_dir=.\result\th.log

del !thput_dir!
del test_finished
	
rem call :setupIerfServer


rem call :runIperf down %ATT% 00
call :runIperf up  %ATT% 00
pause
exit /b 0

rem :setupIerfServer
rem	echo "kill 可能运行的iperf3进程 防止冲突"
rem	taskkill /f /im iperf3.exe
rem	echo "开启iperf3 server端"
rem    iperf3.exe -s -p !TESTPORT! -B !SERVERIP! --forceflush --interval=1 -D
rem
rem exit /b 0

:runIperf
    set DIRECTION=%~1

	set vATT=%~2
	set vJD=%~3
	
    if "!DIRECTION!"=="down" (
        set DIREC=-R
    )else (
         set DIREC=
    )
	
    if "!BAND!"=="2G" (
        set STAIP=!CLIENT_24GIP!
    )else (
        set STAIP=!CLIENT_5GIP!
    )
	
	echo !BAND! !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname1!
	echo !BAND! !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname2!
	
    if "%TESTPROT%"=="UDP" (
		echo "开始!BAND!: iperf UDP !DIRECTION!打流"
		echo  "!BAND! !DIRECTION!: iperf3.exe -u -b 10M -c !LANIP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! -f m !DIREC! --logfile !thlogname1!"
        start /B iperf3.exe -u -b 10M -c !LANIP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! -f m !DIREC! --logfile !thlogname1!
		echo  "!BAND! !DIRECTION!: iperf3.exe -u -b 10M -c !LAN2IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! -f m !DIREC! --logfile !thlogname2!"
		start /B iperf3.exe -u -b 10M -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! -f m !DIREC! --logfile !thlogname2!
    )else (
		echo "开始!BAND!: iperf TCP !DIRECTION!打流"
		rem CUC: iperf3 -c 192.168.1.100 -i 1 -f k -B 192.168.1.50 -p 12346 -R -t 0 -4 -b 0M -P 8 -w 2M
		echo "!BAND! !DIRECTION!: iperf3.exe -c !LANIP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS5G! -t !TESTTIME! -f m !DIREC! --logfile !thlogname1!"
		rem start /B iperf3.exe -c !LANIP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS5G! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname1!
		start /B iperf3.exe -c !LANIP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS5G! -t !TESTTIME! -4 -b 0M -w 2M -f m  !DIREC! --logfile !thlogname1!
		echo "!BAND! !DIRECTION!: iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS5G! -t !TESTTIME! -f m !DIREC! --logfile !thlogname2!"
		rem start /B  iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS5G! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname2!
		start /B  iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS5G! -t !TESTTIME! -4 -b 0M -w 2M -f m !DIREC! --logfile !thlogname2!
		
    )
	set /a sleeptime=!TESTTIME!*1000+5000
	sleep_s !sleeptime!
	sleep_s 2000
	
	rem 获取结果
    tail.exe -n 4 !thlogname1! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth1.log
	for /F  %%i in ( ' type "log\tmpth1.log" ' ) do (
		set tmpth1=%%i 
	)
    tail.exe -n 4 !thlogname2! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth2.log
	for /F  %%i in ( ' type "log\tmpth2.log" ' ) do (
		set tmpth2=%%i 
	)
	set /a tmpth=!tmpth1!+!tmpth2!
	

	echo !DIRECTION! ATT=!vATT! 吞吐量=!tmpth! >> !thput!
    echo !thput_dir! > test_finished
    del log\tmpth1.log
	del log\tmpth2.log
exit /b 0