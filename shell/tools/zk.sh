#!/bin/bash
# =============================================================
# zk.sh — Zookeeper 集群启停脚本
# 用法: zk.sh start | stop | status
# =============================================================

SERVERS=(hadoop101 hadoop102 hadoop103)
ZK_HOME=/opt/module/zookeeper-3.5.7

if [ $# -lt 1 ]; then
    echo "用法: zk.sh start | stop | status"
    exit 1
fi

case $1 in
start)
    for host in "${SERVERS[@]}"; do
        echo "===== 启动 $host 的 Zookeeper ====="
        ssh "$host" "$ZK_HOME/bin/zkServer.sh start"
    done
    ;;
stop)
    for host in "${SERVERS[@]}"; do
        echo "===== 停止 $host 的 Zookeeper ====="
        ssh "$host" "$ZK_HOME/bin/zkServer.sh stop"
    done
    ;;
status)
    for host in "${SERVERS[@]}"; do
        echo "===== $host ====="
        ssh "$host" "$ZK_HOME/bin/zkServer.sh status"
    done
    ;;
*)
    echo "用法: zk.sh start | stop | status"
    exit 1
    ;;
esac
