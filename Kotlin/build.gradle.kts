plugins {
    kotlin("jvm") version "1.9.22"
    `java-library`
    `maven-publish`
}

group = "com.expressionkit"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    
    // Test dependencies
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.10.1")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.10.1")
}

kotlin {
    jvmToolchain(11)
}

tasks.named<Test>("test") {
    useJUnitPlatform()
    
    testLogging {
        events("passed", "skipped", "failed")
        showExceptions = true
        showCauses = true
        showStackTraces = true
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
    }
}

// Task to run tests with detailed output for CI
tasks.register("testDetailed") {
    group = "verification"
    description = "Runs tests with detailed output for CI integration"
    dependsOn("test")
    doLast {
        val testResults = tasks.named<Test>("test").get()
        println("\n🎉 Kotlin Tests Completed!")
        println("   📊 Test Results: ${testResults.testLogging}")
    }
}

// Task to run the example
tasks.register<JavaExec>("runExample") {
    group = "application"
    description = "Runs the Kotlin example application"
    dependsOn("compileKotlin")
    mainClass.set("KotlinExampleKt")
    classpath = sourceSets["main"].runtimeClasspath + files("examples")
    workingDir = file("examples")
}

// Configure Maven publication
publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
            
            pom {
                name.set("ExpressionKit")
                description.set("A lightweight, interface-driven expression parsing and evaluation library for Kotlin/JVM with token sequence analysis")
                url.set("https://github.com/Cloudage/ExpressionKit")
                
                licenses {
                    license {
                        name.set("MIT License")
                        url.set("https://opensource.org/licenses/MIT")
                    }
                }
                
                developers {
                    developer {
                        id.set("cloudage")
                        name.set("Cloudage")
                        url.set("https://github.com/Cloudage")
                    }
                }
                
                scm {
                    connection.set("scm:git:https://github.com/Cloudage/ExpressionKit.git")
                    developerConnection.set("scm:git:https://github.com/Cloudage/ExpressionKit.git")
                    url.set("https://github.com/Cloudage/ExpressionKit")
                }
            }
        }
    }
    
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/Cloudage/ExpressionKit")
            credentials {
                username = project.findProperty("gpr.user") as String? ?: System.getenv("USERNAME")
                password = project.findProperty("gpr.key") as String? ?: System.getenv("TOKEN")
            }
        }
    }
}

// Configure Java compatibility for better IDE support
java {
    withSourcesJar()
    withJavadocJar()
    
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}