#!/bin/bash

COMMIT_MESSAGE="  Test：\"测试\"乱格式 **11** 提示🤔️  (#100)\" 影响jefferyjob/notify-actions (#15)* 测jefferyjob/notify-actions

🤔️

哈哈  李
                                 Dload  Upload   Total   Spent    Left  Speed

* test 1


fdsafds 444 hah

* test 2

fdsafds 444 hah

* test 3333

    fdsafds 444 hah

* test 4

fdsafds 444 hah


    "

COMMIT_MESSAGE="PR: $COMMIT_MESSAGE"

COMMIT_MESSAGE1=$(echo "$COMMIT_MESSAGE" | head -n 1 | tr -d '\n' | sed -e 's/[[:punct:]]//g')
COMMIT_MESSAGE2=$(echo "$COMMIT_MESSAGE" | head -n 1 | tr -d '\n' | sed -e 's/["()\\]//g' -e 's/[[:punct:]]//g')
COMMIT_MESSAGE3=$(echo "$COMMIT_MESSAGE" | head -n 1 | tr -d '\n' | sed -e 's/[\"'\'']//g' -e 's/[()\\]//g')

echo $COMMIT_MESSAGE1
echo $COMMIT_MESSAGE2
echo $COMMIT_MESSAGE3
