#!/bin/sh

username=$1

# Parameter verification
echo ""
if [ ! $username ]; then
    echo "Error: The parameter [username] is required"
    exit 1
fi


# delete user
userdel $username
groupdel $username

# 将用户从 wheel 组中移除
gpasswd -d $username wheel

rm -rf /home/$username/.ssh