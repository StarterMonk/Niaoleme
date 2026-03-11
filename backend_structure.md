# 重庆黑客松项目后端架构

## 项目结构概览

```
chongqing-hackthon-backend/
├── stage1-core/                    # 第一阶段：核心功能单库
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/hackthon/core/
│   │   │   │   ├── config/         # 配置类
│   │   │   │   ├── controller/     # REST控制器
│   │   │   │   ├── service/        # 业务逻辑层
│   │   │   │   ├── repository/     # 数据访问层
│   │   │   │   ├── entity/         # 实体类
│   │   │   │   ├── dto/            # 数据传输对象
│   │   │   │   ├── utils/          # 工具类
│   │   │   │   └── CoreApplication.java
│   │   │   └── resources/
│   │   │       ├── application.yml
│   │   │       ├── application-dev.yml
│   │   │       ├── application-prod.yml
│   │   │       └── db/migration/   # 数据库迁移脚本
│   │   └── test/                   # 测试代码
│   ├── pom.xml                     # Maven配置
│   └── Dockerfile                  # Docker配置
├── stage2-location/                # 第二阶段：地理服务
├── stage3-microservices/           # 第三阶段：完全微服务
├── shared/                         # 共享组件
│   ├── common/                     # 通用工具
│   ├── security/                   # 安全组件
│   └── migration/                  # 数据迁移工具
├── docker-compose.yml              # 本地开发环境
├── k8s/                           # Kubernetes部署配置
└── docs/                          # 项目文档
```

## 技术栈选择

### 第一阶段核心技术栈
- **框架**: Spring Boot 3.2
- **数据库**: MySQL 8.0
- **缓存**: Redis 7.0
- **消息队列**: RabbitMQ (为后续微服务准备)
- **文件存储**: MinIO (兼容S3)
- **监控**: Micrometer + Prometheus
- **文档**: OpenAPI 3.0 (Swagger)

### 演进路径技术栈
- **第二阶段**: Spring Boot + Spring Cloud Gateway
- **第三阶段**: Spring Cloud Alibaba + Nacos + Sentinel