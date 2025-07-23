cmake_minimum_required(VERSION 3.14)
project(ExprTKProject)

set(CMAKE_CXX_STANDARD 17)

# 启用测试
enable_testing()

# 添加 Catch2
include(FetchContent)
FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG        v3.4.0
)
FetchContent_MakeAvailable(Catch2)

# 添加测试可执行文件
add_executable(ExprTKTest test.cpp)

# 链接 Catch2
target_link_libraries(ExprTKTest PRIVATE Catch2::Catch2WithMain)

# 包含头文件目录
target_include_directories(ExprTKTest PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# 注册测试
list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
include(CTest)
include(Catch)
catch_discover_tests(ExprTKTest)

