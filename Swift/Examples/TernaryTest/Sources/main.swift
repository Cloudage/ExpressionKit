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

            // Test nested ternary
            let result5 = try Expression.eval("true ? false ? 1 : 2 : 3")
            print("true ? false ? 1 : 2 : 3 = \(result5)")

            let result6 = try Expression.eval("false ? 1 : true ? 2 : 3")
            print("false ? 1 : true ? 2 : 3 = \(result6)")

            // Test with complex expressions
            let result7 = try Expression.eval("(5 > 3) ? (2 * 10) : (1 + 1)")
            print("(5 > 3) ? (2 * 10) : (1 + 1) = \(result7)")

            let result8 = try Expression.eval("(1 > 3) ? (2 * 10) : (1 + 1)")
            print("(1 > 3) ? (2 * 10) : (1 + 1) = \(result8)")

            print("=== All tests completed successfully! ===")
        } catch {
            print("Error: \(error)")
        }
    }
}