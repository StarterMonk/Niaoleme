# 📱 Niaoleme APP 打包和发布指南

## 🎯 目标

将 React Native Expo 项目打包为可下载的移动应用（APK 和 IPA），并在 GitHub Release 中发布。

---

## 📋 前置要求

### 必需工具
- Node.js 18+
- npm 或 yarn
- Expo CLI (`npm install -g expo-cli`)
- EAS CLI (`npm install -g eas-cli`)
- Git 账户和 GitHub 账户

### 账户配置
- Expo 账户（用于打包）
- GitHub 账户（用于发布）

---

## 🚀 快速开始

### 方式 1: 本地打包（推荐用于测试）

#### 1. 登录 Expo

```bash
cd frontend
eas login
# 输入 Expo 账户凭据
```

#### 2. 配置项目

确保 `app.json` 和 `eas.json` 已配置：

```bash
eas build:configure
```

#### 3. 构建 APK（Android）

```bash
eas build --platform android --non-interactive
```

**输出**：构建链接会显示在终端，可在 Expo Dashboard 中查看进度

#### 4. 构建 IPA（iOS）

```bash
eas build --platform ios --non-interactive
```

**注意**：需要 iOS 开发者账户

#### 5. 下载应用

构建完成后，从 Expo Dashboard 或构建输出中下载 `.apk` 或 `.ipa` 文件

---

### 方式 2: GitHub Actions 自动打包（生产环境）

#### 1. 获取 Expo Token

```bash
eas credentials
# 或访问 https://expo.dev/settings/tokens
```

#### 2. 添加 GitHub Secrets

在 GitHub 仓库设置中：
1. 进入 Settings → Secrets and variables → Actions
2. 点击 "New repository secret"
3. 名称：`EXPO_TOKEN`
4. 值：你的 Expo token

#### 3. 触发构建

创建标签并推送，自动触发构建：

```bash
# 创建标签
git tag v1.0.0

# 推送标签
git push origin v1.0.0
```

GitHub Actions 会自动：
- 构建 APK
- 创建 Release
- 上传文件

---

## 📦 应用配置详解

### app.json 配置

```json
{
  "expo": {
    "name": "尿了么",                    // 应用名称
    "slug": "niaoleme-health-app",      // 应用标识
    "version": "1.0.0",                 // 版本号
    "icon": "./assets/icon.png",        // 应用图标
    "ios": {
      "bundleIdentifier": "com.niaoleme.health"  // iOS Bundle ID
    },
    "android": {
      "package": "com.niaoleme.health"          // Android 包名
    }
  }
}
```

### eas.json 构建配置

```json
{
  "build": {
    "production": {
      "android": { "buildType": "apk" },  // 生成 APK
      "ios": { "buildType": "archive" }   // 生成 IPA
    }
  }
}
```

---

## 🔐 环境变量配置

如果应用需要 API 密钥，使用环境变量：

### 1. 创建 .env 文件

```bash
REACT_APP_API_KEY=sk-your-key-here
REACT_APP_API_URL=https://api.chatanywhere.tech/v1/chat/completions
```

### 2. 配置 EAS Secrets

```bash
eas secret:create --scope project --name API_KEY
# 输入值：sk-your-key-here
```

### 3. 在 eas.json 中使用

```json
{
  "build": {
    "production": {
      "env": {
        "REACT_APP_API_KEY": "@API_KEY"
      }
    }
  }
}
```

---

## 📊 构建状态和下载

### 查看构建历史

```bash
# 列出所有构建
eas build:list

# 查看特定构建
eas build:view <build-id>
```

### Expo Dashboard

访问 https://expo.dev/builds 查看：
- 构建状态
- 下载链接
- 构建日志

### GitHub Releases

访问 https://github.com/StarterMonk/Niaoleme/releases 下载：
- 打包的 APK 文件
- 发布说明
- 版本历史

---

## 🛠️ 故障排除

### 问题 1: 构建失败 - Expo 认证

**症状**：`Error: Not authenticated`

**解决**：
```bash
eas logout
eas login
```

### 问题 2: 构建失败 - 依赖问题

**症状**：`Module not found` 错误

**解决**：
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### 问题 3: APK 大小过大

**优化**：
1. 删除不必要的依赖
2. 启用混淆（Android）
3. 使用代码分割

### 问题 4: 无法上传到 Play Store

**需要**：
- 签名密钥
- 开发者账户
- 应用隐私政策

---

## 📱 安装打包的应用

### 安装 APK（Android）

#### 方式 1: ADB 安装
```bash
adb install app-release.apk
```

#### 方式 2: 文件浏览器安装
1. 下载 APK 到设备
2. 打开文件浏览器
3. 找到 APK 文件并点击安装

#### 方式 3: QR 码分享
使用 Expo 提供的 QR 码：
1. 访问 Expo Dashboard
2. 复制 QR 码
3. 用 Android 设备扫描

### 安装 IPA（iOS）

#### 需要：
- 已注册的 Apple Developer 账户
- 设备注册
- 应用签名

#### 方式：
1. 访问 TestFlight（测试）
2. 或通过 App Store 发布

---

## 🚀 发布到应用商店

### Google Play Store

```bash
# 1. 配置签名
eas build --platform android

# 2. 上传
eas submit --platform android
```

### Apple App Store

```bash
# 1. 配置证书
eas build --platform ios

# 2. 上传
eas submit --platform ios
```

---

## 📝 版本管理

### 更新版本号

编辑 `app.json`：
```json
{
  "expo": {
    "version": "1.0.1"  // 更新版本
  }
}
```

编辑 `eas.json`：
```json
{
  "build": {
    "production": {
      "ios": {
        "buildNumber": "1"  // iOS 构建号
      }
    }
  }
}
```

### 创建 Release

```bash
# 创建标签
git tag v1.0.1 -m "Release version 1.0.1"

# 推送标签
git push origin v1.0.1

# GitHub Actions 会自动构建和发布
```

---

## ✅ 发布检查清单

- [ ] app.json 配置正确
- [ ] eas.json 构建配置就绪
- [ ] 环境变量已配置
- [ ] API 密钥已设置
- [ ] 应用图标已准备（1024x1024+）
- [ ] 隐私政策已编写
- [ ] 版本号已更新
- [ ] 测试构建成功
- [ ] GitHub Secrets 已配置
- [ ] 标签已创建并推送

---

## 🔗 相关资源

- [Expo 官方文档](https://docs.expo.dev)
- [EAS Build 文档](https://docs.expo.dev/build/introduction)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [React Native 最佳实践](https://reactnative.dev/docs/getting-started)

---

## 💡 提示

1. **开发阶段**：使用 `preview` 配置快速迭代
2. **测试阶段**：使用 `eas build --non-interactive` 进行 CI/CD 集成
3. **生产阶段**：使用签名密钥和完整配置
4. **版本管理**：使用语义版本控制（MAJOR.MINOR.PATCH）
5. **自动化**：利用 GitHub Actions 自动化构建流程

---

**下一步**：
1. 配置 Expo 账户
2. 测试本地构建
3. 设置 GitHub Secrets
4. 创建第一个发布版本

🚀 **准备发布你的应用！**
