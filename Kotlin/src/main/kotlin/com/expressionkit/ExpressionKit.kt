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
 * to Kotlin, maintaining the same algorithms, structure, and behavior while using
 * Kotlin-idiomatic patterns and conventions.
 */

/**
 * @file ExpressionKit.kt
 * @brief A lightweight, interface-driven expression parser and evaluator for Kotlin
 * @version 1.0.0
 * @date 2025-01-27
 *
 * ExpressionKit provides a clean and extensible way to parse and evaluate mathematical
 * and logical expressions. This is a pure Kotlin implementation translated 1:1 from the
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

package com.expressionkit

import kotlin.math.*

/**
 * Token types for syntax highlighting and analysis
 *
 * This enumeration defines all possible token types that can be identified
 * during expression parsing, useful for syntax highlighting and other
 * analysis features.
 */
enum class TokenType {
    NUMBER,       // Numeric literals: 42, 3.14, -2.5
    BOOLEAN,      // Boolean literals: true, false
    STRING,       // String literals: "hello", "world"
    IDENTIFIER,   // Variables and function names: x, pos.x, sqrt
    OPERATOR,     // Operators: +, -, *, /, ==, !=, &&, ||, etc.
    PARENTHESIS,  // Parentheses: (, )
    COMMA,        // Function argument separator: ,
    WHITESPACE,   // Spaces, tabs (optional for highlighting)
    UNKNOWN       // Unrecognized tokens
}

/**
 * Token structure for syntax highlighting and analysis
 *
 * Contains information about a single token identified during parsing,
 * including its type, position in the source text, and the actual text.
 */
data class Token(
    val type: TokenType,    // Type of the token
    val start: Int,         // Starting position in source text
    val length: Int,        // Length of the token
    val text: String        // The actual token text
)

/**
 * Exception type for expression parsing and evaluation errors
 */
class ExpressionError(message: String) : Exception(message)

/**
 * Type-safe value system supporting numeric, boolean, and string types
 * 
 * This is the core value type used throughout ExpressionKit, providing
 * automatic type conversions while maintaining type safety.
 */
sealed class Value {
    abstract fun isNumber(): kotlin.Boolean
    abstract fun isBoolean(): kotlin.Boolean 
    abstract fun isString(): kotlin.Boolean
    
    abstract fun asNumber(): Double
    abstract fun asBoolean(): kotlin.Boolean
    abstract fun asString(): kotlin.String
    
    override fun toString(): kotlin.String = asString()
    
    data class Number(val value: Double) : Value() {
        override fun isNumber() = true
        override fun isBoolean() = false
        override fun isString() = false
        
        override fun asNumber() = value
        override fun asBoolean() = value != 0.0
        override fun asString() = if (value == value.toInt().toDouble()) {
            value.toInt().toString()
        } else {
            value.toString()
        }
    }
    
    data class Boolean(val value: kotlin.Boolean) : Value() {
        override fun isNumber() = false
        override fun isBoolean() = true
        override fun isString() = false
        
        override fun asNumber() = if (value) 1.0 else 0.0
        override fun asBoolean() = value
        override fun asString() = if (value) "true" else "false"
    }
    
    data class String(val value: kotlin.String) : Value() {
        override fun isNumber() = false
        override fun isBoolean() = false
        override fun isString() = true
        
        override fun asNumber(): Double {
            // Try to convert string to number
            try {
                val result = value.toDouble()
                return result
            } catch (e: NumberFormatException) {
                throw ExpressionError("Cannot convert string '$value' to number")
            }
        }
        
        override fun asBoolean(): kotlin.Boolean {
            // Convert string to boolean with intuitive rules
            if (value.isEmpty()) return false
            
            // Check for explicit false values (case-insensitive)
            val lower = value.lowercase()
            if (lower in listOf("false", "no", "0")) {
                return false
            }
            
            // All other non-empty strings are true
            return true
        }
        
        override fun asString() = value
    }
    
    companion object {
        fun number(value: Double) = Number(value)
        fun number(value: Float) = Number(value.toDouble())
        fun number(value: Int) = Number(value.toDouble())
        fun number(value: Long) = Number(value.toDouble())
        fun boolean(value: kotlin.Boolean) = Boolean(value)
        fun string(value: kotlin.String) = String(value)
    }
}

/**
 * Environment interface for variable access and function calls
 *
 * Implement this interface to provide custom variable storage and function
 * implementations. The environment is responsible for handling variable reads,
 * optional variable writes, and function calls during expression evaluation.
 */
interface IEnvironment {
    /**
     * Get a variable value by name
     * @param name Variable name (supports dot notation like "pos.x")
     * @return The variable value
     * @throws ExpressionError if the variable is not found
     */
    fun get(name: String): Value
    
    /**
     * Call a function with given arguments
     * @param name Function name
     * @param args Function arguments
     * @return Function result
     * @throws ExpressionError if the function is not found or arguments are invalid
     */
    fun call(name: String, args: List<Value>): Value
}

/**
 * Abstract base class for all AST (Abstract Syntax Tree) nodes
 *
 * This is the foundation of the expression evaluation system. Every element
 * in an expression (numbers, variables, operators, functions) is represented
 * as an AST node that can be evaluated within a given environment context.
 */
abstract class ASTNode {
    /**
     * Evaluate this AST node within the given environment
     * @param env Environment for variable and function resolution
     * @return The computed value
     * @throws ExpressionError if evaluation fails
     */
    abstract fun evaluate(env: IEnvironment): Value
}

/**
 * AST node representing a numeric literal
 */
class NumberNode(private val value: Double) : ASTNode() {
    override fun evaluate(env: IEnvironment): Value = Value.number(value)
    override fun toString(): String = value.toString()
}

/**
 * AST node representing a boolean literal
 */
class BooleanNode(private val value: Boolean) : ASTNode() {
    override fun evaluate(env: IEnvironment): Value = Value.boolean(value)
    override fun toString(): String = value.toString()
}

/**
 * AST node representing a string literal
 */
class StringNode(private val value: String) : ASTNode() {
    override fun evaluate(env: IEnvironment): Value = Value.string(value)
    override fun toString(): String = "\"$value\""
}

/**
 * AST node representing a variable reference
 */
class VariableNode(private val name: String) : ASTNode() {
    override fun evaluate(env: IEnvironment): Value = env.get(name)
    override fun toString(): String = name
}

/**
 * AST node representing a unary operation
 */
class UnaryOpNode(private val op: String, private val operand: ASTNode) : ASTNode() {
    override fun evaluate(env: IEnvironment): Value {
        val value = operand.evaluate(env)
        
        return when (op) {
            "+" -> Value.number(value.asNumber())
            "-" -> Value.number(-value.asNumber())
            "!" -> Value.boolean(!value.asBoolean())
            "not" -> Value.boolean(!value.asBoolean())
            else -> throw ExpressionError("Unknown unary operator: $op")
        }
    }
    
    override fun toString(): String = "$op$operand"
}

/**
 * AST node representing a binary operation
 */
class BinaryOpNode(
    private val left: ASTNode,
    private val op: String,
    private val right: ASTNode
) : ASTNode() {
    
    override fun evaluate(env: IEnvironment): Value {
        // Handle short-circuit evaluation for logical operators
        if (op == "&&" || op == "and") {
            val leftVal = left.evaluate(env)
            if (!leftVal.asBoolean()) {
                return Value.boolean(false)
            }
            val rightVal = right.evaluate(env)
            return Value.boolean(rightVal.asBoolean())
        }
        
        if (op == "||" || op == "or") {
            val leftVal = left.evaluate(env)
            if (leftVal.asBoolean()) {
                return Value.boolean(true)
            }
            val rightVal = right.evaluate(env)
            return Value.boolean(rightVal.asBoolean())
        }
        
        // Evaluate both sides for all other operations
        val leftVal = left.evaluate(env)
        val rightVal = right.evaluate(env)
        
        return when (op) {
            // Arithmetic operations
            "+" -> {
            // Handle string concatenation
            if (leftVal.isString() || rightVal.isString()) {
                Value.string(leftVal.asString() + rightVal.asString())
            } else {
                Value.number(leftVal.asNumber() + rightVal.asNumber())
            }
            }
            "-" -> Value.number(leftVal.asNumber() - rightVal.asNumber())
            "*" -> Value.number(leftVal.asNumber() * rightVal.asNumber())
            "/" -> {
                val divisor = rightVal.asNumber()
                if (divisor == 0.0) {
                    throw ExpressionError("Division by zero")
                }
                Value.number(leftVal.asNumber() / divisor)
            }
            "%" -> {
                val divisor = rightVal.asNumber()
                if (divisor == 0.0) {
                    throw ExpressionError("Modulo by zero")
                }
                Value.number(leftVal.asNumber() % divisor)
            }
            "^", "**" -> Value.number(leftVal.asNumber().pow(rightVal.asNumber()))
            
            // Comparison operations
            "==" -> Value.boolean(leftVal == rightVal)
            "!=" -> Value.boolean(leftVal != rightVal)
            "<" -> Value.boolean(leftVal.asNumber() < rightVal.asNumber())
            "<=" -> Value.boolean(leftVal.asNumber() <= rightVal.asNumber())
            ">" -> Value.boolean(leftVal.asNumber() > rightVal.asNumber())
            ">=" -> Value.boolean(leftVal.asNumber() >= rightVal.asNumber())
            
            else -> throw ExpressionError("Unknown binary operator: $op")
        }
    }
    
    override fun toString(): String = "($left $op $right)"
}

/**
 * AST node representing a function call
 */
class FunctionCallNode(
    private val name: String,
    private val args: List<ASTNode>
) : ASTNode() {
    
    override fun evaluate(env: IEnvironment): Value {
        // Handle built-in mathematical functions first
        when (name.lowercase()) {
            "sqrt" -> {
                if (args.size != 1) throw ExpressionError("sqrt() requires exactly 1 argument")
                val arg = args[0].evaluate(env).asNumber()
                if (arg < 0) throw ExpressionError("sqrt() of negative number")
                return Value.number(sqrt(arg))
            }
            "abs" -> {
                if (args.size != 1) throw ExpressionError("abs() requires exactly 1 argument")
                return Value.number(abs(args[0].evaluate(env).asNumber()))
            }
            "sin" -> {
                if (args.size != 1) throw ExpressionError("sin() requires exactly 1 argument")
                return Value.number(sin(args[0].evaluate(env).asNumber()))
            }
            "cos" -> {
                if (args.size != 1) throw ExpressionError("cos() requires exactly 1 argument")
                return Value.number(cos(args[0].evaluate(env).asNumber()))
            }
            "tan" -> {
                if (args.size != 1) throw ExpressionError("tan() requires exactly 1 argument")
                return Value.number(tan(args[0].evaluate(env).asNumber()))
            }
            "log" -> {
                if (args.size != 1) throw ExpressionError("log() requires exactly 1 argument")
                val arg = args[0].evaluate(env).asNumber()
                if (arg <= 0) throw ExpressionError("log() of non-positive number")
                return Value.number(ln(arg))
            }
            "log10" -> {
                if (args.size != 1) throw ExpressionError("log10() requires exactly 1 argument")
                val arg = args[0].evaluate(env).asNumber()
                if (arg <= 0) throw ExpressionError("log10() of non-positive number")
                return Value.number(log10(arg))
            }
            "pow" -> {
                if (args.size != 2) throw ExpressionError("pow() requires exactly 2 arguments")
                val base = args[0].evaluate(env).asNumber()
                val exp = args[1].evaluate(env).asNumber()
                return Value.number(base.pow(exp))
            }
            "min" -> {
                if (args.size != 2) throw ExpressionError("min() requires exactly 2 arguments")
                val a = args[0].evaluate(env).asNumber()
                val b = args[1].evaluate(env).asNumber()
                return Value.number(min(a, b))
            }
            "max" -> {
                if (args.size != 2) throw ExpressionError("max() requires exactly 2 arguments")
                val a = args[0].evaluate(env).asNumber()
                val b = args[1].evaluate(env).asNumber()
                return Value.number(max(a, b))
            }
            else -> {
                // Delegate to environment for custom functions
                val evaluatedArgs = args.map { it.evaluate(env) }
                return env.call(name, evaluatedArgs)
            }
        }
    }
    
    override fun toString(): String {
        val argsStr = args.joinToString(", ") { it.toString() }
        return "$name($argsStr)"
    }
}

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
 */
internal class Parser(
    private val expr: String,
    private val tokens: MutableList<Token>? = null
) {
    private var pos = 0
    
    private fun addToken(type: TokenType, start: Int, length: Int, text: String) {
        tokens?.add(Token(type, start, length, text))
    }
    
    private fun addToken(type: TokenType, start: Int, length: Int) {
        if (tokens != null && start + length <= expr.length) {
            addToken(type, start, length, expr.substring(start, start + length))
        }
    }
    
    private fun skipWhitespace() {
        val start = pos
        while (pos < expr.length && expr[pos].isWhitespace()) pos++
        if (tokens != null && pos > start) {
            addToken(TokenType.WHITESPACE, start, pos - start)
        }
    }
    
    private fun match(str: String): Boolean {
        skipWhitespace()
        if (pos + str.length <= expr.length && expr.substring(pos, pos + str.length) == str) {
            addToken(TokenType.OPERATOR, pos, str.length, str)
            pos += str.length
            return true
        }
        return false
    }
    
    private fun match(c: Char): Boolean {
        skipWhitespace()
        if (pos < expr.length && expr[pos] == c) {
            val type = when (c) {
                '(', ')' -> TokenType.PARENTHESIS
                ',' -> TokenType.COMMA
                else -> TokenType.OPERATOR
            }
            addToken(type, pos, 1, c.toString())
            pos++
            return true
        }
        return false
    }
    
    private fun peek(): Char {
        skipWhitespace()
        return if (pos >= expr.length) '\u0000' else expr[pos]
    }
    
    private fun peekString(len: Int): String {
        skipWhitespace()
        return if (pos + len > expr.length) "" else expr.substring(pos, pos + len)
    }
    
    private fun consume(): Char {
        skipWhitespace()
        return if (pos >= expr.length) '\u0000' else expr[pos++]
    }
    
    fun parse(): ASTNode {
        val result = parseTernaryExpression()
        skipWhitespace()
        if (pos < expr.length) {
            throw ExpressionError("Unexpected character at position $pos: '${expr[pos]}'")
        }
        return result
    }
    
    // Parse ternary conditional expression (lowest precedence)
    private fun parseTernaryExpression(): ASTNode {
        val condition = parseLogicalOrExpression()
        
        if (match('?')) {
            val trueExpr = parseTernaryExpression()
            if (!match(':')) {
                throw ExpressionError("Missing ':' in ternary expression")
            }
            val falseExpr = parseTernaryExpression()
            
            // Create a custom ternary node
            return TernaryOpNode(condition, trueExpr, falseExpr)
        }
        
        return condition
    }
    
    // Parse logical OR expressions
    private fun parseLogicalOrExpression(): ASTNode {
        var left = parseLogicalAndExpression()
        
        while (match("||") || match("or")) {
            val op = if (expr.substring(pos - 2, pos) == "||") "||" else "or"
            val right = parseLogicalAndExpression()
            left = BinaryOpNode(left, op, right)
        }
        
        return left
    }
    
    // Parse logical AND expressions
    private fun parseLogicalAndExpression(): ASTNode {
        var left = parseEqualityExpression()
        
        while (match("&&") || match("and")) {
            val op = if (peekString(3) == "and" || expr.substring(pos - 3, pos) == "and") "and" else "&&"
            val right = parseEqualityExpression()
            left = BinaryOpNode(left, op, right)
        }
        
        return left
    }
    
    // Parse equality expressions
    private fun parseEqualityExpression(): ASTNode {
        var left = parseRelationalExpression()
        
        while (true) {
            when {
                match("==") -> {
                    val right = parseRelationalExpression()
                    left = BinaryOpNode(left, "==", right)
                }
                match("!=") -> {
                    val right = parseRelationalExpression()
                    left = BinaryOpNode(left, "!=", right)
                }
                else -> break
            }
        }
        
        return left
    }
    
    // Parse relational expressions
    private fun parseRelationalExpression(): ASTNode {
        var left = parseAdditiveExpression()
        
        while (true) {
            when {
                match(">=") -> {
                    val right = parseAdditiveExpression()
                    left = BinaryOpNode(left, ">=", right)
                }
                match("<=") -> {
                    val right = parseAdditiveExpression()
                    left = BinaryOpNode(left, "<=", right)
                }
                match(">") -> {
                    val right = parseAdditiveExpression()
                    left = BinaryOpNode(left, ">", right)
                }
                match("<") -> {
                    val right = parseAdditiveExpression()
                    left = BinaryOpNode(left, "<", right)
                }
                else -> break
            }
        }
        
        return left
    }
    
    // Parse additive expressions
    private fun parseAdditiveExpression(): ASTNode {
        var left = parseMultiplicativeExpression()
        
        while (peek() == '+' || peek() == '-') {
            val op = if (peek() == '+') "+" else "-"
            if (match(op.first())) {
                val right = parseMultiplicativeExpression()
                left = BinaryOpNode(left, op, right)
            } else {
                break
            }
        }
        
        return left
    }
    
    // Parse multiplicative expressions  
    private fun parseMultiplicativeExpression(): ASTNode {
        var left = parseUnaryExpression()
        
        while (peek() == '*' || peek() == '/' || peek() == '%') {
            val op = peek().toString()
            if (match(peek())) {
                val right = parseUnaryExpression()
                left = BinaryOpNode(left, op, right)
            } else {
                break
            }
        }
        
        return left
    }
    
    // Parse unary expressions
    private fun parseUnaryExpression(): ASTNode {
        when {
            match("!") || match("not") -> {
                val op = if (expr.substring(pos - 1, pos) == "!") "!" else "not"
                val operand = parseUnaryExpression()
                return UnaryOpNode(op, operand)
            }
            match("-") -> {
                val operand = parseUnaryExpression()
                return UnaryOpNode("-", operand)
            }
            match("+") -> {
                val operand = parseUnaryExpression()
                return UnaryOpNode("+", operand)
            }
        }
        
        return parsePrimaryExpression()
    }
    
    // Parse primary expressions
    private fun parsePrimaryExpression(): ASTNode {
        // Handle parentheses
        if (match('(')) {
            val expr = parseTernaryExpression()
            if (!match(')')) {
                throw ExpressionError("Missing closing parenthesis")
            }
            return expr
        }
        
        // Handle numbers
        if (peek().isDigit() || peek() == '.') {
            val start = pos
            val num = StringBuilder()
            
            while (pos < expr.length && (expr[pos].isDigit() || expr[pos] == '.')) {
                num.append(expr[pos++])
            }
            
            val numStr = num.toString()
            addToken(TokenType.NUMBER, start, pos - start, numStr)
            
            return try {
                NumberNode(numStr.toDouble())
            } catch (e: NumberFormatException) {
                throw ExpressionError("Invalid number format: $numStr")
            }
        }
        
        // Handle string literals
        if (peek() == '"') {
            return parseStringLiteral()
        }
        
        // Handle identifiers (variables, functions, booleans)
        if (peek().isLetter() || peek() == '_') {
            val start = pos
            val identifier = StringBuilder()
            
            while (pos < expr.length && (expr[pos].isLetterOrDigit() || expr[pos] == '_' || expr[pos] == '.')) {
                identifier.append(expr[pos++])
            }
            
            val name = identifier.toString()
            addToken(TokenType.IDENTIFIER, start, pos - start, name)
            
            // Check for boolean literals
            when (name.lowercase()) {
                "true" -> return BooleanNode(true)
                "false" -> return BooleanNode(false)
            }
            
            // Check for function call
            if (peek() == '(') {
                match('(')
                val args = mutableListOf<ASTNode>()
                
                if (peek() != ')') {
                    args.add(parseTernaryExpression())
                    
                    while (match(',')) {
                        args.add(parseTernaryExpression())
                    }
                }
                
                if (!match(')')) {
                    throw ExpressionError("Missing closing parenthesis in function call")
                }
                
                return FunctionCallNode(name, args)
            }
            
            // Variable reference
            return VariableNode(name)
        }
        
        throw ExpressionError("Unexpected character at position $pos: '${if (pos < expr.length) expr[pos] else "EOF"}'")
    }
    
    private fun parseStringLiteral(): StringNode {
        if (!match('"')) {
            throw ExpressionError("Expected string literal")
        }
        
        val start = pos - 1
        val str = StringBuilder()
        
        while (pos < expr.length && expr[pos] != '"') {
            if (expr[pos] == '\\' && pos + 1 < expr.length) {
                // Handle escape sequences
                pos++
                when (expr[pos]) {
                    'n' -> str.append('\n')
                    't' -> str.append('\t')
                    'r' -> str.append('\r')
                    '\\' -> str.append('\\')
                    '"' -> str.append('"')
                    else -> {
                        str.append('\\')
                        str.append(expr[pos])
                    }
                }
            } else {
                str.append(expr[pos])
            }
            pos++
        }
        
        if (pos >= expr.length) {
            throw ExpressionError("Unterminated string literal")
        }
        
        pos++ // Skip closing quote
        val content = str.toString()
        addToken(TokenType.STRING, start, pos - start, "\"$content\"")
        
        return StringNode(content)
    }
}

/**
 * AST node for ternary conditional expressions (condition ? trueExpr : falseExpr)
 */
class TernaryOpNode(
    private val condition: ASTNode,
    private val trueExpr: ASTNode,
    private val falseExpr: ASTNode
) : ASTNode() {
    
    override fun evaluate(env: IEnvironment): Value {
        val condValue = condition.evaluate(env)
        return if (condValue.asBoolean()) {
            trueExpr.evaluate(env)
        } else {
            falseExpr.evaluate(env)
        }
    }
    
    override fun toString(): String = "($condition ? $trueExpr : $falseExpr)"
}

/**
 * Main Expression class for parsing and evaluating expressions
 *
 * This class provides the primary API for ExpressionKit. It supports:
 * - Direct evaluation of expression strings
 * - Pre-parsing expressions into ASTs for efficient repeated evaluation
 * - Optional token collection for syntax highlighting
 * - Environment-based variable and function resolution
 *
 * Example usage:
 * ```kotlin
 * // Simple evaluation without variables
 * val result = Expression.eval("2 + 3 * 4") // Returns Value.number(14.0)
 *
 * // With environment for variables and functions  
 * val environment = MyEnvironment()
 * val result2 = Expression.eval("x + sqrt(y)", environment)
 *
 * // Parse once, execute multiple times
 * val compiled = Expression.parse("health > maxHealth * 0.5")
 * for (frame in 0..100) {
 *     val alive = compiled.evaluate(environment)
 *     // ... game logic
 * }
 * ```
 */
object Expression {
    /**
     * Evaluate an expression string directly
     * @param expression The expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @return The evaluation result
     * @throws ExpressionError If parsing fails or evaluation encounters an error
     */
    @JvmStatic
    @JvmOverloads
    fun eval(expression: String, environment: IEnvironment? = null): Value {
        return parse(expression).evaluate(environment ?: EmptyEnvironment)
    }
    
    /**
     * Evaluate an expression string directly with token collection
     * @param expression The expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @param collectTokens Whether to collect tokens for syntax highlighting
     * @return Pair of evaluation result and tokens (if requested)
     * @throws ExpressionError If parsing fails or evaluation encounters an error
     */
    @JvmStatic
    @JvmOverloads
    fun eval(expression: String, environment: IEnvironment? = null, collectTokens: Boolean = false): Pair<Value, List<Token>> {
        val tokens = if (collectTokens) mutableListOf<Token>() else null
        val ast = parse(expression, tokens)
        val result = ast.evaluate(environment ?: EmptyEnvironment)
        return Pair(result, tokens ?: emptyList())
    }
    
    /**
     * Parse an expression string into an Abstract Syntax Tree
     * @param expression The expression string to parse
     * @param tokens Optional mutable list to collect tokens for syntax highlighting
     * @return The root AST node
     * @throws ExpressionError If the expression syntax is invalid
     */
    @JvmStatic
    @JvmOverloads
    fun parse(expression: String, tokens: MutableList<Token>? = null): ASTNode {
        val parser = Parser(expression, tokens)
        return parser.parse()
    }
}

/**
 * Empty environment that throws errors for any variable or function access
 */
private object EmptyEnvironment : IEnvironment {
    override fun get(name: String): Value {
        throw ExpressionError("Variable '$name' not found (no environment provided)")
    }
    
    override fun call(name: String, args: List<Value>): Value {
        throw ExpressionError("Function '$name' not found (no environment provided)")
    }
}