#!/bin/sh

USERNAME=$1
NAMESPACE=$2


# How to use k8s addUser ?
# sh k8s-adduser.sh <your username> <k8s namespace>


# 参数定义
# echo $KUBE_APISERVER
User_Openssl_File=/etc/kubernetes/pki/${USERNAME}
Add_User_Doc=https://github.com/mailjobblog/dev_linux/tree/master/220422_linux-sshkey

Cluster_Name=`kubectl config get-clusters | awk '{print $1}' | awk 'NR==2'`
if [ $? -ne 0 ]; then
    echo "Error: get Cluster Name failed"
	  exit 1
fi
Api_Server=`kubectl cluster-info | awk '{print $NF}' | awk 'NR==1' |  sed -r "s:\x1B\[[0-9;]*[mK]::g"`
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
    echo "Please add users before performing this operation [Read Doc: ${Add_User_Doc}]"
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
openssl genrsa -out ${User_Openssl_File}.key 2048
openssl req -new -key ${User_Openssl_File}.key \
-subj "/CN=${USERNAME}/O=devGroup" \
-out ${User_Openssl_File}.csr
openssl x509 -req \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial -in ${User_Openssl_File}.csr -out ${User_Openssl_File}.crt -days 3650

if [ $? -ne 0 ]; then
    echo "Error: openssl create failed"
	  exit 1
fi
echo ">>>>> openssl create success"


# Kubernetes 授权

# cluster name 可以通过 kubectl config get-clusters 获取
# apiserver 通过 kubectl cluster-info 获取

# 设置集群参数
kubectl config set-cluster ${Cluster_Name} \
--embed-certs=true \
--certificate-authority=/etc/kubernetes/pki/ca.crt \
--server=${Api_Server} \
--kubeconfig=${User_Openssl_File}.kubeconfig

if [ $? -ne 0 ]; then
    echo "Error: set-cluster create failed"
	  exit 1
fi
echo ">>>>> set-cluster create success"

# 设置客户端认证参数
kubectl config set-credentials ${USERNAME} \
--embed-certs=true \
--client-certificate=${User_Openssl_File}.crt \
--client-key=${User_Openssl_File}.key \
--kubeconfig=${User_Openssl_File}.kubeconfig

if [ $? -ne 0 ]; then
    echo "Error: set-credentials create failed"
	  exit 1
fi
echo ">>>>> set-credentials create success"

# 设置上下文参数
Set_Context_Name=${USERNAME}@${Cluster_Name}
kubectl config set-context ${Set_Context_Name} \
--cluster=${Cluster_Name} \
--user=${USERNAME} \
--namespace=${NAMESPACE} \
--kubeconfig=${User_Openssl_File}.kubeconfig

if [ $? -ne 0 ]; then
    echo "Error: set-context create failed"
	  exit 1
fi
echo ">>>>> set-context create success"

# 创建角色并绑定用户
# 角色命名与角色绑定器命名说明：
# 如果 user=devuser
# 则 role=role-devuser、 rolebinding=rb-role-devuser
Role_Name=role-${USERNAME}
Role_Binding_Name=rb-${Role_Name}

# 创建角色
kubectl create role ${Role_Name} \
--namespace=${NAMESPACE} \
--verb=get,list,watch,exec \
--resource=pod

if [ $? -ne 0 ]; then
    echo "Error: set role create failed"
	  exit 1
fi
echo ">>>>> set role create success"

# 角色绑定
kubectl create rolebinding ${Role_Binding_Name} \
--namespace=${NAMESPACE} \
--role=${Role_Name} \
--user=${USERNAME}

if [ $? -ne 0 ]; then
    echo "Error: rolebinding create failed"
	  exit 1
fi
echo ">>>>> rolebinding create success"


# 授权文件赋值
mkdir /home/${USERNAME}/.kube
cat ${User_Openssl_File}.kubeconfig > /home/${USERNAME}/.kube/config
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
echo ""
echo "username: ${USERNAME}"
echo "namespace: ${NAMESPACE}"
echo ""
echo "---------------------------------------------------------------"
echo "Rbac authority info"
echo ""
echo "role: ${Role_Name}"
echo "rolebinding: ${Role_Binding_Name}"
echo ""
echo "---------------------------------------------------------------"
echo "Kube config"
echo ""
echo "K8s pki path: ${User_Openssl_File}.kubeconfig"
echo "user kube config path: /home/${USERNAME}/.kube/config"
echo ""
echo "---------------------------------------------------------------"
echo "Kubernetes Cluster config info"
echo ""
echo "cluster name: ${Cluster_Name}"
echo "apiserver: ${Api_Server}"
echo ""
echo "---------------------------------------------------------------"
echo "Help Document"
echo "Please execute the following command under the authorized user"
echo ""
echo "Switched to context:"
echo "kubectl config use-context ${Set_Context_Name} --kubeconfig=/home/${USERNAME}/.kube/config"
echo ""
echo "Test k8s command:"
echo "kubectl get pod -n ${NAMESPACE}"
echo ""
echo "---------------------------------------------------------------"
