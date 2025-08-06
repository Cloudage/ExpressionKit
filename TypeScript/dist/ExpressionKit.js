"use strict";
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
 * to TypeScript, maintaining the same algorithms, structure, and behavior while using
 * TypeScript-idiomatic patterns and conventions.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.Expression = exports.CompiledExpression = exports.BinaryOpNode = exports.UnaryOpNode = exports.FunctionCallNode = exports.VariableNode = exports.StringNode = exports.BooleanNode = exports.NumberNode = exports.ASTNode = exports.Value = exports.ValueType = exports.ExpressionError = exports.TokenType = void 0;
exports.callStandardFunctions = callStandardFunctions;
/**
 * @file ExpressionKit.ts
 * @brief A lightweight, interface-driven expression parser and evaluator for TypeScript
 * @version 1.0.0
 * @date 2025-01-28
 *
 * ExpressionKit provides a clean and extensible way to parse and evaluate mathematical
 * and logical expressions. This is a pure TypeScript implementation translated 1:1 from the
 * C++ header-only library, maintaining identical algorithms and behavior.
 *
 * Key features include:
 *
 * - Interface-based variable and function access through Environment abstraction
 * - Pre-parsed AST support for efficient repeated evaluation
 * - Support for numbers, booleans, strings, variables, and function calls
 * - Comprehensive operator support (arithmetic, comparison, logical)
 * - Type-safe value system with automatic conversions
 * - Exception-based error handling
 * - Token sequence analysis for syntax highlighting
 *
 * The library is designed to be embedded in larger applications where expressions
 * need to be evaluated against dynamic data sources.
 */
/**
 * Token type for syntax highlighting and analysis
 *
 * This enumeration defines all possible token types that can be identified
 * during expression parsing, useful for syntax highlighting and other
 * analysis features.
 */
var TokenType;
(function (TokenType) {
    TokenType[TokenType["NUMBER"] = 0] = "NUMBER";
    TokenType[TokenType["BOOLEAN"] = 1] = "BOOLEAN";
    TokenType[TokenType["STRING"] = 2] = "STRING";
    TokenType[TokenType["IDENTIFIER"] = 3] = "IDENTIFIER";
    TokenType[TokenType["OPERATOR"] = 4] = "OPERATOR";
    TokenType[TokenType["PARENTHESIS"] = 5] = "PARENTHESIS";
    TokenType[TokenType["COMMA"] = 6] = "COMMA";
    TokenType[TokenType["WHITESPACE"] = 7] = "WHITESPACE";
    TokenType[TokenType["UNKNOWN"] = 8] = "UNKNOWN"; // Unrecognized tokens
})(TokenType || (exports.TokenType = TokenType = {}));
/**
 * Exception type for expression parsing and evaluation errors
 */
class ExpressionError extends Error {
    constructor(message, cause) {
        super(message);
        this.cause = cause;
        this.name = 'ExpressionError';
    }
    static parseError(message) {
        return new ExpressionError(`Parse error: ${message}`, 'parseError');
    }
    static evaluationError(message) {
        return new ExpressionError(`Evaluation error: ${message}`, 'evaluationError');
    }
    static typeError(message) {
        return new ExpressionError(`Type error: ${message}`, 'typeError');
    }
    static divisionByZero() {
        return new ExpressionError('Division by zero', 'divisionByZero');
    }
    static unknownVariable(name) {
        return new ExpressionError(`Unknown variable: ${name}`, 'unknownVariable');
    }
    static unknownFunction(name) {
        return new ExpressionError(`Unknown function: ${name}`, 'unknownFunction');
    }
    static domainError(message) {
        return new ExpressionError(`Domain error: ${message}`, 'domainError');
    }
}
exports.ExpressionError = ExpressionError;
/**
 * Value types supported by the expression evaluator
 */
var ValueType;
(function (ValueType) {
    ValueType[ValueType["NUMBER"] = 0] = "NUMBER";
    ValueType[ValueType["BOOLEAN"] = 1] = "BOOLEAN";
    ValueType[ValueType["STRING"] = 2] = "STRING";
})(ValueType || (exports.ValueType = ValueType = {}));
/**
 * Type-safe value container supporting numbers, booleans, and strings
 *
 * This class provides automatic type conversions and represents all possible
 * expression result types. It maintains the same behavior as the C++ Value struct.
 */
class Value {
    constructor(value) {
        this._numberValue = 0;
        this._booleanValue = false;
        this._stringValue = '';
        if (typeof value === 'number') {
            this._type = ValueType.NUMBER;
            this._numberValue = value;
        }
        else if (typeof value === 'boolean') {
            this._type = ValueType.BOOLEAN;
            this._booleanValue = value;
        }
        else {
            this._type = ValueType.STRING;
            this._stringValue = value;
        }
    }
    get type() {
        return this._type;
    }
    /**
     * Convert value to number with automatic type conversion
     */
    asNumber() {
        switch (this._type) {
            case ValueType.NUMBER:
                return this._numberValue;
            case ValueType.BOOLEAN:
                return this._booleanValue ? 1.0 : 0.0;
            case ValueType.STRING:
                const parsed = parseFloat(this._stringValue);
                if (isNaN(parsed)) {
                    throw ExpressionError.typeError(`Cannot convert string "${this._stringValue}" to number`);
                }
                return parsed;
        }
    }
    /**
     * Convert value to boolean with automatic type conversion
     */
    asBoolean() {
        switch (this._type) {
            case ValueType.NUMBER:
                return this._numberValue !== 0.0;
            case ValueType.BOOLEAN:
                return this._booleanValue;
            case ValueType.STRING:
                return this._stringValue.length > 0;
        }
    }
    /**
     * Convert value to string with automatic type conversion
     */
    asString() {
        switch (this._type) {
            case ValueType.NUMBER:
                return this._numberValue.toString();
            case ValueType.BOOLEAN:
                return this._booleanValue.toString();
            case ValueType.STRING:
                return this._stringValue;
        }
    }
    /**
     * Check equality between values with type consideration
     */
    equals(other) {
        if (this._type === other._type) {
            switch (this._type) {
                case ValueType.NUMBER:
                    return Math.abs(this._numberValue - other._numberValue) < Number.EPSILON;
                case ValueType.BOOLEAN:
                    return this._booleanValue === other._booleanValue;
                case ValueType.STRING:
                    return this._stringValue === other._stringValue;
            }
        }
        return false;
    }
    /**
     * String representation for debugging
     */
    toString() {
        return this.asString();
    }
    /**
     * Check if value is truthy (similar to C++ and Swift versions)
     */
    isTruthy() {
        return this.asBoolean();
    }
    /**
     * Create a copy of this value
     */
    copy() {
        switch (this._type) {
            case ValueType.NUMBER:
                return new Value(this._numberValue);
            case ValueType.BOOLEAN:
                return new Value(this._booleanValue);
            case ValueType.STRING:
                return new Value(this._stringValue);
        }
    }
}
exports.Value = Value;
/**
 * Abstract base class for all AST (Abstract Syntax Tree) nodes
 *
 * This is the foundation of the expression evaluation system. Every element
 * in an expression (numbers, variables, operators, functions) is represented
 * as an AST node that can be evaluated against an environment.
 */
class ASTNode {
}
exports.ASTNode = ASTNode;
/**
 * AST node representing a numeric literal
 *
 * This node holds a constant numeric value and returns it during evaluation.
 * Examples: 42, 3.14, -2.5
 */
class NumberNode extends ASTNode {
    constructor(value) {
        super();
        this.value = value;
    }
    evaluate() {
        return new Value(this.value);
    }
}
exports.NumberNode = NumberNode;
/**
 * AST node representing a boolean literal
 *
 * This node holds a constant boolean value and returns it during evaluation.
 * Examples: true, false
 */
class BooleanNode extends ASTNode {
    constructor(value) {
        super();
        this.value = value;
    }
    evaluate() {
        return new Value(this.value);
    }
}
exports.BooleanNode = BooleanNode;
/**
 * AST node representing a string literal
 *
 * This node holds a constant string value and returns it during evaluation.
 * Examples: "hello", "world", "Hello, \"World\"!"
 */
class StringNode extends ASTNode {
    constructor(value) {
        super();
        this.value = value;
    }
    evaluate() {
        return new Value(this.value);
    }
}
exports.StringNode = StringNode;
/**
 * AST node representing a variable reference
 *
 * This node stores a variable name and delegates to the IEnvironment during
 * evaluation to resolve the variable's current value.
 * Examples: x, pos.x, player_health
 */
class VariableNode extends ASTNode {
    constructor(name) {
        super();
        this.name = name;
    }
    evaluate(environment) {
        if (!environment) {
            throw ExpressionError.evaluationError('Variable access requires IEnvironment');
        }
        return environment.get(this.name);
    }
}
exports.VariableNode = VariableNode;
/**
 * Call standard mathematical functions
 *
 * This function handles built-in mathematical functions:
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
function callStandardFunctions(functionName, args) {
    try {
        // Two-argument functions
        if (functionName === 'min' && args.length === 2) {
            if (args[0].type !== ValueType.NUMBER || args[1].type !== ValueType.NUMBER)
                return null;
            return new Value(Math.min(args[0].asNumber(), args[1].asNumber()));
        }
        if (functionName === 'max' && args.length === 2) {
            if (args[0].type !== ValueType.NUMBER || args[1].type !== ValueType.NUMBER)
                return null;
            return new Value(Math.max(args[0].asNumber(), args[1].asNumber()));
        }
        if (functionName === 'pow' && args.length === 2) {
            if (args[0].type !== ValueType.NUMBER || args[1].type !== ValueType.NUMBER)
                return null;
            return new Value(Math.pow(args[0].asNumber(), args[1].asNumber()));
        }
        // Single-argument functions
        if (args.length === 1 && args[0].type === ValueType.NUMBER) {
            const x = args[0].asNumber();
            if (functionName === 'sqrt') {
                if (x < 0)
                    return null; // Domain error
                return new Value(Math.sqrt(x));
            }
            if (functionName === 'sin') {
                return new Value(Math.sin(x));
            }
            if (functionName === 'cos') {
                return new Value(Math.cos(x));
            }
            if (functionName === 'tan') {
                return new Value(Math.tan(x));
            }
            if (functionName === 'abs') {
                return new Value(Math.abs(x));
            }
            if (functionName === 'log') {
                if (x <= 0)
                    return null; // Domain error
                return new Value(Math.log(x));
            }
            if (functionName === 'exp') {
                return new Value(Math.exp(x));
            }
            if (functionName === 'floor') {
                return new Value(Math.floor(x));
            }
            if (functionName === 'ceil') {
                return new Value(Math.ceil(x));
            }
            if (functionName === 'round') {
                return new Value(Math.round(x));
            }
        }
        return null;
    }
    catch {
        return null;
    }
}
/**
 * AST node representing a function call
 *
 * This node stores a function name and arguments, delegating to the IEnvironment
 * during evaluation to call the function with the provided arguments.
 * Examples: max(x, y), sqrt(16), distance(x1, y1, x2, y2)
 */
class FunctionCallNode extends ASTNode {
    constructor(name, args) {
        super();
        this.name = name;
        this.args = args;
    }
    evaluate(environment) {
        // Evaluate all arguments
        const argValues = this.args.map(arg => arg.evaluate(environment));
        // Try standard mathematical functions first (works without environment)
        const standardResult = callStandardFunctions(this.name, argValues);
        if (standardResult !== null) {
            return standardResult;
        }
        // If not a standard function, require environment
        if (!environment) {
            throw ExpressionError.evaluationError('Function calls require IEnvironment');
        }
        // Fall back to user-defined functions
        return environment.call(this.name, argValues);
    }
}
exports.FunctionCallNode = FunctionCallNode;
/**
 * AST node representing a unary operation
 *
 * This node applies a unary operator to a single operand.
 * Examples: -5, !true, not false
 */
class UnaryOpNode extends ASTNode {
    constructor(operator, operand) {
        super();
        this.operator = operator;
        this.operand = operand;
    }
    evaluate(environment) {
        const value = this.operand.evaluate(environment);
        switch (this.operator) {
            case '-':
                return new Value(-value.asNumber());
            case '!':
            case 'not':
                return new Value(!value.asBoolean());
            default:
                throw ExpressionError.evaluationError(`Unknown unary operator: ${this.operator}`);
        }
    }
}
exports.UnaryOpNode = UnaryOpNode;
/**
 * AST node representing a binary operation
 *
 * This node applies a binary operator to two operands with proper operator
 * precedence and type handling.
 * Examples: a + b, x * y, flag && condition, score >= 100
 */
class BinaryOpNode extends ASTNode {
    constructor(operator, left, right) {
        super();
        this.operator = operator;
        this.left = left;
        this.right = right;
    }
    evaluate(environment) {
        const leftValue = this.left.evaluate(environment);
        // Handle short-circuit evaluation for logical operators
        if (this.operator === '&&' || this.operator === 'and') {
            if (!leftValue.asBoolean()) {
                return new Value(false);
            }
            const rightValue = this.right.evaluate(environment);
            return new Value(rightValue.asBoolean());
        }
        if (this.operator === '||' || this.operator === 'or') {
            if (leftValue.asBoolean()) {
                return new Value(true);
            }
            const rightValue = this.right.evaluate(environment);
            return new Value(rightValue.asBoolean());
        }
        // For other operators, always evaluate both sides
        const rightValue = this.right.evaluate(environment);
        switch (this.operator) {
            // Arithmetic operators
            case '+':
                return new Value(leftValue.asNumber() + rightValue.asNumber());
            case '-':
                return new Value(leftValue.asNumber() - rightValue.asNumber());
            case '*':
                return new Value(leftValue.asNumber() * rightValue.asNumber());
            case '/':
                const divisor = rightValue.asNumber();
                if (divisor === 0) {
                    throw ExpressionError.divisionByZero();
                }
                return new Value(leftValue.asNumber() / divisor);
            // Comparison operators
            case '<':
                return new Value(leftValue.asNumber() < rightValue.asNumber());
            case '>':
                return new Value(leftValue.asNumber() > rightValue.asNumber());
            case '<=':
                return new Value(leftValue.asNumber() <= rightValue.asNumber());
            case '>=':
                return new Value(leftValue.asNumber() >= rightValue.asNumber());
            case '==':
                return new Value(leftValue.equals(rightValue));
            case '!=':
                return new Value(!leftValue.equals(rightValue));
            // Logical operators
            case 'xor':
                return new Value(leftValue.asBoolean() !== rightValue.asBoolean());
            default:
                throw ExpressionError.evaluationError(`Unknown binary operator: ${this.operator}`);
        }
    }
}
exports.BinaryOpNode = BinaryOpNode;
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
 *
 * The parser is designed to be used once per expression string and
 * produces an AST that can be evaluated multiple times efficiently.
 */
class Parser {
    constructor(expr, collectTokens = false) {
        this.pos = 0;
        this.tokens = null;
        this.expr = expr;
        this.pos = 0;
        if (collectTokens) {
            this.tokens = [];
        }
    }
    getTokens() {
        return this.tokens;
    }
    addToken(type, start, length, text) {
        if (this.tokens && start + length <= this.expr.length) {
            const tokenText = text || this.expr.substring(start, start + length);
            this.tokens.push({ type, start, length, text: tokenText });
        }
    }
    skipWhitespace() {
        const start = this.pos;
        while (this.pos < this.expr.length && /\s/.test(this.expr[this.pos])) {
            this.pos++;
        }
        if (this.tokens && this.pos > start) {
            this.addToken(TokenType.WHITESPACE, start, this.pos - start);
        }
    }
    match(str) {
        this.skipWhitespace();
        if (this.pos + str.length <= this.expr.length &&
            this.expr.substring(this.pos, this.pos + str.length) === str) {
            this.addToken(TokenType.OPERATOR, this.pos, str.length, str);
            this.pos += str.length;
            return true;
        }
        return false;
    }
    matchChar(c) {
        this.skipWhitespace();
        if (this.pos < this.expr.length && this.expr[this.pos] === c) {
            const type = (c === '(' || c === ')') ? TokenType.PARENTHESIS :
                (c === ',') ? TokenType.COMMA : TokenType.OPERATOR;
            this.addToken(type, this.pos, 1, c);
            this.pos++;
            return true;
        }
        return false;
    }
    peek() {
        this.skipWhitespace();
        if (this.pos >= this.expr.length)
            return '';
        return this.expr[this.pos];
    }
    peekString(len) {
        this.skipWhitespace();
        if (this.pos + len > this.expr.length)
            return '';
        return this.expr.substring(this.pos, this.pos + len);
    }
    consume() {
        this.skipWhitespace();
        if (this.pos >= this.expr.length) {
            throw ExpressionError.parseError('Unexpected end of expression');
        }
        const c = this.expr[this.pos];
        this.addToken(TokenType.OPERATOR, this.pos, 1, c);
        this.pos++;
        return c;
    }
    // Parse OR expressions (lowest precedence)
    parseOrExpression() {
        let left = this.parseAndExpression();
        while (this.match('||') || this.match('or')) {
            const operator = this.pos >= 2 && this.expr.substring(this.pos - 2, this.pos) === '||' ? '||' :
                this.pos >= 2 && this.expr.substring(this.pos - 2, this.pos) === 'or' ? 'or' : '||';
            const right = this.parseAndExpression();
            left = new BinaryOpNode(operator, left, right);
        }
        return left;
    }
    // Parse AND expressions
    parseAndExpression() {
        let left = this.parseXorExpression();
        while (this.match('&&') || this.match('and')) {
            const operator = this.pos >= 2 && this.expr.substring(this.pos - 2, this.pos) === '&&' ? '&&' :
                this.pos >= 3 && this.expr.substring(this.pos - 3, this.pos) === 'and' ? 'and' : '&&';
            const right = this.parseXorExpression();
            left = new BinaryOpNode(operator, left, right);
        }
        return left;
    }
    // Parse XOR expressions
    parseXorExpression() {
        let left = this.parseEqualityExpression();
        while (this.match('xor')) {
            const right = this.parseEqualityExpression();
            left = new BinaryOpNode('xor', left, right);
        }
        return left;
    }
    // Parse equality expressions
    parseEqualityExpression() {
        let left = this.parseRelationalExpression();
        while (this.match('==') || this.match('!=')) {
            const operator = this.expr.substring(this.pos - 2, this.pos);
            const right = this.parseRelationalExpression();
            left = new BinaryOpNode(operator, left, right);
        }
        return left;
    }
    // Parse relational expressions
    parseRelationalExpression() {
        let left = this.parseAdditiveExpression();
        while (this.match('<=') || this.match('>=') || this.match('<') || this.match('>')) {
            let operator;
            if (this.expr.substring(this.pos - 2, this.pos) === '<=' || this.expr.substring(this.pos - 2, this.pos) === '>=') {
                operator = this.expr.substring(this.pos - 2, this.pos);
            }
            else {
                operator = this.expr.substring(this.pos - 1, this.pos);
            }
            const right = this.parseAdditiveExpression();
            left = new BinaryOpNode(operator, left, right);
        }
        return left;
    }
    // Parse additive expressions
    parseAdditiveExpression() {
        let left = this.parseMultiplicativeExpression();
        while (this.matchChar('+') || this.matchChar('-')) {
            const operator = this.expr[this.pos - 1];
            const right = this.parseMultiplicativeExpression();
            left = new BinaryOpNode(operator, left, right);
        }
        return left;
    }
    // Parse multiplicative expressions
    parseMultiplicativeExpression() {
        let left = this.parseUnaryExpression();
        while (this.matchChar('*') || this.matchChar('/')) {
            const operator = this.expr[this.pos - 1];
            const right = this.parseUnaryExpression();
            left = new BinaryOpNode(operator, left, right);
        }
        return left;
    }
    // Parse unary expressions
    parseUnaryExpression() {
        if (this.matchChar('-')) {
            return new UnaryOpNode('-', this.parseUnaryExpression());
        }
        if (this.matchChar('!') || this.match('not')) {
            const operator = this.expr.substring(this.pos - (this.expr.substring(this.pos - 3, this.pos) === 'not' ? 3 : 1), this.pos).trim();
            return new UnaryOpNode(operator, this.parseUnaryExpression());
        }
        return this.parsePrimaryExpression();
    }
    // Parse primary expressions (highest precedence)
    parsePrimaryExpression() {
        this.skipWhitespace();
        // Handle parentheses
        if (this.matchChar('(')) {
            const expr = this.parseOrExpression();
            if (!this.matchChar(')')) {
                throw ExpressionError.parseError('Expected closing parenthesis');
            }
            return expr;
        }
        // Handle string literals
        if (this.peek() === '"') {
            return this.parseStringLiteral();
        }
        // Handle numbers
        if (/\d/.test(this.peek()) || this.peek() === '.') {
            return this.parseNumberLiteral();
        }
        // Handle identifiers (variables and functions)
        if (/[a-zA-Z_]/.test(this.peek())) {
            return this.parseIdentifier();
        }
        throw ExpressionError.parseError(`Unexpected character: ${this.peek()}`);
    }
    parseStringLiteral() {
        const start = this.pos;
        this.pos++; // Skip opening quote
        let value = '';
        while (this.pos < this.expr.length && this.expr[this.pos] !== '"') {
            if (this.expr[this.pos] === '\\' && this.pos + 1 < this.expr.length) {
                this.pos++; // Skip backslash
                const escaped = this.expr[this.pos];
                switch (escaped) {
                    case 'n':
                        value += '\n';
                        break;
                    case 't':
                        value += '\t';
                        break;
                    case 'r':
                        value += '\r';
                        break;
                    case '\\':
                        value += '\\';
                        break;
                    case '"':
                        value += '"';
                        break;
                    default:
                        value += escaped;
                        break;
                }
            }
            else {
                value += this.expr[this.pos];
            }
            this.pos++;
        }
        if (this.pos >= this.expr.length || this.expr[this.pos] !== '"') {
            throw ExpressionError.parseError('Unterminated string literal');
        }
        this.pos++; // Skip closing quote
        this.addToken(TokenType.STRING, start, this.pos - start);
        return new StringNode(value);
    }
    parseNumberLiteral() {
        const start = this.pos;
        let hasDecimal = false;
        while (this.pos < this.expr.length &&
            (/\d/.test(this.expr[this.pos]) ||
                (this.expr[this.pos] === '.' && !hasDecimal))) {
            if (this.expr[this.pos] === '.') {
                hasDecimal = true;
            }
            this.pos++;
        }
        const numberStr = this.expr.substring(start, this.pos);
        const value = parseFloat(numberStr);
        if (isNaN(value)) {
            throw ExpressionError.parseError(`Invalid number: ${numberStr}`);
        }
        this.addToken(TokenType.NUMBER, start, this.pos - start);
        return new NumberNode(value);
    }
    parseIdentifier() {
        const start = this.pos;
        // Parse identifier (including dot notation like "pos.x")
        while (this.pos < this.expr.length &&
            /[a-zA-Z0-9_.]/.test(this.expr[this.pos])) {
            this.pos++;
        }
        const name = this.expr.substring(start, this.pos);
        // Check for boolean literals
        if (name === 'true') {
            this.addToken(TokenType.BOOLEAN, start, this.pos - start);
            return new BooleanNode(true);
        }
        if (name === 'false') {
            this.addToken(TokenType.BOOLEAN, start, this.pos - start);
            return new BooleanNode(false);
        }
        this.addToken(TokenType.IDENTIFIER, start, this.pos - start);
        // Check if this is a function call
        this.skipWhitespace();
        if (this.pos < this.expr.length && this.expr[this.pos] === '(') {
            this.matchChar('('); // Consume opening parenthesis
            const args = [];
            if (!this.matchChar(')')) { // Not empty argument list
                do {
                    args.push(this.parseOrExpression());
                } while (this.matchChar(','));
                if (!this.matchChar(')')) {
                    throw ExpressionError.parseError('Expected closing parenthesis in function call');
                }
            }
            return new FunctionCallNode(name, args);
        }
        // Otherwise, it's a variable
        return new VariableNode(name);
    }
    parse() {
        this.pos = 0;
        const result = this.parseOrExpression();
        this.skipWhitespace();
        if (this.pos < this.expr.length) {
            throw ExpressionError.parseError(`Unexpected input at position ${this.pos}: ${this.expr.substring(this.pos)}`);
        }
        return result;
    }
}
/**
 * Compiled expression for efficient repeated evaluation
 *
 * This class wraps a parsed AST and provides a clean interface for
 * evaluating expressions multiple times with different environments.
 */
class CompiledExpression {
    constructor(ast, tokens = null) {
        this.ast = ast;
        this.tokens = tokens;
    }
    /**
     * Evaluate the compiled expression
     * @param environment Optional environment for variable and function resolution
     * @returns Expression result
     */
    evaluate(environment) {
        return this.ast.evaluate(environment || null);
    }
    /**
     * Get tokens collected during parsing (if token collection was enabled)
     * @returns Array of tokens or null if token collection was disabled
     */
    getTokens() {
        return this.tokens;
    }
}
exports.CompiledExpression = CompiledExpression;
/**
 * Main Expression utility class
 *
 * This class provides the primary interface for parsing and evaluating expressions.
 * It supports both direct evaluation and pre-compilation for efficient repeated execution.
 */
class Expression {
    /**
     * Parse an expression string into a compiled expression
     * @param expr Expression string to parse
     * @param collectTokens Whether to collect tokens for syntax highlighting
     * @returns Compiled expression ready for evaluation
     * @throws ExpressionError if parsing fails
     */
    static parse(expr, collectTokens = false) {
        const parser = new Parser(expr, collectTokens);
        const ast = parser.parse();
        const tokens = parser.getTokens();
        return new CompiledExpression(ast, tokens);
    }
    /**
     * Directly evaluate an expression string
     * @param expr Expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @param collectTokens Whether to collect tokens for syntax highlighting
     * @returns Tuple of [result, tokens] where tokens is null if collectTokens is false
     * @throws ExpressionError if parsing or evaluation fails
     */
    static eval(expr, environment, collectTokens = false) {
        const compiled = Expression.parse(expr, collectTokens);
        const result = compiled.evaluate(environment);
        const tokens = compiled.getTokens();
        return [result, tokens];
    }
    /**
     * Directly evaluate an expression string (simple version)
     * @param expr Expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @returns Expression result
     * @throws ExpressionError if parsing or evaluation fails
     */
    static evalSimple(expr, environment) {
        const [result] = Expression.eval(expr, environment, false);
        return result;
    }
}
exports.Expression = Expression;
