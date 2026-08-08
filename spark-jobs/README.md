# spark-jobs — Spark SQL 计算作业

DIM/DWD/DWS/ADS 的清洗与汇总计算用 **Spark SQL** 执行（Hive 只负责元数据和建表）。

## 目录

```
spark-jobs/
├── dim/     # 维度：用户拉链表（重点）、商品、分类、地区、日期
├── dwd/     # 明细 ETL：JSON 解析拉平、去重、字段清洗
├── dws/     # 主题宽表：用户/商品/地区/时间四主题
└── ads/     # 指标计算：GMV/UV/留存/复购/转化
```

## 运行方式

开发调试（交互式）：
```bash
spark-sql -f dwd/dwd_order_info.sql \
  --conf spark.sql.warehouse.dir=hdfs://hadoop101:8020/user/hive/warehouse
```

调度执行（Airflow 用 BashOperator 或 SparkSubmitOperator 提交）：
```bash
spark-submit --master yarn --deploy-mode client \
  --driver-memory 1g --executor-memory 1g --executor-cores 2 \
  --conf spark.sql.warehouse.dir=hdfs://hadoop101:8020/user/hive/warehouse \
  --conf spark.dynamicAllocation.enabled=false \
  --conf spark.sql.adaptive.enabled=true \
  --files dwd/dwd_order_info.sql
```

> 资源参数按 4G 节点定：executor 1G × 2 核起步，跑不动再调。

## 面试加分点（写代码时注意）

- **数据倾斜**：大表 Join 小表用 `MAPJOIN`；倾斜 Key 加盐/打散；开启 AQE（spark.sql.adaptive）
- **小文件**：输出前 `repartition(n)` / 开启合并，避免下游 NameNode 压力
- **JSON 解析**：`get_json_object` / `lateral view explode`，事件日志拆表是必考
- **去重**：ODS → DWD 用 `row_number()` 按主键去重，讲清为什么 ODS 会有重复
