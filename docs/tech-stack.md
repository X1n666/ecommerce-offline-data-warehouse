# 技术栈与集群规划

## 1. 版本矩阵（2026-08 定版）

> 原参考项目是 2018 年架构（Hadoop 2.7.6 / Hive 1.2 Tez / Sqoop / Azkaban），已过时。
> 本项目采用现代化组合，面试时可讲「Hive 管元数据、Spark 管计算」的企业常见分工。

| 组件 | 版本 | 用途 | 部署节点 |
|---|---|---|---|
| CentOS | 7.9 | 操作系统（3 台虚拟机） | 全部 |
| JDK | 1.8.0 | 运行时 | 全部 |
| Zookeeper | 3.5.7 | 协调服务 | 全部 |
| Hadoop | 3.1.3 | HDFS + Yarn | 全部 |
| Hive | 3.1.2 | 元数据管理 + 建表 | hadoop101 |
| MySQL | 5.7 | 业务库 + Hive Metastore | hadoop101 |
| Kafka | 2.8.0 | 行为日志缓冲 | 全部 |
| Flume | 1.9.0 | 日志采集（taildir） | hadoop101 |
| Spark | 3.2.0 | SQL 计算（yarn 模式） | 全部 |
| DataX | 最新 | MySQL ↔ HDFS 数据同步（替代 Sqoop） | hadoop101 |
| Airflow | 2.x | 任务调度（替代 Azkaban） | hadoop101 |
| Superset | 最新 | 可视化（可选加分） | hadoop101 |

**为什么不用原项目的 Sqoop / Azkaban / Tez**（面试可能被问，先想好答案）：
- Sqoop 已停止维护，DataX 活跃维护且功能更全；
- Azkaban 生态老旧，Airflow 是主流调度（DAG 可视化、重试、告警完善）；
- Hive on Tez 链路旧，Spark SQL 计算性能更好、简历含金量更高。

## 2. 主机规划（16G 物理内存，每台 4G）

| 主机 | 内存 | 角色 |
|---|---|---|
| hadoop101 | 4G | NameNode、ResourceManager、Hive(metastore+HS2)、MySQL、Flume、DataX、Airflow |
| hadoop102 | 4G | DataNode、NodeManager、Kafka、Zookeeper |
| hadoop103 | 4G | DataNode、NodeManager、Kafka、Zookeeper、SecondaryNameNode |

## 3. 端口规划

| 端口 | 组件 |
|---|---|
| 2181 | Zookeeper |
| 8020 / 9870 | HDFS RPC / NameNode WebUI |
| 8088 | Yarn ResourceManager WebUI |
| 9083 / 10000 | Hive Metastore / HiveServer2 |
| 9092 | Kafka |
| 3306 | MySQL |
| 4040 | Spark UI（随作业临时占用） |
| 8080 | Airflow WebUI |

## 4. 安装顺序

JDK → Zookeeper → Hadoop → MySQL → Hive → Kafka → Flume → Spark → DataX → Airflow

## 5. 关键配置（每步装完对照检查）

| 配置项 | 值 | 原因 |
|---|---|---|
| `dfs.replication` | 2 | 本地 3 节点练习，省一半 HDFS 空间 |
| `yarn.nodemanager.resource.memory-mb` | 2048 | 4G 节点小内存，避免 Yarn 把机器 OOM |
| Hive metastore 库编码 | utf8 | 避免中文表名/注释乱码 |
| Kafka `KAFKA_HEAP_OPTS` | `-Xmx512m` | 默认 1G 会挤爆小内存节点 |
| Spark 提交 | yarn-client，executor 1G×2 | 小集群资源规划，避免 OOM |
| Flume taildir | 断点续传，监听 `/opt/module/logs` | 日志生成器输出目录 |

## 6. 目录规范（VM 上）

```
/opt/software        安装包
/opt/module          组件解压目录（软链：/opt/module/zk → zookeeper-3.5.7）
/opt/module/logs     模拟行为日志输出（Flume 监听）
/opt/data            HDFS 以外的临时数据
```

## 7. 资源提醒

- 每台 VM 固定 4G 内存，Windows 留 4G；
- 开机顺序：ZK → HDFS → Yarn → Kafka，关机顺序相反；
- 虚拟机**先 stop 集群再关机**，否则 HDFS 只读文件系统故障（见[踩坑日志](踩坑日志.md)）。
