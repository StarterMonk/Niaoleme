# 尿了么 (NiaoLeMo) - 智能健康检测应用

## 项目概述

**尿了么**是一个基于AI的智能健康检测应用，诞生于重庆黑客松比赛。通过智能分析尿液检测结果，结合地理位置服务和社交互动功能，为用户提供便捷的健康管理体验。项目采用混合架构设计，支持从单体应用到微服务的渐进式演进。

## 核心功能

- 🔬 **智能检测**: 基于AI的尿液检测分析
- 📍 **位置服务**: 厕所位置查找和导航
- 👥 **社交互动**: 用户评价和成就系统
- 📊 **健康档案**: 个人健康数据管理
- 🏆 **成就系统**: 激励用户持续使用

## 技术架构

### 第一阶段：核心功能单库
- **框架**: Spring Boot 3.2 + Spring Security
- **数据库**: MySQL 8.0 + MyBatis Plus
- **缓存**: Redis 7.0 + Redisson
- **文件存储**: MinIO
- **监控**: Prometheus + Grafana

### 演进路径
1. **第一阶段**: 单体应用，快速上线
2. **第二阶段**: 地理服务拆分
3. **第三阶段**: 完全微服务架构

## 快速开始

### 环境要求
- Java 17+
- Maven 3.6+
- Docker & Docker Compose

### 本地开发环境搭建

1. **克隆项目**
```bash
git clone <repository-url>
cd chongqing-hackthon-backend
```

2. **启动基础服务**
```bash
# 启动MySQL、Redis、RabbitMQ、MinIO等基础服务
docker-compose up -d mysql redis rabbitmq minio

# 查看服务状态
docker-compose ps
```

3. **初始化数据库**
```bash
# 数据库会自动初始化，也可以手动执行
mysql -h localhost -u root -p < database_design_hybrid.sql
```

4. **启动应用**
```bash
cd stage1-core
./mvnw spring-boot:run
```

5. **访问应用**
- API文档: http://localhost:8080/doc.html
- 应用接口: http://localhost:8080/api/v1
- 监控面板: http://localhost:8081/actuator

### 使用Docker启动完整环境

```bash
# 启动所有服务（包括应用）
docker-compose --profile app up -d

# 查看日志
docker-compose logs -f app-core
```

## 服务端口

| 服务 | 端口 | 描述 |
|------|------|------|
| 核心应用 | 8080 | 主要API服务 |
| 应用监控 | 8081 | Actuator监控端点 |
| MySQL | 3306 | 数据库服务 |
| Redis | 6379 | 缓存服务 |
| RabbitMQ | 5672/15672 | 消息队列/管理界面 |
| MinIO | 9000/9001 | 对象存储/控制台 |
| Prometheus | 9090 | 监控数据收集 |
| Grafana | 3000 | 监控可视化 |

## API文档

启动应用后访问 http://localhost:8080/doc.html 查看完整的API文档。

### 主要API端点

#### 认证相关
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/refresh` - 刷新令牌

#### 健康检测
- `POST /api/v1/health/tests` - 创建检测任务
- `GET /api/v1/health/tests/{id}` - 获取检测结果
- `GET /api/v1/health/tests` - 获取检测历史

#### 位置服务
- `GET /api/v1/locations/toilets/nearby` - 查找附近厕所
- `POST /api/v1/locations/toilets/{id}/reviews` - 添加评价

## 数据库设计

项目采用混合架构的数据库设计，支持渐进式演进：

### 第一阶段表结构
- `users` - 用户基础信息
- `health_tests` - 健康检测记录
- `test_results` - 检测结果详情
- `analysis_reports` - AI分析报告
- `toilet_locations` - 厕所位置信息
- `toilet_reviews` - 用户评价

详细的数据库设计请参考 `database_design_hybrid.sql` 文件。

## 配置说明

### 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `SPRING_PROFILES_ACTIVE` | dev | 运行环境 |
| `DB_HOST` | localhost | 数据库主机 |
| `DB_USERNAME` | hackthon_user | 数据库用户名 |
| `DB_PASSWORD` | hackthon_pass | 数据库密码 |
| `REDIS_HOST` | localhost | Redis主机 |
| `MINIO_ENDPOINT` | http://localhost:9000 | MinIO端点 |
| `JWT_SECRET` | hackthon-jwt-secret-key-2024-chongqing | JWT密钥 |

### 配置文件

- `application.yml` - 基础配置
- `application-dev.yml` - 开发环境配置
- `application-prod.yml` - 生产环境配置

## 开发指南

### 代码结构

```
src/main/java/com/hackthon/core/
├── config/          # 配置类
├── controller/      # REST控制器
├── service/         # 业务逻辑层
├── repository/      # 数据访问层
├── entity/          # 实体类
├── dto/             # 数据传输对象
├── security/        # 安全相关
└── utils/           # 工具类
```

### 开发规范

1. **代码风格**: 遵循阿里巴巴Java开发手册
2. **注释规范**: 使用JavaDoc注释
3. **异常处理**: 统一异常处理机制
4. **日志规范**: 使用SLF4J + Logback
5. **测试覆盖**: 单元测试覆盖率 > 80%

### 添加新功能

1. 创建实体类（Entity）
2. 创建数据访问层（Repository）
3. 创建业务逻辑层（Service）
4. 创建控制器（Controller）
5. 添加单元测试
6. 更新API文档

## 部署指南

### 生产环境部署

1. **构建镜像**
```bash
cd stage1-core
docker build -t hackthon-core:latest .
```

2. **部署到Kubernetes**
```bash
kubectl apply -f k8s/
```

3. **配置监控**
- 配置Prometheus采集
- 设置Grafana仪表板
- 配置告警规则

### 性能优化

1. **数据库优化**
   - 添加适当索引
   - 配置连接池
   - 启用查询缓存

2. **缓存策略**
   - Redis缓存热点数据
   - 本地缓存静态数据
   - CDN加速静态资源

3. **应用优化**
   - JVM参数调优
   - 异步处理长时间任务
   - 连接池配置优化

## 监控和运维

### 健康检查

- 应用健康检查: `/actuator/health`
- 数据库连接检查
- Redis连接检查
- 外部服务依赖检查

### 监控指标

- **应用指标**: QPS、响应时间、错误率
- **系统指标**: CPU、内存、磁盘、网络
- **业务指标**: 用户活跃度、检测成功率

### 日志管理

- 结构化日志输出
- 日志级别动态调整
- 日志聚合和分析

## 故障排查

### 常见问题

1. **数据库连接失败**
   - 检查数据库服务状态
   - 验证连接参数
   - 查看防火墙设置

2. **Redis连接失败**
   - 检查Redis服务状态
   - 验证连接配置
   - 检查网络连通性

3. **文件上传失败**
   - 检查MinIO服务状态
   - 验证存储桶配置
   - 检查文件大小限制

### 日志查看

```bash
# 查看应用日志
docker-compose logs -f app-core

# 查看特定服务日志
docker-compose logs mysql
docker-compose logs redis
```

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交代码变更
4. 创建Pull Request

## 许可证

MIT License

## 联系方式

- 项目维护者: hackthon-team
- 邮箱: hackthon-team@example.com
- 问题反馈: [GitHub Issues](https://github.com/your-repo/issues)