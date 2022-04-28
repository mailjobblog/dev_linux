#!/bin/sh

USERNAME=$1


# Parameter verification
echo ""
if [ ! $USERNAME ]; then
    echo "Error: The parameter [username] is required"
    exit 1
fi

function get_role_bind() {
    NS=$1
    role_bind=`kubectl get rolebinding -n ${NS} -o wide | awk '{print $1,$4}' | awk 'NR>1' | awk "$2/${USERNAME}/" | awk '{print $1}'`
    if [ $? -ne 0 ]; then
        echo "Error: get rolebinding failed"
    	  exit 1
    fi

    if [[ $role_bind == "No resources found*" ]];then
        echo "包含则跳过 $role_bind"
        return
    fi

    for rb in ${role_bind[@]}; do
      echo "namespace: $NS, role_binding: $rb"
    done
}

get_ns=`kubectl get namespace | awk 'NR>1{print $1}'`
for ns in ${get_ns[@]}; do
  get_role_bind $ns
done