# SSH服务


## frpc.ini

```ini
[common]
server_addr = 119.29.7.120
server_port = 10200

[ssh4]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 20000
```

## frps.ini

```ini
[common]
bind_addr = 0.0.0.0
bind_port=10200
```

# http服务

> 应用场景：有时，我们想要将本地的、在NAT网络后面的web服务暴露，以便用您自己的域名进行测试，不幸的是，我们无法将一个域名解析为本地ip。
但是，我们可以使用frp公开http或https服务。

## frpc.ini

```ini
# frpc.ini
[common]
server_addr = 47.93.28.169
server_port = 7000

[web]
type = http
local_port = 80
custom_domains = www.yourdomain.com
```

## frps.ini

```ini
[common] 
bind_port = 7000
vhost_http_port = 8080
```