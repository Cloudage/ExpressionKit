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
 * Exception types for expression parsing and evaluation errors
 */
public class ExpressionException extends Exception {
    
    public ExpressionException(String message) {
        super(message);
    }

    public ExpressionException(String message, Throwable cause) {
        super(message, cause);
    }

    // Specific exception types for different error conditions
    public static class ParseException extends ExpressionException {
        public ParseException(String message) {
            super(message);
        }
    }

    public static class EvaluationException extends ExpressionException {
        public EvaluationException(String message) {
            super(message);
        }
    }

    public static class TypeException extends ExpressionException {
        public TypeException(String message) {
            super(message);
        }
    }

    public static class DivisionByZeroException extends ExpressionException {
        public DivisionByZeroException() {
            super("Division by zero");
        }
    }

    public static class UnknownVariableException extends ExpressionException {
        public UnknownVariableException(String variableName) {
            super("Unknown variable: " + variableName);
        }
    }

    public static class UnknownFunctionException extends ExpressionException {
        public UnknownFunctionException(String functionName) {
            super("Unknown function: " + functionName);
        }
    }

    public static class DomainException extends ExpressionException {
        public DomainException(String message) {
            super("Domain error: " + message);
        }
    }

    public static class ArityException extends ExpressionException {
        public ArityException(String message) {
            super("Arity error: " + message);
        }
    }
}