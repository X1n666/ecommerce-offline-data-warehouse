#!/bin/bash
# =============================================================
# cluster.sh — Hadoop (HDFS + Yarn) 集群启停
# 用法: cluster.sh start | stop | restart
# 注意: 先启动 Zookeeper (zk.sh start)，再启动 Hadoop
# =============================================================

case $1 in
start)
    start-dfs.sh
    start-yarn.sh
    ;;
stop)
    stop-yarn.sh
    stop-dfs.sh
    ;;
restart)
    stop-yarn.sh
    stop-dfs.sh
    start-dfs.sh
    start-yarn.sh
    ;;
*)
    echo "用法: cluster.sh start | stop | restart"
    exit 1
    ;;
esac
