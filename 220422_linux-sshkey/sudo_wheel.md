# 在 Linux 中如何使用 wheel 组为普通用户授予超级用户访问权限？

wheel 是基于 RHEL 的系统中的一个特殊组，它提供额外的权限，可以授权用户像超级用户一样执行受到限制的命令。

注意，应该在 /etc/sudoers 文件中激活 wheel 组来获得该访问权限。

```bash
# grep -i wheel /etc/sudoers

## Allows people in group wheel to run all commands
%wheel ALL=(ALL) ALL
# %wheel ALL=(ALL) NOPASSWD: ALL
```

假设我们已经创建了一个用户账号来执行这些操作。在此，我将会使用 daygeek 这个用户账号。

执行下面的命令，添加用户到 wheel 组。

```bash
# usermod -aG wheel daygeek
```

我们可以通过下面的命令来确定这一点。

```bash
# getent group wheel
wheel:x:10:daygeek
```

我将要检测用户 daygeek 是否可以访问属于 root 用户的文件。

```bash
$ tail -5 /var/log/secure
tail: cannot open /var/log/secure for reading: Permission denied
```

当我试图以普通用户身份访问 /var/log/secure 文件时出现错误。 我将使用 sudo 访问同一个文件，让我们看看这个魔术。

```bash
$ sudo tail -5 /var/log/secure
[sudo] password for daygeek:
Mar 17 07:01:56 CentOS7 sudo: daygeek : TTY=pts/0 ; PWD=/home/daygeek ; USER=root ; COMMAND=/bin/tail -5 /var/log/secure
Mar 17 07:01:56 CentOS7 sudo: pam_unix(sudo:session): session opened for user root by daygeek(uid=0)
Mar 17 07:01:56 CentOS7 sudo: pam_unix(sudo:session): session closed for user root
Mar 17 07:05:10 CentOS7 sudo: daygeek : TTY=pts/0 ; PWD=/home/daygeek ; USER=root ; COMMAND=/bin/tail -5 /var/log/secure
Mar 17 07:05:10 CentOS7 sudo: pam_unix(sudo:session): session opened for user root by daygeek(uid=0)
```