import { Value, IEnvironment } from './ExpressionKit';
/**
 * Simple implementation of IEnvironment using Map for variable storage
 *
 * This class provides a basic implementation of the IEnvironment interface
 * using a Map to store variables. It also supports standard mathematical
 * functions automatically.
 *
 * Example:
 * ```typescript
 * const env = new SimpleEnvironment();
 * env.setVariable('x', new Value(10));
 * env.setVariable('y', new Value(20));
 *
 * const result = Expression.evalSimple('x + y * 2', env); // 50
 * ```
 */
export declare class SimpleEnvironment implements IEnvironment {
    private variables;
    /**
     * Set a variable value
     * @param name Variable name
     * @param value Variable value
     */
    setVariable(name: string, value: Value): void;
    /**
     * Get a variable value by name
     * @param name Variable name
     * @returns Variable value
     * @throws ExpressionError if variable is not found
     */
    get(name: string): Value;
    /**
     * Call a function with given arguments
     * @param name Function name
     * @param args Function arguments
     * @returns Function result
     * @throws ExpressionError if function is not found or arguments are invalid
     */
    call(name: string, args: Value[]): Value;
    /**
     * Check if a variable exists
     * @param name Variable name
     * @returns True if variable exists
     */
    hasVariable(name: string): boolean;
    /**
     * Remove a variable
     * @param name Variable name
     * @returns True if variable was removed
     */
    removeVariable(name: string): boolean;
    /**
     * Get all variable names
     * @returns Array of variable names
     */
    getVariableNames(): string[];
    /**
     * Clear all variables
     */
    clear(): void;
    /**
     * Get number of variables
     * @returns Number of variables
     */
    size(): number;
    /**
     * Set multiple variables at once
     * @param variables Object with variable name-value pairs
     */
    setVariables(variables: Record<string, Value>): void;
    /**
     * Get all variables as an object
     * @returns Object with variable name-value pairs
     */
    getVariables(): Record<string, Value>;
}
