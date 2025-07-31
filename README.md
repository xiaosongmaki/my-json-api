# My JSON API

一个使用现代化CI/CD流程的简单JSON API项目，展示了SSH部署的最佳实践。

## 🚀 特性

- **现代化部署**: 使用Docker Context进行SSH部署
- **健康检查**: 内置健康检查端点
- **安全性**: 非root用户运行，Helmet安全中间件
- **监控**: 详细的日志和状态端点
- **自动化**: GitHub Actions CI/CD流水线

## 📋 API端点

- `GET /health` - 健康检查
- `GET /api/status` - API状态信息
- `GET /api/users` - 用户列表示例

## 🛠 本地开发

### 前置要求
- Node.js 18+
- Docker & Docker Compose

### 安装和运行
```bash
# 克隆仓库
git clone https://github.com/xiaosongmaki/my-json-api.git
cd my-json-api

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 或使用Docker
docker-compose up --build
```

## 🚢 部署

### CI/CD SSH部署失败原因分析

本项目解决了传统SSH部署的常见问题：

#### 1. 传统SSH部署的问题
- **权限问题**: SSH密钥权限、用户权限、目录权限
- **网络问题**: 连接超时、防火墙阻塞
- **Docker问题**: 服务未运行、镜像拉取失败
- **配置问题**: 环境变量缺失、路径错误

#### 2. 现代化解决方案
- ✅ **Docker Context**: 代替直接SSH命令执行
- ✅ **分离认证**: 先登录Docker Hub，再部署
- ✅ **健康检查**: 自动验证部署状态
- ✅ **错误处理**: 完善的错误处理和回滚机制

### 部署配置

1. **配置GitHub Secrets**:
   - `SERVER_HOST`: 服务器地址
   - `SERVER_USER`: SSH用户名
   - `SERVER_SSH_KEY`: SSH私钥
   - `DOCKER_USERNAME`: Docker Hub用户名
   - `DOCKER_PASSWORD`: Docker Hub密码

2. **服务器准备**:
   ```bash
   # 安装Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # 添加用户到docker组
   sudo usermod -aG docker $USER
   
   # 创建部署目录
   sudo mkdir -p /opt/my-json-api
   sudo chown $USER:$USER /opt/my-json-api
   ```

3. **推送到main分支触发部署**

## 📚 文档

- [部署指南](docs/deployment.md) - 详细的部署配置和最佳实践
- [故障排除](docs/troubleshooting.md) - 常见问题和解决方案

## 🔧 脚本

- `scripts/health-check.sh` - 健康检查脚本
- `scripts/rollback.sh` - 部署回滚脚本

## 🏗 架构

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │   GitHub Actions │    │   Target Server │
│   Repository    │───▶│   CI/CD Pipeline │───▶│   Docker        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Docker Hub     │
                       │   Registry       │
                       └──────────────────┘
```

### 部署流程

1. **构建阶段**: 构建Docker镜像并推送到Docker Hub
2. **准备阶段**: 在目标服务器登录Docker Hub
3. **部署阶段**: 使用Docker Context部署服务
4. **验证阶段**: 健康检查确认部署成功

## 🔒 安全特性

- 非root用户运行容器
- Helmet安全中间件
- SSH密钥认证
- Docker镜像安全扫描
- 最小权限原则

## 📊 监控

- 健康检查端点: `/health`
- 容器健康检查
- 部署状态验证
- 自动日志收集

## 🤝 贡献

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目使用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🆘 支持

如果遇到问题，请：
1. 查看 [故障排除指南](docs/troubleshooting.md)
2. 检查 [GitHub Issues](https://github.com/xiaosongmaki/my-json-api/issues)
3. 创建新的 Issue 描述问题

