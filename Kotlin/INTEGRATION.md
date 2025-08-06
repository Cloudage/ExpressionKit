# ExpressionKit for Kotlin - Easy Integration Guide

This guide shows how to integrate ExpressionKit into your Kotlin projects using the simplest, officially recommended methods - similar to how Swift Package Manager works for Swift.

## Integration Methods

### Method 1: GitHub Packages (Recommended for Production)

GitHub Packages is the preferred method for consuming the library in production projects:

#### Step 1: Add Repository and Dependency

Add to your `build.gradle.kts`:

```kotlin
repositories {
    mavenCentral()
    maven {
        name = "GitHubPackages"
        url = uri("https://maven.pkg.github.com/Cloudage/ExpressionKit")
        credentials {
            username = project.findProperty("gpr.user") as String? ?: System.getenv("GITHUB_USERNAME")
            password = project.findProperty("gpr.key") as String? ?: System.getenv("GITHUB_TOKEN")
        }
    }
}

dependencies {
    implementation("com.expressionkit:ExpressionKit:1.0.0")
}
```

#### Step 2: Set Up Authentication

Create `gradle.properties` in your project root or `~/.gradle/gradle.properties`:

```properties
gpr.user=your_github_username
gpr.key=ghp_your_github_personal_access_token
```

Or set environment variables:
```bash
export GITHUB_USERNAME=your_username
export GITHUB_TOKEN=your_token
```

### Method 2: Local Installation (Recommended for Development)

For development, testing, or when you don't have GitHub Packages access:

#### Step 1: Install ExpressionKit Locally

```bash
git clone https://github.com/Cloudage/ExpressionKit.git
cd ExpressionKit/Kotlin
./gradlew publishToMavenLocal
```

#### Step 2: Use in Your Project

Add to your `build.gradle.kts`:

```kotlin
repositories {
    mavenLocal()  // This enables local Maven repository
    mavenCentral()
}

dependencies {
    implementation("com.expressionkit:ExpressionKit:1.0.0")
}
```

## Usage Examples

Once integrated, import and use ExpressionKit in your Kotlin code:

```kotlin
import com.expressionkit.*

fun main() {
    // Basic arithmetic
    val result1 = Expression.eval("2 + 3 * 4")
    println("2 + 3 * 4 = ${result1.asNumber()}")  // 14.0
    
    // Variables and functions
    val env = SimpleEnvironment()
    env.setVariable("x", 10.0)
    env.setVariable("y", 20.0)
    
    val result2 = Expression.eval("sqrt(x * y)", env)
    println("sqrt(x * y) = ${result2.asNumber()}")  // 14.142135623730951
    
    // Pre-compiled for performance
    val compiled = Expression.parse("health > maxHealth * 0.5")
    env.setVariable("health", 80.0)
    env.setVariable("maxHealth", 100.0)
    
    val isHealthy = compiled.evaluate(env)
    println("Is healthy: ${isHealthy.asBoolean()}")  // true
    
    // Custom functions
    env.setFunction("double") { args ->
        Value.number(args[0].asNumber() * 2)
    }
    
    val doubled = Expression.eval("double(5)", env)
    println("double(5) = ${doubled.asNumber()}")  // 10.0
}
```

## Integration Examples

### Android Project (build.gradle.kts)

```kotlin
android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.example.myapp"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
}

repositories {
    google()
    mavenCentral()
    maven {
        name = "GitHubPackages"
        url = uri("https://maven.pkg.github.com/Cloudage/ExpressionKit")
        credentials {
            username = project.findProperty("gpr.user") as String?
            password = project.findProperty("gpr.key") as String?
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("com.expressionkit:ExpressionKit:1.0.0")
    // ... other dependencies
}
```

### Spring Boot Project

```kotlin
plugins {
    kotlin("jvm") version "1.9.22"
    kotlin("plugin.spring") version "1.9.22"
    id("org.springframework.boot") version "3.1.5"
}

repositories {
    mavenCentral()
    maven("https://maven.pkg.github.com/Cloudage/ExpressionKit") {
        credentials {
            username = project.findProperty("gpr.user") as String?
            password = project.findProperty("gpr.key") as String?
        }
    }
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter")
    implementation("com.expressionkit:ExpressionKit:1.0.0")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
}
```

### Gradle Multi-module Project

```kotlin
// Root build.gradle.kts
allprojects {
    repositories {
        mavenCentral()
        maven("https://maven.pkg.github.com/Cloudage/ExpressionKit") {
            credentials {
                username = findProperty("gpr.user") as String?
                password = findProperty("gpr.key") as String?
            }
        }
    }
}

// Module build.gradle.kts
dependencies {
    api("com.expressionkit:ExpressionKit:1.0.0")
    // ... other dependencies
}
```

## Troubleshooting

### Authentication Issues

If you get authentication errors:

1. Verify your GitHub token has `read:packages` permission
2. Make sure your username and token are correctly set
3. For organization repositories, ensure you have access

### Dependency Resolution

If Gradle can't find the dependency:

1. Try `./gradlew --refresh-dependencies`
2. Check that the repository URL is correct
3. Verify your internet connection
4. For local development, ensure `publishToMavenLocal` completed successfully

### Version Conflicts

If you have version conflicts:

1. Use `./gradlew dependencies` to check dependency tree
2. Add explicit version resolution if needed:

```kotlin
configurations.all {
    resolutionStrategy {
        force("com.expressionkit:ExpressionKit:1.0.0")
    }
}
```

## Why This Is Like Swift Package Manager

This integration approach provides the same benefits as Swift Package Manager:

- **Simple Declaration**: Just add one line to your dependencies
- **Automatic Resolution**: Gradle handles all transitive dependencies
- **Version Management**: Semantic versioning with easy updates
- **IDE Integration**: IntelliJ IDEA and Android Studio provide full support
- **Build Integration**: Works seamlessly with existing Gradle builds
- **No Manual Management**: No need to download/manage JAR files manually

The experience is as simple as Swift's `import ExpressionKit` - just add the dependency and import the package!