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

package com.expressionkit

/**
 * Simple implementation of IEnvironment for testing and basic usage
 * 
 * This class provides a Map-based implementation of the IEnvironment interface,
 * suitable for testing and simple use cases where variables and functions can
 * be pre-defined in dictionaries.
 */
class SimpleEnvironment : IEnvironment {
    private val variables = mutableMapOf<String, Value>()
    private val functions = mutableMapOf<String, (List<Value>) -> Value>()
    
    /**
     * Set a variable value
     * @param name Variable name
     * @param value Variable value
     */
    fun setVariable(name: String, value: Value) {
        variables[name] = value
    }
    
    /**
     * Set a variable value (convenience method for numbers)
     * @param name Variable name  
     * @param value Numeric value
     */
    fun setVariable(name: String, value: Double) {
        variables[name] = Value.number(value)
    }
    
    /**
     * Set a variable value (convenience method for booleans)
     * @param name Variable name
     * @param value Boolean value
     */
    fun setVariable(name: String, value: Boolean) {
        variables[name] = Value.boolean(value)
    }
    
    /**
     * Set a variable value (convenience method for strings)
     * @param name Variable name
     * @param value String value
     */
    fun setVariable(name: String, value: String) {
        variables[name] = Value.string(value)
    }
    
    /**
     * Register a custom function
     * @param name Function name
     * @param implementation Function implementation
     */
    fun setFunction(name: String, implementation: (List<Value>) -> Value) {
        functions[name] = implementation
    }
    
    /**
     * Clear all variables and functions
     */
    fun clear() {
        variables.clear()
        functions.clear()
    }
    
    override fun get(name: String): Value {
        return variables[name] ?: throw ExpressionError("Variable '$name' not found")
    }
    
    override fun call(name: String, args: List<Value>): Value {
        val function = functions[name] ?: throw ExpressionError("Function '$name' not found")
        return try {
            function(args)
        } catch (e: Exception) {
            throw ExpressionError("Error calling function '$name': ${e.message}")
        }
    }
}