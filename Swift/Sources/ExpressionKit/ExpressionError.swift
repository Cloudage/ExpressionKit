// This file provides backward compatibility for the old ExpressionError enum
// The actual ExpressionError implementation is now in ExpressionKit.swift

// Re-export ExpressionError from ExpressionKit.swift - it's already defined there
// No additional code needed as ExpressionError is already public in ExpressionKit.swift

// For backward compatibility, add aliases for the old error case names
extension ExpressionError {
    /// Create a parseFailed error (backward compatibility)
    public static func parseFailed(_ message: String) -> ExpressionError {
        return .parseError(message)
    }
    
    /// Create an evaluationFailed error (backward compatibility)
    public static func evaluationFailed(_ message: String) -> ExpressionError {
        return .evaluationError(message)
    }
    
    /// Create a typeMismatch error (backward compatibility)
    public static func typeMismatch(_ message: String) -> ExpressionError {
        return .typeError(message)
    }
    
    /// Create an environmentError error (backward compatibility)
    public static func environmentError(_ message: String) -> ExpressionError {
        return .evaluationError(message)
    }
    
    /// Create an unknownError error (backward compatibility)
    public static func unknownError(_ message: String) -> ExpressionError {
        return .evaluationError(message)
    }
}