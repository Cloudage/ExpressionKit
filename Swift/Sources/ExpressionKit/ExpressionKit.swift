/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * NOTE: This code is a 1:1 translation from the C++ ExpressionKit.hpp implementation
 * to Swift, maintaining the same algorithms, structure, and behavior while using
 * Swift-idiomatic patterns and conventions.
 */

/**
 * @file ExpressionKit.swift
 * @brief A lightweight, interface-driven expression parser and evaluator for Swift
 * @version 1.0.0
 * @date 2025-01-27
 *
 * ExpressionKit provides a clean and extensible way to parse and evaluate mathematical
 * and logical expressions. This is a pure Swift implementation translated 1:1 from the
 * C++ header-only library, maintaining identical algorithms and behavior.
 *
 * Key features include:
 *
 * - Interface-based variable and function access through Environment abstraction
 * - Pre-parsed AST support for efficient repeated evaluation
 * - Support for numbers, booleans, strings, variables, and function calls
 * - Comprehensive operator support (arithmetic, comparison, logical)
 * - Type-safe value system with automatic conversions
 * - Exception-based error handling
 * - Token sequence analysis for syntax highlighting
 *
 * The library is designed to be embedded in larger applications where expressions
 * need to be evaluated against dynamic data sources.
 */

import Foundation

/// Token type for syntax highlighting and analysis
///
/// This enumeration defines all possible token types that can be identified
/// during expression parsing, useful for syntax highlighting and other
/// analysis features.
public enum TokenType: Int, CaseIterable {
    case number = 0       // Numeric literals: 42, 3.14, -2.5
    case boolean = 1      // Boolean literals: true, false
    case string = 2       // String literals: "hello", "world"
    case identifier = 3   // Variables and function names: x, pos.x, sqrt
    case `operator` = 4   // Operators: +, -, *, /, ==, !=, &&, ||, etc.
    case parenthesis = 5  // Parentheses: (, )
    case comma = 6        // Function argument separator: ,
    case whitespace = 7   // Spaces, tabs (optional for highlighting)
    case unknown = 8      // Unrecognized tokens
}

/// Token structure for syntax highlighting and analysis
///
/// Contains information about a single token identified during parsing,
/// including its type, position in the source text, and the actual text.
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

/// Exception type for expression parsing and evaluation errors
public enum ExpressionError: Error, LocalizedError {
    case parseError(String)
    case evaluationError(String)
    case typeError(String)
    case divisionByZero
    case unknownVariable(String)
    case unknownFunction(String)
    case domainError(String)
    
    public var errorDescription: String? {
        switch self {
        case .parseError(let message):
            return "Parse failed: \(message)"
        case .evaluationError(let message):
            return "Evaluation failed: \(message)"
        case .typeError(let message):
            return "Type mismatch: \(message)"
        case .divisionByZero:
            return "Division by zero"
        case .unknownVariable(let name):
            return "Unknown variable: \(name)"
        case .unknownFunction(let name):
            return "Unknown function: \(name)"
        case .domainError(let message):
            return "Domain error: \(message)"
        }
    }
}

/// Value type that directly uses a Swift-native structure
/// 
/// This maintains the same interface as the C++ version while providing
/// Swift convenience methods and operators.
public struct Value {
    /// Value type enumeration matching C++ implementation
    public enum ValueType: Int {
        case number = 0
        case boolean = 1
        case string = 2
    }
    
    /// The type of this value
    public let type: ValueType
    
    /// Internal storage for the value data
    public enum Data {
        case number(Double)
        case boolean(Bool)
        case string(String)
        
        /// Get the number value (for testing)
        public var number: Double {
            if case .number(let value) = self {
                return value
            }
            fatalError("Not a number value")
        }
        
        /// Get the boolean value (for testing)
        public var boolean: Bool {
            if case .boolean(let value) = self {
                return value
            }
            fatalError("Not a boolean value")
        }
        
        /// Get the string value (for testing)
        public var string: String {
            if case .string(let value) = self {
                return value
            }
            fatalError("Not a string value")
        }
    }
    
    /// Access to the internal data (for testing purposes)
    public let data: Data
    
    // MARK: - Constructors
    
    /// Create a numeric value
    public init(_ value: Double) {
        self.type = .number
        self.data = .number(value)
    }
    
    /// Create a numeric value from Float
    public init(_ value: Float) {
        self.type = .number
        self.data = .number(Double(value))
    }
    
    /// Create a numeric value from Int
    public init(_ value: Int) {
        self.type = .number
        self.data = .number(Double(value))
    }
    
    /// Create a boolean value
    public init(_ value: Bool) {
        self.type = .boolean
        self.data = .boolean(value)
    }
    
    /// Create a string value
    public init(_ value: String) {
        self.type = .string
        self.data = .string(value)
    }
    
    // MARK: - Static factory methods for backward compatibility
    
    /// Create a numeric value (backward compatibility)
    public static func number(_ value: Double) -> Value {
        return Value(value)
    }
    
    /// Create a boolean value (backward compatibility)
    public static func boolean(_ value: Bool) -> Value {
        return Value(value)
    }
    
    /// Create a string value (backward compatibility)
    public static func string(_ value: String) -> Value {
        return Value(value)
    }
    
    // MARK: - Type checking
    
    /// Check if this value is a number
    public var isNumber: Bool { type == .number }
    
    /// Check if this value is a boolean
    public var isBoolean: Bool { type == .boolean }
    
    /// Check if this value is a string
    public var isString: Bool { type == .string }
    
    // MARK: - Convenience properties for backward compatibility
    
    /// Get the number value if this is a number (backward compatibility)
    public var numberValue: Double? {
        return isNumber ? (try? asNumber()) : nil
    }
    
    /// Get the boolean value if this is a boolean (backward compatibility)
    public var booleanValue: Bool? {
        return isBoolean ? (try? asBoolean()) : nil
    }
    
    /// Get the string value if this is a string (backward compatibility)
    public var stringValue: String? {
        return isString ? (try? asString()) : nil
    }
    
    // MARK: - Safe value extraction (strict type checking)
    
    /// Extract number value with strict type checking (no automatic conversions)
    public func asNumber() throws -> Double {
        switch data {
        case .number(let value):
            return value
        default:
            throw ExpressionError.typeError("Cannot convert \(type) to number")
        }
    }
    
    /// Extract boolean value with strict type checking (no automatic conversions)
    public func asBoolean() throws -> Bool {
        switch data {
        case .boolean(let value):
            return value
        default:
            throw ExpressionError.typeError("Cannot convert \(type) to boolean")
        }
    }
    
    /// Extract string value with strict type checking (no automatic conversions)
    public func asString() throws -> String {
        switch data {
        case .string(let value):
            return value
        default:
            throw ExpressionError.typeError("Cannot convert \(type) to string")
        }
    }
    
    // MARK: - Internal conversion methods (for expression evaluation)
    
    /// Convert to number with automatic type conversion (internal use)
    internal func toNumber() throws -> Double {
        switch data {
        case .number(let value):
            return value
        case .string(let str):
            // Try to convert string to number
            if let result = Double(str) {
                return result
            }
            throw ExpressionError.typeError("Cannot convert string '\(str)' to number")
        case .boolean(let bool):
            return bool ? 1.0 : 0.0
        }
    }
    
    /// Convert to boolean with automatic type conversion (internal use)
    internal func toBoolean() throws -> Bool {
        switch data {
        case .boolean(let value):
            return value
        case .number(let num):
            return num != 0.0
        case .string(let str):
            // Convert string to boolean with intuitive rules
            if str.isEmpty { return false }
            
            // Check for explicit false values (case-insensitive)
            let lowercased = str.lowercased()
            if lowercased == "false" || lowercased == "no" || lowercased == "0" {
                return false
            }
            
            // All other non-empty strings are true
            return true
        }
    }
    
    /// Convert to string with automatic type conversion (internal use)
    internal func toStringValue() throws -> String {
        switch data {
        case .string(let value):
            return value
        case .number(let num):
            return String(num)
        case .boolean(let bool):
            return bool ? "true" : "false"
        }
    }
    
    /// String conversion for display
    public func toString() throws -> String {
        return try toStringValue()
    }
}

// MARK: - Value Protocol Conformances

extension Value: Equatable {
    public static func == (lhs: Value, rhs: Value) -> Bool {
        if lhs.type == rhs.type {
            switch (lhs.data, rhs.data) {
            case (.number(let a), .number(let b)):
                return a == b
            case (.boolean(let a), .boolean(let b)):
                return a == b
            case (.string(let a), .string(let b)):
                return a == b
            default:
                return false
            }
        }
        return false
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch data {
        case .number(let value):
            return String(value)
        case .boolean(let value):
            return String(value)
        case .string(let value):
            return value
        }
    }
}

extension Value: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral, ExpressibleByStringLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
    
    public init(integerLiteral value: Int) {
        self.init(value)
    }
    
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// Environment protocol for variable access and function calls
///
/// Implement this protocol to provide custom variable storage and function
/// implementations. The environment is responsible for handling variable reads,
/// optional variable writes, and function calls during expression evaluation.
///
/// The integrating application is responsible for managing the environment's
/// lifetime. ExpressionKit stores only a weak reference and does not take ownership.
public protocol IEnvironment: AnyObject {
    /// Get a variable value by name
    /// - Parameter name: Variable name (supports dot notation like "pos.x")
    /// - Returns: The variable value
    /// - Throws: ExpressionError if the variable is not found
    func get(_ name: String) throws -> Value
    
    /// Call a function with given arguments
    /// - Parameters:
    ///   - name: Function name
    ///   - args: Function arguments
    /// - Returns: Function result
    /// - Throws: ExpressionError if the function is not found or arguments are invalid
    func call(_ name: String, args: [Value]) throws -> Value
}

/// Abstract base protocol for all AST (Abstract Syntax Tree) nodes
///
/// This is the foundation of the expression evaluation system. Every element
/// in an expression (numbers, variables, operators, functions) is represented
/// as an AST node that can be evaluated against an environment.
///
/// This is an internal implementation detail. Users typically work
/// with compiled expressions through the ExpressionKit interface.
protocol ASTNode {
    /// Evaluate this node and return its value
    /// - Parameter environment: Environment for variable and function resolution (can be nil for constants)
    /// - Returns: The computed value of this node
    /// - Throws: ExpressionError if evaluation fails
    func evaluate(_ environment: IEnvironment?) throws -> Value
}

/// AST node representing a numeric literal
///
/// This node holds a constant numeric value and returns it during evaluation.
/// Examples: 42, 3.14, -2.5
class NumberNode: ASTNode {
    private let value: Double
    
    init(_ value: Double) {
        self.value = value
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        return Value(value)
    }
}

/// AST node representing a boolean literal
///
/// This node holds a constant boolean value and returns it during evaluation.
/// Examples: true, false
class BooleanNode: ASTNode {
    private let value: Bool
    
    init(_ value: Bool) {
        self.value = value
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        return Value(value)
    }
}

/// AST node representing a string literal
///
/// This node holds a constant string value and returns it during evaluation.
/// Examples: "hello", "world", "Hello, \"World\"!"
class StringNode: ASTNode {
    private let value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        return Value(value)
    }
}

/// AST node representing a variable reference
///
/// This node stores a variable name and delegates to the IEnvironment during
/// evaluation to resolve the variable's current value.
/// Examples: x, pos.x, player_health
class VariableNode: ASTNode {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        guard let environment = environment else {
            throw ExpressionError.evaluationError("Variable access requires IEnvironment")
        }
        return try environment.get(name)
    }
}

/// Call standard mathematical functions
/// 
/// This function handles built-in mathematical functions matching the C++ implementation:
/// - min(a, b): Returns the smaller of two numbers
/// - max(a, b): Returns the larger of two numbers
/// - sqrt(x): Returns the square root of x
/// - sin(x): Returns the sine of x (in radians)
/// - cos(x): Returns the cosine of x (in radians)
/// - tan(x): Returns the tangent of x (in radians)
/// - abs(x): Returns the absolute value of x
/// - pow(x, y): Returns x raised to the power of y
/// - log(x): Returns the natural logarithm of x
/// - exp(x): Returns e raised to the power of x
/// - floor(x): Returns the largest integer less than or equal to x
/// - ceil(x): Returns the smallest integer greater than or equal to x
/// - round(x): Returns x rounded to the nearest integer
public func callStandardFunctions(_ functionName: String, args: [Value]) throws -> Value? {
    // Two-argument functions
    if functionName == "min" && args.count == 2 {
        let a = try args[0].toNumber()
        let b = try args[1].toNumber()
        return Value(Swift.min(a, b))
    }
    if functionName == "max" && args.count == 2 {
        let a = try args[0].toNumber()
        let b = try args[1].toNumber()
        return Value(Swift.max(a, b))
    }
    if functionName == "pow" && args.count == 2 {
        let x = try args[0].toNumber()
        let y = try args[1].toNumber()
        return Value(pow(x, y))
    }
    
    // Single-argument functions
    if args.count == 1 && args[0].isNumber {
        let x = try args[0].toNumber()
        
        switch functionName {
        case "sqrt":
            guard x >= 0 else {
                throw ExpressionError.domainError("sqrt domain error: \(x) < 0")
            }
            return Value(sqrt(x))
        case "sin":
            return Value(sin(x))
        case "cos":
            return Value(cos(x))
        case "tan":
            return Value(tan(x))
        case "abs":
            return Value(abs(x))
        case "log":
            guard x > 0 else {
                throw ExpressionError.domainError("log domain error: \(x) <= 0")
            }
            return Value(log(x))
        case "exp":
            return Value(exp(x))
        case "floor":
            return Value(floor(x))
        case "ceil":
            return Value(ceil(x))
        case "round":
            return Value(x.rounded())
        default:
            break
        }
    }
    
    return nil // Function not found or invalid arguments
}

/// Enumeration of all supported operators
///
/// This enum defines all arithmetic, comparison, and logical operators
/// supported by the expression system. Operators are grouped by category
/// for easier understanding and implementation.
enum OperatorType {
    case add, sub, mul, div           // Arithmetic operators: +, -, *, /
    case eq, ne, gt, lt, ge, le       // Comparison operators: ==, !=, >, <, >=, <=
    case `in`                         // Inclusion operator: in
    case and, or, xor, not            // Logical operators: &&, ||, xor, !
    case ternary                      // Ternary operator: ? :
}

/// AST node representing binary operations (operations with two operands)
///
/// This node handles all binary operators including arithmetic, comparison,
/// and logical operations. It evaluates both operands and applies the
/// specified operator according to type compatibility rules.
///
/// Supported operations:
/// - Arithmetic: 2 + 3, 5 * 4, 10 / 2, 7 - 1
/// - Comparison: x == 5, age >= 18, score != 0
/// - Logical: a && b, x || y, p xor q
class BinaryOpNode: ASTNode {
    private let left: ASTNode
    private let right: ASTNode
    private let op: OperatorType
    
    init(_ left: ASTNode, _ op: OperatorType, _ right: ASTNode) {
        self.left = left
        self.right = right
        self.op = op
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        let lhs = try left.evaluate(environment)
        let rhs = try right.evaluate(environment)
        
        // Boolean logical operations - allow any types and convert to boolean
        if op == .and || op == .or || op == .xor {
            let a = try lhs.toBoolean()
            let b = try rhs.toBoolean()
            switch op {
            case .and: return Value(a && b)
            case .or: return Value(a || b)
            case .xor: return Value(a != b)
            default: break // Should not reach here
            }
        }
        
        // String operations
        if lhs.isString || rhs.isString {
            switch op {
            case .add:
                // String concatenation: convert both operands to strings
                let lhsStr = try lhs.toStringValue()
                let rhsStr = try rhs.toStringValue()
                return Value(lhsStr + rhsStr)
            case .eq:
                // String equality comparison
                if lhs.isString && rhs.isString {
                    let lhsStr = try lhs.toStringValue()
                    let rhsStr = try rhs.toStringValue()
                    return Value(lhsStr == rhsStr)
                }
                // Different types are not equal
                return Value(false)
            case .ne:
                // String inequality comparison
                if lhs.isString && rhs.isString {
                    let lhsStr = try lhs.toStringValue()
                    let rhsStr = try rhs.toStringValue()
                    return Value(lhsStr != rhsStr)
                }
                // Different types are not equal
                return Value(true)
            case .gt, .lt, .ge, .le:
                // String comparison: both operands must be strings
                if lhs.isString && rhs.isString {
                    let lhsStr = try lhs.toStringValue()
                    let rhsStr = try rhs.toStringValue()
                    switch op {
                    case .gt: return Value(lhsStr > rhsStr)
                    case .lt: return Value(lhsStr < rhsStr)
                    case .ge: return Value(lhsStr >= rhsStr)
                    case .le: return Value(lhsStr <= rhsStr)
                    default: break
                    }
                }
                throw ExpressionError.typeError("String comparison operators require two string operands")
            case .in:
                // String contains check: check if left operand is contained in right operand
                if lhs.isString && rhs.isString {
                    let needle = try lhs.toStringValue()
                    let haystack = try rhs.toStringValue()
                    return Value(haystack.contains(needle))
                }
                throw ExpressionError.typeError("in operator requires two string operands")
            default:
                throw ExpressionError.typeError("Unsupported string operator")
            }
        }
        
        // Numeric operations
        if lhs.isNumber && rhs.isNumber {
            let a = try lhs.toNumber()
            let b = try rhs.toNumber()
            switch op {
            case .add: return Value(a + b)
            case .sub: return Value(a - b)
            case .mul: return Value(a * b)
            case .div:
                if b == 0 { throw ExpressionError.divisionByZero }
                return Value(a / b)
            case .gt: return Value(a > b)
            case .lt: return Value(a < b)
            case .ge: return Value(a >= b)
            case .le: return Value(a <= b)
            case .eq: return Value(a == b)
            case .ne: return Value(a != b)
            default:
                throw ExpressionError.typeError("Unsupported numeric operator")
            }
        }
        // Strict boolean operations (equality/inequality) require both to be boolean
        else if lhs.isBoolean && rhs.isBoolean {
            let a = try lhs.toBoolean()
            let b = try rhs.toBoolean()
            switch op {
            case .eq: return Value(a == b)
            case .ne: return Value(a != b)
            default:
                throw ExpressionError.typeError("Unsupported boolean operator")
            }
        }
        
        throw ExpressionError.typeError("Unsupported operand types")
    }
}

/// AST node representing unary operations (operations with one operand)
///
/// This node handles unary operators that operate on a single value:
/// - Logical NOT: !condition, not flag
/// - Arithmetic negation: -number, -expression
///
/// Examples: !true, -42, -(x + y), not visible
class UnaryOpNode: ASTNode {
    private let operand: ASTNode
    private let op: OperatorType
    
    init(_ op: OperatorType, _ operand: ASTNode) {
        self.op = op
        self.operand = operand
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        let val = try operand.evaluate(environment)
        
        switch op {
        case .not:
            // NOT operator can work with any type - convert to boolean first
            let boolVal = try val.toBoolean()
            return Value(!boolVal)
        case .sub: // Negation
            if !val.isNumber {
                throw ExpressionError.typeError("Negation can only be used with numbers")
            }
            let numVal = try val.toNumber()
            return Value(-numVal)
        default:
            throw ExpressionError.typeError("Unsupported unary operator")
        }
    }
}

/// AST node representing ternary operations (condition ? true_expr : false_expr)
///
/// This node handles the ternary conditional operator (? :).
/// The condition is evaluated using asBoolean() to support any value type.
///
/// Example: 
/// - condition ? value1 : value2
class TernaryOpNode: ASTNode {
    private let condition: ASTNode
    private let trueExpr: ASTNode
    private let falseExpr: ASTNode
    private let op: OperatorType
    
    init(_ condition: ASTNode, _ trueExpr: ASTNode, _ falseExpr: ASTNode, _ op: OperatorType) {
        self.condition = condition
        self.trueExpr = trueExpr
        self.falseExpr = falseExpr
        self.op = op
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        switch op {
        case .ternary:
            // Standard ternary: condition ? trueExpr : falseExpr
            let condValue = try condition.evaluate(environment)
            let condBool = try condValue.toBoolean()
            if condBool {
                return try trueExpr.evaluate(environment)
            } else {
                return try falseExpr.evaluate(environment)
            }
        default:
            throw ExpressionError.typeError("Unsupported ternary operator")
        }
    }
}

/// AST node representing function calls
///
/// This node stores a function name and a list of argument expressions.
/// During evaluation, it evaluates all arguments and delegates to the
/// IEnvironment to perform the actual function call.
///
/// Examples: max(a, b), sqrt(x), distance(x1, y1, x2, y2)
class FunctionCallNode: ASTNode {
    private let name: String
    private let args: [ASTNode]
    
    init(_ name: String, _ args: [ASTNode]) {
        self.name = name
        self.args = args
    }
    
    func evaluate(_ environment: IEnvironment?) throws -> Value {
        var evaluatedArgs: [Value] = []
        for arg in args {
            evaluatedArgs.append(try arg.evaluate(environment))
        }
        
        // First try standard mathematical functions (works without environment)
        if let standardResult = try callStandardFunctions(name, args: evaluatedArgs) {
            return standardResult
        }
        
        // If not a standard function, require environment
        guard let environment = environment else {
            throw ExpressionError.evaluationError("Function call requires IEnvironment")
        }
        return try environment.call(name, args: evaluatedArgs)
    }
}

/// Recursive descent parser for expression strings
///
/// This class implements a complete expression parser using the recursive
/// descent parsing technique. It supports operator precedence, associativity,
/// and proper error reporting.
///
/// Grammar (in order of precedence, highest to lowest):
/// - Primary: numbers, booleans, variables, function calls, parentheses
/// - Unary: !, not, - (unary minus)
/// - Multiplicative: *, /
/// - Additive: +, -
/// - Relational: <, >, <=, >=
/// - Equality: ==, !=
/// - Logical XOR: xor
/// - Logical AND: &&, and
/// - Logical OR: ||, or
/// - Ternary conditional: ? :
///
/// The parser is designed to be used once per expression string and
/// produces an AST that can be evaluated multiple times efficiently.
class Parser {
    private let expr: String
    private var pos: String.Index
    private var tokens: [Token]
    private var collectTokens: Bool
    
    init(_ expression: String, tokens: inout [Token]?) {
        self.expr = expression
        self.pos = expression.startIndex
        self.tokens = []
        self.collectTokens = tokens != nil
    }
    
    convenience init(_ expression: String) {
        var noTokens: [Token]? = nil
        self.init(expression, tokens: &noTokens)
    }
    
    private func addToken(_ type: TokenType, start: Int, length: Int, text: String) {
        if collectTokens {
            tokens.append(Token(type: type, start: start, length: length, text: text))
        }
    }
    
    private func addToken(_ type: TokenType, start: Int, length: Int) {
        if start + length <= expr.count {
            let startIdx = expr.index(expr.startIndex, offsetBy: start)
            let endIdx = expr.index(startIdx, offsetBy: length)
            let text = String(expr[startIdx..<endIdx])
            addToken(type, start: start, length: length, text: text)
        }
    }
    
    private func skipWhitespace() {
        let start = expr.distance(from: expr.startIndex, to: pos)
        while pos < expr.endIndex && expr[pos].isWhitespace {
            pos = expr.index(after: pos)
        }
        let length = expr.distance(from: expr.startIndex, to: pos) - start
        if length > 0 {
            addToken(.whitespace, start: start, length: length)
        }
    }
    
    private func match(_ str: String) -> Bool {
        skipWhitespace()
        let remaining = String(expr[pos...])
        if remaining.hasPrefix(str) {
            let start = expr.distance(from: expr.startIndex, to: pos)
            // Determine correct token type for special characters
            let type: TokenType
            if str == "(" || str == ")" {
                type = .parenthesis
            } else if str == "," {
                type = .comma
            } else {
                type = .operator
            }
            addToken(type, start: start, length: str.count, text: str)
            pos = expr.index(pos, offsetBy: str.count)
            return true
        }
        return false
    }
    
    private func match(_ char: Character) -> Bool {
        skipWhitespace()
        if pos < expr.endIndex && expr[pos] == char {
            let start = expr.distance(from: expr.startIndex, to: pos)
            let type: TokenType = (char == "(" || char == ")") ? .parenthesis :
                                  (char == ",") ? .comma : .operator
            addToken(type, start: start, length: 1, text: String(char))
            pos = expr.index(after: pos)
            return true
        }
        return false
    }
    
    private func peek() -> Character? {
        skipWhitespace()
        if pos >= expr.endIndex { return nil }
        return expr[pos]
    }
    
    private func peekString(_ length: Int) -> String {
        skipWhitespace()
        let remaining = String(expr[pos...])
        if remaining.count >= length {
            return String(remaining.prefix(length))
        }
        return ""
    }
    
    private func consume() throws -> Character {
        skipWhitespace()
        guard pos < expr.endIndex else {
            throw ExpressionError.parseError("Unexpected end of expression")
        }
        let char = expr[pos]
        let start = expr.distance(from: expr.startIndex, to: pos)
        addToken(.operator, start: start, length: 1, text: String(char))
        pos = expr.index(after: pos)
        return char
    }
    
    // Parse ternary expressions (lowest precedence)
    private func parseTernaryExpression() throws -> ASTNode {
        let condition = try parseOrExpression()
        if match("?") {
            let trueExpr = try parseTernaryExpression() // Right associative
            if !match(":") {
                throw ExpressionError.parseError("Expected ':' in ternary expression")
            }
            let falseExpr = try parseTernaryExpression() // Right associative
            return TernaryOpNode(condition, trueExpr, falseExpr, .ternary)
        }
        return condition
    }
    
    // Parse logical OR expressions
    private func parseOrExpression() throws -> ASTNode {
        var left = try parseAndExpression()
        while match("||") || match("or") {
            let right = try parseAndExpression()
            left = BinaryOpNode(left, .or, right)
        }
        return left
    }
    
    // Parse logical AND expressions
    private func parseAndExpression() throws -> ASTNode {
        var left = try parseXorExpression()
        while match("&&") || match("and") {
            let right = try parseXorExpression()
            left = BinaryOpNode(left, .and, right)
        }
        return left
    }
    
    // Parse logical XOR expressions
    private func parseXorExpression() throws -> ASTNode {
        var left = try parseEqualityExpression()
        while match("xor") {
            let right = try parseEqualityExpression()
            left = BinaryOpNode(left, .xor, right)
        }
        return left
    }
    
    // Parse equality expressions
    private func parseEqualityExpression() throws -> ASTNode {
        var left = try parseRelationalExpression()
        while true {
            if match("==") {
                let right = try parseRelationalExpression()
                left = BinaryOpNode(left, .eq, right)
            } else if match("!=") {
                let right = try parseRelationalExpression()
                left = BinaryOpNode(left, .ne, right)
            } else {
                break
            }
        }
        return left
    }
    
    // Parse relational expressions
    private func parseRelationalExpression() throws -> ASTNode {
        var left = try parseAdditiveExpression()
        while true {
            if match(">=") {
                let right = try parseAdditiveExpression()
                left = BinaryOpNode(left, .ge, right)
            } else if match("<=") {
                let right = try parseAdditiveExpression()
                left = BinaryOpNode(left, .le, right)
            } else if match(">") {
                let right = try parseAdditiveExpression()
                left = BinaryOpNode(left, .gt, right)
            } else if match("<") {
                let right = try parseAdditiveExpression()
                left = BinaryOpNode(left, .lt, right)
            } else if match("in") {
                let right = try parseAdditiveExpression()
                left = BinaryOpNode(left, .in, right)
            } else {
                break
            }
        }
        return left
    }
    
    // Parse additive expressions
    private func parseAdditiveExpression() throws -> ASTNode {
        var left = try parseMultiplicativeExpression()
        while let char = peek(), (char == "+" || char == "-") {
            let op: OperatorType = try consume() == "+" ? .add : .sub
            let right = try parseMultiplicativeExpression()
            left = BinaryOpNode(left, op, right)
        }
        return left
    }
    
    // Parse multiplicative expressions
    private func parseMultiplicativeExpression() throws -> ASTNode {
        var left = try parseUnaryExpression()
        while let char = peek(), (char == "*" || char == "/") {
            let op: OperatorType = try consume() == "*" ? .mul : .div
            let right = try parseUnaryExpression()
            left = BinaryOpNode(left, op, right)
        }
        return left
    }
    
    // Parse unary expressions
    private func parseUnaryExpression() throws -> ASTNode {
        if match("!") || match("not") {
            let operand = try parseUnaryExpression()
            return UnaryOpNode(.not, operand)
        }
        
        if match("-") {
            let operand = try parseUnaryExpression()
            return UnaryOpNode(.sub, operand)
        }
        
        return try parsePrimaryExpression()
    }
    
    // Parse primary expressions
    private func parsePrimaryExpression() throws -> ASTNode {
        if match("(") {
            let expr = try parseTernaryExpression()
            if !match(")") {
                throw ExpressionError.parseError("Missing closing parenthesis")
            }
            return expr
        }
        
        // Parse numbers
        if let char = peek(), char.isNumber || char == "." {
            let start = expr.distance(from: expr.startIndex, to: pos)
            var numStr = ""
            while pos < expr.endIndex && (expr[pos].isNumber || expr[pos] == ".") {
                numStr.append(expr[pos])
                pos = expr.index(after: pos)
            }
            let length = expr.distance(from: expr.startIndex, to: pos) - start
            addToken(.number, start: start, length: length, text: numStr)
            guard let num = Double(numStr) else {
                throw ExpressionError.parseError("Invalid number format: \(numStr)")
            }
            return NumberNode(num)
        }
        
        // Parse string literals
        if peek() == "\"" {
            let start = expr.distance(from: expr.startIndex, to: pos)
            pos = expr.index(after: pos) // Skip opening quote
            var str = ""
            
            while pos < expr.endIndex && expr[pos] != "\"" {
                if expr[pos] == "\\" && expr.index(after: pos) < expr.endIndex {
                    // Handle escape sequences
                    pos = expr.index(after: pos) // Skip backslash
                    switch expr[pos] {
                    case "n": str.append("\n")
                    case "t": str.append("\t")
                    case "r": str.append("\r")
                    case "\\": str.append("\\")
                    case "\"": str.append("\"")
                    default:
                        // Unknown escape sequence, keep original characters
                        str.append("\\")
                        str.append(expr[pos])
                    }
                    pos = expr.index(after: pos)
                } else {
                    str.append(expr[pos])
                    pos = expr.index(after: pos)
                }
            }
            
            if pos >= expr.endIndex {
                throw ExpressionError.parseError("Unterminated string literal")
            }
            
            pos = expr.index(after: pos) // Skip closing quote
            let length = expr.distance(from: expr.startIndex, to: pos) - start
            addToken(.string, start: start, length: length, text: "\"\(str)\"")
            return StringNode(str)
        }
        
        // Parse identifiers, booleans, and function calls
        if let char = peek(), char.isLetter {
            let start = expr.distance(from: expr.startIndex, to: pos)
            var ident = ""
            while pos < expr.endIndex && (expr[pos].isLetter || expr[pos].isNumber || expr[pos] == "." || expr[pos] == "_") {
                ident.append(expr[pos])
                pos = expr.index(after: pos)
            }
            
            // Check for function call
            if match("(") {
                var args: [ASTNode] = []
                if !match(")") {
                    repeat {
                        args.append(try parseTernaryExpression())
                    } while match(",")
                    if !match(")") {
                        throw ExpressionError.parseError("Missing closing parenthesis in function call")
                    }
                }
                addToken(.identifier, start: start, length: ident.count, text: ident)
                return FunctionCallNode(ident, args)
            }
            
            // Check for boolean literals
            if ident == "true" {
                addToken(.boolean, start: start, length: ident.count, text: ident)
                return BooleanNode(true)
            }
            if ident == "false" {
                addToken(.boolean, start: start, length: ident.count, text: ident)
                return BooleanNode(false)
            }
            
            // Variable
            addToken(.identifier, start: start, length: ident.count, text: ident)
            return VariableNode(ident)
        }
        
        throw ExpressionError.parseError("Unrecognized expression")
    }
    
    func parse() throws -> ASTNode {
        pos = expr.startIndex
        let result = try parseTernaryExpression()
        skipWhitespace()
        if pos < expr.endIndex {
            throw ExpressionError.parseError("Incomplete expression parsing")
        }
        return result
    }
    
    func getTokens() -> [Token] {
        return tokens
    }
}

/// Main expression toolkit class for parsing and evaluating expressions
///
/// Expression provides a complete expression evaluation system with support for:
/// - Arithmetic operations (+, -, *, /)
/// - Comparison operations (==, !=, <, >, <=, >=)
/// - Logical operations (&&, ||, !, xor)
/// - Variables and functions via Environment interface
/// - Expression compilation and caching for better performance
///
/// Usage examples:
/// ```swift
/// // Simple evaluation without variables
/// let result = try Expression.eval("2 + 3 * 4") // Returns 14.0
///
/// // With environment for variables and functions
/// let environment = MyEnvironment()
/// let result2 = try Expression.eval("x + sqrt(y)", environment: environment)
///
/// // Compile once, execute multiple times
/// let compiled = try Expression.parse("health > maxHealth * 0.5")
/// for frame in 0..<100 {
///     let alive = try compiled.evaluate(environment)
///     // ... game logic
/// }
/// ```
///
/// The Expression instance does not own the Environment object. The caller is
/// responsible for ensuring the Environment remains valid during expression
/// evaluation.
public class Expression {
    /// Evaluate an expression string directly with IEnvironment
    /// - Parameters:
    ///   - expression: The expression string to evaluate
    ///   - environment: Optional environment for variable and function resolution
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if parsing fails or evaluation encounters an error
    public static func eval(_ expression: String, environment: IEnvironment? = nil) throws -> Value {
        let ast = try parse(expression)
        return try ast.evaluate(environment)
    }
    
    /// Evaluate an expression string directly with EnvironmentProtocol (backward compatibility)
    /// - Parameters:
    ///   - expression: The expression string to evaluate
    ///   - environment: Optional environment for variable and function resolution
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if parsing fails or evaluation encounters an error
    public static func eval(_ expression: String, environment: EnvironmentProtocol?) throws -> Value {
        if let environment = environment {
            let adapter = EnvironmentProtocolAdapter(environment)
            return try eval(expression, environment: adapter)
        } else {
            return try eval(expression, environment: nil as IEnvironment?)
        }
    }
    
    /// Evaluate an expression string directly with token collection and IEnvironment
    /// - Parameters:
    ///   - expression: The expression string to evaluate
    ///   - environment: Optional environment for variable and function resolution
    ///   - collectTokens: Whether to collect tokens for syntax highlighting
    /// - Returns: A tuple containing the evaluation result and optional tokens
    /// - Throws: ExpressionError if parsing fails or evaluation encounters an error
    public static func eval(_ expression: String, environment: IEnvironment?, collectTokens: Bool) throws -> (Value, [Token]?) {
        var tokens: [Token]? = collectTokens ? [] : nil
        let ast = try parse(expression, tokens: &tokens)
        let result = try ast.evaluate(environment)
        return (result, tokens)
    }
    
    /// Evaluate an expression string directly with token collection (no environment)
    /// - Parameters:
    ///   - expression: The expression string to evaluate
    ///   - collectTokens: Whether to collect tokens for syntax highlighting
    /// - Returns: A tuple containing the evaluation result and optional tokens
    /// - Throws: ExpressionError if parsing fails or evaluation encounters an error
    public static func eval(_ expression: String, collectTokens: Bool) throws -> (Value, [Token]?) {
        return try eval(expression, environment: nil as IEnvironment?, collectTokens: collectTokens)
    }
    
    /// Evaluate an expression string directly with token collection and EnvironmentProtocol (backward compatibility)
    /// - Parameters:
    ///   - expression: The expression string to evaluate
    ///   - environment: Optional environment for variable and function resolution
    ///   - collectTokens: Whether to collect tokens for syntax highlighting
    /// - Returns: A tuple containing the evaluation result and optional tokens
    /// - Throws: ExpressionError if parsing fails or evaluation encounters an error
    public static func eval(_ expression: String, environment: EnvironmentProtocol?, collectTokens: Bool) throws -> (Value, [Token]?) {
        if let environment = environment {
            let adapter = EnvironmentProtocolAdapter(environment)
            return try eval(expression, environment: adapter, collectTokens: collectTokens)
        } else {
            return try eval(expression, environment: nil as IEnvironment?, collectTokens: collectTokens)
        }
    }
    
    /// Parse an expression string into an Abstract Syntax Tree
    /// - Parameter expression: The expression string to parse
    /// - Returns: The root AST node
    /// - Throws: ExpressionError if the expression syntax is invalid
    ///
    /// This method creates a compiled AST that can be evaluated multiple times
    /// efficiently without re-parsing.
    public static func parse(_ expression: String) throws -> CompiledExpression {
        let parser = Parser(expression)
        let ast = try parser.parse()
        return CompiledExpression(ast: ast)
    }
    
    /// Parse an expression string into an Abstract Syntax Tree with token collection
    /// - Parameters:
    ///   - expression: The expression string to parse
    ///   - tokens: Inout array to collect tokens for syntax highlighting
    /// - Returns: The root AST node
    /// - Throws: ExpressionError if the expression syntax is invalid
    ///
    /// This method parses the expression while collecting tokens
    /// that can be used for syntax highlighting or other analysis.
    public static func parse(_ expression: String, tokens: inout [Token]?) throws -> CompiledExpression {
        let parser = Parser(expression, tokens: &tokens)
        let ast = try parser.parse()
        // Copy tokens back from parser
        if tokens != nil {
            tokens = parser.getTokens()
        }
        return CompiledExpression(ast: ast)
    }
    
    /// Call standard mathematical functions
    /// - Parameters:
    ///   - functionName: The name of the function to call
    ///   - args: The arguments to pass to the function  
    /// - Returns: The function result, or nil if the function was not found
    /// - Throws: ExpressionError if the function arguments are invalid
    ///
    /// This function delegates to the standalone callStandardFunctions for consistency.
    public static func callStandardFunctions(_ functionName: String, args: [Value]) throws -> Value? {
        return try ExpressionKit.callStandardFunctions(functionName, args: args)
    }
}

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
///     let result = try expression.evaluate()  // Much faster than re-parsing each time
/// }
/// ```
public class CompiledExpression {
    private let ast: ASTNode
    
    internal init(ast: ASTNode) {
        self.ast = ast
    }
    
    /// Evaluate this expression with IEnvironment
    /// - Parameter environment: Optional environment for variable and function resolution
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if evaluation fails
    public func evaluate(_ environment: IEnvironment? = nil) throws -> Value {
        return try ast.evaluate(environment)
    }
    
    /// Evaluate this expression with EnvironmentProtocol (backward compatibility)
    /// - Parameter environment: Optional environment for variable and function resolution
    /// - Returns: The evaluation result
    /// - Throws: ExpressionError if evaluation fails
    public func evaluate(_ environment: EnvironmentProtocol?) throws -> Value {
        if let environment = environment {
            let adapter = EnvironmentProtocolAdapter(environment)
            return try evaluate(adapter)
        } else {
            return try evaluate(nil as IEnvironment?)
        }
    }
    
    /// Convenience method for eval() to match existing API with IEnvironment
    public func eval(_ environment: IEnvironment? = nil) throws -> Value {
        return try evaluate(environment)
    }
    
    /// Convenience method for eval() to match existing API with EnvironmentProtocol (backward compatibility)
    public func eval(_ environment: EnvironmentProtocol?) throws -> Value {
        return try evaluate(environment)
    }
}

// MARK: - Namespace-level convenience functions for backward compatibility

/// Evaluate an expression string directly (namespace-level convenience function)
public func eval(_ expression: String, environment: IEnvironment? = nil) throws -> Value {
    return try Expression.eval(expression, environment: environment)
}

/// Evaluate an expression string directly with token collection (namespace-level convenience function)
public func eval(_ expression: String, environment: IEnvironment? = nil, collectTokens: Bool) throws -> (Value, [Token]?) {
    return try Expression.eval(expression, environment: environment, collectTokens: collectTokens)
}

/// Parse an expression string into an Abstract Syntax Tree (namespace-level convenience function)
public func parse(_ expression: String) throws -> CompiledExpression {
    return try Expression.parse(expression)
}

/// Parse an expression string into an Abstract Syntax Tree with token collection (namespace-level convenience function)
public func parse(_ expression: String, tokens: inout [Token]?) throws -> CompiledExpression {
    return try Expression.parse(expression, tokens: &tokens)
}