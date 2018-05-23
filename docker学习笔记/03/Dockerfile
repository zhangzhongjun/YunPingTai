# 一个复杂的例子 制作ubuntu+java+tomcat+ssh server镜像
# 从哪个镜像开始 一般是ubuntu centos等系统镜像
FROM ubuntu
MAINTAINER yongboy "yongboy@gmail.com"
# 更新源，安装ssh server
RUN echo "deb http://linux.xidian.edu.cn/mirrors/ubuntu/ precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install --reinstall -y openssh-server
RUN mkdir -p /var/run/sshd
#设置root ssh的远程登录密码为123456
RUN echo "root:123456" | chpasswd

RUN apt-get install python-software-properties
# 添加oracle java7源，一次性安装vim wget curl java7 tomcat7等必备软件
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -f -y vim wget curl oracle-java7-installer tomcat7

# 设置JAVA_HOME环境变量
RUN update-alternatives --display java
RUN echo "JAVA_HOME=/usr/lib/jvm/java-7-orcle" > /etc/environment
RUN echo "JAVA_HOME=/usr/lib/jvm/java-7-orcle" > /etc/default/tomcat7

# 容器需要开放SSH 22端口
EXPOSE 22

# 容器需要开放TOMCAT 8080端口
EXPOSE 8080

# 设置tomcat7初始化运行，SSH终端服务器作为后台运行
ENTRYPOINT service tomcat7 start && /usr/sbin/sshd -D