# ExpressionKit

一个轻量级、基于接口的 C++ 表达式解析和求值库，支持 Swift 并提供词法序列分析功能

## 🚀 核心特性

- **基于接口的变量读写**：通过 IEnvironment 接口灵活访问变量和函数
- **预解析 AST 执行**：支持表达式预编译，实现高效重复执行
- **词法序列分析**：可选的词法单元收集，用于语法高亮和高级功能
- **类型安全**：强类型的 Value 系统，支持数值、布尔和字符串类型
- **完整的运算符支持**：全面覆盖算术、比较和逻辑运算符
- **基于异常的错误处理**：清晰的错误信息和健壮的异常机制
- **零依赖**：仅依赖 C++ 标准库
- **Swift 支持**：提供简洁的 Swift API，支持 Swift Package Manager 集成

### 🎯 快速开始 - 试用演示程序！

**想要立即体验 ExpressionKit？** 直接运行我们的交互式示例：

| 目标程序 | 描述 | 命令 |
|--------|-------------|---------|
| 🖥️ **ExpressionDemo** | 带语法高亮的交互式命令行界面 | `cd CPP && cmake . && make ExpressionDemo && ./ExpressionDemo` |
| 🧪 **ExprTKTest** | 全面的单元测试套件 | `cd CPP && cmake . && make ExprTKTest && ./ExprTKTest` |
| 🎨 **TokenDemo** | 用于语法高亮的词法分析演示 | `cd CPP && cmake . && make TokenDemo && ./TokenDemo` |
| 🍎 **Swift 示例** | Swift API 演示 | `cd Swift/Examples/SwiftExample && swift run` |

➡️ **[查看详细说明](#quick-start-demo-and-testing)**

## 🧪 测试状态

[![测试状态检查](https://github.com/Cloudage/ExpressionKit/actions/workflows/test-status-check.yml/badge.svg)](https://github.com/Cloudage/ExpressionKit/actions/workflows/test-status-check.yml)

### 自动化测试

本仓库使用 GitHub Actions 进行自动化测试，确保代码质量和可靠性：

- **C++ 核心库**：使用 Catch2 框架进行全面测试
- **Swift 包装器**：通过 Swift Package Manager 使用 XCTest 框架测试

**查看最新测试结果**：点击上方徽章或访问 [Actions 标签页](https://github.com/Cloudage/ExpressionKit/actions/workflows/test-status-check.yml) 查看详细测试结果，包括测试数量、断言和执行摘要。

### 本地运行测试

ExpressionKit 包含 C++ 和 Swift 的全面测试套件和交互式演示：

```bash
# 运行所有测试（C++ 和 Swift）
./scripts/run_all_tests.sh

# 运行单个测试套件
./scripts/run_cpp_tests.sh      # 仅 C++ 测试
./scripts/run_swift_tests.sh    # 仅 Swift 测试
```

**💡 想要试用交互式演示？** 请查看下方的 [演示和测试目标部分](#-实时体验---演示和测试目标) 获取实际操作示例！

## 🤖 AI 生成代码说明

**重要提示：本项目中的代码主要由 AI 工具（如 GitHub Copilot）生成，在人工指导和审查下完成。**

代码遵循现代 C++ 最佳实践，提供了一个简洁的、基于接口的表达式求值系统。

## 🛠️ 安装和配置

### Swift 项目（推荐）

ExpressionKit 可以通过 **Swift Package Manager** 轻松集成到 Swift 项目中：

#### 方式 1：Xcode 集成
1. 打开你的 Xcode 项目
2. 选择 **File** → **Add Package Dependencies**
3. 输入仓库 URL：`https://github.com/Cloudage/ExpressionKit.git`
4. 选择版本（从 `1.0.0` 开始）

#### 方式 2：Package.swift
在你的 `Package.swift` 依赖中添加：

```swift
dependencies: [
    .package(url: "https://github.com/Cloudage/ExpressionKit.git", from: "1.0.0")
]
```

然后导入并使用：

```swift
import ExpressionKit

// 直接求值
let result = try Expression.eval("2 + 3 * 4")  // 14.0

// 解析一次，执行多次（高性能）
let expression = try Expression.parse("(a + b) * c - 1")
for _ in 0..<10000 {
    let result = try expression.eval()  // 非常快！
}
```

**📖 完整的 Swift 文档请参见 [SWIFT_USAGE.md](SWIFT_USAGE.md)**

### C++ 项目

对于 C++ 项目，只需**复制单个头文件** `ExpressionKit.hpp` 到你的项目：

1. **下载**：从本仓库复制 `ExpressionKit.hpp`
2. **包含**：在你的 C++ 文件中添加 `#include "ExpressionKit.hpp"`
3. **编译**：需要 C++11 或更高版本，无外部依赖

```cpp
#include "ExpressionKit.hpp"
using namespace ExpressionKit;

// 求解简单数学表达式
auto result = Expression::Eval("2 + 3 * 4");  // 返回 14.0
std::cout << "结果: " << result.asNumber() << std::endl;

// 布尔表达式
auto boolResult = Expression::Eval("true && false");  // 返回 false
std::cout << "布尔结果: " << boolResult.asBoolean() << std::endl;

// 用于语法高亮的词法序列收集
std::vector<Token> tokens;
auto resultWithTokens = Expression::Eval("2 + 3 * max(4, 5)", nullptr, &tokens);
std::cout << "结果: " << resultWithTokens.asNumber() << std::endl;
for (const auto& token : tokens) {
    std::cout << "词法单元: " << (int)token.type << " '" << token.text 
              << "' 位置 " << token.start << ":" << token.length << std::endl;
}
```

## 📊 快速对比

| 特性 | Swift | C++ |
|------|-------|-----|
| **安装** | Swift Package Manager | 复制单个 .hpp 文件 |
| **依赖** | 无（由 SPM 处理） | 无（仅头文件） |
| **集成** | `import ExpressionKit` | `#include "ExpressionKit.hpp"` |
| **API** | `Expression.eval()` | `Expression::Eval()` |
| **性能** | ✅ 完整性能 | ✅ 完整性能 |
| **功能** | ✅ 所有核心功能 | ✅ 所有功能 + Environment |

### 我应该使用哪个版本？

- **🎯 Swift 项目**：使用 Swift Package Manager 集成，获得简洁、类型安全的 API
- **🔧 C++ 项目**：复制 `ExpressionKit.hpp`，零依赖的头文件解决方案
- **🏗️ 混合项目**：两者可以共存 - 相同的表达式语法和行为

## 🎨 词法序列分析

ExpressionKit 提供强大的词法序列分析功能，用于语法高亮、IDE 集成和高级表达式分析。

### 词法单元类型

库在解析过程中识别以下词法单元类型：

| 词法类型 | 描述 | 示例 |
|----------|------|------|
| `NUMBER` | 数字字面量 | `42`, `3.14`, `-2.5` |
| `BOOLEAN` | 布尔字面量 | `true`, `false` |
| `STRING` | 字符串字面量 | `"hello"`, `"world"`, `""` |
| `IDENTIFIER` | 变量和函数名 | `x`, `pos.x`, `sqrt`, `player_health` |
| `OPERATOR` | 所有运算符 | `+`, `-`, `*`, `/`, `==`, `!=`, `&&`, `\|\|`, `!` |
| `PARENTHESIS` | 分组符号 | `(`, `)` |
| `COMMA` | 函数参数分隔符 | `,` |
| `WHITESPACE` | 空格和制表符 | ` `, `\t` |
| `UNKNOWN` | 无法识别的词法单元 | （用于错误处理） |

### C++ 词法收集

```cpp
#include "ExpressionKit.hpp"
using namespace ExpressionKit;

// 在求值时收集词法单元
std::vector<Token> tokens;
auto result = Expression::Eval("max(x + 5, y * 2)", &environment, &tokens);

// 处理词法单元用于语法高亮
for (const auto& token : tokens) {
    std::cout << "类型: " << (int)token.type 
              << " 文本: '" << token.text << "'" 
              << " 位置: " << token.start << "-" << (token.start + token.length)
              << std::endl;
}

// 另一种方式：解析时收集词法单元用于预编译
std::vector<Token> parseTokens;
auto ast = Expression::Parse("complex_expression", &parseTokens);
// parseTokens 现在包含所有用于语法高亮的词法单元
auto result = ast->evaluate(&environment);
```

### Swift 词法收集

```swift
import ExpressionKit

// 求值时收集词法单元
let (value, tokens) = try Expression.eval("max(x + 5, y * 2)", collectTokens: true)
print("结果: \(value)")

if let tokens = tokens {
    for token in tokens {
        print("类型: \(token.type), 文本: '\(token.text)', 位置: \(token.start)-\(token.start + token.length)")
    }
}

// 解析时收集词法单元用于预编译
let (expression, parseTokens) = try Expression.parse("complex_expression", collectTokens: true)
// parseTokens 包含所有用于分析的词法单元
let result = try expression.eval()
```

### 词法序列的使用场景

- **🎨 语法高亮**：在代码编辑器中为不同词法类型着色
- **🔍 错误报告**：精确的错误位置和上下文信息
- **✅ 表达式验证**：在求值前检查语法
- **🤖 自动补全**：根据上下文提示变量和函数
- **📝 代码格式化**：使用适当的空格美化表达式
- **🔧 静态分析**：无需执行即可分析表达式
- **🏗️ IDE 集成**：构建高级表达式编辑工具
- **📊 表达式度量**：统计运算符数量、复杂度分析

### 性能影响

词法收集的性能开销很小：

```cpp
// 基准测试：100万次求值 "2 + 3 * 4"
// 不收集词法：~50ms
// 收集词法：  ~55ms
// 开销：      ~10%
```

开销主要来自为词法文本分配字符串。对于性能关键的应用，只在需要时收集词法（例如，在开发期间或面向用户的编辑器中）。

## 🎮 实时体验 - 演示和测试目标

ExpressionKit 提供了多个交互式示例和全面的测试程序来展示其功能。以下是运行方法：

### 🖥️ 交互式 C++ 演示

**ExpressionDemo** - 功能丰富的交互式命令行界面，支持语法高亮：

```bash
# 构建并运行交互式演示
cd CPP
cmake .
make ExpressionDemo
./ExpressionDemo
```

**特性：**
- 带颜色语法高亮的交互式表达式求值
- 变量管理（设置、删除、列表）
- 支持所有数学函数
- 实时表达式解析和错误报告

**示例会话：**
```
> set x 5 + 3           # 设置 x 为 8
> set y x * 2           # 设置 y 为 16 
> eval sin(pi/2)        # 计算 sin(π/2) ≈ 1
> ls                    # 显示所有变量
```

### 🧪 C++ 单元测试  

**ExprTKTest** - 由 Catch2 驱动的全面测试套件：

```bash
# 构建并运行所有测试
cd CPP
cmake .
make ExprTKTest
./ExprTKTest

# 运行特定测试类别
./ExprTKTest [tag]           # 运行带特定标签的测试
./ExprTKTest --list-tags     # 查看可用标签
```

### 🎨 词法分析演示

**TokenDemo** - 用于语法高亮的高级词法序列分析：

```bash
# 构建并运行词法演示
cd CPP
cmake .
make TokenDemo
./TokenDemo
```

展示如何收集和分析词法序列，用于：
- 编辑器中的语法高亮
- 表达式验证
- 自动补全系统

### 🍎 Swift 示例

**ExpressionKitExample** - Swift 词法演示和功能展示：

```bash
# 运行带完整词法分析的 Swift 示例
cd Swift/Examples/SwiftExample
swift run
```

**特性：**
- 演示 Swift API 用法
- 词法序列收集示例
- 性能基准测试
- 类型安全演示

---

## 🚀 示例

### Swift 示例

```swift
import ExpressionKit

// 基本算术
let result1 = try Expression.eval("2 + 3 * 4")  // 14.0

// 布尔逻辑
let result2 = try Expression.eval("true && (5 > 3)")  // true

// 字符串表达式
let result2_5 = try Expression.eval("\"你好，世界！\"")  // "你好，世界！"

// 复杂表达式
let result3 = try Expression.eval("(2 + 3) * 4 - 1")  // 19.0

// 解析一次，执行多次以获得高性能
let expression = try Expression.parse("(a + b) * c - 1")
for _ in 0..<10000 {
    let result = try expression.eval()  // 非常快的重复执行
}

// 用于语法高亮的词法序列收集
let (value, tokens) = try Expression.eval("2 + 3 * max(4, 5)", collectTokens: true)
print("结果: \(value)")
if let tokens = tokens {
    for token in tokens {
        print("词法: \(token.type) '\(token.text)' 位置 \(token.start):\(token.length)")
    }
}

// 字符串词法收集
let (stringValue, stringTokens) = try Expression.eval("\"你好，ExpressionKit！\"", collectTokens: true)
print("字符串结果: \(stringValue)")
if let tokens = stringTokens {
    for token in tokens {
        print("字符串词法: \(token.type) '\(token.text)' 位置 \(token.start):\(token.length)")
    }
}

// 错误处理
do {
    let result = try Expression.eval("1 / 0")
} catch let error as ExpressionError {
    print("表达式错误: \(error.localizedDescription)")
}
```

### 使用 IEnvironment 进行变量访问（C++）

```cpp
#include "ExpressionKit.hpp"
#include <unordered_map>

class GameEnvironment : public Expression::IEnvironment {
private:
    std::unordered_map<std::string, Expression::Value> variables;
    
public:
    GameEnvironment() {
        // 初始化游戏状态
        variables["health"] = 100.0;
        variables["maxHealth"] = 100.0;
        variables["level"] = 5.0;
        variables["isAlive"] = true;
        variables["pos.x"] = 10.5;
        variables["pos.y"] = 20.3;
    }
    
    // 实现变量读取
    Expression::Value Get(const std::string& name) override {
        auto it = variables.find(name);
        if (it == variables.end()) {
            throw Expression::ExprException("未找到变量: " + name);
        }
        return it->second;
    }
    
    // 实现函数调用
    Expression::Value Call(const std::string& name, 
                             const std::vector<Expression::Value>& args) override {
        // 首先尝试标准数学函数
        Expression::Value result;
        if (Expression::Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // 自定义函数
        if (name == "distance" && args.size() == 4) {
            double x1 = args[0].asNumber(), y1 = args[1].asNumber();
            double x2 = args[2].asNumber(), y2 = args[3].asNumber();
            double dx = x2 - x1, dy = y2 - y1;
            return Expression::Value(std::sqrt(dx*dx + dy*dy));
        }
        throw Expression::ExprException("未知函数: " + name);
    }
};

// 使用示例
int main() {
    GameEnvironment environment;
    
    // 游戏逻辑表达式
    auto healthPercent = Expression::Eval("health / maxHealth", &environment);
    std::cout << "生命值百分比: " << healthPercent.asNumber() << std::endl;
    
    // 复杂条件检查
    auto needHealing = Expression::Eval("health < maxHealth * 0.5 && isAlive", &environment);
    std::cout << "需要治疗: " << (needHealing.asBoolean() ? "是" : "否") << std::endl;
    
    // 函数调用
    auto playerPos = Expression::Eval("distance(pos.x, pos.y, 0, 0)", &environment);
    std::cout << "距离原点: " << playerPos.asNumber() << std::endl;
    
    return 0;
}
```

### 使用预解析 AST 实现高性能执行（C++）

ExpressionKit 的一个关键特性是支持**预解析 AST**，允许你：
1. 解析表达式一次
2. 高效地多次执行
3. 避免重复解析的开销

```cpp
#include "ExpressionKit.hpp"

class HighPerformanceExample {
private:
    GameEnvironment environment;
    // 预编译的表达式 AST
    std::shared_ptr<Expression::ASTNode> healthCheckExpr;
    std::shared_ptr<Expression::ASTNode> damageCalcExpr;
    std::shared_ptr<Expression::ASTNode> levelUpExpr;
    
public:
    HighPerformanceExample() {
        // 启动时预编译所有表达式
        healthCheckExpr = Expression::Parse("health > 0 && health <= maxHealth");
        damageCalcExpr = Expression::Parse("max(0, damage - armor) * (1.0 + level * 0.1)");
        levelUpExpr = Expression::Parse("exp >= level * 100");
    }
    
    // 游戏循环中的高效执行
    void gameLoop() {
        for (int frame = 0; frame < 10000; ++frame) {
            // 每帧执行而无需重新解析
            bool playerAlive = healthCheckExpr->evaluate(&environment).asBoolean();
            
            if (playerAlive) {
                // 计算伤害（假设已设置 damage 和 armor）
                double finalDamage = damageCalcExpr->evaluate(&environment).asNumber();
                
                // 检查升级
                bool canLevelUp = levelUpExpr->evaluate(&environment).asBoolean();
                
                // 游戏逻辑...
            }
        }
    }
};
```

## 📄 许可证

本项目采用 MIT 许可证 - 请查看文件头部的许可证声明。

## 🔧 支持的语法（C++ 和 Swift 通用）

### 数据类型
- **数字**：`42`、`3.14`、`-2.5`
- **布尔值**：`true`、`false`
- **字符串**：`"hello"`、`"world"`、`""`

### 运算符（按优先级）

| 优先级 | 运算符 | 描述 | 示例 |
|--------|--------|------|------|
| 1 | `()` | 分组 | `(a + b) * c` |
| 2 | `!`、`not`、`-` | 一元运算符 | `!flag`、`not visible`、`-value` |
| 3 | `*`、`/` | 乘法/除法 | `a * b`、`x / y` |
| 4 | `+`、`-` | 加法/减法 | `a + b`、`x - y` |
| 5 | `<`、`>`、`<=`、`>=` | 关系比较 | `age >= 18`、`score < 100` |
| 6 | `==`、`!=` | 相等比较 | `name == "admin"`、`id != 0` |
| 7 | `xor` | 逻辑异或 | `a xor b` |
| 8 | `&&`、`and` | 逻辑与 | `a && b`、`x and y` |
| 9 | `\|\|`、`or` | 逻辑或 | `a \|\| b`、`x or y` |

### 变量和函数
- **变量**：`x`、`health`、`pos.x`、`player_name`
- **函数调用**：`max(a, b)`、`sqrt(x)`、`distance(x1, y1, x2, y2)`

### 内置数学函数
ExpressionKit 通过 `CallStandardFunctions` 方法提供了一套完整的标准数学函数：

| 函数 | 描述 | 示例 |
|------|------|------|
| `min(a, b)` | 返回两个数中较小的 | `min(10, 5)` → `5` |
| `max(a, b)` | 返回两个数中较大的 | `max(10, 5)` → `10` |
| `sqrt(x)` | 返回 x 的平方根 | `sqrt(16)` → `4` |
| `sin(x)` | 返回 x 的正弦值（弧度） | `sin(3.14159/2)` → `1` |
| `cos(x)` | 返回 x 的余弦值（弧度） | `cos(0)` → `1` |
| `tan(x)` | 返回 x 的正切值（弧度） | `tan(0)` → `0` |
| `abs(x)` | 返回 x 的绝对值 | `abs(-5)` → `5` |
| `pow(x, y)` | 返回 x 的 y 次方 | `pow(2, 3)` → `8` |
| `log(x)` | 返回 x 的自然对数 | `log(2.718)` → `≈1` |
| `exp(x)` | 返回 e 的 x 次方 | `exp(1)` → `≈2.718` |
| `floor(x)` | 返回不大于 x 的最大整数 | `floor(3.7)` → `3` |
| `ceil(x)` | 返回不小于 x 的最小整数 | `ceil(3.2)` → `4` |
| `round(x)` | 返回 x 四舍五入到最近的整数 | `round(3.6)` → `4` |

这些函数可以在 IEnvironment 实现中使用，以提供数学计算能力：

```cpp
class MathEnvironment : public Expression::IEnvironment {
public:
    Expression::Value Call(const std::string& name, 
                             const std::vector<Expression::Value>& args) override {
        Expression::Value result;
        
        // 首先尝试标准数学函数
        if (Expression::Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // 自定义函数...
        throw Expression::ExprException("未知函数: " + name);
    }
    
    // ... 其他方法
};
```

## 🏗️ 架构设计

### 核心组件

1. **Value** - 统一的值类型，支持数字、布尔值和字符串
2. **IEnvironment** - 变量和函数访问接口
3. **ASTNode** - 抽象语法树节点基类
4. **Parser** - 递归下降解析器
5. **Expression** - 主要的表达式工具类
6. **CompiledExpression** - 预解析 AST，用于高效重复执行

### Swift 纯实现架构

ExpressionKit 使用**纯 Swift 实现**，直接转译 C++ 算法：

1. **ExpressionKit.hpp** - 参考 C++ 头文件库
2. **ExpressionKit.swift** - C++ 实现的 1:1 Swift 转译
3. **原生 Swift 实现** - 使用 Swift 习惯模式的完整重新实现

```
Swift 代码
    ↓
ExpressionKit.swift（纯 Swift 实现）
    ↓
原生 Swift AST 和解析器（从 C++ 转译）
```

### 纯 Swift 架构的优势

- **性能**：无桥接开销，原生 Swift 执行
- **可维护性**：单一代码库更易维护和调试
- **平台支持**：在所有 Swift 平台上工作，无需 C++ 依赖
- **内存管理**：原生 Swift ARC 而非手动 C++ 内存管理
- **调试**：完整的 Swift 调试能力和堆栈跟踪
- **发布**：更简单的包发布，无混合语言复杂性

### IEnvironment 接口

IEnvironment 是 ExpressionKit 的核心设计模式，提供：

```cpp
class IEnvironment {
public:
    virtual ~IEnvironment() = default;
    
    // 必需：获取变量值
    virtual Value Get(const std::string& name) = 0;
    
    // 必需：调用函数
    virtual Value Call(const std::string& name, 
                      const std::vector<Value>& args) = 0;
};
```

这种设计的优势：
- **解耦**：将表达式解析与具体数据源分离
- **灵活性**：可以与任何数据源集成（数据库、配置文件、游戏状态等）
- **可测试性**：易于为不同场景创建模拟 IEnvironment
- **性能**：避免字符串查找，支持直接内存访问

## 📊 性能特征

### 预解析 AST 的优势

1. **解析一次，执行多次**
   ```cpp
   // 慢：每次都解析
   for (int i = 0; i < 1000000; ++i) {
       auto result = Expression::Eval("complex_expression", &environment);
   }
   
   // 快：预解析并重用
   auto ast = Expression::Parse("complex_expression");
   for (int i = 0; i < 1000000; ++i) {
       auto result = ast->evaluate(&environment);
   }
   ```

2. **内存效率**：AST 节点使用 shared_ptr 确保安全和效率
3. **类型安全**：编译时类型检查和运行时验证

## 🎯 使用场景

- **游戏引擎**：技能系统、AI 条件检查、配置表达式
- **配置系统**：动态规则、条件逻辑
- **业务规则引擎**：复杂的业务逻辑表达式
- **数据处理**：计算字段、过滤条件
- **脚本系统**：嵌入式表达式求值

## 🔍 错误处理

ExpressionKit 使用异常进行错误处理：

```cpp
try {
    auto result = Expression::Eval("invalid expression ++ --", &environment);
} catch (const Expression::ExprException& e) {
    std::cerr << "表达式错误: " << e.what() << std::endl;
}
```

常见错误类型：
- 语法错误：无效的表达式语法
- 类型错误：操作数类型不匹配
- 运行时错误：除零、未定义变量等
- 函数错误：未知函数、参数错误

## 🚧 编译要求

- C++11 或更高版本
- 仅依赖 C++ 标准库

## 📚 更多示例

### 运行实时演示

获取全面的交互式示例，请查看上方的 **[演示和测试目标部分](#-实时体验---演示和测试目标)**，包括：

- **ExpressionDemo**：带语法高亮的交互式命令行界面
- **TokenDemo**：词法序列分析演示  
- **ExprTKTest**：完整的单元测试套件
- **Swift 示例**：完整的 Swift API 展示

### 代码示例

查看专用演示文件获取完整的工作示例：

- **`CPP/demo.cpp`**：具有完整 ExpressionKit 功能的交互式命令行演示
- **`CPP/token_demo.cpp`**：高级词法序列收集和分析  
- **`CPP/test.cpp`**：全面的单元测试和使用示例
- **`Swift/Examples/SwiftExample/`**：完整的 Swift API 演示

查看上述文件了解更多使用示例和测试用例。

## 🤝 贡献

由于这个项目主要是 AI 生成的，对于建议的更改：
1. 提供具体的功能需求
2. 描述期望的 API 设计
3. 包含测试用例

## 📞 支持

如有问题或建议，请提交 Issue 或查看代码注释了解实现细节。
