cmake_minimum_required(VERSION 3.0)

set(QUICK_JS_DIR ${CMAKE_CURRENT_LIST_DIR}/src)

file(STRINGS ${QUICK_JS_DIR}/VERSION QUICK_JS_VERSION)

if ("${PROJECT_NAME}" STREQUAL "")
    project(QuickJs LANGUAGES C)
endif ()

add_library(QuickJs STATIC
        ${QUICK_JS_DIR}/quickjs.h
        ${QUICK_JS_DIR}/quickjs.c
        ${QUICK_JS_DIR}/quickjs-libc.h
        ${QUICK_JS_DIR}/quickjs-libc.c
        ${QUICK_JS_DIR}/cutils.h
        ${QUICK_JS_DIR}/cutils.c
        ${QUICK_JS_DIR}/libbf.h
        ${QUICK_JS_DIR}/libbf.c
        ${QUICK_JS_DIR}/libregexp.h
        ${QUICK_JS_DIR}/libregexp.c
        ${QUICK_JS_DIR}/libunicode.h
        ${QUICK_JS_DIR}/libunicode.c
        ${QUICK_JS_DIR}/unicode_gen.c
        )

target_compile_definitions(QuickJs PRIVATE
        -DCONFIG_VERSION="${QUICK_JS_VERSION}"
        -DCONFIG_BIGNUM
        )

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(QuickJs PRIVATE -D_GNU_SOURCE)
endif()


if (CMAKE_BUILD_TYPE STREQUAL Debug)

    target_compile_definitions(QuickJs PRIVATE
            #-DDUMP_OBJECTS
            #-DDUMP_ATOMS
            #-DDUMP_SHAPES
            -DDUMP_LEAKS
            #-DDUMP_GC_FREE
            )

endif ()

target_include_directories(QuickJs INTERFACE ${QUICK_JS_DIR})