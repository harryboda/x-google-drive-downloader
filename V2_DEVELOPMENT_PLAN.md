# v2.0 开发计划：用户体验优化版本

## 🎯 核心目标

将应用从"开发者工具"升级为"用户友好的独立应用"

### 用户体验目标
- **一次配置，持久使用**：用户首次配置后，无需重复设置
- **即开即用**：双击应用图标即可启动，无需命令行
- **独立分发**：可以打包分享给其他用户直接使用

## 🔍 当前问题深度分析

### 1. Secure Storage 权限问题

**错误现象**:
```
flutter: Failed to save auth to secure storage: PlatformException(Unexpected security result code, Code: -34018, Message: A required entitlement isn't present., -34018, null)
```

**根本原因**:
- macOS错误码 -34018 = `errSecMissingEntitlement`
- 当前 entitlements 缺少 keychain 访问权限
- 之前为了避免签名问题移除了 keychain 权限

**影响**:
- 无法保存OAuth令牌
- 每次启动都需要重新认证
- 用户体验极差

### 2. OAuth 配置问题

**当前模式**:
```bash
--dart-define=GOOGLE_CLIENT_ID="$PROD_CLIENT_ID" \
--dart-define=GOOGLE_CLIENT_SECRET="$PROD_CLIENT_SECRET"
```

**问题**:
- 需要修改脚本配置
- 无法独立分发
- 用户无法自己配置OAuth

### 3. 应用分发问题

**当前状态**:
- 需要Flutter开发环境
- 必须通过脚本启动
- 无法作为独立.app分发

## 📋 v2.0 技术解决方案

### Phase 1: 修复认证持久化 🔧

#### 1.1 修复 macOS Entitlements
```xml
<!-- 添加 keychain 访问权限 -->
<key>com.apple.security.keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.yourcompany.gdrive-downloader</string>
</array>
```

#### 1.2 实现备用存储方案
- **主要方案**: 修复 flutter_secure_storage
- **备用方案**: 使用加密的本地文件存储
- **兜底方案**: 内存中的会话缓存

```dart
class SafeAuthStorage {
  // 尝试secure storage
  // 失败时回退到加密文件
  // 再失败时使用会话缓存
}
```

### Phase 2: OAuth配置内置化 ⚙️

#### 2.1 默认OAuth配置
```dart
class AppConfig {
  // 内置默认的OAuth配置（开发者账号）
  static const String defaultClientId = "YOUR_GOOGLE_CLIENT_ID";
  static const String defaultClientSecret = "YOUR_GOOGLE_CLIENT_SECRET";
  
  // 支持用户自定义配置
  static String? customClientId;
  static String? customClientSecret;
}
```

#### 2.2 应用内OAuth配置界面
```dart
class OAuthSettingsPage extends StatelessWidget {
  // 让高级用户可以配置自己的OAuth凭据
  // 大部分用户使用默认配置
}
```

### Phase 3: 独立应用构建 📦

#### 3.1 自签名证书生成
```bash
# 创建自签名证书用于开发分发
security create-certificate \
  -k ~/Library/Keychains/login.keychain \
  -s "Google Drive Downloader" \
  -S ca \
  -Z sha256
```

#### 3.2 应用打包优化
```bash
# 构建独立.app包
flutter build macos --release --split-debug-info=build/debug-info
```

#### 3.3 分发包创建
- 创建DMG安装包
- 包含使用说明
- 一键安装体验

### Phase 4: 用户体验优化 ✨

#### 4.1 启动流程优化
```dart
class AppBootstrap {
  // 1. 检查认证状态
  // 2. 自动进入主界面或引导配置
  // 3. 智能处理各种异常情况
}
```

#### 4.2 智能链接处理
```dart
class SmartLinkHandler {
  // 1. 自动检测剪贴板中的Google Drive链接
  // 2. 支持拖拽链接到应用
  // 3. URL scheme支持（gdrive://）
}
```

## 🛠️ 实现优先级

### 优先级 1 (必须解决)
1. **修复 Secure Storage 权限问题**
   - 重新配置 entitlements
   - 实现备用存储方案
   - 测试认证持久化

### 优先级 2 (用户体验关键)
2. **内置OAuth配置**
   - 使用开发者的OAuth凭据作为默认配置
   - 移除对环境变量的依赖
   - 支持用户自定义配置（高级选项）

### 优先级 3 (分发必需)
3. **独立应用构建**
   - 配置应用签名
   - 构建可分发的.app包
   - 创建安装说明

### 优先级 4 (体验优化)
4. **用户体验提升**
   - 启动流程优化
   - 智能链接处理
   - 错误处理改进

## 📊 成功指标

### 技术指标
- ✅ 认证成功缓存率 > 95%
- ✅ 应用启动成功率 > 99%
- ✅ 独立安装成功率 > 90%

### 用户体验指标
- ✅ 首次使用配置时间 < 2分钟
- ✅ 日常使用启动时间 < 5秒
- ✅ 零命令行依赖

## 🚀 开发里程碑

### Milestone 1: 认证修复 (Week 1)
- 修复secure storage权限
- 实现认证持久化
- 测试多次启动免登录

### Milestone 2: 配置内置 (Week 1-2)  
- 内置OAuth配置
- 移除脚本依赖
- 实现应用内配置选项

### Milestone 3: 独立构建 (Week 2)
- 配置应用签名
- 构建分发包
- 测试独立安装

### Milestone 4: 体验优化 (Week 2-3)
- 完善用户引导
- 优化错误处理  
- 性能调优

## 🔧 开发环境准备

```bash
# 1. 生成自签名证书
./scripts/setup_signing.sh

# 2. 配置构建环境
./scripts/setup_build.sh

# 3. 运行完整测试
./scripts/test_full_flow.sh
```

---

**v2.0的核心价值**: 将应用从"需要技术知识的开发工具"转变为"普通用户可以轻松使用的独立应用"。