import Foundation
import ExpressionKitCore

/// Swift typealias for the C ExprValue - eliminates duplication
public typealias Value = ExprValue

// MARK: - Swift Extensions for ExprValue to provide convenience methods
extension ExprValue {
    /// Create a Value from a number
    public static func number(_ value: Double) -> ExprValue {
        return expr_make_number(value)
    }
    
    /// Create a Value from a boolean  
    public static func boolean(_ value: Bool) -> ExprValue {
        return expr_make_boolean(value)
    }
    
    /// Get the number value if this is a number
    public var numberValue: Double? {
        return isNumber ? data.number : nil
    }
    
    /// Get the boolean value if this is a boolean
    public var booleanValue: Bool? {
        return isBoolean ? data.boolean : nil
    }
    
    /// Get the number value, throwing an error if not a number
    public func asNumber() throws -> Double {
        guard isNumber else {
            throw ExpressionError.typeMismatch("Expected number, got boolean")
        }
        return data.number
    }
    
    /// Get the boolean value, throwing an error if not a boolean
    public func asBoolean() throws -> Bool {
        guard isBoolean else {
            throw ExpressionError.typeMismatch("Expected boolean, got number")
        }
        return data.boolean
    }
    
    /// Check if this value is a number
    public var isNumber: Bool {
        var copy = self
        return expr_value_is_number(&copy)
    }
    
    /// Check if this value is a boolean
    public var isBoolean: Bool {
        var copy = self
        return expr_value_is_boolean(&copy)
    }
}

// MARK: - ExpressibleBy literals
extension ExprValue: @retroactive ExpressibleByFloatLiteral, @retroactive ExpressibleByIntegerLiteral, @retroactive ExpressibleByBooleanLiteral {
    public init(floatLiteral value: Double) {
        self = expr_make_number(value)
    }
    
    public init(integerLiteral value: Int) {
        self = expr_make_number(Double(value))
    }
    
    public init(booleanLiteral value: Bool) {
        self = expr_make_boolean(value)
    }
}

// MARK: - Equatable
extension ExprValue: @retroactive Equatable {
    public static func == (lhs: ExprValue, rhs: ExprValue) -> Bool {
        if lhs.type != rhs.type {
            return false
        }
        
        switch lhs.type {
        case ExprValueTypeNumber:
            return lhs.data.number == rhs.data.number
        case ExprValueTypeBoolean:
            return lhs.data.boolean == rhs.data.boolean
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible
extension ExprValue: @retroactive CustomStringConvertible {
    public var description: String {
        switch type {
        case ExprValueTypeNumber:
            return String(data.number)
        case ExprValueTypeBoolean:
            return String(data.boolean)
        default:
            return "unknown"
        }
    }
}