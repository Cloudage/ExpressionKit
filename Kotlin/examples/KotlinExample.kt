/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 *
 * Simple example demonstrating Kotlin ExpressionKit usage
 */

import com.expressionkit.*

fun main() {
    println("🧮 ExpressionKit Kotlin Example")
    println("===============================\n")
    
    // Basic arithmetic examples
    println("📊 Basic Arithmetic:")
    println("2 + 3 * 4 = ${Expression.eval("2 + 3 * 4")}")
    println("(2 + 3) * 4 = ${Expression.eval("(2 + 3) * 4")}")
    println("sqrt(16) + abs(-5) = ${Expression.eval("sqrt(16) + abs(-5)")}")
    println()
    
    // Boolean logic examples
    println("🔍 Boolean Logic:")
    println("true && false = ${Expression.eval("true && false")}")
    println("5 > 3 || 2 < 1 = ${Expression.eval("5 > 3 || 2 < 1")}")
    println("!(5 == 3) = ${Expression.eval("!(5 == 3)")}")
    println()
    
    // String operations
    println("📝 String Operations:")
    println("\"Hello\" + \" \" + \"World\" = ${Expression.eval("\"Hello\" + \" \" + \"World\"")}")
    println("\"Value: \" + 42 = ${Expression.eval("\"Value: \" + 42")}")
    println()
    
    // Using environment for variables
    println("🏗️  Using Variables:")
    val env = SimpleEnvironment()
    env.setVariable("x", 10.0)
    env.setVariable("y", 5.0)
    env.setVariable("name", "Alice")
    
    println("x = ${env.get("x")}")
    println("y = ${env.get("y")}")
    println("x + y = ${Expression.eval("x + y", env)}")
    println("x * y - 10 = ${Expression.eval("x * y - 10", env)}")
    println("\"Hello, \" + name = ${Expression.eval("\"Hello, \" + name", env)}")
    println()
    
    // Custom functions
    println("⚙️  Custom Functions:")
    env.setFunction("double") { args ->
        if (args.size != 1) throw ExpressionError("double() requires 1 argument")
        Value.number(args[0].asNumber() * 2)
    }
    
    env.setFunction("greet") { args ->
        if (args.size != 1) throw ExpressionError("greet() requires 1 argument")
        Value.string("Hello, ${args[0].asString()}!")
    }
    
    println("double(21) = ${Expression.eval("double(21)", env)}")
    println("greet(\"Kotlin\") = ${Expression.eval("greet(\"Kotlin\")", env)}")
    println()
    
    // Complex expressions
    println("🎯 Complex Expressions:")
    env.setVariable("health", 75.0)
    env.setVariable("maxHealth", 100.0)
    env.setVariable("level", 5.0)
    
    val isHealthy = Expression.eval("health > maxHealth * 0.5", env)
    val combatPower = Expression.eval("level * 10 + health", env)
    
    println("health > maxHealth * 0.5 = $isHealthy")
    println("level * 10 + health = $combatPower")
    println()
    
    // Token collection for syntax highlighting
    println("🌈 Token Analysis:")
    val expression = "2 + sqrt(x * y)"
    val (result, tokens) = Expression.eval(expression, env, collectTokens = true)
    
    println("Expression: $expression")
    println("Result: $result")
    println("Tokens:")
    for (token in tokens.filter { it.type != TokenType.WHITESPACE }) {
        println("  ${token.type}: '${token.text}' at position ${token.start}")
    }
    println()
    
    // Pre-parsed expressions for efficiency
    println("⚡ Pre-parsed Expressions:")
    val compiledExpr = Expression.parse("health / maxHealth * 100")
    
    for (i in 1..3) {
        env.setVariable("health", 25.0 * i)
        val percentage = compiledExpr.evaluate(env)
        println("Health at ${25 * i}: ${percentage.asNumber()}%")
    }
    
    println("\n✨ ExpressionKit Kotlin Demo Complete!")
}