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
 * NOTE: This code is a 1:1 translation from the C++ test.cpp implementation
 * to C# XUnit tests, maintaining the same test cases and behavior while using
 * C#-idiomatic patterns and conventions.
 */

using System;
using System.Collections.Generic;
using Xunit;
using ExpressionKit;

namespace ExpressionKit.Tests
{
    /// <summary>
    /// Test environment implementation equivalent to C++ TestEnvironment
    /// </summary>
    public class TestEnvironment : IEnvironment
    {
        private readonly Dictionary<string, Value> _variables = new();

        public Value Get(string name)
        {
            if (_variables.TryGetValue(name, out Value value))
                return value;
            
            throw new ExpressionException($"Variable not defined: {name}");
        }

        public void Set(string name, Value value)
        {
            _variables[name] = value;
        }

        public Value Call(string name, IReadOnlyList<Value> args)
        {
            if (name == "add")
            {
                if (args.Count != 2 || !args[0].IsNumber || !args[1].IsNumber)
                    throw new ExpressionException("add function requires two numeric parameters");
                return new Value(args[0].AsNumber() + args[1].AsNumber());
            }
            
            throw new ExpressionException($"Function not defined: {name}");
        }
    }

    /// <summary>
    /// 1:1 translation of C++ ExpressionKit tests to XUnit
    /// </summary>
    public class ExpressionKitTests
    {
        [Fact]
        public void NumberExpression()
        {
            var result = Expression.Eval("1 + 2 * 3", null);
            Assert.Equal(7.0, result.AsNumber(), 5);
        }

        [Fact]
        public void BooleanExpression()
        {
            var result = Expression.Eval("true && false", null);
            Assert.Equal(false, result.AsBoolean());
        }

        [Fact]
        public void VariableExpression()
        {
            var environment = new TestEnvironment();
            environment.Set("x", new Value(5.0));

            var result = Expression.Eval("x + 3", environment);
            Assert.Equal(8.0, result.AsNumber(), 5);
        }

        [Fact]
        public void FunctionCall()
        {
            var environment = new TestEnvironment();

            var result = Expression.Eval("add(2, 3)", environment);
            Assert.Equal(5.0, result.AsNumber(), 5);
        }

        [Fact]
        public void ParseError()
        {
            Assert.Throws<ExpressionException>(() => Expression.Eval("1 + * 3", null));
        }

        [Fact]
        public void DivisionByZero()
        {
            Assert.Throws<ExpressionException>(() => Expression.Eval("1 / 0", null));
        }

        [Fact]
        public void NewBooleanOperators()
        {
            // Test && (and)
            Assert.True(Expression.Eval("true && true", null).AsBoolean());
            Assert.False(Expression.Eval("true && false", null).AsBoolean());
            Assert.False(Expression.Eval("true and false", null).AsBoolean());

            // Test || (or)
            Assert.True(Expression.Eval("true || false", null).AsBoolean());
            Assert.False(Expression.Eval("false || false", null).AsBoolean());
            Assert.True(Expression.Eval("false or true", null).AsBoolean());

            // Test xor
            Assert.True(Expression.Eval("true xor false", null).AsBoolean());
            Assert.False(Expression.Eval("true xor true", null).AsBoolean());

            // Test ! (not)
            Assert.False(Expression.Eval("!true", null).AsBoolean());
            Assert.True(Expression.Eval("!false", null).AsBoolean());
            Assert.False(Expression.Eval("not true", null).AsBoolean());
        }

        [Fact]
        public void EqualityOperators()
        {
            // Test ==
            Assert.True(Expression.Eval("5 == 5", null).AsBoolean());
            Assert.False(Expression.Eval("5 == 3", null).AsBoolean());
            Assert.True(Expression.Eval("true == true", null).AsBoolean());
            Assert.False(Expression.Eval("true == false", null).AsBoolean());

            // Test !=
            Assert.True(Expression.Eval("5 != 3", null).AsBoolean());
            Assert.False(Expression.Eval("5 != 5", null).AsBoolean());
            Assert.True(Expression.Eval("true != false", null).AsBoolean());
        }

        [Fact]
        public void ExtendedComparisonOperators()
        {
            // Test >=
            Assert.True(Expression.Eval("5 >= 5", null).AsBoolean());
            Assert.True(Expression.Eval("5 >= 3", null).AsBoolean());
            Assert.False(Expression.Eval("3 >= 5", null).AsBoolean());

            // Test <=
            Assert.True(Expression.Eval("3 <= 5", null).AsBoolean());
            Assert.True(Expression.Eval("5 <= 5", null).AsBoolean());
            Assert.False(Expression.Eval("5 <= 3", null).AsBoolean());

            // Test >
            Assert.True(Expression.Eval("5 > 3", null).AsBoolean());
            Assert.False(Expression.Eval("3 > 5", null).AsBoolean());

            // Test <
            Assert.True(Expression.Eval("3 < 5", null).AsBoolean());
            Assert.False(Expression.Eval("5 < 3", null).AsBoolean());
        }

        [Fact]
        public void ComplexExpressions()
        {
            // Test complex boolean expressions
            Assert.True(Expression.Eval("(true && false) || (true && true)", null).AsBoolean());
            Assert.True(Expression.Eval("!false && (true || false)", null).AsBoolean());

            // Test mixed numeric and boolean operations
            Assert.True(Expression.Eval("(5 > 3) && (2 + 3 == 5)", null).AsBoolean());
            Assert.True(Expression.Eval("(10 / 2 >= 5) || (3 * 2 != 6)", null).AsBoolean());

            // Test operator precedence
            Assert.True(Expression.Eval("2 + 3 * 4 == 14", null).AsBoolean());
            Assert.True(Expression.Eval("true || false && false", null).AsBoolean()); // || has lower precedence than &&
        }

        [Fact]
        public void UnaryOperators()
        {
            // Test negative
            Assert.Equal(-5.0, Expression.Eval("-5", null).AsNumber(), 5);
            Assert.Equal(-5.0, Expression.Eval("-(2 + 3)", null).AsNumber(), 5);

            // Test NOT
            Assert.False(Expression.Eval("!(5 > 3)", null).AsBoolean());
            Assert.True(Expression.Eval("not (2 == 3)", null).AsBoolean());
        }

        [Fact]
        public void ParenthesesAndComplexArithmetic()
        {
            // Basic parentheses
            Assert.Equal(9.0, Expression.Eval("(1 + 2) * 3", null).AsNumber(), 5);
            Assert.Equal(7.0, Expression.Eval("1 + (2 * 3)", null).AsNumber(), 5);

            // Nested parentheses
            Assert.Equal(5.0, Expression.Eval("((2 + 3) * (4 - 1)) / 3", null).AsNumber(), 5);
            Assert.Equal(10.0, Expression.Eval("(10 - (3 + 2)) * 2", null).AsNumber(), 5);

            // Complex mathematical expressions
            Assert.Equal(4.333333, Expression.Eval("(5 * 2 + 3) / (4 - 1)", null).AsNumber(), 0.001);
            Assert.Equal(10.0, Expression.Eval("2 * (3 + 4) - (8 / 2)", null).AsNumber(), 5);

            // Parentheses with negation
            Assert.Equal(-20.0, Expression.Eval("-(2 + 3) * 4", null).AsNumber(), 5);
            Assert.Equal(-4.0, Expression.Eval("(-5 + 3) * 2", null).AsNumber(), 5);
        }

        [Fact]
        public void VariablesInComplexExpressions()
        {
            var environment = new TestEnvironment();

            // Set test variables
            environment.Set("x", new Value(10.0));
            environment.Set("y", new Value(5.0));
            environment.Set("z", new Value(2.0));
            environment.Set("isActive", new Value(true));
            environment.Set("isComplete", new Value(false));

            // Basic variable operations
            Assert.Equal(15.0, Expression.Eval("x + y", environment).AsNumber(), 5);
            Assert.Equal(25.0, Expression.Eval("x * y / z", environment).AsNumber(), 5);

            // Parentheses with variables
            Assert.Equal(30.0, Expression.Eval("(x + y) * z", environment).AsNumber(), 5);
            Assert.Equal(3.333333, Expression.Eval("x / (y - z)", environment).AsNumber(), 0.001);

            // Mixed numbers and variables
            Assert.Equal(35.0, Expression.Eval("x + 5 * y", environment).AsNumber(), 5);
            Assert.Equal(1.0, Expression.Eval("(x - 3) / (y + 2)", environment).AsNumber(), 5);

            // Boolean variable operations
            Assert.True(Expression.Eval("isActive && !isComplete", environment).AsBoolean());
            Assert.True(Expression.Eval("isActive || isComplete", environment).AsBoolean());

            // Mixed numeric comparison and boolean variables
            Assert.True(Expression.Eval("(x > y) && isActive", environment).AsBoolean());
            Assert.True(Expression.Eval("(x == 10) and !isComplete", environment).AsBoolean());
        }

        [Fact]
        public void RealWorldScenarios()
        {
            var environment = new TestEnvironment();

            // Geometric calculation scenario
            environment.Set("radius", new Value(5.0));
            environment.Set("pi", new Value(3.14159));

            // Game state scenario
            environment.Set("health", new Value(75.0));
            environment.Set("maxHealth", new Value(100.0));
            environment.Set("hasShield", new Value(true));
            environment.Set("level", new Value(5.0));

            // Business logic scenario
            environment.Set("price", new Value(99.99));
            environment.Set("discount", new Value(0.15));
            environment.Set("quantity", new Value(3.0));
            environment.Set("shipping", new Value(9.99));
            environment.Set("isPremium", new Value(true));

            // Circle area: π * r²
            Assert.Equal(78.539, Expression.Eval("pi * radius * radius", environment).AsNumber(), 0.01);

            // Player status evaluation
            Assert.True(Expression.Eval("health > maxHealth / 2", environment).AsBoolean());
            Assert.True(Expression.Eval("(health / maxHealth) >= 0.5 && hasShield", environment).AsBoolean());
            Assert.True(Expression.Eval("level >= 5 && (health > 50 || hasShield)", environment).AsBoolean());

            // Price calculations
            double discountedPrice = Expression.Eval("price * (1 - discount)", environment).AsNumber();
            Assert.Equal(84.9915, discountedPrice, 0.001);

            double totalBeforeShipping = Expression.Eval("price * (1 - discount) * quantity", environment).AsNumber();
            Assert.Equal(254.97, totalBeforeShipping, 0.01);

            // Free shipping evaluation
            Assert.True(Expression.Eval("isPremium || (quantity * price > 200)", environment).AsBoolean());
        }

        [Fact]
        public void StandardMathematicalFunctions()
        {
            // Test without environment (built-in functions)
            Assert.Equal(3.0, Expression.Eval("max(1, 3)", null).AsNumber(), 5);
            Assert.Equal(1.0, Expression.Eval("min(1, 3)", null).AsNumber(), 5);
            Assert.Equal(3.0, Expression.Eval("sqrt(9)", null).AsNumber(), 5);
            Assert.Equal(2.0, Expression.Eval("abs(-2)", null).AsNumber(), 5);
            Assert.Equal(8.0, Expression.Eval("pow(2, 3)", null).AsNumber(), 5);

            // Test mathematical constants/functions
            double sinResult = Expression.Eval("sin(0)", null).AsNumber();
            Assert.Equal(0.0, sinResult, 0.001);

            double cosResult = Expression.Eval("cos(0)", null).AsNumber();
            Assert.Equal(1.0, cosResult, 0.001);

            double floorResult = Expression.Eval("floor(3.7)", null).AsNumber();
            Assert.Equal(3.0, floorResult, 5);

            double ceilResult = Expression.Eval("ceil(3.2)", null).AsNumber();
            Assert.Equal(4.0, ceilResult, 5);
        }

        [Fact]
        public void StringOperations()
        {
            // String concatenation
            Assert.Equal("Hello World", Expression.Eval("\"Hello \" + \"World\"", null).AsString());

            // String comparison
            Assert.True(Expression.Eval("\"hello\" == \"hello\"", null).AsBoolean());
            Assert.False(Expression.Eval("\"hello\" == \"world\"", null).AsBoolean());
            Assert.True(Expression.Eval("\"hello\" != \"world\"", null).AsBoolean());

            // String contains (in operator)
            Assert.True(Expression.Eval("\"ell\" in \"hello\"", null).AsBoolean());
            Assert.False(Expression.Eval("\"xyz\" in \"hello\"", null).AsBoolean());
        }

        [Fact]
        public void TokenCollection()
        {
            var tokens = new List<Token>();
            var result = Expression.Eval("2 + 3 * 4", null, tokens);
            
            Assert.Equal(14.0, result.AsNumber(), 5);
            Assert.True(tokens.Count > 0);
            
            // Check that we collected some tokens
            bool hasNumber = false;
            bool hasOperator = false;
            foreach (var token in tokens)
            {
                if (token.Type == TokenType.Number) hasNumber = true;
                if (token.Type == TokenType.Operator) hasOperator = true;
            }
            
            Assert.True(hasNumber);
            Assert.True(hasOperator);
        }

        [Fact]
        public void CompiledExpressionReuse()
        {
            var environment = new TestEnvironment();
            environment.Set("x", new Value(10.0));

            // Parse once, evaluate multiple times
            var compiled = Expression.Parse("x * 2 + 5");
            
            // First evaluation
            var result1 = compiled.Evaluate(environment);
            Assert.Equal(25.0, result1.AsNumber(), 5);
            
            // Change variable and evaluate again
            environment.Set("x", new Value(15.0));
            var result2 = compiled.Evaluate(environment);
            Assert.Equal(35.0, result2.AsNumber(), 5);
        }
    }
}