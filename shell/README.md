# shell — 集群与数仓运维脚本

## 目录

```
shell/
├── tools/     # 集群公共脚本：xsync 分发、xcall 批量执行、jpsall、zk.sh、cluster.sh
├── utils/     # 通用工具：日期计算、日志函数
├── ods/       # ODS 层加载脚本（Flume 启动、DataX 触发）
├── dwd/       # DWD 层 Spark SQL 提交脚本
├── dws/       # DWS 层提交脚本
└── ads/       # ADS 层提交脚本
```

## 使用说明

- **运行环境是 Linux（虚拟机）**，本仓库在 Windows 开发；写完用 git 拉到 VM 或 `xsync` 分发
- 脚本统一以日期参数 `$1` 入参，如 `./ods/load_ods.sh 2026-08-09`
- 脚本首行 `#!/bin/bash`，仓库已配置 .gitattributes 强制 LF 换行（避免 CRLF 报错）
- 提交到 git 前确认有执行权限：`git update-index --chmod=+x shell/tools/*.sh`
