# Kubernetes RBAC 认证管理

## 介绍

使用 RBAC 可以让我们更好的管理资源，比如访问某个资源的用户，比如访问某个资源的组等。

## k8s-adduser.sh

```bash
sh k8s-adduser.sh <your username> <k8s namespace>
```

### 说明

该shell脚本采用 Role、RoleBinding 的方式来授权认证用户。  
Role只能对命名空间内的资源进行授权，需要指定nameapce。  
一个角色就是一组权限的集合，这里的权限都是许可形式的（白名单）。  

> 如果你想跨namespace授权，则此shell脚本无法满足您的需求。  
> 请查看[官方文档](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#clusterrole-%E7%A4%BA%E4%BE%8B)使用 ClusterRole、ClusterRoleBinding 的方法授权认证用户。    

## k8s-deluser.sh

```bash
sh k8s-deluser.sh <your username> <k8s namespace>
```

### 说明

如果要删除 role、rolebinding 是使用此脚本删除被授权用户。  

**执行工作如下：**

- 删除用户角色role
- 删除用户和角色的绑定关系rolebinding
- 删除用户生成的openssl证书文件
- 删除用户目录下的k8s配置目录 `.kube`


