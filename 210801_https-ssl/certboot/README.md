# Certbot Let's encrypt

**注：此方式需要你的域名必须可以在公网解析。**

[Let’s Encrypt](https://letsencrypt.org/zh-cn/) 是一个自动签发 https 证书的免费项目
[Certbot](https://certbot.eff.org/)是 [Let’s Encrypt](https://letsencrypt.org/zh-cn/) 官方推荐的证书生成客户端工具。

注：每种操作系统及要绑定证书的网站不同，对应的安装操作可能也有出入，我这里以证书是在centos 7上给nginx使用，若你们的需求和我不一样，可以去[官网查询](https://certbot.eff.org/)安装过程。

## letsencrypt有什么限制

> - 同一个顶级域名下的二级域名，一周做多申请 20 个
> - 一个域名一周最多申请 5 次
> - 1 小时最多允许失败 5 次
> - 请求频率需要小于 20 次/s
> - 一个 ip 3 小时内最多创建 10 个账户
> - 一个账户最多同时存在 300 个 pending 的审核

## 申请证书步骤

### 配置yum

```bash
[root@nginx ~]# yum -y install epel-release 
[root@nginx ~]# yum -y install yum-utils
[root@nginx ~]# yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
```

### 安装certbor

```bash
[root@nginx ~]# yum -y install certbot python2-certbot-nginx

# # 确定已安装
[root@nginx ~]# certbot --version
certbot 1.3.0
```

### 以命令交互方式开始制作证书

```bash
[root@nginx ~]# certbot certonly      # 进入交互模式
Saving debug log to /var/log/letsencrypt/letsencrypt.log
 
How would you like to authenticate with the ACME CA?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: Nginx Web Server plugin (nginx)   # 此方式需要修改配置文件
2: Spin up a temporary webserver (standalone)     # 此方式需要停止服务
3: Place files in webroot directory (webroot)     # 如果需要不影响服务器正常运行的情况下制作证书，可以选择这种方式
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-3] then [enter] (press 'c' to cancel): 1
# 在这里我们输入1，选择为nginx插件
Plugins selected: Authenticator nginx, Installer None
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): xxxxxxxxx@qq.com        # 这里输入你的邮箱账号（只有第一次使用时会出现）
Starting new HTTPS connection (1): acme-v02.api.letsencrypt.org
 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server at
https://acme-v02.api.letsencrypt.org/directory
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(A)gree/(C)ancel: a       # 输入“a”同意(只有第一次使用时会出现)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y          # 输入“y”确认
Starting new HTTPS connection (1): supporters.eff.org
Please enter in your domain name(s) (comma and/or space separated)  (Enter 'c'
to cancel): www.lvjianzhao.top          # 这里输入你的域名
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for www.lvjianzhao.top
nginx: [error] invalid PID number "" in "/run/nginx.pid"
Waiting for verification...
Cleaning up challenges
 
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/www.lvjianzhao.top/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/www.lvjianzhao.top/privkey.pem
   Your cert will expire on 2020-07-18. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:
 
   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
 
 - We were unable to subscribe you the EFF mailing list because your
   e-mail address appears to be invalid. You can try again later by
   visiting https://act.eff.org.
 
 
# 假如你的域名解析没有问题，那么至此就是证书制作成功了。
 
```

## 配置nginx使用生成的证书

```bash
server {
    # ...
    ssl_certificate "/etc/nginx/ssl/www.lvjianzhao.top/fullchain.pem";
    ssl_certificate_key "/etc/nginx/ssl/www.lvjianzhao.top/privkey.pem";
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    # ...
}
```

### 访问测试https是否生效

![2020-04-19_214105](https://gitee.com/lvjianzhao/ray-xsj/raw/master/%E5%B0%8F%E4%B9%A6%E5%8C%A0/2020-04-19_214105.png)

参考博文：[Certbot 自动化生成 https 证书](https://www.jianshu.com/p/6ea81a7b768f)

### 设置自动任务，配置自动续订（防止证书过期）

```bash
[root@nginx nginx]# echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | tee -a /etc/crontab
```



