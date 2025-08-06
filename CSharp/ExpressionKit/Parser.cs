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
    /// Recursive descent parser for expression strings.
    /// This class implements a complete expression parser using the recursive
    /// descent parsing technique. It supports operator precedence, associativity,
    /// and proper error reporting.
    /// 
    /// Grammar (in order of precedence, highest to lowest):
    /// - Primary: numbers, booleans, variables, function calls, parentheses
    /// - Unary: !, not, - (unary minus)
    /// - Multiplicative: *, /
    /// - Additive: +, -
    /// - Relational: <, >, <=, >=
    /// - Equality: ==, !=
    /// - Logical XOR: xor
    /// - Logical AND: &&, and
    /// - Logical OR: ||, or
    /// - Ternary conditional: ? :
    /// 
    /// The parser is designed to be used once per expression string and
    /// produces an AST that can be evaluated multiple times efficiently.
    /// </summary>
    internal sealed class Parser
    {
        private readonly string _expr;
        private int _pos = 0;
        private readonly List<Token>? _tokens;

        public Parser(string expression)
        {
            _expr = expression;
        }

        public Parser(string expression, List<Token> tokens)
        {
            _expr = expression;
            _tokens = tokens;
        }

        /// <summary>
        /// Add token to collection if token collection is enabled
        /// </summary>
        private void AddToken(TokenType type, int start, int length, string text)
        {
            _tokens?.Add(new Token(type, start, length, text));
        }

        /// <summary>
        /// Add token to collection using substring from expression
        /// </summary>
        private void AddToken(TokenType type, int start, int length)
        {
            if (_tokens != null && start + length <= _expr.Length)
            {
                AddToken(type, start, length, _expr.Substring(start, length));
            }
        }

        /// <summary>
        /// Skip whitespace and add token if collecting tokens
        /// </summary>
        private void SkipWhitespace()
        {
            int start = _pos;
            while (_pos < _expr.Length && char.IsWhiteSpace(_expr[_pos]))
                _pos++;

            if (_tokens != null && _pos > start)
            {
                AddToken(TokenType.Whitespace, start, _pos - start);
            }
        }

        /// <summary>
        /// Try to match and consume a string literal
        /// </summary>
        private bool Match(string str)
        {
            SkipWhitespace();
            if (_pos + str.Length <= _expr.Length && _expr.Substring(_pos, str.Length) == str)
            {
                AddToken(TokenType.Operator, _pos, str.Length, str);
                _pos += str.Length;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Try to match and consume a single character
        /// </summary>
        private bool Match(char c)
        {
            SkipWhitespace();
            if (_pos < _expr.Length && _expr[_pos] == c)
            {
                TokenType type = c switch
                {
                    '(' or ')' => TokenType.Parenthesis,
                    ',' => TokenType.Comma,
                    _ => TokenType.Operator
                };
                AddToken(type, _pos, 1, c.ToString());
                _pos++;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Peek at the current character without consuming it
        /// </summary>
        private char Peek()
        {
            SkipWhitespace();
            return _pos >= _expr.Length ? '\0' : _expr[_pos];
        }

        /// <summary>
        /// Peek at a substring without consuming it
        /// </summary>
        private string PeekString(int length)
        {
            SkipWhitespace();
            if (_pos + length > _expr.Length) return string.Empty;
            return _expr.Substring(_pos, length);
        }

        /// <summary>
        /// Consume and return the current character
        /// </summary>
        private char Consume()
        {
            SkipWhitespace();
            if (_pos >= _expr.Length)
                throw new ExpressionException("Unexpected end of expression");

            char c = _expr[_pos];
            AddToken(TokenType.Operator, _pos, 1, c.ToString());
            _pos++;
            return c;
        }

        /// <summary>
        /// Parse the expression and return the root AST node
        /// </summary>
        public ASTNode Parse()
        {
            _pos = 0;
            var result = ParseTernaryExpression();
            SkipWhitespace();
            if (_pos < _expr.Length)
                throw new ExpressionException("Incomplete expression parsing");
            return result;
        }

        /// <summary>
        /// Parse ternary expressions (lowest precedence)
        /// </summary>
        private ASTNode ParseTernaryExpression()
        {
            var condition = ParseOrExpression();
            if (Match("?"))
            {
                var trueExpr = ParseTernaryExpression(); // Right associative
                if (!Match(":"))
                    throw new ExpressionException("Expected ':' in ternary expression");
                var falseExpr = ParseTernaryExpression(); // Right associative
                return new TernaryOpNode(condition, trueExpr, falseExpr, OperatorType.Ternary);
            }
            return condition;
        }

        /// <summary>
        /// Parse logical OR expressions
        /// </summary>
        private ASTNode ParseOrExpression()
        {
            var left = ParseAndExpression();
            while (Match("||") || Match("or"))
            {
                var right = ParseAndExpression();
                left = new BinaryOpNode(left, OperatorType.Or, right);
            }
            return left;
        }

        /// <summary>
        /// Parse logical AND expressions
        /// </summary>
        private ASTNode ParseAndExpression()
        {
            var left = ParseXorExpression();
            while (Match("&&") || Match("and"))
            {
                var right = ParseXorExpression();
                left = new BinaryOpNode(left, OperatorType.And, right);
            }
            return left;
        }

        /// <summary>
        /// Parse logical XOR expressions
        /// </summary>
        private ASTNode ParseXorExpression()
        {
            var left = ParseEqualityExpression();
            while (Match("xor"))
            {
                var right = ParseEqualityExpression();
                left = new BinaryOpNode(left, OperatorType.Xor, right);
            }
            return left;
        }

        /// <summary>
        /// Parse equality expressions
        /// </summary>
        private ASTNode ParseEqualityExpression()
        {
            var left = ParseRelationalExpression();
            while (true)
            {
                if (Match("=="))
                {
                    var right = ParseRelationalExpression();
                    left = new BinaryOpNode(left, OperatorType.Eq, right);
                }
                else if (Match("!="))
                {
                    var right = ParseRelationalExpression();
                    left = new BinaryOpNode(left, OperatorType.Ne, right);
                }
                else
                {
                    break;
                }
            }
            return left;
        }

        /// <summary>
        /// Parse relational expressions
        /// </summary>
        private ASTNode ParseRelationalExpression()
        {
            var left = ParseAdditiveExpression();
            while (true)
            {
                if (Match(">="))
                {
                    var right = ParseAdditiveExpression();
                    left = new BinaryOpNode(left, OperatorType.Ge, right);
                }
                else if (Match("<="))
                {
                    var right = ParseAdditiveExpression();
                    left = new BinaryOpNode(left, OperatorType.Le, right);
                }
                else if (Match(">"))
                {
                    var right = ParseAdditiveExpression();
                    left = new BinaryOpNode(left, OperatorType.Gt, right);
                }
                else if (Match("<"))
                {
                    var right = ParseAdditiveExpression();
                    left = new BinaryOpNode(left, OperatorType.Lt, right);
                }
                else if (Match("in"))
                {
                    var right = ParseAdditiveExpression();
                    left = new BinaryOpNode(left, OperatorType.In, right);
                }
                else
                {
                    break;
                }
            }
            return left;
        }

        /// <summary>
        /// Parse additive expressions
        /// </summary>
        private ASTNode ParseAdditiveExpression()
        {
            var left = ParseMultiplicativeExpression();
            while (Peek() == '+' || Peek() == '-')
            {
                char op = Consume();
                var right = ParseMultiplicativeExpression();
                OperatorType opType = op == '+' ? OperatorType.Add : OperatorType.Sub;
                left = new BinaryOpNode(left, opType, right);
            }
            return left;
        }

        /// <summary>
        /// Parse multiplicative expressions
        /// </summary>
        private ASTNode ParseMultiplicativeExpression()
        {
            var left = ParseUnaryExpression();
            while (Peek() == '*' || Peek() == '/')
            {
                char op = Consume();
                var right = ParseUnaryExpression();
                OperatorType opType = op == '*' ? OperatorType.Mul : OperatorType.Div;
                left = new BinaryOpNode(left, opType, right);
            }
            return left;
        }

        /// <summary>
        /// Parse unary expressions
        /// </summary>
        private ASTNode ParseUnaryExpression()
        {
            if (Match("!") || Match("not"))
            {
                var operand = ParseUnaryExpression();
                return new UnaryOpNode(OperatorType.Not, operand);
            }

            if (Match("-"))
            {
                var operand = ParseUnaryExpression();
                return new UnaryOpNode(OperatorType.Sub, operand);
            }

            return ParsePrimaryExpression();
        }

        /// <summary>
        /// Parse primary expressions (literals, variables, function calls, parentheses)
        /// </summary>
        private ASTNode ParsePrimaryExpression()
        {
            // Parenthesized expressions
            if (Match('('))
            {
                var expr = ParseTernaryExpression();
                if (!Match(')'))
                    throw new ExpressionException("Missing closing parenthesis");
                return expr;
            }

            // Numbers
            if (char.IsDigit(Peek()) || Peek() == '.')
            {
                int start = _pos;
                string num = string.Empty;
                while (_pos < _expr.Length && (char.IsDigit(_expr[_pos]) || _expr[_pos] == '.'))
                {
                    num += _expr[_pos++];
                }
                AddToken(TokenType.Number, start, _pos - start, num);
                
                if (!double.TryParse(num, NumberStyles.Float, CultureInfo.InvariantCulture, out double value))
                    throw new ExpressionException($"Invalid number format: {num}");
                    
                return new NumberNode(value);
            }

            // String literals
            if (Peek() == '"')
            {
                int start = _pos;
                _pos++; // Skip opening quote
                string str = string.Empty;

                while (_pos < _expr.Length && _expr[_pos] != '"')
                {
                    if (_expr[_pos] == '\\' && _pos + 1 < _expr.Length)
                    {
                        _pos++; // Skip backslash
                        str += _expr[_pos] switch
                        {
                            'n' => '\n',
                            't' => '\t',
                            'r' => '\r',
                            '\\' => '\\',
                            '"' => '"',
                            var c => "\\" + c // Unknown escape sequence, keep original
                        };
                        _pos++;
                    }
                    else
                    {
                        str += _expr[_pos++];
                    }
                }

                if (_pos >= _expr.Length)
                    throw new ExpressionException("Unterminated string literal");

                _pos++; // Skip closing quote
                AddToken(TokenType.String, start, _pos - start, "\"" + str + "\"");
                return new StringNode(str);
            }

            // Identifiers (variables, functions, booleans)
            if (char.IsLetter(Peek()))
            {
                int start = _pos;
                string ident = string.Empty;
                while (_pos < _expr.Length && (char.IsLetterOrDigit(_expr[_pos]) || _expr[_pos] == '.' || _expr[_pos] == '_'))
                {
                    ident += _expr[_pos++];
                }

                // Function calls
                if (Match('('))
                {
                    var args = new List<ASTNode>();
                    if (!Match(')'))
                    {
                        do
                        {
                            args.Add(ParseTernaryExpression());
                        } while (Match(','));
                        
                        if (!Match(')'))
                            throw new ExpressionException("Missing closing parenthesis in function call");
                    }
                    AddToken(TokenType.Identifier, start, ident.Length, ident);
                    return new FunctionCallNode(ident, args);
                }

                // Boolean literals
                if (ident == "true")
                {
                    AddToken(TokenType.Boolean, start, ident.Length, ident);
                    return new BooleanNode(true);
                }
                if (ident == "false")
                {
                    AddToken(TokenType.Boolean, start, ident.Length, ident);
                    return new BooleanNode(false);
                }

                // Variables
                AddToken(TokenType.Identifier, start, ident.Length, ident);
                return new VariableNode(ident);
            }

            throw new ExpressionException("Unrecognized expression");
        }
    }
}