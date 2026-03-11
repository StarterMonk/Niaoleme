# 尿了么项目文件结构

## 📁 完整项目结构

```
niaolemo/
├── 📋 README.md                           # 项目说明文档
├── 📋 README_GITHUB.md                    # GitHub项目介绍
├── 📋 LICENSE                             # 开源协议
├── 📋 .gitignore                          # Git忽略文件
├── 🚀 start-dev.ps1                       # Windows启动脚本
├── 🚀 start-dev.sh                        # Linux/Mac启动脚本
├── 🛑 stop-dev.ps1                        # Windows停止脚本
├── 🐳 docker-compose.yml                  # Docker编排配置
├── 📊 monitoring/                         # 监控配置
│   └── prometheus.yml                     # Prometheus配置
├── 🗄️ database_design_hybrid.sql          # 混合架构数据库设计
├── 🗄️ database_design_microservices.sql   # 微服务架构数据库设计
├── 🗄️ database_design_monolithic.sql      # 单体架构数据库设计
├── 📚 docs/                               # 项目文档
│   ├── PROJECT_SUMMARY.md                 # 项目总结
│   ├── PROJECT_STATUS_CHECK.md            # 项目状态检查
│   ├── DEVELOPMENT_ROADMAP.md             # 开发路线图
│   ├── SECURITY_CHECKLIST.md              # 安全检查清单
│   ├── PROJECT_STRUCTURE.md               # 项目结构说明
│   └── backend_structure.md               # 后端架构说明
├── 🔧 k8s/                                # Kubernetes部署配置
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── stage1-core/                           # 第一阶段核心应用
    ├── 📦 pom.xml                         # Maven配置
    ├── 🐳 Dockerfile                      # Docker配置
    ├── 📋 .gitignore                      # 模块Git忽略
    ├── ⚙️ src/main/resources/              # 配置文件
    │   ├── application.yml                # 主配置文件
    │   ├── application-dev.yml            # 开发环境配置
    │   ├── application-prod.yml           # 生产环境配置
    │   ├── logback-spring.xml             # 日志配置
    │   └── db/migration/                  # 数据库迁移脚本
    │       └── V1__Initial_schema.sql
    └── 💻 src/main/java/com/niaolemo/core/ # Java源代码
        ├── CoreApplication.java           # 应用启动类
        ├── 🏗️ config/                     # 配置类
        │   ├── DatabaseConfig.java       # 数据库配置
        │   ├── SecurityConfig.java       # 安全配置
        │   ├── RedisConfig.java          # Redis配置
        │   ├── SwaggerConfig.java        # API文档配置
        │   └── AsyncConfig.java          # 异步配置
        ├── 🎮 controller/                 # 控制器层
        │   ├── AuthController.java       # 认证控制器
        │   ├── UserController.java       # 用户控制器
        │   ├── HealthController.java     # 健康检测控制器
        │   ├── LocationController.java   # 位置服务控制器
        │   └── AdminController.java      # 管理员控制器
        ├── 🔧 service/                    # 服务层
        │   ├── UserService.java          # 用户服务接口
        │   ├── JwtService.java           # JWT服务
        │   ├── HealthTestService.java    # 健康检测服务
        │   ├── LocationService.java      # 位置服务
        │   ├── FileUploadService.java    # 文件上传服务
        │   ├── NotificationService.java  # 通知服务
        │   └── impl/                     # 服务实现类
        │       ├── UserServiceImpl.java
        │       ├── HealthTestServiceImpl.java
        │       ├── LocationServiceImpl.java
        │       └── FileUploadServiceImpl.java
        ├── 🗄️ repository/                 # 数据访问层
        │   ├── UserRepository.java       # 用户数据访问
        │   ├── HealthTestRepository.java # 健康检测数据访问
        │   ├── TestResultRepository.java # 检测结果数据访问
        │   ├── ToiletLocationRepository.java # 厕所位置数据访问
        │   ├── ToiletReviewRepository.java    # 评价数据访问
        │   └── mapper/                   # MyBatis映射文件
        │       ├── UserMapper.xml
        │       ├── HealthTestMapper.xml
        │       └── LocationMapper.xml
        ├── 📦 entity/                     # 实体类
        │   ├── User.java                 # 用户实体
        │   ├── HealthTest.java           # 健康检测实体
        │   ├── TestResult.java           # 检测结果实体
        │   ├── AnalysisReport.java       # 分析报告实体
        │   ├── ToiletLocation.java       # 厕所位置实体
        │   ├── ToiletReview.java         # 评价实体
        │   └── BaseEntity.java           # 基础实体类
        ├── 📋 dto/                        # 数据传输对象
        │   ├── request/                  # 请求DTO
        │   │   ├── RegisterRequest.java  # 注册请求
        │   │   ├── LoginRequest.java     # 登录请求
        │   │   ├── CreateTestRequest.java # 创建检测请求
        │   │   └── UpdateProfileRequest.java # 更新资料请求
        │   └── response/                 # 响应DTO
        │       ├── ApiResponse.java      # 统一响应格式
        │       ├── LoginResponse.java    # 登录响应
        │       ├── TestResultResponse.java # 检测结果响应
        │       └── UserProfileResponse.java # 用户资料响应
        ├── 🔒 security/                   # 安全相关
        │   ├── JwtAuthenticationFilter.java    # JWT过滤器
        │   ├── JwtAuthenticationEntryPoint.java # JWT入口点
        │   ├── SecurityAuditLogger.java        # 安全审计日志
        │   └── RateLimitInterceptor.java       # 限流拦截器
        ├── 🛠️ utils/                      # 工具类
        │   ├── IpUtils.java              # IP工具类
        │   ├── SensitiveWordFilter.java  # 敏感词过滤器
        │   ├── EncryptionUtils.java      # 加密工具类
        │   ├── ValidationUtils.java     # 验证工具类
        │   └── DateUtils.java            # 日期工具类
        ├── ❌ exception/                  # 异常处理
        │   ├── BusinessException.java    # 业务异常
        │   ├── SecurityException.java    # 安全异常
        │   └── GlobalExceptionHandler.java # 全局异常处理器
        ├── 📊 aspect/                     # 切面编程
        │   ├── LoggingAspect.java        # 日志切面
        │   ├── SecurityAuditAspect.java  # 安全审计切面
        │   └── PerformanceAspect.java    # 性能监控切面
        └── 🧪 test/                       # 测试代码
            ├── java/com/niaolemo/core/
            │   ├── controller/           # 控制器测试
            │   ├── service/              # 服务测试
            │   ├── repository/           # 数据访问测试
            │   └── integration/          # 集成测试
            └── resources/
                ├── application-test.yml  # 测试配置
                └── test-data.sql         # 测试数据
```

## 📋 文件说明

### 🔧 配置文件

| 文件 | 说明 |
|------|------|
| `application.yml` | 主配置文件，包含数据库、Redis、JWT等配置 |
| `application-dev.yml` | 开发环境特定配置 |
| `application-prod.yml` | 生产环境特定配置 |
| `docker-compose.yml` | 本地开发环境Docker编排 |
| `pom.xml` | Maven依赖管理 |

### 🚀 启动脚本

| 文件 | 说明 |
|------|------|
| `start-dev.ps1` | Windows开发环境一键启动 |
| `start-dev.sh` | Linux/Mac开发环境一键启动 |
| `stop-dev.ps1` | Windows开发环境停止脚本 |

### 📚 文档文件

| 文件 | 说明 |
|------|------|
| `README.md` | 项目主要说明文档 |
| `README_GITHUB.md` | GitHub项目介绍页面 |
| `PROJECT_SUMMARY.md` | 项目架构总结 |
| `DEVELOPMENT_ROADMAP.md` | 详细开发路线图 |
| `SECURITY_CHECKLIST.md` | 安全检查清单 |

### 🗄️ 数据库文件

| 文件 | 说明 |
|------|------|
| `database_design_hybrid.sql` | 混合架构数据库设计（推荐） |
| `database_design_microservices.sql` | 微服务架构数据库设计 |
| `database_design_monolithic.sql` | 单体架构数据库设计 |

## 🎯 核心模块说明

### 1. 认证模块 (Auth)
- **AuthController** - 处理注册、登录、登出
- **UserService** - 用户业务逻辑
- **JwtService** - JWT令牌管理
- **SecurityConfig** - Spring Security配置

### 2. 健康检测模块 (Health)
- **HealthController** - 检测相关接口
- **HealthTestService** - 检测业务逻辑
- **AI集成** - 图像分析和结果生成

### 3. 位置服务模块 (Location)
- **LocationController** - 位置相关接口
- **LocationService** - 地理位置业务逻辑
- **地图集成** - 附近厕所搜索和导航

### 4. 安全模块 (Security)
- **敏感词过滤** - 用户输入内容检查
- **IP工具** - 客户端IP获取和分析
- **加密工具** - 数据加密和解密
- **审计日志** - 安全事件记录

### 5. 工具模块 (Utils)
- **通用工具类** - 日期、验证、加密等
- **业务工具类** - 项目特定的工具方法
- **第三方集成** - 外部服务调用封装

## 🔄 开发流程

### 1. 环境准备
```bash
# 克隆项目
git clone <repository-url>
cd niaolemo

# 启动开发环境
.\start-dev.ps1  # Windows
./start-dev.sh   # Linux/Mac
```

### 2. 开发规范
- 遵循包命名规范：`com.niaolemo.core.模块名`
- 使用统一的代码风格和注释规范
- 每个功能模块独立开发和测试
- 提交前运行完整的测试套件

### 3. 部署流程
- **开发环境** - Docker Compose一键部署
- **测试环境** - Kubernetes集群部署
- **生产环境** - 蓝绿部署策略

## 📊 项目统计

- **总文件数** - 约80+个文件
- **代码行数** - 约15,000+行
- **测试覆盖率** - 目标80%+
- **API接口数** - 约30+个接口
- **数据库表数** - 15+张表

## 🎉 下一步计划

1. **完善健康检测功能** - AI模型集成
2. **开发移动端应用** - React Native/Flutter
3. **增加数据分析功能** - 用户健康趋势分析
4. **扩展社交功能** - 健康社区和分享
5. **国际化支持** - 多语言版本

---

这个项目结构设计考虑了可扩展性、可维护性和安全性，为后续的功能扩展和架构演进提供了良好的基础。