import Foundation
import ExpressionKitBridge

/// Token type for syntax highlighting and analysis
public enum TokenType: Int {
    case number = 0
    case boolean = 1
    case identifier = 2
    case `operator` = 3
    case parenthesis = 4
    case comma = 5
    case whitespace = 6
    case unknown = 7
}

/// Token structure for syntax highlighting and analysis
public struct Token {
    /// Type of the token
    public let type: TokenType
    /// Starting position in source text
    public let start: Int
    /// Length of the token
    public let length: Int
    /// The actual token text
    public let text: String
    
    public init(type: TokenType, start: Int, length: Int, text: String) {
        self.type = type
        self.start = start
        self.length = length
        self.text = text
    }
}

/// Swift wrapper for ExpressionKit library
/// Provides a clean Swift API while maintaining the "parse once, execute many times" capability
public final class Expression {
    
    /// Evaluate an expression string directly (without environment support for now)
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
    
    /// Evaluate an expression string directly with token collection
    /// - Parameters:
    ///   - expression: The expression string to evaluate
    ///   - collectTokens: Whether to collect tokens for syntax highlighting
    /// - Returns: A tuple containing the evaluation result and optional tokens
    /// - Throws: ExpressionError if parsing or evaluation fails
    public static func evaluate(_ expression: String, collectTokens: Bool) throws -> (value: Value, tokens: [Token]?) {
        if collectTokens {
            let tokenArray = expr_token_array_create()
            defer { expr_token_array_destroy(tokenArray) }
            
            let result = expr_evaluate_with_tokens(expression, nil, tokenArray)
            
            if expr_get_last_error() != ExprErrorNone {
                let message = String(cString: expr_get_last_error_message())
                throw ExpressionError.evaluationFailed(message)
            }
            
            let tokens = extractTokens(from: tokenArray!)
            return (value: result, tokens: tokens)
        } else {
            let value = try evaluate(expression)
            return (value: value, tokens: nil)
        }
    }
    
    /// Parse an expression into a reusable Expression object
    /// - Parameter expression: The expression string to parse
    /// - Returns: A compiled Expression that can be evaluated multiple times
    /// - Throws: ExpressionError if parsing fails
    public static func parse(_ expression: String) throws -> CompiledExpression {
        guard let handle = expr_parse(expression) else {
            let message = String(cString: expr_get_last_error_message())
            throw ExpressionError.parseFailed(message)
        }
        
        return CompiledExpression(handle: handle)
    }
    
    /// Parse an expression into a reusable Expression object with token collection
    /// - Parameters:
    ///   - expression: The expression string to parse
    ///   - collectTokens: Whether to collect tokens for syntax highlighting
    /// - Returns: A tuple containing the compiled Expression and optional tokens
    /// - Throws: ExpressionError if parsing fails
    public static func parse(_ expression: String, collectTokens: Bool) throws -> (expression: CompiledExpression, tokens: [Token]?) {
        if collectTokens {
            let tokenArray = expr_token_array_create()
            defer { expr_token_array_destroy(tokenArray) }
            
            guard let handle = expr_parse_with_tokens(expression, tokenArray) else {
                let message = String(cString: expr_get_last_error_message())
                throw ExpressionError.parseFailed(message)
            }
            
            let tokens = extractTokens(from: tokenArray!)
            return (expression: CompiledExpression(handle: handle), tokens: tokens)
        } else {
            let expr = try parse(expression)
            return (expression: expr, tokens: nil)
        }
    }
    
    /// Extract tokens from C token array
    private static func extractTokens(from tokenArray: UnsafeMutablePointer<ExprTokenArray>) -> [Token] {
        let count = expr_token_array_size(tokenArray)
        var tokens: [Token] = []
        tokens.reserveCapacity(Int(count))
        
        for i in 0..<count {
            guard let cToken = expr_token_array_get(tokenArray, i) else { continue }
            
            let tokenType = TokenType(rawValue: Int(cToken.pointee.type.rawValue)) ?? .unknown
            let text = String(cString: cToken.pointee.text)
            
            let token = Token(
                type: tokenType,
                start: Int(cToken.pointee.start),
                length: Int(cToken.pointee.length),
                text: text
            )
            tokens.append(token)
        }
        
        return tokens
    }
}