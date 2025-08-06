/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 *
 * ExpressionKit TypeScript Example
 * 
 * This example demonstrates the TypeScript implementation of ExpressionKit
 * and shows equivalence with the C++ and Swift versions.
 */

import {
    Expression,
    Value,
    SimpleEnvironment,
    TokenType
} from '../src/index';

console.log('🚀 ExpressionKit TypeScript Example\n');

// Basic arithmetic
console.log('📊 Basic Arithmetic:');
console.log(`  2 + 3 * 4 = ${Expression.evalSimple('2 + 3 * 4').asNumber()}`);
console.log(`  (2 + 3) * 4 = ${Expression.evalSimple('(2 + 3) * 4').asNumber()}`);
console.log(`  15 / 3 = ${Expression.evalSimple('15 / 3').asNumber()}`);

// Boolean expressions  
console.log('\n🔗 Boolean Logic:');
console.log(`  true && (5 > 3) = ${Expression.evalSimple('true && (5 > 3)').asBoolean()}`);
console.log(`  false || (10 != 5) = ${Expression.evalSimple('false || (10 != 5)').asBoolean()}`);
console.log(`  !true = ${Expression.evalSimple('!true').asBoolean()}`);

// String expressions
console.log('\n📝 String Literals:');
console.log(`  "Hello, World!" = "${Expression.evalSimple('"Hello, World!"').asString()}"`);
console.log(`  "" = "${Expression.evalSimple('""').asString()}"`);

// Mathematical functions
console.log('\n🧮 Mathematical Functions:');
console.log(`  sqrt(16) = ${Expression.evalSimple('sqrt(16)').asNumber()}`);
console.log(`  max(10, 5) = ${Expression.evalSimple('max(10, 5)').asNumber()}`);
console.log(`  min(10, 5) = ${Expression.evalSimple('min(10, 5)').asNumber()}`);
console.log(`  pow(2, 3) = ${Expression.evalSimple('pow(2, 3)').asNumber()}`);
console.log(`  abs(-42) = ${Expression.evalSimple('abs(-42)').asNumber()}`);

// Complex expressions
console.log('\n🔥 Complex Expressions:');
console.log(`  sqrt(pow(3, 2) + pow(4, 2)) = ${Expression.evalSimple('sqrt(pow(3, 2) + pow(4, 2))').asNumber()}`);
console.log(`  max(min(10, 5), 3) = ${Expression.evalSimple('max(min(10, 5), 3)').asNumber()}`);

// Using variables with SimpleEnvironment
console.log('\n🎯 Variable Environment:');
const env = new SimpleEnvironment();
env.setVariable('health', new Value(75));
env.setVariable('maxHealth', new Value(100));
env.setVariable('level', new Value(8));
env.setVariable('pos.x', new Value(10.5));
env.setVariable('pos.y', new Value(20.3));

console.log(`  health = ${env.get('health').asNumber()}`);
console.log(`  maxHealth = ${env.get('maxHealth').asNumber()}`);
console.log(`  health / maxHealth = ${Expression.evalSimple('health / maxHealth', env).asNumber()}`);
console.log(`  health < maxHealth * 0.5 = ${Expression.evalSimple('health < maxHealth * 0.5', env).asBoolean()}`);
console.log(`  level > 0 && health > 0 = ${Expression.evalSimple('level > 0 && health > 0', env).asBoolean()}`);
console.log(`  pos.x = ${Expression.evalSimple('pos.x', env).asNumber()}`);
console.log(`  pos.y = ${Expression.evalSimple('pos.y', env).asNumber()}`);

// Pre-compiled expressions for performance  
console.log('\n⚡ Pre-compiled Expressions:');
const compiled = Expression.parse('(health / maxHealth) * 100');
console.log(`  Health percentage: ${compiled.evaluate(env).asNumber()}%`);

// Update variables and re-evaluate
env.setVariable('health', new Value(90));
console.log(`  After healing - Health percentage: ${compiled.evaluate(env).asNumber()}%`);

// Token collection for syntax highlighting
console.log('\n🎨 Token Analysis:');
const [result, tokens] = Expression.eval('max(pos.x + 5, pos.y * 2)', env, true);
console.log(`  Expression result: ${result.asNumber()}`);
if (tokens) {
    console.log('  Tokens collected:');
    tokens.forEach((token, i) => {
        const typeName = Object.keys(TokenType)[Object.values(TokenType).indexOf(token.type)];
        console.log(`    ${i + 1}. ${typeName}: "${token.text}" at ${token.start}:${token.length}`);
    });
}

// Error handling demonstration
console.log('\n❌ Error Handling:');
try {
    Expression.evalSimple('1 / 0');
} catch (error) {
    console.log(`  Division by zero: ${(error as Error).message}`);
}

try {
    Expression.evalSimple('unknown_variable', env);
} catch (error) {
    console.log(`  Unknown variable: ${(error as Error).message}`);
}

try {
    Expression.evalSimple('sqrt(-1)');
} catch (error) {
    console.log(`  Domain error: ${(error as Error).message}`);
}

console.log('\n✅ ExpressionKit TypeScript implementation complete!');