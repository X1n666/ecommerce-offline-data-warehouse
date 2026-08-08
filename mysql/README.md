# mysql — 业务数据库设计

## 目录

```
mysql/
├── business_ddl.sql      # 业务库建表语句（gmall 库）
├── init_data.sql         # 初始数据（省份、分类等静态维度）
└── functions/            # 造数辅助函数/存储过程（可选）
```

## 建表原则

- 贴近真实电商业务字段，面试时能讲清每张表含义（表清单见 [docs/tables.md](../docs/tables.md)）
- 金额用 `decimal(16,2)`，时间统一 `datetime`
- **业务表预留 `update_time`** —— 增量同步的天然水位线（DataX where 条件）
- 订单表含状态字段（下单/支付/发货/完成），支持状态流转分析

## 表清单（业务库 gmall）

| 表名 | 说明 |
|---|---|
| user_info | 用户表 |
| base_province | 省份表（静态） |
| base_category | 商品分类（静态） |
| sku_info / spu_info | 商品 SKU / SPU |
| order_info / order_detail | 订单主表 / 明细 |
| payment_info | 支付流水 |
| order_refund_info | 退款信息 |
| coupon_info / coupon_use / cart_info / comment_info | 可选扩展 |
