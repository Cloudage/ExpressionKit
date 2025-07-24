import Foundation

/// Errors that can occur during expression parsing and evaluation
public enum ExpressionError: Error, LocalizedError {
    case parseFailed(String)
    case evaluationFailed(String)
    case typeMismatch(String)
    case backendError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .parseFailed(let message):
            return "Parse failed: \(message)"
        case .evaluationFailed(let message):
            return "Evaluation failed: \(message)"
        case .typeMismatch(let message):
            return "Type mismatch: \(message)"
        case .backendError(let message):
            return "Backend error: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}