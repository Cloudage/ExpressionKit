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
 * NOTE: This is a demonstration application for the C# ExpressionKit library.
 */

using System;
using System.Collections.Generic;
using ExpressionKit;

namespace ExpressionKitDemo
{
    /// <summary>
    /// Interactive demo application for ExpressionKit C#
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("🚀 ExpressionKit C# Demo");
            Console.WriteLine("========================");
            Console.WriteLine();

            // Demo environment with some variables and functions
            var environment = new SimpleEnvironment();
            environment.SetVariable("x", 10.0);
            environment.SetVariable("y", 5.0);
            environment.SetVariable("pi", 3.14159);
            environment.SetVariable("isActive", true);
            
            // Add a custom function
            environment.SetFunction("double", args => 
            {
                if (args.Count != 1 || !args[0].IsNumber)
                    throw new ExpressionException("double function requires one numeric parameter");
                return new Value(args[0].AsNumber() * 2);
            });

            // Demo expressions
            var demoExpressions = new[]
            {
                "2 + 3 * 4",
                "x + y * 2", 
                "sqrt(x) + abs(-5)",
                "max(x, y) * min(3, 7)",
                "(x > y) && isActive",
                "isActive ? \"Yes\" : \"No\"",
                "double(x) / 4",
                "pi * 2 * 3",
                "\"Hello \" + \"World\"",
                "pow(2, 3) + floor(3.7)"
            };

            Console.WriteLine("📋 Pre-built Examples:");
            Console.WriteLine("======================");
            
            for (int i = 0; i < demoExpressions.Length; i++)
            {
                try
                {
                    string expr = demoExpressions[i];
                    var tokens = new List<Token>();
                    var result = Expression.Eval(expr, environment, tokens);
                    
                    Console.WriteLine($"{i + 1:D2}. {expr}");
                    Console.WriteLine($"    Result: {result} (Type: {result.Type})");
                    Console.WriteLine($"    Tokens: {tokens.Count}");
                    Console.WriteLine();
                }
                catch (ExpressionException ex)
                {
                    Console.WriteLine($"{i + 1:D2}. {demoExpressions[i]}");
                    Console.WriteLine($"    Error: {ex.Message}");
                    Console.WriteLine();
                }
            }

            // Interactive mode
            Console.WriteLine("🎮 Interactive Mode:");
            Console.WriteLine("====================");
            Console.WriteLine("Available variables: x=10, y=5, pi=3.14159, isActive=true");
            Console.WriteLine("Available functions: All standard math functions + double(n)");
            Console.WriteLine("Type 'exit' to quit, 'help' for examples");
            Console.WriteLine();

            while (true)
            {
                Console.Write("Expression> ");
                string? input = Console.ReadLine()?.Trim();

                if (string.IsNullOrEmpty(input))
                    continue;

                if (input.Equals("exit", StringComparison.OrdinalIgnoreCase))
                    break;

                if (input.Equals("help", StringComparison.OrdinalIgnoreCase))
                {
                    ShowHelp();
                    continue;
                }

                try
                {
                    var tokens = new List<Token>();
                    var result = Expression.Eval(input, environment, tokens);
                    
                    Console.WriteLine($"✅ Result: {result} (Type: {result.Type})");
                    Console.WriteLine($"   Tokens: {tokens.Count} parsed");
                    Console.WriteLine();
                }
                catch (ExpressionException ex)
                {
                    Console.WriteLine($"❌ Error: {ex.Message}");
                    Console.WriteLine();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"💥 Unexpected error: {ex.Message}");
                    Console.WriteLine();
                }
            }

            Console.WriteLine("👋 Thanks for using ExpressionKit C#!");
        }

        static void ShowHelp()
        {
            Console.WriteLine();
            Console.WriteLine("📚 Help - Expression Examples:");
            Console.WriteLine("===============================");
            Console.WriteLine("Arithmetic:    2 + 3 * 4, (1 + 2) * 3");
            Console.WriteLine("Variables:     x + y, x * pi");
            Console.WriteLine("Functions:     sqrt(16), max(x, y), sin(pi/2)");
            Console.WriteLine("Comparisons:   x > y, x == 10");
            Console.WriteLine("Logic:         x > 5 && isActive, !isActive");
            Console.WriteLine("Ternary:       x > y ? \"bigger\" : \"smaller\"");
            Console.WriteLine("Strings:       \"Hello \" + \"World\"");
            Console.WriteLine("Custom:        double(5)");
            Console.WriteLine();
            Console.WriteLine("Math Functions: sin, cos, tan, sqrt, abs, pow, log, exp, floor, ceil, round, min, max");
            Console.WriteLine("Operators:      +, -, *, /, ==, !=, <, >, <=, >=, &&, ||, !, and, or, not, xor, ?:");
            Console.WriteLine();
        }
    }
}