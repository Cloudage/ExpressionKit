# ExpressionKit

一个轻量级、接口驱动的C++表达式解析与求值库

## 🚀 主要特性

- **接口化变量读写**：通过Backend接口实现变量和函数的灵活访问
- **预解析AST执行**：支持表达式预编译，可重复高效执行
- **类型安全**：强类型Value系统，支持数值和布尔类型
- **完整运算符支持**：算术、比较、逻辑运算符全覆盖
- **异常错误处理**：清晰的错误信息和异常机制
- **零依赖**：仅依赖C++标准库

## 🤖 AI生成声明

**重要提示：本项目代码主要由AI（GitHub Copilot等AI工具）生成，经过人工指导和审查。**

代码遵循现代C++最佳实践，提供了一个清洁、基于接口的表达式求值系统。

## 📄 许可证

本项目采用MIT许可证 - 详见文件头部的许可证声明。

## 🛠️ 快速开始

### 基本用法

```cpp
#include "ExpressionKit.hpp"
using namespace ExpressionKit;

// 简单的数学表达式求值
auto result = ExprTK::Eval("2 + 3 * 4");  // 返回 14.0
std::cout << "结果: " << result.asNumber() << std::endl;

// 布尔表达式
auto boolResult = ExprTK::Eval("true && false");  // 返回 false
std::cout << "布尔结果: " << boolResult.asBoolean() << std::endl;
```

### 使用Backend实现变量访问

```cpp
#include "ExpressionKit.hpp"
#include <unordered_map>

class GameBackend : public ExpressionKit::Backend {
private:
    std::unordered_map<std::string, ExpressionKit::Value> variables;
    
public:
    GameBackend() {
        // 初始化游戏状态
        variables["health"] = 100.0;
        variables["maxHealth"] = 100.0;
        variables["level"] = 5.0;
        variables["isAlive"] = true;
        variables["pos.x"] = 10.5;
        variables["pos.y"] = 20.3;
    }
    
    // 实现变量读取
    ExpressionKit::Value get(const std::string& name) override {
        auto it = variables.find(name);
        if (it == variables.end()) {
            throw ExpressionKit::ExprException("未找到变量: " + name);
        }
        return it->second;
    }
    
    // 实现变量写入（可选）
    void set(const std::string& name, const ExpressionKit::Value& value) override {
        variables[name] = value;
    }
    
    // 实现函数调用
    ExpressionKit::Value call(const std::string& name, 
                             const std::vector<ExpressionKit::Value>& args) override {
        if (name == "max" && args.size() == 2) {
            double a = args[0].asNumber();
            double b = args[1].asNumber();
            return ExpressionKit::Value(std::max(a, b));
        }
        if (name == "sqrt" && args.size() == 1) {
            double val = args[0].asNumber();
            return ExpressionKit::Value(std::sqrt(val));
        }
        if (name == "distance" && args.size() == 4) {
            double x1 = args[0].asNumber(), y1 = args[1].asNumber();
            double x2 = args[2].asNumber(), y2 = args[3].asNumber();
            double dx = x2 - x1, dy = y2 - y1;
            return ExpressionKit::Value(std::sqrt(dx*dx + dy*dy));
        }
        throw ExpressionKit::ExprException("未知函数: " + name);
    }
};

// 使用示例
int main() {
    GameBackend backend;
    
    // 游戏逻辑表达式
    auto healthPercent = ExprTK::Eval("health / maxHealth", &backend);
    std::cout << "生命值百分比: " << healthPercent.asNumber() << std::endl;
    
    // 复杂条件判断
    auto needHealing = ExprTK::Eval("health < maxHealth * 0.5 && isAlive", &backend);
    std::cout << "需要治疗: " << (needHealing.asBoolean() ? "是" : "否") << std::endl;
    
    // 函数调用
    auto playerPos = ExprTK::Eval("distance(pos.x, pos.y, 0, 0)", &backend);
    std::cout << "距离原点: " << playerPos.asNumber() << std::endl;
    
    return 0;
}
```

### 预解析AST高性能执行

ExpressionKit的一个关键特性是支持**预解析AST**，这允许你：
1. 一次解析表达式
2. 多次高效执行
3. 避免重复解析开销

```cpp
#include "ExpressionKit.hpp"

class HighPerformanceExample {
private:
    GameBackend backend;
    // 预编译的表达式AST
    std::shared_ptr<ExpressionKit::ASTNode> healthCheckExpr;
    std::shared_ptr<ExpressionKit::ASTNode> damageCalcExpr;
    std::shared_ptr<ExpressionKit::ASTNode> levelUpExpr;
    
public:
    HighPerformanceExample() {
        // 游戏启动时预编译所有表达式
        healthCheckExpr = ExprTK::Parse("health > 0 && health <= maxHealth");
        damageCalcExpr = ExprTK::Parse("max(0, damage - armor) * (1.0 + level * 0.1)");
        levelUpExpr = ExprTK::Parse("exp >= level * 100");
    }
    
    // 游戏循环中高效执行
    void gameLoop() {
        for (int frame = 0; frame < 10000; ++frame) {
            // 每帧都执行，但不需要重新解析
            bool playerAlive = healthCheckExpr->evaluate(&backend).asBoolean();
            
            if (playerAlive) {
                // 计算伤害（假设设置了damage和armor变量）
                double finalDamage = damageCalcExpr->evaluate(&backend).asNumber();
                
                // 检查升级
                bool canLevelUp = levelUpExpr->evaluate(&backend).asBoolean();
                
                // 游戏逻辑...
            }
        }
    }
};
```

## 🔧 支持的语法

### 数据类型
- **数值**: `42`, `3.14`, `-2.5`
- **布尔值**: `true`, `false`

### 运算符（按优先级排序）

| 优先级 | 运算符 | 说明 | 示例 |
|--------|--------|------|------|
| 1 | `()` | 括号分组 | `(a + b) * c` |
| 2 | `!`, `not`, `-` | 一元运算符 | `!flag`, `not visible`, `-value` |
| 3 | `*`, `/` | 乘除运算 | `a * b`, `x / y` |
| 4 | `+`, `-` | 加减运算 | `a + b`, `x - y` |
| 5 | `<`, `>`, `<=`, `>=` | 关系比较 | `age >= 18`, `score < 100` |
| 6 | `==`, `!=` | 相等比较 | `name == "admin"`, `id != 0` |
| 7 | `xor` | 逻辑异或 | `a xor b` |
| 8 | `&&`, `and` | 逻辑与 | `a && b`, `x and y` |
| 9 | `\|\|`, `or` | 逻辑或 | `a \|\| b`, `x or y` |

### 变量和函数
- **变量**: `x`, `health`, `pos.x`, `player_name`
- **函数调用**: `max(a, b)`, `sqrt(x)`, `distance(x1, y1, x2, y2)`

## 🏗️ 架构设计

### 核心组件

1. **Value** - 统一的值类型，支持数值和布尔
2. **Backend** - 变量和函数访问接口
3. **ASTNode** - 抽象语法树节点基类
4. **Parser** - 递归下降解析器
5. **ExprTK** - 主要的表达式工具类

### Backend接口

Backend是ExpressionKit的核心设计模式，它提供了：

```cpp
class Backend {
public:
    virtual ~Backend() = default;
    
    // 必须实现：获取变量值
    virtual Value get(const std::string& name) = 0;
    
    // 可选实现：设置变量值
    virtual void set(const std::string& name, const Value& value);
    
    // 必须实现：调用函数
    virtual Value call(const std::string& name, 
                      const std::vector<Value>& args) = 0;
};
```

这种设计的优势：
- **解耦**：表达式解析与具体数据源分离
- **灵活**：可以接入任何数据源（数据库、配置文件、游戏状态等）
- **可测试**：易于为不同场景创建Mock Backend
- **高性能**：避免字符串查找，支持直接内存访问

## 📊 性能特性

### 预解析AST的优势

1. **一次解析，多次执行**
   ```cpp
   // 慢：每次都解析
   for (int i = 0; i < 1000000; ++i) {
       auto result = ExprTK::Eval("complex_expression", &backend);
   }
   
   // 快：预解析后重复执行
   auto ast = ExprTK::Parse("complex_expression");
   for (int i = 0; i < 1000000; ++i) {
       auto result = ast->evaluate(&backend);
   }
   ```

2. **内存效率**: AST节点使用shared_ptr，安全且高效
3. **类型安全**: 编译时类型检查，运行时类型验证

## 🎯 使用场景

- **游戏引擎**: 技能系统、AI条件判断、配置表达式
- **配置系统**: 动态配置规则、条件判断
- **业务规则引擎**: 复杂业务逻辑表达式
- **数据处理**: 计算字段、过滤条件
- **脚本系统**: 嵌入式表达式求值

## 🔍 错误处理

ExpressionKit使用异常机制处理错误：

```cpp
try {
    auto result = ExprTK::Eval("invalid expression ++ --", &backend);
} catch (const ExpressionKit::ExprException& e) {
    std::cerr << "表达式错误: " << e.what() << std::endl;
}
```

常见错误类型：
- 语法错误：无效的表达式语法
- 类型错误：类型不匹配的操作
- 运行时错误：除零、未定义变量等
- 函数错误：未知函数、参数不匹配

## 🚧 编译要求

- C++11 或更高版本
- 支持的编译器：GCC 4.8+, Clang 3.4+, MSVC 2015+
- 仅依赖C++标准库

## 📚 更多示例

查看 `test.cpp` 文件以获取更多使用示例和测试用例。

## 🤝 贡献

由于本项目主要由AI生成，如需修改建议：
1. 提出具体的功能需求
2. 描述预期的API设计
3. 提供测试用例

## 📞 支持

如有问题或建议，请创建Issue或查看代码注释以了解实现细节。
