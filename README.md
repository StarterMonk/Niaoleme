# 尿了没 - 尿液健康管理App

<div align="center">

![尿了没](https://img.shields.io/badge/尿了没-PeeHealthy-blue?style=for-the-badge&logo=react&logoColor=white)
![React Native](https://img.shields.io/badge/React_Native-0.81-blue?style=for-the-badge&logo=react&logoColor=white)
![Expo SDK](https://img.shields.io/badge/Expo_SDK-54-black?style=for-the-badge&logo=expo&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18-green?style=for-the-badge&logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-7-green?style=for-the-badge&logo=mongodb&logoColor=white)
![CI](https://img.shields.io/badge/CI-passing-brightgreen?style=for-the-badge&logo=github-actions&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-24%20passed-brightgreen?style=for-the-badge&logo=jest&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**一款关注泌尿健康的智能应用,帮你记录、分析、找厕所**

[![Download APK](https://img.shields.io/badge/下载-APK安装包-blue?style=for-the-badge&logo=android&logoColor=white)](https://expo.dev/artifacts/eas/JGdM7txLUEQ1SGLSslCKuNMlEIUfGta6uUMVlJ5yriw.apk)

</div>

---

## 中文

### 项目简介

**尿了没** 是一款专注于泌尿系统健康管理的移动应用。我们相信,关注每一次嘘嘘,就是关注自己的健康。

无论是想要追踪排尿习惯、分析健康状况,还是在外出时急需找厕所, **尿了没** 都能帮到你。

### 核心功能

- **尿液记录** - 一键记录排尿次数、尿量、颜色、时间、地点等健康指标
- **健康评分** - AI智能分析你的泌尿健康状况,给出个性化建议
- **找厕所** - 实时查看附近公共厕所位置,查看其他用户评价
- **厕所评价** - 标注公共厕所,评价卫生条件、硬件设施
- **趋势分析** - 可视化展示排尿频率、饮水量等健康趋势
- **广告位** - 为成人纸尿裤、女性卫生用品等提供精准广告投放

### 技术栈

| 技术 | 说明 |
|------|------|
| React Native | 跨平台移动应用开发 |
| Expo SDK 54 | 开发工具链 |
| React Navigation | 页面导航 |
| Expo Location | 定位服务 |
| Node.js + Express | 后端API服务 |
| MongoDB + Mongoose | 数据库 + ODM |
| JWT | 用户认证 |
| Helmet + Rate Limit | 安全防护 |
| Jest + Supertest | 测试框架 |
| ESLint | 代码规范 |
| GitHub Actions | CI/CD |
| Docker | 容器化部署 |

### 项目结构

```
├── frontend/                  # React Native 前端
│   ├── src/
│   │   ├── screens/          # 页面组件
│   │   ├── components/       # 通用组件 (ErrorBoundary, LoadingStates)
│   │   ├── services/         # API服务层 (api, auth, record, toilet)
│   │   ├── constants/        # 主题常量
│   │   └── utils/            # 工具函数 (logger, validators)
│   ├── assets/               # 静态资源
│   ├── App.js                # 应用入口 (ErrorBoundary + GestureHandler)
│   └── package.json          # 依赖配置
├── backend/                   # Node.js 后端
│   ├── src/
│   │   ├── config/           # 配置 (db, env)
│   │   ├── models/           # 数据模型 (User, UrineRecord, Toilet)
│   │   ├── routes/           # API路由 (auth, records, toilets)
│   │   ├── controllers/      # 控制器
│   │   └── middleware/       # 中间件 (auth, errorHandler, rateLimit)
│   ├── tests/                # 测试套件 (24 tests)
│   ├── server.js             # 服务入口
│   ├── Dockerfile            # Docker配置 (non-root + healthcheck)
│   └── package.json          # 依赖配置
├── .github/workflows/        # GitHub Actions CI
├── docker-compose.yml        # Docker编排
└── README.md                 # 项目说明
```

### 快速开始

#### 前端开发

```bash
# 1. 克隆项目
git clone https://github.com/StarterMonk/Niaoleme.git

# 2. 进入前端目录
cd frontend

# 3. 安装依赖
npm install

# 4. 启动开发服务器
npm start

# 5. 在 Expo Go 中扫描二维码即可预览
```

#### 后端开发

```bash
# 1. 进入后端目录
cd backend

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env 文件,配置 MongoDB 连接字符串和 JWT_SECRET

# 4. 启动后端服务
npm run dev

# 5. 运行测试
npm test

# 6. 代码检查
npm run lint
```

#### Docker 部署

```bash
# 一键启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### API 接口

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/v1/auth/register | 用户注册 | 否 |
| POST | /api/v1/auth/login | 用户登录 | 否 |
| GET | /api/v1/auth/profile | 获取用户信息 | 是 |
| POST | /api/v1/records | 创建嘘嘘记录 | 是 |
| GET | /api/v1/records | 获取记录列表 | 是 |
| GET | /api/v1/records/stats | 获取统计数据 | 是 |
| DELETE | /api/v1/records/:id | 删除记录 | 是 |
| GET | /api/v1/toilets | 获取附近厕所 | 否 |
| GET | /api/v1/toilets/:id | 获取厕所详情 | 否 |
| POST | /api/v1/toilets | 添加厕所 | 是 |
| POST | /api/v1/toilets/:id/rate | 评价厕所 | 是 |
| GET | /api/v1/health | 健康检查 | 否 |

### 下载APK

点击下方按钮直接下载APK安装包:

[![Download APK](https://img.shields.io/badge/下载-APK安装包-blue?style=for-the-badge&logo=android&logoColor=white)](https://expo.dev/artifacts/eas/JGdM7txLUEQ1SGLSslCKuNMlEIUfGta6uUMVlJ5yriw.apk)

### 开发计划

- [x] 用户注册/登录系统
- [x] 真实数据持久化
- [x] 安全加固 (Helmet, Rate Limit, Input Validation)
- [x] 测试套件 (24 tests)
- [x] CI/CD (GitHub Actions)
- [ ] 高德地图集成
- [ ] AI大模型健康分析
- [ ] 社区功能
- [ ] 成就系统
- [ ] 推送提醒

### 贡献

欢迎提交Issue和Pull Request!

### 许可证

MIT License

---

## English

### Introduction

**PeeHealthy** is a mobile application focused on urinary system health management. We believe that paying attention to every pee is paying attention to your health.

Whether you want to track urination habits, analyze health conditions, or find a toilet urgently when you're out, **PeeHealthy** can help.

### Core Features

- **Urine Recording** - One-click recording of urination frequency, volume, color, time, location, and other health indicators
- **Health Score** - AI-powered analysis of your urinary health status with personalized suggestions
- **Find Toilets** - Real-time nearby public toilet locations with user reviews
- **Toilet Rating** - Mark public toilets and rate hygiene conditions and facilities
- **Trend Analysis** - Visual display of urination frequency, water intake, and other health trends
- **Ad Placement** - Targeted advertising for adult diapers, feminine hygiene products, etc.

### Tech Stack

| Technology | Description |
|------------|-------------|
| React Native | Cross-platform mobile app development |
| Expo SDK 54 | Development toolchain |
| React Navigation | Page navigation |
| Expo Location | Location services |
| Node.js + Express | Backend API service |
| MongoDB + Mongoose | Database + ODM |
| JWT | User authentication |
| Helmet + Rate Limit | Security |
| Jest + Supertest | Testing framework |
| ESLint | Code linting |
| GitHub Actions | CI/CD |
| Docker | Containerized deployment |

### Quick Start

#### Frontend Development

```bash
# 1. Clone the project
git clone https://github.com/StarterMonk/Niaoleme.git

# 2. Enter frontend directory
cd frontend

# 3. Install dependencies
npm install

# 4. Start development server
npm start

# 5. Scan the QR code in Expo Go to preview
```

#### Backend Development

```bash
# 1. Enter backend directory
cd backend

# 2. Install dependencies
npm install

# 3. Configure environment variables
cp .env.example .env
# Edit .env file, configure MongoDB connection and JWT_SECRET

# 4. Start backend server
npm run dev

# 5. Run tests
npm test

# 6. Lint code
npm run lint
```

#### Docker Deployment

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### API Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /api/v1/auth/register | Register user | No |
| POST | /api/v1/auth/login | Login user | No |
| GET | /api/v1/auth/profile | Get user profile | Yes |
| POST | /api/v1/records | Create record | Yes |
| GET | /api/v1/records | List records | Yes |
| GET | /api/v1/records/stats | Get statistics | Yes |
| DELETE | /api/v1/records/:id | Delete record | Yes |
| GET | /api/v1/toilets | Get nearby toilets | No |
| GET | /api/v1/toilets/:id | Get toilet details | No |
| POST | /api/v1/toilets | Add toilet | Yes |
| POST | /api/v1/toilets/:id/rate | Rate toilet | Yes |
| GET | /api/v1/health | Health check | No |

### Download APK

Click the button below to download the APK:

[![Download APK](https://img.shields.io/badge/Download-APK-blue?style=for-the-badge&logo=android&logoColor=white)](https://expo.dev/artifacts/eas/JGdM7txLUEQ1SGLSslCKuNMlEIUfGta6uUMVlJ5yriw.apk)

### Roadmap

- [x] User registration/login system
- [x] Real data persistence
- [x] Security hardening (Helmet, Rate Limit, Input Validation)
- [x] Test suite (24 tests)
- [x] CI/CD (GitHub Actions)
- [ ] Amap (高德地图) integration
- [ ] AI model health analysis
- [ ] Community features
- [ ] Achievement system
- [ ] Push notifications

### Contributing

Issues and Pull Requests are welcome!

### License

MIT License
