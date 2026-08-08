# 表清单（全链路表目录）

> 规划蓝图：实际以建表 SQL 为准（mysql/、sql/、spark-jobs/ 下的 DDL）。
> 面试时能对每张表讲清：**粒度、分区、用途、口径**。
> 列格式：表名 | 粒度 | 分区/更新方式 | 说明

## 1. MySQL 业务表（数据源，gmall 业务库）

| 表名 | 说明 | 备注 |
|---|---|---|
| user_info | 用户表 | 含 update_time，增量同步依据 |
| base_province | 省份表 | 静态维度 |
| base_category | 商品分类表 | 静态维度 |
| sku_info | 商品 SKU 表 | 含 update_time |
| spu_info | 商品 SPU 表 | 含 update_time |
| order_info | 订单主表 | 下单时间/状态/金额 |
| order_detail | 订单明细表 | 订单内商品行 |
| payment_info | 支付流水表 | 支付时间/金额 |
| order_refund_info | 退款信息表 | 退款金额/时间 |
| coupon_info / coupon_use | 优惠券 + 领用表 | 可选 |
| cart_info | 购物车表 | 可选 |
| comment_info | 商品评价表 | 可选 |

> 面试重点：为什么保留 `update_time`？——增量同步的天然水位线。

## 2. ODS 层（gmall_ods，原始镜像，按天分区）

| 表名 | 来源 | 说明 |
|---|---|---|
| ods_user_info | DataX | 业务表镜像 |
| ods_sku_info / ods_spu_info / ods_base_category / ods_base_province | DataX | 商品/维度镜像 |
| ods_order_info / ods_order_detail | DataX | 交易镜像 |
| ods_payment_info / ods_refund_info | DataX | 支付/退款镜像 |
| ods_log | Flume | 行为日志原始 JSON（不解析，整行存储） |

## 3. DIM 层（gmall_dim，标准维度）

| 表名 | 粒度 | 更新方式 | 说明 |
|---|---|---|---|
| dim_user_info | 用户 | **拉链表**（每日增量） | 面试必讲：历史版本追溯 |
| dim_sku_info | SKU | 每日全量覆盖 | 关联 spu/分类，降维宽表 |
| dim_base_category | 分类 | 每日全量 | 一级/二级/三级分类 |
| dim_base_province | 省份 | 每日全量 | |
| dim_date | 天 | 一次性生成 | 日期维度（年/月/周/季度/节假日） |

## 4. DWD 层（gmall_dwd，清洗后明细）

| 表名 | 粒度 | 说明 |
|---|---|---|
| dwd_start_log | 每次启动 | 启动日志（去重、提字段） |
| dwd_page_log | 每次浏览 | 页面日志（含页面 id、停留时长） |
| dwd_action_log | 每次行为事件 | 点击/加购/收藏/下单/支付事件，JSON 拉平 |
| dwd_order_info | 每笔订单 | 清洗后订单主表 |
| dwd_order_detail | 订单行 | 明细行 + 商品信息补全 |
| dwd_payment_info | 每笔支付 | 支付明细 |
| dwd_refund_info | 每笔退款 | 退款明细 |

> 面试重点：日志 JSON 怎么解析成列（get_json_object / 自定义 UDTF）；事件日志怎么从页面日志里拆出来（lateral view explode）。

## 5. DWS 层（gmall_dws，主题宽表，日粒度）

| 表名 | 主题 | 说明 |
|---|---|---|
| dws_user_action_day | 用户 | 每日每用户：PV、加购数、下单数、支付数、金额 |
| dws_sku_stats_day | 商品 | 每日每 SKU：曝光、加购、下单、支付 GMV |
| dws_area_stats_day | 地区 | 每日每省份：UV、下单数、GMV |
| dws_flow_stats_day | 时间/整体 | 每日整体：PV/UV、各事件次数 |
| dws_user_retention_day | 用户 | 每日每用户是否活跃（留存计算底座） |

> 面试重点：DWS 的主题划分依据（用户/商品/地区/时间四维）；宽表设计如何减少下游重复计算。

## 6. ADS 层（gmall_ads，指标结果，导出 MySQL）

| 表名 | 指标 | 口径（见 architecture.md 第 5 节） |
|---|---|---|
| ads_gmv_day | 每日 GMV/订单数/客单价 | 按支付时间 |
| ads_trade_refund | 退款率 | 退款金额 ÷ GMV |
| ads_flow_stats | PV/UV/跳出率 | UV 按 user_id 去重 |
| ads_flow_convert | 转化漏斗 | 浏览→加购→下单→支付 |
| ads_user_retention | 次日/7 日留存 | 新增用户中活跃占比 |
| ads_user_stats | 新增/活跃/复购率 | 复购：购买 ≥2 次 ÷ 购买用户 |
| ads_sku_topN | 商品 TOP N | 按 GMV 排名 |
| ads_area_stats | 地区 GMV/UV | 按省份 |

## 7. 关键设计决策（面试问答素材）

1. **为什么 DWD 拆 3 张日志表**：启动/页面/事件分析场景不同，拆开各算各的，互不阻塞；
2. **为什么 ODS 日志不解析**：原始数据留底，解析放 DWD（清洗逻辑可随时重跑）；
3. **为什么 ADS 要导出 MySQL**：可视化工具（Superset）直连 Hive 太慢，指标结果小、适合落 MySQL；
4. **历史数据怎么造**：生成器按天批量回灌 3-6 个月，保证拉链表、留存等历史指标可算。
