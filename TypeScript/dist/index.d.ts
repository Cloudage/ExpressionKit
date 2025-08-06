/**
 * ExpressionKit for TypeScript
 *
 * A lightweight, interface-driven expression parser and evaluator translated 1:1
 * from the C++ ExpressionKit implementation.
 */
export { TokenType, Token, ExpressionError, ValueType, Value, IEnvironment, ASTNode, NumberNode, BooleanNode, StringNode, VariableNode, UnaryOpNode, BinaryOpNode, FunctionCallNode, callStandardFunctions, CompiledExpression, Expression } from './ExpressionKit';
export { SimpleEnvironment } from './SimpleEnvironment';
