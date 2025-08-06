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

/**
 * Token types for syntax highlighting and analysis
 *
 * This enumeration defines all possible token types that can be identified
 * during expression parsing, useful for syntax highlighting and other
 * analysis features.
 */
public enum TokenType {
    NUMBER(0),       // Numeric literals: 42, 3.14, -2.5
    BOOLEAN(1),      // Boolean literals: true, false
    STRING(2),       // String literals: "hello", "world"
    IDENTIFIER(3),   // Variables and function names: x, pos.x, sqrt
    OPERATOR(4),     // Operators: +, -, *, /, ==, !=, &&, ||, etc.
    PARENTHESIS(5),  // Parentheses: (, )
    COMMA(6),        // Function argument separator: ,
    WHITESPACE(7),   // Spaces, tabs (optional for highlighting)
    UNKNOWN(8);      // Unrecognized tokens

    private final int value;

    TokenType(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }

    public static TokenType fromValue(int value) {
        for (TokenType type : values()) {
            if (type.value == value) {
                return type;
            }
        }
        return UNKNOWN;
    }
}