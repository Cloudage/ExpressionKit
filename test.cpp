#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <map>
#include "ExpressionKit.hpp"

using namespace ExpressionKit;
using Catch::Approx;

// 简单的测试用 IBackend
class TestBackend final : public IBackend {
    std::map<std::string, Value> variables;

public:
    Value Get(const std::string& name) override {
        if (const auto it = variables.find(name); it != variables.end()) return it->second;
        throw ExprException("变量未定义：" + name);
    }

    void set(const std::string& name, const Value& value) {
        variables[name] = value;
    }

    Value Call(const std::string& name, const std::vector<Value>& args) override {
        if (name == "add") {
            if (args.size() != 2 || !args[0].isNumber() || !args[1].isNumber())
                throw ExprException("add函数需要两个数值参数");
            return args[0].asNumber() + args[1].asNumber();
        }
        throw ExprException("未定义的函数：" + name);
    }
};

TEST_CASE("Number Expression", "[basic]") {
    
    const auto result = ExprTK::Eval("1 + 2 * 3", nullptr); // 不需要Backend的表达式
    REQUIRE(result.asNumber() == 7.0);
}

TEST_CASE("Boolean Expression", "[basic]") {
    
    const auto result = ExprTK::Eval("true && false", nullptr); // 不需要Backend的表达式
    REQUIRE(result.asBoolean() == false);
}

TEST_CASE("Variable Expression", "[variables]") {
    
    TestBackend backend;
    backend.set("x", Value(5.0));

    const auto result = ExprTK::Eval("x + 3", &backend); // 直接传入Backend
    REQUIRE(result.asNumber() == 8.0);
}

TEST_CASE("Function Call", "[functions]") {
    
    TestBackend backend;

    const auto result = ExprTK::Eval("add(2, 3)", &backend); // 直接传入Backend
    REQUIRE(result.asNumber() == 5.0);
}

TEST_CASE("Parse Error", "[errors]") {
    
    REQUIRE_THROWS_AS(ExprTK::Eval("1 + * 3", nullptr), ExprException);
}

TEST_CASE("Division by Zero", "[errors]") {
    
    REQUIRE_THROWS_AS(ExprTK::Eval("1 / 0", nullptr), ExprException);
}

TEST_CASE("New Boolean Operators", "[boolean]") {
    

    // 测试 && (and) - 不需要Backend
    REQUIRE(ExprTK::Eval("true && true", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("true && false", nullptr).asBoolean() == false);
    REQUIRE(ExprTK::Eval("true and false", nullptr).asBoolean() == false);

    // 测试 || (or)
    REQUIRE(ExprTK::Eval("true || false", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("false || false", nullptr).asBoolean() == false);
    REQUIRE(ExprTK::Eval("false or true", nullptr).asBoolean() == true);

    // 测试 xor
    REQUIRE(ExprTK::Eval("true xor false", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("true xor true", nullptr).asBoolean() == false);

    // 测试 ! (not)
    REQUIRE(ExprTK::Eval("!true", nullptr).asBoolean() == false);
    REQUIRE(ExprTK::Eval("!false", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("not true", nullptr).asBoolean() == false);
}

TEST_CASE("Equality Operators", "[comparison]") {
    

    // 测试 == - 不需要Backend
    REQUIRE(ExprTK::Eval("5 == 5", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("5 == 3", nullptr).asBoolean() == false);
    REQUIRE(ExprTK::Eval("true == true", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("true == false", nullptr).asBoolean() == false);

    // 测试 !=
    REQUIRE(ExprTK::Eval("5 != 3", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("5 != 5", nullptr).asBoolean() == false);
    REQUIRE(ExprTK::Eval("true != false", nullptr).asBoolean() == true);
}

TEST_CASE("Extended Comparison Operators", "[comparison]") {
    

    // 测试 >= - 不需要Backend
    REQUIRE(ExprTK::Eval("5 >= 5", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("5 >= 3", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("3 >= 5", nullptr).asBoolean() == false);

    // 测试 <=
    REQUIRE(ExprTK::Eval("3 <= 5", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("5 <= 5", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("5 <= 3", nullptr).asBoolean() == false);

    // 测试 >
    REQUIRE(ExprTK::Eval("5 > 3", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("3 > 5", nullptr).asBoolean() == false);

    // 测试 <
    REQUIRE(ExprTK::Eval("3 < 5", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("5 < 3", nullptr).asBoolean() == false);
}

TEST_CASE("Complex Expressions", "[complex]") {
    

    // 测试复杂的布尔表达式 - 不需要Backend
    REQUIRE(ExprTK::Eval("(true && false) || (true && true)", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("!false && (true || false)", nullptr).asBoolean() == true);

    // 测试混合数值和布尔运算
    REQUIRE(ExprTK::Eval("(5 > 3) && (2 + 3 == 5)", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(10 / 2 >= 5) || (3 * 2 != 6)", nullptr).asBoolean() == true);

    // 测试运算符优先级
    REQUIRE(ExprTK::Eval("2 + 3 * 4 == 14", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("true || false && false", nullptr).asBoolean() == true); // || 优先级低于 &&
}

TEST_CASE("Unary Operators", "[unary]") {
    

    // 测试负号 - 不需要Backend
    REQUIRE(ExprTK::Eval("-5", nullptr).asNumber() == -5.0);
    REQUIRE(ExprTK::Eval("-(2 + 3)", nullptr).asNumber() == -5.0);

    // 测试 NOT
    REQUIRE(ExprTK::Eval("!(5 > 3)", nullptr).asBoolean() == false);
    REQUIRE(ExprTK::Eval("not (2 == 3)", nullptr).asBoolean() == true);
}

TEST_CASE("Parentheses and Complex Arithmetic", "[arithmetic]") {
    

    // 基本括号运算 - 不需要Backend
    REQUIRE(ExprTK::Eval("(1 + 2) * 3", nullptr).asNumber() == 9.0);
    REQUIRE(ExprTK::Eval("1 + (2 * 3)", nullptr).asNumber() == 7.0);

    // 多层嵌套括号
    REQUIRE(ExprTK::Eval("((2 + 3) * (4 - 1)) / 3", nullptr).asNumber() == 5.0);
    REQUIRE(ExprTK::Eval("(10 - (3 + 2)) * 2", nullptr).asNumber() == 10.0);

    // 复杂的数学表达式
    REQUIRE(ExprTK::Eval("(5 * 2 + 3) / (4 - 1)", nullptr).asNumber() == Approx(4.333333).epsilon(0.001));
    REQUIRE(ExprTK::Eval("2 * (3 + 4) - (8 / 2)", nullptr).asNumber() == 10.0);

    // 带负号的括号运算
    REQUIRE(ExprTK::Eval("-(2 + 3) * 4", nullptr).asNumber() == -20.0);
    REQUIRE(ExprTK::Eval("(-5 + 3) * 2", nullptr).asNumber() == -4.0);
}

TEST_CASE("Variables in Complex Expressions", "[variables]") {
    
    TestBackend backend;

    // 设置测试变量
    backend.set("x", Value(10.0));
    backend.set("y", Value(5.0));
    backend.set("z", Value(2.0));
    backend.set("isActive", Value(true));
    backend.set("isComplete", Value(false));

    // 基本变量运算
    REQUIRE(ExprTK::Eval("x + y", &backend).asNumber() == 15.0);
    REQUIRE(ExprTK::Eval("x * y / z", &backend).asNumber() == 25.0);

    // 带括号的变量运算
    REQUIRE(ExprTK::Eval("(x + y) * z", &backend).asNumber() == 30.0);
    REQUIRE(ExprTK::Eval("x / (y - z)", &backend).asNumber() == Approx(3.333333).epsilon(0.001));

    // 混合数值和变量
    REQUIRE(ExprTK::Eval("x + 5 * y", &backend).asNumber() == 35.0);
    REQUIRE(ExprTK::Eval("(x - 3) / (y + 2)", &backend).asNumber() == 1.0);

    // 布尔变量运算
    REQUIRE(ExprTK::Eval("isActive && !isComplete", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("isActive || isComplete", &backend).asBoolean() == true);

    // 混合数值比较和布尔变量
    REQUIRE(ExprTK::Eval("(x > y) && isActive", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(x == 10) and !isComplete", &backend).asBoolean() == true);
}

TEST_CASE("Real World Scenarios", "[practical]") {
    
    TestBackend backend;

    // 几何计算场景
    backend.set("radius", 5.0);
    backend.set("pi", 3.14159);

    // 游戏状态判断场景
    backend.set("health", 75.0);
    backend.set("maxHealth", 100.0);
    backend.set("hasShield", true);
    backend.set("level", 5.0);

    // 商业逻辑场景
    backend.set("price", 99.99);
    backend.set("discount", 0.15);
    backend.set("quantity", 3.0);
    backend.set("shipping", 9.99);
    backend.set("isPremium", true);

    // 圆的面积: π * r² - 直接传入Backend
    REQUIRE(ExprTK::Eval("pi * radius * radius", &backend).asNumber() == Approx(78.539).epsilon(0.01));

    // 判断玩家状态
    REQUIRE(ExprTK::Eval("health > maxHealth / 2", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(health / maxHealth) >= 0.5 && hasShield", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("level >= 5 && (health > 50 || hasShield)", &backend).asBoolean() == true);

    // 计算总价格 = (price * (1 - discount) * quantity) + (isPremium ? 0 : shipping)
    double discountedPrice = ExprTK::Eval("price * (1 - discount)", &backend).asNumber();
    REQUIRE(discountedPrice == Approx(84.9915).epsilon(0.001));

    double totalBeforeShipping = ExprTK::Eval("price * (1 - discount) * quantity", &backend).asNumber();
    REQUIRE(totalBeforeShipping == Approx(254.97).epsilon(0.01));

    // 免费配送判断
    REQUIRE(ExprTK::Eval("isPremium || (quantity * price > 200)", &backend).asBoolean() == true);
}

TEST_CASE("Complex Boolean Logic", "[boolean_logic]") {
    
    TestBackend backend;

    // 设置用户权限变量
    backend.set("isAdmin", false);
    backend.set("isOwner", true);
    backend.set("hasPermission", false);
    backend.set("isLoggedIn", true);
    backend.set("accountAge", 365.0);
    backend.set("trustScore", 85.0);

    // 复杂权限检查 - 直接传入Backend
    REQUIRE(ExprTK::Eval("isLoggedIn && (isAdmin || isOwner)", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(isAdmin || hasPermission) && isLoggedIn", &backend).asBoolean() == false);

    // 多条件验证
    REQUIRE(ExprTK::Eval("isLoggedIn && accountAge >= 30 && trustScore > 80", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(isAdmin || (isOwner && trustScore >= 70)) && isLoggedIn", &backend).asBoolean() == true);

    // 复杂的异或逻辑
    REQUIRE(ExprTK::Eval("isAdmin xor isOwner", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("hasPermission xor (trustScore > 90)", &backend).asBoolean() == false);
}

TEST_CASE("Mixed Type Expressions", "[mixed_types]") {
    
    TestBackend backend;

    backend.set("temperature", 25.5);
    backend.set("humidity", 60.0);
    backend.set("isRaining", false);
    backend.set("windSpeed", 15.0);

    // 复合条件
    backend.set("score1", 85.0);
    backend.set("score2", 92.0);
    backend.set("score3", 78.0);

    // 天气条件判断 - 直接传入Backend
    REQUIRE(ExprTK::Eval("temperature > 20 && humidity < 70", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("!isRaining && windSpeed <= 20", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(temperature >= 20 && temperature <= 30) && !isRaining", &backend).asBoolean() == true);

    // 平均分计算和及格判断
    double average = ExprTK::Eval("(score1 + score2 + score3) / 3", &backend).asNumber();
    REQUIRE(average == Approx(85.0).epsilon(0.1));

    // 判断是否所有分数都及格
    REQUIRE(ExprTK::Eval("score1 >= 60 && score2 >= 60 && score3 >= 60", &backend).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(score1 + score2 + score3) / 3 >= 80", &backend).asBoolean() == true);
}

TEST_CASE("Edge Cases and Error Handling", "[edge_cases]") {
    

    // 测试空格处理 - 不需要Backend
    REQUIRE(ExprTK::Eval("  1   +   2  ", nullptr).asNumber() == 3.0);
    REQUIRE(ExprTK::Eval("true   &&   false", nullptr).asBoolean() == false);

    // 测试运算符优先级
    REQUIRE(ExprTK::Eval("1 + 2 * 3 + 4", nullptr).asNumber() == 11.0);
    REQUIRE(ExprTK::Eval("true || false && false", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("(true || false) && false", nullptr).asBoolean() == false);

    // 测试连续运算符
    REQUIRE(ExprTK::Eval("!!true", nullptr).asBoolean() == true);
    REQUIRE(ExprTK::Eval("--5", nullptr).asNumber() == 5.0);
    REQUIRE(ExprTK::Eval("not not false", nullptr).asBoolean() == false);

    // 无效表达式应该抛出异常
    REQUIRE_THROWS_AS(ExprTK::Eval("1 +", nullptr), ExprException);
    REQUIRE_THROWS_AS(ExprTK::Eval("(1 + 2", nullptr), ExprException);
    REQUIRE_THROWS_AS(ExprTK::Eval("1 + 2)", nullptr), ExprException);
    REQUIRE_THROWS_AS(ExprTK::Eval("", nullptr), ExprException);
}

TEST_CASE("Backends", "[backend]") {
    // 创建一个只读Backend（不重写set方法）
    class ReadOnlyBackend : public IBackend {
        std::unordered_map<std::string, Value> vars = {
            {"x", Value(10.0)},
            {"y", Value(5.0)}
        };
    public:
        Value Get(const std::string& name) override {
            if (const auto it = vars.find(name); it != vars.end()) return it->second;
            throw ExprException("变量未定义：" + name);
        }

        // 不重写set方法，使用默认实现

        Value Call(const std::string& name, const std::vector<Value>& args) override {
            throw ExprException("未定义的函数：" + name);
        }
    };

    ReadOnlyBackend backend;

    SECTION("只读Backend可以正常读取变量") {
        const auto result = ExprTK::Eval("x + y * 2", &backend);
        REQUIRE(result.asNumber() == 20.0);
    }

    SECTION("可以使用不同的Backend执行相同表达式") {
        // 第一个Backend
        class Backend1 : public IBackend {
        public:
            Value Get(const std::string& name) override {
                if (name == "value") return 100;
                throw ExprException("变量未定义：" + name);
            }
            Value Call(const std::string& name, const std::vector<Value>& args) override {
                throw ExprException("未定义的函数：" + name);
            }
        };

        // 第二个Backend
        class Backend2 : public IBackend {
        public:
            Value Get(const std::string& name) override {
                if (name == "value") return 200;
                throw ExprException("变量未定义：" + name);
            }
            Value Call(const std::string& name, const std::vector<Value>& args) override {
                throw ExprException("未定义的函数：" + name);
            }
        };

        Backend1 backend1;
        Backend2 backend2;

        // 同一个表达式，不同的Backend，得到不同的结果
        const auto result1 = ExprTK::Eval("value * 2", &backend1);
        const auto result2 = ExprTK::Eval("value * 2", &backend2);

        REQUIRE(result1.asNumber() == 200.0);
        REQUIRE(result2.asNumber() == 400.0);
    }
}
