# sql — 数仓 SQL 脚本

按分层组织目录，每层一个子目录，SQL 按业务域拆分：

```
sql/
├── ods/          # ODS 层：建表 + 装载
│   ├── ods_db.sql       # 业务数据镜像表（DataX 导入目标）
│   └── ods_log.sql      # 行为日志原始表（Flume 写入目标，整行 JSON）
├── dim/          # 维度层：用户拉链表、商品、分类、地区、日期
├── dwd/          # 明细层：日志三表 + 交易四表
├── dws/          # 汇总层：用户/商品/地区/时间主题宽表
└── ads/          # 指标层：GMV/UV/留存/复购/转化
```

## 规范

- 每个 SQL 文件同时包含**建表 DDL** 和**当日装载语句**（`INSERT OVERWRITE`）
- 表名带层前缀：`ods_` / `dim_` / `dwd_` / `dws_` / `ads_`
- 一律 Hive 外部表 + ORC + Snappy，按 `dt` 分区
- 装载语句用 `dt` 变量参数化（配合 Airflow 传参调度）：

```sql
-- 示例：DWD 层参数化装载模板
INSERT OVERWRITE TABLE gmall_dwd.dwd_order_info PARTITION (dt = '${dt}')
SELECT ... FROM gmall_ods.ods_order_info WHERE dt = '${dt}';
```

> 表名和口径以 [docs/tables.md](../docs/tables.md) 为准；DIM 层以上的计算优先走 Spark SQL（见 spark-jobs/），本目录以 Hive DDL 和较简单的装载为主。
