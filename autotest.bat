:::::::::::::::::::::::::::::::::::::::::::::::::
:: WIFI RVR/360度吞吐量自动测试工具         :::::
::@Code by hxping                           :::::
:: version 1.1@2022/11/01 inital version    :::::
:: V2.0 增加图形化脚本                    :::::                   :::::
:::::::::::::::::::::::::::::::::::::::::::::::::

::说明： 
:: 自动连接时必须先手动设置电脑的无线网卡为WLAN
:: 双击执行main.cmd 将调用powershell图形脚本，
::    需要设置powershell相关权限
:: 或者进入到脚本目录下使用管路员权限cmd窗口 执行autotest.bat
:: 

@echo off
setlocal enabledelayedexpansion

rem ###########参数设置##############
call config.bat

set PROFILEPATH=profile

rem ###############################
rem ###运行环境###
set path=%path%;bin;bin/GnuWin32/bin;bin/iperf;bin/UnxUpdates
set logname=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set myrand=%time:~0,2%%time:~3,2%%time:~6,2%
rem 移除空格
set logname=%logname: =%
set myrand=%myrand: =%

echo *************************************************
echo *                                               *
echo *  FireAutoRVR WIFI RVR/360度自动测试工具V2.0   *
echo *                                               *
echo *************************************************
call :logprintf "启动测试"
echo ======正在检查运行环境============
echo ======1:检查运行脚本必要的工具====
	if not exist bin ( 
		echo 	bin目录不存在，脚本工具不完整无法运行
		call :Usage
		exit /b 0
	)else (
		echo 工具完整 
	)

IF  !AUTOCONNECT! EQU 1 (	
	rem 测试频段，0:分别测试2.4G 和 5G；1:只测2.4G； 2：只测5G:	
	if not %TEST_BAND% EQU 2 (
		if "%SSID2G%" == "" (
			rem echo check "!SSID2G!" pass!
			echo 2.4G SSID未设置
			call :Usage
			exit /b 0
		)
	)
	if not %TEST_BAND% EQU 1 (
		if "%SSID5G%" == "" ( 
			echo 5G SSID未设置
			call :Usage
			exit /b 0
		)
	)
)	
rem 检查result目录
if not exist result ( 
	md result 
)
	
echo ======2:正在设置串口参数==========
call :logprintf "设置ATT串口参数"
	mode %ATTCOM1%:%SETCOMPARA% | findstr /L "设备状态" && ( echo 设置串口%ATTCOM1%成功！&& mode %ATTCOM1% ) || ( echo 设置串口%ATTCOM1%失败！&& mode && call :Usage && exit /b 0)
	mode %ATTCOM2%:%SETCOMPARA% | findstr /L "设备状态" && ( echo 设置串口%ATTCOM2%成功！&& mode %ATTCOM2% ) || ( echo 设置串口%ATTCOM2%失败！&& mode && call :Usage && exit /b 0)
call :logprintf "设置转盘串口参数"
	mode %ZPCOM%:%SETZPCOMPARA% | findstr /L "设备状态" && ( echo 设置串口%ZPCOM%成功！&& mode %ZPCOM% ) || ( echo 设置串口%ZPCOM%失败！&& mode && call :Usage && exit /b 0)

rem 生成wifi profile	
IF  !AUTOCONNECT! EQU 1 (
	echo ======3:正在生成WiFi Profile==========
	rem 测试频段，0:分别测试2.4G 和 5G；1:只测2.4G； 2：只测5G:
	if not %TEST_BAND% EQU 2 ( 
		call :profilegenerate 2G
	)

	if not %TEST_BAND% EQU 1 ( 
		call :profilegenerate 5G
	)
)

set pingfail=0
set count=0
set JDtotal=0
rem main function
:main
	color 0f
	set /a count+=1
	echo 总次数=%TESTCOUNT%
	echo 当前执行次数=!count!
	call :logprintf  "当前执行次数=!count!"
	rem 流量模式，0:2.4G 和5G 分别跑；1:2.4G和5G并发跑
	if !TRAFFIC_MODE! EQU 1 (
		rem 并发模式不支持配置自动连接WiFi
		set AUTOCONNECT=0
		call :TestStartBoth24Gand5G
	)else (
		call :TestStart
	)
	
	sleep_s 1000
	if !count! LSS  %TESTCOUNT% (
		goto :main
	)else (
		echo 测试结束,测试结果位于result目录 
		rem 设置ATT为0
		call :setATT 00
		del !thdowntmp_dir!
		del !thuptmp_dir!
		call :logprintf "测试结束!"
		pause
		exit /b 0 
	)


rem TestStart
:TestStart
echo ======开始360/RVR测试============ 

	rem 设置ATT为0
    call :setATT 00
	set /a JDend=360-!JDINTERVAL!
rem 测试频段，0:分别测试2.4G 和 5G；1:只测2.4G； 2：只测5G:	
if not %TEST_BAND% EQU 2 (	
    echo ======开始2.4G 360/RVR测试============ 
	rem connect SSID
	IF  !AUTOCONNECT! EQU 1 (
		call :connectWLAN !SSID2G!
	)
	sleep_s 1000
	rem 强制使用5G 同一个网卡
	set CLIENT_24GIP=!CLIENT_5GIP!
	rem 执行ping命令，检查是否连接成功
	call :pingdbg !LAN1IP! !CLIENT_24GIP! 
	IF  !pingfail! EQU 1 (
		rem echo ping !LAN1IP! -S !CLIENT_24GIP! fail!
		call :logprintf "ping !LAN1IP! -S !CLIENT_24GIP! fail!"
		exit /b 0
	) 
	
	call :pingdbg !DUTIP! !CLIENT_24GIP!
	IF  !pingfail! EQU 1 (
		rem echo ping !DUTIP! -S !CLIENT_24GIP! fail!
		call :logprintf "ping !DUTIP! -S !CLIENT_24GIP! fail!"
		exit /b 0
	) 
	sleep_s 500
	
	rem 设置iperf3 服务
	rem IF  !AUTOCONNECT! EQU 1 (
	rem	call :setupIerfServer !CLIENT_24GIP!
	rem )
	
    for %%a in (!ATTLIST2G!) do (
	    rem 设置ATT
        call :setATT %%a
		
		IF  !ZPENABLE! EQU 1 (
			for /L %%i in (0,!JDINTERVAL!,!JDend!) do (
				rem 转盘
				call :set360ZP go %%i
				rem 执行iperf3打流
				IF  !DOWNTEST! EQU 1 (
					call :runIperf down 2G %%a %%i
					sleep_s !TESTDELAY!
				)
				IF  !UPTEST! EQU 1 (
					call :runIperf up 2G %%a %%i
					sleep_s !TESTDELAY!
				)
			)
			
			IF  !ZPENABLE! EQU 1 (
				rem 测试结束 转盘回到原点
				call :set360ZP backzore
			)
		
		)else (
			rem 执行iperf3打流
			IF  !DOWNTEST! EQU 1 (
				call :runIperf down 2G %%a 0
				sleep_s !TESTDELAY!
			)
			IF  !UPTEST! EQU 1 (
				call :runIperf up 2G %%a 0
				sleep_s !TESTDELAY!
			)
		)

	)
	
	rem 格式化最终数据，方便记录
	IF  !DOWNTEST! EQU 1 (
		call :formartTXT !thdowntmp! !thdownf!
		sleep_s 500
	)
	IF  !UPTEST! EQU 1 (
		call :formartTXT !thuptmp! !thupf!
		sleep_s 1000
	)
	sleep_s 1000
	rem 设置ATT为0
    call :setATT 00
    sleep_s 500
) 
rem 测试频段，0:分别测试2.4G 和 5G；1:只测2.4G； 2：只测5G:	
if not %TEST_BAND% EQU 1 (
    if not "!SSID5G!" == "" (
        echo ======开始5G 360/RVR测试============ 
		rem connect SSID
		IF  !AUTOCONNECT! EQU 1 (
			call :connectWLAN !SSID5G!
		)
		sleep_s 1000
		rem 执行ping命令，检查是否连接成功
		call :pingdbg !LAN1IP! !CLIENT_5GIP!
		IF  !pingfail! EQU 1 (
			rem echo ping !LAN1IP! -S !CLIENT_5GIP! fail!
			call :logprintf "ping !LAN1IP! -S !CLIENT_5GIP! fail!"
			exit /b 0
		) 
		
		call :pingdbg !DUTIP! !CLIENT_5GIP!
		IF  !pingfail! EQU 1 (
			rem echo ping !DUTIP! -S !CLIENT_5GIP! fail!
			call :logprintf "ping !DUTIP! -S !CLIENT_5GIP! fail!"
			exit /b 0
		) 
		rem 设置iperf3 服务,假如5G网卡在本电脑，才启用server
		rem IF  !AUTOCONNECT! EQU 1 (
		rem	call :setupIerfServer !CLIENT_5GIP!
		rem )
		
        rem 设置ATT
        for %%b in (!ATTLIST5G!) do (
            call :setATT %%b
            sleep_s 500
			IF  !ZPENABLE! EQU 1 (	
				for /L %%i in (0,!JDINTERVAL!,!JDend!) do (
					rem 转盘
					call :set360ZP go %%i
					rem 执行iperf3打流
					IF  !DOWNTEST! EQU 1 (
						call :runIperf down 5G %%b %%i
						sleep_s !TESTDELAY!
					)				
					IF  !UPTEST! EQU 1 (
						call :runIperf up 5G %%b %%i
						sleep_s !TESTDELAY!
					)
				)
				call :logprintf "转盘所有角度测试结束"
				sleep_s !TESTDELAY!
				IF  !ZPENABLE! EQU 1 (
					rem 测试结束 转盘回到原点
					call :set360ZP backzore
				)
			)else (
				rem 执行iperf3打流
				IF  !DOWNTEST! EQU 1 (
					call :runIperf down 5G %%b 0
					sleep_s !TESTDELAY!
				)
				IF  !UPTEST! EQU 1 (
					call :runIperf up 5G %%b 0
					sleep_s !TESTDELAY!
				)
			)	
		)
		rem 格式化最终数据，方便记录
		IF  !DOWNTEST! EQU 1 (
			call :formartTXT !thdowntmp! !thdownf!
			sleep_s 1000
		)
		IF  !UPTEST! EQU 1 (
			call :formartTXT !thuptmp! !thupf!
			sleep_s 1000
		)
    )
)
exit /b 0

:TestStartBoth24Gand5G
echo ======开始360/RVR测试============ 

	rem 设置ATT为0
    call :setATT 00
	set /a JDend=360-!JDINTERVAL!
if  "%CLIENT_24GIP%"=="" (	
    echo CLIENT_24GIP未设置
    call :Usage
    exit /b 0
) 
if  "%CLIENT_5GIP%"=="" (	
    echo CLIENT_5GIP未设置
    call :Usage
    exit /b 0
) 
if "%LAN3IP%" == "" ( 
    echo LAN3IP未设置
    call :Usage
    exit /b 0
)

    echo ======开始2.4G+5G 360/RVR测试============ 

	rem 执行ping命令，检查是否连接成功
	call :pingdbg !LAN1IP! !CLIENT_5GIP!
	IF  !pingfail! EQU 1 (
		echo ping %%a -S !CLIENT_5GIP! fail!
		call :logprintf "ping %%a -S !CLIENT_5GIP! fail!"
		exit /b 0
	) 
	
	call :pingdbg !LAN2IP! !CLIENT_5GIP!
	IF  !pingfail! EQU 1 (
		echo ping %%a -S !CLIENT_5GIP! fail!
		call :logprintf "ping %%a -S !CLIENT_5GIP! fail!"
		exit /b 0
	) 
	call :pingdbg !LAN3IP! !CLIENT_5GIP!
	IF  !pingfail! EQU 1 (
		echo ping %%a -S !CLIENT_5GIP! fail!
		call :logprintf "ping %%a -S !CLIENT_5GIP! fail!"
		exit /b 0
	) 
	
	call :pingdbg !DUTIP! !CLIENT_5GIP!
	IF  !pingfail! EQU 1 (
		echo ping %%a -S !CLIENT_5GIP! fail!
		call :logprintf "ping %%a -S !CLIENT_5GIP! fail!"
		exit /b 0
	) 

    rem 设置ATT
    for %%b in (!ATTLIST5G!) do (
        call :setATT %%b
        sleep_s 500
		IF  !ZPENABLE! EQU 1 (	
			for /L %%i in (0,!JDINTERVAL!,!JDend!) do (
				rem 转盘
				call :set360ZP go %%i
				rem 执行iperf3打流
				IF  !DOWNTEST! EQU 1 (
					call :runIperfBoth2Gand5G down %%b %%i
					sleep_s !TESTDELAY!
				)				
				IF  !UPTEST! EQU 1 (
					call :runIperfBoth2Gand5G up %%b %%i
					sleep_s !TESTDELAY!
				)
			)
			call :logprintf "转盘所有角度测试结束"
			sleep_s !TESTDELAY!
			IF  !ZPENABLE! EQU 1 (
				rem 测试结束 转盘回到原点
				call :set360ZP backzore
			)
		)else (
			rem 执行iperf3打流
			IF  !DOWNTEST! EQU 1 (
				call :runIperfBoth2Gand5G down %%b 0
				sleep_s !TESTDELAY!
			)
			IF  !UPTEST! EQU 1 (
				call :runIperfBoth2Gand5G up %%b 0
				sleep_s !TESTDELAY!
			)
		)	
	)
	rem 格式化最终数据，方便记录
	IF  !DOWNTEST! EQU 1 (
		call :formartTXT !thdowntmp! !thdownf!
		sleep_s 1000
	)
	IF  !UPTEST! EQU 1 (
		call :formartTXT !thuptmp! !thupf!
		sleep_s 1000
	)

exit /b 0

:setupIerfServer
	set BINDIP=%~1
	
	echo "kill 可能运行的iperf3进程 防止冲突"
	taskkill /f /im iperf3.exe
	echo "开启iperf3 server端"
        rem iperf3.exe -s -p !TESTPORT! -B !BINDIP! -D
	iperf3.exe -s -p !TESTPORT! -B !BINDIP! --forceflush --interval=1 -D
	call :logprintf "iperf3.exe -s -p !TESTPORT! -B !BINDIP! -D"

exit /b 0

:runIperf
    set DIRECTION=%~1
	set BAND=%~2
	set vATT=%~3
	set vJD=%~4
	
	set IPERFLOG=throughput
	set thlogname1=log/!BAND!_!IPERFLOG!-!myrand!.log
	set thlogname2=log/!BAND!_2_!IPERFLOG!-!myrand!.log
	set thdown=result/!BAND!_down_!IPERFLOG!-!myrand!.log
	set thup=result/!BAND!_up_!IPERFLOG!-!myrand!.log
	set thdowntmp=result/!BAND!_down_!IPERFLOG!-!myrand!.tmp
	set thdowntmp_dir=result\!BAND!_down_!IPERFLOG!-!myrand!.tmp
	set thuptmp=result/!BAND!_up_!IPERFLOG!-!myrand!.tmp
	set thuptmp_dir=result\!BAND!_up_!IPERFLOG!-!myrand!.tmp
	set thdownf=result/final_!BAND!_down_!IPERFLOG!-!myrand!.log
	set thupf=result/final_!BAND!_up_!IPERFLOG!-!myrand!.log
	set thupf_dir=result\final_!BAND!_up_!IPERFLOG!-!myrand!.log
	
    if "!DIRECTION!"=="up" (
        set DIREC=
    )else (
         set DIREC=-R
    )
	
    if "!BAND!"=="2G" (
        set STAIP=!CLIENT_24GIP!
		set TESTPAIRS=!TESTPAIRS2G!
    )else (
        set STAIP=!CLIENT_5GIP!
		set TESTPAIRS=!TESTPAIRS5G!
    )
	
    echo !BAND! !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname1!
	if "!BAND!"=="5G" (	
	  echo !BAND! !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname2!
	)
	
    if "%TESTPROT%"=="UDP" (
		echo "开始!BAND!: iperf UDP !DIRECTION!打流"
		call :logprintf  "!BAND! !DIRECTION!: iperf3.exe -u -c !LAN1IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname1!"
        start /B iperf3.exe -u -c !LAN1IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname1!
		if "!BAND!"=="5G" (	
			call :logprintf  "!BAND! !DIRECTION!: iperf3.exe -u -c !LAN2IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname2!"
			start /B iperf3.exe -u  -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname2!
		)
		
    )else (
		echo "开始!BAND!: iperf TCP !DIRECTION!打流"
		rem CUC: iperf3 -c 192.168.2.4 -i 1 -f k -B 192.168.2.204 -p 10102 -R -t 0 -4 -b 0M -P 8 -w 2M
		call :logprintf "!BAND! !DIRECTION!: iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname1!"
		rem start /B iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname1!
		start /B iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname1!
		if "!BAND!"=="5G" (
		  call :logprintf "!BAND! !DIRECTION!: iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname2!"
		  rem start /B iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname2!
		  start /B iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !STAIP! -P !TESTPAIRS! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname2!
		)
    )
	rem wait iperf3 finish
	set /a sleeptime=!TESTTIME!*1000+5000
	echo "等待iperf3打流结束 sleeptime=!sleeptime!毫秒"
	sleep_s !sleeptime!
	sleep_s 2000
	
	echo "正在获取结果..."
	rem 获取结果
    tail.exe -n 4 !thlogname1! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth1.log
	for /F  %%i in ( ' type "log\tmpth1.log" ' ) do (
		set tmpth1=%%i 
	)
	if "!BAND!"=="5G" (
		tail.exe -n 4 !thlogname2! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth2.log
		for /F  %%i in ( ' type "log\tmpth2.log" ' ) do (
			set tmpth2=%%i 
		)
	)
	if "!BAND!"=="5G" (
		set /a tmpth=!tmpth1!+!tmpth2!
	)else (
		set tmpth=!tmpth1!
	)
	
	if "!DIRECTION!"=="down" (
		call :logprintf "衰减=!vATT!时,  角度=!vJD!, !BAND!下行吞吐量=!tmpth!"
        echo 衰减=!vATT!; 角度=!vJD!; 吞吐量=!tmpth! >> !thdown!
		echo !vATT!;!vJD!;!tmpth! >> !thdowntmp!
    )else (
		call :logprintf "衰减=!vATT!时, 角度=!vJD!, !BAND!上行吞吐量=!tmpth!"
        echo 衰减=!vATT!; 角度=!vJD!; 吞吐量=!tmpth! >> !thup!
		echo !vATT!;!vJD!;!tmpth! >> !thuptmp!	
    )
    del log\tmpth1.log
	if "!BAND!"=="5G" (
		del log\tmpth2.log
	)
exit /b 0

:runIperfBoth2Gand5G
    set DIRECTION=%~1
	set BAND=Both
	set vATT=%~2
	set vJD=%~3
	
	set IPERFLOG=throughput
	set thlogname1=log/24G_!IPERFLOG!-!myrand!.log
	set thlogname2=log/5G_1_!IPERFLOG!-!myrand!.log
	set thlogname3=log/5G_2_!IPERFLOG!-!myrand!.log
	set thdown=result/!BAND!_down_!IPERFLOG!-!myrand!.log
	set thup=result/!BAND!_up_!IPERFLOG!-!myrand!.log
	set thdowntmp=result/!BAND!_down_!IPERFLOG!-!myrand!.tmp
	set thdowntmp_dir=result\!BAND!_down_!IPERFLOG!-!myrand!.tmp
	set thuptmp=result/!BAND!_up_!IPERFLOG!-!myrand!.tmp
	set thuptmp_dir=result\!BAND!_up_!IPERFLOG!-!myrand!.tmp
	set thdownf=result/final_!BAND!_down_!IPERFLOG!-!myrand!.log
	set thupf=result/final_!BAND!_up_!IPERFLOG!-!myrand!.log
	set thupf_dir=result\final_!BAND!_up_!IPERFLOG!-!myrand!.log
	
    if "!DIRECTION!"=="up" (
        set DIREC=
		set DIREC2G=-R
    )else (
         set DIREC=-R
		 set DIREC2G=
    )
	
    echo 2.4G !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname1!
	echo 5G-1 !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname2!
	echo 5G-2 !DIRECTION! ATT=!vATT!dB, !vJD!度 : >> !thlogname3!
	
    if "%TESTPROT%"=="UDP" (
		echo "开始!BAND!: iperf UDP !DIRECTION!打流"
		rem 2.4G
		call :logprintf  "!BAND! !DIRECTION!: iperf3.exe -u -c !CLIENT_24GIP! -p !TESTPORT! -B !LAN3IP! -P !TESTPAIRS2G! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname1!"
        start /B iperf3.exe -u -c !CLIENT_24GIP! -p !TESTPORT! -B !LAN3IP! -P !TESTPAIRS2G! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname1!
		rem 5G1
		call :logprintf  "!BAND! !DIRECTION!: iperf3.exe -u -c !LAN1IP! -p !TESTPORT! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname2!"
		start /B iperf3.exe -u -c !LAN1IP! -p !TESTPORT2! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname2!
		rem 5G2
		call :logprintf  "!BAND! !DIRECTION!: iperf3.exe -u -c !LAN2IP! -p !TESTPORT! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname3!"
		start /B iperf3.exe -u -c !LAN2IP! -p !TESTPORT2! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !UDPOPTIONS! -f m !DIREC! --logfile !thlogname3!
    )else (
		echo "开始!BAND!: iperf TCP !DIRECTION!打流"
		rem CUC: iperf3 -c 192.168.2.4 -i 1 -f k -B 192.168.2.204 -p 10102 -R -t 0 -4 -b 0M -P 8 -w 2M
		rem 2.4G
		call :logprintf "!BAND! !DIRECTION!: iperf3.exe -c !CLIENT_24GIP! -p !TESTPORT! -B !LAN3IP! -P !TESTPAIRS2G! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC2G! --logfile !thlogname1!"
		rem start /B iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !LAN3IP! -P !TESTPAIRS2G! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname1!
		start /B iperf3.exe -c !CLIENT_24GIP! -p !TESTPORT3! -B !LAN3IP! -P !TESTPAIRS2G! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC2G! --logfile !thlogname1!
        rem 5G1
		call :logprintf "!BAND! !DIRECTION!: iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname2!"
		rem start /B iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname2!
		start /B iperf3.exe -c !LAN1IP! -p !TESTPORT! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname2!
		rem 5G2
		call :logprintf "!BAND! !DIRECTION!: iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! -f m !DIREC! --logfile !thlogname3!"
		rem start /B iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! --set-mss=88-1460 -f m !DIREC! --logfile !thlogname3!
		start /B iperf3.exe -c !LAN2IP! -p !TESTPORT2! -B !CLIENT_5GIP! -P !TESTPAIRS5G! -t !TESTTIME! !TCPOPTIONS! -f m !DIREC! --logfile !thlogname3!
		
    )
	rem wait iperf3 finish
	set /a sleeptime=!TESTTIME!*1000+5000
	echo "等待iperf3打流结束 sleeptime=!sleeptime!毫秒"
	sleep_s !sleeptime!
	sleep_s 2000
	
	echo "正在获取结果..."
	rem 获取结果
    tail.exe -n 4 !thlogname1! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth1.log
	for /F  %%i in ( ' type "log\tmpth1.log" ' ) do (
		set tmpth1=%%i 
	)
    tail.exe -n 4 !thlogname2! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth2.log
	for /F  %%i in ( ' type "log\tmpth2.log" ' ) do (
		set tmpth2=%%i 
	)
	tail.exe -n 4 !thlogname3! | grep SUM | grep receiver | gawk.exe "{ print $6 }" > log/tmpth3.log
	for /F  %%i in ( ' type "log\tmpth3.log" ' ) do (
		set tmpth3=%%i 
	)
	set /a tmpth=!tmpth1!+!tmpth2!+!tmpth3!
	
	if "!DIRECTION!"=="down" (
		call :logprintf "衰减=!vATT!时,  角度=!vJD!, 2.4G吞吐量=!tmpth1!, 5G-STA1吞吐量=!tmpth2!，5G-STA2吞吐量=!tmpth3!，总下行吞吐量=!tmpth!"
        echo 衰减=!vATT!; 角度=!vJD!; 2.4G吞吐量=!tmpth1!; 5G-STA1吞吐量=!tmpth2!; 5G-STA2吞吐量=!tmpth3!; 总下行吞吐量=!tmpth! >> !thdown!
		echo !vATT!;!vJD!;!tmpth1!;!tmpth2!;!tmpth3!;!tmpth! >> !thdowntmp!
    )else (
		call :logprintf "衰减=!vATT!时, 角度=!vJD!, 2.4G吞吐量=!tmpth1!, 5G-STA1吞吐量=!tmpth2!，5G-STA2吞吐量=!tmpth3!，总上行吞吐量=!tmpth!"
        echo 衰减=!vATT!; 角度=!vJD!; 2.4G吞吐量=!tmpth1!; 5G-STA1吞吐量=!tmpth2!; 5G-STA2吞吐量=!tmpth3!; 总上行吞吐量=!tmpth! >> !thup!
		echo !vATT!;!vJD!;!tmpth1!;!tmpth2!;!tmpth3!;!tmpth! >> !thuptmp!	
    )
    del log\tmpth1.log
    del log\tmpth2.log
	del log\tmpth3.log
exit /b 0

:setATT
    set ATTVAL=%~1
    echo 设置ATT值为%ATTVAL%
    call :logprintf  "设置ATT值为=%ATTVAL%"
    @echo att-0%ATTVAL%.00 >!ATTCOM1!
    @echo att-0%ATTVAL%.00 >!ATTCOM2!
exit /b 0

:set360ZP
	rem 方向
	set JDDI=%~1
	rem 角度值
	set JDtotal=%~2
	
    set HEX360=go!JDINTERVAL!.bin
	rem 后退360度
	if "%JDDI%"=="backzore" (
		echo "转盘正回退到起点，请等待"
		rem 先前进一个间隔 跑满360度
		copy driver\!HEX360! \\.\!ZPCOM! /b
		sleep_s 12000
		set HEX360=back360.bin
		copy driver\!HEX360! \\.\!ZPCOM! /b
		sleep_s 40000
		exit /b 0
	)
	
	if !JDtotal! EQU 0 (
		echo 转盘到达!JDtotal!度，无需前进
		call :logprintf  "转盘到达!JDtotal!度，无需前进"
		exit /b 0
	) else (
		echo 前进!JDINTERVAL!度，目标!JDtotal!度
	)

	copy driver\!HEX360! \\.\!ZPCOM! /b
	set /a zpsleep=!JDINTERVAL!*166
	sleep_s !zpsleep!
	sleep_s 1000
	echo 转盘到达!JDtotal!度
	call :logprintf  "转盘到达!JDtotal!度"
	
exit /b 0

rem 格式化输出结果
:formartTXT
	rem file input
	set infile=%~1
	set outfile=%~2
	
	echo "正在处理结果数据!infile!"
	set tmpATTOLD=00
	for /F "tokens=1-5 delims=;" %%a in ( !infile! ) do (	
		set tmpATT=%%a
		
		if  "!tmpATT!"=="!tmpATTOLD!" (
			rem echo "ATT相同"
			set tmpJD=!tmpJD!  %%b
			set tmpv=!tmpv! %%c
		)else (
			rem echo "ATT不相同"
			echo 衰减：!tmpATTOLD! dB >> !outfile!
			echo 角度：  !tmpJD!  >> !outfile!
			echo 吞吐量：!tmpv! >> !outfile!

			set tmpATTOLD=%%a
			set tmpJD=%%b
			set tmpv=%%c
		) 
	)
	
	rem 最后一组数据
	echo 衰减：!tmpATTOLD! dB >> !outfile!
	sleep_s 1000
	echo 角度：  !tmpJD!  >> !outfile!
	sleep_s 1000
	echo 吞吐量：!tmpv! >> !outfile!
	echo !thupf_dir! > test_finished
	sleep_s 500
	echo "结果数据处理完成"
	call :logprintf  "结果数据处理完成"
	rem 清理变量
	set tmpJD= 
	set tmpv= 
		
exit /b 0


rem function generate the WLAN profile
:profilegenerate 
    set BAND=%~1
    if "%BAND%"=="2G" (
        set SSID=!SSID2G!
        set WPAKEY=!KEY2G!
    )else (
        set SSID=!SSID5G!
        set WPAKEY=!KEY5G!
    )

    if not exist !PROFILEPATH! ( 
        md !PROFILEPATH! 
        echo 正在创建profile目录
    )

	call :string2hex !SSID!
    echo 正在创建windows WLAN profile文件!SSID!.xml
	
    (
    echo ^<?xml version="1.0" ?^>
    echo ^<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"^>
    echo ^<name^>!SSID!^</name^>
    echo 	^<SSIDConfig^>
    echo 		^<SSID^>
    echo 			^<hex^>!SSIDHEX!^</hex^>
    echo 			^<name^>!SSID!^</name^>
    echo 		^</SSID^>
    echo	^</SSIDConfig^>
    echo	^<connectionType^>ESS^</connectionType^>
    echo	^<connectionMode^>auto^</connectionMode^>
    echo	^<MSM^>
    echo		^<security^>
    echo			^<authEncryption^>
    echo				^<authentication^>WPA2PSK^</authentication^>
    echo				^<encryption^>AES^</encryption^>
    echo				^<useOneX^>false^</useOneX^>
    echo			^</authEncryption^>
    echo			^<sharedKey^>
    echo				^<keyType^>passPhrase^</keyType^>
    echo				^<protected^>false^</protected^>
    echo				^<keyMaterial^>!WPAKEY!^</keyMaterial^>
    echo			^</sharedKey^>
    echo		^</security^>
    echo	^</MSM^>
    echo ^</WLANProfile^>
    ) > "!PROFILEPATH!/!SSID!.xml"

	echo 创建windows WLAN profile文件!SSID!.xml 成功
	call :logprintf "创建windows WLAN profile文件!SSID!.xml 成功"
exit /b 0



:connectWLAN
    set SSID=%~1
    rem reneable interface 
    netsh interface set interface name="!INTERFACENAME!" admin=disabled
	sleep_s 1000
    netsh interface set interface name="!INTERFACENAME!" admin=enabled
    echo 等待10秒，让无线网卡正常起来
    sleep_s 10000
    arp -d
 	
    rem do some clean
    echo 正在断开网卡当前连接
    netsh wlan disconnect interface="!INTERFACENAME!"
    netsh wlan delete profile name="!SSID2G!" interface="!INTERFACENAME!" 
    netsh wlan delete profile name="!SSID5G!" interface="!INTERFACENAME!" 
	
    rem add profile for windows wireless dongle
    echo 正在连接无线!SSID!
    call :logprintf "add !PROFILEPATH!\!SSID!.xml"
    netsh wlan add profile filename="!PROFILEPATH!\!SSID!.xml" interface="!INTERFACENAME!" 
	sleep_s.exe 2000
    rem connect SSID
    call :logprintf  "connecting !SSID!"
    netsh wlan connect name="!SSID!" ssid="!SSID!" interface="!INTERFACENAME!" 
    rem sleep 5s
    sleep_s.exe 5000

exit /b 0


rem ping 
:pingdbg
set PINGTARGET=%~1
set SIP=%~2
set /a i=0
for %%a in (%PINGTARGET%) do (
	 echo ping dip=%%a
	 set /a i+=1
	 ping %%a -S !SIP! |findstr TTL= && ( call :logprintf  ping %%a 成功！&& color 0f ) || ( color 0c && set /a pingfail%%a+=1 && call :logprintf pingfail_%%a失败总计!pingfail%%a!次  ) 
	 rem echo pingfail_%%a=!pingfail%%a! 
	IF  !pingfail%%a! EQU 1 (
        set pingfail=1
		echo ping %%a -S !SIP! fail!
    ) ELSE (
        set pingfail=0
		echo ping %%a -S !SIP! success!
    )
)
	
color 0f
exit /b 0

rem string2hex tools
:string2hex
rem Store the string in chr.tmp file
set /P "=%~1" < NUL > chr.tmp

rem Create zero.tmp file with the same number of Ascii zero characters
for %%a in (chr.tmp) do fsutil file createnew zero.tmp %%~Za > NUL

rem Compare both files with FC /B and get the differences
set "hex="
for /F "skip=1 tokens=2" %%a in ('fc /B chr.tmp zero.tmp') do set "hex=!hex!%%a"

del chr.tmp zero.tmp
set SSIDHEX=%hex%
exit /b 0

rem logprintf log
:logprintf
if not exist log ( 
	md log 
	echo 正在创建log目录
)
set mydate=%DATE%-%TIME% 
if not "%~1"=="" ( 
echo addlog "%~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9" 
echo %mydate% %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9 >> log\"!logname!".log
)
exit /b 0

:Usage
echo =====使用方法===== 
echo 管理员权限cmd窗口 进入到脚本目录下
echo 执行autotest.bat
echo 生成的结果位于result目录
echo 运行之前，请确保编辑config.bat文件，配置好相应的参数
echo 更多帮助 请查看 使用说明.txt
exit /b 0 