import Foundation
import ExpressionKitBridge

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
    
    /// Create a Value from a string
    public static func string(_ value: String) -> ExprValue {
        return expr_make_string(value)
    }
    
    /// Get the number value if this is a number
    public var numberValue: Double? {
        return isNumber ? data.number : nil
    }
    
    /// Get the boolean value if this is a boolean
    public var booleanValue: Bool? {
        return isBoolean ? data.boolean : nil
    }
    
    /// Get the string value if this is a string
    public var stringValue: String? {
        if isString {
            var copy = self
            if let cString = expr_value_as_string(&copy) {
                return String(cString: cString)
            }
        }
        return nil
    }
    
    /// Get the number value, throwing an error if not a number
    /// - Returns: The number value as Double
    /// - Throws: ExpressionError.typeMismatch if this value is not a number
    public func asNumber() throws -> Double {
        guard isNumber else {
            let actualType = typeDescription
            throw ExpressionError.typeMismatch("Expected number, got \(actualType)")
        }
        return data.number
    }
    
    /// Get the boolean value, throwing an error if not a boolean
    /// - Returns: The boolean value as Bool
    /// - Throws: ExpressionError.typeMismatch if this value is not a boolean
    public func asBoolean() throws -> Bool {
        guard isBoolean else {
            let actualType = typeDescription
            throw ExpressionError.typeMismatch("Expected boolean, got \(actualType)")
        }
        return data.boolean
    }
    
    /// Get the string value, throwing an error if not a string
    /// - Returns: The string value as String
    /// - Throws: ExpressionError.typeMismatch if this value is not a string
    public func asString() throws -> String {
        guard isString else {
            let actualType = typeDescription
            throw ExpressionError.typeMismatch("Expected string, got \(actualType)")
        }
        var copy = self
        guard let cString = expr_value_as_string(&copy) else {
            throw ExpressionError.evaluationFailed("Failed to get string value")
        }
        return String(cString: cString)
    }
    
    /// Human-readable description of the value's type
    /// - Returns: A string describing the type ("number", "boolean", "string", or "unknown")
    public var typeDescription: String {
        if isNumber {
            return "number"
        } else if isBoolean {
            return "boolean"
        } else if isString {
            return "string"
        } else {
            return "unknown"
        }
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
    
    /// Check if this value is a string
    public var isString: Bool {
        var copy = self
        return expr_value_is_string(&copy)
    }
}

// MARK: - ExpressibleBy literals
extension ExprValue: @retroactive ExpressibleByFloatLiteral, @retroactive ExpressibleByIntegerLiteral, @retroactive ExpressibleByBooleanLiteral, @retroactive ExpressibleByStringLiteral {
    public init(floatLiteral value: Double) {
        self = expr_make_number(value)
    }
    
    public init(integerLiteral value: Int) {
        self = expr_make_number(Double(value))
    }
    
    public init(booleanLiteral value: Bool) {
        self = expr_make_boolean(value)
    }
    
    public init(stringLiteral value: String) {
        self = expr_make_string(value)
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
        case ExprValueTypeString:
            guard let lhsString = lhs.stringValue,
                  let rhsString = rhs.stringValue else {
                return false
            }
            return lhsString == rhsString
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
        case ExprValueTypeString:
            return stringValue ?? "nil"
        default:
            return "unknown"
        }
    }
}