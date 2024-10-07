#!/bin/bash

export STATUS="1"

export REPO_URL="https://baidu.com"
export WORKFLOW_URL="https://weibo.com"

export REPO="gitee/example"
export REPO_URL="https://gitee.com"


# 企业微信
export WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=7fd4ebfc-63ff-4ef0-9eb6-07bc0effc61e"
sh deploy.notice.sh workWechat text
sh deploy.notice.sh workWechat markdown

# 飞书
export WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/eb6bfd1c-a280-47ea-af3e-d372cad188d7"
#sh deploy.notice.sh feishu text
#sh deploy.notice.sh feishu card

# 钉钉
export WEBHOOK_URL="https://oapi.dingtalk.com/robot/send?access_token=b1b6024c02ff4b65235a90af7f713338cb3a2ac4df04e588ff5a701c1c014c35"
#sh deploy.notice.sh dingtalk text
#sh deploy.notice.sh dingtalk markdown