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
using System.Globalization;

namespace ExpressionKit
{
    /// <summary>
    /// Exception type for expression parsing and evaluation errors
    /// </summary>
    public class ExpressionException : Exception
    {
        /// <summary>
        /// Creates a new ExpressionException with the specified message
        /// </summary>
        /// <param name="message">The error message</param>
        public ExpressionException(string message) : base(message)
        {
        }

        /// <summary>
        /// Creates a new ExpressionException with the specified message and inner exception
        /// </summary>
        /// <param name="message">The error message</param>
        /// <param name="innerException">The inner exception</param>
        public ExpressionException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }

    /// <summary>
    /// Type-safe Value type that supports NUMBER, BOOLEAN, and STRING values
    /// with automatic conversions. Direct translation from C++ Value struct.
    /// </summary>
    public readonly struct Value : IEquatable<Value>
    {
        /// <summary>
        /// Type enumeration for Value
        /// </summary>
        public enum ValueType
        {
            /// <summary>Numeric value (double)</summary>
            Number = 0,
            
            /// <summary>Boolean value</summary>
            Boolean = 1,
            
            /// <summary>String value</summary>
            String = 2
        }

        /// <summary>The type of this value</summary>
        public ValueType Type { get; }

        private readonly double _numberValue;
        private readonly bool _booleanValue;
        private readonly string _stringValue;

        /// <summary>
        /// Creates a numeric Value
        /// </summary>
        /// <param name="value">The numeric value</param>
        public Value(double value)
        {
            Type = ValueType.Number;
            _numberValue = value;
            _booleanValue = false;
            _stringValue = string.Empty;
        }

        /// <summary>
        /// Creates a numeric Value from an integer
        /// </summary>
        /// <param name="value">The integer value</param>
        public Value(int value) : this((double)value) { }

        /// <summary>
        /// Creates a numeric Value from a float
        /// </summary>
        /// <param name="value">The float value</param>
        public Value(float value) : this((double)value) { }

        /// <summary>
        /// Creates a boolean Value
        /// </summary>
        /// <param name="value">The boolean value</param>
        public Value(bool value)
        {
            Type = ValueType.Boolean;
            _numberValue = 0.0;
            _booleanValue = value;
            _stringValue = string.Empty;
        }

        /// <summary>
        /// Creates a string Value
        /// </summary>
        /// <param name="value">The string value</param>
        public Value(string value)
        {
            Type = ValueType.String;
            _numberValue = 0.0;
            _booleanValue = false;
            _stringValue = value ?? string.Empty;
        }

        /// <summary>
        /// Checks if this value is a number
        /// </summary>
        public bool IsNumber => Type == ValueType.Number;

        /// <summary>
        /// Checks if this value is a boolean
        /// </summary>
        public bool IsBoolean => Type == ValueType.Boolean;

        /// <summary>
        /// Checks if this value is a string
        /// </summary>
        public bool IsString => Type == ValueType.String;

        /// <summary>
        /// Converts this value to a number with type coercion
        /// </summary>
        /// <returns>The numeric representation of this value</returns>
        /// <exception cref="ExpressionException">If the conversion is not possible</exception>
        public double AsNumber()
        {
            return Type switch
            {
                ValueType.Number => _numberValue,
                ValueType.Boolean => _booleanValue ? 1.0 : 0.0,
                ValueType.String => ConvertStringToNumber(_stringValue),
                _ => throw new ExpressionException("Type error: expected number")
            };
        }

        /// <summary>
        /// Converts this value to a boolean with type coercion
        /// </summary>
        /// <returns>The boolean representation of this value</returns>
        /// <exception cref="ExpressionException">If the conversion is not possible</exception>
        public bool AsBoolean()
        {
            return Type switch
            {
                ValueType.Boolean => _booleanValue,
                ValueType.Number => _numberValue != 0.0,
                ValueType.String => ConvertStringToBoolean(_stringValue),
                _ => throw new ExpressionException("Type error: expected boolean")
            };
        }

        /// <summary>
        /// Converts this value to a string
        /// </summary>
        /// <returns>The string representation of this value</returns>
        public string AsString()
        {
            return Type switch
            {
                ValueType.String => _stringValue,
                ValueType.Number => _numberValue.ToString(CultureInfo.InvariantCulture),
                ValueType.Boolean => _booleanValue ? "true" : "false",
                _ => throw new ExpressionException("Type error: expected string")
            };
        }

        /// <summary>
        /// Converts string to number following C++ logic
        /// </summary>
        private static double ConvertStringToNumber(string value)
        {
            if (string.IsNullOrEmpty(value))
                throw new ExpressionException("Cannot convert empty string to number");

            if (double.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out double result))
                return result;

            throw new ExpressionException($"Cannot convert string '{value}' to number");
        }

        /// <summary>
        /// Converts string to boolean following C++ logic
        /// </summary>
        private static bool ConvertStringToBoolean(string value)
        {
            if (string.IsNullOrEmpty(value))
                return false;

            // Check for explicit false values (case-insensitive)
            string lower = value.ToLowerInvariant();
            return !(lower == "false" || lower == "no" || lower == "0");
        }

        /// <summary>
        /// Implicit conversion from double
        /// </summary>
        public static implicit operator Value(double value) => new(value);

        /// <summary>
        /// Implicit conversion from int
        /// </summary>
        public static implicit operator Value(int value) => new(value);

        /// <summary>
        /// Implicit conversion from bool
        /// </summary>
        public static implicit operator Value(bool value) => new(value);

        /// <summary>
        /// Implicit conversion from string
        /// </summary>
        public static implicit operator Value(string value) => new(value);

        /// <summary>
        /// Equality comparison
        /// </summary>
        public bool Equals(Value other)
        {
            if (Type != other.Type)
            {
                // Cross-type comparison: try to convert both to the same type
                try
                {
                    if (Type == ValueType.Number || other.Type == ValueType.Number)
                        return Math.Abs(AsNumber() - other.AsNumber()) < double.Epsilon;
                    if (Type == ValueType.Boolean || other.Type == ValueType.Boolean)
                        return AsBoolean() == other.AsBoolean();
                    return AsString() == other.AsString();
                }
                catch
                {
                    return false;
                }
            }

            return Type switch
            {
                ValueType.Number => Math.Abs(_numberValue - other._numberValue) < double.Epsilon,
                ValueType.Boolean => _booleanValue == other._booleanValue,
                ValueType.String => _stringValue == other._stringValue,
                _ => false
            };
        }

        /// <summary>
        /// Equality operator
        /// </summary>
        public static bool operator ==(Value left, Value right) => left.Equals(right);

        /// <summary>
        /// Inequality operator
        /// </summary>
        public static bool operator !=(Value left, Value right) => !left.Equals(right);

        /// <summary>
        /// Override Equals for object comparison
        /// </summary>
        public override bool Equals(object? obj) => obj is Value value && Equals(value);

        /// <summary>
        /// Override GetHashCode
        /// </summary>
        public override int GetHashCode()
        {
            return Type switch
            {
                ValueType.Number => _numberValue.GetHashCode(),
                ValueType.Boolean => _booleanValue.GetHashCode(),
                ValueType.String => _stringValue.GetHashCode(),
                _ => 0
            };
        }

        /// <summary>
        /// String representation of the value
        /// </summary>
        public override string ToString() => AsString();
    }
}