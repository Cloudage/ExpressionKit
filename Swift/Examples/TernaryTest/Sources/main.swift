import Foundation
import ExpressionKit

@main
struct TernaryTest {
    static func main() {
        print("=== Testing Ternary Operators ===")

        do {
            // Test basic ternary
            let result1 = try Expression.eval("true ? 42 : 0")
            print("true ? 42 : 0 = \(result1)")

            let result2 = try Expression.eval("false ? 42 : 0") 
            print("false ? 42 : 0 = \(result2)")

            // Test with expressions
            let result3 = try Expression.eval("2 > 1 ? \"yes\" : \"no\"")
            print("2 > 1 ? \"yes\" : \"no\" = \(result3)")

            let result4 = try Expression.eval("2 < 1 ? \"yes\" : \"no\"")
            print("2 < 1 ? \"yes\" : \"no\" = \(result4)")

            // Test null coalescing
            let result5 = try Expression.eval("true ?? \"fallback\"")
            print("true ?? \"fallback\" = \(result5)")

            let result6 = try Expression.eval("false ?? \"fallback\"")
            print("false ?? \"fallback\" = \(result6)")

            let result7 = try Expression.eval("0 ?? 99")
            print("0 ?? 99 = \(result7)")

            let result8 = try Expression.eval("5 ?? 99")
            print("5 ?? 99 = \(result8)")

            // Test nested
            let result9 = try Expression.eval("true ? false ? 1 : 2 : 3")
            print("true ? false ? 1 : 2 : 3 = \(result9)")

            let result10 = try Expression.eval("false ? 1 : true ? 2 : 3")
            print("false ? 1 : true ? 2 : 3 = \(result10)")

            // Test precedence
            let result11 = try Expression.eval("false ?? true ? 100 : 200")
            print("false ?? true ? 100 : 200 = \(result11)")

            print("=== All tests completed successfully! ===")
        } catch {
            print("Error: \(error)")
        }
    }
}