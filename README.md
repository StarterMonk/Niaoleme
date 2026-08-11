# 尿了没 - 尿液健康管理App

<div align="center">

![尿了没](https://img.shields.io/badge/尿了没-PeeHealthy-blue?style=for-the-badge&logo=react&logoColor=white)
![React Native](https://img.shields.io/badge/React_Native-0.81-blue?style=for-the-badge&logo=react&logoColor=white)
![Expo SDK](https://img.shields.io/badge/Expo_SDK-54-black?style=for-the-badge&logo=expo&logoColor=white)
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

### 服务人群

- 关注自身健康状况的人群
- 有尿频、尿急等症状的用户
- 需要频繁外出的用户(旅行者、上班族)
- 喜欢小众、有趣的年轻人

### 技术栈

| 技术 | 说明 |
|------|------|
| React Native | 跨平台移动应用开发 |
| Expo SDK 54 | 开发工具链 |
| React Navigation | 页面导航 |
| Expo Location | 定位服务 |
| Node.js + Express | 后端API服务 |
| MongoDB | 数据库 |

### 项目结构

```
├── frontend/              # React Native 前端
│   ├── src/
│   │   └── screens/      # 页面组件
│   ├── assets/            # 静态资源
│   ├── App.js             # 应用入口
│   └── package.json       # 依赖配置
├── README.md              # 项目说明
└── urine-health-app.apk   # APK安装包
```

### 快速开始

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

### 下载APK

点击下方按钮直接下载APK安装包:

[![Download APK](https://img.shields.io/badge/下载-APK安装包-blue?style=for-the-badge&logo=android&logoColor=white)](https://expo.dev/artifacts/eas/JGdM7txLUEQ1SGLSslCKuNMlEIUfGta6uUMVlJ5yriw.apk)

### 开发计划

- [ ] 用户注册/登录系统
- [ ] 真实数据持久化
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

### Target Audience

- People who care about their own health status
- Users with symptoms like frequent urination, urgency
- Users who need to go out frequently (travelers, office workers)
- Young people who like niche and fun apps

### Tech Stack

| Technology | Description |
|------------|-------------|
| React Native | Cross-platform mobile app development |
| Expo SDK 54 | Development toolchain |
| React Navigation | Page navigation |
| Expo Location | Location services |
| Node.js + Express | Backend API service |
| MongoDB | Database |

### Quick Start

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

### Download APK

Click the button below to download the APK:

[![Download APK](https://img.shields.io/badge/Download-APK-blue?style=for-the-badge&logo=android&logoColor=white)](https://expo.dev/artifacts/eas/JGdM7txLUEQ1SGLSslCKuNMlEIUfGta6uUMVlJ5yriw.apk)

### Roadmap

- [ ] User registration/login system
- [ ] Real data persistence
- [ ] Amap (高德地图) integration
- [ ] AI model health analysis
- [ ] Community features
- [ ] Achievement system
- [ ] Push notifications

### Contributing

Issues and Pull Requests are welcome!

### License

MIT License
