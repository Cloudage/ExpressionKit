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
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SimpleEnvironment = exports.Expression = exports.CompiledExpression = exports.callStandardFunctions = exports.FunctionCallNode = exports.BinaryOpNode = exports.UnaryOpNode = exports.VariableNode = exports.StringNode = exports.BooleanNode = exports.NumberNode = exports.ASTNode = exports.Value = exports.ValueType = exports.ExpressionError = exports.TokenType = void 0;
/**
 * ExpressionKit for TypeScript
 *
 * A lightweight, interface-driven expression parser and evaluator translated 1:1
 * from the C++ ExpressionKit implementation.
 */
// Re-export all public API
var ExpressionKit_1 = require("./ExpressionKit");
Object.defineProperty(exports, "TokenType", { enumerable: true, get: function () { return ExpressionKit_1.TokenType; } });
Object.defineProperty(exports, "ExpressionError", { enumerable: true, get: function () { return ExpressionKit_1.ExpressionError; } });
Object.defineProperty(exports, "ValueType", { enumerable: true, get: function () { return ExpressionKit_1.ValueType; } });
Object.defineProperty(exports, "Value", { enumerable: true, get: function () { return ExpressionKit_1.Value; } });
Object.defineProperty(exports, "ASTNode", { enumerable: true, get: function () { return ExpressionKit_1.ASTNode; } });
Object.defineProperty(exports, "NumberNode", { enumerable: true, get: function () { return ExpressionKit_1.NumberNode; } });
Object.defineProperty(exports, "BooleanNode", { enumerable: true, get: function () { return ExpressionKit_1.BooleanNode; } });
Object.defineProperty(exports, "StringNode", { enumerable: true, get: function () { return ExpressionKit_1.StringNode; } });
Object.defineProperty(exports, "VariableNode", { enumerable: true, get: function () { return ExpressionKit_1.VariableNode; } });
Object.defineProperty(exports, "UnaryOpNode", { enumerable: true, get: function () { return ExpressionKit_1.UnaryOpNode; } });
Object.defineProperty(exports, "BinaryOpNode", { enumerable: true, get: function () { return ExpressionKit_1.BinaryOpNode; } });
Object.defineProperty(exports, "FunctionCallNode", { enumerable: true, get: function () { return ExpressionKit_1.FunctionCallNode; } });
Object.defineProperty(exports, "callStandardFunctions", { enumerable: true, get: function () { return ExpressionKit_1.callStandardFunctions; } });
Object.defineProperty(exports, "CompiledExpression", { enumerable: true, get: function () { return ExpressionKit_1.CompiledExpression; } });
Object.defineProperty(exports, "Expression", { enumerable: true, get: function () { return ExpressionKit_1.Expression; } });
var SimpleEnvironment_1 = require("./SimpleEnvironment");
Object.defineProperty(exports, "SimpleEnvironment", { enumerable: true, get: function () { return SimpleEnvironment_1.SimpleEnvironment; } });
