cmake_minimum_required(VERSION 3.14)

# Don't declare a project if we're being included from parent
if(CMAKE_PROJECT_NAME STREQUAL "")
    project(ExpressionKitTests)
endif()

set(CMAKE_CXX_STANDARD 17)

# Use the parent ExpressionKit target if available, otherwise include header manually
if(TARGET ExpressionKit)
    set(EXPRESSIONKIT_TARGET ExpressionKit)
else()
    # Create a simple interface target for the header
    add_library(ExpressionKitHeader INTERFACE)
    target_include_directories(ExpressionKitHeader INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/..)
    set(EXPRESSIONKIT_TARGET ExpressionKitHeader)
endif()

# Enable testing
enable_testing()

# Add Catch2
include(FetchContent)
FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG        v3.4.0
)
FetchContent_MakeAvailable(Catch2)

# Add test executable
add_executable(ExpressionKitTest test.cpp)

# Link ExpressionKit and Catch2
target_link_libraries(ExpressionKitTest PRIVATE ${EXPRESSIONKIT_TARGET} Catch2::Catch2WithMain)

# Register tests
list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
include(CTest)
include(Catch)
catch_discover_tests(ExpressionKitTest)

