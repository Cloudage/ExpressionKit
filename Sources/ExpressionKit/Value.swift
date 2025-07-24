import Foundation
import ExpressionKitCore

/// Represents a value that can be either a number or boolean
public enum Value {
    case number(Double)
    case boolean(Bool)
    
    /// Create a Value from the C ExprValue
    internal init(from cValue: ExprValue) {
        switch cValue.type {
        case ExprValueTypeNumber:
            self = .number(cValue.data.number)
        case ExprValueTypeBoolean:
            self = .boolean(cValue.data.boolean)
        default:
            self = .number(0.0) // fallback
        }
    }
    
    /// Convert to C ExprValue
    internal var cValue: ExprValue {
        switch self {
        case .number(let value):
            return expr_make_number(value)
        case .boolean(let value):
            return expr_make_boolean(value)
        }
    }
    
    /// Get the number value if this is a number
    public var numberValue: Double? {
        if case .number(let value) = self {
            return value
        }
        return nil
    }
    
    /// Get the boolean value if this is a boolean
    public var booleanValue: Bool? {
        if case .boolean(let value) = self {
            return value
        }
        return nil
    }
    
    /// Get the number value, throwing an error if not a number
    public func asNumber() throws -> Double {
        guard case .number(let value) = self else {
            throw ExpressionError.typeMismatch("Expected number, got boolean")
        }
        return value
    }
    
    /// Get the boolean value, throwing an error if not a boolean
    public func asBoolean() throws -> Bool {
        guard case .boolean(let value) = self else {
            throw ExpressionError.typeMismatch("Expected boolean, got number")
        }
        return value
    }
    
    /// Check if this value is a number
    public var isNumber: Bool {
        if case .number = self { return true }
        return false
    }
    
    /// Check if this value is a boolean
    public var isBoolean: Bool {
        if case .boolean = self { return true }
        return false
    }
}

// MARK: - ExpressibleBy literals
extension Value: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
    
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
    
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

// MARK: - Equatable
extension Value: Equatable {
    public static func == (lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.number(let l), .number(let r)):
            return l == r
        case (.boolean(let l), .boolean(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible
extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case .number(let value):
            return String(value)
        case .boolean(let value):
            return String(value)
        }
    }
}