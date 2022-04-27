#!/bin/sh

USERNAME=$1
NAMESPACE=$2


# How to use k8s delUser ?
# sh k8s-deluser.sh <your username> <k8s namespace>


Role_Name=role-${USERNAME}
Role_Binding_Name=rb-${Role_Name}


kubectl delete role ${Role_Name} -n ${NAMESPACE}
if [ $? -ne 0 ]; then
    echo "Error: delete role failed"
else
    echo ">>>>> delete role success"
fi


kubectl delete rolebinding ${Role_Binding_Name} -n ${NAMESPACE}
if [ $? -ne 0 ]; then
    echo "Error: delete rolebinding failed"
else
    echo ">>>>> delete rolebinding success"
fi



rm -rf /home/${$USERNAME}/.kube
echo ">>>>> delete user .kube dir success"

