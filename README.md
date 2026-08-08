# Ecommerce Offline Data Warehouse

基于 Hadoop、Hive 和 Spark SQL 构建的电商用户行为离线数仓。

## 项目目标

本项目模拟电商业务数据和用户行为日志，完成数据采集、清洗、建模、汇总及指标分析，构建 ODS、DIM、DWD、DWS、ADS 五层数据仓库。

## 技术栈

- Hadoop / HDFS
- Hive
- Spark SQL
- MySQL
- DataX
- Shell
- Airflow

## 数仓分层

- ODS：保存原始业务数据和行为日志
- DIM：保存用户、商品、地区、日期等维度数据
- DWD：保存清洗后的明细事实数据
- DWS：按用户、商品、地区等主题汇总
- ADS：输出业务分析指标

## 业务主题

- 交易主题：下单、支付、退款
- 流量主题：浏览、搜索、点击、加购
- 用户主题：活跃、新增、留存、复购

## 项目结构

```
data-generator/   模拟数据生成器（业务数据 + 行为日志）
datax/            DataX 同步任务（MySQL ↔ HDFS）
docs/             设计文档（架构 / 技术栈 / 表清单 / 路线图 / 踩坑日志）
mysql/            业务数据库 DDL
quality/          数据质量检查脚本
scheduler/        Airflow 调度 DAG
shell/            集群管理 + 各层加载脚本
spark-jobs/       Spark SQL 计算作业（DIM/DWD/DWS/ADS）
sql/              Hive 建表与装载 SQL
```

## 文档导航

- [架构设计](docs/architecture.md) — 分层职责、维度建模、指标口径
- [技术栈与集群规划](docs/tech-stack.md) — 组件版本、主机/端口规划
- [表清单](docs/tables.md) — 全链路表目录（MySQL → ODS → DIM/DWD/DWS → ADS）
- [开发路线图](docs/roadmap.md) — 阶段计划与验收标准
- [踩坑日志](docs/踩坑日志.md) — 问题记录（面试素材）

## 项目状态

项目开发中，进度见 [开发路线图](docs/roadmap.md)。
