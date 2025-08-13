# 代码审查检查清单

## JSON 模型和序列化

### 🔍 必须检查项

- [ ] **没有使用危险的强制类型转换**
  ```dart
  // ❌ 禁止
  (json['field'] as num).toInt()
  (json['field'] as int) 
  
  // ✅ 必须使用
  @JsonKey(fromJson: _parseField)
  static int _parseField(dynamic value) { /* 安全解析 */ }
  ```

- [ ] **所有数值字段都有自定义解析器**
  - int 字段: `@JsonKey(fromJson: _parseInt)`
  - int? 字段: `@JsonKey(fromJson: _parseOptionalInt)`  
  - double 字段: `@JsonKey(fromJson: _parseDouble)`

- [ ] **解析器覆盖所有输入类型**
  ```dart
  static int _parseInt(dynamic value) {
    if (value is int) return value;        // ✅
    if (value is double) return value.toInt(); // ✅ 
    if (value is String) return int.parse(value); // ✅
    throw ArgumentError('...'); // ✅ 明确错误
  }
  ```

- [ ] **错误处理策略正确**
  - 关键字段: 抛出 `ArgumentError` 
  - 可选字段: 返回 `null`

- [ ] **生成的 .g.dart 文件使用自定义解析器**
  ```dart
  // ✅ 正确
  field: Model._parseField(json['field'])
  
  // ❌ 需要修复
  field: (json['field'] as num).toInt()
  ```

## 数据流和状态管理

### 🔍 类型一致性检查

- [ ] **百分比计算明确使用 double**
  ```dart
  // ✅ 正确
  percentage: (count / total * 100).toDouble()
  
  // ❌ 类型不确定
  percentage: count / total * 100
  ```

- [ ] **统一数值类型策略**
  - 百分比: `double` (0.0-100.0)
  - 计数: `int`
  - 大小: `int` (bytes)

- [ ] **copyWith 调用类型安全**
  ```dart
  // ✅ 明确类型
  progress.copyWith(percentage: 50.0)
  
  // ❌ 可能类型错误  
  progress.copyWith(percentage: 50)
  ```

## Provider 和依赖注入

### 🔍 架构检查

- [ ] **Provider 类型声明正确**
  ```dart
  // ✅ 明确泛型类型
  Consumer<DownloadService>(
    builder: (context, service, child) => ...
  )
  ```

- [ ] **避免循环依赖**
- [ ] **服务初始化顺序正确**

## 错误处理

### 🔍 错误处理检查

- [ ] **catch 块处理具体异常类型**
  ```dart
  try {
    // 操作
  } on FormatException catch (e) {
    // 具体处理
  } on ArgumentError catch (e) {
    // 具体处理  
  } catch (e) {
    // 通用处理
  }
  ```

- [ ] **错误信息包含调试信息**
  ```dart
  throw ArgumentError('无法解析字段值: $value (类型: ${value.runtimeType})');
  ```

## 测试覆盖

### 🔍 测试要求

- [ ] **每个自定义解析器都有单元测试**
- [ ] **测试覆盖所有输入类型**: int, double, String, null
- [ ] **测试边界情况和异常场景**
- [ ] **集成测试验证完整数据流**

## 性能考虑

### 🔍 性能检查

- [ ] **避免不必要的类型转换**
- [ ] **缓存昂贵的计算结果**
- [ ] **使用 const 构造函数**

## 文档和注释

### 🔍 文档检查

- [ ] **复杂的类型转换逻辑有注释说明**
- [ ] **自定义解析器有文档说明处理的输入类型**
- [ ] **异常情况有清晰的文档**

## 构建和部署

### 🔍 构建检查

- [ ] **运行 build_runner 重新生成代码**
  ```bash
  flutter packages pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] **构建无警告和错误**
- [ ] **所有测试通过**
- [ ] **静态分析通过** (`flutter analyze`)

## 审查签字

### 审查者检查清单

- [ ] 我已检查所有 JSON 模型的类型安全性
- [ ] 我已验证数据流中的类型一致性  
- [ ] 我已确认错误处理策略适当
- [ ] 我已检查测试覆盖情况
- [ ] 代码符合项目的类型安全规范

**审查者**: _______________  
**日期**: _______________  
**备注**: _______________

---

## 快速检查命令

```bash
# 检查危险的类型转换
grep -r "as num" lib/ && echo "⚠️ 发现不安全转换!" || echo "✅ 类型转换安全"

# 检查生成的代码
grep -r "_parse" lib/**/*.g.dart && echo "✅ 使用自定义解析器" || echo "⚠️ 未使用自定义解析器"

# 运行所有检查
flutter analyze && flutter test && echo "✅ 所有检查通过"
```