# lo

网卡名：lo

功能：用来测试一个网络程序，但又不想让局域网或外网的用户查看到，只能在此台主机上运行和查阅。在这种情况下面需要使用到lo网卡。

# eno1

DEVICE=eth0 #描述网卡对应的设备别名，例如ifcfg-eth0的文件中它为eth0
BOOTPROTO=static #设置网卡获得ip地址的方式，可能的选项为static，dhcp或bootp，分别对应静态指定的 ip地址，通过dhcp协议获得的ip地址，通过bootp协议获得的ip地址
BROADCAST=192.168.0.255 #对应的子网广播地址
HWADDR=00:07:E9:05:E8:B4 #对应的网卡物理地址
IPADDR=12.168.1.2 #如果设置网卡获得 ip地址的方式为静态指定，此字段就指定了网卡对应的ip地址
IPV6INIT=no
IPV6_AUTOCONF=no
NETMASK=255.255.255.0 #网卡对应的网络掩码
NETWORK=192.168.1.0 #网卡对应的网络地址
ONBOOT=yes #系统启动时是否设置此网络接口，设置为yes时，系统启动时激活此设备


