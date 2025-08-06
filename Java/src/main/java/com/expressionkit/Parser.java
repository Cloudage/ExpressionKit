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
 * Recursive descent parser for expression strings
 *
 * This class implements a complete expression parser using the recursive
 * descent parsing technique. It supports operator precedence, associativity,
 * and proper error reporting.
 *
 * Grammar (in order of precedence, highest to lowest):
 * - Primary: numbers, booleans, variables, function calls, parentheses
 * - Unary: !, not, - (unary minus)
 * - Multiplicative: *, /
 * - Additive: +, -
 * - Relational: <, >, <=, >=
 * - Equality: ==, !=
 * - Logical XOR: xor
 * - Logical AND: &&, and
 * - Logical OR: ||, or
 * - Ternary conditional: ? :
 *
 * The parser is designed to be used once per expression string and
 * produces an AST that can be evaluated multiple times efficiently.
 */
final class Parser {
    private final String expr;
    private int pos = 0;
    private List<Token> tokens = null;  // Optional token collection

    public Parser(String expression) {
        this.expr = expression;
    }

    public Parser(String expression, List<Token> tokenList) {
        this.expr = expression;
        this.tokens = tokenList;
    }

    private void addToken(TokenType type, int start, int length, String text) {
        if (tokens != null) {
            tokens.add(new Token(type, start, length, text));
        }
    }

    private void addToken(TokenType type, int start, int length) {
        if (tokens != null && start + length <= expr.length()) {
            addToken(type, start, length, expr.substring(start, start + length));
        }
    }

    private void skipWhitespace() {
        int start = pos;
        while (pos < expr.length() && Character.isWhitespace(expr.charAt(pos))) {
            pos++;
        }
        if (tokens != null && pos > start) {
            addToken(TokenType.WHITESPACE, start, pos - start);
        }
    }

    private boolean match(String str) {
        skipWhitespace();
        if (pos + str.length() <= expr.length() &&
            expr.substring(pos, pos + str.length()).equals(str)) {
            addToken(TokenType.OPERATOR, pos, str.length(), str);
            pos += str.length();
            return true;
        }
        return false;
    }

    private boolean match(char c) {
        skipWhitespace();
        if (pos < expr.length() && expr.charAt(pos) == c) {
            TokenType type = (c == '(' || c == ')') ? TokenType.PARENTHESIS :
                           (c == ',') ? TokenType.COMMA : TokenType.OPERATOR;
            addToken(type, pos, 1, String.valueOf(c));
            pos++;
            return true;
        }
        return false;
    }

    private char peek() {
        skipWhitespace();
        if (pos >= expr.length()) return '\0';
        return expr.charAt(pos);
    }

    private String peekString(int len) {
        skipWhitespace();
        if (pos + len > expr.length()) return "";
        return expr.substring(pos, pos + len);
    }

    private char consume() throws ExpressionException.ParseException {
        skipWhitespace();
        if (pos >= expr.length()) {
            throw new ExpressionException.ParseException("Unexpected end of expression");
        }
        char c = expr.charAt(pos);
        addToken(TokenType.OPERATOR, pos, 1, String.valueOf(c));
        return expr.charAt(pos++);
    }

    // Parse ternary expression (lowest precedence)
    private ASTNode parseTernaryExpression() throws ExpressionException {
        ASTNode condition = parseOrExpression();
        if (match("?")) {
            ASTNode trueExpr = parseTernaryExpression(); // Right associative
            if (!match(":")) {
                throw new ExpressionException.ParseException("Expected ':' in ternary expression");
            }
            ASTNode falseExpr = parseTernaryExpression(); // Right associative
            return new TernaryOpNode(condition, trueExpr, falseExpr, OperatorType.TERNARY);
        }
        return condition;
    }

    // Parse logical OR expression (lowest precedence)
    private ASTNode parseOrExpression() throws ExpressionException {
        ASTNode left = parseAndExpression();
        while (match("||") || match("or")) {
            ASTNode right = parseAndExpression();
            left = new BinaryOpNode(left, OperatorType.OR, right);
        }
        return left;
    }

    // Parse logical AND expression
    private ASTNode parseAndExpression() throws ExpressionException {
        ASTNode left = parseXorExpression();
        while (match("&&") || match("and")) {
            ASTNode right = parseXorExpression();
            left = new BinaryOpNode(left, OperatorType.AND, right);
        }
        return left;
    }

    // Parse logical XOR expression
    private ASTNode parseXorExpression() throws ExpressionException {
        ASTNode left = parseEqualityExpression();
        while (match("xor")) {
            ASTNode right = parseEqualityExpression();
            left = new BinaryOpNode(left, OperatorType.XOR, right);
        }
        return left;
    }

    // Parse equality expression
    private ASTNode parseEqualityExpression() throws ExpressionException {
        ASTNode left = parseRelationalExpression();
        while (true) {
            if (match("==")) {
                ASTNode right = parseRelationalExpression();
                left = new BinaryOpNode(left, OperatorType.EQ, right);
            } else if (match("!=")) {
                ASTNode right = parseRelationalExpression();
                left = new BinaryOpNode(left, OperatorType.NE, right);
            } else {
                break;
            }
        }
        return left;
    }

    // Parse relational expression
    private ASTNode parseRelationalExpression() throws ExpressionException {
        ASTNode left = parseAdditiveExpression();
        while (true) {
            if (match(">=")) {
                ASTNode right = parseAdditiveExpression();
                left = new BinaryOpNode(left, OperatorType.GE, right);
            } else if (match("<=")) {
                ASTNode right = parseAdditiveExpression();
                left = new BinaryOpNode(left, OperatorType.LE, right);
            } else if (match(">")) {
                ASTNode right = parseAdditiveExpression();
                left = new BinaryOpNode(left, OperatorType.GT, right);
            } else if (match("<")) {
                ASTNode right = parseAdditiveExpression();
                left = new BinaryOpNode(left, OperatorType.LT, right);
            } else if (match("in")) {
                ASTNode right = parseAdditiveExpression();
                left = new BinaryOpNode(left, OperatorType.IN, right);
            } else {
                break;
            }
        }
        return left;
    }

    // Parse additive expression
    private ASTNode parseAdditiveExpression() throws ExpressionException {
        ASTNode left = parseMultiplicativeExpression();
        while (peek() == '+' || peek() == '-') {
            char op = consume();
            ASTNode right = parseMultiplicativeExpression();
            OperatorType opType = (op == '+') ? OperatorType.ADD : OperatorType.SUB;
            left = new BinaryOpNode(left, opType, right);
        }
        return left;
    }

    // Parse multiplicative expression
    private ASTNode parseMultiplicativeExpression() throws ExpressionException {
        ASTNode left = parseUnaryExpression();
        while (peek() == '*' || peek() == '/') {
            char op = consume();
            ASTNode right = parseUnaryExpression();
            OperatorType opType = (op == '*') ? OperatorType.MUL : OperatorType.DIV;
            left = new BinaryOpNode(left, opType, right);
        }
        return left;
    }

    // Parse unary expression
    private ASTNode parseUnaryExpression() throws ExpressionException {
        if (match("!") || match("not")) {
            ASTNode operand = parseUnaryExpression();
            return new UnaryOpNode(OperatorType.NOT, operand);
        }

        if (match("-")) {
            ASTNode operand = parseUnaryExpression();
            return new UnaryOpNode(OperatorType.SUB, operand);
        }

        return parsePrimaryExpression();
    }

    // Parse primary expression
    private ASTNode parsePrimaryExpression() throws ExpressionException {
        if (match('(')) {
            ASTNode expr = parseTernaryExpression();
            if (!match(')')) {
                throw new ExpressionException.ParseException("Missing closing parenthesis");
            }
            return expr;
        }

        if (Character.isDigit(peek()) || peek() == '.') {
            int start = pos;
            StringBuilder num = new StringBuilder();
            while (pos < expr.length() && (Character.isDigit(expr.charAt(pos)) || expr.charAt(pos) == '.')) {
                num.append(expr.charAt(pos++));
            }
            addToken(TokenType.NUMBER, start, pos - start, num.toString());
            try {
                return new NumberNode(Double.parseDouble(num.toString()));
            } catch (NumberFormatException e) {
                throw new ExpressionException.ParseException("Invalid number format: " + num.toString());
            }
        }

        // Parse string literals
        if (peek() == '"') {
            int start = pos;
            pos++; // Skip opening quote
            StringBuilder str = new StringBuilder();

            while (pos < expr.length() && expr.charAt(pos) != '"') {
                if (expr.charAt(pos) == '\\' && pos + 1 < expr.length()) {
                    // Handle escape sequences
                    pos++; // Skip backslash
                    switch (expr.charAt(pos)) {
                        case 'n': str.append('\n'); break;
                        case 't': str.append('\t'); break;
                        case 'r': str.append('\r'); break;
                        case '\\': str.append('\\'); break;
                        case '"': str.append('"'); break;
                        default:
                            // Unknown escape sequence, preserve original characters
                            str.append('\\');
                            str.append(expr.charAt(pos));
                            break;
                    }
                    pos++;
                } else {
                    str.append(expr.charAt(pos++));
                }
            }

            if (pos >= expr.length()) {
                throw new ExpressionException.ParseException("Unterminated string literal");
            }

            pos++; // Skip closing quote
            addToken(TokenType.STRING, start, pos - start, "\"" + str.toString() + "\"");
            return new StringNode(str.toString());
        }

        if (Character.isLetter(peek())) {
            int start = pos;
            StringBuilder ident = new StringBuilder();
            while (pos < expr.length() && 
                   (Character.isLetterOrDigit(expr.charAt(pos)) || 
                    expr.charAt(pos) == '.' || expr.charAt(pos) == '_')) {
                ident.append(expr.charAt(pos++));
            }

            if (match('(')) {
                List<ASTNode> args = new ArrayList<>();
                if (!match(')')) {
                    do {
                        args.add(parseTernaryExpression());
                    } while (match(','));
                    if (!match(')')) {
                        throw new ExpressionException.ParseException("Missing closing parenthesis in function call");
                    }
                }
                addToken(TokenType.IDENTIFIER, start, ident.length(), ident.toString());
                return new FunctionCallNode(ident.toString(), args);
            }

            String identStr = ident.toString();
            if ("true".equals(identStr)) {
                addToken(TokenType.BOOLEAN, start, ident.length(), ident.toString());
                return new BooleanNode(true);
            }
            if ("false".equals(identStr)) {
                addToken(TokenType.BOOLEAN, start, ident.length(), ident.toString());
                return new BooleanNode(false);
            }

            addToken(TokenType.IDENTIFIER, start, ident.length(), ident.toString());
            return new VariableNode(identStr);
        }

        throw new ExpressionException.ParseException("Unrecognized expression");
    }

    public ASTNode parse() throws ExpressionException {
        pos = 0;
        ASTNode result = parseTernaryExpression();
        skipWhitespace();
        if (pos < expr.length()) {
            throw new ExpressionException.ParseException("Incomplete expression parsing");
        }
        return result;
    }
}