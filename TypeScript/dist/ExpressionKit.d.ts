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
export declare enum TokenType {
    NUMBER = 0,// Numeric literals: 42, 3.14, -2.5
    BOOLEAN = 1,// Boolean literals: true, false
    STRING = 2,// String literals: "hello", "world"
    IDENTIFIER = 3,// Variables and function names: x, pos.x, sqrt
    OPERATOR = 4,// Operators: +, -, *, /, ==, !=, &&, ||, etc.
    PARENTHESIS = 5,// Parentheses: (, )
    COMMA = 6,// Function argument separator: ,
    WHITESPACE = 7,// Spaces, tabs (optional for highlighting)
    UNKNOWN = 8
}
/**
 * Token structure for syntax highlighting and analysis
 *
 * Contains information about a single token identified during parsing,
 * including its type, position in the source text, and the actual text.
 */
export interface Token {
    /** Type of the token */
    type: TokenType;
    /** Starting position in source text */
    start: number;
    /** Length of the token */
    length: number;
    /** The actual token text */
    text: string;
}
/**
 * Exception type for expression parsing and evaluation errors
 */
export declare class ExpressionError extends Error {
    readonly cause?: string | undefined;
    constructor(message: string, cause?: string | undefined);
    static parseError(message: string): ExpressionError;
    static evaluationError(message: string): ExpressionError;
    static typeError(message: string): ExpressionError;
    static divisionByZero(): ExpressionError;
    static unknownVariable(name: string): ExpressionError;
    static unknownFunction(name: string): ExpressionError;
    static domainError(message: string): ExpressionError;
}
/**
 * Value types supported by the expression evaluator
 */
export declare enum ValueType {
    NUMBER = 0,
    BOOLEAN = 1,
    STRING = 2
}
/**
 * Type-safe value container supporting numbers, booleans, and strings
 *
 * This class provides automatic type conversions and represents all possible
 * expression result types. It maintains the same behavior as the C++ Value struct.
 */
export declare class Value {
    private _type;
    private _numberValue;
    private _booleanValue;
    private _stringValue;
    constructor(value: number | boolean | string);
    get type(): ValueType;
    /**
     * Convert value to number with automatic type conversion
     */
    asNumber(): number;
    /**
     * Convert value to boolean with automatic type conversion
     */
    asBoolean(): boolean;
    /**
     * Convert value to string with automatic type conversion
     */
    asString(): string;
    /**
     * Check equality between values with type consideration
     */
    equals(other: Value): boolean;
    /**
     * String representation for debugging
     */
    toString(): string;
    /**
     * Check if value is truthy (similar to C++ and Swift versions)
     */
    isTruthy(): boolean;
    /**
     * Create a copy of this value
     */
    copy(): Value;
}
/**
 * Environment interface for variable and function resolution
 *
 * This interface provides the abstraction for accessing variables and calling
 * functions during expression evaluation, allowing integration with any data source.
 */
export interface IEnvironment {
    /**
     * Get a variable value by name
     * @param name Variable name
     * @returns Variable value
     * @throws ExpressionError if variable is not found
     */
    get(name: string): Value;
    /**
     * Call a function with given arguments
     * @param name Function name
     * @param args Function arguments
     * @returns Function result
     * @throws ExpressionError if function is not found or arguments are invalid
     */
    call(name: string, args: Value[]): Value;
}
/**
 * Abstract base class for all AST (Abstract Syntax Tree) nodes
 *
 * This is the foundation of the expression evaluation system. Every element
 * in an expression (numbers, variables, operators, functions) is represented
 * as an AST node that can be evaluated against an environment.
 */
export declare abstract class ASTNode {
    /**
     * Evaluate this node and return its value
     * @param environment Environment for variable and function resolution (can be null for constants)
     * @returns The computed value of this node
     * @throws ExpressionError If evaluation fails
     */
    abstract evaluate(environment: IEnvironment | null): Value;
}
/**
 * AST node representing a numeric literal
 *
 * This node holds a constant numeric value and returns it during evaluation.
 * Examples: 42, 3.14, -2.5
 */
export declare class NumberNode extends ASTNode {
    private value;
    constructor(value: number);
    evaluate(): Value;
}
/**
 * AST node representing a boolean literal
 *
 * This node holds a constant boolean value and returns it during evaluation.
 * Examples: true, false
 */
export declare class BooleanNode extends ASTNode {
    private value;
    constructor(value: boolean);
    evaluate(): Value;
}
/**
 * AST node representing a string literal
 *
 * This node holds a constant string value and returns it during evaluation.
 * Examples: "hello", "world", "Hello, \"World\"!"
 */
export declare class StringNode extends ASTNode {
    private value;
    constructor(value: string);
    evaluate(): Value;
}
/**
 * AST node representing a variable reference
 *
 * This node stores a variable name and delegates to the IEnvironment during
 * evaluation to resolve the variable's current value.
 * Examples: x, pos.x, player_health
 */
export declare class VariableNode extends ASTNode {
    private name;
    constructor(name: string);
    evaluate(environment: IEnvironment | null): Value;
}
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
export declare function callStandardFunctions(functionName: string, args: Value[]): Value | null;
/**
 * AST node representing a function call
 *
 * This node stores a function name and arguments, delegating to the IEnvironment
 * during evaluation to call the function with the provided arguments.
 * Examples: max(x, y), sqrt(16), distance(x1, y1, x2, y2)
 */
export declare class FunctionCallNode extends ASTNode {
    private name;
    private args;
    constructor(name: string, args: ASTNode[]);
    evaluate(environment: IEnvironment | null): Value;
}
/**
 * AST node representing a unary operation
 *
 * This node applies a unary operator to a single operand.
 * Examples: -5, !true, not false
 */
export declare class UnaryOpNode extends ASTNode {
    private operator;
    private operand;
    constructor(operator: string, operand: ASTNode);
    evaluate(environment: IEnvironment | null): Value;
}
/**
 * AST node representing a binary operation
 *
 * This node applies a binary operator to two operands with proper operator
 * precedence and type handling.
 * Examples: a + b, x * y, flag && condition, score >= 100
 */
export declare class BinaryOpNode extends ASTNode {
    private operator;
    private left;
    private right;
    constructor(operator: string, left: ASTNode, right: ASTNode);
    evaluate(environment: IEnvironment | null): Value;
}
/**
 * Compiled expression for efficient repeated evaluation
 *
 * This class wraps a parsed AST and provides a clean interface for
 * evaluating expressions multiple times with different environments.
 */
export declare class CompiledExpression {
    private ast;
    private tokens;
    constructor(ast: ASTNode, tokens?: Token[] | null);
    /**
     * Evaluate the compiled expression
     * @param environment Optional environment for variable and function resolution
     * @returns Expression result
     */
    evaluate(environment?: IEnvironment): Value;
    /**
     * Get tokens collected during parsing (if token collection was enabled)
     * @returns Array of tokens or null if token collection was disabled
     */
    getTokens(): Token[] | null;
}
/**
 * Main Expression utility class
 *
 * This class provides the primary interface for parsing and evaluating expressions.
 * It supports both direct evaluation and pre-compilation for efficient repeated execution.
 */
export declare class Expression {
    /**
     * Parse an expression string into a compiled expression
     * @param expr Expression string to parse
     * @param collectTokens Whether to collect tokens for syntax highlighting
     * @returns Compiled expression ready for evaluation
     * @throws ExpressionError if parsing fails
     */
    static parse(expr: string, collectTokens?: boolean): CompiledExpression;
    /**
     * Directly evaluate an expression string
     * @param expr Expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @param collectTokens Whether to collect tokens for syntax highlighting
     * @returns Tuple of [result, tokens] where tokens is null if collectTokens is false
     * @throws ExpressionError if parsing or evaluation fails
     */
    static eval(expr: string, environment?: IEnvironment, collectTokens?: boolean): [Value, Token[] | null];
    /**
     * Directly evaluate an expression string (simple version)
     * @param expr Expression string to evaluate
     * @param environment Optional environment for variable and function resolution
     * @returns Expression result
     * @throws ExpressionError if parsing or evaluation fails
     */
    static evalSimple(expr: string, environment?: IEnvironment): Value;
}
