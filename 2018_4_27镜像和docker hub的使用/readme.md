## 网上的镜像的问题
```bash
# 这个ubuntu是16.04版本的
docker search ubuntu
```
1. 不是使用的西电源
2. 没有预装vi工具
## 制作一个适合自己的ubuntu镜像
### 下载ubuntu
```bash
docker pull ubuntu:latest
```

### 运行ubuntu
```bash
# 运行 请记住container id，这个会用到
docker run -it ubuntu:latest /bin/bash
# 通过源来判断系统的版本
root@44955c7763f3:/# cat /etc/apt/sources.list
# 做好备份
root@44955c7763f3:/# cp /etc/apt/sources.list /etc/apt/sources.list.bak
# 替换为西电源
root@44955c7763f3:/# echo '
deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial main restricted universe multiverse
deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial main restricted universe multiverse

deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-security main restricted universe multiverse

deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-updates main restricted universe multiverse

deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-backports main restricted universe multiverse

deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-proposed main restricted universe multiverse
deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-proposed main restricted universe multiverse' > /etc/apt/sources.list
# 更新源
apt-get update
# 退出container
exit
```

### 将修改之后的镜像commit到本地仓库
```bash
docker commit CONTAINER ID 18835109707/ubuntu
```

### 登录你的docker hub账号
```bash
docker login
```

### push到远程仓库
```bash
docker push 18835109707/ubuntu:latest
```
