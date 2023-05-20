
rem 请设置以下参数，值前后都不要有空格

rem 设置DUT IP
set DUTIP=192.168.1.1

rem 是否自动连接SSID，0为手动连接，1为自动，为自动时，只支持本机电脑的无线网卡
rem AUTOCONNECT为0时 不需要设置INTERFACENAME 以及SSID和密码
set AUTOCONNECT=1
rem 电脑无线网卡名字,必须先手动设置电脑的无线网卡为WLANAX
set INTERFACENAME=WLANAX
rem 设置DUT的2.4G SSID和密码，如果不测试2.4G，那么把SSID2G 设置为空
rem set SSID2G=CMCC-GYAj
set SSID2G=CU_9966
set KEY2G=12345678
rem 设置DUT的5G SSID和密码，如果不测试5G，那么把SSID5G 设置为空
set SSID5G=CU_9966_5G
set KEY5G=12345678

rem 流量模式，0:2.4G 和5G 分别跑；1:2.4G和5G并发跑
set TRAFFIC_MODE=1
rem 测试频段，0:分别测试2.4G 和 5G；1:只测2.4G； 2：只测5G:
set TEST_BAND=0

rem 设置IPERF3 server 电脑的 IP,需要和DUT一个网段
rem 即电脑有线网卡配置为192.168.1.100
rem 说明：2.4G 5G分开跑时，2.4G用LAN1IP，5G用LAN1IP LAN2IP
set LAN1IP=192.168.1.100
set LAN2IP=192.168.1.200
rem 当跑2.4G+5G并发时，2.4G用LAN3IP，5G用LANIP LAN2IP
set LAN3IP=192.168.1.240

rem 设置IPERF3 client IP,需要和DUT一个网段
rem 2.4G无线网卡配置为192.168.1.24，当2.4G和5G分别跑时，必须设置为与CLIENT_5GIP一样
set CLIENT_24GIP=192.168.1.24
rem 5G无线网卡配置为192.168.1.50
set CLIENT_5GIP=192.168.1.50


rem 设置端口号
set TESTPORT=12346
set TESTPORT2=12347
set TESTPORT3=12348

rem 设置TCP OR UDP
set TESTPROT=TCP
rem iperf3 TCP的一些额外参数 例如 --set-mss=88-1460  --dont-fragment
set TCPOPTIONS=-4 -b 0M -w 2M 
set UDPOPTIONS=-b 10M  
rem 设置打流条数
set TESTPAIRS2G=4
set TESTPAIRS5G=8
rem 设置打流时长,单位秒,默认60秒
set TESTTIME=600
rem 设置打流间隔,单位毫秒
set TESTDELAY=5000
rem 是否测试下行,0为不测试，1为测试
set DOWNTEST=0
rem 是否测试上行,0为不测试，1为测试
set UPTEST=1

rem 设置ATT串口COM
set ATTCOM1=com6
set ATTCOM2=com7
rem 设置串口波特率等参数(波特率,奇偶校验,数据位,停止位)
set SETCOMPARA=9600,n,8,1
rem 设置衰减器依次衰减的值
rem set ATTLIST2G=00,10,15,20,25,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58
rem set ATTLIST5G=00,10,15,20,25,28,30,32,34,36,38,40,42,44,46,48,50
rem set ATTLIST2G=00,30,40,44,48,50
rem set ATTLIST5G=00,10,20,25,30
rem 假如需要测试不同衰减的360度吞吐量，可以配置多个衰减值
set ATTLIST2G=00
set ATTLIST5G=08

rem 设置转盘参数
rem 启动转盘，为0时，转盘不转动
set ZPENABLE=0
rem 转盘的串口号
set ZPCOM=com5
rem 设置串口波特率等参数(波特率,奇偶校验,数据位,停止位)
set SETZPCOMPARA=57600,n,8,1
rem 角度间隔,只支持10,15,20,30 等360整除的数,默认30度
set JDINTERVAL=90

rem 设置测试次数，默认只测试一次
set TESTCOUNT=1