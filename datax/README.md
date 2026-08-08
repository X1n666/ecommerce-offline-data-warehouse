# datax — DataX 同步任务（替代 Sqoop）

JSON 任务配置，两条链路：

```
datax/
├── mysql2hdfs/        # MySQL → HDFS（ODS 层入库）
│   ├── order_info.json
│   ├── user_info.json
│   └── ...
└── hdfs2mysql/        # Hive(ADS) → MySQL（指标导出，可视化用）
    ├── ads_gmv_day.json
    └── ...
```

## 用法

```bash
python datax.py job/mysql2hdfs/order_info.json
```

## 设计要点

1. **全量初始化**（Phase 1）：首次把 MySQL 全表导入 HDFS ODS
2. **增量同步**（日常调度）：reader 用 `where` 条件按 `update_time > 上次水位` 过滤
3. **导出链路**：ADS 指标结果小，适合落 MySQL，Superset 直连展示
4. **中文乱码**：reader/writer 都显式 `encoding: "utf-8"`，JDBC 连接串加 `characterEncoding=utf8`

## 示例（增量同步 where 条件）

```json
{
  "job": {
    "content": [{
      "reader": {
        "name": "mysqlreader",
        "parameter": {
          "username": "root", "password": "******",
          "connection": [{
            "jdbcUrl": ["jdbc:mysql://hadoop101:3306/gmall?useUnicode=true&characterEncoding=utf8"],
            "table": ["order_info"]
          }],
          "where": "update_time >= '${last_sync_time}'"
        }
      },
      "writer": {
        "name": "hdfswriter",
        "parameter": {
          "path": "/warehouse/gmall_ods/ods_order_info/dt=${dt}",
          "fileType": "orc", "compress": "snappy", "fieldDelimiter": "",
          "defaultFS": "hdfs://hadoop101:8020"
        }
      }
    }],
    "setting": { "speed": { "channel": 2 } }
  }
}
```

> 面试点：全量 vs 增量怎么选（数据量、变更频率、业务要求）；为什么 Sqoop 被 DataX 取代。
