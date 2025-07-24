import Foundation
import ExpressionKitCore

/// Swift wrapper for ExpressionKit library
/// Provides a clean Swift API while maintaining the "parse once, execute many times" capability
public final class ExpressionKit {
    
    /// Evaluate an expression string directly (without backend support for now)
    /// - Parameter expression: The expression string to evaluate
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if parsing or evaluation fails
    public static func evaluate(_ expression: String) throws -> Value {
        let result = expr_evaluate(expression, nil)
        
        if expr_get_last_error() != ExprErrorNone {
            let message = String(cString: expr_get_last_error_message())
            throw ExpressionError.evaluationFailed(message)
        }
        
        return result
    }
    
    /// Parse an expression into a reusable Expression object
    /// - Parameter expression: The expression string to parse
    /// - Returns: A compiled Expression that can be evaluated multiple times
    /// - Throws: ExpressionError if parsing fails
    public static func parse(_ expression: String) throws -> Expression {
        guard let handle = expr_parse(expression) else {
            let message = String(cString: expr_get_last_error_message())
            throw ExpressionError.parseFailed(message)
        }
        
        return Expression(handle: handle)
    }
}