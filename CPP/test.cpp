#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <map>
#include <unordered_map>
#include "ExpressionKit.hpp"

using namespace ExpressionKit;
using Catch::Approx;

// 简单的测试用 IEnvironment
class TestEnvironment final : public IEnvironment {
    std::map<std::string, Value> variables;

public:
    Value Get(const std::string& name) override {
        if (const auto it = variables.find(name); it != variables.end()) return it->second;
        throw ExprException("Variable not defined: " + name);
    }

    void set(const std::string& name, const Value& value) {
        variables[name] = value;
    }

    Value Call(const std::string& name, const std::vector<Value>& args) override {
        if (name == "add") {
            if (args.size() != 2 || !args[0].isNumber() || !args[1].isNumber())
                throw ExprException("add function requires two numeric parameters");
            return args[0].asNumber() + args[1].asNumber();
        }
        throw ExprException("Function not defined: " + name);
    }
};

TEST_CASE("Number Expression", "[basic]") {
    
    const auto result = Expression::Eval("1 + 2 * 3", nullptr); // 不需要Environment的表达式
    REQUIRE(result.asNumber() == 7.0);
}

TEST_CASE("Boolean Expression", "[basic]") {
    
    const auto result = Expression::Eval("true && false", nullptr); // 不需要Environment的表达式
    REQUIRE(result.asBoolean() == false);
}

TEST_CASE("Variable Expression", "[variables]") {
    
    TestEnvironment environment;
    environment.set("x", Value(5.0));

    const auto result = Expression::Eval("x + 3", &environment); // 直接传入Environment
    REQUIRE(result.asNumber() == 8.0);
}

TEST_CASE("Function Call", "[functions]") {
    
    TestEnvironment environment;

    const auto result = Expression::Eval("add(2, 3)", &environment); // 直接传入Environment
    REQUIRE(result.asNumber() == 5.0);
}

TEST_CASE("Parse Error", "[errors]") {
    
    REQUIRE_THROWS_AS(Expression::Eval("1 + * 3", nullptr), ExprException);
}

TEST_CASE("Division by Zero", "[errors]") {
    
    REQUIRE_THROWS_AS(Expression::Eval("1 / 0", nullptr), ExprException);
}

TEST_CASE("New Boolean Operators", "[boolean]") {
    

    // 测试 && (and) - 不需要Environment
    REQUIRE(Expression::Eval("true && true", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("true && false", nullptr).asBoolean() == false);
    REQUIRE(Expression::Eval("true and false", nullptr).asBoolean() == false);

    // 测试 || (or)
    REQUIRE(Expression::Eval("true || false", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("false || false", nullptr).asBoolean() == false);
    REQUIRE(Expression::Eval("false or true", nullptr).asBoolean() == true);

    // 测试 xor
    REQUIRE(Expression::Eval("true xor false", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("true xor true", nullptr).asBoolean() == false);

    // 测试 ! (not)
    REQUIRE(Expression::Eval("!true", nullptr).asBoolean() == false);
    REQUIRE(Expression::Eval("!false", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("not true", nullptr).asBoolean() == false);
}

TEST_CASE("Equality Operators", "[comparison]") {
    

    // 测试 == - 不需要Environment
    REQUIRE(Expression::Eval("5 == 5", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("5 == 3", nullptr).asBoolean() == false);
    REQUIRE(Expression::Eval("true == true", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("true == false", nullptr).asBoolean() == false);

    // 测试 !=
    REQUIRE(Expression::Eval("5 != 3", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("5 != 5", nullptr).asBoolean() == false);
    REQUIRE(Expression::Eval("true != false", nullptr).asBoolean() == true);
}

TEST_CASE("Extended Comparison Operators", "[comparison]") {
    

    // 测试 >= - 不需要Environment
    REQUIRE(Expression::Eval("5 >= 5", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("5 >= 3", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("3 >= 5", nullptr).asBoolean() == false);

    // 测试 <=
    REQUIRE(Expression::Eval("3 <= 5", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("5 <= 5", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("5 <= 3", nullptr).asBoolean() == false);

    // 测试 >
    REQUIRE(Expression::Eval("5 > 3", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("3 > 5", nullptr).asBoolean() == false);

    // 测试 <
    REQUIRE(Expression::Eval("3 < 5", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("5 < 3", nullptr).asBoolean() == false);
}

TEST_CASE("Complex Expressions", "[complex]") {
    

    // 测试复杂的布尔表达式 - 不需要Environment
    REQUIRE(Expression::Eval("(true && false) || (true && true)", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("!false && (true || false)", nullptr).asBoolean() == true);

    // 测试混合数值和布尔运算
    REQUIRE(Expression::Eval("(5 > 3) && (2 + 3 == 5)", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("(10 / 2 >= 5) || (3 * 2 != 6)", nullptr).asBoolean() == true);

    // 测试运算符优先级
    REQUIRE(Expression::Eval("2 + 3 * 4 == 14", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("true || false && false", nullptr).asBoolean() == true); // || 优先级低于 &&
}

TEST_CASE("Unary Operators", "[unary]") {
    

    // 测试负号 - 不需要Environment
    REQUIRE(Expression::Eval("-5", nullptr).asNumber() == -5.0);
    REQUIRE(Expression::Eval("-(2 + 3)", nullptr).asNumber() == -5.0);

    // 测试 NOT
    REQUIRE(Expression::Eval("!(5 > 3)", nullptr).asBoolean() == false);
    REQUIRE(Expression::Eval("not (2 == 3)", nullptr).asBoolean() == true);
}

TEST_CASE("Parentheses and Complex Arithmetic", "[arithmetic]") {
    

    // 基本括号运算 - 不需要Environment
    REQUIRE(Expression::Eval("(1 + 2) * 3", nullptr).asNumber() == 9.0);
    REQUIRE(Expression::Eval("1 + (2 * 3)", nullptr).asNumber() == 7.0);

    // 多层嵌套括号
    REQUIRE(Expression::Eval("((2 + 3) * (4 - 1)) / 3", nullptr).asNumber() == 5.0);
    REQUIRE(Expression::Eval("(10 - (3 + 2)) * 2", nullptr).asNumber() == 10.0);

    // 复杂的数学表达式
    REQUIRE(Expression::Eval("(5 * 2 + 3) / (4 - 1)", nullptr).asNumber() == Approx(4.333333).epsilon(0.001));
    REQUIRE(Expression::Eval("2 * (3 + 4) - (8 / 2)", nullptr).asNumber() == 10.0);

    // 带负号的括号运算
    REQUIRE(Expression::Eval("-(2 + 3) * 4", nullptr).asNumber() == -20.0);
    REQUIRE(Expression::Eval("(-5 + 3) * 2", nullptr).asNumber() == -4.0);
}

TEST_CASE("Variables in Complex Expressions", "[variables]") {
    
    TestEnvironment environment;

    // 设置测试变量
    environment.set("x", Value(10.0));
    environment.set("y", Value(5.0));
    environment.set("z", Value(2.0));
    environment.set("isActive", Value(true));
    environment.set("isComplete", Value(false));

    // 基本变量运算
    REQUIRE(Expression::Eval("x + y", &environment).asNumber() == 15.0);
    REQUIRE(Expression::Eval("x * y / z", &environment).asNumber() == 25.0);

    // 带括号的变量运算
    REQUIRE(Expression::Eval("(x + y) * z", &environment).asNumber() == 30.0);
    REQUIRE(Expression::Eval("x / (y - z)", &environment).asNumber() == Approx(3.333333).epsilon(0.001));

    // 混合数值和变量
    REQUIRE(Expression::Eval("x + 5 * y", &environment).asNumber() == 35.0);
    REQUIRE(Expression::Eval("(x - 3) / (y + 2)", &environment).asNumber() == 1.0);

    // 布尔变量运算
    REQUIRE(Expression::Eval("isActive && !isComplete", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("isActive || isComplete", &environment).asBoolean() == true);

    // 混合数值比较和布尔变量
    REQUIRE(Expression::Eval("(x > y) && isActive", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("(x == 10) and !isComplete", &environment).asBoolean() == true);
}

TEST_CASE("Real World Scenarios", "[practical]") {
    
    TestEnvironment environment;

    // 几何计算场景
    environment.set("radius", 5.0);
    environment.set("pi", 3.14159);

    // 游戏状态判断场景
    environment.set("health", 75.0);
    environment.set("maxHealth", 100.0);
    environment.set("hasShield", true);
    environment.set("level", 5.0);

    // 商业逻辑场景
    environment.set("price", 99.99);
    environment.set("discount", 0.15);
    environment.set("quantity", 3.0);
    environment.set("shipping", 9.99);
    environment.set("isPremium", true);

    // 圆的面积: π * r² - 直接传入Environment
    REQUIRE(Expression::Eval("pi * radius * radius", &environment).asNumber() == Approx(78.539).epsilon(0.01));

    // 判断玩家状态
    REQUIRE(Expression::Eval("health > maxHealth / 2", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("(health / maxHealth) >= 0.5 && hasShield", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("level >= 5 && (health > 50 || hasShield)", &environment).asBoolean() == true);

    // 计算总价格 = (price * (1 - discount) * quantity) + (isPremium ? 0 : shipping)
    double discountedPrice = Expression::Eval("price * (1 - discount)", &environment).asNumber();
    REQUIRE(discountedPrice == Approx(84.9915).epsilon(0.001));

    double totalBeforeShipping = Expression::Eval("price * (1 - discount) * quantity", &environment).asNumber();
    REQUIRE(totalBeforeShipping == Approx(254.97).epsilon(0.01));

    // 免费配送判断
    REQUIRE(Expression::Eval("isPremium || (quantity * price > 200)", &environment).asBoolean() == true);
}

TEST_CASE("Complex Boolean Logic", "[boolean_logic]") {
    
    TestEnvironment environment;

    // 设置用户权限变量
    environment.set("isAdmin", false);
    environment.set("isOwner", true);
    environment.set("hasPermission", false);
    environment.set("isLoggedIn", true);
    environment.set("accountAge", 365.0);
    environment.set("trustScore", 85.0);

    // 复杂权限检查 - 直接传入Environment
    REQUIRE(Expression::Eval("isLoggedIn && (isAdmin || isOwner)", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("(isAdmin || hasPermission) && isLoggedIn", &environment).asBoolean() == false);

    // 多条件验证
    REQUIRE(Expression::Eval("isLoggedIn && accountAge >= 30 && trustScore > 80", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("(isAdmin || (isOwner && trustScore >= 70)) && isLoggedIn", &environment).asBoolean() == true);

    // 复杂的异或逻辑
    REQUIRE(Expression::Eval("isAdmin xor isOwner", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("hasPermission xor (trustScore > 90)", &environment).asBoolean() == false);
}

TEST_CASE("Mixed Type Expressions", "[mixed_types]") {
    
    TestEnvironment environment;

    environment.set("temperature", 25.5);
    environment.set("humidity", 60.0);
    environment.set("isRaining", false);
    environment.set("windSpeed", 15.0);

    // 复合条件
    environment.set("score1", 85.0);
    environment.set("score2", 92.0);
    environment.set("score3", 78.0);

    // 天气条件判断 - 直接传入Environment
    REQUIRE(Expression::Eval("temperature > 20 && humidity < 70", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("!isRaining && windSpeed <= 20", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("(temperature >= 20 && temperature <= 30) && !isRaining", &environment).asBoolean() == true);

    // 平均分计算和及格判断
    double average = Expression::Eval("(score1 + score2 + score3) / 3", &environment).asNumber();
    REQUIRE(average == Approx(85.0).epsilon(0.1));

    // 判断是否所有分数都及格
    REQUIRE(Expression::Eval("score1 >= 60 && score2 >= 60 && score3 >= 60", &environment).asBoolean() == true);
    REQUIRE(Expression::Eval("(score1 + score2 + score3) / 3 >= 80", &environment).asBoolean() == true);
}

TEST_CASE("Edge Cases and Error Handling", "[edge_cases]") {
    

    // 测试空格处理 - 不需要Environment
    REQUIRE(Expression::Eval("  1   +   2  ", nullptr).asNumber() == 3.0);
    REQUIRE(Expression::Eval("true   &&   false", nullptr).asBoolean() == false);

    // 测试运算符优先级
    REQUIRE(Expression::Eval("1 + 2 * 3 + 4", nullptr).asNumber() == 11.0);
    REQUIRE(Expression::Eval("true || false && false", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("(true || false) && false", nullptr).asBoolean() == false);

    // 测试连续运算符
    REQUIRE(Expression::Eval("!!true", nullptr).asBoolean() == true);
    REQUIRE(Expression::Eval("--5", nullptr).asNumber() == 5.0);
    REQUIRE(Expression::Eval("not not false", nullptr).asBoolean() == false);

    // 无效表达式应该抛出异常
    REQUIRE_THROWS_AS(Expression::Eval("1 +", nullptr), ExprException);
    REQUIRE_THROWS_AS(Expression::Eval("(1 + 2", nullptr), ExprException);
    REQUIRE_THROWS_AS(Expression::Eval("1 + 2)", nullptr), ExprException);
    REQUIRE_THROWS_AS(Expression::Eval("", nullptr), ExprException);
}

TEST_CASE("Environments", "[environment]") {
    // 创建一个只读Environment（不重写set方法）
    class ReadOnlyEnvironment : public IEnvironment {
        std::unordered_map<std::string, Value> vars = {
            {"x", Value(10.0)},
            {"y", Value(5.0)}
        };
    public:
        Value Get(const std::string& name) override {
            if (const auto it = vars.find(name); it != vars.end()) return it->second;
            throw ExprException("Variable not defined: " + name);
        }

        // 不重写set方法，使用默认实现

        Value Call(const std::string& name, const std::vector<Value>& args) override {
            throw ExprException("Function not defined: " + name);
        }
    };

    ReadOnlyEnvironment environment;

    SECTION("只读Environment可以正常读取变量") {
        const auto result = Expression::Eval("x + y * 2", &environment);
        REQUIRE(result.asNumber() == 20.0);
    }

    SECTION("可以使用不同的Environment执行相同表达式") {
        // 第一个Environment
        class Environment1 : public IEnvironment {
        public:
            Value Get(const std::string& name) override {
                if (name == "value") return 100;
                throw ExprException("Variable not defined: " + name);
            }
            Value Call(const std::string& name, const std::vector<Value>& args) override {
                throw ExprException("Function not defined: " + name);
            }
        };

        // 第二个Environment
        class Environment2 : public IEnvironment {
        public:
            Value Get(const std::string& name) override {
                if (name == "value") return 200;
                throw ExprException("Variable not defined: " + name);
            }
            Value Call(const std::string& name, const std::vector<Value>& args) override {
                throw ExprException("Function not defined: " + name);
            }
        };

        Environment1 environment1;
        Environment2 environment2;

        // 同一个表达式，不同的Environment，得到不同的结果
        const auto result1 = Expression::Eval("value * 2", &environment1);
        const auto result2 = Expression::Eval("value * 2", &environment2);

        REQUIRE(result1.asNumber() == 200.0);
        REQUIRE(result2.asNumber() == 400.0);
    }
}

TEST_CASE("Standard Mathematical Functions", "[standard_functions]") {
    // 创建一个使用标准函数的Environment
    class StandardMathEnvironment : public IEnvironment {
    public:
        Value Get(const std::string& name) override {
            throw ExprException("Variable not defined: " + name);
        }

        Value Call(const std::string& name, const std::vector<Value>& args) override {
            Value result;

            // 先尝试标准数学函数
            if (Expression::CallStandardFunctions(name, args, result)) {
                return result;
            }

            throw ExprException("Function not defined: " + name);
        }
    };

    StandardMathEnvironment environment;

    SECTION("Two-argument functions") {
        // min函数
        REQUIRE(Expression::Eval("min(10, 5)", &environment).asNumber() == 5.0);
        REQUIRE(Expression::Eval("min(-3, 7)", &environment).asNumber() == -3.0);
        REQUIRE(Expression::Eval("min(3.14, 2.71)", &environment).asNumber() == Approx(2.71));

        // max函数
        REQUIRE(Expression::Eval("max(10, 5)", &environment).asNumber() == 10.0);
        REQUIRE(Expression::Eval("max(-3, 7)", &environment).asNumber() == 7.0);
        REQUIRE(Expression::Eval("max(3.14, 2.71)", &environment).asNumber() == Approx(3.14));

        // pow函数
        REQUIRE(Expression::Eval("pow(2, 3)", &environment).asNumber() == 8.0);
        REQUIRE(Expression::Eval("pow(5, 2)", &environment).asNumber() == 25.0);
        REQUIRE(Expression::Eval("pow(2, 0)", &environment).asNumber() == 1.0);
        REQUIRE(Expression::Eval("pow(4, 0.5)", &environment).asNumber() == Approx(2.0));
    }

    SECTION("Single-argument functions") {
        // sqrt函数
        REQUIRE(Expression::Eval("sqrt(16)", &environment).asNumber() == 4.0);
        REQUIRE(Expression::Eval("sqrt(25)", &environment).asNumber() == 5.0);
        REQUIRE(Expression::Eval("sqrt(2)", &environment).asNumber() == Approx(1.414213).epsilon(0.000001));

        // abs函数
        REQUIRE(Expression::Eval("abs(5)", &environment).asNumber() == 5.0);
        REQUIRE(Expression::Eval("abs(-5)", &environment).asNumber() == 5.0);
        REQUIRE(Expression::Eval("abs(-3.14)", &environment).asNumber() == Approx(3.14));

        // floor函数
        REQUIRE(Expression::Eval("floor(3.7)", &environment).asNumber() == 3.0);
        REQUIRE(Expression::Eval("floor(-2.3)", &environment).asNumber() == -3.0);
        REQUIRE(Expression::Eval("floor(5.0)", &environment).asNumber() == 5.0);

        // ceil函数
        REQUIRE(Expression::Eval("ceil(3.2)", &environment).asNumber() == 4.0);
        REQUIRE(Expression::Eval("ceil(-2.8)", &environment).asNumber() == -2.0);
        REQUIRE(Expression::Eval("ceil(5.0)", &environment).asNumber() == 5.0);

        // round函数
        REQUIRE(Expression::Eval("round(3.6)", &environment).asNumber() == 4.0);
        REQUIRE(Expression::Eval("round(3.4)", &environment).asNumber() == 3.0);
        REQUIRE(Expression::Eval("round(-2.7)", &environment).asNumber() == -3.0);
    }

    SECTION("Trigonometric functions") {
        const double pi = 3.14159265358979323846;

        // sin函数
        REQUIRE(Expression::Eval("sin(0)", &environment).asNumber() == Approx(0.0).epsilon(0.000001));
        REQUIRE(Expression::Eval("sin(1.5707963)", &environment).asNumber() == Approx(1.0).epsilon(0.000001)); // sin(π/2)

        // cos函数
        REQUIRE(Expression::Eval("cos(0)", &environment).asNumber() == Approx(1.0).epsilon(0.000001));
        REQUIRE(Expression::Eval("cos(3.14159265)", &environment).asNumber() == Approx(-1.0).epsilon(0.000001)); // cos(π)

        // tan函数
        REQUIRE(Expression::Eval("tan(0)", &environment).asNumber() == Approx(0.0).epsilon(0.000001));
        REQUIRE(Expression::Eval("tan(0.78539816)", &environment).asNumber() == Approx(1.0).epsilon(0.000001)); // tan(π/4)
    }

    SECTION("Logarithmic and exponential functions") {
        // exp函数
        REQUIRE(Expression::Eval("exp(0)", &environment).asNumber() == Approx(1.0).epsilon(0.000001));
        REQUIRE(Expression::Eval("exp(1)", &environment).asNumber() == Approx(2.718281).epsilon(0.000001)); // e

        // log函数 (自然对数)
        REQUIRE(Expression::Eval("log(1)", &environment).asNumber() == Approx(0.0).epsilon(0.000001));
        REQUIRE(Expression::Eval("log(2.718281)", &environment).asNumber() == Approx(1.0).epsilon(0.001)); // ln(e)
    }

    SECTION("Complex expressions with standard functions") {
        // 复合函数调用
        REQUIRE(Expression::Eval("max(abs(-5), sqrt(16))", &environment).asNumber() == 5.0);
        REQUIRE(Expression::Eval("min(ceil(3.2), floor(5.8))", &environment).asNumber() == 4.0);
        REQUIRE(Expression::Eval("pow(sqrt(4), 3)", &environment).asNumber() == 8.0);

        // 与算术运算结合
        REQUIRE(Expression::Eval("sqrt(25) + abs(-3)", &environment).asNumber() == 8.0);
        REQUIRE(Expression::Eval("max(10, 5) * min(2, 3)", &environment).asNumber() == 20.0);
        REQUIRE(Expression::Eval("pow(2, 3) - sqrt(9)", &environment).asNumber() == 5.0);
    }

    SECTION("Error handling for standard functions") {
        // sqrt负数应该返回false (通过backend的调用会抛出异常)
        REQUIRE_THROWS_AS(Expression::Eval("sqrt(-1)", &environment), ExprException);

        // log非正数应该返回false
        REQUIRE_THROWS_AS(Expression::Eval("log(0)", &environment), ExprException);
        REQUIRE_THROWS_AS(Expression::Eval("log(-1)", &environment), ExprException);
    }

    SECTION("Direct CallStandardFunctions testing") {
        std::vector<Value> args;
        Value result;

        // 测试min函数
        args = {Value(10.0), Value(5.0)};
        REQUIRE(Expression::CallStandardFunctions("min", args, result) == true);
        REQUIRE(result.asNumber() == 5.0);

        // 测试sqrt函数
        args = {Value(16.0)};
        REQUIRE(Expression::CallStandardFunctions("sqrt", args, result) == true);
        REQUIRE(result.asNumber() == 4.0);

        // 测试不存在的函数
        args = {Value(1.0)};
        REQUIRE(Expression::CallStandardFunctions("nonexistent", args, result) == false);

        // 测试参数数量错误
        args = {Value(1.0), Value(2.0), Value(3.0)};
        REQUIRE(Expression::CallStandardFunctions("sqrt", args, result) == false);

        // 测试参数类型错误
        args = {Value(true)};
        REQUIRE(Expression::CallStandardFunctions("sqrt", args, result) == false);
    }
}

TEST_CASE("Token Collection", "[tokens]") {
    
    SECTION("Basic number token") {
        std::vector<Token> tokens;
        Expression::Eval("42", nullptr, &tokens);
        
        REQUIRE(tokens.size() == 1);
        REQUIRE(tokens[0].type == TokenType::NUMBER);
        REQUIRE(tokens[0].text == "42");
        REQUIRE(tokens[0].start == 0);
        REQUIRE(tokens[0].length == 2);
    }
    
    SECTION("Basic boolean token") {
        std::vector<Token> tokens;
        Expression::Eval("true", nullptr, &tokens);
        
        REQUIRE(tokens.size() == 1);
        REQUIRE(tokens[0].type == TokenType::BOOLEAN);
        REQUIRE(tokens[0].text == "true");
    }
    
    SECTION("Basic string token") {
        std::vector<Token> tokens;
        Expression::Eval("\"hello\"", nullptr, &tokens);
        
        REQUIRE(tokens.size() == 1);
        REQUIRE(tokens[0].type == TokenType::STRING);
        REQUIRE(tokens[0].text == "\"hello\"");
    }
    
    SECTION("Basic identifier token") {
        TestEnvironment environment;
        environment.set("x", Value(5.0));
        
        std::vector<Token> tokens;
        Expression::Eval("x", &environment, &tokens);
        
        REQUIRE(tokens.size() == 1);
        REQUIRE(tokens[0].type == TokenType::IDENTIFIER);
        REQUIRE(tokens[0].text == "x");
    }
    
    SECTION("Arithmetic expression tokens") {
        std::vector<Token> tokens;
        Expression::Eval("2 + 3", nullptr, &tokens);
        
        // Should collect at least: "2", "+", "3" (whitespace may vary)
        REQUIRE(tokens.size() >= 3);
        
        // Find the specific token types
        bool hasNumber2 = false, hasPlus = false, hasNumber3 = false;
        for (const auto& token : tokens) {
            if (token.type == TokenType::NUMBER && token.text == "2") hasNumber2 = true;
            if (token.type == TokenType::OPERATOR && token.text == "+") hasPlus = true;
            if (token.type == TokenType::NUMBER && token.text == "3") hasNumber3 = true;
        }
        
        REQUIRE(hasNumber2);
        REQUIRE(hasPlus);
        REQUIRE(hasNumber3);
    }
    
    SECTION("Complex expression tokens") {
        TestEnvironment environment;
        environment.set("x", Value(10.0));
        
        std::vector<Token> tokens;
        Expression::Eval("(x + 5) * 2", &environment, &tokens);
        
        // Find specific token types
        bool hasParenthesis = false;
        bool hasIdentifier = false;
        bool hasOperator = false;
        bool hasNumber = false;
        
        for (const auto& token : tokens) {
            if (token.type == TokenType::PARENTHESIS) hasParenthesis = true;
            if (token.type == TokenType::IDENTIFIER) hasIdentifier = true;
            if (token.type == TokenType::OPERATOR) hasOperator = true;
            if (token.type == TokenType::NUMBER) hasNumber = true;
        }
        
        REQUIRE(hasParenthesis);
        REQUIRE(hasIdentifier);
        REQUIRE(hasOperator);
        REQUIRE(hasNumber);
    }
    
    SECTION("Function call tokens") {
        TestEnvironment environment;
        
        std::vector<Token> tokens;
        Expression::Eval("add(2, 3)", &environment, &tokens);
        
        // Should have function name, parentheses, numbers, and comma
        bool hasFunction = false;
        bool hasComma = false;
        
        for (const auto& token : tokens) {
            if (token.type == TokenType::IDENTIFIER && token.text == "add") hasFunction = true;
            if (token.type == TokenType::COMMA) hasComma = true;
        }
        
        REQUIRE(hasFunction);
        REQUIRE(hasComma);
    }
    
    SECTION("Parse with tokens vs without tokens") {
        // Test that parsing with and without tokens produces the same AST
        TestEnvironment environment;
        environment.set("x", Value(10.0));
        
        auto result1 = Expression::Eval("x + 5", &environment);
        
        std::vector<Token> tokens;
        auto result2 = Expression::Eval("x + 5", &environment, &tokens);
        
        REQUIRE(result1.asNumber() == result2.asNumber());
        REQUIRE(tokens.size() > 0); // Should have collected some tokens
    }
}

TEST_CASE("String Literals", "[strings]") {
    
    SECTION("Basic string literals") {
        auto result = Expression::Eval("\"hello\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "hello");
    }
    
    SECTION("Empty string") {
        auto result = Expression::Eval("\"\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "");
    }
    
    SECTION("String with spaces") {
        auto result = Expression::Eval("\"hello world\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "hello world");
    }
    
    SECTION("Strings with escape sequences") {
        // Test newline escape
        auto result1 = Expression::Eval("\"hello\\nworld\"", nullptr);
        REQUIRE(result1.asString() == "hello\nworld");
        
        // Test tab escape
        auto result2 = Expression::Eval("\"hello\\tworld\"", nullptr);
        REQUIRE(result2.asString() == "hello\tworld");
        
        // Test backslash escape
        auto result3 = Expression::Eval("\"hello\\\\world\"", nullptr);
        REQUIRE(result3.asString() == "hello\\world");
        
        // Test quote escape
        auto result4 = Expression::Eval("\"hello\\\"world\"", nullptr);
        REQUIRE(result4.asString() == "hello\"world");
        
        // Test carriage return escape
        auto result5 = Expression::Eval("\"hello\\rworld\"", nullptr);
        REQUIRE(result5.asString() == "hello\rworld");
    }
    
    SECTION("String with unknown escape sequence") {
        // Unknown escape sequences should be preserved
        auto result = Expression::Eval("\"hello\\xworld\"", nullptr);
        REQUIRE(result.asString() == "hello\\xworld");
    }
    
    SECTION("Unterminated string should throw") {
        REQUIRE_THROWS_AS(Expression::Eval("\"unterminated", nullptr), ExprException);
    }
}

TEST_CASE("String Concatenation", "[strings]") {
    
    SECTION("Basic string concatenation") {
        auto result = Expression::Eval("\"hello\" + \"world\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "helloworld");
    }
    
    SECTION("String concatenation with spaces") {
        auto result = Expression::Eval("\"hello \" + \"world\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "hello world");
    }
    
    SECTION("Multiple string concatenation") {
        auto result = Expression::Eval("\"a\" + \"b\" + \"c\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "abc");
    }
    
    SECTION("String concatenation with parentheses") {
        auto result = Expression::Eval("\"hello \" + (\"beautiful \" + \"world\")", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "hello beautiful world");
    }
    
    SECTION("String concatenation with numbers") {
        auto result1 = Expression::Eval("\"value: \" + 42", nullptr);
        REQUIRE(result1.isString());
        REQUIRE(result1.asString() == "value: 42.000000");
        
        auto result2 = Expression::Eval("123 + \" is the number\"", nullptr);
        REQUIRE(result2.isString());
        REQUIRE(result2.asString() == "123.000000 is the number");
    }
    
    SECTION("String concatenation with booleans") {
        auto result1 = Expression::Eval("\"status: \" + true", nullptr);
        REQUIRE(result1.isString());
        REQUIRE(result1.asString() == "status: true");
        
        auto result2 = Expression::Eval("false + \" value\"", nullptr);
        REQUIRE(result2.isString());
        REQUIRE(result2.asString() == "false value");
    }
}

TEST_CASE("String Comparison", "[strings]") {
    
    SECTION("String equality") {
        REQUIRE(Expression::Eval("\"hello\" == \"hello\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"hello\" == \"world\"", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"\" == \"\"", nullptr).asBoolean() == true);
    }
    
    SECTION("String inequality") {
        REQUIRE(Expression::Eval("\"hello\" != \"world\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"hello\" != \"hello\"", nullptr).asBoolean() == false);
    }
    
    SECTION("String lexicographic comparison") {
        // Less than
        REQUIRE(Expression::Eval("\"apple\" < \"banana\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"banana\" < \"apple\"", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"apple\" < \"apple\"", nullptr).asBoolean() == false);
        
        // Greater than  
        REQUIRE(Expression::Eval("\"banana\" > \"apple\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"apple\" > \"banana\"", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"apple\" > \"apple\"", nullptr).asBoolean() == false);
        
        // Less than or equal
        REQUIRE(Expression::Eval("\"apple\" <= \"banana\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"apple\" <= \"apple\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"banana\" <= \"apple\"", nullptr).asBoolean() == false);
        
        // Greater than or equal
        REQUIRE(Expression::Eval("\"banana\" >= \"apple\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"apple\" >= \"apple\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"apple\" >= \"banana\"", nullptr).asBoolean() == false);
    }
    
    SECTION("String comparison with different types should throw for ordering") {
        REQUIRE_THROWS_AS(Expression::Eval("\"hello\" > 42", nullptr), ExprException);
        REQUIRE_THROWS_AS(Expression::Eval("42 < \"world\"", nullptr), ExprException);
        REQUIRE_THROWS_AS(Expression::Eval("\"test\" >= true", nullptr), ExprException);
    }
    
    SECTION("Mixed-type equality comparison") {
        // Different types should be not equal
        REQUIRE(Expression::Eval("\"42\" == 42", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"true\" == true", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"42\" != 42", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"true\" != true", nullptr).asBoolean() == true);
    }
}

TEST_CASE("Type Conversion", "[strings]") {
    
    SECTION("String to number conversion") {
        auto value1 = Value("42");
        REQUIRE(value1.asNumber() == 42.0);
        
        auto value2 = Value("3.14");
        REQUIRE(value2.asNumber() == Approx(3.14));
        
        auto value3 = Value("-5.5");
        REQUIRE(value3.asNumber() == Approx(-5.5));
    }
    
    SECTION("Invalid string to number conversion should throw") {
        auto value1 = Value("hello");
        REQUIRE_THROWS_AS(value1.asNumber(), ExprException);
        
        auto value2 = Value("123abc");
        REQUIRE_THROWS_AS(value2.asNumber(), ExprException);
        
        auto value3 = Value("");
        REQUIRE_THROWS_AS(value3.asNumber(), ExprException);
    }
    
    SECTION("String to boolean conversion") {
        auto value1 = Value("hello");
        REQUIRE(value1.asBoolean() == true); // Non-empty string is true
        
        auto value2 = Value("");
        REQUIRE(value2.asBoolean() == false); // Empty string is false
        
        // Test explicit false values
        auto value3 = Value("false");
        REQUIRE(value3.asBoolean() == false);
        
        auto value4 = Value("False");
        REQUIRE(value4.asBoolean() == false);
        
        auto value5 = Value("FALSE");
        REQUIRE(value5.asBoolean() == false);
        
        auto value6 = Value("no");
        REQUIRE(value6.asBoolean() == false);
        
        auto value7 = Value("No");
        REQUIRE(value7.asBoolean() == false);
        
        auto value8 = Value("NO");
        REQUIRE(value8.asBoolean() == false);
        
        auto value9 = Value("0");
        REQUIRE(value9.asBoolean() == false); // "0" string is now false
        
        // Test other strings that should be true
        auto value10 = Value("true");
        REQUIRE(value10.asBoolean() == true);
        
        auto value11 = Value("yes");
        REQUIRE(value11.asBoolean() == true);
        
        auto value12 = Value("1");
        REQUIRE(value12.asBoolean() == true);
        
        auto value13 = Value("anything");
        REQUIRE(value13.asBoolean() == true);
    }
    
    SECTION("Number to string conversion") {
        auto value1 = Value(42.0);
        REQUIRE(value1.asString() == "42.000000");
        
        auto value2 = Value(3.14);
        // Note: exact string representation may vary, just check it contains the number
        std::string str = value2.asString();
        REQUIRE(str.find("3.14") != std::string::npos);
    }
    
    SECTION("Boolean to string conversion") {
        auto value1 = Value(true);
        REQUIRE(value1.asString() == "true");
        
        auto value2 = Value(false);
        REQUIRE(value2.asString() == "false");
    }
    
    SECTION("Boolean to number conversion") {
        auto value1 = Value(true);
        REQUIRE(value1.asNumber() == 1.0);
        
        auto value2 = Value(false);
        REQUIRE(value2.asNumber() == 0.0);
    }
    
    SECTION("Number to boolean conversion") {
        auto value1 = Value(1.0);
        REQUIRE(value1.asBoolean() == true);
        
        auto value2 = Value(0.0);
        REQUIRE(value2.asBoolean() == false);
        
        auto value3 = Value(-5.5);
        REQUIRE(value3.asBoolean() == true); // Non-zero is true
    }
}

TEST_CASE("String Variables and Functions", "[strings]") {
    
    class StringTestEnvironment : public IEnvironment {
        std::map<std::string, Value> variables;
    public:
        StringTestEnvironment() {
            variables["name"] = Value("Alice");
            variables["greeting"] = Value("Hello");
            variables["count"] = Value(5.0);
            variables["isActive"] = Value(true);
        }
        
        Value Get(const std::string& name) override {
            if (const auto it = variables.find(name); it != variables.end()) return it->second;
            throw ExprException("Variable not defined: " + name);
        }
        
        Value Call(const std::string& name, const std::vector<Value>& args) override {
            if (name == "concat" && args.size() == 2) {
                return Value(args[0].asString() + args[1].asString());
            }
            throw ExprException("Function not defined: " + name);
        }
    };
    
    StringTestEnvironment environment;
    
    SECTION("String variables") {
        auto result = Expression::Eval("name", &environment);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "Alice");
    }
    
    SECTION("String concatenation with variables") {
        auto result = Expression::Eval("greeting + \", \" + name", &environment);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "Hello, Alice");
    }
    
    SECTION("Mixed type expressions with string variables") {
        auto result1 = Expression::Eval("name + \" has \" + count + \" items\"", &environment);
        REQUIRE(result1.isString());
        REQUIRE(result1.asString() == "Alice has 5.000000 items");
        
        auto result2 = Expression::Eval("\"User \" + name + \" is \" + isActive", &environment);
        REQUIRE(result2.isString());
        REQUIRE(result2.asString() == "User Alice is true");
    }
    
    SECTION("String comparison with variables") {
        REQUIRE(Expression::Eval("name == \"Alice\"", &environment).asBoolean() == true);
        REQUIRE(Expression::Eval("greeting != \"Hi\"", &environment).asBoolean() == true);
        REQUIRE(Expression::Eval("name > \"A\"", &environment).asBoolean() == true);
    }
    
    SECTION("String functions") {
        auto result = Expression::Eval("concat(greeting, name)", &environment);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "HelloAlice");
    }
}

TEST_CASE("Complex String Expressions", "[strings]") {
    
    SECTION("Nested string concatenation with arithmetic") {
        auto result = Expression::Eval("\"Result: \" + (5 + 3) + \" items\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "Result: 8.000000 items");
    }
    
    SECTION("String expressions with boolean logic") {
        auto result1 = Expression::Eval("(\"a\" < \"b\") && (\"hello\" != \"world\")", nullptr);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("(\"test\" == \"test\") || (\"x\" > \"z\")", nullptr);
        REQUIRE(result2.asBoolean() == true);
    }
    
    SECTION("Parenthesized string expressions") {
        auto result = Expression::Eval("(\"hello\" + \" \") + (\"beautiful\" + \" world\")", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "hello beautiful world");
    }
    
    SECTION("String expression with escape sequences in concatenation") {
        auto result = Expression::Eval("\"Line 1\\n\" + \"Line 2\\t\" + \"End\"", nullptr);
        REQUIRE(result.isString());
        REQUIRE(result.asString() == "Line 1\nLine 2\tEnd");
    }
}

TEST_CASE("Improved String to Boolean Conversion", "[string_boolean]") {
    
    SECTION("Explicit false values") {
        // Test case variations of "false"
        REQUIRE(Value("false").asBoolean() == false);
        REQUIRE(Value("False").asBoolean() == false);
        REQUIRE(Value("FALSE").asBoolean() == false);
        
        // Test case variations of "no"
        REQUIRE(Value("no").asBoolean() == false);
        REQUIRE(Value("No").asBoolean() == false);
        REQUIRE(Value("NO").asBoolean() == false);
        
        // Test "0" string
        REQUIRE(Value("0").asBoolean() == false);
        
        // Test empty string
        REQUIRE(Value("").asBoolean() == false);
    }
    
    SECTION("Explicit true values") {
        // Common true-like strings
        REQUIRE(Value("true").asBoolean() == true);
        REQUIRE(Value("True").asBoolean() == true);
        REQUIRE(Value("TRUE").asBoolean() == true);
        REQUIRE(Value("yes").asBoolean() == true);
        REQUIRE(Value("Yes").asBoolean() == true);
        REQUIRE(Value("YES").asBoolean() == true);
        REQUIRE(Value("1").asBoolean() == true);
        REQUIRE(Value("on").asBoolean() == true);
        REQUIRE(Value("enabled").asBoolean() == true);
        
        // Any other non-empty string should be true
        REQUIRE(Value("hello").asBoolean() == true);
        REQUIRE(Value("world").asBoolean() == true);
        REQUIRE(Value("123").asBoolean() == true);
        REQUIRE(Value("anything").asBoolean() == true);
    }
    
    SECTION("String boolean conversion in expressions") {
        // Test string-to-boolean conversion in logical expressions
        REQUIRE(Expression::Eval("\"true\" && true", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"false\" || false", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"no\" && true", nullptr).asBoolean() == false);
        REQUIRE(Expression::Eval("\"0\" || true", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("\"yes\" && true", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("!\"false\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("!\"no\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("!\"0\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("!\"\"", nullptr).asBoolean() == true);
        REQUIRE(Expression::Eval("!\"true\"", nullptr).asBoolean() == false);
    }
}

TEST_CASE("String In Operator", "[strings]") {
    
    SECTION("Basic string containment") {
        auto result1 = Expression::Eval("\"abc\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result1.isBoolean());
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("\"xyz\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result2.isBoolean());
        REQUIRE(result2.asBoolean() == false);
    }
    
    SECTION("Case sensitive containment") {
        auto result1 = Expression::Eval("\"ABC\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result1.asBoolean() == false);
        
        auto result2 = Expression::Eval("\"sing\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result2.asBoolean() == true);
    }
    
    SECTION("Empty string containment") {
        auto result1 = Expression::Eval("\"\" in \"hello world\"", nullptr);
        REQUIRE(result1.asBoolean() == true); // Empty string is contained in any string
        
        auto result2 = Expression::Eval("\"hello\" in \"\"", nullptr);
        REQUIRE(result2.asBoolean() == false); // Non-empty string is not contained in empty string
    }
    
    SECTION("Exact match containment") {
        auto result1 = Expression::Eval("\"hello\" in \"hello\"", nullptr);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("\"hello world\" in \"hello world\"", nullptr);
        REQUIRE(result2.asBoolean() == true);
    }
    
    SECTION("Partial word containment") {
        auto result1 = Expression::Eval("\"can\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("\"sing\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result2.asBoolean() == true);
        
        auto result3 = Expression::Eval("\"my\" in \"I can sing my abc\"", nullptr);
        REQUIRE(result3.asBoolean() == true);
    }
    
    SECTION("String in operator with variables") {
        TestEnvironment environment;
        environment.set("text", Value("The quick brown fox"));
        environment.set("search", Value("brown"));
        environment.set("missing", Value("zebra"));
        
        auto result1 = Expression::Eval("search in text", &environment);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("missing in text", &environment);
        REQUIRE(result2.asBoolean() == false);
        
        auto result3 = Expression::Eval("\"quick\" in text", &environment);
        REQUIRE(result3.asBoolean() == true);
    }
    
    SECTION("String in operator with complex expressions") {
        auto result1 = Expression::Eval("(\"a\" + \"b\") in \"abc\"", nullptr);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("\"test\" in (\"This is a \" + \"test string\")", nullptr);
        REQUIRE(result2.asBoolean() == true);
    }
    
    SECTION("Boolean logic with in operator") {
        auto result1 = Expression::Eval("(\"abc\" in \"abcdef\") && (\"xyz\" in \"xyz123\")", nullptr);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("(\"abc\" in \"abcdef\") || (\"xyz\" in \"123\")", nullptr);
        REQUIRE(result2.asBoolean() == true);
        
        auto result3 = Expression::Eval("!(\"xyz\" in \"abc\")", nullptr);
        REQUIRE(result3.asBoolean() == true);
    }
    
    SECTION("In operator with escape sequences") {
        auto result1 = Expression::Eval("\"\\n\" in \"Hello\\nWorld\"", nullptr);
        REQUIRE(result1.asBoolean() == true);
        
        auto result2 = Expression::Eval("\"\\t\" in \"Tab\\there\"", nullptr);
        REQUIRE(result2.asBoolean() == true);
    }
    
    SECTION("In operator should require string operands") {
        REQUIRE_THROWS_AS(Expression::Eval("5 in \"hello\"", nullptr), ExprException);
        REQUIRE_THROWS_AS(Expression::Eval("\"hello\" in 5", nullptr), ExprException);
        REQUIRE_THROWS_AS(Expression::Eval("true in \"hello\"", nullptr), ExprException);
    }
}
