# CI/CD SSH部署故障排除指南

## 常见问题和解决方案

### 1. SSH连接问题

#### 问题: "Permission denied (publickey)"
```
Error: Process completed with exit code 255.
ssh: Permission denied (publickey)
```

**解决方案:**
1. 检查SSH密钥格式是否正确
2. 确保私钥没有密码保护
3. 验证公钥已添加到服务器的`~/.ssh/authorized_keys`

```bash
# 在服务器上检查authorized_keys
cat ~/.ssh/authorized_keys

# 检查SSH密钥权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

#### 问题: "Host key verification failed"
```
Error: Host key verification failed.
```

**解决方案:**
在GitHub Actions中添加服务器到known_hosts：
```yaml
- name: Add server to known_hosts
  run: |
    mkdir -p ~/.ssh
    ssh-keyscan -H ${{ secrets.SERVER_HOST }} >> ~/.ssh/known_hosts
```

### 2. Docker相关问题

#### 问题: "Cannot connect to the Docker daemon"
```
Error: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**解决方案:**
1. 确保Docker服务正在运行
2. 检查用户是否在docker组中

```bash
# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 添加用户到docker组
sudo usermod -aG docker $USER
# 重新登录或运行
newgrp docker
```

#### 问题: "docker: command not found"
```
Error: docker: command not found
```

**解决方案:**
安装Docker：
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 3. 镜像拉取问题

#### 问题: "pull access denied"
```
Error: pull access denied for username/image, repository does not exist or may require 'docker login'
```

**解决方案:**
1. 确保Docker Hub凭据正确
2. 检查镜像名称是否正确
3. 验证Docker登录状态

```bash
# 手动登录测试
echo "password" | docker login -u username --password-stdin

# 检查登录状态
docker info | grep Username
```

#### 问题: "no space left on device"
```
Error: no space left on device
```

**解决方案:**
清理Docker资源：
```bash
# 清理未使用的镜像
docker image prune -a -f

# 清理未使用的容器
docker container prune -f

# 清理未使用的卷
docker volume prune -f

# 清理构建缓存
docker builder prune -a -f
```

### 4. 网络问题

#### 问题: "port is already allocated"
```
Error: driver failed programming external connectivity on endpoint: bind for 0.0.0.0:3000 failed: port is already allocated
```

**解决方案:**
1. 停止占用端口的服务
2. 更改应用端口

```bash
# 查找占用端口的进程
sudo lsof -i :3000
sudo netstat -tulpn | grep :3000

# 停止占用端口的容器
docker ps | grep 3000
docker stop <container_id>
```

### 5. 健康检查失败

#### 问题: 健康检查超时
```
Error: Health check failed after 10 attempts
```

**解决方案:**
1. 检查应用启动时间
2. 增加健康检查超时时间
3. 检查应用日志

```bash
# 查看容器日志
docker logs my-json-api --tail 100

# 手动测试健康检查端点
curl -v http://localhost:3000/health

# 检查容器内部
docker exec -it my-json-api sh
```

### 6. Docker Context问题

#### 问题: "context does not exist"
```
Error: context "remote" does not exist
```

**解决方案:**
重新创建Docker Context：
```bash
# 删除现有context
docker context rm remote || true

# 重新创建context
docker context create remote --docker "host=ssh://user@server"

# 验证context
docker context ls
```

### 7. 文件权限问题

#### 问题: "permission denied" 在容器内
```
Error: EACCES: permission denied, open '/app/file'
```

**解决方案:**
检查Dockerfile中的用户设置：
```dockerfile
# 确保正确设置用户权限
RUN chown -R nodejs:nodejs /app
USER nodejs
```

### 8. 环境变量问题

#### 问题: 应用配置错误
```
Error: Missing required environment variable
```

**解决方案:**
1. 检查.env文件
2. 验证docker-compose.yml中的环境变量
3. 确保GitHub Secrets正确设置

```yaml
# 在docker-compose.yml中明确设置环境变量
environment:
  - NODE_ENV=production
  - PORT=3000
```

## 调试技巧

### 1. 启用详细日志
```yaml
# 在GitHub Actions中启用调试
- name: Debug SSH Connection
  uses: appleboy/ssh-action@v1.0.3
  with:
    debug: true
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
```

### 2. 手动测试部署步骤
```bash
# 在服务器上手动执行部署步骤
cd /opt/my-json-api
docker compose pull
docker compose up -d
docker compose ps
docker logs my-json-api
```

### 3. 检查系统资源
```bash
# 检查磁盘空间
df -h

# 检查内存使用
free -h

# 检查CPU使用
top
```

### 4. 网络连接测试
```bash
# 测试从服务器到Docker Hub的连接
curl -I https://registry-1.docker.io/

# 测试SSH连接
ssh -T user@server

# 测试应用端口
telnet localhost 3000
```

## 预防措施

1. **定期清理**: 设置定期清理Docker资源的cron任务
2. **监控**: 设置服务器资源监控
3. **备份**: 定期备份重要配置文件
4. **测试**: 在staging环境中测试部署流程
5. **文档**: 保持部署文档更新

## 联系支持

如果问题仍然存在，请提供以下信息：
- 错误日志的完整输出
- 服务器系统信息 (`uname -a`)
- Docker版本 (`docker --version`)
- 网络配置信息

