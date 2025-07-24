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

// Wrapper for C++ IBackend to bridge to C callbacks
class CallbackBackend : public IBackend {
private:
    ExprBackendConfig config;
    
public:
    explicit CallbackBackend(const ExprBackendConfig& cfg) : config(cfg) {}
    
    Value Get(const std::string& name) override {
        ExprErrorCode error = ExprErrorNone;
        ExprValue result = config.getVariable(name.c_str(), config.context, &error);
        
        if (error != ExprErrorNone) {
            throw ExprException("Backend variable access failed: " + name);
        }
        
        return convertFromCValue(result);
    }
    
    Value Call(const std::string& name, const std::vector<Value>& args) override {
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
            throw ExprException("Backend function call failed: " + name);
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

// Backend wrapper
struct BackendWrapper {
    std::unique_ptr<CallbackBackend> backend;
    void* swiftContext; // Store the Swift context pointer
    
    BackendWrapper(const ExprBackendConfig& config) 
        : backend(std::make_unique<CallbackBackend>(config)), swiftContext(config.context) {}
        
    ~BackendWrapper() {
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
        auto ast = ExprTK::Parse(expression);
        return reinterpret_cast<ExprASTHandle>(new ASTWrapper(ast));
    } catch (const ExprException& e) {
        setError(ExprErrorParseError, e.what());
        return nullptr;
    } catch (const std::exception& e) {
        setError(ExprErrorParseError, std::string("Parse error: ") + e.what());
        return nullptr;
    }
}

ExprValue expr_evaluate_ast(ExprASTHandle ast, ExprBackendHandle backend) {
    clearError();
    
    ExprValue invalidResult = { ExprValueTypeNumber, { 0.0 } };
    
    if (!ast) {
        setError(ExprErrorRuntimeError, "AST handle is null");
        return invalidResult;
    }
    
    try {
        auto* astWrapper = reinterpret_cast<ASTWrapper*>(ast);
        IBackend* backendPtr = nullptr;
        
        if (backend) {
            auto* backendWrapper = reinterpret_cast<BackendWrapper*>(backend);
            backendPtr = backendWrapper->backend.get();
        }
        
        Value result = astWrapper->ast->evaluate(backendPtr);
        return convertToCValue(result);
    } catch (const ExprException& e) {
        setError(ExprErrorRuntimeError, e.what());
        return invalidResult;
    } catch (const std::exception& e) {
        setError(ExprErrorRuntimeError, std::string("Evaluation error: ") + e.what());
        return invalidResult;
    }
}

ExprValue expr_evaluate(const char* expression, ExprBackendHandle backend) {
    clearError();
    
    ExprValue invalidResult = { ExprValueTypeNumber, { 0.0 } };
    
    if (!expression) {
        setError(ExprErrorParseError, "Expression string is null");
        return invalidResult;
    }
    
    try {
        IBackend* backendPtr = nullptr;
        
        if (backend) {
            auto* backendWrapper = reinterpret_cast<BackendWrapper*>(backend);
            backendPtr = backendWrapper->backend.get();
        }
        
        Value result = ExprTK::Eval(expression, backendPtr);
        return convertToCValue(result);
    } catch (const ExprException& e) {
        setError(ExprErrorRuntimeError, e.what());
        return invalidResult;
    } catch (const std::exception& e) {
        setError(ExprErrorRuntimeError, std::string("Evaluation error: ") + e.what());
        return invalidResult;
    }
}

ExprBackendHandle expr_backend_create(const ExprBackendConfig* config) {
    clearError();
    
    if (!config || !config->getVariable || !config->callFunction) {
        setError(ExprErrorBackendError, "Invalid backend configuration");
        return nullptr;
    }
    
    try {
        return reinterpret_cast<ExprBackendHandle>(new BackendWrapper(*config));
    } catch (const std::exception& e) {
        setError(ExprErrorBackendError, std::string("Backend creation failed: ") + e.what());
        return nullptr;
    }
}

void expr_backend_destroy(ExprBackendHandle backend) {
    if (backend) {
        auto* wrapper = reinterpret_cast<BackendWrapper*>(backend);
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

} // extern "C"