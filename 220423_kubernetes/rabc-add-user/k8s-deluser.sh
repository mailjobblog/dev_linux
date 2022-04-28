#!/bin/sh

USERNAME=$1
NAMESPACE=$2


# How to use k8s delUser ?
# sh k8s-deluser.sh <your username> <k8s namespace>


# 参数定义
# k8s用户证书文件存放地址
User_Openssl_File=/etc/kubernetes/pki/${USERNAME}

Role_Name=role-${USERNAME}
Role_Binding_Name=rb-${Role_Name}


kubectl delete role ${Role_Name} -n ${NAMESPACE}
if [ $? -ne 0 ]; then
    echo "Warning: delete role failed"
else
    echo ">>>>> delete role success"
fi


kubectl delete rolebinding ${Role_Binding_Name} -n ${NAMESPACE}
if [ $? -ne 0 ]; then
    echo "Warning: delete rolebinding failed"
else
    echo ">>>>> delete rolebinding success"
fi


# 删除用户证书文件
if [ -f "${User_Openssl_File}.key" ];then
  rm -f ${User_Openssl_File}.key
  rm -f ${User_Openssl_File}.csr
  rm -f ${User_Openssl_File}.crt
  echo ">>>>> delete user openssl key,csr,crt success"
fi



# 删除用户配置信息
if [ -d "/home/${$USERNAME}/.kube" ];then
  rm -rf /home/${$USERNAME}/.kube
  echo ">>>>> delete user .kube dir success"
fi




