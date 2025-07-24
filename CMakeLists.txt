cmake_minimum_required(VERSION 3.14)
project(ExpressionKit VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Header-only library target
add_library(ExpressionKit INTERFACE)

# Add include directories
target_include_directories(ExpressionKit 
    INTERFACE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

# Install configuration for use with find_package
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Install the header file
install(FILES ExpressionKit.hpp
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install the target
install(TARGETS ExpressionKit
    EXPORT ExpressionKitTargets
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install the export set
install(EXPORT ExpressionKitTargets
    FILE ExpressionKitTargets.cmake
    NAMESPACE ExpressionKit::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ExpressionKit
)

# Create and install the config file
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ExpressionKitConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/ExpressionKitConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ExpressionKit
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Create and install the version file
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/ExpressionKitConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/ExpressionKitConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/ExpressionKitConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ExpressionKit
)

# Option to build tests (when not used as a subproject)
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/CPP/CMakeLists.txt")
    option(EXPRESSIONKIT_BUILD_TESTS "Build ExpressionKit tests" ON)
    if(EXPRESSIONKIT_BUILD_TESTS)
        add_subdirectory(CPP)
    endif()
endif()