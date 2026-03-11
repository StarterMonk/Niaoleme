# 尿了么部署指南

## 概述

本文档介绍如何在不同环境中部署尿了么智能健康检测应用。

## 环境要求

### 基础环境
- **Java**: OpenJDK 17+
- **Maven**: 3.8+
- **MySQL**: 8.0+
- **Redis**: 6.0+
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

### 推荐配置
- **CPU**: 4核心以上
- **内存**: 8GB以上
- **存储**: 100GB以上SSD
- **网络**: 100Mbps以上

## 本地开发环境

### 1. 克隆项目

```bash
git clone https://github.com/your-org/niaolemo.git
cd niaolemo
```

### 2. 启动基础服务

```bash
# Windows
.\start-dev.ps1

# Linux/Mac
./start-dev.sh
```

### 3. 初始化数据库

```bash
# 连接MySQL并执行初始化脚本
mysql -u root -p < database/init.sql
```

### 4. 启动应用

```bash
cd backend
mvn spring-boot:run
```

### 5. 验证部署

访问 http://localhost:8080/actuator/health 检查应用状态。

## Docker 部署

### 1. 构建镜像

```bash
# 构建后端镜像
cd backend
docker build -t niaolemo/core:latest .
```

### 2. 使用 Docker Compose

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f niaolemo-core
```

### 3. 环境变量配置

创建 `.env` 文件：

```env
# 数据库配置
DB_USERNAME=niaolemo_user
DB_PASSWORD=your_secure_password
DB_HOST=mysql
DB_PORT=3306
DB_NAME=niaolemo_core_db

# Redis配置
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# JWT配置
JWT_SECRET=your_jwt_secret_key_here

# MinIO配置
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=your_minio_password

# 应用配置
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
```

## Kubernetes 部署

### 1. 准备集群

确保Kubernetes集群已就绪，并安装以下组件：
- Ingress Controller (Nginx)
- Cert-Manager (可选，用于HTTPS)
- Prometheus + Grafana (可选，用于监控)

### 2. 创建命名空间

```bash
kubectl apply -f k8s/namespace.yaml
```

### 3. 配置密钥

```bash
# 创建数据库密钥
kubectl create secret generic niaolemo-secrets \
  --from-literal=DB_USERNAME=niaolemo_user \
  --from-literal=DB_PASSWORD=your_secure_password \
  --from-literal=REDIS_PASSWORD=your_redis_password \
  --from-literal=JWT_SECRET=your_jwt_secret \
  -n niaolemo
```

### 4. 部署应用

```bash
# 按顺序部署
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

### 5. 验证部署

```bash
# 检查Pod状态
kubectl get pods -n niaolemo

# 检查服务状态
kubectl get svc -n niaolemo

# 查看应用日志
kubectl logs -f deployment/niaolemo-core -n niaolemo
```

## 生产环境部署

### 1. 安全配置

#### 数据库安全
```sql
-- 创建专用数据库用户
CREATE USER 'niaolemo_prod'@'%' IDENTIFIED BY 'complex_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON niaolemo_core_db.* TO 'niaolemo_prod'@'%';

-- 启用SSL连接
ALTER USER 'niaolemo_prod'@'%' REQUIRE SSL;
```

#### Redis安全
```bash
# 配置Redis密码
echo "requirepass your_redis_password" >> /etc/redis/redis.conf

# 禁用危险命令
echo "rename-command FLUSHDB \"\"" >> /etc/redis/redis.conf
echo "rename-command FLUSHALL \"\"" >> /etc/redis/redis.conf
```

### 2. 性能优化

#### JVM参数
```bash
export JAVA_OPTS="-Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

#### 数据库优化
```sql
-- 优化MySQL配置
SET GLOBAL innodb_buffer_pool_size = 2147483648; -- 2GB
SET GLOBAL max_connections = 500;
SET GLOBAL query_cache_size = 134217728; -- 128MB
```

### 3. 监控配置

#### Prometheus配置
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'niaolemo-core'
    static_configs:
      - targets: ['niaolemo-core:8080']
    metrics_path: '/actuator/prometheus'
```

#### Grafana仪表板
导入预配置的Grafana仪表板：
- JVM监控
- 应用性能监控
- 数据库监控
- Redis监控

### 4. 备份策略

#### 数据库备份
```bash
#!/bin/bash
# 每日备份脚本
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u backup_user -p niaolemo_core_db > /backup/niaolemo_${DATE}.sql
gzip /backup/niaolemo_${DATE}.sql

# 保留30天备份
find /backup -name "niaolemo_*.sql.gz" -mtime +30 -delete
```

#### 文件备份
```bash
#!/bin/bash
# 备份上传文件
rsync -av /app/uploads/ /backup/uploads/
```

## 故障排除

### 常见问题

#### 1. 应用启动失败
```bash
# 检查日志
docker logs niaolemo-core
kubectl logs deployment/niaolemo-core -n niaolemo

# 检查配置
docker exec -it niaolemo-core cat /app/config/application.yml
```

#### 2. 数据库连接失败
```bash
# 测试数据库连接
mysql -h mysql-host -u niaolemo_user -p niaolemo_core_db

# 检查网络连通性
telnet mysql-host 3306
```

#### 3. Redis连接失败
```bash
# 测试Redis连接
redis-cli -h redis-host -p 6379 -a password ping
```

#### 4. 内存不足
```bash
# 检查内存使用
free -h
docker stats

# 调整JVM参数
export JAVA_OPTS="-Xms1g -Xmx2g"
```

### 性能调优

#### 1. 数据库优化
- 添加适当索引
- 优化慢查询
- 配置连接池

#### 2. 缓存优化
- 合理设置Redis过期时间
- 使用Redis集群
- 实现多级缓存

#### 3. 应用优化
- 启用HTTP/2
- 配置Gzip压缩
- 使用CDN加速静态资源

## 安全检查清单

- [ ] 更改默认密码
- [ ] 启用HTTPS
- [ ] 配置防火墙
- [ ] 定期更新依赖
- [ ] 配置日志审计
- [ ] 实施访问控制
- [ ] 定期安全扫描
- [ ] 备份验证

## 更新升级

### 滚动更新
```bash
# Kubernetes滚动更新
kubectl set image deployment/niaolemo-core niaolemo-core=niaolemo/core:v1.1.0 -n niaolemo

# 检查更新状态
kubectl rollout status deployment/niaolemo-core -n niaolemo
```

### 回滚操作
```bash
# 查看历史版本
kubectl rollout history deployment/niaolemo-core -n niaolemo

# 回滚到上一版本
kubectl rollout undo deployment/niaolemo-core -n niaolemo
```

## 联系支持

如遇到部署问题，请联系技术支持：
- 邮箱: support@niaolemo.com
- 文档: https://docs.niaolemo.com
- GitHub: https://github.com/your-org/niaolemo/issues