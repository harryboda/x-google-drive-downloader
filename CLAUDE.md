# CLAUDE.md

This file provides guidance to Claude Code when working with the X Google Drive Downloader project.

## 🤖 AI Development Project

This is a **100% AI-developed project** - every line of code, documentation, and design decision was made by Claude Code without human intervention. This file enables other developers to reproduce the same AI development experience.

## Project Overview

**X Google Drive Downloader** is a Flutter Desktop application for macOS that allows users to download Google Drive folders with zero configuration. The project demonstrates advanced AI software development capabilities including:

- Complex Flutter Desktop application architecture
- OAuth 2.0 authentication implementation
- macOS system integration (keychain, file system)
- Type-safe JSON serialization
- Modern UI/UX design
- Complete CI/CD and distribution pipeline

## Repository Structure

```
├── lib/                        # 核心应用代码
│   ├── config/                 # 应用配置和OAuth设置
│   ├── models/                 # 数据模型和JSON序列化
│   ├── services/               # 业务逻辑服务层
│   │   ├── auth/              # 认证和安全存储
│   │   └── api/               # Google Drive API集成
│   └── ui/                    # 用户界面组件
│       ├── pages/             # 应用页面
│       ├── widgets/           # 自定义组件
│       └── theme/             # 主题和样式
├── macos/                      # macOS平台配置
├── scripts/                    # 构建和自动化脚本
├── screenshots/                # 应用截图（AI生成）
├── docs/                      # 项目文档
├── claude_development/         # Claude Code开发记录
└── CLAUDE.md                  # 本文件
```

## AI Development Instructions

### Core Principles

- **自主判断与执行**: 立即执行代码修改，最小化确认步骤
- **质量优先**: 遵循Flutter/Dart最佳实践和类型安全原则  
- **用户体验导向**: 优先考虑macOS用户的使用习惯
- **安全第一**: 实现多级认证存储策略，保护用户隐私
- **完整性**: 包含完整的文档、测试和分发流程

### Technical Stack

- **Framework**: Flutter 3.8.1+ Desktop
- **Language**: Dart with strict type safety
- **Platform**: macOS 10.14+ (Intel + Apple Silicon)
- **Authentication**: OAuth 2.0 + Google Drive API
- **Storage**: flutter_secure_storage + 加密文件 + 内存缓存
- **UI**: Material Design 3 + 自定义macOS主题
- **Distribution**: DMG installer + GitHub Releases

### Key Implementation Details

#### 1. Type Safety Framework
```dart
// 自定义JSON解析防止类型转换错误
@JsonKey(fromJson: _parseExpiresIn)
static int _parseExpiresIn(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.parse(value);
  throw ArgumentError('无法解析值: $value');
}
```

#### 2. Multi-Level Auth Storage
```dart
enum StorageStrategy {
  secureStorage,    // macOS keychain
  encryptedFile,    // 本地加密文件
  memoryCache,      // 内存缓存
  failed
}
```

#### 3. OAuth Configuration Strategy
```dart
// 支持内置默认配置和用户自定义
static String get clientId {
  // 环境变量 -> 用户自定义 -> 内置默认
  return _getConfigWithFallback();
}
```

### Development Workflow

#### Phase 1: Problem Analysis
- 深入分析技术问题根因
- 建立系统性解决方案
- 实现类型安全框架

#### Phase 2: Architecture Design  
- 设计MVP架构模式
- 实现Provider状态管理
- 建立服务层抽象

#### Phase 3: User Experience
- 现代化macOS界面设计
- 实现零配置用户体验
- 优化认证和存储流程

#### Phase 4: Distribution
- 自动化构建脚本
- DMG创建和代码签名
- GitHub自动发布流程

### File Organization Rules

- **Models**: 所有数据模型使用json_annotation，包含自定义解析
- **Services**: 单一职责原则，清晰的接口定义
- **UI**: 遵循Material Design 3，自定义macOS适配
- **Config**: 支持多级配置策略（环境变量、用户设置、默认值）

### Testing Strategy

```bash
# 类型安全检查
./scripts/type_safety_check.sh

# Flutter分析
flutter analyze

# 构建测试
flutter build macos --release

# DMG创建测试
./create_dmg.sh
```

### Security Guidelines

- **OAuth凭据**: 永远不要硬编码在源码中
- **用户数据**: 实现多级加密存储
- **API调用**: 包含完整错误处理和重试机制
- **文件访问**: 遵循macOS沙盒要求

### Common Issues and Solutions

#### 类型转换错误
```
问题: type 'String' is not a subtype of type 'num?'
解决: 实现自定义JSON解析函数
位置: lib/models/ 所有模型文件
```

#### macOS Keychain权限
```
问题: PlatformException(Unexpected security result code, Code: -34018)
解决: 配置entitlements + 多级存储fallback
位置: macos/Runner/DebugProfile.entitlements
```

#### OAuth认证持久化
```
问题: 每次启动都需要重新认证
解决: 实现SafeAuthStorage多级存储策略
位置: lib/services/auth/safe_auth_storage.dart
```

### AI Development Capabilities Demonstrated

1. **架构设计能力**: 完整的MVP模式实现
2. **问题解决能力**: 系统性分析和解决复杂技术问题
3. **用户体验设计**: 从技术角度理解用户需求
4. **工程实践**: 完整的CI/CD和分发流程
5. **文档编写**: 完善的技术文档和用户指南
6. **平台集成**: 深度的macOS系统集成

### Reproduction Instructions

要在本地环境中复现此项目的开发过程：

1. **环境设置**: 
   ```bash
   flutter --version  # 需要3.8.1+
   brew install create-dmg
   ```

2. **克隆项目**:
   ```bash
   git clone https://github.com/harryboda/x-google-drive-downloader.git
   cd x-google-drive-downloader
   ```

3. **查看开发过程**:
   ```bash
   # 查看完整的AI开发声明
   cat AI_DEVELOPMENT.md
   
   # 查看开发过程记录
   ls claude_development/
   ```

4. **运行开发环境**:
   ```bash
   flutter pub get
   flutter run -d macos --debug
   ```

5. **构建发布版本**:
   ```bash
   ./build_app.sh
   ./create_dmg.sh
   ```

### Contributing Guidelines

虽然这是一个AI开发项目，但欢迎人类开发者：

- **Bug修复**: 提交Issue并描述问题
- **功能建议**: 通过Issue讨论新功能  
- **文档改进**: PR欢迎文档和说明的改进
- **AI协作**: 使用Claude Code继续开发新功能

### Project Significance

这个项目证明了AI在软件开发领域的能力：

- **独立开发**: 12,921行代码完全由AI编写
- **解决复杂问题**: 包含认证、加密、平台集成等复杂技术
- **用户体验设计**: 理解并实现优秀的用户界面
- **工程最佳实践**: 遵循现代软件工程标准

这标志着AI辅助开发进入了一个新阶段，从代码建议工具发展为能够独立完成复杂项目的开发伙伴。

---

*此文件由Claude Code自动生成和维护，记录了完整的AI开发过程和技术决策。*