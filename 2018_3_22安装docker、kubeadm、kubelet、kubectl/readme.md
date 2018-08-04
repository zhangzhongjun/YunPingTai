# 安装docker、kubeadm、kubelet、kubectl
> 今日任务：为所有的结点安装docker、kubeadm、kubelet、kubectl

## Installing docker
```cmd
[root@masterNode ~]# yum install -y docker
```

## 开启docker的服务
```cmd
[root@masterNode ~]# systemctl enable docker && systemctl start docker
```

## Installing kubeadm, kubelet and kubectl
kubeadm 是Kubernetes官方推出的快速部署Kubernetes集群工具，其思路是将Kubernetes相关服务容器化(Kubernetes静态Pod)以简化部署
kubelet 是
kubectl 是管理集群的命令
### 更改/etc/yum.repos.d/kubernetes.repo，配置到阿里云的yum源
```bash
# 下面这句话的意思是，向kubernentes.repo中写入内容，（删除原始内容），并在输入EOF之后停止
[root@masterNode ~]# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
> [kubernetes]
> name=Kubernetes
> baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
> enabled=1
> gpgcheck=1
> repo_gpgcheck=1
> gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
> EOF
```

### 关闭防火墙、安装kubelet kubeadm kubectl、开启kubelet服务
```cmd
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
```

## seting network
设定/etc/sysctl.d/k8s.conf的系统参数
```cmd
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```
从文件中加载系统参数
```cmd
sysctl --system
```

## 在master node上使用kubelet配置cgroup驱动

### 查询Cgroup Driver
```cmd
[root@masterNode ~]# docker info | grep -i cgroup
```
Output: 
```cmd
WARNING: You're not using the default seccomp profile
<u>Cgroup Driver: systemd</u>
```

### 检查配置文件，要求第11行要和上面的下划线的部分保持一致
```cmd
[root@masterNode ~]# cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

```cmd
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local"
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=0"
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true --cert-dir=/var/lib/kubelet/pki"
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CGROUP_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS
```
如果不一致的话需要执行
```cmd
sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet
```
## 使用脚本文件
```cmd
curl https://raw.githubusercontent.com/RuiYunLab/YunPingTai/master/2018_3_22/3_22.sh?token=AgSLI3ojhINsCOwpE86RQcq6mCfK_tpLks5avO3DwA%3D%3D -o /root/3_22.sh
```
```cmd
chmod +x ./3_22.sh
```
```cmd
./3_22.sh
```