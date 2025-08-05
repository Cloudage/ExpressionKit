# ExpressionKit 数组和字典支持实现方案

## 概述

本文档分析了为 ExpressionKit 添加数组和字典支持的三种主要实现方案。每个方案都考虑了以下关键要求：

- **最小化更改**：尽可能少地修改现有代码
- **向后兼容性**：确保现有功能不受影响
- **Swift 集成**：保持与 Swift Package Manager 的无缝集成
- **跨语言支持**：为未来的语言绑定提供良好基础
- **性能考虑**：避免对现有简单类型造成性能损失

## 当前架构分析

### 现有 Value 系统
```cpp
struct Value {
    enum Type : int { NUMBER = 0, BOOLEAN = 1, STRING = 2 } type;
    union Data {
        double number;
        bool boolean;
    } data;
    std::string stringValue;  // 字符串单独存储
};
```

### 关键设计约束
1. **内存效率**：当前使用 union 确保基础类型的内存效率
2. **类型安全**：强类型系统，编译时和运行时检查
3. **C++ 头文件库**：必须保持头文件独立性
4. **Swift 桥接**：通过 C 接口与 Swift 交互
5. **零依赖**：仅依赖 C++ 标准库

---

## 方案一：扩展 Union 系统（最小更改方案）

### 概述
在现有 Value 结构中添加新的类型标识符，使用独立的容器成员变量存储集合数据。这是对现有系统影响最小的方案。

### 实现细节

#### 核心更改
```cpp
struct Value {
    enum Type : int { 
        NUMBER = 0, 
        BOOLEAN = 1, 
        STRING = 2, 
        ARRAY = 3,      // 新增
        DICTIONARY = 4  // 新增
    } type;
    
    union Data {
        double number;
        bool boolean;
    } data;
    
    std::string stringValue;
    std::vector<Value> arrayValue;                    // 新增：数组存储
    std::unordered_map<std::string, Value> dictValue; // 新增：字典存储
};
```

#### 语法设计
```javascript
// 数组字面量
[1, 2, 3, "hello", true]
[1 + 2, x * 3, func(y)]

// 字典字面量  
{"name": "John", "age": 30, "active": true}
{"key1": expr1, "key2": expr2}

// 访问语法
array[0]           // 数组索引访问
dict["key"]        // 字典键访问
array.length       // 数组长度属性
dict.keys          // 字典键集合
```

#### 解析器扩展
```cpp
// 新增 Token 类型
enum class TokenType {
    // ... 现有类型
    BRACKET_OPEN,   // [
    BRACKET_CLOSE,  // ]
    BRACE_OPEN,     // {
    BRACE_CLOSE,    // }
    COLON,          // :
};

// 新增 AST 节点
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

### 优势
- **最小侵入性**：只需扩展现有 Value 结构
- **向后兼容**：完全保持现有 API 不变
- **实现简单**：基于现有设计模式
- **内存清晰**：每种类型的内存布局明确
- **Swift 集成容易**：可以直接映射到 Swift 的 Array 和 Dictionary

### 劣势
- **内存开销**：每个 Value 实例都包含所有容器成员（即使未使用）
- **复制成本**：深度复制大型集合可能较昂贵
- **类型膨胀**：Value 结构体变得更大

### Swift 集成
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

## 方案二：多态 Value 系统（类型擦除方案）

### 概述
重新设计 Value 系统，使用基于多态和类型擦除的现代 C++ 设计，支持任意类型的扩展。这提供了最大的灵活性和扩展性。

### 实现细节

#### 核心设计
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
        
        // ... 其他实现
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

// 专用类型定义
using Array = std::vector<Value>;
using Dictionary = std::unordered_map<std::string, Value>;
```

#### 语法和解析
语法设计与方案一相同，但解析器可以更灵活地处理不同类型：

```cpp
// 类型特化处理
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

### 优势
- **零内存开销**：每个 Value 只存储实际需要的数据
- **无限扩展性**：可以轻松添加新的数据类型
- **类型安全**：编译时和运行时类型检查
- **现代 C++**：使用现代 C++ 特性，代码更优雅
- **性能优化**：可以针对不同类型进行专门优化

### 劣势
- **重大重构**：需要大幅修改现有代码
- **编译复杂性**：模板代码增加编译时间
- **调试困难**：类型擦除使调试更复杂
- **Swift 集成复杂**：需要重新设计 C 桥接接口
- **向后兼容风险**：现有代码可能需要修改

### Swift 集成挑战
需要重新设计整个 C 桥接层：
```c
// 新的 C 接口
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
// ... 更多接口
```

---

## 方案三：插件式集合支持（最小影响方案）

### 概述
保持现有 Value 系统不变，通过 IEnvironment 接口和特殊函数调用来支持集合操作。这种方案对核心系统影响最小，同时提供集合功能。

### 实现细节

#### 核心理念
集合不作为独立的 Value 类型存储，而是通过环境变量和特殊函数来模拟：

```cpp
// 现有 Value 结构保持不变
struct Value {
    enum Type : int { NUMBER = 0, BOOLEAN = 1, STRING = 2 } type;
    // ... 现有实现
};

// 扩展 IEnvironment 以支持集合操作
class IEnvironment {
public:
    // 现有接口
    virtual Value Get(const std::string& name) = 0;
    virtual Value Call(const std::string& name, const std::vector<Value>& args) = 0;
    
    // 新增：集合操作接口（可选实现）
    virtual bool IsCollection(const std::string& name) const { return false; }
    virtual Value GetCollectionElement(const std::string& name, const Value& index) { 
        throw ExprException("Collection access not supported"); 
    }
    virtual size_t GetCollectionSize(const std::string& name) {
        throw ExprException("Collection size not supported");
    }
};
```

#### 语法设计
```javascript
// 通过函数调用语法
array_get(myarray, 0)      // 等同于 myarray[0]
dict_get(mydict, "key")    // 等同于 mydict["key"] 
array_size(myarray)        // 获取数组大小
dict_keys(mydict)          // 获取字典键

// 或者通过特殊访问语法（解析器扩展）
myarray.0                  // 数组索引访问
mydict.key                 // 字典键访问（限制为标识符键）
```

#### 环境实现示例
```cpp
class CollectionEnvironment : public IEnvironment {
private:
    std::unordered_map<std::string, Value> variables;
    std::unordered_map<std::string, std::vector<Value>> arrays;
    std::unordered_map<std::string, std::unordered_map<std::string, Value>> dicts;

public:
    Value Call(const std::string& name, const std::vector<Value>& args) override {
        // 标准数学函数
        Value result;
        if (Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // 集合函数
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
        
        // ... 更多集合函数
        
        throw ExprException("Unknown function: " + name);
    }
    
    // 便利方法设置集合
    void SetArray(const std::string& name, const std::vector<Value>& values) {
        arrays[name] = values;
    }
    
    void SetDictionary(const std::string& name, const std::unordered_map<std::string, Value>& dict) {
        dicts[name] = dict;
    }
};
```

### 优势
- **零核心修改**：Value 和 Expression 核心保持完全不变
- **完全向后兼容**：现有代码无需任何修改
- **灵活实现**：不同环境可以选择性支持集合
- **渐进式采用**：可以逐步添加集合功能
- **Swift 集成简单**：不需要修改现有桥接接口

### 劣势
- **语法限制**：不支持原生的 `[]` 访问语法
- **性能开销**：函数调用比直接访问慢
- **使用复杂**：需要记忆特殊函数名
- **类型检查弱**：集合类型错误只能在运行时发现

### Swift 集成
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
            // ... 类似实现
            
        default:
            // 调用标准函数或抛出错误
        }
    }
}
```

---

## 性能和内存分析

### 内存使用对比
| 方案 | 基础类型开销 | 数组开销 | 字典开销 | 总体评估 |
|------|-------------|---------|---------|----------|
| 方案一 | +32 bytes | 24 + n*size | 56 + n*size | 中等 |
| 方案二 | +8 bytes | 24 + n*size | 56 + n*size | 最优 |
| 方案三 | 0 bytes | 环境管理 | 环境管理 | 最优（基础类型） |

### 性能特征
| 操作 | 方案一 | 方案二 | 方案三 |
|------|-------|-------|-------|
| 基础类型创建 | 慢（大结构） | 快 | 快 |
| 集合访问 | 快（直接） | 快（直接） | 慢（函数调用） |
| 内存复制 | 慢（大结构） | 快（智能指针） | 快 |
| 类型检查 | 快 | 快 | 慢 |

---

## 跨语言集成考虑

### Swift 集成评估
| 方案 | Swift 映射 | 类型安全 | 开发工作量 | 维护成本 |
|------|-----------|---------|-----------|----------|
| 方案一 | 直接映射 | 高 | 中等 | 低 |
| 方案二 | 需要重构 | 最高 | 高 | 中等 |
| 方案三 | 无需修改 | 中等 | 最低 | 最低 |

### 未来语言支持
- **方案一**：容易扩展到其他语言（Python、JavaScript、Java）
- **方案二**：需要为每种语言重新设计绑定
- **方案三**：通过函数接口，自然支持所有语言

---

## 推荐方案

### 短期推荐：方案三（插件式集合支持）
**理由**：
1. **零风险**：不影响现有代码和用户
2. **快速实现**：可以在不修改核心的情况下快速验证需求
3. **渐进式**：可以作为其他方案的前期验证

### 长期推荐：方案一（扩展 Union 系统）
**理由**：
1. **平衡性好**：在功能性和稳定性之间找到平衡
2. **Swift 友好**：可以直接映射到 Swift 原生类型
3. **语法自然**：支持现代编程语言的集合访问语法
4. **渐进迁移**：可以从方案三逐步迁移而来

### 不推荐：方案二（多态 Value 系统）
**理由**：
- 重构风险太高
- Swift 集成复杂度过大
- 与"最小更改"的要求冲突

---

## 实施建议

### 阶段一：验证需求（使用方案三）
1. 实现基础的集合函数支持
2. 创建示例和测试用例
3. 收集用户反馈和使用模式

### 阶段二：核心集成（迁移到方案一）
1. 扩展 Value 结构体
2. 添加新的语法解析支持
3. 实现 Swift 桥接扩展
4. 完善测试覆盖

### 阶段三：优化和完善
1. 性能优化
2. 内存使用优化
3. 错误处理改进
4. 文档和示例完善

这种分阶段的方法可以最大化降低风险，同时确保最终解决方案满足所有需求。