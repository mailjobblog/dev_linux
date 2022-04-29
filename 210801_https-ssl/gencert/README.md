# gencert ssl证书生成

## 说明

- 该 sheel 脚本生成 ssl 证书，并且生成的证书可以用于 https 请求
- 该脚本生成证书实际使用的是 [openssl](https://www.openssl.org) 生成证书的方式
- 证书存在的问题：**若不将root.crt导入到client的浏览器，https访问时会提示不安全**

## 创建步骤

创建自签名证书需要安装openssl，使用以下步骤：

- 创建Key；
- 创建签名请求；
- 将Key的口令移除；
- 用Key签名证书。

## 步骤说明

为HTTPS准备的证书需要注意，创建的签名请求的CN必须与域名完全一致，否则无法通过浏览器验证。  
运行脚本，假设你的域名是www.test.com，那么按照提示输入：

```bash
$ ./gencert.sh 
Enter your domain [www.example.com]: www.test.com          
Create server key...
Generating RSA private key, 1024 bit long modulus
.................++++++
.....++++++
e is 65537 (0x10001)
Enter pass phrase for www.test.com.key:输入口令
Verifying - Enter pass phrase for www.test.com.key:输入口令
Create server certificate signing request...
Enter pass phrase for www.test.com.key:输入口令
Remove password...
Enter pass phrase for www.test.com.origin.key:输入口令
writing RSA key
Sign SSL certificate...
Signature ok
subject=/C=US/ST=Mars/L=iTranswarp/O=iTranswarp/OU=iTranswarp/CN=www.test.com
Getting Private key
TODO:
Copy www.test.com.crt to ../ssl/www.test.com.crt
Copy www.test.com.key to ../ssl/www.test.com.key
Add configuration in nginx:
server {
    ...
    ssl on;
    ssl_certificate     ../ssl/www.test.com.crt;
    ssl_certificate_key ../ssl/www.test.com.key;
}
```

输入口令 部分是输入，注意4次输入的口令都是一样的。

在当前目录下会创建出4个文件：

- www.test.com.crt：自签名的证书
- www.test.com.csr：证书的请求
- www.test.com.key：不带口令的Key
- www.test.com.origin.key：带口令的Key

Web服务器需要把 www.test.com.crt 发给浏览器验证，然后用 www.test.com.key 解密浏览器发送的数据，剩下两个文件不需要上传到Web服务器上。

以Nginx为例，需要在server {...}中配置：

```bash
server {
    ...
    ssl on;
    ssl_certificate     ../ssl/www.test.com.crt;
    ssl_certificate_key ../ssl/www.test.com.key;
}
```

如果一切顺利，打开浏览器，就可以通过HTTPS访问网站。第一次访问时会出现警告（因为我们的自签名证书不被浏览器信任），把证书通过浏览器导入到系统（Windows使用IE导入，Mac使用Safari导入）并设置为“受信任”，以后该电脑访问网站就可以安全地连接Web服务器了：

self-signed-cert

如何在应用服务器中配置证书呢？例如Tomcat，gunicorn等。正确的做法是不配置，让Nginx处理HTTPS，然后通过proxy以HTTP连接后端的应用服务器，相当于利用Nginx作为HTTPS到HTTP的安全代理，这样即利用了Nginx的HTTP/HTTPS处理能力，又避免了应用服务器不擅长HTTPS的缺点。
