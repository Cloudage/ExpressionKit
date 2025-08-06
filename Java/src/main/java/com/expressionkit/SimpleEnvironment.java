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
 *
 * NOTE: This code is a 1:1 translation from the C++ ExpressionKit.hpp implementation
 * to Java, maintaining the same algorithms, structure, and behavior while using
 * Java-idiomatic patterns and conventions.
 */

package com.expressionkit;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Simple implementation of IEnvironment using a HashMap for variable storage
 *
 * This is a basic environment implementation that stores variables in a Map
 * and delegates function calls to standard mathematical functions. It's useful
 * for testing and simple use cases.
 *
 * Example usage:
 * <pre>
 * SimpleEnvironment env = new SimpleEnvironment();
 * env.set("x", new Value(10.0));
 * env.set("y", new Value(20.0));
 * 
 * Value result = Expression.eval("x + y * 2", env); // Returns 50.0
 * </pre>
 */
public class SimpleEnvironment implements IEnvironment {
    private final Map<String, Value> variables = new HashMap<>();

    /**
     * Create an empty environment
     */
    public SimpleEnvironment() {
    }

    /**
     * Create an environment with initial variables
     * @param initialVariables Map of initial variable values
     */
    public SimpleEnvironment(Map<String, Value> initialVariables) {
        if (initialVariables != null) {
            variables.putAll(initialVariables);
        }
    }

    /**
     * Set a variable value
     * @param name Variable name
     * @param value Variable value
     */
    public void set(String name, Value value) {
        variables.put(name, value);
    }

    /**
     * Set a variable value (convenience method for numbers)
     * @param name Variable name
     * @param value Variable value
     */
    public void set(String name, double value) {
        variables.put(name, new Value(value));
    }

    /**
     * Set a variable value (convenience method for booleans)
     * @param name Variable name
     * @param value Variable value
     */
    public void set(String name, boolean value) {
        variables.put(name, new Value(value));
    }

    /**
     * Set a variable value (convenience method for strings)
     * @param name Variable name
     * @param value Variable value
     */
    public void set(String name, String value) {
        variables.put(name, new Value(value));
    }

    /**
     * Remove a variable
     * @param name Variable name
     * @return true if variable was removed, false if it didn't exist
     */
    public boolean remove(String name) {
        return variables.remove(name) != null;
    }

    /**
     * Clear all variables
     */
    public void clear() {
        variables.clear();
    }

    /**
     * Check if a variable exists
     * @param name Variable name
     * @return true if variable exists
     */
    public boolean contains(String name) {
        return variables.containsKey(name);
    }

    /**
     * Get all variable names
     * @return Set of variable names
     */
    public java.util.Set<String> getVariableNames() {
        return variables.keySet();
    }

    /**
     * Get the number of variables
     * @return Number of variables
     */
    public int size() {
        return variables.size();
    }

    @Override
    public Value get(String name) throws ExpressionException {
        Value value = variables.get(name);
        if (value == null) {
            throw new ExpressionException.UnknownVariableException(name);
        }
        return value;
    }

    @Override
    public Value call(String name, List<Value> args) throws ExpressionException {
        // Try standard mathematical functions first
        Value standardResult = StandardFunctions.call(name, args);
        if (standardResult != null) {
            return standardResult;
        }

        // If not a standard function, throw exception
        throw new ExpressionException.UnknownFunctionException(name);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("SimpleEnvironment{");
        boolean first = true;
        for (Map.Entry<String, Value> entry : variables.entrySet()) {
            if (!first) {
                sb.append(", ");
            }
            sb.append(entry.getKey()).append("=").append(entry.getValue().toString());
            first = false;
        }
        sb.append("}");
        return sb.toString();
    }
}