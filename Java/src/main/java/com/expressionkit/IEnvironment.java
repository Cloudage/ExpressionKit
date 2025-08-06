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

import java.util.List;

/**
 * Environment interface for variable access and function calls
 *
 * Implement this interface to provide custom variable storage and function
 * implementations. The environment is responsible for handling variable reads,
 * optional variable writes, and function calls during expression evaluation.
 *
 * Note: The integrating application is responsible for managing the environment's
 * lifetime. ExpressionKit stores only a reference and does not take ownership.
 */
public interface IEnvironment {
    
    /**
     * Get a variable value by name
     * @param name Variable name (supports dot notation like "pos.x")
     * @return The variable value
     * @throws ExpressionException if the variable is not found
     */
    Value get(String name) throws ExpressionException;

    /**
     * Call a function with given arguments
     * @param name Function name
     * @param args Function arguments
     * @return Function result
     * @throws ExpressionException if the function is not found or arguments are invalid
     */
    Value call(String name, List<Value> args) throws ExpressionException;
}