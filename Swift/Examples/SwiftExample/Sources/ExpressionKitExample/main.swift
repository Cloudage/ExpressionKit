import ExpressionKit
import Foundation

// Example: High-Performance Game Logic with ExpressionKit
@main
struct ExpressionKitExample {
    static func main() {
        print("🚀 ExpressionKit Swift Example")
        print("=" * 50)
        
        // Basic expression evaluation
        basicExpressions()
        
        // Performance demonstration
        performanceDemo()
        
        // Game logic simulation
        gameLogicDemo()
    }
    
    static func basicExpressions() {
        print("\n📊 Basic Expression Evaluation:")
        
        let expressions = [
            "2 + 3 * 4",
            "(5 + 3) * 2 - 1", 
            "true && false",
            "5 > 3 && 2 == 2",
            "!false || true",
            "10 / 2 + 3 * 4"
        ]
        
        for expr in expressions {
            do {
                let result = try ExpressionKit.evaluate(expr)
                print("  \(expr) = \(result)")
            } catch {
                print("  \(expr) = ERROR: \(error)")
            }
        }
    }
    
    static func performanceDemo() {
        print("\n⚡ Performance Demonstration:")
        print("Comparing direct evaluation vs. parse-once-execute-many...")
        
        let _ = "(health + armor * 0.5) / maxHealth > 0.3 && isAlive"
        let iterations = 100_000
        
        // Method 1: Parse every time (slow)
        let start1 = Date()
        for _ in 0..<iterations {
            // This would fail because we don't have variables, but shows the pattern
            do {
                let _ = try ExpressionKit.parse("2 + 3 * 4")  // Simulating parse overhead
            } catch {
                // Expected to fail
            }
        }
        let time1 = Date().timeIntervalSince(start1)
        
        // Method 2: Parse once, execute many (fast)
        let start2 = Date()
        do {
            let expression = try ExpressionKit.parse("2 + 3 * 4")
            for _ in 0..<iterations {
                let _ = try expression.evaluate()
            }
        } catch {
            print("  Error in method 2: \(error)")
        }
        let time2 = Date().timeIntervalSince(start2)
        
        print("  Parse every time:     \(String(format: "%.4f", time1)) seconds")
        print("  Parse once, exec many: \(String(format: "%.4f", time2)) seconds")
        print("  Speedup: \(String(format: "%.1fx", time1 / time2)) faster!")
    }
    
    static func gameLogicDemo() {
        print("\n🎮 Game Logic Simulation:")
        
        // Pre-compile common game expressions
        let expressions = [
            ("Health Check", try! ExpressionKit.parse("100 > 50")),
            ("Damage Calculation", try! ExpressionKit.parse("10 + 5 * 2")),
            ("Level Up Condition", try! ExpressionKit.parse("1000 >= 500")),
            ("Critical Hit", try! ExpressionKit.parse("true && false")),
            ("Skill Cooldown", try! ExpressionKit.parse("30 - 25 <= 10"))
        ]
        
        // Simulate game loop
        print("  Simulating 1000 game frames...")
        let startTime = Date()
        
        for frame in 1...1000 {
            for (name, expression) in expressions {
                do {
                    let result = try expression.evaluate()
                    // In a real game, you'd use these results for game logic
                    if frame == 1 {  // Only print first frame results
                        print("    Frame 1 - \(name): \(result)")
                    }
                } catch {
                    print("    Error in \(name): \(error)")
                }
            }
        }
        
        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)
        print("  ✅ Completed 1000 frames in \(String(format: "%.4f", totalTime)) seconds")
        print("  📈 Average: \(String(format: "%.6f", totalTime / 1000)) seconds per frame")
    }
}

// String multiplication extension for prettier output
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}