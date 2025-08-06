"use strict";
/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SimpleEnvironment = void 0;
const ExpressionKit_1 = require("./ExpressionKit");
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
class SimpleEnvironment {
    constructor() {
        this.variables = new Map();
    }
    /**
     * Set a variable value
     * @param name Variable name
     * @param value Variable value
     */
    setVariable(name, value) {
        this.variables.set(name, value);
    }
    /**
     * Get a variable value by name
     * @param name Variable name
     * @returns Variable value
     * @throws ExpressionError if variable is not found
     */
    get(name) {
        const value = this.variables.get(name);
        if (value === undefined) {
            throw ExpressionKit_1.ExpressionError.unknownVariable(name);
        }
        return value;
    }
    /**
     * Call a function with given arguments
     * @param name Function name
     * @param args Function arguments
     * @returns Function result
     * @throws ExpressionError if function is not found or arguments are invalid
     */
    call(name, args) {
        // Try standard mathematical functions first
        const result = (0, ExpressionKit_1.callStandardFunctions)(name, args);
        if (result !== null) {
            return result;
        }
        // If not a standard function, throw error
        throw ExpressionKit_1.ExpressionError.unknownFunction(name);
    }
    /**
     * Check if a variable exists
     * @param name Variable name
     * @returns True if variable exists
     */
    hasVariable(name) {
        return this.variables.has(name);
    }
    /**
     * Remove a variable
     * @param name Variable name
     * @returns True if variable was removed
     */
    removeVariable(name) {
        return this.variables.delete(name);
    }
    /**
     * Get all variable names
     * @returns Array of variable names
     */
    getVariableNames() {
        return Array.from(this.variables.keys());
    }
    /**
     * Clear all variables
     */
    clear() {
        this.variables.clear();
    }
    /**
     * Get number of variables
     * @returns Number of variables
     */
    size() {
        return this.variables.size;
    }
    /**
     * Set multiple variables at once
     * @param variables Object with variable name-value pairs
     */
    setVariables(variables) {
        for (const [name, value] of Object.entries(variables)) {
            this.setVariable(name, value);
        }
    }
    /**
     * Get all variables as an object
     * @returns Object with variable name-value pairs
     */
    getVariables() {
        const result = {};
        for (const [name, value] of this.variables.entries()) {
            result[name] = value;
        }
        return result;
    }
}
exports.SimpleEnvironment = SimpleEnvironment;
