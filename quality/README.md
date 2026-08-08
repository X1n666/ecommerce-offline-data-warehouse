# quality — 数据质量检查

每个环节跑完后做质量校验，防止脏数据流向下游。检查节点嵌在 Airflow DAG 中，失败则阻断下游任务。

## 检查项

| 脚本 | 检查内容 | 判败条件 |
|---|---|---|
| check_rowcount.sh | ODS 装载行数 vs 源（DataX 统计/日志行数） | 行数差 > 阈值 |
| check_pk_dup.sh | DWD 关键表主键去重检查 | 有重复主键 |
| check_null_rate.sh | 关键字段空值率（订单金额、user_id） | 空值率 > 1% |
| check_kpi_ratio.sh | ADS 指标与昨日环比波动 | |环比| > 30% 告警 |

## 目录

```
quality/
├── check_rowcount.sh
├── check_pk_dup.sh
├── check_null_rate.sh
├── check_kpi_ratio.sh
└── lib/          # 公共函数（Spark SQL / Hive 查询封装）
```

## 示例（空值检查）

```sql
-- 输出: 表名, 字段, 空值率
SELECT count(*) - count(order_amount) / count(*) AS null_rate
FROM gmall_dwd.dwd_order_info WHERE dt = '${dt}';
```

> 面试点：数据质量是数仓岗位区分度最高的软技能之一，把「检查什么、为什么、失败怎么处理」讲清楚。
