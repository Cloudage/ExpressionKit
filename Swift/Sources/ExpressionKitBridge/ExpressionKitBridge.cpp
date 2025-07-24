/*
 * ExpressionKitBridge.cpp
 * C Bridge Implementation for ExpressionKit
 */

#include "ExpressionKitBridge.h"
#include "../../../ExpressionKit.hpp"
#include <memory>
#include <string>
#include <thread>
#include <cstddef>
#include <cstring>
#include <cstdlib>

using namespace ExpressionKit;

// Thread-local error state
thread_local ExprErrorCode g_lastError = ExprErrorNone;
thread_local std::string g_lastErrorMessage;

// Convert C++ Value to C ExprValue (should be binary compatible)
static ExprValue convertToCValue(const Value& value) {
    // Since Value and ExprValue have the same layout, we can cast directly
    static_assert(sizeof(Value) == sizeof(ExprValue), "Value and ExprValue must have same size");
    static_assert(offsetof(Value, type) == offsetof(ExprValue, type), "Type field must be at same offset");
    static_assert(offsetof(Value, data) == offsetof(ExprValue, data), "Data field must be at same offset");
    
    ExprValue result;
    result.type = static_cast<ExprValueType>(value.type);
    if (value.isNumber()) {
        result.data.number = value.data.number;
    } else {
        result.data.boolean = value.data.boolean;
    }
    return result;
}

// Convert C ExprValue to C++ Value
static Value convertFromCValue(const ExprValue& cValue) {
    if (cValue.type == ExprValueTypeNumber) {
        return Value(cValue.data.number);
    } else {
        return Value(cValue.data.boolean);
    }
}

// Wrapper for C++ IEnvironment to bridge to C callbacks
class CallbackEnvironment : public IEnvironment {
private:
    ExprEnvironmentConfig config;
    
public:
    explicit CallbackEnvironment(const ExprEnvironmentConfig& cfg) : config(cfg) {}
    
    Value Get(const std::string& name) override {
        ExprErrorCode error = ExprErrorNone;
        ExprValue result = config.getVariable(name.c_str(), config.context, &error);
        
        if (error != ExprErrorNone) {
            throw ExprException("Environment variable access failed: " + name);
        }
        
        return convertFromCValue(result);
    }
    
    Value Call(const std::string& name, const std::vector<Value>& args) override {
        // First try standard mathematical functions from C++
        Value standardResult;
        if (::ExpressionKit::Expression::CallStandardFunctions(name, args, standardResult)) {
            return standardResult;
        }
        
        // If not a standard function, delegate to Swift environment
        // Convert C++ Value vector to C ExprValue array
        std::vector<ExprValue> cArgs;
        cArgs.reserve(args.size());
        
        for (const auto& arg : args) {
            cArgs.push_back(convertToCValue(arg));
        }
        
        ExprErrorCode error = ExprErrorNone;
        ExprValue result = config.callFunction(name.c_str(), 
                                             cArgs.empty() ? nullptr : cArgs.data(), 
                                             cArgs.size(), 
                                             config.context, 
                                             &error);
        
        if (error != ExprErrorNone) {
            throw ExprException("Environment function call failed: " + name);
        }
        
        return convertFromCValue(result);
    }
};

// Internal helper to set error state
static void setError(ExprErrorCode code, const std::string& message) {
    g_lastError = code;
    g_lastErrorMessage = message;
}

static void clearError() {
    g_lastError = ExprErrorNone;
    g_lastErrorMessage.clear();
}

// AST wrapper with reference counting
struct ASTWrapper {
    std::shared_ptr<ASTNode> ast;
    int refCount;
    
    explicit ASTWrapper(std::shared_ptr<ASTNode> node) : ast(std::move(node)), refCount(1) {}
};

// Environment wrapper
struct EnvironmentWrapper {
    std::unique_ptr<CallbackEnvironment> environment;
    void* swiftContext; // Store the Swift context pointer
    
    EnvironmentWrapper(const ExprEnvironmentConfig& config) 
        : environment(std::make_unique<CallbackEnvironment>(config)), swiftContext(config.context) {}
        
    ~EnvironmentWrapper() {
        // Release the Swift context when destroying
        if (swiftContext) {
            // This will be handled by Swift's deinit
        }
    }
};

// C API Implementation

extern "C" {

ExprASTHandle expr_parse(const char* expression) {
    clearError();
    
    if (!expression) {
        setError(ExprErrorParseError, "Expression string is null");
        return nullptr;
    }
    
    try {
        auto ast = ::ExpressionKit::Expression::Parse(expression);
        return reinterpret_cast<ExprASTHandle>(new ASTWrapper(ast));
    } catch (const ExprException& e) {
        setError(ExprErrorParseError, e.what());
        return nullptr;
    } catch (const std::exception& e) {
        setError(ExprErrorParseError, std::string("Parse error: ") + e.what());
        return nullptr;
    }
}

ExprValue expr_evaluate_ast(ExprASTHandle ast, ExprEnvironmentHandle environment) {
    clearError();
    
    ExprValue invalidResult = { ExprValueTypeNumber, { 0.0 } };
    
    if (!ast) {
        setError(ExprErrorRuntimeError, "AST handle is null");
        return invalidResult;
    }
    
    try {
        auto* astWrapper = reinterpret_cast<ASTWrapper*>(ast);
        IEnvironment* environmentPtr = nullptr;
        
        if (environment) {
            auto* environmentWrapper = reinterpret_cast<EnvironmentWrapper*>(environment);
            environmentPtr = environmentWrapper->environment.get();
        }
        
        Value result = astWrapper->ast->evaluate(environmentPtr);
        return convertToCValue(result);
    } catch (const ExprException& e) {
        setError(ExprErrorRuntimeError, e.what());
        return invalidResult;
    } catch (const std::exception& e) {
        setError(ExprErrorRuntimeError, std::string("Evaluation error: ") + e.what());
        return invalidResult;
    }
}

ExprValue expr_evaluate(const char* expression, ExprEnvironmentHandle environment) {
    clearError();
    
    ExprValue invalidResult = { ExprValueTypeNumber, { 0.0 } };
    
    if (!expression) {
        setError(ExprErrorParseError, "Expression string is null");
        return invalidResult;
    }
    
    try {
        IEnvironment* environmentPtr = nullptr;
        
        if (environment) {
            auto* environmentWrapper = reinterpret_cast<EnvironmentWrapper*>(environment);
            environmentPtr = environmentWrapper->environment.get();
        }
        
        Value result = ::ExpressionKit::Expression::Eval(expression, environmentPtr);
        return convertToCValue(result);
    } catch (const ExprException& e) {
        setError(ExprErrorRuntimeError, e.what());
        return invalidResult;
    } catch (const std::exception& e) {
        setError(ExprErrorRuntimeError, std::string("Evaluation error: ") + e.what());
        return invalidResult;
    }
}

ExprEnvironmentHandle expr_environment_create(const ExprEnvironmentConfig* config) {
    clearError();
    
    if (!config || !config->getVariable || !config->callFunction) {
        setError(ExprErrorEnvironmentError, "Invalid environment configuration");
        return nullptr;
    }
    
    try {
        return reinterpret_cast<ExprEnvironmentHandle>(new EnvironmentWrapper(*config));
    } catch (const std::exception& e) {
        setError(ExprErrorEnvironmentError, std::string("Environment creation failed: ") + e.what());
        return nullptr;
    }
}

void expr_environment_destroy(ExprEnvironmentHandle environment) {
    if (environment) {
        auto* wrapper = reinterpret_cast<EnvironmentWrapper*>(environment);
        // Release the Swift context
        if (wrapper->swiftContext) {
            // This should release the retained Swift object
            // The Swift side will handle this in deinit
        }
        delete wrapper;
    }
}

void expr_ast_retain(ExprASTHandle ast) {
    if (ast) {
        auto* wrapper = reinterpret_cast<ASTWrapper*>(ast);
        wrapper->refCount++;
    }
}

void expr_ast_release(ExprASTHandle ast) {
    if (ast) {
        auto* wrapper = reinterpret_cast<ASTWrapper*>(ast);
        wrapper->refCount--;
        if (wrapper->refCount <= 0) {
            delete wrapper;
        }
    }
}

ExprErrorCode expr_get_last_error(void) {
    return g_lastError;
}

const char* expr_get_last_error_message(void) {
    return g_lastErrorMessage.c_str();
}

void expr_clear_error(void) {
    clearError();
}

ExprValue expr_make_number(double value) {
    ExprValue result;
    result.type = ExprValueTypeNumber;
    result.data.number = value;
    return result;
}

ExprValue expr_make_boolean(bool value) {
    ExprValue result;
    result.type = ExprValueTypeBoolean;
    result.data.boolean = value;
    return result;
}

bool expr_value_is_number(const ExprValue* value) {
    return value && value->type == ExprValueTypeNumber;
}

bool expr_value_is_boolean(const ExprValue* value) {
    return value && value->type == ExprValueTypeBoolean;
}

double expr_value_as_number(const ExprValue* value) {
    if (expr_value_is_number(value)) {
        return value->data.number;
    }
    return 0.0;
}

bool expr_value_as_boolean(const ExprValue* value) {
    if (expr_value_is_boolean(value)) {
        return value->data.boolean;
    }
    return false;
}

// Convert C++ TokenType to C ExprTokenType
static ExprTokenType convertTokenType(TokenType type) {
    switch (type) {
        case TokenType::NUMBER: return ExprTokenTypeNumber;
        case TokenType::BOOLEAN: return ExprTokenTypeBoolean;
        case TokenType::IDENTIFIER: return ExprTokenTypeIdentifier;
        case TokenType::OPERATOR: return ExprTokenTypeOperator;
        case TokenType::PARENTHESIS: return ExprTokenTypeParenthesis;
        case TokenType::COMMA: return ExprTokenTypeComma;
        case TokenType::WHITESPACE: return ExprTokenTypeWhitespace;
        case TokenType::UNKNOWN: return ExprTokenTypeUnknown;
    }
    return ExprTokenTypeUnknown;
}

// Convert C++ tokens to C token array
static void populateTokenArray(const std::vector<Token>& cppTokens, ExprTokenArray* cArray) {
    if (!cArray) return;
    
    cArray->count = cppTokens.size();
    cArray->capacity = cppTokens.size();
    cArray->tokens = static_cast<ExprToken*>(malloc(sizeof(ExprToken) * cArray->count));
    
    for (size_t i = 0; i < cppTokens.size(); ++i) {
        const auto& cppToken = cppTokens[i];
        ExprToken& cToken = cArray->tokens[i];
        
        cToken.type = convertTokenType(cppToken.type);
        cToken.start = cppToken.start;
        cToken.length = cppToken.length;
        
        // Allocate and copy the text
        cToken.text = static_cast<char*>(malloc(cppToken.text.size() + 1));
        strcpy(cToken.text, cppToken.text.c_str());
    }
}

// Token management functions
ExprTokenArray* expr_token_array_create(void) {
    auto* array = static_cast<ExprTokenArray*>(malloc(sizeof(ExprTokenArray)));
    array->tokens = nullptr;
    array->count = 0;
    array->capacity = 0;
    return array;
}

void expr_token_array_destroy(ExprTokenArray* array) {
    if (!array) return;
    
    // Free all text strings
    for (size_t i = 0; i < array->count; ++i) {
        free(array->tokens[i].text);
    }
    
    // Free the tokens array
    free(array->tokens);
    
    // Free the array structure
    free(array);
}

size_t expr_token_array_size(const ExprTokenArray* array) {
    return array ? array->count : 0;
}

const ExprToken* expr_token_array_get(const ExprTokenArray* array, size_t index) {
    if (!array || index >= array->count) return nullptr;
    return &array->tokens[index];
}

// Parse expression with token collection
ExprASTHandle expr_parse_with_tokens(const char* expression, ExprTokenArray* tokens) {
    if (!expression) {
        g_lastError = ExprErrorParseError;
        g_lastErrorMessage = "Null expression string";
        return nullptr;
    }
    
    try {
        std::vector<Token> cppTokens;
        auto ast = ::ExpressionKit::Expression::Parse(std::string(expression), tokens ? &cppTokens : nullptr);
        
        if (tokens) {
            populateTokenArray(cppTokens, tokens);
        }
        
        g_lastError = ExprErrorNone;
        g_lastErrorMessage.clear();
        
        // Return a copy of the shared_ptr on the heap
        return new ASTNodePtr(ast);
    } catch (const ExprException& e) {
        g_lastError = ExprErrorParseError;
        g_lastErrorMessage = e.what();
        return nullptr;
    } catch (const std::exception& e) {
        g_lastError = ExprErrorRuntimeError;
        g_lastErrorMessage = std::string("Unexpected error: ") + e.what();
        return nullptr;
    }
}

// Direct evaluation with token collection
ExprValue expr_evaluate_with_tokens(const char* expression, ExprEnvironmentHandle environment, ExprTokenArray* tokens) {
    if (!expression) {
        g_lastError = ExprErrorParseError;
        g_lastErrorMessage = "Null expression string";
        return expr_make_number(0.0);
    }
    
    try {
        std::vector<Token> cppTokens;
        CallbackEnvironment* cppEnvironment = static_cast<CallbackEnvironment*>(environment);
        
        auto result = ::ExpressionKit::Expression::Eval(std::string(expression), cppEnvironment, tokens ? &cppTokens : nullptr);
        
        if (tokens) {
            populateTokenArray(cppTokens, tokens);
        }
        
        g_lastError = ExprErrorNone;
        g_lastErrorMessage.clear();
        
        return convertToCValue(result);
    } catch (const ExprException& e) {
        g_lastError = ExprErrorRuntimeError;
        g_lastErrorMessage = e.what();
        return expr_make_number(0.0);
    } catch (const std::exception& e) {
        g_lastError = ExprErrorRuntimeError;
        g_lastErrorMessage = std::string("Unexpected error: ") + e.what();
        return expr_make_number(0.0);
    }
}

} // extern "C"