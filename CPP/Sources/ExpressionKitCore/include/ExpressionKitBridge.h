/*
 * ExpressionKitBridge.h
 * C Bridge for ExpressionKit C++ Library
 *
 * This header provides C-compatible interface to ExpressionKit for Swift integration.
 * It wraps the core functionality while maintaining the "parse once, execute many times" pattern.
 */

#ifndef EXPRESSION_KIT_BRIDGE_H
#define EXPRESSION_KIT_BRIDGE_H

#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handles for C++ objects
typedef void* ExprASTHandle;
typedef void* ExprBackendHandle;

// Value type for expression results
typedef enum {
    ExprValueTypeNumber = 0,
    ExprValueTypeBoolean = 1
} ExprValueType;

typedef struct {
    ExprValueType type;
    union {
        double number;
        bool boolean;
    } data;
} ExprValue;

// Error handling
typedef enum {
    ExprErrorNone = 0,
    ExprErrorParseError = 1,
    ExprErrorRuntimeError = 2,
    ExprErrorTypeError = 3,
    ExprErrorBackendError = 4
} ExprErrorCode;

// Backend callback function types
typedef ExprValue (*ExprGetVariableCallback)(const char* name, void* context, ExprErrorCode* error);
typedef ExprValue (*ExprCallFunctionCallback)(const char* name, const ExprValue* args, size_t argCount, void* context, ExprErrorCode* error);

// Backend configuration
typedef struct {
    ExprGetVariableCallback getVariable;
    ExprCallFunctionCallback callFunction;
    void* context;
} ExprBackendConfig;

// Core API functions

// Parse expression into AST (returns NULL on error, check expr_get_last_error)
ExprASTHandle expr_parse(const char* expression);

// Evaluate AST with optional backend (returns invalid value on error, check expr_get_last_error)
ExprValue expr_evaluate_ast(ExprASTHandle ast, ExprBackendHandle backend);

// Direct evaluation (combines parse + evaluate)
ExprValue expr_evaluate(const char* expression, ExprBackendHandle backend);

// Backend management
ExprBackendHandle expr_backend_create(const ExprBackendConfig* config);
void expr_backend_destroy(ExprBackendHandle backend);

// AST memory management
void expr_ast_retain(ExprASTHandle ast);
void expr_ast_release(ExprASTHandle ast);

// Error handling
ExprErrorCode expr_get_last_error(void);
const char* expr_get_last_error_message(void);
void expr_clear_error(void);

// Utility functions
ExprValue expr_make_number(double value);
ExprValue expr_make_boolean(bool value);
bool expr_value_is_number(const ExprValue* value);
bool expr_value_is_boolean(const ExprValue* value);
double expr_value_as_number(const ExprValue* value);
bool expr_value_as_boolean(const ExprValue* value);

#ifdef __cplusplus
}
#endif

#endif // EXPRESSION_KIT_BRIDGE_H