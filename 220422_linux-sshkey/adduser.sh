#!/bin/sh

# How to use addUser ?
# sh adduser.sh <username> "<your pub key>"

# How to generate SSH key ?
# ssh-keygen -t rsa -C "your_eamil@163.com"

# SSH key parameter introduction：
# -t：指定要创建的密钥类型（支持 RSA 和 DSA 两种认证方式，默认：RSA）
# -C：指定密钥的描述信息（默认：主机名称）
# id_rsa：私钥文件
# id_rsa.pub：公钥文件


# Parameter verification
echo ""
if [ ! $1 ]; then
    echo "Error: The parameter [username] is required"
    exit 1
fi

if [ ! $2 ]; then
    echo "Error: The parameter [ssh-key] is required"
    exit 1
fi

if id -u $1 >/dev/null 2>&1 ; then
    echo "Warning: User [$1] exists"
    echo "Please delete the user before creating the user"
    exit 1
fi


# 添加用户 user
useradd -m $1
# 添加用户到sheel组，使其具备sudo权限
# 一般情况情况下将用户添加到 wheel 组，那么该用户就具备 sudo 权限，需要您重新为该用户单独添加 sudo 权限
# 前提是 /etc/sudoers 文件中，wheel 组的 sudo 已经被开放 `%wheel ALL=(ALL) ALL`
usermod -G wheel $1
# 删除用户密码
passwd -d $1

# ssh-key authorization
mkdir /home/$1/.ssh
echo $2 > /home/$1/.ssh/authorized_keys
chmod 600 /home/$1/.ssh/authorized_keys
chown $1:$1 /home/$1/.ssh -R



echo ""
echo "+-------------------------------------------------------------+"
echo "|                                                             |"
echo "| Linux add user succes                                       |"
echo "|                                                             |"
echo "+-------------------------------------------------------------+"
echo ""
echo "username: $1"
echo "ssh-key: $2"
echo ""
echo "---------------------------------------------------------------"
echo "Help Document"
echo ""
echo ""
echo "---------------------------------------------------------------"