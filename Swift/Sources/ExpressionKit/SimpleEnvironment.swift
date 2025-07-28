import Foundation
import ExpressionKitBridge

/// Simple implementation of EnvironmentProtocol that stores variables in a dictionary
/// 
/// This environment provides basic variable storage and automatic access to all standard
/// mathematical functions (min, max, sqrt, abs, sin, cos, tan, log, exp, pow, floor, ceil, round).
/// Custom functions can be added by subclassing and overriding `callFunction`.
///
/// ## Standard Functions Available:
/// - `min(a, b)`, `max(a, b)` - Minimum and maximum values
/// - `sqrt(x)`, `abs(x)`, `pow(x, y)` - Square root, absolute value, power
/// - `sin(x)`, `cos(x)`, `tan(x)` - Trigonometric functions (radians)
/// - `log(x)`, `exp(x)` - Natural logarithm and exponential
/// - `floor(x)`, `ceil(x)`, `round(x)` - Rounding functions
///
/// ## Usage:
/// ```swift
/// let env = SimpleEnvironment()
/// env.setValue(.number(42), for: "x")
/// env.setValue(.boolean(true), for: "enabled")
/// 
/// // Variables can be used in expressions
/// let result = try Expression.eval("x * 2 + sqrt(16)", environment: env)
/// ```
public final class SimpleEnvironment: EnvironmentProtocol {
    private var variables: [String: Value] = [:]
    
    /// Initialize with optional initial variables
    /// - Parameter variables: Dictionary of initial variable name-value pairs
    public init(variables: [String: Value] = [:]) {
        self.variables = variables
    }
    
    /// Set a variable value
    /// - Parameters:
    ///   - value: The value to store
    ///   - name: The variable name (supports dot notation like "pos.x")
    public func setValue(_ value: Value, for name: String) {
        variables[name] = value
    }
    
    /// Get all currently stored variables
    /// - Returns: Dictionary of all variable name-value pairs
    public var allVariables: [String: Value] {
        return variables
    }
    
    /// Check if a variable exists
    /// - Parameter name: Variable name to check
    /// - Returns: true if the variable exists, false otherwise
    public func hasVariable(named name: String) -> Bool {
        return variables.keys.contains(name)
    }
    
    public func getValue(for name: String) throws -> Value {
        guard let value = variables[name] else {
            throw ExpressionError.environmentError("Variable not found: \(name)")
        }
        return value
    }
    
    public func callFunction(name: String, arguments: [Value]) throws -> Value {
        // All standard mathematical functions (min, max, abs, sqrt, pow, sin, cos, tan, log, exp, floor, ceil, round)
        // are automatically handled by the C++ bridge layer via ExpressionKit::CallStandardFunctions()
        // Only custom/domain-specific functions need to be implemented here
        
        // Provide a more specific error message
        throw ExpressionError.environmentError("Unknown function '\(name)' with \(arguments.count) argument(s). Standard mathematical functions are handled automatically.")
    }
}