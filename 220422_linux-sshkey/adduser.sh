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


# user info
# user_info=`cat /etc/passwd | grep adduser1 | awk -F: '{print "用户名称: "$1, "用户ID: "$3, "用户所在组ID: "$4, "备注: "$5, "用户家目录: "$6}'`
user_id=`cat /etc/passwd | grep adduser1 | awk -F: '{print $3}'`
user_group_id=`cat /etc/passwd | grep adduser1 | awk -F: '{print $4}'`
user_remarks=`cat /etc/passwd | grep adduser1 | awk -F: '{print $5}'`
user_home=`cat /etc/passwd | grep adduser1 | awk -F: '{print $6}'`
user_group_name=`cat /etc/group | grep ${user_group_id} | awk -F: '{print $1}'`

echo ""
echo "+-------------------------------------------------------------+"
echo "|                                                             |"
echo "| Linux authorization user success                            |"
echo "|                                                             |"
echo "+-------------------------------------------------------------+"
echo ""
echo "username: $1"
echo "ssh-key: $2"
echo ""
echo "---------------------------------------------------------------"
echo ""
echo "用户ID: ${user_id}"
echo "用户组ID: ${user_group_id}"
echo "用户组名称: ${user_group_name}"
echo "用户备注: ${user_remarks}"
echo "用户家目录: ${user_home}"
echo ""
echo "---------------------------------------------------------------"
