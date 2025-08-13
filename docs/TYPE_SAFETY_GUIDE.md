# Flutter 类型安全开发规范

## 概述

本文档记录了在 Google Drive Downloader 项目开发过程中发现的类型安全问题以及对应的解决方案，旨在防止类似的 `type 'String' is not a subtype of type 'num?' in type cast` 错误再次发生。

## 核心原则

### 1. 永不假设外部数据类型
来自外部 API 的数据类型可能不一致，必须实施防御性编程：
- Google OAuth API 可能返回字符串 `"3600"` 而非数字 `3600`
- Google Drive API 的文件大小可能是字符串或数字
- 任何外部数据源都可能改变其数据格式

### 2. 安全优先，性能其次
宁愿增加类型检查和转换的开销，也不要让应用因为类型错误而崩溃。

### 3. 明确的错误处理
区分可恢复错误（返回默认值）和不可恢复错误（抛出明确异常）。

## JSON 模型开发规范

### 必须遵循的规则

#### 1. 所有可能为多种类型的字段必须使用自定义解析器

**✅ 正确示例**:
```dart
@JsonSerializable()
class MyModel {
  @JsonKey(fromJson: _parseNumber)
  final int number;
  
  @JsonKey(fromJson: _parseOptionalNumber) 
  final int? optionalNumber;

  static int _parseNumber(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    throw ArgumentError('无法解析数字值: $value (类型: ${value.runtimeType})');
  }
  
  static int? _parseOptionalNumber(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null; // 无法解析时返回null，不抛出异常
  }
}
```

**❌ 错误示例**:
```dart
@JsonSerializable()
class BadModel {
  final int number; // 依赖自动生成的 (json['number'] as num).toInt()
}
```

#### 2. 数值类型字段的处理模式

**整数字段** (id, count, size 等):
```dart
static int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.parse(value);
  throw ArgumentError('无法解析整数: $value');
}
```

**可选整数字段**:
```dart
static int? _parseOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  return null;
}
```

**浮点数字段** (percentage, rate 等):
```dart
static double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.parse(value);
  throw ArgumentError('无法解析浮点数: $value');
}
```

#### 3. 日期时间字段处理

```dart
@JsonKey(fromJson: _parseDateTime)
final DateTime? createdAt;

static DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null; // 日期解析失败时返回null
    }
  }
  return null;
}
```

### 代码生成最佳实践

#### 1. 始终使用自定义解析器而非依赖自动转换

**生成前** (models/example.dart):
```dart
@JsonSerializable()
class Example {
  @JsonKey(fromJson: _parseId)
  final int id;
  
  @JsonKey(fromJson: _parseSize)
  final int? size;
  
  static int _parseId(dynamic value) { /* 实现 */ }
  static int? _parseSize(dynamic value) { /* 实现 */ }
}
```

#### 2. 每次修改模型后立即重新生成

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 3. 验证生成的代码

检查 `.g.dart` 文件确保使用了自定义解析器:
```dart
// ✅ 正确的生成结果
id: Example._parseId(json['id']),
size: Example._parseSize(json['size']),

// ❌ 错误的生成结果（需要修复）
id: (json['id'] as num).toInt(),
size: (json['size'] as num?)?.toInt(),
```

## 数据流类型安全规范

### 1. 进度更新中的类型一致性

**✅ 正确的进度计算**:
```dart
void updateProgress(int downloaded, int total) {
  final percentage = total > 0 
    ? (downloaded / total * 100).toDouble()  // 明确转换为double
    : 0.0;  // 使用double常量
    
  _progress = _progress.copyWith(
    percentage: percentage,
  );
}
```

**❌ 错误的进度计算**:
```dart
void updateProgress(int downloaded, int total) {
  final percentage = total > 0 
    ? downloaded / total * 100  // 类型不确定
    : 0;  // int vs double 不一致
}
```

### 2. 统一数值类型策略

- **百分比**: 统一使用 `double` (0.0 - 100.0)
- **计数器**: 统一使用 `int`  
- **文件大小**: 统一使用 `int` (字节数)
- **时间戳**: 统一使用 `DateTime`

## 错误处理规范

### 1. 异常分类策略

**关键字段** (必须有值，解析失败应终止):
```dart
static int _parseUserId(dynamic value) {
  // ... 类型检查
  throw ArgumentError('用户ID解析失败: $value'); // 抛出异常
}
```

**可选字段** (可以为空，解析失败返回默认值):
```dart
static int? _parseOptionalSize(dynamic value) {
  // ... 类型检查  
  return null; // 返回null，不抛出异常
}
```

### 2. 错误信息标准格式

```dart
throw ArgumentError('无法解析 [字段名] 值: $value (类型: ${value.runtimeType})');
```

## 开发流程检查清单

### 新增 JSON 模型时

- [ ] 所有数值字段都使用自定义解析器
- [ ] 区分必须字段和可选字段的错误处理策略
- [ ] 运行 `build_runner` 生成序列化代码
- [ ] 检查生成的 `.g.dart` 文件使用了自定义解析器
- [ ] 编写单元测试验证不同输入类型

### 修改现有模型时  

- [ ] 保持字段类型的一致性
- [ ] 更新相应的自定义解析器
- [ ] 重新生成序列化代码
- [ ] 运行相关测试确保向后兼容

### 代码审查检查点

- [ ] 没有使用 `as num` 或 `as int` 强制转换
- [ ] 所有外部数据字段都有类型安全处理
- [ ] 数值运算结果类型明确 (使用 `.toDouble()` 等)
- [ ] 错误处理策略符合字段重要性

## 测试覆盖要求

### JSON 解析测试

每个自定义解析器都必须测试以下场景:

```dart
group('_parseNumber', () {
  test('应该正确解析 int 类型', () {
    expect(Model._parseNumber(42), equals(42));
  });
  
  test('应该正确解析 double 类型', () {
    expect(Model._parseNumber(42.7), equals(42));
  });
  
  test('应该正确解析 String 类型', () {
    expect(Model._parseNumber('42'), equals(42));
  });
  
  test('应该在无效输入时抛出异常', () {
    expect(() => Model._parseNumber('invalid'), throwsA(isA<ArgumentError>()));
    expect(() => Model._parseNumber(null), throwsA(isA<ArgumentError>()));
  });
});
```

## 工具和自动化

### 1. 代码质量检查

在 `analysis_options.yaml` 中添加:
```yaml
linter:
  rules:
    - avoid_dynamic_calls
    - prefer_typing_uninitialized_variables
    - always_specify_types  # 在关键位置明确类型
```

### 2. 构建脚本

创建 `scripts/build_models.sh`:
```bash
#!/bin/bash
echo "重新生成 JSON 序列化代码..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "验证生成的代码..."
grep -r "as num" lib/models/ && echo "⚠️  发现不安全的类型转换!" || echo "✅ 类型转换检查通过"
```

## 总结

通过遵循这些规范，可以有效防止类型转换错误:

1. **预防为主**: 使用自定义解析器处理所有外部数据
2. **防御编程**: 不信任任何外部数据的类型声明  
3. **明确处理**: 区分关键错误和可恢复错误
4. **持续验证**: 通过测试和工具确保规范执行

这些规范已经在解决 `type 'String' is not a subtype of type 'num?' in type cast` 错误的过程中得到验证，应当在所有 Flutter 项目开发中严格执行。