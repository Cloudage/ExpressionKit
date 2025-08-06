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
 * Type-safe Value class that supports numbers, booleans, and strings
 * 
 * This is a 1:1 translation of the C++ Value struct, providing the same
 * type conversion and safety mechanisms.
 */
public final class Value {
    public enum Type {
        NUMBER(0),
        BOOLEAN(1),
        STRING(2);
        
        private final int value;
        
        Type(int value) {
            this.value = value;
        }
        
        public int getValue() {
            return value;
        }
    }

    private final Type type;
    private final double numberValue;
    private final boolean booleanValue;
    private final String stringValue;

    // Constructors
    public Value() {
        this.type = Type.NUMBER;
        this.numberValue = 0.0;
        this.booleanValue = false;
        this.stringValue = null;
    }

    public Value(double value) {
        this.type = Type.NUMBER;
        this.numberValue = value;
        this.booleanValue = false;
        this.stringValue = null;
    }

    public Value(float value) {
        this((double) value);
    }

    public Value(int value) {
        this((double) value);
    }

    public Value(long value) {
        this((double) value);
    }

    public Value(boolean value) {
        this.type = Type.BOOLEAN;
        this.numberValue = 0.0;
        this.booleanValue = value;
        this.stringValue = null;
    }

    public Value(String value) {
        this.type = Type.STRING;
        this.numberValue = 0.0;
        this.booleanValue = false;
        this.stringValue = value != null ? value : "";
    }

    // Type checking
    public boolean isNumber() {
        return type == Type.NUMBER;
    }

    public boolean isBoolean() {
        return type == Type.BOOLEAN;
    }

    public boolean isString() {
        return type == Type.STRING;
    }

    public Type getType() {
        return type;
    }

    // Safe value extraction with conversion
    public double asNumber() throws ExpressionException.TypeException {
        if (isNumber()) {
            return numberValue;
        }
        if (isString()) {
            // Try to convert string to number
            try {
                String trimmed = stringValue.trim();
                if (trimmed.isEmpty()) {
                    throw new ExpressionException.TypeException("Cannot convert empty string to number");
                }
                return Double.parseDouble(trimmed);
            } catch (NumberFormatException e) {
                throw new ExpressionException.TypeException("Cannot convert string '" + stringValue + "' to number");
            }
        }
        if (isBoolean()) {
            return booleanValue ? 1.0 : 0.0;
        }
        throw new ExpressionException.TypeException("Type error: expected number");
    }

    public boolean asBoolean() throws ExpressionException.TypeException {
        if (isBoolean()) {
            return booleanValue;
        }
        if (isNumber()) {
            return numberValue != 0.0;
        }
        if (isString()) {
            // Convert string to boolean with more intuitive rules
            if (stringValue.isEmpty()) {
                return false;
            }

            // Check for explicit false values (case-insensitive)
            String lower = stringValue.toLowerCase();
            if (lower.equals("false") || lower.equals("no") || lower.equals("0")) {
                return false;
            }

            // All other non-empty strings are true
            return true;
        }
        throw new ExpressionException.TypeException("Type error: expected boolean");
    }

    public String asString() throws ExpressionException.TypeException {
        if (isString()) {
            return stringValue;
        }
        if (isNumber()) {
            // Format number similar to C++ std::to_string
            if (numberValue == Math.floor(numberValue) && !Double.isInfinite(numberValue)) {
                return String.format("%.0f", numberValue);
            }
            return Double.toString(numberValue);
        }
        if (isBoolean()) {
            return booleanValue ? "true" : "false";
        }
        throw new ExpressionException.TypeException("Type error: expected string");
    }

    // String conversion (same as asString but doesn't throw)
    @Override
    public String toString() {
        try {
            return asString();
        } catch (ExpressionException.TypeException e) {
            return "Invalid Value";
        }
    }

    // Equality
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Value other = (Value) obj;
        
        if (type != other.type) {
            return false;
        }
        
        switch (type) {
            case NUMBER:
                return Double.compare(numberValue, other.numberValue) == 0;
            case BOOLEAN:
                return booleanValue == other.booleanValue;
            case STRING:
                return java.util.Objects.equals(stringValue, other.stringValue);
            default:
                return false;
        }
    }

    @Override
    public int hashCode() {
        switch (type) {
            case NUMBER:
                return java.util.Objects.hash(type, numberValue);
            case BOOLEAN:
                return java.util.Objects.hash(type, booleanValue);
            case STRING:
                return java.util.Objects.hash(type, stringValue);
            default:
                return java.util.Objects.hash(type);
        }
    }
}