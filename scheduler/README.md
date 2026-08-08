# scheduler — Airflow 任务调度

用 Airflow 2.x 编排数仓全流程，替代手工执行脚本。

## 目录

```
scheduler/
├── dags/
│   ├── dw_ods.py        # 采集：Flume/Kafka 落 ODS + DataX 同步业务表
│   ├── dw_dim.py        # 维度层（含用户拉链表每日更新）
│   ├── dw_dwd.py        # ODS → DWD（Spark SQL）
│   ├── dw_dws.py        # DWD → DWS
│   ├── dw_ads.py        # DWS → ADS + DataX 导出 MySQL
│   └── dw_all.py        # master DAG：组合上述依赖
└── README.md
```

## 设计要点

1. **依赖关系**：`dw_ods`（前日 23:00）→ `dw_dim`/`dw_dwd` → `dw_dws` → `dw_ads`（次日 02:00 前）
2. **时间参数**：统一用 `{{ ds }}` 传给 BashOperator/SparkSubmitOperator，SQL 全部参数化
3. **失败重试**：`retries=3, retry_delay=5min`，失败告警（Email/钉钉可后续加）
4. **幂等**：每层 `INSERT OVERWRITE`，重跑不产生重复数据

```python
# 示例骨架
with DAG("dw_all", schedule="0 1 * * *", catchup=False) as dag:
    t_ods  = BashOperator(task_id="load_ods", bash_command="...", retries=3)
    t_dim  = SparkSubmitOperator(task_id="build_dim", application="...")
    t_dwd  = SparkSubmitOperator(task_id="build_dwd", application="...")
    t_dws  = SparkSubmitOperator(task_id="build_dws", application="...")
    t_ads  = SparkSubmitOperator(task_id="build_ads", application="...")
    t_export = BashOperator(task_id="export_mysql", bash_command="python datax.py ...")

    t_ods >> [t_dim, t_dwd] >> t_dws >> t_ads >> t_export
```
