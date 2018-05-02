
* [部署K8S](#部署K8S)

	* [环境说明](#环境说明)

	* [安装配置etcd](#安装配置etcd)

		* [etcd安装](#etcd安装)

		* [创建etcd证书](#创建etcd证书)

		* [生成etcd密钥](#生成etcd密钥)

		* [修改 etcd配置](#修改-etcd配置)

		* [启动 etcd](#启动-etcd)

		* [验证 etcd 集群状态](#验证-etcd-集群状态)

	* [配置 Flannel 网络](#配置-Flannel-网络)

		* [安装&配置 Flannel](#安装&配置-Flannel)

		* [配置 Flannel](#配置-Flannel)

		* [启动 flannel](#启动-flannel)

		* [查看 flannel 验证网络](#查看-flannel-验证网络)

	* [配置 Kubernetes 集群](#配置-Kubernetes-集群)

		* [组件安装](#组件安装)

		* [创建admin证书](#创建admin证书)

		* [配置 kubectl kubeconfig 文件](#配置-kubectl-kubeconfig-文件)

		* [创建 kubernetes 证书](#创建-kubernetes-证书)

		* [生成 kubernetes 证书和私钥](#生成-kubernetes-证书和私钥)

		* [配置 kube-apiserver](#配置-kube-apiserver)

		* [启动 kube-apiserver](#启动-kube-apiserver)

		* [配置 kube-controller-manager](#配置-kube-controller-manager)

		* [启动 kube-controller-manager](#启动-kube-controller-manager)

		* [配置 kube-scheduler](#配置-kube-scheduler)

		* [启动 kube-scheduler](#启动-kube-scheduler)

		* [配置 kubelet](#配置-kubelet)

		* [配置 kube-proxy](#配置-kube-proxy)

		* [生成 kube-proxy 证书和私钥](#生成-kube-proxy-证书和私钥)

		* [创建 kube-proxy kubeconfig 文件](#创建-kube-proxy-kubeconfig-文件)

		* [创建 kube-proxy.service 文件](#创建-kube-proxy.service-文件)

		* [启动 kube-proxy](#启动-kube-proxy)

		* [Node 端配置——Nginx](#Node-端配置——Nginx)

	* [安装docker](#安装docker)

	* [配置CoreDNS](#配置CoreDNS)

		* [下载yaml文件](#下载yaml文件)

		* [导入yaml文件](#导入yaml文件)

		* [查看kubedns服务](#查看kubedns服务)

	* [部署harbor私有仓库](#部署harbor私有仓库)

		* [下载文件](#下载文件)

		* [导入 docker images](#导入-docker-images)

		* [修改 harbor.cfg 文件](#修改-harbor.cfg-文件)

		* [加载和启动 harbor 镜像](#加载和启动-harbor-镜像)
# 部署K8S

* [环境说明](#环境说明)
* [安装配置etcd](#安装配置etcd)
  * [etcd安装](#etcd安装)


## 环境说明
masternode：192.168.12.1
pods：192.168.12.101-109
```bash
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
## 安装配置etcd
### etcd安装
```bash
wget https://github.com/coreos/etcd/releases/download/v3.2.11/etcd-v3.2.11-linux-amd64.tar.gz
tar zxvf etcd-v3.2.11-linux-amd64.tar.gz
cd etcd-v3.2.11-linux-amd64
mv etcd  etcdctl /usr/bin/
```
### 创建etcd证书
```bash
cd /opt/ssl/
vi etcd-csr.json
{
    "CN": "smartCloud",
    "hosts": [
        "127.0.0.1",
        "192.168.12.1",
        "192.168.12.101",
        "192.168.12.102",
        "192.168.12.103",
        "192.168.12.104",
        "192.168.12.105",
        "192.168.12.106",
        "192.168.12.107",
        "192.168.12.108",
        "192.168.12.109"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shaanxi",
            "ST": "Xi'an",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
```
### 生成etcd密钥
```bash
# 生成密钥
/opt/local/cfssl/cfssl gencert -ca=/opt/ssl/ca.pem \
  -ca-key=/opt/ssl/ca-key.pem \
  -config=/opt/ssl/config.json \
  -profile=kubernetes etcd-csr.json | /opt/local/cfssl/cfssljson -bare etcd
```
```bash
# 查看生成
ls etcd*
etcd.csr  etcd-csr.json  etcd-kay.pem  etcd.pem
```
```bash
# 拷贝到etcd服务器
cp etcd*.pem /etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.101:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.102:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.103:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.104:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.105:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.106:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.107:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.108:/etc/kubernetes/ssl/
scp etcd*.pem 192.168.12.109:/etc/kubernetes/ssl/
```
### 修改 etcd配置
```bash
# 部署在所有主机上
# 授予修改权限
useradd etcd
mkdir -p /opt/etcd
chown -R etcd:etcd /opt/etcd
```

```bash
# etcd-1
cd /usr/lib/systemd/system
vi etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
User=etcd
# set GOMAXPROCS to number of processors
ExecStart=/usr/bin/etcd \
  --name=etcd1 \
  --cert-file=/etc/kubernetes/ssl/etcd.pem \
  --key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --peer-cert-file=/etc/kubernetes/ssl/etcd.pem \
  --peer-key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls=https://192.168.12.1:2380 \
  --listen-peer-urls=https://192.168.12.1:2380 \
  --listen-client-urls=https://192.168.12.1:2379,http://127.0.0.1:2379 \
  --advertise-client-urls=https://192.168.12.1:2379 \
  --initial-cluster-token=k8s-etcd-cluster \
  --initial-cluster=etcd1=https://192.168.12.1:2380,etcd2=https://192.168.12.101:2380,etcd3=https://192.168.12.102:2380,etcd4=https://192.168.12.103:2380,etcd5=https://192.168.12.104:2380,etcd6=https://192.168.12.105:2380,etcd7=https://192.168.12.106:2380,etcd8=https://192.168.12.107:2380,etcd9=https://192.168.12.108:2380,etcd10=https://192.168.12.109:2380 \
  --initial-cluster-state=new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```
```bash
# etcd-2
cd /usr/lib/systemd/system
vi etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
User=etcd
# set GOMAXPROCS to number of processors
ExecStart=/usr/bin/etcd \
  --name=etcd2 \
  --cert-file=/etc/kubernetes/ssl/etcd.pem \
  --key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --peer-cert-file=/etc/kubernetes/ssl/etcd.pem \
  --peer-key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls=https://192.168.12.101:2380 \
  --listen-peer-urls=https://192.168.12.101:2380 \
  --listen-client-urls=https://192.168.12.101:2379,http://127.0.0.1:2379 \
  --advertise-client-urls=https://192.168.12.101:2379 \
  --initial-cluster-token=k8s-etcd-cluster \
  --initial-cluster=etcd1=https://192.168.12.1:2380,etcd2=https://192.168.12.101:2380,etcd3=https://192.168.12.102:2380,etcd4=https://192.168.12.103:2380,etcd5=https://192.168.12.104:2380,etcd6=https://192.168.12.105:2380,etcd7=https://192.168.12.106:2380,etcd8=https://192.168.12.107:2380,etcd9=https://192.168.12.108:2380,etcd10=https://192.168.12.109:2380 \
  --initial-cluster-state=new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```
```bash
# etc3-etc10 以此类推
```
### 启动 etcd
```bash
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
systemctl status etcd
```
### 验证 etcd 集群状态
```bash
etcdctl --endpoints= https://192.168.12.101:2379,https://192.168.12.101:2379,https://192.168.12.102:2379,https://192.168.12.103:2379,https://192.168.12.104:2379,https://192.168.12.105:2379,https://192.168.12.106:2379,https://192.168.12.107:2379, https://192.168.12.108:2379,https://192.168.12.109:2379\
--cert-file=/etc/kubernetes/ssl/etcd.pem \
--ca-file=/etc/kubernetes/ssl/ca.pem \
--key-file=/etc/kubernetes/ssl/etcd-key.pem \
cluster-health
```
## 配置 Flannel 网络
kubernetes 要求集群内各节点能通过 Pod 网段互联互通，本章节介绍使用 Flannel 在所有节点 (Master、Node) 上创建互联互通的 Pod 网段的步骤。

### 安装&配置 Flannel 
```bash
rpm -ivh flannel-0.9.1-1.x86_64.rpm
# 或
mkdir flannel
wget https://github.com/coreos/flannel/releases/download/v0.7.1/flannel-v0.7.1-linux-amd64.tar.gz
tar -xzvf flannel-v0.7.1-linux-amd64.tar.gz -C flannel
sudo cp flannel/{flanneld,mk-docker-opts.sh} /root/local/bin
```
### 配置 Flannel

```bash
# 配置 flannel， 由于我们docker更改了 docker.service.d 的路径， 所以这里把 flannel.conf 的配置拷贝到 这个目录去
mv /usr/lib/systemd/system/docker.service.d/flannel.conf /etc/systemd/system/docker.service.d
```
```bash
# 配置 flannel 网段
etcdctl --endpoints= https://192.168.12.101:2379,https://192.168.12.101:2379,https://192.168.12.102:2379,https://192.168.12.103:2379,https://192.168.12.104:2379,https://192.168.12.105:2379,https://192.168.12.106:2379,https://192.168.12.107:2379, https://192.168.12.108:2379,https://192.168.12.109:2379\
        --cert-file=/etc/kubernetes/ssl/etcd.pem \
        --ca-file=/etc/kubernetes/ssl/ca.pem \
        --key-file=/etc/kubernetes/ssl/etcd-key.pem \
        set /flannel/network/config \ '{"Network":"10.254.64.0/18","SubnetLen":24,"Backend":{"Type":"host-gw"}}'
```
```bash
# 修改 flanneld 配置
vi /etc/sysconfig/flannel
# Flanneld configuration options
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://127.0.0.1:2379"
# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/atomic.io/network"
# Any additional options that you want to pass
#FLANNEL_OPTIONS=""
```
```bash
# etcd 地址
FLANNEL_ETCD_ENDPOINTS=" https://192.168.12.101:2379,https://192.168.12.101:2379,https://192.168.12.102:2379,https://192.168.12.103:2379,https://192.168.12.104:2379,https://192.168.12.105:2379,https://192.168.12.106:2379,https://192.168.12.107:2379, https://192.168.12.108:2379,https://192.168.12.109:2379"
```
```bash
# 配置为上面的路径 flannel/network
FLANNEL_ETCD_PREFIX="/flannel/network"
```
### 启动 flannel

```bash
# 启动 flannel 
systemctl daemon-reload
systemctl enable flanneld
systemctl start flanneld
systemctl status flannel
```
```bash
# 重启 kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
```
### 查看 flannel 验证网络
```bash
 ifconfig
 #查看  docker0 网络 是否已经更改为配置IP网段
 flannel.1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 172.30.34.0  netmask 255.255.255.255  broadcast 0.0.0.0
        inet6 fe80::e822:38ff:fea1:948b  prefixlen 64  scopeid 0x20<link>
        ether ea:22:38:a1:94:8b  txqueuelen 0  (Ethernet)
        RX packets 140927  bytes 41745995 (39.8 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 293588  bytes 35318099 (33.6 MiB)
        TX errors 0  dropped 39042 overruns 0  carrier 0  collisions 0
```
```bash
# 测试集群
kubectl get pods -o wide
kubectl get svc -o wide 
```
## 配置 Kubernetes 集群
*  kubectl 安装在所有需要进行操作的机器上
   Master 需要部署 kube-apiserver , kube-scheduler , kube-controller-manager 这三个组件。 
   	kube-scheduler 作用是调度pods分配到那个node里，简单来说就是资源调度。 
   	同时只能有一个 kube-scheduler、kube-controller-manager 进程处于工作状态，如果运行多个，则需要通过选举产生一个 leader；
   	kube-controller-manager 作用是 对 deployment controller , replication controller, endpoints controller, namespace controller, and serviceaccounts controller等等的循环控制，与kube-apiserver交互。
###  组件安装
```bash
cd /tmp
wget https://dl.k8s.io/v1.9.0/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl} /usr/local/bin/
scp server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet} 192.168.12.1:/usr/local/bin/
scp server/bin/{kube-proxy,kubelet} 192.168.12.101:/usr/local/bin/
```
### 创建admin证书
```bash
cd /opt/ssl/
vi admin-csr.json
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shaanxi",
      "L": "Xi'an",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
```
```bash
# 生成 admin 证书和私钥
cd /opt/ssl/
/opt/local/cfssl/cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/opt/ssl/config.json \
  -profile=kubernetes admin-csr.json | /opt/local/cfssl/cfssljson -bare admin
```
```bash
# 查看生成
ls admin*
admin.csr  admin-csr.json  admin-key.pem  admin.pem
cp admin*.pem /etc/kubernetes/ssl/
scp admin*.pem 192.168.12.1:/etc/kubernetes/ssl/
```
### 配置 kubectl kubeconfig 文件
```bash
# 配置 kubernetes 集群
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443
```
```bash
# 配置 客户端认证
kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/admin-key.pem
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin
kubectl config use-context kubernetes
```
###  创建 kubernetes 证书
```bash
# 这里 hosts 字段中 三个 IP 分别为 127.0.0.1 本机， 192.168.12.1为 Master 的IP，多个Master需要写多个。10.254.0.1 为 kubernetes SVC 的 IP， 一般是 部署网络的第一个IP , 如: 10.254.0.1 ， 在启动完成后，我们使用   kubectl get svc ， 就可以查看到
cd /opt/ssl
vi kubernetes-csr.json
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "192.168.12.1",
    "10.254.0.1",
    "kubernetes",
    "k8s-api.virtual.local",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shaanxi",
      "L": "Xi'an",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
```
### 生成 kubernetes 证书和私钥
```bash
/opt/local/cfssl/cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/opt/ssl/config.json \
  -profile=kubernetes kubernetes-csr.json | /opt/local/cfssl/cfssljson -bare kubernetes
```
```bash
# 查看生成
ls -lt kubernetes*
-rw-r--r-- 1 root root 1273 Apr 15 19:12 kubernetes.csr
-rw------- 1 root root 1675 Apr 15 19:12 kubernetes-key.pem
-rw-r--r-- 1 root root 1639 Apr 15 19:12 kubernetes.pem
-rw-r--r-- 1 root root  463 Mar 28 16:17 kubernetes-csr.json
```
```bash
# 拷贝到目录
cp kubernetes*.pem /etc/kubernetes/ssl/
scp kubernetes*.pem 192.168.12.1:/etc/kubernetes/ssl/
```
### 配置 kube-apiserver
```bash
# 自定义 系统 service 文件一般存于 /etc/systemd/system/ 下
# 配置为 各自的本地 IP

vi /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
User=root
ExecStart=/usr/bin/kube-apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota,NodeRestriction \
  --advertise-address=192.168.12.1 \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-policy-file=/etc/kubernetes/audit-policy.yaml \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/kubernetes/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=192.168.12.1 \
  --secure-port=6443 \
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --enable-swagger-ui=true \
  --etcd-cafile=/etc/kubernetes/ssl/ca.pem \
  --etcd-certfile=/etc/kubernetes/ssl/etcd.pem \
  --etcd-keyfile=/etc/kubernetes/ssl/etcd-key.pem \
  --etcd-servers=https://192.168.12.1:2379,https://192.168.12.101:2379, https://192.168.12.102:2379, https://192.168.12.103:2379, https://192.168.12.104:2379, https://192.168.12.105:2379, https://192.168.12.106:2379, https://192.168.12.107:2379, https://192.168.12.108:2379, https://192.168.12.109:2379 \
  --event-ttl=1h \
  --kubelet-https=true \
  --insecure-bind-address=192.168.12.1 \
  --insecure-port=8080 \
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-cluster-ip-range=10.254.0.0/18 \
  --service-node-port-range=30000-32000 \
  --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  --enable-bootstrap-token-auth \
  --token-auth-file=/etc/kubernetes/token.csv \
  --v=2
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

```
### 启动 kube-apiserver
```bash
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
systemctl status kube-apiserver
```
### 配置 kube-controller-manager
```bash
# 创建 kube-controller-manager.service 文件
vi /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-controller-manager \
  --address=127.0.0.1 \
  --master=http://192.168.12.1:8080 \
  --allocate-node-cidrs=true \
  --service-cluster-ip-range=10.254.0.0/16 \
  --cluster-cidr=170.30.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \
  --leader-elect=true \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
### 启动 kube-controller-manager
```bash
systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl start kube-controller-manager
systemctl status kube-controller-manager
```
### 配置 kube-scheduler
```bash
# 创建 kube-cheduler.service 文件
vi /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
[Service]
ExecStart=/usr/bin/kube-scheduler \
  --address=127.0.0.1 \
  --master=http://192.168.12.1:8080 \
  --leader-elect=true \
  --v=2
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
```
### 启动 kube-scheduler
```bash
systemctl daemon-reload
systemctl enable kube-scheduler
systemctl start kube-scheduler
systemctl status kube-scheduler
```
```bash
# 验证Master节点
kubectl get componentstatuses
```
### 配置 kubelet
```bash 
#部署节点
#先创建认证请求 只需创建一次就可以
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
```
```bash
# 配置集群
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=https://192.168.12.1:6443 \
  --kubeconfig=bootstrap.kubeconfig
```
```bash
# 配置客户端认证
kubectl config set-credentials kubelet-bootstrap \
  --token=d2d7f3a19490ff667fbe94b0f31f9967 \
  --kubeconfig=bootstrap.kubeconfig
```
```bash
# 配置关联
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig
```
```bash
# 配置默认关联
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
```
```bash
# 拷贝生成的 bootstrap.kubeconfig 文件
mv bootstrap.kubeconfig /etc/kubernetes/
```
```bash
# 创建 kubelet 目录，配置为 node 本机 IP
mkdir /var/lib/kubelet
vi /etc/systemd/system/kubelet.service

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
ExecStart=/usr/local/bin/kubelet \
  --cgroup-driver=cgroupfs \
  --hostname-override=pod \
  --pod-infra-container-image=jicki/pause-amd64:3.0 \
  --experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --cert-dir=/etc/kubernetes/ssl \
  --cluster_dns=10.254.0.2 \
  --cluster_domain=cluster.local. \
  --hairpin-mode promiscuous-bridge \
  --allow-privileged=true \
  --fail-swap-on=false \
  --serialize-image-pulls=false \
  --logtostderr=true \
  --max-pods=512 \
  --v=2

[Install]
WantedBy=multi-user.target
```
```bash
# 启动 kubelet
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet
```
```bash
# 查看 csr 的名称
kubectl get csr
```
```bash
# 增加 认证
kubectl get csr | grep Pending | awk '{print $1}' | xargs kubectl certificate approve
```
```bash
# 验证 nodes
kubectl get nodes
```
### 配置 kube-proxy
```bash
# 创建 kube-proxy 证书
cd /opt/ssl
vi kube-proxy-csr.json
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shaanxi",
      "L": "Xi'an",
      "O": "k8s",
      "OU": "System"
    }
  ]
} 
```
### 生成 kube-proxy 证书和私钥
```bash
/opt/local/cfssl/cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/opt/ssl/config.json \
  -profile=kubernetes  kube-proxy-csr.json | /opt/local/cfssl/cfssljson -bare kube-proxy
```
```bash
# 查看生成
ls kube-proxy*
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem
```
```bash
# 拷贝到目录
scp kube-proxy*.pem 192.168.12.101:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.102:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.103:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.104:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.105:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.106:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.107:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.108:/etc/kubernetes/ssl/
scp kube-proxy*.pem 192.168.12.109:/etc/kubernetes/ssl/
```
### 创建 kube-proxy kubeconfig 文件
```bash
# 配置集群
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-proxy.kubeconfig
```
```bash
# 配置客户端认证
kubectl config set-credentials kube-proxy \
  --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
  --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
```
```bash
# 配置关联
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
```
```bash
# 配置默认关联
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
```
```bash
# 拷贝到需要的 node 端里
scp kube-proxy.kubeconfig 192.168.12.101:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.102:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.103:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.104:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.105:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.106:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.107:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.108:/etc/kubernetes/
scp kube-proxy.kubeconfig 192.168.12.109:/etc/kubernetes/
```
### 创建 kube-proxy.service 文件
```bash
# 创建 kube-proxy 目录
mkdir -p /var/lib/kube-proxy
vi /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/usr/local/bin/kube-proxy \
  --bind-address=192.168.12.101 \
  --hostname-override=pod2 \
  --cluster-cidr=10.254.64.0/16 \
  --masquerade-all \
  --feature-gates=SupportIPVSProxyMode=true \
  --proxy-mode=ipvs \
  --ipvs-min-sync-period=5s \
  --ipvs-sync-period=5s \
  --ipvs-scheduler=rr \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig \
  --logtostderr=true \
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```
### 启动 kube-proxy
```bash
systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
systemctl status kube-proxy
```
```bash
# 检查  ipvs
ipvsadm -L -n
```
### Node 端配置——Nginx
单 Node 部分 需要部署的组件有 docker calico kubelet kube-proxy 这几个组件。 Node 节点 基于 Nginx 负载 API 做 Master HA
```
# 发布证书 ALL node
mkdir -p /etc/kubernetes/ssl/
scp ca.pem kube-proxy.pem kube-proxy-key.pem  node-*:/etc/kubernetes/ssl/
```
```bash
# 创建Nginx 代理
# 创建配置目录
mkdir -p /etc/nginx
# 写入代理配置
cat << EOF >> /etc/nginx/nginx.conf
error_log stderr notice;
worker_processes auto;
events {
  multi_accept on;
  use epoll;
  worker_connections 1024;
}

stream {
    upstream kube_apiserver {
        least_conn;
        server 192.168.12.101:6443;
        server 192.168.12.102:6443;
        server 192.168.12.103:6443;
        server 192.168.12.104:6443;
        server 192.168.12.105:6443;
        server 192.168.12.106:6443;
        server 192.168.12.107:6443;
        server 192.168.12.108:6443;
        server 192.168.12.109:6443;
    }

    server {
        listen        0.0.0.0:6443;
        proxy_pass    kube_apiserver;
        proxy_timeout 10m;
        proxy_connect_timeout 1s;
    }
}
EOF
```
```bash
# 更新权限
chmod +r /etc/nginx/nginx.conf
# 配置 Nginx 基于 docker 进程，然后配置 systemd 来启动
cat << EOF >> /etc/systemd/system/nginx-proxy.service
[Unit]
Description=kubernetes apiserver docker wrapper
Wants=docker.socket
After=docker.service

[Service]
User=root
PermissionsStartOnly=true
ExecStart=/usr/bin/docker run -p 127.0.0.1:6443:6443 \\
                              -v /etc/nginx:/etc/nginx \\
                              --name nginx-proxy \\
                              --net=host \\
                              --restart=on-failure:5 \\
                              --memory=512M \\
                              nginx:1.13.7-alpine
ExecStartPre=-/usr/bin/docker rm -f nginx-proxy
ExecStop=/usr/bin/docker stop nginx-proxy
Restart=always
RestartSec=15s
TimeoutStartSec=30s

[Install]
WantedBy=multi-user.target
EOF
```
```bash
# 启动 Nginx
systemctl daemon-reload
systemctl start nginx-proxy
systemctl enable nginx-proxy
systemctl status nginx-proxy
# 配置Kubelet.service & kube-proxy.service文件（见前）
```

## 安装docker
```bash
# 更改docker配置
vi usr/lib/systemd/system/docker.service
```
```bash
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target firewalld.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
[root@pod ~]# cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target firewalld.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
[root@pod ~]# ^C
[root@pod ~]# cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target firewalld.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target

```

## 配置CoreDNS
### 下载yaml文件
```bash
wget https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml.sed
mv coredns.yaml.sed coredns.yaml
# vi coredns.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes CLUSTER_DOMAIN REVERSE_CIDRS {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        reload
    }
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: "CoreDNS"
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      containers:
      - name: coredns
        image: coredns/coredns:1.1.2
        imagePullPolicy: IfNotPresent
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.254.0.2
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
protocol: TCP
```
### 导入yaml文件
```bash
# kubectl apply -f coredns.yaml 
serviceaccount "coredns" created
clusterrole "system:coredns" created
clusterrolebinding "system:coredns" created
configmap "coredns" created
deployment "coredns" created
service "coredns" created
```
### 查看kubedns服务
```bash
#kubectl get pod,svc -n kube-system
NAME                                       READY     STATUS    RESTARTS   AGE
po/coredns-94cc654d9-rpkvg                 1/1       Running   0          29d
po/heapster-5959dd9c7c-bnxpn               1/1       Running   0          26d
po/kubernetes-dashboard-6f88cd57b5-km642   1/1       Running   0          28d
po/monitoring-grafana-67b48f7f76-sw28r     1/1       Running   0          26d
po/monitoring-influxdb-654455bf5d-fn6zm    1/1       Running   0          26d

NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
svc/coredns                ClusterIP   10.254.0.2      <none>        53/UDP,53/TCP   29d
svc/heapster               ClusterIP   10.254.57.240   <none>        80/TCP          26d
svc/kubernetes-dashboard   ClusterIP   10.254.37.7     <none>        443/TCP         28d
svc/monitoring-grafana     ClusterIP   10.254.58.119   <none>        80/TCP          26d
svc/monitoring-influxdb    ClusterIP   10.254.63.93    <none>        8086/TCP        26d
```
## 部署harbor私有仓库
### 下载文件

```bash
#从 docker compose 发布页面下载最新的 docker-compose 二进制文件
wget https://github.com/docker/compose/releases/download/1.12.0/docker-compose-Linux-x86_64
mv ~/docker-compose-Linux-x86_64 /root/local/bin/docker-compose
chmod a+x  /root/local/bin/docker-compose
export PATH=/root/local/bin:$PATH
#从 harbor 发布页面下载最新的 harbor 离线安装包
wget  --continue https://github.com/vmware/harbor/releases/download/v1.1.0/harbor-offline-installer-v1.1.0.tgz
tar -xzvf harbor-offline-installer-v1.1.0.tgz
cd harbor
```
### 导入 docker images
```bash
#导入离线安装包中 harbor 相关的 docker images：、
docker load -i harbor.v1.1.0.tar.gz
#创建 harbor nginx 服务器使用的 TLS 证书
#创建 harbor 证书签名请求：
$ cat > harbor-csr.json <<EOF
{
  "CN": "harbor",
  "hosts": [
    "127.0.0.1",
    "192.168.12.101",
    "192.168.12.102",
    "192.168.12.103",
    "192.168.12.104",
    "192.168.12.105",
    "192.168.12.106",
    "192.168.12.107",
    "192.168.12.108",
    "192.168.12.109"
    ],

  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
        "C": "CN",
        "L": "Shaanxi",
        "ST": "Xi'an",
        "O": "k8s",
        "OU": "System"
    }
  ]
}
EOF
#hosts 字段指定授权使用该证书的当前部署节点 IP，如果后续使用域名访问 harbor则还需要添加域名；


### 生成 harbor 证书和私钥：
​```bash
cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes harbor-csr.json | cfssljson -bare harbor
ls harbor*
harbor.csr  harbor-csr.json  harbor-key.pem harbor.pem
sudo mkdir -p /etc/harbor/ssl
sudo mv harbor*.pem /etc/harbor/ssl
rm harbor.csr  harbor-csr.json
```
### 修改 harbor.cfg 文件
```bash
diff harbor.cfg.orig harbor.cfg
5c5
< hostname = reg.mydomain.com
---
> hostname = 10.64.3.7
9c9
< ui_url_protocol = http
---
> ui_url_protocol = https
24,25c24,25
< ssl_cert = /data/cert/server.crt
< ssl_cert_key = /data/cert/server.key
---
> ssl_cert = /etc/harbor/ssl/harbor.pem
> ssl_cert_key = /etc/harbor/ssl/harbor-key.pem
```
### 加载和启动 harbor 镜像
```bash
$ ./install.sh
[Step 0]: checking installation environment ...

Note: docker version: 17.04.0

Note: docker-compose version: 1.12.0

[Step 1]: loading Harbor images ...
Loaded image: vmware/harbor-adminserver:v1.1.0
Loaded image: vmware/harbor-ui:v1.1.0
Loaded image: vmware/harbor-log:v1.1.0
Loaded image: vmware/harbor-jobservice:v1.1.0
Loaded image: vmware/registry:photon-2.6.0
Loaded image: vmware/harbor-notary-db:mariadb-10.1.10
Loaded image: vmware/harbor-db:v1.1.0
Loaded image: vmware/nginx:1.11.5-patched
Loaded image: photon:1.0
Loaded image: vmware/notary-photon:server-0.5.0
Loaded image: vmware/notary-photon:signer-0.5.0


[Step 2]: preparing environment ...
Generated and saved secret to file: /data/secretkey
Generated configuration file: ./common/config/nginx/nginx.conf
Generated configuration file: ./common/config/adminserver/env
Generated configuration file: ./common/config/ui/env
Generated configuration file: ./common/config/registry/config.yml
Generated configuration file: ./common/config/db/env
Generated configuration file: ./common/config/jobservice/env
Generated configuration file: ./common/config/jobservice/app.conf
Generated configuration file: ./common/config/ui/app.conf
Generated certificate, key file: ./common/config/ui/private_key.pem, cert file: ./common/config/registry/root.crt
The configuration files are ready, please use docker-compose to start the service.


[Step 3]: checking existing instance of Harbor ...


[Step 4]: starting Harbor ...
Creating network "harbor_harbor" with the default driver
Creating harbor-log
Creating registry
Creating harbor-adminserver
Creating harbor-db
Creating harbor-ui
Creating harbor-jobservice
Creating nginx

✔ ----Harbor has been installed and started successfully.----

Now you should be able to visit the admin portal at https://10.64.3.7.
For more details, please visit https://github.com/vmware/harbor.

```
