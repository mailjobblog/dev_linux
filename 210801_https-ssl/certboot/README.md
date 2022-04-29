# HTTPS SSL 证书生成

## 方法介绍

几个方法的共同点是都是基于 [certbot](https://certbot.eff.org/) 生成 SSL 证书的工具。

- certbot
- certbot-auto
- acme

## 区别介绍

### certbot

该方法是 certbot 官网文档中介绍的 ssl 证书生成的方式。

### certbot-auto

certbot-auto 对 certbot 做了包装，可以设置系统环境或自动升级。

### acme

[acme.sh](https://github.com/acmesh-official/acme.sh) 是对 certbot 做了一些升级，省去了手动去域名后台改DNS记录的步骤，而且不用依赖Python。