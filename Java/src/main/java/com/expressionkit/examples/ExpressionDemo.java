/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 */

package com.expressionkit.examples;

import com.expressionkit.*;
import java.util.List;
import java.util.Scanner;

/**
 * Interactive demonstration of ExpressionKit Java implementation
 * 
 * This demo provides an interactive CLI interface for testing expression evaluation,
 * variable management, and token analysis - similar to the C++ ExpressionDemo.
 */
public class ExpressionDemo {
    private final SimpleEnvironment environment;
    private final Scanner scanner;

    public ExpressionDemo() {
        this.environment = new SimpleEnvironment();
        this.scanner = new Scanner(System.in);
        
        // Initialize with some default variables and constants
        environment.set("pi", Math.PI);
        environment.set("e", Math.E);
        environment.set("x", 10.0);
        environment.set("y", 20.0);
    }

    public void run() {
        System.out.println("🚀 ExpressionKit Java Interactive Demo");
        System.out.println("=======================================");
        System.out.println();
        System.out.println("Available commands:");
        System.out.println("  eval <expression>     - Evaluate an expression");
        System.out.println("  set <var> <expr>      - Set a variable to expression result");
        System.out.println("  del <var>             - Delete a variable");
        System.out.println("  ls                    - List all variables");
        System.out.println("  tokens <expression>   - Show token analysis");
        System.out.println("  help                  - Show this help");
        System.out.println("  quit                  - Exit the demo");
        System.out.println();
        System.out.println("Expression syntax:");
        System.out.println("  Numbers:    42, 3.14, -2.5");
        System.out.println("  Booleans:   true, false");
        System.out.println("  Strings:    \"hello\", \"world\"");
        System.out.println("  Operators:  +, -, *, /, ==, !=, <, >, <=, >=, &&, ||, !, xor");
        System.out.println("  Functions:  min, max, sqrt, sin, cos, tan, abs, pow, log, exp, floor, ceil, round");
        System.out.println("  Variables:  x, y, pi, e (and any you define)");
        System.out.println();

        while (true) {
            System.out.print("> ");
            String line = scanner.nextLine().trim();
            
            if (line.isEmpty()) continue;
            
            try {
                if (line.equals("quit") || line.equals("exit") || line.equals("q")) {
                    break;
                } else if (line.equals("help") || line.equals("h")) {
                    showHelp();
                } else if (line.equals("ls")) {
                    listVariables();
                } else if (line.startsWith("eval ")) {
                    evaluateExpression(line.substring(5));
                } else if (line.startsWith("set ")) {
                    setVariable(line.substring(4));
                } else if (line.startsWith("del ")) {
                    deleteVariable(line.substring(4));
                } else if (line.startsWith("tokens ")) {
                    analyzeTokens(line.substring(7));
                } else {
                    // Treat as direct expression evaluation
                    evaluateExpression(line);
                }
            } catch (Exception e) {
                System.err.println("❌ Error: " + e.getMessage());
            }
        }
        
        System.out.println("👋 Thanks for using ExpressionKit Java Demo!");
    }

    private void evaluateExpression(String expression) {
        try {
            Value result = Expression.eval(expression, environment);
            
            System.out.printf("✅ Result: %s", formatValue(result));
            
            // Show type information
            if (result.isNumber()) {
                System.out.printf(" (Number)%n");
            } else if (result.isBoolean()) {
                System.out.printf(" (Boolean)%n");
            } else if (result.isString()) {
                System.out.printf(" (String)%n");
            }
            
        } catch (ExpressionException e) {
            System.err.println("❌ Expression Error: " + e.getMessage());
        }
    }

    private void setVariable(String command) {
        String[] parts = command.split("\\s+", 2);
        if (parts.length != 2) {
            System.err.println("❌ Usage: set <variable> <expression>");
            return;
        }
        
        String varName = parts[0];
        String expression = parts[1];
        
        try {
            Value result = Expression.eval(expression, environment);
            environment.set(varName, result);
            System.out.printf("✅ Set %s = %s%n", varName, formatValue(result));
        } catch (ExpressionException e) {
            System.err.println("❌ Expression Error: " + e.getMessage());
        }
    }

    private void deleteVariable(String varName) {
        if (environment.remove(varName)) {
            System.out.printf("✅ Deleted variable: %s%n", varName);
        } else {
            System.err.printf("❌ Variable not found: %s%n", varName);
        }
    }

    private void listVariables() {
        if (environment.size() == 0) {
            System.out.println("📝 No variables defined");
            return;
        }
        
        System.out.printf("📝 Variables (%d total):%n", environment.size());
        for (String name : environment.getVariableNames()) {
            try {
                Value value = environment.get(name);
                System.out.printf("  %s = %s%n", name, formatValue(value));
            } catch (ExpressionException e) {
                System.out.printf("  %s = <error: %s>%n", name, e.getMessage());
            }
        }
    }

    private void analyzeTokens(String expression) {
        try {
            Expression.EvalResult result = Expression.evalWithTokens(expression, environment);
            
            System.out.printf("✅ Result: %s%n", formatValue(result.getValue()));
            System.out.println("🔍 Token Analysis:");
            
            List<Token> tokens = result.getTokens();
            for (int i = 0; i < tokens.size(); i++) {
                Token token = tokens.get(i);
                String typeColor = getTokenTypeColor(token.getType());
                System.out.printf("  %2d: %s%-12s%s '%s' at %d:%d%n",
                    i + 1,
                    typeColor,
                    token.getType(),
                    "\u001B[0m", // Reset color
                    token.getText(),
                    token.getStart(),
                    token.getLength());
            }
            
        } catch (ExpressionException e) {
            System.err.println("❌ Expression Error: " + e.getMessage());
        }
    }

    private String getTokenTypeColor(TokenType type) {
        switch (type) {
            case NUMBER: return "\u001B[36m"; // Cyan
            case BOOLEAN: return "\u001B[35m"; // Magenta  
            case STRING: return "\u001B[32m"; // Green
            case IDENTIFIER: return "\u001B[33m"; // Yellow
            case OPERATOR: return "\u001B[31m"; // Red
            case PARENTHESIS: return "\u001B[34m"; // Blue
            case COMMA: return "\u001B[37m"; // White
            case WHITESPACE: return "\u001B[90m"; // Gray
            default: return "\u001B[0m"; // Reset
        }
    }

    private String formatValue(Value value) {
        try {
            if (value.isNumber()) {
                double num = value.asNumber();
                if (num == Math.floor(num) && !Double.isInfinite(num)) {
                    return String.format("%.0f", num);
                }
                return String.valueOf(num);
            } else if (value.isBoolean()) {
                return String.valueOf(value.asBoolean());
            } else if (value.isString()) {
                return "\"" + value.asString() + "\"";
            }
        } catch (ExpressionException.TypeException e) {
            return "<invalid value>";
        }
        return value.toString();
    }

    private void showHelp() {
        System.out.println("📖 ExpressionKit Java Demo Help");
        System.out.println("=================================");
        System.out.println();
        System.out.println("Commands:");
        System.out.println("  eval <expr>    - Evaluate expression and show result");
        System.out.println("  set <var> <expr> - Set variable to expression result");
        System.out.println("  del <var>      - Delete a variable");
        System.out.println("  ls             - List all variables and values");
        System.out.println("  tokens <expr>  - Show token analysis with syntax highlighting");
        System.out.println("  help           - Show this help message");
        System.out.println("  quit           - Exit the demo");
        System.out.println();
        System.out.println("Examples:");
        System.out.println("  eval 2 + 3 * 4");
        System.out.println("  set radius 5");
        System.out.println("  eval pi * pow(radius, 2)");
        System.out.println("  tokens \"hello\" + \" world\"");
        System.out.println("  eval sqrt(x*x + y*y)");
        System.out.println("  set name \"ExpressionKit\"");
        System.out.println("  eval name == \"ExpressionKit\"");
        System.out.println();
    }

    public static void main(String[] args) {
        ExpressionDemo demo = new ExpressionDemo();
        demo.run();
    }
}