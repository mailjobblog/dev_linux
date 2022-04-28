#!/bin/sh

USERNAME=$1


# Parameter verification
echo ""
if [ ! $USERNAME ]; then
    echo "Error: The parameter [username] is required"
    exit 1
fi


# 查看命名空间下的角色绑定关系
function get_role_bind() {
    namespace=$1
    role_bind=`kubectl get rolebinding -n ${namespace} -o wide | awk '{print $1,$4}' | awk 'NR>1' | awk "$2/${USERNAME}/" | awk '{print $1}'`
    if [ $? -ne 0 ]; then
        echo "Error: get rolebinding failed"
    	  exit 1
    fi

    if [[ $role_bind == "No resources found*" ]];then
        echo "包含则跳过 $role_bind"
        return
    fi

    for rb in ${role_bind[@]}; do
      echo "namespace: $namespace, role_binding: $rb"
    done
}


# 查询所有命名空间
get_ns=`kubectl get namespace | awk 'NR>1{print $1}'`
for ns in ${get_ns[@]}; do
  get_role_bind $ns
done