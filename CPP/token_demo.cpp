/*
 * ExpressionKit Token Demo
 * 
 * This demo showcases the token sequence output functionality that allows
 * for syntax highlighting, expression analysis, and other advanced features.
 */

#include "../ExpressionKit.hpp"
#include <iostream>
#include <iomanip>
#include <unordered_map>
#include <vector>
#include <cmath>

using namespace ExpressionKit;

// Function to print token type name
std::string tokenTypeName(TokenType type) {
    switch (type) {
        case TokenType::NUMBER: return "NUMBER";
        case TokenType::BOOLEAN: return "BOOLEAN";
        case TokenType::IDENTIFIER: return "IDENTIFIER";
        case TokenType::OPERATOR: return "OPERATOR";
        case TokenType::PARENTHESIS: return "PARENTHESIS";
        case TokenType::COMMA: return "COMMA";
        case TokenType::WHITESPACE: return "WHITESPACE";
        case TokenType::UNKNOWN: return "UNKNOWN";
    }
    return "UNKNOWN";
}

// Function to demonstrate token collection for an expression
void demonstrateTokens(const std::string& expression, IEnvironment* environment = nullptr) {
    std::cout << "\n" << std::string(60, '=') << std::endl;
    std::cout << "Expression: " << expression << std::endl;
    std::cout << std::string(60, '=') << std::endl;
    
    try {
        // Collect tokens during evaluation
        std::vector<Token> tokens;
        Value result = ExpressionKit::Eval(expression, environment, &tokens);
        
        std::cout << "Result: " << result.toString() << std::endl;
        std::cout << "\nTokens collected (" << tokens.size() << " total):" << std::endl;
        std::cout << std::left << std::setw(12) << "Type" 
                  << std::setw(8) << "Start" 
                  << std::setw(8) << "Length" 
                  << "Text" << std::endl;
        std::cout << std::string(60, '-') << std::endl;
        
        for (const auto& token : tokens) {
            std::cout << std::left << std::setw(12) << tokenTypeName(token.type)
                      << std::setw(8) << token.start
                      << std::setw(8) << token.length
                      << "\"" << token.text << "\"" << std::endl;
        }
        
        // Demonstrate parsing with tokens (for pre-compilation scenarios)
        std::cout << "\n--- Alternative: Parse with tokens, then execute ---" << std::endl;
        std::vector<Token> parseTokens;
        auto ast = ExpressionKit::Parse(expression, &parseTokens);
        Value parseResult = ast->evaluate(environment);
        
        std::cout << "Parse result: " << parseResult.toString() << std::endl;
        std::cout << "Parse tokens: " << parseTokens.size() << " (same as above)" << std::endl;
        
    } catch (const ExprException& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }
}

// Simple environment for variable demonstration
class DemoBackend : public IEnvironment {
    std::unordered_map<std::string, Value> variables;
    
public:
    DemoBackend() {
        variables["x"] = 10.0;
        variables["y"] = 5.0;
        variables["pi"] = 3.14159;
        variables["isActive"] = true;
        variables["player.health"] = 75.0;
        variables["player.maxHealth"] = 100.0;
    }
    
    Value Get(const std::string& name) override {
        auto it = variables.find(name);
        if (it != variables.end()) return it->second;
        throw ExprException("Variable not found: " + name);
    }
    
    Value Call(const std::string& name, const std::vector<Value>& args) override {
        // First try standard mathematical functions
        Value result;
        if (ExpressionKit::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // Custom functions
        if (name == "distance" && args.size() == 4) {
            double x1 = args[0].asNumber(), y1 = args[1].asNumber();
            double x2 = args[2].asNumber(), y2 = args[3].asNumber();
            double dx = x2 - x1, dy = y2 - y1;
            return Value(std::sqrt(dx*dx + dy*dy));
        }
        
        throw ExprException("Function not found: " + name);
    }
};

int main() {
    std::cout << "🚀 ExpressionKit Token Sequence Demo" << std::endl;
    std::cout << "=====================================" << std::endl;
    std::cout << "\nThis demo shows how to collect token sequences during expression" << std::endl;
    std::cout << "parsing for syntax highlighting, analysis, and other advanced features." << std::endl;
    
    // Basic arithmetic expression
    demonstrateTokens("2 + 3 * 4");
    
    // Boolean expression with operators
    demonstrateTokens("true && (false || !true)");
    
    // Complex expression with parentheses
    demonstrateTokens("(10 + 5) * 2 - 3");
    
    // Expression with comparison operators
    demonstrateTokens("5 >= 3 && 10 != 8");
    
    // Mathematical functions
    demonstrateTokens("max(10, 5) + sqrt(16)");
    
    // Now with environment for variables and custom functions
    DemoBackend environment;
    
    // Variable access
    demonstrateTokens("x + y * pi", &environment);
    
    // Complex expression with variables
    demonstrateTokens("player.health / player.maxHealth >= 0.5", &environment);
    
    // Function call with variables
    demonstrateTokens("distance(0, 0, x, y)", &environment);
    
    // Mixed expression with everything
    demonstrateTokens("isActive && (player.health > 50) && max(x, y) >= 5", &environment);
    
    std::cout << "\n" << std::string(60, '=') << std::endl;
    std::cout << "🎯 Use Cases for Token Sequences:" << std::endl;
    std::cout << "• Syntax highlighting in code editors" << std::endl;
    std::cout << "• Expression validation and error reporting" << std::endl;
    std::cout << "• Auto-completion for variables and functions" << std::endl;
    std::cout << "• Expression formatting and pretty-printing" << std::endl;
    std::cout << "• Static analysis and optimization" << std::endl;
    std::cout << "• IDE integration and debugging tools" << std::endl;
    std::cout << std::string(60, '=') << std::endl;
    
    return 0;
}