# 睿云云平台

## 网络拓扑图
![网络拓扑图](imgs/网络拓扑图.png)

## 主机名
```bash
[root@hostname ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.12.1 masternode
192.168.12.101 pod1
192.168.12.102 pod2
192.168.12.103 pod3
192.168.12.104 pod4
192.168.12.105 pod5
192.168.12.106 pod6
192.168.12.107 pod7
192.168.12.108 pod8
192.168.12.109 pod9
192.168.12.1 smart.com
```

## 常用命令
1. 登录master node
```bash
ssh root@119.29.7.120 -p 20000
密码是xidian123
```
2. 查看可用的node
```bash
kubectl get nodes
```
3. 登录slave node
```bash
ssh root@192.168.12.101 -p 22
密码是xidian123
```

## 版本
系统版本
```bash
[root@hostname ~]# cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```
docker版本
```bash
[root@hostname ~]# docker version
Client:
 Version:      17.03.2-ce
 API version:  1.27
 Go version:   go1.7.5
 Git commit:   f5ec1e2
 Built:        Tue Jun 27 02:21:36 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.03.2-ce
 API version:  1.27 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   f5ec1e2
 Built:        Tue Jun 27 02:21:36 2017
 OS/Arch:      linux/amd64
 Experimental: false
```

## 参考文献
[主要参考](https://jicki.me/2017/12/20/kubernetes-1.9-ipvs/#%E9%85%8D%E7%BD%AE-kubelet)
[次要参考，安装顺序是这个教程的](https://github.com/opsnull/follow-me-install-kubernetes-cluster)
