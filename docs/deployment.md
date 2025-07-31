# CI/CD SSH部署指南

## 概述

本项目使用现代化的Docker Context方法进行SSH部署，避免了传统SSH部署的常见问题。

## SSH部署失败的常见原因分析

### 1. 权限问题
- **SSH密钥权限不正确**: 私钥文件权限必须是600
- **用户权限不足**: 部署用户没有Docker操作权限
- **目录权限问题**: 部署目录没有写入权限

### 2. 网络连接问题
- **SSH连接超时**: 服务器防火墙或网络配置问题
- **Docker Registry连接失败**: 无法拉取镜像
- **端口冲突**: 应用端口被占用

### 3. Docker相关问题
- **Docker未运行**: 目标服务器Docker服务未启动
- **镜像拉取失败**: 认证问题或网络问题
- **容器启动失败**: 配置错误或资源不足

### 4. 配置问题
- **环境变量缺失**: 必要的环境变量未设置
- **文件路径错误**: docker-compose.yml路径不正确
- **版本兼容性**: Docker/Docker Compose版本不兼容

## 最佳实践解决方案

### 1. 使用Docker Context代替直接SSH命令
```yaml
# 传统方式（不推荐）
- name: Deploy via SSH
  run: |
    ssh user@server 'docker compose up -d'

# 现代方式（推荐）
- name: Set up Docker Context
  run: |
    docker context create remote --docker "host=ssh://user@server"
    docker context use remote
    docker compose up -d
```

### 2. 分离认证和部署步骤
```yaml
# 先在远程服务器登录Docker Hub
- name: Login to Docker Hub on Remote Server
  uses: appleboy/ssh-action@v1.0.3
  with:
    script: |
      echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

# 然后使用Docker Context部署
- name: Deploy with Docker Context
  run: |
    docker context use remote
    docker compose up -d
```

### 3. 健康检查和验证
```yaml
- name: Health Check
  run: |
    for i in {1..10}; do
      if curl -f http://localhost:3000/health; then
        echo "部署成功!"
        break
      fi
      sleep 10
    done
```

## GitHub Secrets配置

在GitHub仓库的Settings > Secrets and variables > Actions中配置以下secrets：

### 必需的Secrets
- `SERVER_HOST`: 服务器IP地址或域名
- `SERVER_USER`: SSH用户名
- `SERVER_SSH_KEY`: SSH私钥内容
- `DOCKER_USERNAME`: Docker Hub用户名
- `DOCKER_PASSWORD`: Docker Hub密码或访问令牌

### SSH密钥生成
```bash
# 在本地生成SSH密钥对
ssh-keygen -t ed25519 -C "github-actions@yourdomain.com" -f ~/.ssh/deploy_key

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/deploy_key.pub user@your-server

# 将私钥内容复制到GitHub Secrets
cat ~/.ssh/deploy_key
```

## 服务器环境准备

### 1. 安装Docker和Docker Compose
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 添加用户到docker组
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. 创建部署目录
```bash
sudo mkdir -p /opt/my-json-api
sudo chown $USER:$USER /opt/my-json-api
```

### 3. 配置防火墙
```bash
# 允许SSH和应用端口
sudo ufw allow 22
sudo ufw allow 3000
sudo ufw enable
```

## 部署流程

1. **代码推送**: 推送到main分支触发部署
2. **镜像构建**: GitHub Actions构建并推送Docker镜像
3. **服务器准备**: 在远程服务器登录Docker Hub
4. **文件传输**: 传输docker-compose.yml到服务器
5. **服务部署**: 使用Docker Context部署服务
6. **健康检查**: 验证部署是否成功

## 监控和日志

### 查看容器状态
```bash
docker ps | grep my-json-api
```

### 查看应用日志
```bash
docker logs my-json-api --tail 100 -f
```

### 健康检查
```bash
curl http://localhost:3000/health
```

## 故障排除

参见 [troubleshooting.md](./troubleshooting.md) 获取详细的故障排除指南。

