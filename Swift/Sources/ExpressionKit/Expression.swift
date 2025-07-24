import Foundation
import ExpressionKitBridge

/// A compiled expression that can be evaluated multiple times efficiently
/// This enables the "parse once, execute many times" pattern
public final class Expression {
    private let handle: ExprASTHandle
    
    /// Internal initializer with AST handle
    internal init(handle: ExprASTHandle) {
        self.handle = handle
        expr_ast_retain(handle)
    }
    
    deinit {
        expr_ast_release(handle)
    }
    
    /// Evaluate this expression (without backend for now)
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if evaluation fails
    public func evaluate() throws -> Value {
        let result = expr_evaluate_ast(handle, nil)
        
        if expr_get_last_error() != ExprErrorNone {
            let message = String(cString: expr_get_last_error_message())
            throw ExpressionError.evaluationFailed(message)
        }
        
        return result
    }
}