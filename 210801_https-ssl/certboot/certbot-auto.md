# Certbot-auto生成ssl证书

## 先决条件

1、拥有一个域名，例如 mydomain.com
2、在域名服务器创建一条A记录，指向云主机的公网IP地址。例如 demo.mydomain.com 指向 192.168.0.1 的IP地址
3、要等到新创建的域名解析能在公网上被解析到

## 安装 Certbot

前往 [Certbot 官网](https://blog.hlogc.com/wp-content/themes/begin5.2/inc/go.php?url=https://certbot.eff.org/)按照步骤安装 certbot

![img](https://upload-images.jianshu.io/upload_images/3551539-2287f2c0cb3901f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/939/format/webp)

Certbot

或者直接获取自动安装脚本，然后在按如下两种模式生成证书

```
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto # 给脚本执行权限
```

## Certbot 两种生成证书的方式

### certbot 模式（推荐）

certbot 会启动自带的 nginx（如果服务器上已经有nginx或apache运行，需要停止已有的nginx或apache，因为安装过程中可能需要用到80端口做校验）生成证书

首先，删除旧的证书文件（如果存在 /etc/letsencrypt/live/xxx.xxx.com/）

```
rm -rf /etc/letsencrypt/live/xxx.xxx.com/
```

执行

```
./certbot-auto certonly --standalone -d example.com -d www.example.com
```

或者

```
./certbot-auto certonly --standalone -d www.example.com
```

### webroot 模式

1、配置验证目录

```
server {
  listen 80;
  server_name 127.0.0.1;
  location / {
    root   /var/www/example;
    index  index.html;
  }
}
```

2、重启 nginx

```
nginx -t // 检查nginx配置文件是否正确
nginx -s reload // 使配置生效
service nginx restart // 重启 nginx
```

3、执行 certbot 脚本生成证书

```
certbot certonly --webroot -w /var/www/example/ -d www.example.com -d example.com -w /var/www/other -d other.example.net -d another.other.example.net
```

certbot会生成随机文件到给定目录(nginx配置的网页目录)下的/.well-known/acme-challenge/目录里面，并通过已经启动的nginx验证随机文件，生成证书

### 证书应用

通过以上方式生的成证书及 privkey 等文件一般位于 `/etc/letsencrypt/live/example.com/` 下：

| 文件          | 描述                                                |
| :------------ | :-------------------------------------------------- |
| cert.pem      | 服务器证书                                          |
| chain.pem     | 包含Web浏览器为验证服务器而需要的证书或附加中间证书 |
| fullchain.pem | cert.pem+chain.pem                                  |
| privkey.pem   | 证书的私钥                                          |

### 在 Nginx 使用证书

在 `sites-available/default` 中的 `server` 节点下添加：

```
listen 443 ssl;
listen [::]:443 ssl;
ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
```

### 续期

```
certbot renew --dry-run
```

