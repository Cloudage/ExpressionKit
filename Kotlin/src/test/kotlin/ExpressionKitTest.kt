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
 * NOTE: This test suite maintains 1:1 correspondence with the C++ and Swift test suites
 * to ensure behavioral consistency across all language implementations.
 */

package com.expressionkit

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.BeforeEach
import kotlin.math.*

class ExpressionKitTest {
    
    private lateinit var env: SimpleEnvironment
    
    @BeforeEach
    fun setup() {
        env = SimpleEnvironment()
    }
    
    // MARK: - Basic Arithmetic Tests
    
    @Test
    fun testBasicArithmetic() {
        assertEquals(Value.number(5.0), Expression.eval("2 + 3"))
        assertEquals(Value.number(7.0), Expression.eval("10 - 3"))
        assertEquals(Value.number(20.0), Expression.eval("4 * 5"))
        assertEquals(Value.number(5.0), Expression.eval("15 / 3"))
        assertEquals(Value.number(14.0), Expression.eval("2 + 3 * 4"))
    }
    
    @Test
    fun testArithmeticPrecedence() {
        assertEquals(Value.number(14.0), Expression.eval("2 + 3 * 4")) // 2 + (3 * 4)
        assertEquals(Value.number(10.0), Expression.eval("2 * 3 + 4")) // (2 * 3) + 4
        assertEquals(Value.number(4.0), Expression.eval("10 - 2 * 3")) // 10 - (2 * 3)
        assertEquals(Value.number(6.0), Expression.eval("12 / 3 + 2")) // (12 / 3) + 2
    }
    
    @Test
    fun testParenthesesGrouping() {
        assertEquals(Value.number(20.0), Expression.eval("(2 + 3) * 4"))
        assertEquals(Value.number(14.0), Expression.eval("2 * (3 + 4)"))
        assertEquals(Value.number(2.0), Expression.eval("(10 - 2) / (3 + 1)"))
        assertEquals(Value.number(19.0), Expression.eval("((2 + 3) * 4) - 1"))
    }
    
    @Test
    fun testComplexArithmetic() {
        assertEquals(Value.number(19.0), Expression.eval("(2 + 3) * 4 - 1"))
        assertEquals(Value.number(8.0), Expression.eval("10 / (2 + 3) * 4"))
        assertEquals(Value.number(11.0), Expression.eval("1 + 2 * 3 + 4"))
        assertEquals(Value.number(21.0), Expression.eval("(1 + 2) * (3 + 4)"))
    }
    
    // MARK: - Boolean Logic Tests
    
    @Test
    fun testBasicBooleanLogic() {
        assertEquals(Value.boolean(true), Expression.eval("true"))
        assertEquals(Value.boolean(false), Expression.eval("false"))
        assertEquals(Value.boolean(true), Expression.eval("true && true"))
        assertEquals(Value.boolean(false), Expression.eval("true && false"))
        assertEquals(Value.boolean(false), Expression.eval("false && false"))
    }
    
    @Test
    fun testLogicalOperators() {
        // AND operations
        assertEquals(Value.boolean(true), Expression.eval("true && true"))
        assertEquals(Value.boolean(false), Expression.eval("true && false"))
        assertEquals(Value.boolean(false), Expression.eval("false && true"))
        assertEquals(Value.boolean(false), Expression.eval("false && false"))
        
        // OR operations
        assertEquals(Value.boolean(true), Expression.eval("true || true"))
        assertEquals(Value.boolean(true), Expression.eval("true || false"))
        assertEquals(Value.boolean(true), Expression.eval("false || true"))
        assertEquals(Value.boolean(false), Expression.eval("false || false"))
        
        // NOT operations
        assertEquals(Value.boolean(false), Expression.eval("!true"))
        assertEquals(Value.boolean(true), Expression.eval("!false"))
        assertEquals(Value.boolean(false), Expression.eval("not true"))
        assertEquals(Value.boolean(true), Expression.eval("not false"))
    }
    
    @Test
    fun testTextualLogicalOperators() {
        // AND
        assertEquals(Value.boolean(true), Expression.eval("true and true"))
        assertEquals(Value.boolean(false), Expression.eval("true and false"))
        
        // OR  
        assertEquals(Value.boolean(true), Expression.eval("true or false"))
        assertEquals(Value.boolean(false), Expression.eval("false or false"))
        
        // NOT
        assertEquals(Value.boolean(false), Expression.eval("not true"))
        assertEquals(Value.boolean(true), Expression.eval("not false"))
    }
    
    @Test
    fun testLogicalPrecedence() {
        assertEquals(Value.boolean(true), Expression.eval("true || false && false")) // true || (false && false)
        assertEquals(Value.boolean(false), Expression.eval("false && true || false")) // (false && true) || false
        assertEquals(Value.boolean(true), Expression.eval("!false && true")) // (!false) && true
        assertEquals(Value.boolean(false), Expression.eval("!true || false")) // (!true) || false
    }
    
    // MARK: - Comparison Tests
    
    @Test
    fun testBasicComparisons() {
        assertEquals(Value.boolean(true), Expression.eval("5 > 3"))
        assertEquals(Value.boolean(false), Expression.eval("3 > 5"))
        assertEquals(Value.boolean(true), Expression.eval("3 < 5"))
        assertEquals(Value.boolean(false), Expression.eval("5 < 3"))
        assertEquals(Value.boolean(true), Expression.eval("5 >= 5"))
        assertEquals(Value.boolean(true), Expression.eval("5 >= 3"))
        assertEquals(Value.boolean(false), Expression.eval("3 >= 5"))
        assertEquals(Value.boolean(true), Expression.eval("3 <= 3"))
        assertEquals(Value.boolean(true), Expression.eval("3 <= 5"))
        assertEquals(Value.boolean(false), Expression.eval("5 <= 3"))
    }
    
    @Test
    fun testEqualityComparisons() {
        // Numbers
        assertEquals(Value.boolean(true), Expression.eval("5 == 5"))
        assertEquals(Value.boolean(false), Expression.eval("5 == 3"))
        assertEquals(Value.boolean(false), Expression.eval("5 != 5"))
        assertEquals(Value.boolean(true), Expression.eval("5 != 3"))
        
        // Booleans
        assertEquals(Value.boolean(true), Expression.eval("true == true"))
        assertEquals(Value.boolean(true), Expression.eval("false == false"))
        assertEquals(Value.boolean(false), Expression.eval("true == false"))
        assertEquals(Value.boolean(false), Expression.eval("false != false"))
        assertEquals(Value.boolean(true), Expression.eval("true != false"))
    }
    
    // MARK: - Variable Tests
    
    @Test
    fun testBasicVariables() {
        env.setVariable("x", 10.0)
        env.setVariable("y", 5.0)
        
        assertEquals(Value.number(10.0), Expression.eval("x", env))
        assertEquals(Value.number(5.0), Expression.eval("y", env))
        assertEquals(Value.number(15.0), Expression.eval("x + y", env))
        assertEquals(Value.number(50.0), Expression.eval("x * y", env))
    }
    
    @Test
    fun testBooleanVariables() {
        env.setVariable("isTrue", true)
        env.setVariable("isFalse", false)
        
        assertEquals(Value.boolean(true), Expression.eval("isTrue", env))
        assertEquals(Value.boolean(false), Expression.eval("isFalse", env))
        assertEquals(Value.boolean(false), Expression.eval("isTrue && isFalse", env))
        assertEquals(Value.boolean(true), Expression.eval("isTrue || isFalse", env))
    }
    
    @Test
    fun testStringVariables() {
        env.setVariable("name", "world")
        env.setVariable("greeting", "hello")
        
        assertEquals(Value.string("world"), Expression.eval("name", env))
        assertEquals(Value.string("hello"), Expression.eval("greeting", env))
        assertEquals(Value.string("helloworld"), Expression.eval("greeting + name", env))
    }
    
    @Test
    fun testVariableNotFound() {
        val exception = assertThrows<ExpressionError> {
            Expression.eval("unknownVar")
        }
        assertTrue(exception.message!!.contains("Variable 'unknownVar' not found"))
    }
    
    // MARK: - Function Tests
    
    @Test
    fun testBuiltinMathFunctions() {
        assertEquals(Value.number(4.0), Expression.eval("sqrt(16)"))
        assertEquals(Value.number(5.0), Expression.eval("abs(-5)"))
        assertEquals(Value.number(5.0), Expression.eval("abs(5)"))
        assertEquals(Value.number(8.0), Expression.eval("pow(2, 3)"))
        assertEquals(Value.number(3.0), Expression.eval("min(3, 5)"))
        assertEquals(Value.number(5.0), Expression.eval("max(3, 5)"))
    }
    
    @Test
    fun testTrigonometricFunctions() {
        // Test basic trig functions with known values
        val pi = PI
        assertEquals(0.0, Expression.eval("sin(0)").asNumber(), 1e-10)
        assertEquals(1.0, Expression.eval("cos(0)").asNumber(), 1e-10)
        assertEquals(0.0, Expression.eval("tan(0)").asNumber(), 1e-10)
    }
    
    @Test
    fun testLogarithmicFunctions() {
        assertEquals(1.0, Expression.eval("log(${E})").asNumber(), 1e-10)
        assertEquals(1.0, Expression.eval("log10(10)").asNumber(), 1e-10)
        
        // Test error cases
        assertThrows<ExpressionError> {
            Expression.eval("log(-1)")
        }
        assertThrows<ExpressionError> {
            Expression.eval("log10(0)")
        }
    }
    
    @Test
    fun testCustomFunctions() {
        env.setFunction("double") { args ->
            if (args.size != 1) throw ExpressionError("double() requires exactly 1 argument")
            Value.number(args[0].asNumber() * 2)
        }
        
        env.setFunction("concat") { args ->
            if (args.size != 2) throw ExpressionError("concat() requires exactly 2 arguments")
            Value.string(args[0].asString() + args[1].asString())
        }
        
        assertEquals(Value.number(10.0), Expression.eval("double(5)", env))
        assertEquals(Value.string("helloworld"), Expression.eval("concat(\"hello\", \"world\")", env))
    }
    
    @Test
    fun testFunctionNotFound() {
        val exception = assertThrows<ExpressionError> {
            Expression.eval("unknownFunc(1, 2)")
        }
        assertTrue(exception.message!!.contains("Function 'unknownFunc' not found"))
    }
    
    // MARK: - String Literal Tests
    
    @Test
    fun testStringLiterals() {
        assertEquals(Value.string("hello"), Expression.eval("\"hello\""))
        assertEquals(Value.string(""), Expression.eval("\"\""))
        assertEquals(Value.string("hello world"), Expression.eval("\"hello world\""))
    }
    
    @Test
    fun testStringConcatenation() {
        assertEquals(Value.string("helloworld"), Expression.eval("\"hello\" + \"world\""))
        assertEquals(Value.string("hello5"), Expression.eval("\"hello\" + 5"))
        assertEquals(Value.string("5hello"), Expression.eval("5 + \"hello\""))
        assertEquals(Value.string("hellotrue"), Expression.eval("\"hello\" + true"))
    }
    
    @Test
    fun testStringEscapes() {
        assertEquals(Value.string("hello\nworld"), Expression.eval("\"hello\\nworld\""))
        assertEquals(Value.string("hello\tworld"), Expression.eval("\"hello\\tworld\""))
        assertEquals(Value.string("hello\"world"), Expression.eval("\"hello\\\"world\""))
        assertEquals(Value.string("hello\\world"), Expression.eval("\"hello\\\\world\""))
    }
    
    // MARK: - Type Conversion Tests
    
    @Test
    fun testNumberToBoolean() {
        assertTrue(Value.number(1.0).asBoolean())
        assertTrue(Value.number(-1.0).asBoolean())
        assertTrue(Value.number(0.1).asBoolean())
        assertFalse(Value.number(0.0).asBoolean())
    }
    
    @Test
    fun testBooleanToNumber() {
        assertEquals(1.0, Value.boolean(true).asNumber())
        assertEquals(0.0, Value.boolean(false).asNumber())
    }
    
    @Test
    fun testStringToNumber() {
        assertEquals(42.0, Value.string("42").asNumber())
        assertEquals(3.14, Value.string("3.14").asNumber())
        assertEquals(-5.0, Value.string("-5").asNumber())
        
        assertThrows<ExpressionError> {
            Value.string("not a number").asNumber()
        }
    }
    
    @Test
    fun testStringToBoolean() {
        // Empty string is false
        assertFalse(Value.string("").asBoolean())
        
        // Explicit false values
        assertFalse(Value.string("false").asBoolean())
        assertFalse(Value.string("no").asBoolean())
        assertFalse(Value.string("0").asBoolean())
        
        // All other non-empty strings are true
        assertTrue(Value.string("true").asBoolean())
        assertTrue(Value.string("yes").asBoolean())
        assertTrue(Value.string("hello").asBoolean())
        assertTrue(Value.string("1").asBoolean())
    }
    
    @Test
    fun testValueToString() {
        assertEquals("42", Value.number(42.0).asString())
        assertEquals("true", Value.boolean(true).asString())
        assertEquals("false", Value.boolean(false).asString())
        assertEquals("hello", Value.string("hello").asString())
    }
    
    // MARK: - Error Handling Tests
    
    @Test
    fun testDivisionByZero() {
        assertThrows<ExpressionError> {
            Expression.eval("5 / 0")
        }
    }
    
    @Test
    fun testModuloByZero() {
        assertThrows<ExpressionError> {
            Expression.eval("5 % 0")
        }
    }
    
    @Test
    fun testSyntaxErrors() {
        // Missing closing parenthesis
        assertThrows<ExpressionError> {
            Expression.eval("(2 + 3")
        }
        
        // Missing opening parenthesis
        assertThrows<ExpressionError> {
            Expression.eval("2 + 3)")
        }
        
        // Invalid function call syntax
        assertThrows<ExpressionError> {
            Expression.eval("sqrt(")
        }
        
        // Unexpected character
        assertThrows<ExpressionError> {
            Expression.eval("2 + @ + 3")
        }
    }
    
    @Test
    fun testInvalidFunctionArguments() {
        // sqrt with wrong number of arguments
        assertThrows<ExpressionError> {
            Expression.eval("sqrt(1, 2)")
        }
        
        // sqrt of negative number
        assertThrows<ExpressionError> {
            Expression.eval("sqrt(-1)")
        }
    }
    
    // MARK: - Token Collection Tests
    
    @Test
    fun testTokenCollection() {
        env.setVariable("x", 5.0)
        val (result, tokens) = Expression.eval("2 + 3 * x", env, true)
        
        assertTrue(tokens.isNotEmpty())
        
        // Should contain number, operator, number, operator, identifier tokens
        val tokenTypes = tokens.map { it.type }
        assertTrue(tokenTypes.contains(TokenType.NUMBER), "Should contain NUMBER token")
        assertTrue(tokenTypes.contains(TokenType.OPERATOR), "Should contain OPERATOR token") 
        assertTrue(tokenTypes.contains(TokenType.IDENTIFIER), "Should contain IDENTIFIER token")
    }
    
    @Test
    fun testTokenPositions() {
        env.setVariable("x", 5.0)
        val (_, tokens) = Expression.eval("42 + sqrt(x)", env, true)
        
        // Verify token positions are sequential and non-overlapping
        var lastEnd = 0
        for (token in tokens.filter { it.type != TokenType.WHITESPACE }) {
            assertTrue(token.start >= lastEnd, "Token positions should be sequential")
            lastEnd = token.start + token.length
        }
    }
    
    // MARK: - Complex Expression Tests
    
    @Test
    fun testComplexExpressions() {
        env.setVariable("a", 10.0)
        env.setVariable("b", 5.0)
        env.setVariable("c", 2.0)
        
        // Complex arithmetic with variables
        assertEquals(Value.number(30.0), Expression.eval("a + b * c + a", env))
        
        // Mixed boolean and arithmetic
        assertEquals(Value.boolean(true), Expression.eval("a > b && b > c", env))
        
        // Function calls in complex expressions
        assertEquals(Value.number(sqrt(15.0) * sqrt(4.0)), Expression.eval("sqrt(a + b) * sqrt(b - 1)", env))
    }
    
    @Test
    fun testNestedFunctionCalls() {
        assertEquals(Value.number(3.0), Expression.eval("sqrt(sqrt(81))"))
        assertEquals(Value.number(16.0), Expression.eval("pow(sqrt(16), 2)"))
        assertEquals(Value.number(8.0), Expression.eval("max(min(10, 8), 6)"))
    }
    
    // MARK: - Parse and Evaluate Separately Tests
    
    @Test
    fun testParseAndEvaluate() {
        env.setVariable("x", 5.0)
        env.setVariable("y", 3.0)
        
        // Parse expression once
        val ast = Expression.parse("x * 2 + y")
        
        // Evaluate multiple times with different variable values
        assertEquals(Value.number(13.0), ast.evaluate(env))
        
        env.setVariable("x", 10.0)
        assertEquals(Value.number(23.0), ast.evaluate(env))
        
        env.setVariable("y", 7.0)
        assertEquals(Value.number(27.0), ast.evaluate(env))
    }
    
    // MARK: - Edge Cases
    
    @Test
    fun testEmptyExpression() {
        assertThrows<ExpressionError> {
            Expression.eval("")
        }
    }
    
    @Test
    fun testWhitespaceOnly() {
        assertThrows<ExpressionError> {
            Expression.eval("   \t\n  ")
        }
    }
    
    @Test
    fun testUnaryOperators() {
        assertEquals(Value.number(5.0), Expression.eval("+5"))
        assertEquals(Value.number(-5.0), Expression.eval("-5"))
        assertEquals(Value.number(5.0), Expression.eval("-(-5)"))
        assertEquals(Value.boolean(false), Expression.eval("!true"))
        assertEquals(Value.boolean(true), Expression.eval("!!true"))
    }
}