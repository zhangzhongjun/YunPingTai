#!/bin/sh
yum install -y docker
systemctl enable docker && systemctl start docker
curl https://raw.githubusercontent.com/RuiYunLab/YunPingTai/master/2018_3_22/kubernetes.repo?token=AgSLI5x2PzIeyBFOrqJriv55HWyRS5Bfks5avNtLwA%3D%3D -o /etc/yum.repos.d/kubernetes.repo
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
curl https://raw.githubusercontent.com/RuiYunLab/YunPingTai/master/2018_3_22/k8s.conf?token=AgSLIxGFUELN971GR0jBl0XuvnyY-AYgks5avNz1wA%3D%3D -o /etc/sysctl.d/k8s.conf
sysctl --system
docker info | grep -i cgroup
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf