# FireAutoRVR
a simple bat script project for wifi rvr test  

this script based on bat and powershell，only run on windows 7 10 11   
## usage：   
1，run main.cmd will call a windows powershell script，then edit the config，and click “开始测试”  
2，this script based on a programable ATT and turntable，you must modify the command fit for your ATT and turntable   
3,traffic only based on iperf3   

## 脚本功能：   
1，配合程控衰减和程控电动转台 完成wifi的RVR 和360度方向吞吐量测试。  
2，使用iperf3 打流  
3，输出简单txt格式的打流结果报告  

## 使用环境：
1，脚本适用于windows 7、10、11  由bat脚本执行具体的逻辑循环与串口操作。  
2，若使用powershell窗口化脚本，则需要安装powershell，以及设置相关脚本执行权限
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned 提示选择Y即可   

## 使用方法：
1，使用powershell图形化脚本  
    双击运行main.cmd，然后编辑配置，然后点击自动运行  
2，编辑好config.bat里面的配置，然后cmd下运行autotest.bat

## 特别注意：
该脚本基于特定型号的程控衰减器和程控转盘，不同的型号具体指令需要自己修改。  