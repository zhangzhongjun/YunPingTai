0. VT-x or AMD-v virtualization must be enabled in your computer’s BIOS
1. 安装虚拟机( Virtualbox xhyve VMWare)
```bash
sudo apt-get install virtualbox
```
3. 安装kubectl命令行工具
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
```
4. 安装minikube命令行工具
```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.23.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```
5. 运行minikube start
6. 完成