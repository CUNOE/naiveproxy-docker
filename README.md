# NaiveProxy-Docker
## 服务端Server
### Caddyfile
下面是一个简单的Caddyfile配置文件，可以用于NaiveProxy的服务端。
请将`example.com`替换为你的域名，`<user>`和`<pass>`替换为你的NaiveProxy用户名和密码，`me@example.com`替换为你的邮箱。

```shell
vim Caddyfile
```
```Caddyfile
:443, example.com
tls me@example.com
route {
  forward_proxy {
    basic_auth <user> <pass>
    hide_ip
    hide_via
    probe_resistance
  }
  file_server {
    root /var/www/html
  }
}
```

### 通过Docker Run运行
```shell
docker pull cunoe/naiveproxy:server
docker run -d --name naiveproxy-server -p 443:443 -v ./Caddyfile:/app/Caddyfile cunoe/naiveproxy:server
```

### 通过Docker Compose运行
```shell
wget -O docker-compose.yml https://raw.githubusercontent.com/CUNOE/naiveproxy-docker/master/docker-compose-server.yml
docker-compose up -d
```

## 客户端Client

### 通过Docker Run运行
请将`user`和`pass`替换为你的NaiveProxy用户名和密码，`example.com`替换为你的域名。
```shell
docker pull cunoe/naiveproxy:client
docker run -d --name naiveproxy-client -p 1080:1080 -e PROXY_SERVER=https://user:pass@example.com  cunoe/naiveproxy:client
```

### 通过Docker Compose运行
请将`user`和`pass`替换为你的NaiveProxy用户名和密码，`example.com`替换为你的域名。
```shell
wget -O docker-compose.yml https://raw.githubusercontent.com/CUNOE/naiveproxy-docker/master/docker-compose-client.yml
vim docker-compose.yml
docker-compose up -d
```
