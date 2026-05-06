# 🚀 Niaoleme APP 发布说明

## ✅ 发布完成准备

项目已配置完毕，可以开始构建和发布 APP！

---

## 📋 已完成的配置

### ✅ 配置文件

- **app.json** - Expo 应用配置（名称、版本、图标、包名等）
- **eas.json** - EAS Build 构建配置（APK/IPA 构建规则）
- **package.json** - 前端依赖管理
- **.github/workflows/build-release.yml** - 自动构建工作流

### ✅ 项目结构

```
Niaoleme/
├── frontend/
│   ├── app.json              ✅ Expo 配置
│   ├── eas.json              ✅ 构建配置
│   ├── package.json          ✅ 依赖管理
│   ├── App.js
│   ├── src/
│   │   ├── screens/          (5个主屏幕)
│   │   └── services/         (业务逻辑)
│   └── assets/               (图标和启动画面)
├── .github/
│   └── workflows/
│       └── build-release.yml ✅ CI/CD 工作流
└── APP_BUILD_GUIDE.md        ✅ 详细构建指南
```

---

## 🎯 发布步骤

### 第 1 步：创建 GitHub Release（已完成标签）

**标签已创建**：v1.0.0

现在需要在 GitHub 上创建 Release：

1. **访问 GitHub**
   - 打开：https://github.com/StarterMonk/Niaoleme/releases

2. **创建 Release**
   - 点击"Draft a new release"
   - 选择标签：v1.0.0
   - 标题：🎉 Niaoleme v1.0.0 - Initial Release
   
3. **填写发布说明**
   ```markdown
   ## 🎉 Niaoleme v1.0.0 首发版本
   
   ### ✨ 核心功能
   - 🤖 ChatAnywhere GPT-3.5 AI 健康分析
   - 🚻 社区厕所库（用户可添加、搜索、评分）
   - 📊 周报告生成和数据分析
   - 💬 实时 AI 聊天对话
   - 📝 本地数据隐私存储
   
   ### 📥 下载应用
   
   - **Android APK**：从下方下载或[点击这里](链接到APK)
   - **iOS IPA**：即将上线 App Store
   
   ### 🔄 自动构建
   
   GitHub Actions 将在推送标签后自动构建应用。
   
   构建完成后，APK 文件将自动上传到此 Release。
   
   ### 🐛 已知问题
   - 无
   
   ### 🙏 感谢
   感谢所有贡献者和支持者！
   ```

4. **发布 Release**
   - 勾选"This is a pre-release"（测试版）或不勾选（正式版）
   - 点击"Publish release"

---

## 🤖 自动构建流程

### GitHub Actions 工作流

当推送标签 `v1.0.0` 时，GitHub Actions 自动：

1. ✅ **检出代码** - 拉取最新代码
2. ✅ **安装依赖** - npm install
3. ✅ **Expo 认证** - 使用 EXPO_TOKEN
4. ✅ **构建 APK** - eas build --platform android
5. ✅ **创建 Release** - 自动发布到 GitHub Releases

### 查看构建状态

1. 访问：https://github.com/StarterMonk/Niaoleme/actions
2. 查看最新的工作流运行
3. 点击查看构建日志

---

## 🔐 配置 Expo Token（必需）

### 第 1 步：生成 Expo Token

```bash
# 方式 1: 使用命令行
eas login
eas credentials

# 方式 2: 访问 Expo 网站
# https://expo.dev/settings/tokens
```

### 第 2 步：添加到 GitHub Secrets

1. **访问仓库设置**
   - https://github.com/StarterMonk/Niaoleme/settings/secrets/actions

2. **创建新 Secret**
   - 点击"New repository secret"
   - 名称：`EXPO_TOKEN`
   - 值：粘贴你的 Expo token

3. **保存**

---

## 📱 手动构建应用（测试）

如果不想等待 GitHub Actions，可以本地构建：

### 1. 安装工具

```bash
npm install -g eas-cli
cd frontend
npm install
```

### 2. 登录 Expo

```bash
eas login
```

### 3. 构建 APK

```bash
eas build --platform android --non-interactive
```

### 4. 构建完成

- 终端会显示构建链接
- 或访问 Expo Dashboard 下载

---

## 📥 下载和安装应用

### 从 GitHub Releases 下载

1. 访问：https://github.com/StarterMonk/Niaoleme/releases
2. 找到 v1.0.0 Release
3. 点击下载 `.apk` 文件

### 安装到 Android 设备

#### 方式 1: ADB 安装

```bash
adb install app-release.apk
```

#### 方式 2: 直接安装

1. 将 APK 下载到手机
2. 打开文件管理器找到 APK
3. 点击安装

#### 方式 3: 扫描二维码

- Expo 构建完成后会生成 QR 码
- 用 Android 设备扫描可直接安装

---

## 🚀 下一版本发布

### 更新应用

1. **修改代码**
   ```bash
   # 进行开发和修改
   git add .
   git commit -m "feat: 新功能说明"
   git push origin main
   ```

2. **更新版本号**
   ```bash
   # 编辑 app.json
   "version": "1.0.1"
   ```

3. **创建新标签**
   ```bash
   git tag v1.0.1 -m "Release v1.0.1"
   git push origin v1.0.1
   ```

4. **GitHub Actions 自动构建**
   - 检查 Actions 标签页
   - 等待构建完成
   - Release 自动生成

---

## 📊 构建和发布流程图

```
创建标签
  ↓
git push origin v1.0.0
  ↓
GitHub Actions 触发
  ↓
├─ 检出代码
├─ 安装依赖
├─ Expo 认证
├─ 构建 APK
└─ 创建 Release
  ↓
Release 发布完成
  ↓
用户可下载 APK
```

---

## 🔧 故障排除

### 问题 1: GitHub Actions 构建失败

**查看日志**：
1. 访问 Actions 页面
2. 找到失败的工作流
3. 查看"Logs"标签

**常见原因**：
- EXPO_TOKEN 未配置
- Expo 账户过期
- 网络连接问题

### 问题 2: Expo Token 无效

**解决**：
```bash
eas logout
eas login
eas credentials
```

然后更新 GitHub Secret

### 问题 3: APK 构建失败

**查看详细日志**：
```bash
eas build:list
eas build:view <build-id> --verbose
```

---

## 📝 发布清单

发布前确认：

- [ ] 版本号已更新（app.json）
- [ ] 发布说明已编写
- [ ] Expo Token 已配置
- [ ] 代码已推送到 main
- [ ] 标签已创建和推送
- [ ] GitHub Actions 工作流已运行
- [ ] 构建已成功完成
- [ ] Release 已发布

---

## 🎯 发布时间表

| 步骤 | 时间 |
|------|------|
| 创建标签 | 1 秒 |
| GitHub Actions 运行 | 1-2 分钟 |
| APK 构建 | 5-10 分钟 |
| Release 自动生成 | 自动 |
| 总计 | 10-15 分钟 |

---

## 💡 提示

1. **测试 Release 流程**：先用 pre-release 版本测试
2. **版本控制**：始终使用标签作为版本标记
3. **自动化**：让 GitHub Actions 处理构建
4. **通知用户**：在 Release 说明中清楚地说明新功能

---

## 🔗 快速链接

| 内容 | 链接 |
|------|------|
| GitHub 仓库 | https://github.com/StarterMonk/Niaoleme |
| Releases 页面 | https://github.com/StarterMonk/Niaoleme/releases |
| GitHub Actions | https://github.com/StarterMonk/Niaoleme/actions |
| Expo Dashboard | https://expo.dev/builds |
| 详细构建指南 | APP_BUILD_GUIDE.md |

---

## 📞 需要帮助？

- 📖 查看 APP_BUILD_GUIDE.md 获取详细说明
- 🔍 检查 GitHub Actions 日志了解构建状态
- 🐛 提交 Issue 报告问题

---

**准备发布你的应用了吗？** 🚀

下一步：
1. 配置 Expo Token
2. 在 GitHub 创建 Release
3. 等待自动构建完成
4. 分享下载链接给用户！

🎉 **祝贺！Niaoleme APP 已准备好发布！**
