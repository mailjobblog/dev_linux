# Shell通知（飞书/企微/钉钉/ShowDoc）
本项目提供了一个通过 Shell 脚本向不同消息平台（飞书、企业微信、钉钉、ShowDoc）发送通知的工具，支持文本、Markdown 和卡片格式的消息，适用于部署流水线中的通知推送。

## 机器人开发文档
飞书
- https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot
- https://open.feishu.cn/document/uAjLw4CM/ukzMukzMukzM/feishu-cards/feishu-card-cardkit/feishu-cardkit-overview

企微
- https://developer.work.weixin.qq.com/document/path/91770

钉钉
- https://open.dingtalk.com/document/orgapp/custom-robot-access#title-zob-eyu-qse

ShowDoc
- https://www.showdoc.com.cn/push

## 使用方法
## 配置环境变量
| 变量名         | 是否必须 | 描述                                                                          |
| -------------- |------|-----------------------------------------------------------------------------|
| STATUS         | 是    | 部署状态，`1` 表示成功，`0` 表示失败，用于标识本次部署是否成功。                                        |
| WEBHOOK_URL    | 是    | 通知服务的 Webhook 地址，用于向如飞书、钉钉等平台发送部署通知。                                        |
| REPO           | 是    | 仓库名称，标识当前项目的名称，通常用于区分不同的应用或服务（如：`organizations/repo`）。                      |
| REPO_URL       | 是    | 仓库的 URL 地址，指向项目的源码仓库位置，便于查看代码库（如：`https://example.com/organizations/repo`）。 |
| WORKFLOW_URL   | 是    | 部署流水线的 URL 地址，提供本次部署执行流程的详细信息（如：`https://ci.example.com/organizations/repo/workflow/1`）。      |
| BRANCH         | 否    | 部署分支，指定从哪个分支进行代码部署，若不指定则使用默认分支（如：`main`）。                                   |
| COMMIT_USER    | 否    | 提交代码的作者，用于记录和展示触发本次部署的人员信息。                                                 |
| COMMIT_SHA     | 否    | 提交的 Git 哈希值，用于唯一标识具体的提交版本，便于追踪和回滚（如：`a1b2c3d`）。                             |
| COMMIT_MESSAGE | 否    | 提交信息，记录本次代码提交时的备注内容，便于理解代码更改的目的和背景。                                         |


### 脚本运行
```bash
# 下载后运行
curl -fsSL deploy.notice.sh https://raw.githubusercontent.com/mailjobblog/dev_linux/refs/heads/main/241007_notice/deploy.notice.sh
chmod +x deploy.notice.sh
./notify.sh [NOTICE_TYPE] [MSG_TYPE]

# 直接运行
curl -fsSL https://raw.githubusercontent.com/mailjobblog/dev_linux/refs/heads/main/241007_notice/deploy.notice.sh | bash -s [NOTICE_TYPE] [MSG_TYPE]
```

示例
```bash
STATUS=1 WEBHOOK_URL=https://open.feishu.cn/webhook/xxxx REPO=example/repo ./deploy.notice.sh feishu markdown
```

**Tips**
- 如果您在国内服务器运行，推荐使用 [国内镜像](https://gitee.com/mailjobblog/dev_linux/tree/main/241007_notice) 以提高下载速度。

#### 参数
NOTICE_TYPE：通知发送的平台，支持以下选项
- feishu: 使用飞书发送通知
- dingtalk: 使用钉钉发送通知
- workWechat: 使用企业微信发送通知
- showDoc: 使用ShowDoc发送通知

MSG_TYPE：消息类型，支持以下选项
- text: 发送纯文本通知
- markdown: 发送 Markdown 格式的通知
- card: 发送卡片式通知

#### 支持功能列表
| 通知平台      | text | markdown | Card |
|-----------| ---- | ------- | ---- |
| feishu    | √    | √       | √    |
| dingtalk  | √    | √       | ×    |
| workWechat | √    | √       | ×    |
| showDoc   | √    | √       | ×    |

