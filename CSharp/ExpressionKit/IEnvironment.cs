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
 * to C#, maintaining the same algorithms, structure, and behavior while using
 * C#-idiomatic patterns and conventions.
 */

using System;
using System.Collections.Generic;

namespace ExpressionKit
{
    /// <summary>
    /// Environment interface for variable and function resolution.
    /// This interface provides a clean abstraction for accessing variables and functions
    /// during expression evaluation, following the C++ IEnvironment pattern.
    /// </summary>
    public interface IEnvironment
    {
        /// <summary>
        /// Gets the value of a variable
        /// </summary>
        /// <param name="name">The variable name</param>
        /// <returns>The variable value</returns>
        /// <exception cref="ExpressionException">If the variable is not defined</exception>
        Value Get(string name);

        /// <summary>
        /// Calls a function with the given arguments
        /// </summary>
        /// <param name="name">The function name</param>
        /// <param name="args">The function arguments</param>
        /// <returns>The function result</returns>
        /// <exception cref="ExpressionException">If the function is not defined or arguments are invalid</exception>
        Value Call(string name, IReadOnlyList<Value> args);
    }

    /// <summary>
    /// Simple implementation of IEnvironment using dictionaries.
    /// Provides basic variable and function storage, equivalent to C++ TestEnvironment.
    /// </summary>
    public class SimpleEnvironment : IEnvironment
    {
        private readonly Dictionary<string, Value> _variables = new();
        private readonly Dictionary<string, Func<IReadOnlyList<Value>, Value>> _functions = new();

        /// <summary>
        /// Sets a variable value
        /// </summary>
        /// <param name="name">Variable name</param>
        /// <param name="value">Variable value</param>
        public void SetVariable(string name, Value value)
        {
            _variables[name] = value;
        }

        /// <summary>
        /// Sets a function implementation
        /// </summary>
        /// <param name="name">Function name</param>
        /// <param name="function">Function implementation</param>
        public void SetFunction(string name, Func<IReadOnlyList<Value>, Value> function)
        {
            _functions[name] = function;
        }

        /// <summary>
        /// Gets the value of a variable
        /// </summary>
        public Value Get(string name)
        {
            if (_variables.TryGetValue(name, out Value value))
                return value;
            
            throw new ExpressionException($"Variable not defined: {name}");
        }

        /// <summary>
        /// Calls a function with the given arguments
        /// </summary>
        public Value Call(string name, IReadOnlyList<Value> args)
        {
            if (_functions.TryGetValue(name, out var function))
                return function(args);

            throw new ExpressionException($"Function not defined: {name}");
        }
    }
}