/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 */

package com.expressionkit;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;

/**
 * Comprehensive test suite for ExpressionKit Java implementation
 * 
 * This test suite maintains equivalent coverage to the C++ and Swift implementations,
 * ensuring behavioral parity across all language implementations.
 */
class ExpressionKitTests {

    /**
     * Simple test environment for testing variable and function support
     */
    static class TestEnvironment implements IEnvironment {
        private final SimpleEnvironment simpleEnv = new SimpleEnvironment();

        @Override
        public Value get(String name) throws ExpressionException {
            return simpleEnv.get(name);
        }

        public void set(String name, Value value) {
            simpleEnv.set(name, value);
        }

        @Override
        public Value call(String name, List<Value> args) throws ExpressionException {
            // Try standard functions first
            Value result = StandardFunctions.call(name, args);
            if (result != null) {
                return result;
            }

            // Custom test functions
            if ("add".equals(name)) {
                if (args.size() != 2 || !args.get(0).isNumber() || !args.get(1).isNumber()) {
                    throw new ExpressionException("add function requires two numeric parameters");
                }
                return new Value(args.get(0).asNumber() + args.get(1).asNumber());
            }

            throw new ExpressionException.UnknownFunctionException(name);
        }
    }

    @Test
    void testNumberExpression() throws ExpressionException {
        Value result = Expression.eval("1 + 2 * 3"); // No environment needed
        assertEquals(7.0, result.asNumber(), 0.001);
    }

    @Test
    void testBooleanExpression() throws ExpressionException {
        Value result = Expression.eval("true && false"); // No environment needed
        assertFalse(result.asBoolean());
    }

    @Test
    void testVariableExpression() throws ExpressionException {
        TestEnvironment environment = new TestEnvironment();
        environment.set("x", new Value(5.0));

        Value result = Expression.eval("x + 3", environment);
        assertEquals(8.0, result.asNumber(), 0.001);
    }

    @Test
    void testFunctionCall() throws ExpressionException {
        TestEnvironment environment = new TestEnvironment();

        Value result = Expression.eval("add(2, 3)", environment);
        assertEquals(5.0, result.asNumber(), 0.001);
    }

    @Test
    void testParseError() {
        assertThrows(ExpressionException.class, () -> {
            Expression.eval("1 + * 3");
        });
    }

    @Test
    void testDivisionByZero() {
        assertThrows(ExpressionException.DivisionByZeroException.class, () -> {
            Expression.eval("1 / 0");
        });
    }

    @Test
    void testBooleanOperators() throws ExpressionException {
        // Test && (and) - no environment needed
        assertTrue(Expression.eval("true && true").asBoolean());
        assertFalse(Expression.eval("true && false").asBoolean());
        assertFalse(Expression.eval("true and false").asBoolean());

        // Test || (or)
        assertTrue(Expression.eval("true || false").asBoolean());
        assertFalse(Expression.eval("false || false").asBoolean());
        assertTrue(Expression.eval("false or true").asBoolean());

        // Test xor
        assertTrue(Expression.eval("true xor false").asBoolean());
        assertFalse(Expression.eval("true xor true").asBoolean());

        // Test ! (not)
        assertFalse(Expression.eval("!true").asBoolean());
        assertTrue(Expression.eval("!false").asBoolean());
        assertFalse(Expression.eval("not true").asBoolean());
    }

    @Test
    void testEqualityOperators() throws ExpressionException {
        // Test == - no environment needed
        assertTrue(Expression.eval("5 == 5").asBoolean());
        assertFalse(Expression.eval("5 == 3").asBoolean());

        // Test !=
        assertTrue(Expression.eval("5 != 3").asBoolean());
        assertFalse(Expression.eval("5 != 5").asBoolean());

        // Test boolean equality
        assertTrue(Expression.eval("true == true").asBoolean());
        assertFalse(Expression.eval("true == false").asBoolean());
    }

    @Test
    void testComparisonOperators() throws ExpressionException {
        // Test < > <= >=
        assertTrue(Expression.eval("3 < 5").asBoolean());
        assertFalse(Expression.eval("5 < 3").asBoolean());
        
        assertTrue(Expression.eval("5 > 3").asBoolean());
        assertFalse(Expression.eval("3 > 5").asBoolean());
        
        assertTrue(Expression.eval("3 <= 5").asBoolean());
        assertTrue(Expression.eval("5 <= 5").asBoolean());
        assertFalse(Expression.eval("5 <= 3").asBoolean());
        
        assertTrue(Expression.eval("5 >= 3").asBoolean());
        assertTrue(Expression.eval("5 >= 5").asBoolean());
        assertFalse(Expression.eval("3 >= 5").asBoolean());
    }

    @Test
    void testArithmeticOperators() throws ExpressionException {
        assertEquals(8.0, Expression.eval("5 + 3").asNumber(), 0.001);
        assertEquals(2.0, Expression.eval("5 - 3").asNumber(), 0.001);
        assertEquals(15.0, Expression.eval("5 * 3").asNumber(), 0.001);
        assertEquals(2.5, Expression.eval("5 / 2").asNumber(), 0.001);
    }

    @Test
    void testStringOperations() throws ExpressionException {
        // String concatenation
        assertEquals("hello world", Expression.eval("\"hello\" + \" world\"").asString());
        
        // String equality
        assertTrue(Expression.eval("\"hello\" == \"hello\"").asBoolean());
        assertFalse(Expression.eval("\"hello\" == \"world\"").asBoolean());
        
        // String inequality
        assertTrue(Expression.eval("\"hello\" != \"world\"").asBoolean());
        assertFalse(Expression.eval("\"hello\" != \"hello\"").asBoolean());
        
        // String comparison
        assertTrue(Expression.eval("\"apple\" < \"banana\"").asBoolean());
        assertFalse(Expression.eval("\"banana\" < \"apple\"").asBoolean());
        
        // String contains (in operator)
        assertTrue(Expression.eval("\"ell\" in \"hello\"").asBoolean());
        assertFalse(Expression.eval("\"xyz\" in \"hello\"").asBoolean());
    }

    @Test
    void testUnaryOperators() throws ExpressionException {
        // Unary minus
        assertEquals(-5.0, Expression.eval("-5").asNumber(), 0.001);
        assertEquals(-10.0, Expression.eval("-(5 + 5)").asNumber(), 0.001);
        
        // Logical NOT
        assertTrue(Expression.eval("!false").asBoolean());
        assertFalse(Expression.eval("!true").asBoolean());
    }

    @Test
    void testPrecedence() throws ExpressionException {
        assertEquals(11.0, Expression.eval("2 + 3 * 3").asNumber(), 0.001); // Should be 2 + (3 * 3) = 11
        assertEquals(15.0, Expression.eval("(2 + 3) * 3").asNumber(), 0.001); // Should be (2 + 3) * 3 = 15
        assertEquals(14.0, Expression.eval("2 * 3 + 4 * 2").asNumber(), 0.001); // Should be (2*3) + (4*2) = 14
    }

    @Test
    void testStandardMathFunctions() throws ExpressionException {
        // min/max
        assertEquals(3.0, Expression.eval("min(5, 3)").asNumber(), 0.001);
        assertEquals(5.0, Expression.eval("max(5, 3)").asNumber(), 0.001);
        
        // sqrt
        assertEquals(4.0, Expression.eval("sqrt(16)").asNumber(), 0.001);
        
        // abs
        assertEquals(5.0, Expression.eval("abs(-5)").asNumber(), 0.001);
        assertEquals(5.0, Expression.eval("abs(5)").asNumber(), 0.001);
        
        // pow
        assertEquals(8.0, Expression.eval("pow(2, 3)").asNumber(), 0.001);
        
        // floor/ceil/round
        assertEquals(3.0, Expression.eval("floor(3.7)").asNumber(), 0.001);
        assertEquals(4.0, Expression.eval("ceil(3.2)").asNumber(), 0.001);
        assertEquals(4.0, Expression.eval("round(3.6)").asNumber(), 0.001);
    }

    @Test
    void testTrigonometricFunctions() throws ExpressionException {
        // Test sin/cos/tan with common values
        assertEquals(0.0, Expression.eval("sin(0)").asNumber(), 0.001);
        assertEquals(1.0, Expression.eval("cos(0)").asNumber(), 0.001);
        assertEquals(0.0, Expression.eval("tan(0)").asNumber(), 0.001);
        
        // Test with π/2 (approximately 1.5708)
        assertEquals(1.0, Expression.eval("sin(1.5708)").asNumber(), 0.01);
        assertEquals(0.0, Expression.eval("cos(1.5708)").asNumber(), 0.01);
    }

    @Test
    void testLogarithmicFunctions() throws ExpressionException {
        // Test log and exp
        assertEquals(0.0, Expression.eval("log(1)").asNumber(), 0.001);
        assertEquals(1.0, Expression.eval("exp(0)").asNumber(), 0.001);
        
        // Test that exp(log(x)) ≈ x
        assertEquals(5.0, Expression.eval("exp(log(5))").asNumber(), 0.001);
    }

    @Test
    void testTokenCollection() throws ExpressionException {
        Expression.EvalResult result = Expression.evalWithTokens("2 + 3 * 4", null);
        
        assertEquals(14.0, result.getValue().asNumber(), 0.001);
        
        List<Token> tokens = result.getTokens();
        assertFalse(tokens.isEmpty());
        
        // Check that we have number, operator, number, operator, number tokens
        // (ignoring whitespace tokens)
        long numberTokens = tokens.stream()
            .filter(t -> t.getType() == TokenType.NUMBER)
            .count();
        long operatorTokens = tokens.stream()
            .filter(t -> t.getType() == TokenType.OPERATOR)
            .count();
            
        assertEquals(3, numberTokens); // 2, 3, 4
        assertEquals(2, operatorTokens); // +, *
    }

    @Test
    void testCompiledExpression() throws ExpressionException {
        TestEnvironment environment = new TestEnvironment();
        environment.set("x", new Value(10.0));
        environment.set("y", new Value(5.0));
        
        Expression.CompiledExpression compiled = Expression.compile("x + y * 2");
        
        // Test multiple evaluations
        for (int i = 0; i < 10; i++) {
            Value result = compiled.evaluate(environment);
            assertEquals(20.0, result.asNumber(), 0.001); // 10 + 5*2 = 20
        }
        
        // Change variables and test again
        environment.set("x", new Value(5.0));
        environment.set("y", new Value(3.0));
        
        Value result = compiled.evaluate(environment);
        assertEquals(11.0, result.asNumber(), 0.001); // 5 + 3*2 = 11
    }

    @Test
    void testParseWithTokens() throws ExpressionException {
        Expression.ParseResult parseResult = Expression.parseWithTokens("sqrt(x) + 5");
        
        assertNotNull(parseResult.getAstNode());
        assertFalse(parseResult.getTokens().isEmpty());
        
        // Should have identifier (sqrt), parenthesis, identifier (x), etc.
        List<Token> tokens = parseResult.getTokens();
        assertTrue(tokens.stream().anyMatch(t -> t.getType() == TokenType.IDENTIFIER && "sqrt".equals(t.getText())));
        assertTrue(tokens.stream().anyMatch(t -> t.getType() == TokenType.IDENTIFIER && "x".equals(t.getText())));
        assertTrue(tokens.stream().anyMatch(t -> t.getType() == TokenType.NUMBER && "5".equals(t.getText())));
    }

    @Test
    void testTernaryOperator() throws ExpressionException {
        assertTrue(Expression.eval("true ? true : false").asBoolean());
        assertFalse(Expression.eval("false ? true : false").asBoolean());
        
        assertEquals(5.0, Expression.eval("3 > 2 ? 5 : 10").asNumber(), 0.001);
        assertEquals(10.0, Expression.eval("3 < 2 ? 5 : 10").asNumber(), 0.001);
        
        // Test nested ternary
        assertEquals(1.0, Expression.eval("true ? (false ? 2 : 1) : 3").asNumber(), 0.001);
    }

    @Test
    void testSimpleEnvironment() throws ExpressionException {
        SimpleEnvironment env = new SimpleEnvironment();
        env.set("pi", 3.14159);
        env.set("name", "ExpressionKit");
        env.set("active", true);
        
        assertEquals(3.14159, Expression.eval("pi", env).asNumber(), 0.0001);
        assertEquals("ExpressionKit", Expression.eval("name", env).asString());
        assertTrue(Expression.eval("active", env).asBoolean());
        
        assertTrue(env.contains("pi"));
        assertFalse(env.contains("nonexistent"));
        
        assertEquals(3, env.size());
        
        env.remove("pi");
        assertEquals(2, env.size());
        assertFalse(env.contains("pi"));
        
        env.clear();
        assertEquals(0, env.size());
    }

    @Test
    void testTypeConversions() throws ExpressionException {
        // Number to boolean
        assertTrue(new Value(1.0).asBoolean());
        assertFalse(new Value(0.0).asBoolean());
        
        // Boolean to number
        assertEquals(1.0, new Value(true).asNumber(), 0.001);
        assertEquals(0.0, new Value(false).asNumber(), 0.001);
        
        // String to number
        assertEquals(42.0, new Value("42").asNumber(), 0.001);
        assertEquals(3.14, new Value("3.14").asNumber(), 0.001);
        
        // Number to string
        assertEquals("42", new Value(42.0).asString());
        assertEquals("true", new Value(true).asString());
        assertEquals("false", new Value(false).asString());
        
        // String to boolean
        assertTrue(new Value("hello").asBoolean());
        assertFalse(new Value("").asBoolean());
        assertFalse(new Value("false").asBoolean());
        assertFalse(new Value("0").asBoolean());
    }

    @Test
    void testErrorHandling() {
        // Unknown variable
        assertThrows(ExpressionException.UnknownVariableException.class, () -> {
            Expression.eval("unknown_variable");
        });
        
        // Unknown function
        assertThrows(ExpressionException.UnknownFunctionException.class, () -> {
            Expression.eval("unknown_function(5)");
        });
        
        // Invalid string to number conversion
        assertThrows(ExpressionException.TypeException.class, () -> {
            new Value("not a number").asNumber();
        });
        
        // Domain errors for mathematical functions
        SimpleEnvironment env = new SimpleEnvironment();
        assertThrows(ExpressionException.class, () -> {
            Expression.eval("sqrt(-1)", env);
        });
        
        assertThrows(ExpressionException.class, () -> {
            Expression.eval("log(-1)", env);
        });
    }
    
    @ParameterizedTest
    @ValueSource(strings = {
        "2 + 2",
        "true && false",
        "\"hello\" + \" world\"",
        "max(5, 3)",
        "sqrt(16)",
        "3 < 5 ? 10 : 20"
    })
    void testValidExpressions(String expression) {
        assertDoesNotThrow(() -> {
            Value result = Expression.eval(expression);
            assertNotNull(result);
        });
    }

    @ParameterizedTest
    @ValueSource(strings = {
        "2 + + 2",
        "true && ",
        "\"unterminated string",
        "unknown_function(5)",
        "(",
        "2 +"
    })
    void testInvalidExpressions(String expression) {
        assertThrows(ExpressionException.class, () -> {
            Expression.eval(expression);
        });
    }
}