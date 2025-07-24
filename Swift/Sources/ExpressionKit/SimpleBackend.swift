import Foundation
import ExpressionKitBridge

/// Simple backend that just stores variables and handles basic math functions
public final class SimpleBackend {
    private var variables: [String: Value] = [:]
    
    public init(variables: [String: Value] = [:]) {
        self.variables = variables
    }
    
    public func setValue(_ value: Value, for name: String) {
        variables[name] = value
    }
    
    public func getValue(for name: String) throws -> Value {
        guard let value = variables[name] else {
            throw ExpressionError.backendError("Variable not found: \(name)")
        }
        return value
    }
    
    public func callFunction(name: String, arguments: [Value]) throws -> Value {
        // Implement basic mathematical functions directly
        switch name {
        case "min" where arguments.count == 2:
            let a = try arguments[0].asNumber()
            let b = try arguments[1].asNumber()
            return .number(min(a, b))
        case "max" where arguments.count == 2:
            let a = try arguments[0].asNumber()
            let b = try arguments[1].asNumber()
            return .number(max(a, b))
        case "abs" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(abs(a))
        case "sqrt" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            guard a >= 0 else { throw ExpressionError.backendError("sqrt: negative argument") }
            return .number(sqrt(a))
        case "pow" where arguments.count == 2:
            let a = try arguments[0].asNumber()
            let b = try arguments[1].asNumber()
            return .number(pow(a, b))
        case "sin" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(sin(a))
        case "cos" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(cos(a))
        case "tan" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(tan(a))
        case "log" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            guard a > 0 else { throw ExpressionError.backendError("log: non-positive argument") }
            return .number(log(a))
        case "exp" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(exp(a))
        case "floor" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(floor(a))
        case "ceil" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(ceil(a))
        case "round" where arguments.count == 1:
            let a = try arguments[0].asNumber()
            return .number(round(a))
        default:
            throw ExpressionError.backendError("Unknown function: \(name)")
        }
    }
}