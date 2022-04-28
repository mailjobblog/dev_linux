# Linux 服务器密钥授权验证

## 介绍

Linux下使用用户名和密码登陆服务器是不安全，所以我们需要使用密钥授权验证。

## 密钥生成

```bash
ssh-keygen -t rsa -C "your_eamil@163.com"
```

**参数说明：**

- -t：指定要创建的密钥类型（支持 RSA 和 DSA 两种认证方式，默认：RSA）
- -C：指定密钥的描述信息（默认：主机名称）

**生成文件：**

- id_rsa：私钥文件
- id_rsa.pub：公钥文件


## 授权用户

```bash
sh adduser.sh <username> "<your pub key>"
```

**本地测试连接**

```bash
ssh -p 22 <username>@<ipadress>
```

## 其他安全配置

### 禁止root账户和密码方式登陆

```bash
vi /etc/ssh/sshd_config
```

**禁止root账户登陆** 

PermitRootLogin yes 改为 no
```text
PermitRootLogin no
```

**禁止密码登陆**

PasswordAuthentication yes改为no
```text
PasswordAuthentication no
```

**修改ssh登陆端口**

```text
Port 22
```
注意：修改ssh登陆端口后，需要把修改后的端口加入到防火墙中，否则服务器无法登陆。

**重启ssh服务**

```bash
systemctl restart sshd.service
```

### 配置sudo权限
