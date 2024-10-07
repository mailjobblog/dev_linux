#!/bin/bash

# commit备注生成
default_commit="auto git";
read -p "请输入 commit 备注信息: " commit
# 备注信息为空赋默认值
if [ ! -n "$commit" ];then
	commit=${default_commit};
fi

#==============================================
# git 命令执行
#==============================================
git pull origin main && \
git add . && \
git commit -m "${commit}" && \
git push origin main