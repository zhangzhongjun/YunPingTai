#!/bin/bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl https://raw.githubusercontent.com/RuiYunLab/YunPingTai/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo
sudo yum makecache
yum -y install vim