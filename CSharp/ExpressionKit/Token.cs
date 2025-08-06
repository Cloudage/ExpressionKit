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

namespace ExpressionKit
{
    /// <summary>
    /// Token type for syntax highlighting and analysis.
    /// This enumeration defines all possible token types that can be identified
    /// during expression parsing, useful for syntax highlighting and other analysis features.
    /// </summary>
    public enum TokenType
    {
        /// <summary>Numeric literals: 42, 3.14, -2.5</summary>
        Number = 0,
        
        /// <summary>Boolean literals: true, false</summary>
        Boolean = 1,
        
        /// <summary>String literals: "hello", "world"</summary>
        String = 2,
        
        /// <summary>Variables and function names: x, pos.x, sqrt</summary>
        Identifier = 3,
        
        /// <summary>Operators: +, -, *, /, ==, !=, &&, ||, etc.</summary>
        Operator = 4,
        
        /// <summary>Parentheses: (, )</summary>
        Parenthesis = 5,
        
        /// <summary>Function argument separator: ,</summary>
        Comma = 6,
        
        /// <summary>Spaces, tabs (optional for highlighting)</summary>
        Whitespace = 7,
        
        /// <summary>Unrecognized tokens</summary>
        Unknown = 8
    }

    /// <summary>
    /// Token structure for syntax highlighting and analysis.
    /// Contains information about a single token identified during parsing,
    /// including its type, position in the source text, and the actual text.
    /// </summary>
    public readonly struct Token
    {
        /// <summary>Type of the token</summary>
        public TokenType Type { get; }
        
        /// <summary>Starting position in source text</summary>
        public int Start { get; }
        
        /// <summary>Length of the token</summary>
        public int Length { get; }
        
        /// <summary>The actual token text</summary>
        public string Text { get; }

        /// <summary>
        /// Creates a new Token
        /// </summary>
        /// <param name="type">Type of the token</param>
        /// <param name="start">Starting position in source text</param>
        /// <param name="length">Length of the token</param>
        /// <param name="text">The actual token text</param>
        public Token(TokenType type, int start, int length, string text)
        {
            Type = type;
            Start = start;
            Length = length;
            Text = text;
        }

        /// <summary>
        /// Returns a string representation of this token
        /// </summary>
        public override string ToString()
        {
            return $"Token({Type}, {Start}:{Length}, \"{Text}\")";
        }
    }
}