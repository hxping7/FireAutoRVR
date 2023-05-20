@echo off
del go10.log go10.bin go30.log  go30.bin  
del go90.log go90.bin go360.log go360.bin back360.log back360.bin  
del go15.log go15.bin backzore.log backzore.bin
del *.log *.bin

rem 转换为bin格式
echo 00032001 >go1.log
certutil -decodehex go1.log go1.bin

echo 00032002 >back1.log 
certutil -decodehex back1.log back1.bin

echo 000FA001 >go5.log
certutil -decodehex go5.log go5.bin

echo 000FA002 >back5.log 
certutil -decodehex back5.log back5.bin

echo 001F4001 >go10.log
certutil -decodehex go10.log go10.bin
echo 001F4002 >back10.log 
certutil -decodehex back10.log back10.bin

echo 002EE001 >go15.log
certutil -decodehex go15.log go15.bin
echo 002EE002 >back15.log
certutil -decodehex back15.log back15.bin

echo 005DC001 >go30.log
certutil -decodehex go30.log go30.bin
echo 005DC002 >back30.log
certutil -decodehex back30.log back30.bin

echo 00BB8001 >go60.log
certutil -decodehex go60.log go60.bin

echo 00BB8002 >back60.log
certutil -decodehex back60.log back60.bin

echo 01194001 >go90.log
certutil -decodehex go90.log go90.bin
echo 01194002 >back90.log
certutil -decodehex back90.log back90.bin

echo 04650001 >go360.log
certutil -decodehex go360.log go360.bin
rem 后退360度
echo 04650002 >back360.log
certutil -decodehex back360.log back360.bin
rem 后退330度zore
echo 04074002 >backzore.log
certutil -decodehex backzore.log backzore.bin

pause