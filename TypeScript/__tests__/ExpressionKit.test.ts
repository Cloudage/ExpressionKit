/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 *
 * ExpressionKit TypeScript Test Suite
 * 
 * This test suite ensures 1:1 behavioral parity with the C++ and Swift implementations.
 * Test cases are translated from the C++ test.cpp file to ensure identical behavior.
 */

import {
    Expression,
    Value,
    ValueType,
    ExpressionError,
    SimpleEnvironment,
    TokenType,
    callStandardFunctions
} from '../src/index';

describe('ExpressionKit TypeScript Tests', () => {
    describe('Value Tests', () => {
        test('Number Value Creation and Conversion', () => {
            const value = new Value(42);
            expect(value.type).toBe(ValueType.NUMBER);
            expect(value.asNumber()).toBe(42);
            expect(value.asBoolean()).toBe(true);
            expect(value.asString()).toBe('42');
        });

        test('Boolean Value Creation and Conversion', () => {
            const trueValue = new Value(true);
            expect(trueValue.type).toBe(ValueType.BOOLEAN);
            expect(trueValue.asNumber()).toBe(1);
            expect(trueValue.asBoolean()).toBe(true);
            expect(trueValue.asString()).toBe('true');

            const falseValue = new Value(false);
            expect(falseValue.type).toBe(ValueType.BOOLEAN);
            expect(falseValue.asNumber()).toBe(0);
            expect(falseValue.asBoolean()).toBe(false);
            expect(falseValue.asString()).toBe('false');
        });

        test('String Value Creation and Conversion', () => {
            const value = new Value('hello');
            expect(value.type).toBe(ValueType.STRING);
            expect(value.asString()).toBe('hello');
            expect(value.asBoolean()).toBe(true);

            const emptyString = new Value('');
            expect(emptyString.asBoolean()).toBe(false);

            const numericString = new Value('123.45');
            expect(numericString.asNumber()).toBeCloseTo(123.45);

            expect(() => new Value('not_a_number').asNumber()).toThrow(ExpressionError);
        });

        test('Value Equality', () => {
            expect(new Value(42).equals(new Value(42))).toBe(true);
            expect(new Value(true).equals(new Value(true))).toBe(true);
            expect(new Value('hello').equals(new Value('hello'))).toBe(true);
            
            expect(new Value(42).equals(new Value(43))).toBe(false);
            expect(new Value(42).equals(new Value(true))).toBe(false);
        });
    });

    describe('Simple Environment Tests', () => {
        test('Variable Storage and Retrieval', () => {
            const env = new SimpleEnvironment();
            env.setVariable('x', new Value(10));
            env.setVariable('y', new Value(20));
            
            expect(env.get('x').asNumber()).toBe(10);
            expect(env.get('y').asNumber()).toBe(20);
            expect(() => env.get('unknown')).toThrow(ExpressionError);
        });

        test('Standard Mathematical Functions', () => {
            const env = new SimpleEnvironment();
            
            // Test min/max
            expect(env.call('min', [new Value(5), new Value(10)]).asNumber()).toBe(5);
            expect(env.call('max', [new Value(5), new Value(10)]).asNumber()).toBe(10);
            
            // Test mathematical functions
            expect(env.call('sqrt', [new Value(16)]).asNumber()).toBe(4);
            expect(env.call('abs', [new Value(-5)]).asNumber()).toBe(5);
            expect(env.call('pow', [new Value(2), new Value(3)]).asNumber()).toBe(8);
            
            // Test domain errors
            expect(() => env.call('unknown_function', [])).toThrow(ExpressionError);
        });
    });

    describe('Basic Expression Evaluation', () => {
        test('Simple Arithmetic', () => {
            expect(Expression.evalSimple('2 + 3').asNumber()).toBe(5);
            expect(Expression.evalSimple('10 - 4').asNumber()).toBe(6);
            expect(Expression.evalSimple('3 * 4').asNumber()).toBe(12);
            expect(Expression.evalSimple('15 / 3').asNumber()).toBe(5);
        });

        test('Operator Precedence', () => {
            expect(Expression.evalSimple('2 + 3 * 4').asNumber()).toBe(14);
            expect(Expression.evalSimple('(2 + 3) * 4').asNumber()).toBe(20);
            expect(Expression.evalSimple('2 * 3 + 4').asNumber()).toBe(10);
            expect(Expression.evalSimple('2 * (3 + 4)').asNumber()).toBe(14);
        });

        test('Boolean Literals', () => {
            expect(Expression.evalSimple('true').asBoolean()).toBe(true);
            expect(Expression.evalSimple('false').asBoolean()).toBe(false);
        });

        test('String Literals', () => {
            expect(Expression.evalSimple('"hello"').asString()).toBe('hello');
            expect(Expression.evalSimple('"Hello, World!"').asString()).toBe('Hello, World!');
            expect(Expression.evalSimple('""').asString()).toBe('');
        });

        test('Unary Operators', () => {
            expect(Expression.evalSimple('-5').asNumber()).toBe(-5);
            expect(Expression.evalSimple('!true').asBoolean()).toBe(false);
            expect(Expression.evalSimple('!false').asBoolean()).toBe(true);
            expect(Expression.evalSimple('not true').asBoolean()).toBe(false);
        });
    });

    describe('Comparison Operations', () => {
        test('Relational Operators', () => {
            expect(Expression.evalSimple('5 < 10').asBoolean()).toBe(true);
            expect(Expression.evalSimple('10 < 5').asBoolean()).toBe(false);
            expect(Expression.evalSimple('5 > 10').asBoolean()).toBe(false);
            expect(Expression.evalSimple('10 > 5').asBoolean()).toBe(true);
            expect(Expression.evalSimple('5 <= 5').asBoolean()).toBe(true);
            expect(Expression.evalSimple('5 >= 5').asBoolean()).toBe(true);
        });

        test('Equality Operators', () => {
            expect(Expression.evalSimple('5 == 5').asBoolean()).toBe(true);
            expect(Expression.evalSimple('5 == 6').asBoolean()).toBe(false);
            expect(Expression.evalSimple('5 != 6').asBoolean()).toBe(true);
            expect(Expression.evalSimple('5 != 5').asBoolean()).toBe(false);
        });
    });

    describe('Logical Operations', () => {
        test('AND Operations', () => {
            expect(Expression.evalSimple('true && true').asBoolean()).toBe(true);
            expect(Expression.evalSimple('true && false').asBoolean()).toBe(false);
            expect(Expression.evalSimple('false && true').asBoolean()).toBe(false);
            expect(Expression.evalSimple('false && false').asBoolean()).toBe(false);
            expect(Expression.evalSimple('true and true').asBoolean()).toBe(true);
        });

        test('OR Operations', () => {
            expect(Expression.evalSimple('true || false').asBoolean()).toBe(true);
            expect(Expression.evalSimple('false || true').asBoolean()).toBe(true);
            expect(Expression.evalSimple('false || false').asBoolean()).toBe(false);
            expect(Expression.evalSimple('true || true').asBoolean()).toBe(true);
            expect(Expression.evalSimple('true or false').asBoolean()).toBe(true);
        });

        test('XOR Operations', () => {
            expect(Expression.evalSimple('true xor false').asBoolean()).toBe(true);
            expect(Expression.evalSimple('false xor true').asBoolean()).toBe(true);
            expect(Expression.evalSimple('true xor true').asBoolean()).toBe(false);
            expect(Expression.evalSimple('false xor false').asBoolean()).toBe(false);
        });

        test('Short-Circuit Evaluation', () => {
            const env = new SimpleEnvironment();
            env.setVariable('x', new Value(0));
            
            // This should not cause division by zero due to short-circuit evaluation
            expect(Expression.evalSimple('false && (1 / x) > 0', env).asBoolean()).toBe(false);
            expect(Expression.evalSimple('true || (1 / x) > 0', env).asBoolean()).toBe(true);
        });
    });

    describe('Variable Access', () => {
        test('Simple Variables', () => {
            const env = new SimpleEnvironment();
            env.setVariable('x', new Value(10));
            env.setVariable('y', new Value(20));
            
            expect(Expression.evalSimple('x', env).asNumber()).toBe(10);
            expect(Expression.evalSimple('y', env).asNumber()).toBe(20);
            expect(Expression.evalSimple('x + y', env).asNumber()).toBe(30);
        });

        test('Dot Notation Variables', () => {
            const env = new SimpleEnvironment();
            env.setVariable('pos.x', new Value(10.5));
            env.setVariable('pos.y', new Value(20.3));
            
            expect(Expression.evalSimple('pos.x', env).asNumber()).toBeCloseTo(10.5);
            expect(Expression.evalSimple('pos.y', env).asNumber()).toBeCloseTo(20.3);
        });

        test('Unknown Variable Error', () => {
            const env = new SimpleEnvironment();
            expect(() => Expression.evalSimple('unknown_var', env)).toThrow(ExpressionError);
        });
    });

    describe('Function Calls', () => {
        test('Standard Mathematical Functions', () => {
            expect(Expression.evalSimple('min(5, 10)').asNumber()).toBe(5);
            expect(Expression.evalSimple('max(5, 10)').asNumber()).toBe(10);
            expect(Expression.evalSimple('sqrt(16)').asNumber()).toBe(4);
            expect(Expression.evalSimple('abs(-5)').asNumber()).toBe(5);
            expect(Expression.evalSimple('pow(2, 3)').asNumber()).toBe(8);
            expect(Expression.evalSimple('floor(3.7)').asNumber()).toBe(3);
            expect(Expression.evalSimple('ceil(3.2)').asNumber()).toBe(4);
            expect(Expression.evalSimple('round(3.6)').asNumber()).toBe(4);
        });

        test('Trigonometric Functions', () => {
            expect(Expression.evalSimple('sin(0)').asNumber()).toBeCloseTo(0);
            expect(Expression.evalSimple('cos(0)').asNumber()).toBeCloseTo(1);
            expect(Expression.evalSimple('tan(0)').asNumber()).toBeCloseTo(0);
        });

        test('Logarithmic Functions', () => {
            expect(Expression.evalSimple('exp(0)').asNumber()).toBeCloseTo(1);
            expect(Expression.evalSimple('log(1)').asNumber()).toBeCloseTo(0);
        });

        test('Function Domain Errors', () => {
            // sqrt of negative number should fail gracefully
            expect(() => Expression.evalSimple('sqrt(-1)')).toThrow();
            // log of non-positive number should fail gracefully  
            expect(() => Expression.evalSimple('log(0)')).toThrow();
            expect(() => Expression.evalSimple('log(-1)')).toThrow();
        });
    });

    describe('Complex Expressions', () => {
        test('Nested Function Calls', () => {
            expect(Expression.evalSimple('max(min(10, 5), 3)').asNumber()).toBe(5);
            expect(Expression.evalSimple('sqrt(pow(3, 2) + pow(4, 2))').asNumber()).toBe(5);
        });

        test('Mixed Operations', () => {
            const env = new SimpleEnvironment();
            env.setVariable('health', new Value(100));
            env.setVariable('maxHealth', new Value(100));
            env.setVariable('level', new Value(5));
            
            expect(Expression.evalSimple('health / maxHealth', env).asNumber()).toBe(1);
            expect(Expression.evalSimple('health < maxHealth * 0.5', env).asBoolean()).toBe(false);
            expect(Expression.evalSimple('level > 0 && health > 0', env).asBoolean()).toBe(true);
        });
    });

    describe('Error Handling', () => {
        test('Division by Zero', () => {
            expect(() => Expression.evalSimple('1 / 0')).toThrow(ExpressionError);
            expect(() => Expression.evalSimple('10 / (5 - 5)')).toThrow(ExpressionError);
        });

        test('Parse Errors', () => {
            expect(() => Expression.evalSimple('2 +')).toThrow(ExpressionError);
            expect(() => Expression.evalSimple('2 * * 3')).toThrow(ExpressionError);
            expect(() => Expression.evalSimple('(2 + 3')).toThrow(ExpressionError);
            expect(() => Expression.evalSimple(')')).toThrow(ExpressionError);
        });

        test('Unknown Function', () => {
            expect(() => Expression.evalSimple('unknown_function(1, 2)')).toThrow(ExpressionError);
        });
    });

    describe('Pre-compiled Expressions', () => {
        test('Parse Once, Execute Many', () => {
            const env = new SimpleEnvironment();
            const compiled = Expression.parse('x * 2 + y');
            
            env.setVariable('x', new Value(5));
            env.setVariable('y', new Value(3));
            expect(compiled.evaluate(env).asNumber()).toBe(13);
            
            env.setVariable('x', new Value(10));
            env.setVariable('y', new Value(7));
            expect(compiled.evaluate(env).asNumber()).toBe(27);
        });

        test('Performance Benefits', () => {
            // This test demonstrates the performance benefit of pre-compilation
            // but doesn't actually measure performance in the unit test
            const env = new SimpleEnvironment();
            env.setVariable('x', new Value(5));
            
            const compiled = Expression.parse('x * 2 + sqrt(x) - floor(x / 2)');
            
            for (let i = 0; i < 100; i++) {
                env.setVariable('x', new Value(i));
                const result = compiled.evaluate(env);
                expect(result.type).toBe(ValueType.NUMBER);
            }
        });
    });

    describe('Token Collection', () => {
        test('Basic Token Collection', () => {
            const [result, tokens] = Expression.eval('2 + 3', undefined, true);
            
            expect(result.asNumber()).toBe(5);
            expect(tokens).not.toBeNull();
            expect(tokens!.length).toBeGreaterThan(0);
            
            // Check that we have the expected token types
            const tokenTypes = tokens!.map(t => t.type);
            expect(tokenTypes).toContain(TokenType.NUMBER);
            expect(tokenTypes).toContain(TokenType.OPERATOR);
        });

        test('Function Call Token Collection', () => {
            const [result, tokens] = Expression.eval('max(10, 5)', undefined, true);
            
            expect(result.asNumber()).toBe(10);
            expect(tokens).not.toBeNull();
            
            const tokenTypes = tokens!.map(t => t.type);
            expect(tokenTypes).toContain(TokenType.IDENTIFIER);
            expect(tokenTypes).toContain(TokenType.PARENTHESIS);
            expect(tokenTypes).toContain(TokenType.NUMBER);
            expect(tokenTypes).toContain(TokenType.COMMA);
        });

        test('String Token Collection', () => {
            const [result, tokens] = Expression.eval('"hello world"', undefined, true);
            
            expect(result.asString()).toBe('hello world');
            expect(tokens).not.toBeNull();
            
            const tokenTypes = tokens!.map(t => t.type);
            expect(tokenTypes).toContain(TokenType.STRING);
        });

        test('No Token Collection', () => {
            const [result, tokens] = Expression.eval('2 + 3', undefined, false);
            
            expect(result.asNumber()).toBe(5);
            expect(tokens).toBeNull();
        });
    });

    describe('String Literal Parsing', () => {
        test('Basic String Literals', () => {
            expect(Expression.evalSimple('"hello"').asString()).toBe('hello');
            expect(Expression.evalSimple('""').asString()).toBe('');
            expect(Expression.evalSimple('"Hello, World!"').asString()).toBe('Hello, World!');
        });

        test('Escaped Characters', () => {
            expect(Expression.evalSimple('"hello\\nworld"').asString()).toBe('hello\nworld');
            expect(Expression.evalSimple('"hello\\tworld"').asString()).toBe('hello\tworld');
            expect(Expression.evalSimple('"hello\\\\world"').asString()).toBe('hello\\world');
            expect(Expression.evalSimple('"say \\"hello\\""').asString()).toBe('say "hello"');
        });

        test('Unterminated String Error', () => {
            expect(() => Expression.evalSimple('"unterminated')).toThrow(ExpressionError);
        });
    });

    describe('Edge Cases and Compatibility', () => {
        test('Number Parsing Edge Cases', () => {
            expect(Expression.evalSimple('0').asNumber()).toBe(0);
            expect(Expression.evalSimple('0.0').asNumber()).toBe(0);
            expect(Expression.evalSimple('.5').asNumber()).toBe(0.5);
            expect(Expression.evalSimple('123.456').asNumber()).toBeCloseTo(123.456);
        });

        test('Boolean Conversion Edge Cases', () => {
            expect(new Value(0).asBoolean()).toBe(false);
            expect(new Value(0.0).asBoolean()).toBe(false);
            expect(new Value(1).asBoolean()).toBe(true);
            expect(new Value(-1).asBoolean()).toBe(true);
            expect(new Value(0.1).asBoolean()).toBe(true);
        });

        test('Expression Without Environment', () => {
            // Should work for constants and standard functions
            expect(Expression.evalSimple('2 + 3').asNumber()).toBe(5);
            expect(Expression.evalSimple('sqrt(16)').asNumber()).toBe(4);
            expect(Expression.evalSimple('true && false').asBoolean()).toBe(false);
            
            // Should fail for variables
            expect(() => Expression.evalSimple('x + 1')).toThrow(ExpressionError);
        });
    });
});