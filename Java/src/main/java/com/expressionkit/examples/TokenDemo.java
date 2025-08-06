/*
 * MIT License
 *
 * Copyright (c) 2025 ExpressionKit Contributors
 */

package com.expressionkit.examples;

import com.expressionkit.*;
import java.util.List;

/**
 * Token analysis demonstration for ExpressionKit Java implementation
 * 
 * This demo shows how to collect and analyze tokens during expression parsing,
 * useful for syntax highlighting, IDE integration, and advanced expression analysis.
 */
public class TokenDemo {

    public static void main(String[] args) {
        System.out.println("🎨 ExpressionKit Java Token Analysis Demo");
        System.out.println("=========================================");
        System.out.println();

        // Test expressions with different token types
        String[] testExpressions = {
            "2 + 3 * 4",
            "true && (5 > 3)",
            "\"hello\" + \" world\"",
            "max(x, sqrt(y))",
            "condition ? value1 : value2",
            "pi * pow(radius, 2)",
            "name == \"ExpressionKit\" and active",
            "!(x < 0) or (y >= 10)",
            "floor(3.7) + ceil(2.1)"
        };

        SimpleEnvironment environment = new SimpleEnvironment();
        environment.set("x", 5.0);
        environment.set("y", 16.0);
        environment.set("pi", Math.PI);
        environment.set("radius", 3.0);
        environment.set("name", "ExpressionKit");
        environment.set("active", true);
        environment.set("condition", false);
        environment.set("value1", 10);
        environment.set("value2", 20);

        for (int i = 0; i < testExpressions.length; i++) {
            String expression = testExpressions[i];
            
            System.out.printf("📝 Expression %d: %s%n", i + 1, expression);
            System.out.println("─".repeat(50));

            try {
                // Parse and evaluate with token collection
                Expression.EvalResult result = Expression.evalWithTokens(expression, environment);
                
                // Show evaluation result
                System.out.printf("✅ Result: %s (%s)%n", 
                    formatValue(result.getValue()), 
                    getTypeName(result.getValue()));
                
                System.out.println();
                System.out.println("🔍 Token Breakdown:");
                
                // Analyze tokens
                List<Token> tokens = result.getTokens();
                analyzeTokens(tokens, expression);
                
                System.out.println();
                showSyntaxHighlighting(tokens, expression);
                
            } catch (ExpressionException e) {
                System.err.println("❌ Error: " + e.getMessage());
            }
            
            System.out.println();
            System.out.println("═".repeat(70));
            System.out.println();
        }

        System.out.println("📊 Token Analysis Summary");
        System.out.println("=========================");
        System.out.println();
        System.out.println("Token Types and Their Uses:");
        System.out.println("  🔢 NUMBER      - Numeric literals (42, 3.14, -2.5)");
        System.out.println("  🔘 BOOLEAN     - Boolean literals (true, false)");
        System.out.println("  📝 STRING      - String literals (\"hello\", \"world\")");
        System.out.println("  🏷️  IDENTIFIER  - Variables and functions (x, sqrt, max)");
        System.out.println("  ⚙️  OPERATOR    - All operators (+, -, ==, &&, etc.)");
        System.out.println("  🎯 PARENTHESIS - Grouping symbols ( )");
        System.out.println("  📍 COMMA       - Function argument separator");
        System.out.println("  ⬜ WHITESPACE  - Spaces and tabs (for formatting)");
        System.out.println();
        System.out.println("💡 Use Cases:");
        System.out.println("  • Syntax highlighting in code editors");
        System.out.println("  • Error reporting with precise locations");
        System.out.println("  • Auto-completion suggestions");
        System.out.println("  • Expression validation before evaluation");
        System.out.println("  • Static analysis and complexity metrics");
        System.out.println("  • Pretty-printing and code formatting");
    }

    private static void analyzeTokens(List<Token> tokens, String expression) {
        int[] typeCounts = new int[TokenType.values().length];
        
        System.out.printf("%-4s %-12s %-20s %-10s %-8s%n", 
            "#", "Type", "Text", "Position", "Length");
        System.out.println("─".repeat(60));
        
        for (int i = 0; i < tokens.size(); i++) {
            Token token = tokens.get(i);
            typeCounts[token.getType().getValue()]++;
            
            String typeColor = getTokenTypeColor(token.getType());
            String resetColor = "\u001B[0m";
            
            System.out.printf("%-4d %s%-12s%s %-20s %-10s %-8d%n",
                i + 1,
                typeColor,
                token.getType(),
                resetColor,
                "\"" + escapeString(token.getText()) + "\"",
                token.getStart() + ":" + (token.getStart() + token.getLength()),
                token.getLength());
        }
        
        System.out.println();
        System.out.println("📈 Token Statistics:");
        for (TokenType type : TokenType.values()) {
            int count = typeCounts[type.getValue()];
            if (count > 0) {
                String typeColor = getTokenTypeColor(type);
                System.out.printf("  %s%s%s: %d%n", 
                    typeColor, type, "\u001B[0m", count);
            }
        }
    }

    private static void showSyntaxHighlighting(List<Token> tokens, String expression) {
        System.out.println("🎨 Syntax Highlighting Preview:");
        
        StringBuilder highlighted = new StringBuilder();
        int lastEnd = 0;
        
        for (Token token : tokens) {
            // Add any gaps (shouldn't happen in practice)
            if (token.getStart() > lastEnd) {
                highlighted.append(expression, lastEnd, token.getStart());
            }
            
            // Add colored token
            String color = getTokenTypeColor(token.getType());
            highlighted.append(color)
                      .append(token.getText())
                      .append("\u001B[0m"); // Reset color
            
            lastEnd = token.getStart() + token.getLength();
        }
        
        // Add any remaining text
        if (lastEnd < expression.length()) {
            highlighted.append(expression.substring(lastEnd));
        }
        
        System.out.println("  " + highlighted.toString());
    }

    private static String getTokenTypeColor(TokenType type) {
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

    private static String formatValue(Value value) {
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
            return "<invalid>";
        }
        return value.toString();
    }

    private static String getTypeName(Value value) {
        if (value.isNumber()) return "Number";
        if (value.isBoolean()) return "Boolean";
        if (value.isString()) return "String";
        return "Unknown";
    }

    private static String escapeString(String str) {
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\t", "\\t")
                  .replace("\r", "\\r");
    }
}