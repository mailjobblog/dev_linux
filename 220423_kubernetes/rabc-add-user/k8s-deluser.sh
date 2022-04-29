#!/bin/sh

USERNAME=$1
NAMESPACE=$2


# How to use k8s delUser ?
# sh k8s-deluser.sh <your username> <k8s namespace>


# 参数定义
# k8s用户证书文件存放地址
user_openssl_path_name=/etc/kubernetes/pki/${USERNAME}
# 角色名
role_name=role-${USERNAME}
# 角色绑定名称
rolebinding_name=rb-${role_name}


kubectl delete role ${role_name} -n ${NAMESPACE}
if [ $? -ne 0 ]; then
    echo "Warning: delete role failed"
else
    echo ">>>>> delete role success"
fi


kubectl delete rolebinding ${rolebinding_name} -n ${NAMESPACE}
if [ $? -ne 0 ]; then
    echo "Warning: delete rolebinding failed"
else
    echo ">>>>> delete rolebinding success"
fi


# 删除用户证书文件
if [ -f "${user_openssl_path_name}.key" ];then
  rm -f ${user_openssl_path_name}.key
  rm -f ${user_openssl_path_name}.csr
  rm -f ${user_openssl_path_name}.crt
  echo ">>>>> delete user openssl key,csr,crt success"
fi



# 删除用户配置信息
if [ -d "/home/${$USERNAME}/.kube" ];then
  rm -rf /home/${$USERNAME}/.kube
  echo ">>>>> delete user .kube dir success"
fi




