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
    /// Main expression toolkit class for parsing and evaluating expressions.
    /// 
    /// Expression provides a complete expression evaluation system with support for:
    /// - Arithmetic operations (+, -, *, /)
    /// - Comparison operations (==, !=, &lt;, &gt;, &lt;=, &gt;=)
    /// - Logical operations (&amp;&amp;, ||, !, xor)
    /// - Variables and functions via Environment interface
    /// - Expression compilation and caching for better performance
    /// 
    /// Usage examples:
    /// <code>
    /// // Simple evaluation without variables
    /// var result = Expression.Eval("2 + 3 * 4"); // Returns 14.0
    /// 
    /// // With environment for variables and functions
    /// var environment = new SimpleEnvironment();
    /// environment.SetVariable("x", 5.0);
    /// var result2 = Expression.Eval("x + sqrt(9)", environment);
    /// 
    /// // Compile once, execute multiple times
    /// var compiled = Expression.Parse("health > maxHealth * 0.5");
    /// for (int frame = 0; frame < 100; frame++) {
    ///     var alive = compiled.Evaluate(environment);
    ///     // ... game logic
    /// }
    /// </code>
    /// </summary>
    public static class Expression
    {
        /// <summary>
        /// Evaluate an expression string directly
        /// </summary>
        /// <param name="expression">The expression string to evaluate</param>
        /// <param name="environment">Optional environment for variable and function resolution</param>
        /// <returns>The evaluation result</returns>
        /// <exception cref="ExpressionException">If parsing fails or evaluation encounters an error</exception>
        /// 
        /// <remarks>
        /// This method parses and evaluates the expression in one call. For
        /// expressions that will be evaluated multiple times, consider using
        /// Parse() and Evaluate() for better performance.
        /// 
        /// Supported syntax:
        /// - Numbers: 42, 3.14, -2.5
        /// - Booleans: true, false
        /// - Arithmetic: +, -, *, /
        /// - Comparison: ==, !=, &lt;, &gt;, &lt;=, &gt;=
        /// - Logical: &amp;&amp;, ||, !, and, or, not, xor
        /// - Parentheses for grouping: (expr)
        /// - Variables: x, pos.x, player_health
        /// - Functions: max(a, b), sqrt(x)
        /// </remarks>
        public static Value Eval(string expression, IEnvironment? environment = null)
        {
            return Parse(expression).Evaluate(environment);
        }

        /// <summary>
        /// Evaluate an expression string directly with token collection
        /// </summary>
        /// <param name="expression">The expression string to evaluate</param>
        /// <param name="environment">Optional environment for variable and function resolution</param>
        /// <param name="tokens">List to collect tokens for syntax highlighting</param>
        /// <returns>The evaluation result</returns>
        /// <exception cref="ExpressionException">If parsing fails or evaluation encounters an error</exception>
        /// 
        /// <remarks>
        /// This method parses and evaluates the expression while collecting
        /// tokens that can be used for syntax highlighting or other analysis.
        /// </remarks>
        public static Value Eval(string expression, IEnvironment? environment, List<Token> tokens)
        {
            return Parse(expression, tokens).Evaluate(environment);
        }

        /// <summary>
        /// Parse an expression string into an Abstract Syntax Tree
        /// </summary>
        /// <param name="expression">The expression string to parse</param>
        /// <returns>The root AST node</returns>
        /// <exception cref="ExpressionException">If the expression syntax is invalid</exception>
        /// 
        /// <remarks>
        /// This method is for advanced usage where you want to parse once and evaluate
        /// multiple times for better performance. Most users should use Eval() for
        /// direct evaluation.
        /// </remarks>
        public static CompiledExpression Parse(string expression)
        {
            var parser = new Parser(expression);
            var ast = parser.Parse();
            return new CompiledExpression(ast);
        }

        /// <summary>
        /// Parse an expression string into an Abstract Syntax Tree with token collection
        /// </summary>
        /// <param name="expression">The expression string to parse</param>
        /// <param name="tokens">List to collect tokens for syntax highlighting</param>
        /// <returns>The root AST node</returns>
        /// <exception cref="ExpressionException">If the expression syntax is invalid</exception>
        /// 
        /// <remarks>
        /// This method parses the expression while collecting tokens
        /// that can be used for syntax highlighting or other analysis.
        /// </remarks>
        public static CompiledExpression Parse(string expression, List<Token> tokens)
        {
            var parser = new Parser(expression, tokens);
            var ast = parser.Parse();
            return new CompiledExpression(ast);
        }
    }

    /// <summary>
    /// Represents a compiled expression that can be evaluated multiple times efficiently
    /// </summary>
    public sealed class CompiledExpression
    {
        private readonly ASTNode _root;

        internal CompiledExpression(ASTNode root)
        {
            _root = root;
        }

        /// <summary>
        /// Evaluate this compiled expression
        /// </summary>
        /// <param name="environment">Optional environment for variable and function resolution</param>
        /// <returns>The evaluation result</returns>
        /// <exception cref="ExpressionException">If evaluation encounters an error</exception>
        public Value Evaluate(IEnvironment? environment = null)
        {
            return _root.Evaluate(environment);
        }
    }
}