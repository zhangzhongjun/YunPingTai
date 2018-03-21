## 2018/3/21
系统是centos7
登录master
```cmd
ssh root@119.29.7.120 -p 20000
密码是xidian123
```
通过master登录其他的节点192.168.12.101-109，命名格式是
* 192.168.12.101 pod
* 192.168.12.102 pod2
* 192.168.12.103 pod3
* 192.168.12.104 pod
```cmd
ssh root@192.168.12.101 -p 22
密码是xidian123
```
断开ssh连接
```cmd
exit
```
### 配置yum源
参考文献：https://linux.xidian.edu.cn/wiki/mirror-help/centos
1. 首先备份 CentOS-Base.repo
```cmd
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
```
2. 下载西电源的配置文件
```cmd
curl https://raw.githubusercontent.com/RuiYunLab/YunPingTai/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo
```
3.运行 sudo yum makecache 生成缓存
```cmd
sudo yum makecache
```
### 安装vim
```cmd
yum -y install vim
```

### 使用脚本
1. 下载sh脚本
```cmd
curl https://raw.githubusercontent.com/RuiYunLab/YunPingTai/master/2018_3_21.sh -o /root/3_21.sh
```
2. 添加权限
```cmd
chmod +x ./3_21.sh
```
3. 运行脚本
```cmd
./3_21.sh
```