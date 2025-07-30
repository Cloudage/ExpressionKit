/*
 * ExpressionKit Interactive CLI Demo
 * 
 * This demo provides an interactive command-line interface for the ExpressionKit
 * expression evaluation library. Users can set variables, evaluate expressions,
 * and manage their workspace through simple commands.
 */

#include "../ExpressionKit.hpp"
#include <iostream>
#include <sstream>
#include <map>
#include <string>
#include <iomanip>
#include <algorithm>

using namespace ExpressionKit;

// ANSI Color codes for syntax highlighting
namespace Colors {
    const std::string RESET = "\033[0m";
    const std::string NUMBER = "\033[36m";      // Cyan for numbers
    const std::string STRING = "\033[32m";      // Green for strings
    const std::string IDENTIFIER = "\033[33m";  // Yellow for variables
    const std::string OPERATOR = "\033[31m";    // Red for operators
    const std::string PARENTHESIS = "\033[37m"; // White for parentheses
    const std::string COMMA = "\033[37m";       // White for commas
    const std::string BOOLEAN = "\033[35m";     // Magenta for booleans
    const std::string UNKNOWN = "\033[91m";     // Bright red for unknown tokens
}

/**
 * @brief Apply syntax highlighting to an expression using token parsing
 * @param expression The expression to highlight
 * @param environment Optional environment for token parsing context
 * @return Highlighted expression with ANSI color codes
 */
std::string highlightExpression(const std::string& expression, IEnvironment* environment = nullptr) {
    if (expression.empty()) {
        return expression;
    }
    
    try {
        // Parse the expression to collect tokens
        std::vector<Token> tokens;
        
        // Try to parse - if it fails, we'll still get partial tokens
        try {
            Expression::Parse(expression, &tokens);
        } catch (const ExprException&) {
            // Even if parsing fails, we might have collected some tokens
            // This allows highlighting even for incomplete expressions
        }
        
        if (tokens.empty()) {
            return expression; // Fallback to original if no tokens
        }
        
        // Sort tokens by their start position to ensure proper reconstruction
        std::sort(tokens.begin(), tokens.end(), [](const Token& a, const Token& b) {
            return a.start < b.start;
        });
        
        std::string highlighted;
        size_t lastPos = 0;
        
        for (const auto& token : tokens) {
            // Add any unprocessed text before this token
            if (token.start > lastPos) {
                highlighted += expression.substr(lastPos, token.start - lastPos);
            }
            
            // Apply color based on token type
            std::string color;
            switch (token.type) {
                case TokenType::NUMBER:
                    color = Colors::NUMBER;
                    break;
                case TokenType::STRING:
                    color = Colors::STRING;
                    break;
                case TokenType::IDENTIFIER:
                    color = Colors::IDENTIFIER;
                    break;
                case TokenType::OPERATOR:
                    color = Colors::OPERATOR;
                    break;
                case TokenType::PARENTHESIS:
                    color = Colors::PARENTHESIS;
                    break;
                case TokenType::COMMA:
                    color = Colors::COMMA;
                    break;
                case TokenType::BOOLEAN:
                    color = Colors::BOOLEAN;
                    break;
                case TokenType::WHITESPACE:
                    // Don't color whitespace
                    color = "";
                    break;
                case TokenType::UNKNOWN:
                    color = Colors::UNKNOWN;
                    break;
            }
            
            // Add the colored token
            if (!color.empty()) {
                highlighted += color + token.text + Colors::RESET;
            } else {
                highlighted += token.text;
            }
            
            lastPos = token.start + token.length;
        }
        
        // Add any remaining text after the last token
        if (lastPos < expression.length()) {
            highlighted += expression.substr(lastPos);
        }
        
        return highlighted;
        
    } catch (const ExprException&) {
        // If token parsing completely fails, return original expression
        return expression;
    }
}

/**
 * @brief Environment implementation for the CLI demo
 * 
 * This class manages variables and provides access to standard mathematical functions.
 * Variables are stored in a map and can be set, retrieved, and deleted through CLI commands.
 */
class DemoEnvironment final : public IEnvironment {
private:
    std::map<std::string, Value> variables;

public:
    /**
     * @brief Get a variable value by name
     * @param name Variable name
     * @return Variable value
     * @throws ExprException if variable not found
     */
    Value Get(const std::string& name) override {
        auto it = variables.find(name);
        if (it != variables.end()) {
            return it->second;
        }
        throw ExprException("Variable '" + name + "' is not defined");
    }

    /**
     * @brief Call a standard mathematical function
     * @param name Function name
     * @param args Function arguments
     * @return Function result
     * @throws ExprException if function not found or invalid arguments
     */
    Value Call(const std::string& name, const std::vector<Value>& args) override {
        Value result;
        if (Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        throw ExprException("Function '" + name + "' is not defined");
    }

    /**
     * @brief Set a variable value
     * @param name Variable name
     * @param value Variable value
     */
    void setVariable(const std::string& name, const Value& value) {
        variables[name] = value;
    }

    /**
     * @brief Delete a variable
     * @param name Variable name
     * @return true if variable was deleted, false if it didn't exist
     */
    bool deleteVariable(const std::string& name) {
        return variables.erase(name) > 0;
    }

    /**
     * @brief List all variables
     * @return Map of all variables
     */
    const std::map<std::string, Value>& listVariables() const {
        return variables;
    }

    /**
     * @brief Check if environment has any variables
     * @return true if variables exist, false otherwise
     */
    bool hasVariables() const {
        return !variables.empty();
    }
};

/**
 * @brief Print a formatted value to output
 * @param value The value to print
 */
void printValue(const Value& value) {
    if (value.isNumber()) {
        double num = value.asNumber();
        // Check if it's an integer
        if (num == static_cast<long long>(num)) {
            std::cout << static_cast<long long>(num);
        } else {
            std::cout << std::fixed << std::setprecision(6) << num;
        }
    } else if (value.isBoolean()) {
        std::cout << (value.asBoolean() ? "true" : "false");
    } else if (value.isString()) {
        std::cout << "\"" << value.asString() << "\"";
    }
}

/**
 * @brief Split a string by the first occurrence of a delimiter
 * @param str Input string
 * @param delimiter Delimiter character
 * @return Pair of (before delimiter, after delimiter)
 */
std::pair<std::string, std::string> splitFirst(const std::string& str, char delimiter) {
    size_t pos = str.find(delimiter);
    if (pos == std::string::npos) {
        return {str, ""};
    }
    return {str.substr(0, pos), str.substr(pos + 1)};
}

/**
 * @brief Trim whitespace from both ends of a string
 * @param str Input string
 * @return Trimmed string
 */
std::string trim(const std::string& str) {
    size_t start = str.find_first_not_of(" \t\n\r");
    if (start == std::string::npos) return "";
    size_t end = str.find_last_not_of(" \t\n\r");
    return str.substr(start, end - start + 1);
}

/**
 * @brief Display welcome message and usage instructions
 */
void showWelcome() {
    std::cout << R"(
🧮 ExpressionKit Interactive Demo
================================

Welcome to the ExpressionKit expression evaluator! You can use the following commands:

✨ Features syntax highlighting with colors for better visualization!

Commands:
  set <name> <expression>  - Set a variable to the result of an expression
  del <name>              - Delete a variable
  eval <expression>       - Evaluate an expression and show the result
  ls                      - List all variables and their values
  exit                    - Exit the program

Examples:
  > set x 5 + 3           # Set x to 8
  > set y x * 2           # Set y to 16 (uses the value of x)
  > eval x + y            # Evaluate and show 24
  > set pi 3.14159        # Set pi to a value
  > eval sin(pi/2)        # Evaluate sin(π/2) ≈ 1
  > ls                    # Show all variables
  > del x                 # Delete variable x
  > exit                  # Quit

Supported operators: +, -, *, /, %, ^, ==, !=, <, <=, >, >=, &&, ||, !
Supported functions: sin, cos, tan, asin, acos, atan, sqrt, log, exp, abs, 
                     floor, ceil, round, min, max, pow, and more

Type your commands below:
)" << std::endl;
}

/**
 * @brief Process a user command
 * @param command User input command
 * @param env Environment instance
 * @return true to continue, false to exit
 */
bool processCommand(const std::string& command, DemoEnvironment& env) {
    std::string trimmedCmd = trim(command);
    
    if (trimmedCmd.empty()) {
        return true; // Continue on empty input
    }

    // Parse command
    std::istringstream iss(trimmedCmd);
    std::string cmd;
    iss >> cmd;

    try {
        if (cmd == "exit") {
            std::cout << "Goodbye!" << std::endl;
            return false;
        }
        else if (cmd == "ls") {
            if (!env.hasVariables()) {
                std::cout << "No variables defined." << std::endl;
            } else {
                std::cout << "Variables:" << std::endl;
                for (const auto& pair : env.listVariables()) {
                    std::cout << "  " << pair.first << " = ";
                    printValue(pair.second);
                    std::cout << std::endl;
                }
            }
        }
        else if (cmd == "set") {
            // Extract variable name and expression
            std::string remainder = trimmedCmd.substr(3); // Remove "set"
            remainder = trim(remainder);
            
            auto [varName, expression] = splitFirst(remainder, ' ');
            varName = trim(varName);
            expression = trim(expression);
            
            if (varName.empty() || expression.empty()) {
                std::cout << "Usage: set <variable_name> <expression>" << std::endl;
                return true;
            }
            
            // Show highlighted expression
            std::cout << "Evaluating: " << highlightExpression(expression, &env) << std::endl;
            
            // Evaluate expression and set variable
            Value result = Expression::Eval(expression, &env);
            env.setVariable(varName, result);
            
            std::cout << varName << " = ";
            printValue(result);
            std::cout << std::endl;
        }
        else if (cmd == "del") {
            std::string remainder = trimmedCmd.substr(3); // Remove "del"
            std::string varName = trim(remainder);
            
            if (varName.empty()) {
                std::cout << "Usage: del <variable_name>" << std::endl;
                return true;
            }
            
            if (env.deleteVariable(varName)) {
                std::cout << "Variable '" << varName << "' deleted." << std::endl;
            } else {
                std::cout << "Variable '" << varName << "' not found." << std::endl;
            }
        }
        else if (cmd == "eval") {
            std::string expression = trimmedCmd.substr(4); // Remove "eval"
            expression = trim(expression);
            
            if (expression.empty()) {
                std::cout << "Usage: eval <expression>" << std::endl;
                return true;
            }
            
            // Show highlighted expression
            std::cout << "Evaluating: " << highlightExpression(expression, &env) << std::endl;
            
            Value result = Expression::Eval(expression, &env);
            std::cout << "Result: ";
            printValue(result);
            std::cout << std::endl;
        }
        else {
            std::cout << "Unknown command: " << cmd << std::endl;
            std::cout << "Available commands: set, del, eval, ls, exit" << std::endl;
        }
    }
    catch (const ExprException& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }
    catch (const std::exception& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }

    return true;
}

/**
 * @brief Main program entry point
 */
int main() {
    DemoEnvironment env;
    std::string input;

    showWelcome();

    while (true) {
        std::cout << "> ";
        std::getline(std::cin, input);
        
        // Handle EOF (Ctrl+D)
        if (std::cin.eof()) {
            std::cout << std::endl << "Goodbye!" << std::endl;
            break;
        }
        
        if (!processCommand(input, env)) {
            break;
        }
    }

    return 0;
}