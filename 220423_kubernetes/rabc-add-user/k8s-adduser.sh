#!/bin/sh

USERNAME=$1
NAMESPACE=$2


# How to use k8s addUser ?
# sh k8s-adduser.sh <your username> <k8s namespace>


# 参数定义

# 环境变量
# 用于定义k8s集群master服务器IP地址
# KUBE_APISERVER
# export KUBE_APISERVER="https://your_ipaddress:6443"

# k8s用户证书文件存放地址
user_openssl_path_name=/etc/kubernetes/pki/${USERNAME}

# Linux添加用户说明文档
add_user_doc=https://github.com/mailjobblog/dev_linux/tree/master/220422_linux-sshkey



cluster_name=`kubectl config get-clusters | awk '{print $1}' | awk 'NR==2'`
if [ $? -ne 0 ]; then
    echo "Error: get Cluster Name failed"
	  exit 1
fi
api_server=`kubectl cluster-info | awk '{print $NF}' | awk 'NR==1' |  sed -r "s:\x1B\[[0-9;]*[mK]::g"`
if [ $? -ne 0 ]; then
    echo "Error: get Api Server failed"
	  exit 1
fi


# Parameter verification
echo ""
if [ ! $USERNAME ]; then
    echo "Error: The parameter [username] is required"
    exit 1
fi

if [ ! $NAMESPACE ]; then
    echo "Error: The parameter [namespace] is required"
    exit 1
fi

egrep "^$USERNAME" /etc/passwd >& /dev/null
if [ $? -ne 0 ]; then
    echo "Warning: User ${USERNAME} not exists"
    echo ""
    echo "Please add users before performing this operation [Read Doc: ${add_user_doc}]"
    echo ""
	  exit 1
fi


# verification
if [ ! $KUBE_APISERVER ]; then
    echo "Error: Environment variable [KUBE_APISERVER] no export"
    echo ""
    echo "Please run [export KUBE_APISERVER="https://your_ipaddress:6443"]"
    echo ""
    exit 1
fi


# 签名文件和证书生成
openssl genrsa -out ${user_openssl_path_name}.key 2048
openssl req -new -key ${user_openssl_path_name}.key \
-subj "/CN=${USERNAME}/O=devGroup" \
-out ${user_openssl_path_name}.csr
openssl x509 -req \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial -in ${user_openssl_path_name}.csr -out ${user_openssl_path_name}.crt -days 3650

if [ $? -ne 0 ]; then
    echo "Error: openssl create failed"
	  exit 1
fi
echo ">>>>> openssl create success"


# Kubernetes 授权

# cluster name 可以通过 kubectl config get-clusters 获取
# apiserver 通过 kubectl cluster-info 获取

# 设置集群参数
kubectl config set-cluster ${cluster_name} \
--embed-certs=true \
--certificate-authority=/etc/kubernetes/pki/ca.crt \
--server=${api_server} \
--kubeconfig=${user_openssl_path_name}.kubeconfig

if [ $? -ne 0 ]; then
    echo "Error: set-cluster create failed"
	  exit 1
fi
echo ">>>>> set-cluster create success"

# 设置客户端认证参数
kubectl config set-credentials ${USERNAME} \
--embed-certs=true \
--client-certificate=${user_openssl_path_name}.crt \
--client-key=${user_openssl_path_name}.key \
--kubeconfig=${user_openssl_path_name}.kubeconfig

if [ $? -ne 0 ]; then
    echo "Error: set-credentials create failed"
	  exit 1
fi
echo ">>>>> set-credentials create success"

# 设置上下文参数
set_context_name=${USERNAME}@${cluster_name}
kubectl config set-context ${set_context_name} \
--cluster=${cluster_name} \
--user=${USERNAME} \
--namespace=${NAMESPACE} \
--kubeconfig=${user_openssl_path_name}.kubeconfig

if [ $? -ne 0 ]; then
    echo "Error: set-context create failed"
	  exit 1
fi
echo ">>>>> set-context create success"

# 创建角色并绑定用户
# 角色命名与角色绑定器命名说明：
# 如果 user=devuser
# 则 role=role-devuser、 rolebinding=rb-role-devuser
role_name=role-${USERNAME}
rolebinding_name=rb-${role_name}

# 创建角色
kubectl create role ${role_name} \
--namespace=${NAMESPACE} \
--verb=get,list,watch,exec \
--resource=pod

if [ $? -ne 0 ]; then
    echo "Error: set role create failed"
	  exit 1
fi
echo ">>>>> set role create success"

# 角色绑定
kubectl create rolebinding ${rolebinding_name} \
--namespace=${NAMESPACE} \
--role=${role_name} \
--user=${USERNAME}

if [ $? -ne 0 ]; then
    echo "Error: rolebinding create failed"
	  exit 1
fi
echo ">>>>> rolebinding create success"


# 授权文件赋值
mkdir /home/${USERNAME}/.kube
cat ${user_openssl_path_name}.kubeconfig > /home/${USERNAME}/.kube/config
chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.kube -R

if [ $? -ne 0 ]; then
    echo "Error: user chown failed"
	  exit 1
fi
echo ">>>>> user chown success"


# Success info
echo ""
echo "+-------------------------------------------------------------+"
echo "|                                                             |"
echo "| Kubernetes RBAC add user Success                            |"
echo "|                                                             |"
echo "+-------------------------------------------------------------+"
echo "username: ${USERNAME}"
echo "namespace: ${NAMESPACE}"
echo "---------------------------------------------------------------"
echo "Rbac authority info"
echo "role: ${role_name}"
echo "rolebinding: ${rolebinding_name}"
echo "---------------------------------------------------------------"
echo "Kube config"
echo ""
echo "K8s pki path: ${user_openssl_path_name}.kubeconfig"
echo "user kube config path: /home/${USERNAME}/.kube/config"
echo "---------------------------------------------------------------"
echo "Kubernetes Cluster config info"
echo ""
echo "cluster name: ${cluster_name}"
echo "apiserver: ${api_server}"
echo "---------------------------------------------------------------"
echo "Help Document"
echo "Please execute the following command under the authorized user"
echo ""
echo "Switched to context:"
echo "kubectl config use-context ${set_context_name} --kubeconfig=/home/${USERNAME}/.kube/config"
echo ""
echo "Test k8s command:"
echo "kubectl get pod -n ${NAMESPACE}"
echo "---------------------------------------------------------------"
