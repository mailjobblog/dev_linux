# acme申请ssl证书

这个方法简单粗暴，屡试不爽，博主推荐。本博客上一篇文章的另外一个方法----[CentOS安装使用certbot申请Let’s Encrypt 通配符证书](https://blog.hlogc.com/2019/07/19/centos-apply-lets-encrypt-wild-card-ssl-via-certbot/)---有点繁琐。

Let's Encrypt 发布的 ACME v2 现已正式支持通配符证书，接下来将为大家介绍怎样申请，Let's go.

注 本教程是在centos 7下操作的，其他Linux系统大同小异。

2018.03.15 20:48 更新了通过`acme.sh`方式获取证书的方法，墙裂推荐这种方法
2018.08.13 18:30 增加可通过docker镜像获取证书的方法

## 一、`acme.sh`的方式

### 1.获取`acme.sh`

```
curl https://get.acme.sh | sh
```

如下所示安装成功

![image](https://static.oschina.net/uploads/img/201803/15205059_CCQX.png)

注：我在centos 7上遇到问题，安装完后执行`acme.sh`，提示命令没找到，如果遇到跟我一样的问题，请关掉终端然后再登陆，或者执行以下指令：

```
source ~/.bashrc
```

### 2.开始获取证书

`acme.sh`强大之处在于，可以自动配置DNS，不用去域名后台操作解析记录了，我的域名是在阿里注册的，下面给出阿里云解析的例子，其他地方注册的请参考这里自行修改：[传送门](https://blog.hlogc.com/wp-content/themes/begin5.2/inc/go.php?url=https://github.com/Neilpang/acme.sh/wiki/How-to-issue-a-cert)，各个域名注册商的key和id请看[这里](https://blog.hlogc.com/wp-content/themes/begin5.2/inc/go.php?url=https://github.com/Neilpang/acme.sh/wiki/dnsapi)。

请先前往阿里云后台获取`App_Key`跟`App_Secret` [传送门](https://blog.hlogc.com/wp-content/themes/begin5.2/inc/go.php?url=https://ak-console.aliyun.com/#/accesskey)，然后执行以下脚本

```
# 替换成从阿里云后台获取的密钥
export Ali_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
export Ali_Secret="jlsdflanljkljlfdsaklkjflsa"
# 换成自己的域名
acme.sh --issue --dns dns_ali -d zhuziyu.cn -d *.zhuziyu.cn
```

这里是通过线程休眠120秒等待DNS生效的方式，所以至少需要等待两分钟

![image](https://static.oschina.net/uploads/img/201803/15205848_JoPT.png)

到了这一步大功告成，撒花

生成的证书放在该目录下: `~/acme.sh/domain/`

下面是一个Nginx应用该证书的例子:

```
# domain自行替换成自己的域名
server {
    server_name xx.domain.com;
    listen 443 http2 ssl;
    ssl_certificate /path/.acme.sh/domain/fullchain.cer;
    ssl_certificate_key /path/.acme.sh/domain/domain.key;
    ssl_trusted_certificate  /path/.acme.sh/domain/ca.cer;

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:10086;
    }
}
```

`acme.sh`比`certbot`的方式更加自动化，省去了手动去域名后台改DNS记录的步骤，而且不用依赖Python，墙裂推荐

第一次成功之后，`acme.sh`会记录下App_Key跟App_Secret，并且生成一个定时任务，每天凌晨0：00自动检测过期域名并且自动续期。对这种方式有顾虑的，请慎重，不过也可以自行删掉用户级的定时任务，并且清理掉~/.acme.sh文件夹就行

## 二、 docker 镜像获取

如果装有docker环境的话，也可以用docker镜像来获取证书，只需一行命令即可

```
docker run --rm  -it  \
  -v "$(pwd)/out":/acme.sh  \
  -e Ali_Key="xxxxxx" \
  -e Ali_Secret="xxxx" \
  neilpang/acme.sh  --issue --dns dns_ali -d domain.cn -d *.domain.cn
```

成功之后，证书会保存在当前目录下的out文件夹，也可以指定路径，修改上面第一行 `"$(pwd)/out"`，改为你想要保存的路径即可。

详细用法，可以参考：[传送门](https://blog.hlogc.com/wp-content/themes/begin5.2/inc/go.php?url=https://github.com/Neilpang/acme.sh/wiki/Run-acme.sh-in-docker)

获取下来的证书跟方式一 获取的一模一样，其他信息请参考方式一。

## 三、 `certbot`方式获取证书`[不推荐]`

### 1.获取`certbot-auto`

```
# 下载
wget https://dl.eff.org/certbot-auto

# 设为可执行权限
chmod a+x certbot-auto
```

### 2.开始申请证书

```
# 注xxx.com请根据自己的域名自行更改
./certbot-auto --server https://acme-v02.api.letsencrypt.org/directory -d "*.xxx.com" --manual --preferred-challenges dns-01 certonly
```

执行完这一步之后，会下载一些需要的依赖，稍等片刻之后，会提示输入邮箱，随便输入都行【该邮箱用于安全提醒以及续期提醒】

![image](https://static.oschina.net/uploads/img/201803/14144603_4ezr.png)

注意，申请通配符证书是要经过DNS认证的，按照提示，前往域名后台添加对应的DNS TXT记录。添加之后，不要心急着按回车，先执行`dig xxxx.xxx.com txt`确认解析记录是否生效，生效之后再回去按回车确认

![image](https://static.oschina.net/uploads/img/201803/14144824_vKdF.png)

到了这一步后，大功告成！！！ 证书存放在/etc/letsencrypt/live/xxx.com/里面

要续期的话，执行`certbot-auto renew`就可以了

![image](https://static.oschina.net/uploads/img/201803/14144952_1Soy.png)

注：经评论区 ddatsh 的指点，这样的证书无法应用到主域名`xxx.com`上，如需把主域名也增加到证书的覆盖范围，请在开始申请证书步骤的那个指令把主域名也加上，如下： 需要注意的是，这样的话需要修改两次解析记录

```
./certbot-auto --server https://acme-v02.api.letsencrypt.org/directory -d "*.xxx.com" -d "xxx.com" --manual --preferred-challenges dns-01 certonly
```

![image](https://static.oschina.net/uploads/img/201803/15095409_uiHL.png)

下面是一个nginx应用该证书的一个例子

```
server {
    server_name xxx.com;
    listen 443 http2 ssl;
    ssl on;
    ssl_certificate /etc/cert/xxx.cn/fullchain.pem;
    ssl_certificate_key /etc/cert/xxx.cn/privkey.pem;
    ssl_trusted_certificate  /etc/cert/xxx.cn/chain.pem;

    location / {
      proxy_pass http://127.0.0.1:6666;
    }
}
```

