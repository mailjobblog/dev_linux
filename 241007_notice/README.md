# Shell通知（飞书/企微/钉钉）

## 机器人开发文档
### 飞书
- https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot
- https://open.feishu.cn/document/uAjLw4CM/ukzMukzMukzM/feishu-cards/feishu-card-cardkit/feishu-cardkit-overview
### 企微
- https://developer.work.weixin.qq.com/document/path/91770
### 钉钉
- https://open.dingtalk.com/document/orgapp/custom-robot-access#title-zob-eyu-qse
### ShowDoc
- https://www.showdoc.com.cn/push

## 使用方法
## 配置环境变量
| 变量名         | 是否必须 | 描述                                                 |
| -------------- |------| ---------------------------------------------------- |
| STATUS         | 是    | 部署状态，只能是 1 或者 0                            |
| WEBHOOK_URL    | 是    | 通知地址，一般是飞书、钉钉等等的自定义机器人通知地址 |
| REPO           | 是    | 仓库名称                                             |
| REPO_URL       | 是    | 仓库URL地址                                          |
| WORKFLOW_URL   | 是    | 部署流水线URL地址                                    |
| BRANCH         | 否    | 部署分支                                             |
| COMMIT_USER    | 否    | 提交作者                                             |
| COMMIT_SHA     | 否    | 提交GIT哈希值                                        |
| COMMIT_MESSAGE | 否    | 提交信息                                             |


### 脚本运行
```bash
```

#### 参数
NOTICE_TYPE
- feishu: 使用飞书发送通知
- dingtalk: 使用钉钉发送通知
- workWechat: 使用企业微信发送通知
- showDoc: 使用ShowDoc发送通知

MSG_TYPE
- text: 发送纯文本通知
- markdown: 发送 Markdown 格式的通知
- card: 发送卡片式通知

#### 脚本参数支持
|            | text | markdown | Card |
| ---------- | ---- | ------- | ---- |
| feishu     | √    | √       | √    |
| dingtalk   | √    | √       | ×    |
| workWechat | √    | √       | ×    |
| showDoc    | √    | ×       | ×    |

