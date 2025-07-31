#!/bin/bash

# 回滚脚本
# 用于在部署失败时回滚到上一个版本

set -e

COMPOSE_FILE=${1:-/opt/my-json-api/docker-compose.yml}
BACKUP_TAG=${2:-previous}

echo "开始回滚部署..."
echo "使用compose文件: $COMPOSE_FILE"
echo "回滚到标签: $BACKUP_TAG"

# 检查是否存在备份镜像
if ! docker images | grep -q "$BACKUP_TAG"; then
    echo "❌ 错误: 找不到备份镜像标签 '$BACKUP_TAG'"
    echo "可用的镜像:"
    docker images | grep my-json-api || echo "没有找到my-json-api镜像"
    exit 1
fi

# 停止当前服务
echo "停止当前服务..."
docker compose -f "$COMPOSE_FILE" down

# 更新compose文件使用备份镜像
echo "更新compose文件使用备份镜像..."
sed -i "s|image: .*|image: \${DOCKER_USERNAME}/my-json-api:$BACKUP_TAG|" "$COMPOSE_FILE"

# 启动回滚版本
echo "启动回滚版本..."
docker compose -f "$COMPOSE_FILE" up -d

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 验证回滚
echo "验证回滚状态..."
if curl -f -s http://localhost:3000/health > /dev/null; then
    echo "✅ 回滚成功!"
    docker compose -f "$COMPOSE_FILE" ps
else
    echo "❌ 回滚验证失败"
    echo "容器状态:"
    docker compose -f "$COMPOSE_FILE" ps
    echo "容器日志:"
    docker compose -f "$COMPOSE_FILE" logs --tail 50
    exit 1
fi

