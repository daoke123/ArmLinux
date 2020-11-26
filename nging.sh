#!/bin/bash
LANG=en_US.UTF-8

name="nging"
port="9999"
user=`id -u`
version="3.0.2"
path="/opt"
unamem=`uname -m`
downlink="https://img.nging.coscms.com/nging/v$version"
hostip=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
info="\033[32m[信息]\033[0m"
if [[ $user -ne 0 ]]; then
	echo -e "$info 该脚本需要root权限!"
	exit 1
fi
if ! command -v unzip > /dev/null 2>&1;then
	echo -e "$info 未找到unzip命令"
	echo -e "$info 请安装后再运行此脚本"
	exit 1
fi

check_path(){
if [ ! -d "$path" ];then
	mkdir $path
fi	
if [ ! -d "$path/$name" ];then
	mkdir $path/$name
else
	rm -rf $path/$name
	mkdir $path/$name
fi
}
install(){
while [ "$yn" != "y" ] && [ "$yn" != "n" ]
do
	read -p "确认安装?(y/n): " yn;
done
if [ "$yn" = "n" ];then
        exit 0
fi
check_path
case $unamem in
*armv5*)
	osarch=linux_arm-5
;;
*armv6*)
	osarch=linux_arm-6
;;
*armv7*)
	osarch=linux_arm-7
;;
*armv8*)
	osarch=linux_arm64
;;
*arm64*)
	osarch=linux_arm64
;;
*aarch64*)
	osarch=linux_arm64
;;
*)
	echo -e "$info 暂不支持此系统!"
	echo -e "$info 请前往官方网站下载对应程序!"
	exit 1
;;
esac
cd $path/$name
wget --no-check-certificate -O $path/$name/nging_$osarch.zip $downlink/nging_$osarch.zip
echo -e "$info 正在解压文件"
unzip -qd $path/$name $path/$name/nging_$osarch.zip
chmod +x $name
rm -rf nging_$osarch.zip 
./$name service install > /dev/null 2>&1
./$name service start > /dev/null 2>&1
wget -O /usr/bin/nging http://script.mouyijun.cn/nging > /dev/null 2>&1 
chmod 777 /usr/bin/nging
clear
echo -e "--------------------------------------------"
echo -e "$info 安装完成!"
echo -e "浏览器访问\e[36m$hostip:$port\e[0m"
echo -e "若无法访问请去防火墙打开$port端口号"
echo -e "--------------------------------------------"
}
uninstall(){
rm -f /usr/bin/$name > /dev/null 2>&1
cd /opt/$name > /dev/null 2>&1
./nging service stop > /dev/null 2>&1
./nging service uninstall > /dev/null 2>&1
rm -rf $path/$name > /dev/null 2>&1
echo -e "$info 卸载完成!"
}
clear
echo -e "============================================"
echo -e "$name 安装脚本"
echo -e "\e[31m仅限Arm Linux系统!\e[0m"
echo -e "默认安装至\e[36m$path/$name\e[0m"
echo -e "其它架构的Linux系统请前往官网下载对应程序!"
echo -e "============================================"
echo -e "请选择你要使用的功能:"
echo -e " 1. 安装$name"
echo -e " 2. 卸载$name"
read -p "输入数字以执行(1-2): " number
case $number in
1)
	install
;;
2)
	uninstall
;;
*)
	echo -e "$info 请输入正确的数字!"
	exit 1
;;
esac
exit 0
