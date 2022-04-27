#!/bin/sh

USERNAME=$1

# How to use k8s get user namespace ?
# sh k8s-getuserns.sh <your username>

role_bind=`kubectl get rolebinding -n dev -o wide | awk '{print $1,$4}' | awk 'NR>1' | grep ${USERNAME}`

for b in ${role_bind[@]}; do

done