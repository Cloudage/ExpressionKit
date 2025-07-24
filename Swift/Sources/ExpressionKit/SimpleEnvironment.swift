import Foundation
import ExpressionKitBridge

/// Simple environment that just stores variables and handles basic math functions
public final class SimpleEnvironment {
    private var variables: [String: Value] = [:]
    
    public init(variables: [String: Value] = [:]) {
        self.variables = variables
    }
    
    public func setValue(_ value: Value, for name: String) {
        variables[name] = value
    }
    
    public func getValue(for name: String) throws -> Value {
        guard let value = variables[name] else {
            throw ExpressionError.environmentError("Variable not found: \(name)")
        }
        return value
    }
    
    public func callFunction(name: String, arguments: [Value]) throws -> Value {
        // All standard mathematical functions (min, max, abs, sqrt, pow, sin, cos, tan, log, exp, floor, ceil, round)
        // are automatically handled by the C++ bridge layer via ExprTK::CallStandardFunctions()
        // Only custom/domain-specific functions need to be implemented here
        
        throw ExpressionError.environmentError("Unknown function: \(name)")
    }
}