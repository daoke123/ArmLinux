#!/bin/bash
LANG=en_US.UTF-8

name="simple-torrent"
port="3000"
user=`id -u`
unamem=`uname -m`
downlink="https://ndns.coding.net/p/mouyijun/d/armsoft/git/raw/master/$name"
hostip=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
info="\033[32m[信息]\033[0m"
if [[ $user -ne 0 ]]; then
	echo -e "$info 该脚本需要root权限!"
	exit 1
fi
if ! command -v systemctl > /dev/null 2>&1;then
	echo -e "$info 该脚本只适用于使用systemd的Linux系统"
	echo -e "$info 例如:Ubuntu 16.04 + 或者 Centos 7 +"
	exit 1
fi

check_path(){
if [ ! -d "/opt" ];then
	mkdir /opt
fi	
if [ ! -d "/opt/$name" ];then
	mkdir /opt/$name
else
	rm -rf /opt/$name
	mkdir /opt/$name
fi
}
add_service(){
echo "[Unit]
Description=Simple torrent download manager
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/$name
Environment=AUTH=$username:$password
Environment=PORT=$port
ExecStart=/opt/$name/$name -c ./cloud-torrent.json --host 0.0.0.0 --disable-log-time
Restart=always
RestartPreventExitStatus=42
RestartSec=3

#adjust file limit if using non-root user.
#LimitNOFILE=50000

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/$name.service
systemctl daemon-reload
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
	osarch=linux-armv5
;;
*armv6*)
	osarch=linux-armv6
;;
*armv7*)
	osarch=linux-armv7
;;
*armv8*)
	osarch=linux-arm64
;;
*arm64*)
	osarch=linux-arm64
;;
*aarch64*)
	osarch=linux-arm64
;;
*)
	echo -e "$info 暂不支持此系统!"
	echo -e "$info 请前往官方网站下载对应程序!"
	exit 1
;;
esac
wget --no-check-certificate -O /opt/$name/$osarch.tar.gz $downlink/$osarch.tar.gz
tar zxf /opt/$name/$osarch.tar.gz -C /opt/$name
chmod +x /opt/$name/$name
rm -rf /opt/$name/$osarch.tar.gz
username="admin"
password="admin"
add_service
systemctl enable $name.service
systemctl start $name.service
clear
echo -e "--------------------------------------------"
echo -e "$info 安装完成!"
echo -e "浏览器访问\e[36m$hostip:$port\e[0m"
echo -e "若无法访问请去防火墙打开$port端口号"
echo -e "账号:\e[36madmin\e[0m"
echo -e "密码:\e[36madmin\e[0m"
echo -e "--------------------------------------------"
}
uninstall(){
systemctl stop $name.service > /dev/null 2>&1
systemctl disable $name.service > /dev/null 2>&1
rm -rf /etc/systemd/system/$name.service
systemctl daemon-reload > /dev/null 2>&1
rm -rf /opt/$name > /dev/null 2>&1
echo -e "$info 卸载完成!"
}
change_idpw(){
echo ""
if [ -f /opt/$name/$name ];then
	echo -e "$info 账号密码可为空"
	read -p "新的用户名:" username
	read -p "新的密码:" password
	echo -e "$info 端口号默认为3000"
	echo -e "$info 端口号范围建议为2000-65535"
	read -p "新的端口号:" port
	if [ -z $port ];then
		port="3000"
	fi
	add_service
	systemctl restart $name.service
	echo ""
	echo -e "--------------------------------------------"
	echo -e "$info 更改完成!"
	echo -e "$info 浏览器访问 $hostip:$port"
else
	echo -e "$info 程序未安装!"
fi
}
clear
echo -e "============================================"
echo -e "$name 安装脚本"
echo -e "\e[31m仅限Arm Linux系统!\e[0m"
echo -e "默认安装至\e[36m/opt/$name\e[0m"
echo -e "其它架构的Linux系统请前往官网下载对应程序!"
echo -e "============================================"
echo -e "请选择你要使用的功能:"
echo -e " 1. 安装$name"
echo -e " 2. 卸载$name"
echo -e " 3. 修改账号,密码,端口号"
read -p "输入数字以执行(1-3): " number
case $number in
1)
	install
;;
2)
	uninstall
;;
3)
	change_idpw
;;
*)
	echo -e "$info 请输入正确的数字!"
	exit 1
;;
esac
exit 0
