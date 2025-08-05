import Foundation

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
/// env.setValue(42, for: "x")
/// env.setValue(true, for: "enabled")
/// 
/// // Variables can be used in expressions
/// let result = try Expression.eval("x * 2 + sqrt(16)", environment: env)
/// ```
public final class SimpleEnvironment: EnvironmentProtocol, IEnvironment {
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
    
    // MARK: - EnvironmentProtocol implementation
    
    public func getValue(for name: String) throws -> Value {
        guard let value = variables[name] else {
            throw ExpressionError.unknownVariable(name)
        }
        return value
    }
    
    public func callFunction(name: String, arguments: [Value]) throws -> Value {
        // Try standard mathematical functions first
        if let result = try callStandardFunctions(name, args: arguments) {
            return result
        }
        
        // If not a standard function, throw an error
        throw ExpressionError.unknownFunction(name)
    }
    
    // MARK: - IEnvironment implementation
    
    public func get(_ name: String) throws -> Value {
        return try getValue(for: name)
    }
    
    public func call(_ name: String, args: [Value]) throws -> Value {
        return try callFunction(name: name, arguments: args)
    }
}