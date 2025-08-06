plugins {
    kotlin("jvm") version "1.9.22"
    `java-library`
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