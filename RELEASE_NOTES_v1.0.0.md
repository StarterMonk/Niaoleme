# 🎉 Niaoleme v1.0.0 发布说明

**发布日期：** 2026-05-16  
**版本状态：** 🟢 稳定版  
**APK 大小：** 64.6 MB

---

## 📋 更新内容

### ✅ 新功能

#### 1. 用户认证系统
- ✔️ 用户注册与登录
- ✔️ 手机号/邮箱/用户名多种登录方式
- ✔️ JWT 身份令牌管理
- ✔️ 密码安全加密存储
- ✔️ 账户安全锁定保护

#### 2. 社区厕所库（多人共享）
- ✔️ 附近厕所搜索（基于地理位置）
- ✔️ 厕所详情页面
- ✔️ 用户评价与评论系统
- ✔️ 厕所经纬度地理编码
- ✔️ 实时数据同步（所有用户看到最新数据）
- ✔️ 数据库中央存储（多人共享）

#### 3. 后端 API 服务
- ✔️ RESTful API 架构 (`/api/v1/`)
- ✔️ Spring Boot 框架
- ✔️ MySQL 持久化存储
- ✔️ Redis 缓存加速
- ✔️ 实时健康检查 (`/actuator/health`)
- ✔️ Swagger/Knife4j API 文档

#### 4. 基础健康管理
- ✔️ 本地隐私存储（无云端上传）
- ✔️ 检测记录管理
- ✔️ 简化的位置信息关联

### 🔧 技术基础设施

**前端**
- React Native 0.74.5
- Expo SDK 51.0.39
- React Navigation 路由系统
- AsyncStorage 本地数据库
- Axios HTTP 客户端

**后端**
- Java 17
- Spring Boot 3.x
- Spring Security (JWT)
- MyBatis Plus
- Druid 连接池

**数据库**
- MySQL 8.0（主数据库）
- Redis 7.0（缓存）
- 支持后续微服务分离

**DevOps**
- Docker 容器化
- Docker Compose 编排
- Kubernetes 部署配置
- GitHub Actions CI/CD 就绪
- Prometheus + Grafana 监控

---

## 📦 安装指南

### Android

#### 推荐方案：直接安装 APK
```bash
# 1. 从 GitHub Release 下载 Niaoleme-v1.0.0.apk
# 2. 在 Android 设备上打开文件管理器，找到 APK
# 3. 点击安装，授予必要权限

# 或使用 adb 命令行安装
adb install Niaoleme-v1.0.0.apk
```

#### 备选方案：本地开发环境编译
```bash
# 需要：Node.js, Android SDK, Java 17

git clone https://github.com/StarterMonk/Niaoleme.git
cd Niaoleme/frontend

npm install
npm run build:android
# 或使用 eas-cli
eas build --platform android
```

### iOS（规划中）
- TestFlight 测试版（即将推出）
- App Store 正式版（计划 v1.1.0）

### 云端部署（后端服务）

**快速启动**
```bash
# 1. 在 Linux 服务器上克隆项目
git clone https://github.com/StarterMonk/Niaoleme.git
cd Niaoleme

# 2. 启动所有组件（MySQL + Redis + Backend）
docker compose up -d

# 3. 初始化数据库
mysql -h localhost -u root -p < database/init.sql

# 4. 访问 API
# 本地: http://localhost:8080/api/v1
# 生产: 配置域名 DNS 指向服务器 IP，使用 HTTPS
```

**更多部署详情**
- 参考 [DEPLOYMENT.md](docs/DEPLOYMENT.md)
- Kubernetes 配置: `k8s/`
- Docker Compose: `docker-compose.yml`

---

## 🔐 多人共享数据说明

### 如何实现"像美团一样共享"？

当您的后端部署到服务器后，所有 APP 用户将自动进行**实时数据同步**：

1. **用户 A 上传厕所点位**
   ```
   POST /api/v1/locations/toilets
   {
     "name": "朝阳公园卫生间",
     "latitude": 39.9730,
     "longitude": 116.5028,
     "address": "北京市朝阳区..."
   }
   ```
   → 数据写入服务器 MySQL 数据库

2. **用户 B 搜索附近厕所**
   ```
   GET /api/v1/locations/toilets/nearby?lat=39.9728&lng=116.5030&radius=1000
   ```
   → 立刻返回包括用户 A 上传的最新点位

3. **用户 C 评价厕所**
   ```
   POST /api/v1/locations/toilets/{id}/reviews
   {
     "rating": 5,
     "content": "很干净！"
   }
   ```
   → 其他所有用户刷新后即可看到最新评价

### 数据流
```
APP（用户输入）
    ↓ HTTPS
后端 API (Spring Boot)
    ↓ SQL
MySQL 数据库（共享存储）
    ↓ 
所有 APP 用户共享可见
```

---

## 📱 快速开始

### 1. 首次启动
- 选择登录或注册
- 授予定位权限（用于附近搜索）
- 同意隐私政策

### 2. 上传厕所位置
- 打开应用，进入"社区厕所库"
- 点击"新增点位"
- 输入厕所名称和地址
- 系统自动获取经纬度
- 确认提交

### 3. 搜索附近厕所
- 首页显示附近厕所列表
- 长按地图查看详细信息
- 查看其他用户的评价与照片

### 4. 参与评价
- 点击厕所进入详情页
- 点击"写评价"
- 选择星级和标签
- 发送评价

---

## 🐛 已知限制

| 功能 | 状态 | 预计修复 |
|------|------|---------|
| iOS 支持 | ❌ 未实现 | v1.1.0 |
| AI 健康分析 | 🔄 基础框架 | v1.2.0 |
| 离线模式 | ❌ 未实现 | v1.3.0 |
| 推送通知 | ❌ 未实现 | v1.2.0 |
| 社交分享 | 🔄 部分支持 | v1.1.0 |
| 黑名单用户 | ❌ 未实现 | v1.2.0 |

---

## 🚀 后续版本计划

### v1.1.0（预计 2026-07 发布）
- [ ] iOS APP 发布
- [ ] 推送通知系统
- [ ] 图片上传与展示
- [ ] 厕所营业时间信息
- [ ] 用户等级与徽章

### v1.2.0（预计 2026-09 发布）
- [ ] ChatGPT 健康咨询（可选接入）
- [ ] 数据导出功能
- [ ] 深度分析报告
- [ ] 社群论坛
- [ ] 黑名单与举报系统

### v1.3.0+（后续规划）
- [ ] 离线地图与数据同步
- [ ] 分布式存储优化
- [ ] 微服务架构升级
- [ ] 国际化支持

---

## 💾 数据库架构

### 核心表
- `users` - 用户信息与认证
- `toilet_locations` - 厕所点位（含经纬度）
- `toilet_reviews` - 用户评价与评论
- `health_tests` - 健康检测记录

### 后续规划扩展
- `user_favorites` - 收藏夹
- `location_statistics` - 位置热力图数据
- `user_badges` - 用户等级徽章
- `content_moderation_logs` - 内容审核日志

---

## 🔐 隐私和安全

✅ **已实现**
- 密码 BCrypt 加密存储
- JWT 令牌身份验证
- 数据库连接 SSL/TLS（生产环境）
- 敏感词过滤（评论内容）

⏳ **计划中**
- GDPR 数据导出功能
- 端到端加密（可选）
- 隐私数据自动删除政策

---

## 📞 反馈与支持

- **GitHub Issues**: [StarterMonk/Niaoleme/issues](https://github.com/StarterMonk/Niaolemo/issues)
- **Email**: jimmyhao.dev@gmail.com
- **GitHub**: [@StarterMonk](https://github.com/StarterMonk)

---

## 📄 许可证

本项目采用 **MIT 许可证**  
详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

感谢所有参与开发、测试和反馈的同学！

**开发者**: jimmyhao  
**重庆黑客松**: 2026-05

### 2. 记录尿液
- 打开"记录"标签页
- 选择颜色
- 选择地点（从厕所库中选择）
- 点击保存

### 3. 查看数据
- 打开"首页"查看今日统计
- 打开"分析"查看 AI 分析
- 打开"地图"浏览厕所库

### 4. AI 分析
- 点击"🧠 深度分析"获得健康建议
- 或输入问题与 AI 对话
- 查看周报告和趋势分析

---

## ✅ 已知问题与限制

### 功能完整性
✅ 所有核心功能已实现
✅ AI 分析完全集成
✅ 厕所库完全可用
✅ 本地存储工作正常

### 已知问题
- 无严重问题
- 首次启动可能需要 5-10 秒
- 大数据集下分析可能需要等待

### 后续计划
- 🔄 社交分享功能
- 🗺️ 实时地图集成
- 👥 用户社区功能
- 📈 高级数据分析
- 🌐 多语言支持

---

## 📊 系统要求

| 平台 | 最低版本 | 推荐版本 |
|------|---------|---------|
| **Android** | 5.0+ | 10+ |
| **iOS** | 14+ | 15+ |
| **存储** | 100MB | 200MB+ |
| **内存** | 2GB | 4GB+ |

---

## 🔐 隐私与安全

### 数据保护
✅ 所有用户数据本地存储
✅ 无个人信息云端上传
✅ 支持数据备份和恢复
✅ 支持本地数据删除

### API 安全
✅ HTTPS 加密通信
✅ API 密钥安全管理
✅ 请求超时保护
✅ 错误日志记录

### 隐私政策
详见项目中的隐私政策文档

---

## 🎯 性能指标

| 指标 | 值 |
|------|-----|
| **应用大小** | ~80-100MB (APK) |
| **启动时间** | 2-5 秒 |
| **响应时间** | < 1 秒 |
| **API 延迟** | 1-3 秒 |
| **本地查询** | < 100ms |

---

## 📞 支持与反馈

### 获取帮助
- 📖 查看完整文档
- 🐛 提交 Issue
- 💬 参与讨论

### 报告 Bug
访问 GitHub Issues 页面提交问题

### 功能建议
欢迎在 Issues 中提议新功能

---

## 🙏 致谢

感谢以下项目和服务：
- React Native 社区
- Expo 框架
- ChatAnywhere AI 服务
- 所有测试者和贡献者

---

## 📄 许可证

MIT License - 详见 LICENSE 文件

---

## 🔗 相关链接

| 链接 | URL |
|------|-----|
| **GitHub 仓库** | https://github.com/StarterMonk/Niaoleme |
| **项目主页** | https://github.com/StarterMonk/Niaoleme |
| **问题反馈** | https://github.com/StarterMonk/Niaoleme/issues |
| **讨论区** | https://github.com/StarterMonk/Niaoleme/discussions |

---

## 📈 版本历史

### v1.0.0 (2026-05-06) - 首发版本
✨ 初始发布
- 完整的前端应用
- AI 健康分析
- 社区厕所库
- GitHub Actions CI/CD

### 未来计划
- v1.0.1 - Bug 修复和优化
- v1.1.0 - 新功能（社交分享）
- v1.2.0 - 高级分析功能
- v2.0.0 - 大版本更新（微服务架构）

---

## 🎊 特别感谢

感谢您下载并使用 Niaoleme！

如果您喜欢这个应用，请：
- ⭐ 在 GitHub 上给个 Star
- 📣 分享给朋友
- 💬 提供反馈和建议

---

**Niaoleme - 智能健康管理应用**

*让健康管理变得简单有趣*

🚽 Have Fun Recording Your Pee! ✨

---

**发布信息**
- 发布日期：2026-05-06
- 版本号：1.0.0
- 状态：✅ 稳定版本
- 下载：[GitHub Releases](https://github.com/StarterMonk/Niaoleme/releases)
