import Foundation
import ExpressionKitBridge

/// A compiled expression that can be evaluated multiple times efficiently
/// 
/// This enables the "parse once, execute many times" pattern, which is significantly faster
/// than parsing the same expression repeatedly. CompiledExpression objects are thread-safe
/// for evaluation (but not for creation/destruction).
///
/// ## Performance Benefits:
/// - Parsing overhead is eliminated for repeated evaluations
/// - AST is pre-built and optimized
/// - Memory usage is more efficient for repeated execution
///
/// ## Usage:
/// ```swift
/// let expression = try Expression.parse("complex * calculation + here")
/// for i in 0..<10000 {
///     let result = try expression.eval()  // Much faster than re-parsing each time
/// }
/// ```
public final class CompiledExpression {
    private let handle: ExprASTHandle
    
    /// Internal initializer with AST handle
    internal init(handle: ExprASTHandle) {
        self.handle = handle
        expr_ast_retain(handle)
    }
    
    deinit {
        expr_ast_release(handle)
    }
    
    /// Evaluate this expression (without environment for now)
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if evaluation fails
    public func eval() throws -> Value {
        let result = expr_evaluate_ast(handle, nil)
        
        if expr_get_last_error() != ExprErrorNone {
            let message = String(cString: expr_get_last_error_message())
            throw ExpressionError.evaluationFailed(message)
        }
        
        return result
    }
}