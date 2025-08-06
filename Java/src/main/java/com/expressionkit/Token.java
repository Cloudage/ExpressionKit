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
 * Token structure for syntax highlighting and analysis
 *
 * Contains information about a single token identified during parsing,
 * including its type, position in the source text, and the actual text.
 */
public final class Token {
    private final TokenType type;
    private final int start;
    private final int length;
    private final String text;

    public Token(TokenType type, int start, int length, String text) {
        this.type = type;
        this.start = start;
        this.length = length;
        this.text = text;
    }

    public TokenType getType() {
        return type;
    }

    public int getStart() {
        return start;
    }

    public int getLength() {
        return length;
    }

    public String getText() {
        return text;
    }

    @Override
    public String toString() {
        return String.format("Token{type=%s, start=%d, length=%d, text='%s'}", 
                           type, start, length, text);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Token token = (Token) obj;
        return start == token.start &&
               length == token.length &&
               type == token.type &&
               text.equals(token.text);
    }

    @Override
    public int hashCode() {
        return java.util.Objects.hash(type, start, length, text);
    }
}