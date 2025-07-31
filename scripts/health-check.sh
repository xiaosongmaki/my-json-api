#!/bin/bash

# 健康检查脚本
# 用于验证应用部署后的状态

set -e

HOST=${1:-localhost}
PORT=${2:-3000}
MAX_ATTEMPTS=${3:-10}
WAIT_TIME=${4:-10}

echo "开始健康检查: $HOST:$PORT"
echo "最大尝试次数: $MAX_ATTEMPTS, 等待间隔: ${WAIT_TIME}秒"

for i in $(seq 1 $MAX_ATTEMPTS); do
    echo "尝试 $i/$MAX_ATTEMPTS..."
    
    if curl -f -s "http://$HOST:$PORT/health" > /dev/null; then
        echo "✅ 健康检查通过!"
        
        # 获取详细的健康信息
        echo "=== 健康状态详情 ==="
        curl -s "http://$HOST:$PORT/health" | jq '.' 2>/dev/null || curl -s "http://$HOST:$PORT/health"
        
        # 测试API端点
        echo "=== 测试API端点 ==="
        curl -s "http://$HOST:$PORT/api/status" | jq '.' 2>/dev/null || curl -s "http://$HOST:$PORT/api/status"
        
        exit 0
    else
        echo "❌ 健康检查失败 (尝试 $i/$MAX_ATTEMPTS)"
        if [ $i -lt $MAX_ATTEMPTS ]; then
            echo "等待 ${WAIT_TIME} 秒后重试..."
            sleep $WAIT_TIME
        fi
    fi
done

echo "❌ 健康检查最终失败，已达到最大尝试次数"
exit 1

