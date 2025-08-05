# ExpressionKit Array and Dictionary Support Implementation Plans

## Overview

This document analyzes three main implementation approaches for adding array and dictionary support to ExpressionKit. Each approach considers the following key requirements:

- **Minimal Changes**: Modify existing code as little as possible
- **Backward Compatibility**: Ensure existing functionality remains unaffected
- **Swift Integration**: Maintain seamless integration with Swift Package Manager
- **Cross-Language Support**: Provide a solid foundation for future language bindings
- **Performance Considerations**: Avoid performance penalties for existing simple types

## Current Architecture Analysis

### Existing Value System
```cpp
struct Value {
    enum Type : int { NUMBER = 0, BOOLEAN = 1, STRING = 2 } type;
    union Data {
        double number;
        bool boolean;
    } data;
    std::string stringValue;  // String stored separately
};
```

### Key Design Constraints
1. **Memory Efficiency**: Current union ensures memory efficiency for basic types
2. **Type Safety**: Strong typing system with compile-time and runtime checks
3. **C++ Header Library**: Must maintain header independence
4. **Swift Bridging**: Interacts with Swift through C interface
5. **Zero Dependencies**: Only depends on C++ standard library

---

## Approach 1: Union System Extension (Minimal Changes)

### Overview
Add new type identifiers to the existing Value structure and use separate container member variables to store collection data. This approach has the least impact on the existing system.

### Implementation Details

#### Core Changes
```cpp
struct Value {
    enum Type : int { 
        NUMBER = 0, 
        BOOLEAN = 1, 
        STRING = 2, 
        ARRAY = 3,      // New
        DICTIONARY = 4  // New
    } type;
    
    union Data {
        double number;
        bool boolean;
    } data;
    
    std::string stringValue;
    std::vector<Value> arrayValue;                    // New: Array storage
    std::unordered_map<std::string, Value> dictValue; // New: Dictionary storage
};
```

#### Syntax Design
```javascript
// Array literals
[1, 2, 3, "hello", true]
[1 + 2, x * 3, func(y)]

// Dictionary literals  
{"name": "John", "age": 30, "active": true}
{"key1": expr1, "key2": expr2}

// Access syntax
array[0]           // Array index access
dict["key"]        // Dictionary key access
array.length       // Array length property
dict.keys          // Dictionary key collection
```

#### Parser Extensions
```cpp
// New Token types
enum class TokenType {
    // ... existing types
    BRACKET_OPEN,   // [
    BRACKET_CLOSE,  // ]
    BRACE_OPEN,     // {
    BRACE_CLOSE,    // }
    COLON,          // :
};

// New AST nodes
class ArrayLiteralNode : public ASTNode {
    std::vector<ASTNodePtr> elements;
};

class DictLiteralNode : public ASTNode {
    std::vector<std::pair<ASTNodePtr, ASTNodePtr>> pairs;
};

class IndexAccessNode : public ASTNode {
    ASTNodePtr object;
    ASTNodePtr index;
};
```

### Advantages
- **Minimal Intrusion**: Only extends existing Value structure
- **Backward Compatibility**: Maintains existing API completely
- **Simple Implementation**: Based on existing design patterns
- **Clear Memory**: Each type's memory layout is explicit
- **Easy Swift Integration**: Can directly map to Swift's Array and Dictionary

### Disadvantages
- **Memory Overhead**: Every Value instance contains all container members (even when unused)
- **Copy Cost**: Deep copying large collections can be expensive
- **Type Bloat**: Value struct becomes larger

### Swift Integration
```swift
extension ExprValue {
    static func array(_ values: [ExprValue]) -> ExprValue
    static func dictionary(_ dict: [String: ExprValue]) -> ExprValue
    
    var arrayValue: [ExprValue]? { get }
    var dictionaryValue: [String: ExprValue]? { get }
    
    func asArray() throws -> [ExprValue]
    func asDictionary() throws -> [String: ExprValue]
}
```

---

## Approach 2: Polymorphic Value System (Type Erasure)

### Overview
Redesign the Value system using polymorphic and type erasure-based modern C++ design to support arbitrary type extensions. This provides maximum flexibility and extensibility.

### Implementation Details

#### Core Design
```cpp
class Value {
private:
    struct ValueConcept {
        virtual ~ValueConcept() = default;
        virtual std::unique_ptr<ValueConcept> clone() const = 0;
        virtual std::string typeName() const = 0;
        virtual std::string toString() const = 0;
        virtual bool equals(const ValueConcept& other) const = 0;
    };
    
    template<typename T>
    struct ValueModel : ValueConcept {
        T data;
        explicit ValueModel(T value) : data(std::move(value)) {}
        
        std::unique_ptr<ValueConcept> clone() const override {
            return std::make_unique<ValueModel>(data);
        }
        
        std::string typeName() const override {
            return TypeTraits<T>::name();
        }
        
        // ... other implementations
    };
    
    std::unique_ptr<ValueConcept> pimpl;

public:
    template<typename T>
    Value(T&& value) : pimpl(std::make_unique<ValueModel<std::decay_t<T>>>(std::forward<T>(value))) {}
    
    template<typename T>
    T& as() { return static_cast<ValueModel<T>&>(*pimpl).data; }
    
    template<typename T>
    const T& as() const { return static_cast<const ValueModel<T>&>(*pimpl).data; }
};

// Specialized type definitions
using Array = std::vector<Value>;
using Dictionary = std::unordered_map<std::string, Value>;
```

#### Syntax and Parsing
Syntax design is the same as Approach 1, but the parser can handle different types more flexibly:

```cpp
// Type specialization handling
template<>
struct TypeTraits<Array> {
    static constexpr const char* name() { return "array"; }
    static Value createElement(const std::vector<ASTNodePtr>& elements, IEnvironment* env);
};

template<>
struct TypeTraits<Dictionary> {
    static constexpr const char* name() { return "dictionary"; }
    static Value createElement(const std::vector<std::pair<ASTNodePtr, ASTNodePtr>>& pairs, IEnvironment* env);
};
```

### Advantages
- **Zero Memory Overhead**: Each Value only stores the data it actually needs
- **Unlimited Extensibility**: Can easily add new data types
- **Type Safety**: Compile-time and runtime type checking
- **Modern C++**: Uses modern C++ features, more elegant code
- **Performance Optimization**: Can optimize specifically for different types

### Disadvantages
- **Major Refactoring**: Requires significant modification of existing code
- **Compilation Complexity**: Template code increases compilation time
- **Debugging Difficulty**: Type erasure makes debugging more complex
- **Complex Swift Integration**: Requires redesigning the C bridge interface
- **Backward Compatibility Risk**: Existing code may need modification

### Swift Integration Challenges
Requires redesigning the entire C bridge layer:
```c
// New C interface
typedef enum {
    EXPR_TYPE_NUMBER,
    EXPR_TYPE_BOOLEAN, 
    EXPR_TYPE_STRING,
    EXPR_TYPE_ARRAY,
    EXPR_TYPE_DICT,
    EXPR_TYPE_CUSTOM
} ExprValueType;

typedef struct ExprValue* ExprValueRef;

ExprValueType expr_value_get_type(ExprValueRef value);
ExprValueRef expr_value_array_get(ExprValueRef array, size_t index);
size_t expr_value_array_size(ExprValueRef array);
// ... more interfaces
```

---

## Approach 3: Plugin-Style Collection Support (Minimal Impact)

### Overview
Keep the existing Value system unchanged and support collection operations through the IEnvironment interface and special function calls. This approach has minimal impact on the core system while providing collection functionality.

### Implementation Details

#### Core Concept
Collections are not stored as independent Value types but simulated through environment variables and special functions:

```cpp
// Existing Value structure remains unchanged
struct Value {
    enum Type : int { NUMBER = 0, BOOLEAN = 1, STRING = 2 } type;
    // ... existing implementation
};

// Extend IEnvironment to support collection operations
class IEnvironment {
public:
    // Existing interfaces
    virtual Value Get(const std::string& name) = 0;
    virtual Value Call(const std::string& name, const std::vector<Value>& args) = 0;
    
    // New: Collection operation interfaces (optional implementation)
    virtual bool IsCollection(const std::string& name) const { return false; }
    virtual Value GetCollectionElement(const std::string& name, const Value& index) { 
        throw ExprException("Collection access not supported"); 
    }
    virtual size_t GetCollectionSize(const std::string& name) {
        throw ExprException("Collection size not supported");
    }
};
```

#### Syntax Design
```javascript
// Through function call syntax
array_get(myarray, 0)      // Equivalent to myarray[0]
dict_get(mydict, "key")    // Equivalent to mydict["key"] 
array_size(myarray)        // Get array size
dict_keys(mydict)          // Get dictionary keys

// Or through special access syntax (parser extension)
myarray.0                  // Array index access
mydict.key                 // Dictionary key access (limited to identifier keys)
```

#### Environment Implementation Example
```cpp
class CollectionEnvironment : public IEnvironment {
private:
    std::unordered_map<std::string, Value> variables;
    std::unordered_map<std::string, std::vector<Value>> arrays;
    std::unordered_map<std::string, std::unordered_map<std::string, Value>> dicts;

public:
    Value Call(const std::string& name, const std::vector<Value>& args) override {
        // Standard mathematical functions
        Value result;
        if (Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // Collection functions
        if (name == "array_get" && args.size() == 2) {
            std::string arrayName = args[0].asString();
            int index = static_cast<int>(args[1].asNumber());
            
            auto it = arrays.find(arrayName);
            if (it != arrays.end() && index >= 0 && index < it->second.size()) {
                return it->second[index];
            }
            throw ExprException("Array access out of bounds");
        }
        
        if (name == "dict_get" && args.size() == 2) {
            std::string dictName = args[0].asString();
            std::string key = args[1].asString();
            
            auto it = dicts.find(dictName);
            if (it != dicts.end()) {
                auto keyIt = it->second.find(key);
                if (keyIt != it->second.end()) {
                    return keyIt->second;
                }
            }
            throw ExprException("Dictionary key not found");
        }
        
        // ... more collection functions
        
        throw ExprException("Unknown function: " + name);
    }
    
    // Convenience methods for setting collections
    void SetArray(const std::string& name, const std::vector<Value>& values) {
        arrays[name] = values;
    }
    
    void SetDictionary(const std::string& name, const std::unordered_map<std::string, Value>& dict) {
        dicts[name] = dict;
    }
};
```

### Advantages
- **Zero Core Modification**: Value and Expression core remain completely unchanged
- **Full Backward Compatibility**: Existing code requires no modifications
- **Flexible Implementation**: Different environments can selectively support collections
- **Progressive Adoption**: Collection functionality can be added gradually
- **Simple Swift Integration**: No need to modify existing bridge interface

### Disadvantages
- **Syntax Limitations**: No native `[]` access syntax support
- **Performance Overhead**: Function calls are slower than direct access
- **Usage Complexity**: Need to remember special function names
- **Weak Type Checking**: Collection type errors can only be detected at runtime

### Swift Integration
```swift
class CollectionEnvironment: EnvironmentProtocol {
    private var arrays: [String: [Value]] = [:]
    private var dictionaries: [String: [String: Value]] = [:]
    
    func setArray(name: String, values: [Value]) {
        arrays[name] = values
    }
    
    func setDictionary(name: String, dict: [String: Value]) {
        dictionaries[name] = dict
    }
    
    func callFunction(name: String, arguments: [Value]) throws -> Value {
        switch name {
        case "array_get":
            guard arguments.count == 2 else { throw ExpressionError.invalidArguments }
            let arrayName = try arguments[0].asString()
            let index = Int(try arguments[1].asNumber())
            
            guard let array = arrays[arrayName],
                  index >= 0 && index < array.count else {
                throw ExpressionError.evaluationFailed("Array access out of bounds")
            }
            return array[index]
            
        case "dict_get":
            // ... similar implementation
            
        default:
            // Call standard functions or throw error
        }
    }
}
```

---

## Performance and Memory Analysis

### Memory Usage Comparison
| Approach | Basic Type Overhead | Array Overhead | Dictionary Overhead | Overall Assessment |
|----------|-------------------|----------------|-------------------|-------------------|
| Approach 1 | +32 bytes | 24 + n*size | 56 + n*size | Medium |
| Approach 2 | +8 bytes | 24 + n*size | 56 + n*size | Optimal |
| Approach 3 | 0 bytes | Environment managed | Environment managed | Optimal (basic types) |

### Performance Characteristics
| Operation | Approach 1 | Approach 2 | Approach 3 |
|-----------|------------|------------|------------|
| Basic type creation | Slow (large struct) | Fast | Fast |
| Collection access | Fast (direct) | Fast (direct) | Slow (function call) |
| Memory copying | Slow (large struct) | Fast (smart pointers) | Fast |
| Type checking | Fast | Fast | Slow |

---

## Cross-Language Integration Considerations

### Swift Integration Assessment
| Approach | Swift Mapping | Type Safety | Development Effort | Maintenance Cost |
|----------|---------------|-------------|-------------------|------------------|
| Approach 1 | Direct mapping | High | Medium | Low |
| Approach 2 | Requires refactoring | Highest | High | Medium |
| Approach 3 | No modification needed | Medium | Lowest | Lowest |

### Future Language Support
- **Approach 1**: Easy to extend to other languages (Python, JavaScript, Java)
- **Approach 2**: Requires redesigning bindings for each language
- **Approach 3**: Through function interface, naturally supports all languages

---

## Recommendations

### Short-term Recommendation: Approach 3 (Plugin-style Collection Support)
**Reasons**:
1. **Zero Risk**: Does not affect existing code and users
2. **Quick Implementation**: Can quickly validate requirements without modifying the core
3. **Progressive**: Can serve as preliminary validation for other approaches

### Long-term Recommendation: Approach 1 (Union System Extension)
**Reasons**:
1. **Good Balance**: Finds balance between functionality and stability
2. **Swift Friendly**: Can directly map to Swift native types
3. **Natural Syntax**: Supports modern programming language collection access syntax
4. **Progressive Migration**: Can gradually migrate from Approach 3

### Not Recommended: Approach 2 (Polymorphic Value System)
**Reasons**:
- Refactoring risk is too high
- Swift integration complexity is too great
- Conflicts with "minimal changes" requirement

---

## Implementation Suggestions

### Phase 1: Validate Requirements (Using Approach 3)
1. Implement basic collection function support
2. Create examples and test cases
3. Collect user feedback and usage patterns

### Phase 2: Core Integration (Migrate to Approach 1)
1. Extend Value structure
2. Add new syntax parsing support
3. Implement Swift bridge extensions
4. Complete test coverage

### Phase 3: Optimization and Refinement
1. Performance optimization
2. Memory usage optimization
3. Error handling improvements
4. Documentation and example completion

This phased approach can maximize risk reduction while ensuring the final solution meets all requirements.