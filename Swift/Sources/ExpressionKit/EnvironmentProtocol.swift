import Foundation

/// Protocol for providing variable access and function calls during expression evaluation
/// This corresponds to the IEnvironment interface in the C++ version
/// 
/// Note: This is provided for backward compatibility. New code should use IEnvironment from ExpressionKit.swift
public protocol EnvironmentProtocol {
    /// Get a variable value by name
    /// - Parameter name: Variable name (supports dot notation like "pos.x")
    /// - Returns: The variable value
    /// - Throws: ExpressionError if the variable is not found
    func getValue(for name: String) throws -> Value
    
    /// Call a function with given arguments
    /// - Parameters:
    ///   - name: Function name
    ///   - arguments: Function arguments
    /// - Returns: Function result
    /// - Throws: ExpressionError if the function is not found or arguments are invalid
    func callFunction(name: String, arguments: [Value]) throws -> Value
}

/// Bridge adapter to make EnvironmentProtocol work with IEnvironment
internal class EnvironmentProtocolAdapter: IEnvironment {
    private let environment: EnvironmentProtocol
    
    init(_ environment: EnvironmentProtocol) {
        self.environment = environment
    }
    
    func get(_ name: String) throws -> Value {
        return try environment.getValue(for: name)
    }
    
    func call(_ name: String, args: [Value]) throws -> Value {
        return try environment.callFunction(name: name, arguments: args)
    }
}