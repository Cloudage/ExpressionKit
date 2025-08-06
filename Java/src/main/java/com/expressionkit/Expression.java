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
import java.util.ArrayList;

/**
 * Main expression toolkit class for parsing and evaluating expressions
 *
 * Expression provides a complete expression evaluation system with support for:
 * - Arithmetic operations (+, -, *, /)
 * - Comparison operations (==, !=, <, >, <=, >=)
 * - Logical operations (&&, ||, !, xor)
 * - Variables and functions via Environment interface
 * - Expression compilation and caching for better performance
 *
 * Usage examples:
 * <pre>
 * // Simple evaluation without variables
 * Value result = Expression.eval("2 + 3 * 4"); // Returns 14.0
 *
 * // With environment for variables and functions
 * IEnvironment environment = new MyEnvironment();
 * Value result2 = Expression.eval("x + sqrt(y)", environment);
 *
 * // Compile once, execute multiple times
 * ASTNode compiled = Expression.parse("health > maxHealth * 0.5");
 * for (int frame = 0; frame < 100; frame++) {
 *     Value alive = compiled.evaluate(environment);
 *     // ... game logic
 * }
 * </pre>
 *
 * Note: The Expression instance does not own the Environment object. The caller is
 * responsible for ensuring the Environment remains valid during expression
 * evaluation.
 */
public final class Expression {
    
    private Expression() {
        // Utility class - prevent instantiation
    }

    /**
     * Evaluate an expression string directly
     * @param expression The expression string to evaluate
     * @return The evaluation result
     * @throws ExpressionException If parsing fails or evaluation encounters an error
     *
     * This method parses and evaluates the expression in one call. For
     * expressions that will be evaluated multiple times, consider using
     * parse() and evaluate() for better performance.
     *
     * Supported syntax:
     * - Numbers: 42, 3.14, -2.5
     * - Booleans: true, false
     * - Strings: "hello", "world"
     * - Arithmetic: +, -, *, /
     * - Comparison: ==, !=, <, >, <=, >=
     * - Logical: &&, ||, !, and, or, not, xor
     * - Parentheses for grouping: (expr)
     * - Variables: x, pos.x, player_health
     * - Functions: max(a, b), sqrt(x)
     */
    public static Value eval(String expression) throws ExpressionException {
        return eval(expression, null);
    }

    /**
     * Evaluate an expression string directly with environment
     * @param expression The expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @return The evaluation result
     * @throws ExpressionException If parsing fails or evaluation encounters an error
     */
    public static Value eval(String expression, IEnvironment environment) throws ExpressionException {
        return parse(expression).evaluate(environment);
    }

    /**
     * Evaluate an expression string directly with token collection
     * @param expression The expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @param tokens Optional list to collect tokens for syntax highlighting
     * @return The evaluation result
     * @throws ExpressionException If parsing fails or evaluation encounters an error
     *
     * This method parses and evaluates the expression while optionally collecting
     * tokens that can be used for syntax highlighting or other analysis.
     */
    public static Value eval(String expression, IEnvironment environment, List<Token> tokens) 
            throws ExpressionException {
        return parse(expression, tokens).evaluate(environment);
    }

    /**
     * Parse an expression string into an Abstract Syntax Tree
     * @param expression The expression string to parse
     * @return The root AST node
     * @throws ExpressionException If the expression syntax is invalid
     *
     * This method is primarily for internal use. Most users should use
     * eval() for direct evaluation or parse() for cached expressions.
     */
    public static ASTNode parse(String expression) throws ExpressionException {
        Parser parser = new Parser(expression);
        return parser.parse();
    }

    /**
     * Parse an expression string into an Abstract Syntax Tree with token collection
     * @param expression The expression string to parse
     * @param tokens Optional list to collect tokens for syntax highlighting
     * @return The root AST node
     * @throws ExpressionException If the expression syntax is invalid
     *
     * This method parses the expression while optionally collecting tokens
     * that can be used for syntax highlighting or other analysis.
     */
    public static ASTNode parse(String expression, List<Token> tokens) throws ExpressionException {
        Parser parser = new Parser(expression, tokens);
        return parser.parse();
    }

    /**
     * Compiled expression wrapper for efficient repeated evaluation
     * 
     * This class wraps a pre-parsed AST node and provides a clean interface
     * for repeated evaluation with different environments.
     */
    public static final class CompiledExpression {
        private final ASTNode astNode;

        private CompiledExpression(ASTNode astNode) {
            this.astNode = astNode;
        }

        /**
         * Evaluate the compiled expression
         * @param environment Environment for variable and function resolution
         * @return The evaluation result
         * @throws ExpressionException If evaluation encounters an error
         */
        public Value evaluate(IEnvironment environment) throws ExpressionException {
            return astNode.evaluate(environment);
        }

        /**
         * Evaluate the compiled expression without environment
         * @return The evaluation result
         * @throws ExpressionException If evaluation encounters an error
         */
        public Value evaluate() throws ExpressionException {
            return astNode.evaluate(null);
        }
    }

    /**
     * Compile an expression for efficient repeated evaluation
     * @param expression The expression string to compile
     * @return A compiled expression object
     * @throws ExpressionException If the expression syntax is invalid
     */
    public static CompiledExpression compile(String expression) throws ExpressionException {
        return new CompiledExpression(parse(expression));
    }

    /**
     * Compile an expression for efficient repeated evaluation with token collection
     * @param expression The expression string to compile
     * @param tokens Optional list to collect tokens for syntax highlighting
     * @return A compiled expression object
     * @throws ExpressionException If the expression syntax is invalid
     */
    public static CompiledExpression compile(String expression, List<Token> tokens) throws ExpressionException {
        return new CompiledExpression(parse(expression, tokens));
    }

    /**
     * Result class for eval operations that return both value and tokens
     */
    public static final class EvalResult {
        private final Value value;
        private final List<Token> tokens;

        public EvalResult(Value value, List<Token> tokens) {
            this.value = value;
            this.tokens = tokens;
        }

        public Value getValue() {
            return value;
        }

        public List<Token> getTokens() {
            return tokens;
        }
    }

    /**
     * Evaluate an expression and return both result and tokens
     * @param expression The expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @return EvalResult containing both value and tokens
     * @throws ExpressionException If parsing fails or evaluation encounters an error
     */
    public static EvalResult evalWithTokens(String expression, IEnvironment environment) 
            throws ExpressionException {
        List<Token> tokens = new ArrayList<>();
        Value value = eval(expression, environment, tokens);
        return new EvalResult(value, tokens);
    }

    /**
     * Result class for parse operations that return both AST and tokens
     */
    public static final class ParseResult {
        private final ASTNode astNode;
        private final List<Token> tokens;

        public ParseResult(ASTNode astNode, List<Token> tokens) {
            this.astNode = astNode;
            this.tokens = tokens;
        }

        public ASTNode getAstNode() {
            return astNode;
        }

        public List<Token> getTokens() {
            return tokens;
        }

        /**
         * Create a compiled expression from this parse result
         * @return A compiled expression
         */
        public CompiledExpression compile() {
            return new CompiledExpression(astNode);
        }
    }

    /**
     * Parse an expression and return both AST and tokens
     * @param expression The expression string to parse
     * @return ParseResult containing both AST node and tokens
     * @throws ExpressionException If the expression syntax is invalid
     */
    public static ParseResult parseWithTokens(String expression) throws ExpressionException {
        List<Token> tokens = new ArrayList<>();
        ASTNode astNode = parse(expression, tokens);
        return new ParseResult(astNode, tokens);
    }
}