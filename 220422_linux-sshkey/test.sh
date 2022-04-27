#!bin/sh

Api_Server=`kubectl cluster-info |  awk '{print $NF}' | sed -n 1p`

echo ${Api_Server} > test.log