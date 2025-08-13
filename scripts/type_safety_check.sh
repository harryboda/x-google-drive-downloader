#!/bin/bash

# Flutter 项目类型安全检查脚本
# 用于自动检测可能的类型转换问题

echo "🔍 Flutter 项目类型安全检查"
echo "================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查计数器
ISSUES=0

# 1. 检查危险的类型转换
echo -e "\n1. 检查危险的类型转换..."
if grep -rn "as num\|as int\|as double" lib/ --include="*.dart" --exclude-dir=".dart_tool"; then
    echo -e "${RED}❌ 发现不安全的强制类型转换!${NC}"
    echo "   请使用自定义解析器替代强制转换"
    ((ISSUES++))
else
    echo -e "${GREEN}✅ 未发现不安全的类型转换${NC}"
fi

# 2. 检查 JSON 模型是否使用自定义解析器  
echo -e "\n2. 检查 JSON 模型自定义解析器使用情况..."
GENERATED_FILES=$(find lib/ -name "*.g.dart" 2>/dev/null)
if [ -z "$GENERATED_FILES" ]; then
    echo -e "${YELLOW}⚠️  未发现生成的 .g.dart 文件${NC}"
else
    CUSTOM_PARSERS=$(grep -l "_parse" $GENERATED_FILES 2>/dev/null | wc -l)
    TOTAL_GENERATED=$(echo "$GENERATED_FILES" | wc -l)
    
    if [ $CUSTOM_PARSERS -gt 0 ]; then
        echo -e "${GREEN}✅ $CUSTOM_PARSERS/$TOTAL_GENERATED 个文件使用自定义解析器${NC}"
    else
        echo -e "${RED}❌ 生成的文件未使用自定义解析器${NC}"
        ((ISSUES++))
    fi
fi

# 3. 检查数值类型一致性
echo -e "\n3. 检查数值类型一致性..."
if grep -rn "percentage.*: [0-9]$\|percentage.*: [0-9][^.]" lib/ --include="*.dart"; then
    echo -e "${YELLOW}⚠️  发现可能的整数百分比，建议使用 double${NC}"
    echo "   例: percentage: 50.0 而非 percentage: 50"
fi

# 4. 检查 copyWith 调用
echo -e "\n4. 检查 copyWith 类型安全..."
COPYWITH_ISSUES=$(grep -rn "copyWith(" lib/ --include="*.dart" | grep -v "\.toDouble\|\.0" | grep "percentage.*:" || true)
if [ ! -z "$COPYWITH_ISSUES" ]; then
    echo -e "${YELLOW}⚠️  发现可能的 copyWith 类型问题:${NC}"
    echo "$COPYWITH_ISSUES"
fi

# 5. 检查错误处理
echo -e "\n5. 检查错误处理完整性..."
PARSE_FUNCTIONS=$(grep -rn "static.*_parse" lib/ --include="*.dart" -A 10 | grep -c "throw\|return null" || echo "0")
if [ $PARSE_FUNCTIONS -eq 0 ]; then
    echo -e "${RED}❌ 自定义解析器缺少错误处理${NC}"
    ((ISSUES++))
else
    echo -e "${GREEN}✅ 发现 $PARSE_FUNCTIONS 个错误处理实例${NC}"
fi

# 6. 检查模型字段注解
echo -e "\n6. 检查模型字段注解..."
JSONKEY_COUNT=$(grep -rn "@JsonKey(fromJson:" lib/ --include="*.dart" | wc -l)
if [ $JSONKEY_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ 发现 $JSONKEY_COUNT 个自定义 JsonKey 注解${NC}"
else
    echo -e "${YELLOW}⚠️  未发现 @JsonKey 自定义注解${NC}"
fi

# 7. 检查构建状态
echo -e "\n7. 检查代码生成状态..."
if [ -f "pubspec.yaml" ]; then
    if flutter packages pub deps | grep -q "build_runner"; then
        echo -e "${GREEN}✅ 发现 build_runner 依赖${NC}"
        
        # 检查是否需要重新生成
        DART_FILES_TIME=$(find lib/ -name "*.dart" -not -name "*.g.dart" -newer $(find lib/ -name "*.g.dart" | head -1) 2>/dev/null | wc -l)
        if [ $DART_FILES_TIME -gt 0 ]; then
            echo -e "${YELLOW}⚠️  检测到模型文件比生成文件新，建议运行 build_runner${NC}"
            echo "   运行: flutter packages pub run build_runner build --delete-conflicting-outputs"
        fi
    else
        echo -e "${YELLOW}⚠️  未发现 build_runner 依赖${NC}"
    fi
fi

# 8. 运行静态分析
echo -e "\n8. 运行 Flutter 静态分析..."
if command -v flutter >/dev/null 2>&1; then
    if flutter analyze --no-congratulate 2>/dev/null; then
        echo -e "${GREEN}✅ 静态分析通过${NC}"
    else
        echo -e "${RED}❌ 静态分析发现问题${NC}"
        ((ISSUES++))
    fi
else
    echo -e "${YELLOW}⚠️  Flutter 命令不可用，跳过静态分析${NC}"
fi

# 总结报告
echo -e "\n================================"
echo -e "🏁 检查完成"

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ 恭喜！未发现类型安全问题${NC}"
    echo -e "${GREEN}   项目符合类型安全开发规范${NC}"
    exit 0
else
    echo -e "${RED}❌ 发现 $ISSUES 个类型安全问题${NC}"
    echo -e "${RED}   请参考 docs/TYPE_SAFETY_GUIDE.md 进行修复${NC}"
    exit 1
fi