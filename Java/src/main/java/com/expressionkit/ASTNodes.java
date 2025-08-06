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
 * AST node representing a numeric literal
 *
 * This node holds a constant numeric value and returns it during evaluation.
 * Examples: 42, 3.14, -2.5
 */
final class NumberNode extends ASTNode {
    private final double value;

    public NumberNode(double value) {
        this.value = value;
    }

    @Override
    public Value evaluate(IEnvironment environment) {
        return new Value(value);
    }
}

/**
 * AST node representing a boolean literal
 *
 * This node holds a constant boolean value and returns it during evaluation.
 * Examples: true, false
 */
final class BooleanNode extends ASTNode {
    private final boolean value;

    public BooleanNode(boolean value) {
        this.value = value;
    }

    @Override
    public Value evaluate(IEnvironment environment) {
        return new Value(value);
    }
}

/**
 * AST node representing a string literal
 *
 * This node holds a constant string value and returns it during evaluation.
 * Examples: "hello", "world", "Hello, \"World\"!"
 */
final class StringNode extends ASTNode {
    private final String value;

    public StringNode(String value) {
        this.value = value;
    }

    @Override
    public Value evaluate(IEnvironment environment) {
        return new Value(value);
    }
}

/**
 * AST node representing a variable reference
 *
 * This node stores a variable name and delegates to the IEnvironment during
 * evaluation to resolve the variable's current value.
 * Examples: x, pos.x, player_health
 */
final class VariableNode extends ASTNode {
    private final String name;

    public VariableNode(String name) {
        this.name = name;
    }

    @Override
    public Value evaluate(IEnvironment environment) throws ExpressionException {
        if (environment == null) {
            throw new ExpressionException.UnknownVariableException(name);
        }
        return environment.get(name);
    }
}

/**
 * AST node representing binary operations (operations with two operands)
 *
 * This node handles all binary operators including arithmetic, comparison,
 * and logical operations. It evaluates both operands and applies the
 * specified operator according to type compatibility rules.
 *
 * Supported operations:
 * - Arithmetic: 2 + 3, 5 * 4, 10 / 2, 7 - 1
 * - Comparison: x == 5, age >= 18, score != 0
 * - Logical: a && b, x || y, p xor q
 */
final class BinaryOpNode extends ASTNode {
    private final ASTNode left;
    private final ASTNode right;
    private final OperatorType op;

    public BinaryOpNode(ASTNode left, OperatorType op, ASTNode right) {
        this.left = left;
        this.right = right;
        this.op = op;
    }

    @Override
    public Value evaluate(IEnvironment environment) throws ExpressionException {
        Value lhs = left.evaluate(environment);
        Value rhs = right.evaluate(environment);

        // Boolean logical operations - allow any types and convert to boolean
        if (op == OperatorType.AND || op == OperatorType.OR || op == OperatorType.XOR) {
            boolean a = lhs.asBoolean();
            boolean b = rhs.asBoolean();
            switch (op) {
                case AND: return new Value(a && b);
                case OR: return new Value(a || b);
                case XOR: return new Value(a != b);
                default: break; // Should not reach here
            }
        }

        // String operations
        if (lhs.isString() || rhs.isString()) {
            switch (op) {
                case ADD: {
                    // String concatenation: convert both operands to strings
                    return new Value(lhs.asString() + rhs.asString());
                }
                case EQ: {
                    // String equality comparison
                    if (lhs.isString() && rhs.isString()) {
                        return new Value(lhs.asString().equals(rhs.asString()));
                    }
                    // Different types are not equal
                    return new Value(false);
                }
                case NE: {
                    // String inequality comparison
                    if (lhs.isString() && rhs.isString()) {
                        return new Value(!lhs.asString().equals(rhs.asString()));
                    }
                    // Different types are not equal
                    return new Value(true);
                }
                case GT:
                case LT:
                case GE:
                case LE: {
                    // String comparison: both operands must be strings
                    if (lhs.isString() && rhs.isString()) {
                        String a = lhs.asString();
                        String b = rhs.asString();
                        int comparison = a.compareTo(b);
                        switch (op) {
                            case GT: return new Value(comparison > 0);
                            case LT: return new Value(comparison < 0);
                            case GE: return new Value(comparison >= 0);
                            case LE: return new Value(comparison <= 0);
                            default: break;
                        }
                    }
                    throw new ExpressionException("String comparison operators require two string operands");
                }
                case IN: {
                    // String contains check: check if left operand is contained in right operand
                    if (lhs.isString() && rhs.isString()) {
                        String needle = lhs.asString();
                        String haystack = rhs.asString();
                        return new Value(haystack.contains(needle));
                    }
                    throw new ExpressionException("in operator requires two string operands");
                }
                default:
                    throw new ExpressionException("Unsupported string operator");
            }
        }

        // Numeric operations
        if (lhs.isNumber() && rhs.isNumber()) {
            double a = lhs.asNumber();
            double b = rhs.asNumber();
            switch (op) {
                case ADD: return new Value(a + b);
                case SUB: return new Value(a - b);
                case MUL: return new Value(a * b);
                case DIV:
                    if (b == 0) throw new ExpressionException.DivisionByZeroException();
                    return new Value(a / b);
                case GT: return new Value(a > b);
                case LT: return new Value(a < b);
                case GE: return new Value(a >= b);
                case LE: return new Value(a <= b);
                case EQ: return new Value(a == b);
                case NE: return new Value(a != b);
                default:
                    throw new ExpressionException("Unsupported numeric operator");
            }
        }
        // Strict boolean operations (equality/inequality) require both to be boolean
        else if (lhs.isBoolean() && rhs.isBoolean()) {
            boolean a = lhs.asBoolean();
            boolean b = rhs.asBoolean();
            switch (op) {
                case EQ: return new Value(a == b);
                case NE: return new Value(a != b);
                default:
                    throw new ExpressionException("Unsupported boolean operator");
            }
        }

        throw new ExpressionException("Unsupported operand types");
    }
}

/**
 * AST node representing unary operations (operations with one operand)
 *
 * This node handles unary operators that operate on a single value:
 * - Logical NOT: !condition, not flag
 * - Arithmetic negation: -number, -expression
 *
 * Examples: !true, -42, -(x + y), not visible
 */
final class UnaryOpNode extends ASTNode {
    private final ASTNode operand;
    private final OperatorType op;

    public UnaryOpNode(OperatorType op, ASTNode operand) {
        this.operand = operand;
        this.op = op;
    }

    @Override
    public Value evaluate(IEnvironment environment) throws ExpressionException {
        Value val = operand.evaluate(environment);

        switch (op) {
            case NOT:
                // NOT operator can work with any type - convert to boolean first
                return new Value(!val.asBoolean());
            case SUB: // Negation
                if (!val.isNumber()) {
                    throw new ExpressionException("Negation can only be used with numbers");
                }
                return new Value(-val.asNumber());
            default:
                throw new ExpressionException("Unsupported unary operator");
        }
    }
}

/**
 * AST node representing ternary operations (condition ? true_expr : false_expr)
 *
 * This node handles the ternary conditional operator (? :).
 * The condition is evaluated using asBoolean() to support any value type.
 *
 * Example: 
 * - condition ? value1 : value2
 */
final class TernaryOpNode extends ASTNode {
    private final ASTNode condition;
    private final ASTNode trueExpr;
    private final ASTNode falseExpr;
    private final OperatorType op;

    public TernaryOpNode(ASTNode condition, ASTNode trueExpr, ASTNode falseExpr, OperatorType op) {
        this.condition = condition;
        this.trueExpr = trueExpr;
        this.falseExpr = falseExpr;
        this.op = op;
    }

    @Override
    public Value evaluate(IEnvironment environment) throws ExpressionException {
        switch (op) {
            case TERNARY: {
                // Standard ternary: condition ? trueExpr : falseExpr
                Value condValue = condition.evaluate(environment);
                if (condValue.asBoolean()) {
                    return trueExpr.evaluate(environment);
                } else {
                    return falseExpr.evaluate(environment);
                }
            }
            default:
                throw new ExpressionException("Unsupported ternary operator");
        }
    }
}

/**
 * AST node representing function calls
 *
 * This node stores a function name and a list of argument expressions.
 * During evaluation, it evaluates all arguments and delegates to the
 * IEnvironment to perform the actual function call.
 *
 * Examples: max(a, b), sqrt(x), distance(x1, y1, x2, y2)
 */
final class FunctionCallNode extends ASTNode {
    private final String name;
    private final List<ASTNode> args;

    public FunctionCallNode(String name, List<ASTNode> args) {
        this.name = name;
        this.args = new ArrayList<>(args);
    }

    @Override
    public Value evaluate(IEnvironment environment) throws ExpressionException {
        List<Value> evaluatedArgs = new ArrayList<>();
        for (ASTNode arg : args) {
            evaluatedArgs.add(arg.evaluate(environment));
        }

        // First try standard mathematical functions (works without environment)
        Value standardResult = StandardFunctions.call(name, evaluatedArgs);
        if (standardResult != null) {
            return standardResult;
        }

        // If not a standard function, require environment
        if (environment == null) {
            throw new ExpressionException.UnknownFunctionException(name);
        }
        return environment.call(name, evaluatedArgs);
    }
}