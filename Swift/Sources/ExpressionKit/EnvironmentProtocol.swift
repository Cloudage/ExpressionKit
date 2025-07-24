import Foundation

/// Protocol for providing variable access and function calls during expression evaluation
/// This corresponds to the IEnvironment interface in the C++ version
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