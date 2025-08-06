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
using System.Globalization;

namespace ExpressionKit
{
    /// <summary>
    /// Enumeration of all supported operators.
    /// This enum defines all arithmetic, comparison, and logical operators
    /// supported by the expression system. Operators are grouped by category
    /// for easier understanding and implementation.
    /// </summary>
    internal enum OperatorType
    {
        Add, Sub, Mul, Div,                  // Arithmetic operators: +, -, *, /
        Eq, Ne, Gt, Lt, Ge, Le,              // Comparison operators: ==, !=, >, <, >=, <=
        In,                                  // Inclusion operator: in
        And, Or, Xor, Not,                   // Logical operators: &&, ||, xor, !
        Ternary                              // Ternary operator: ? :
    }

    /// <summary>
    /// Abstract base class for all AST nodes.
    /// Each element in an expression (numbers, variables, operators, functions) is represented
    /// as an AST node that can be evaluated against an environment.
    /// </summary>
    internal abstract class ASTNode
    {
        /// <summary>
        /// Evaluate this node and return its value
        /// </summary>
        /// <param name="environment">Environment for variable and function resolution (can be null for constants)</param>
        /// <returns>The computed value of this node</returns>
        /// <exception cref="ExpressionException">If evaluation fails</exception>
        public abstract Value Evaluate(IEnvironment? environment);
    }

    /// <summary>
    /// AST node representing a numeric literal.
    /// This node holds a constant numeric value and returns it during evaluation.
    /// Examples: 42, 3.14, -2.5
    /// </summary>
    internal sealed class NumberNode : ASTNode
    {
        private readonly double _value;

        public NumberNode(double value)
        {
            _value = value;
        }

        public override Value Evaluate(IEnvironment? environment) => new(_value);
    }

    /// <summary>
    /// AST node representing a boolean literal.
    /// This node holds a constant boolean value and returns it during evaluation.
    /// Examples: true, false
    /// </summary>
    internal sealed class BooleanNode : ASTNode
    {
        private readonly bool _value;

        public BooleanNode(bool value)
        {
            _value = value;
        }

        public override Value Evaluate(IEnvironment? environment) => new(_value);
    }

    /// <summary>
    /// AST node representing a string literal.
    /// This node holds a constant string value and returns it during evaluation.
    /// Examples: "hello", "world", "Hello, \"World\"!"
    /// </summary>
    internal sealed class StringNode : ASTNode
    {
        private readonly string _value;

        public StringNode(string value)
        {
            _value = value;
        }

        public override Value Evaluate(IEnvironment? environment) => new(_value);
    }

    /// <summary>
    /// AST node representing a variable reference.
    /// This node stores a variable name and delegates to the IEnvironment during
    /// evaluation to resolve the variable's current value.
    /// Examples: x, pos.x, player_health
    /// </summary>
    internal sealed class VariableNode : ASTNode
    {
        private readonly string _name;

        public VariableNode(string name)
        {
            _name = name;
        }

        public override Value Evaluate(IEnvironment? environment)
        {
            if (environment == null)
                throw new ExpressionException("Variable access requires IEnvironment");
            
            return environment.Get(_name);
        }
    }

    /// <summary>
    /// AST node representing binary operations (operations with two operands).
    /// This node handles all binary operators including arithmetic, comparison,
    /// and logical operations. It evaluates both operands and applies the
    /// specified operator according to type compatibility rules.
    /// </summary>
    internal sealed class BinaryOpNode : ASTNode
    {
        private readonly ASTNode _left;
        private readonly ASTNode _right;
        private readonly OperatorType _op;

        public BinaryOpNode(ASTNode left, OperatorType op, ASTNode right)
        {
            _left = left;
            _right = right;
            _op = op;
        }

        public override Value Evaluate(IEnvironment? environment)
        {
            Value lhs = _left.Evaluate(environment);
            Value rhs = _right.Evaluate(environment);

            // Boolean logical operations - allow any types and convert to boolean
            if (_op == OperatorType.And || _op == OperatorType.Or || _op == OperatorType.Xor)
            {
                bool a = lhs.AsBoolean();
                bool b = rhs.AsBoolean();
                return _op switch
                {
                    OperatorType.And => new Value(a && b),
                    OperatorType.Or => new Value(a || b),
                    OperatorType.Xor => new Value(a != b),
                    _ => throw new ExpressionException("Unsupported logical operator")
                };
            }

            // String operations
            if (lhs.IsString || rhs.IsString)
            {
                return _op switch
                {
                    OperatorType.Add => new Value(lhs.AsString() + rhs.AsString()),
                    OperatorType.Eq when lhs.IsString && rhs.IsString => new Value(lhs.AsString() == rhs.AsString()),
                    OperatorType.Eq => new Value(false),
                    OperatorType.Ne when lhs.IsString && rhs.IsString => new Value(lhs.AsString() != rhs.AsString()),
                    OperatorType.Ne => new Value(true),
                    OperatorType.Gt when lhs.IsString && rhs.IsString => new Value(string.Compare(lhs.AsString(), rhs.AsString(), StringComparison.Ordinal) > 0),
                    OperatorType.Lt when lhs.IsString && rhs.IsString => new Value(string.Compare(lhs.AsString(), rhs.AsString(), StringComparison.Ordinal) < 0),
                    OperatorType.Ge when lhs.IsString && rhs.IsString => new Value(string.Compare(lhs.AsString(), rhs.AsString(), StringComparison.Ordinal) >= 0),
                    OperatorType.Le when lhs.IsString && rhs.IsString => new Value(string.Compare(lhs.AsString(), rhs.AsString(), StringComparison.Ordinal) <= 0),
                    OperatorType.In when lhs.IsString && rhs.IsString => new Value(rhs.AsString().Contains(lhs.AsString())),
                    OperatorType.Gt or OperatorType.Lt or OperatorType.Ge or OperatorType.Le => throw new ExpressionException("String comparison operators require two string operands"),
                    OperatorType.In => throw new ExpressionException("in operator requires two string operands"),
                    _ => throw new ExpressionException("Unsupported string operator")
                };
            }

            // Numeric operations
            if (lhs.IsNumber && rhs.IsNumber)
            {
                double a = lhs.AsNumber();
                double b = rhs.AsNumber();
                return _op switch
                {
                    OperatorType.Add => new Value(a + b),
                    OperatorType.Sub => new Value(a - b),
                    OperatorType.Mul => new Value(a * b),
                    OperatorType.Div => b == 0 ? throw new ExpressionException("Division by zero") : new Value(a / b),
                    OperatorType.Gt => new Value(a > b),
                    OperatorType.Lt => new Value(a < b),
                    OperatorType.Ge => new Value(a >= b),
                    OperatorType.Le => new Value(a <= b),
                    OperatorType.Eq => new Value(Math.Abs(a - b) < double.Epsilon),
                    OperatorType.Ne => new Value(Math.Abs(a - b) >= double.Epsilon),
                    _ => throw new ExpressionException("Unsupported numeric operator")
                };
            }

            // Strict boolean operations (equality/inequality) require both to be boolean
            if (lhs.IsBoolean && rhs.IsBoolean)
            {
                bool a = lhs.AsBoolean();
                bool b = rhs.AsBoolean();
                return _op switch
                {
                    OperatorType.Eq => new Value(a == b),
                    OperatorType.Ne => new Value(a != b),
                    _ => throw new ExpressionException("Unsupported boolean operator")
                };
            }

            throw new ExpressionException("Unsupported operand types");
        }
    }

    /// <summary>
    /// AST node representing unary operations (operations with one operand).
    /// This node handles unary operators that operate on a single value:
    /// - Logical NOT: !condition, not flag
    /// - Arithmetic negation: -number, -expression
    /// </summary>
    internal sealed class UnaryOpNode : ASTNode
    {
        private readonly ASTNode _operand;
        private readonly OperatorType _op;

        public UnaryOpNode(OperatorType op, ASTNode operand)
        {
            _operand = operand;
            _op = op;
        }

        public override Value Evaluate(IEnvironment? environment)
        {
            Value val = _operand.Evaluate(environment);

            return _op switch
            {
                OperatorType.Not => new Value(!val.AsBoolean()),
                OperatorType.Sub when val.IsNumber => new Value(-val.AsNumber()),
                OperatorType.Sub => throw new ExpressionException("Negation can only be used with numbers"),
                _ => throw new ExpressionException("Unsupported unary operator")
            };
        }
    }

    /// <summary>
    /// AST node representing ternary operations (condition ? true_expr : false_expr).
    /// This node handles the ternary conditional operator (? :).
    /// The condition is evaluated using AsBoolean() to support any value type.
    /// </summary>
    internal sealed class TernaryOpNode : ASTNode
    {
        private readonly ASTNode _condition;
        private readonly ASTNode _trueExpr;
        private readonly ASTNode _falseExpr;
        private readonly OperatorType _op;

        public TernaryOpNode(ASTNode condition, ASTNode trueExpr, ASTNode falseExpr, OperatorType op)
        {
            _condition = condition;
            _trueExpr = trueExpr;
            _falseExpr = falseExpr;
            _op = op;
        }

        public override Value Evaluate(IEnvironment? environment)
        {
            return _op switch
            {
                OperatorType.Ternary => _condition.Evaluate(environment).AsBoolean() 
                    ? _trueExpr.Evaluate(environment) 
                    : _falseExpr.Evaluate(environment),
                _ => throw new ExpressionException("Unsupported ternary operator")
            };
        }
    }

    /// <summary>
    /// AST node representing function calls.
    /// This node stores a function name and a list of argument expressions.
    /// During evaluation, it evaluates all arguments and delegates to the
    /// IEnvironment to perform the actual function call.
    /// </summary>
    internal sealed class FunctionCallNode : ASTNode
    {
        private readonly string _name;
        private readonly List<ASTNode> _args;

        public FunctionCallNode(string name, List<ASTNode> args)
        {
            _name = name;
            _args = args;
        }

        public override Value Evaluate(IEnvironment? environment)
        {
            var evaluatedArgs = new List<Value>(_args.Count);
            foreach (var arg in _args)
            {
                evaluatedArgs.Add(arg.Evaluate(environment));
            }

            // First try standard mathematical functions (works without environment)
            if (CallStandardFunctions(_name, evaluatedArgs, out Value standardResult))
            {
                return standardResult;
            }

            // If not a standard function, require environment
            if (environment == null)
                throw new ExpressionException("Function call requires IEnvironment");

            return environment.Call(_name, evaluatedArgs);
        }

        /// <summary>
        /// Call standard mathematical functions.
        /// This function handles built-in mathematical functions equivalent to C++ implementation.
        /// </summary>
        private static bool CallStandardFunctions(string functionName, IReadOnlyList<Value> args, out Value result)
        {
            result = new Value(0.0);

            try
            {
                // Two-argument functions
                if (functionName == "min" && args.Count == 2)
                {
                    if (!args[0].IsNumber || !args[1].IsNumber) return false;
                    result = new Value(Math.Min(args[0].AsNumber(), args[1].AsNumber()));
                    return true;
                }

                if (functionName == "max" && args.Count == 2)
                {
                    if (!args[0].IsNumber || !args[1].IsNumber) return false;
                    result = new Value(Math.Max(args[0].AsNumber(), args[1].AsNumber()));
                    return true;
                }

                if (functionName == "pow" && args.Count == 2)
                {
                    if (!args[0].IsNumber || !args[1].IsNumber) return false;
                    result = new Value(Math.Pow(args[0].AsNumber(), args[1].AsNumber()));
                    return true;
                }

                // Single-argument functions
                if (args.Count == 1 && args[0].IsNumber)
                {
                    double x = args[0].AsNumber();

                    switch (functionName)
                    {
                        case "sqrt":
                            if (x < 0) return false; // Domain error
                            result = new Value(Math.Sqrt(x));
                            return true;

                        case "sin":
                            result = new Value(Math.Sin(x));
                            return true;

                        case "cos":
                            result = new Value(Math.Cos(x));
                            return true;

                        case "tan":
                            result = new Value(Math.Tan(x));
                            return true;

                        case "abs":
                            result = new Value(Math.Abs(x));
                            return true;

                        case "log":
                            if (x <= 0) return false; // Domain error
                            result = new Value(Math.Log(x));
                            return true;

                        case "exp":
                            result = new Value(Math.Exp(x));
                            return true;

                        case "floor":
                            result = new Value(Math.Floor(x));
                            return true;

                        case "ceil":
                            result = new Value(Math.Ceiling(x));
                            return true;

                        case "round":
                            result = new Value(Math.Round(x));
                            return true;
                    }
                }

                return false; // Function not found or invalid arguments
            }
            catch
            {
                return false; // Error occurred
            }
        }
    }
}