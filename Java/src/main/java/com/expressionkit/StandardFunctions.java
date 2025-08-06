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

import java.util.List;

/**
 * Standard mathematical functions implementation
 * 
 * This class handles built-in mathematical functions:
 * - min(a, b): Returns the smaller of two numbers
 * - max(a, b): Returns the larger of two numbers
 * - sqrt(x): Returns the square root of x
 * - sin(x): Returns the sine of x (in radians)
 * - cos(x): Returns the cosine of x (in radians)
 * - tan(x): Returns the tangent of x (in radians)
 * - abs(x): Returns the absolute value of x
 * - pow(x, y): Returns x raised to the power of y
 * - log(x): Returns the natural logarithm of x
 * - exp(x): Returns e raised to the power of x
 * - floor(x): Returns the largest integer less than or equal to x
 * - ceil(x): Returns the smallest integer greater than or equal to x
 * - round(x): Returns x rounded to the nearest integer
 */
final class StandardFunctions {
    
    private StandardFunctions() {
        // Utility class - prevent instantiation
    }

    /**
     * Call standard mathematical functions
     * 
     * @param functionName Name of the function to call
     * @param args Function arguments
     * @return Function result, or null if function not found or invalid arguments
     */
    public static Value call(String functionName, List<Value> args) {
        try {
            // Two-argument functions
            if ("min".equals(functionName) && args.size() == 2) {
                if (!args.get(0).isNumber() || !args.get(1).isNumber()) return null;
                return new Value(Math.min(args.get(0).asNumber(), args.get(1).asNumber()));
            }
            if ("max".equals(functionName) && args.size() == 2) {
                if (!args.get(0).isNumber() || !args.get(1).isNumber()) return null;
                return new Value(Math.max(args.get(0).asNumber(), args.get(1).asNumber()));
            }
            if ("pow".equals(functionName) && args.size() == 2) {
                if (!args.get(0).isNumber() || !args.get(1).isNumber()) return null;
                return new Value(Math.pow(args.get(0).asNumber(), args.get(1).asNumber()));
            }

            // Single-argument functions
            if (args.size() == 1 && args.get(0).isNumber()) {
                double x = args.get(0).asNumber();

                switch (functionName) {
                    case "sqrt":
                        if (x < 0) return null; // Domain error
                        return new Value(Math.sqrt(x));
                        
                    case "sin":
                        return new Value(Math.sin(x));
                        
                    case "cos":
                        return new Value(Math.cos(x));
                        
                    case "tan":
                        return new Value(Math.tan(x));
                        
                    case "abs":
                        return new Value(Math.abs(x));
                        
                    case "log":
                        if (x <= 0) return null; // Domain error
                        return new Value(Math.log(x));
                        
                    case "exp":
                        return new Value(Math.exp(x));
                        
                    case "floor":
                        return new Value(Math.floor(x));
                        
                    case "ceil":
                        return new Value(Math.ceil(x));
                        
                    case "round":
                        return new Value(Math.round(x));
                        
                    default:
                        return null; // Function not found
                }
            }

            return null; // Function not found or invalid arguments
        } catch (Exception e) {
            return null; // Error occurred
        }
    }
}