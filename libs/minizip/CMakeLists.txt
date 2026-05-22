cmake_minimum_required(VERSION 3.10)

set(TARGET nscp_miniz)

project(${TARGET})

# Two backends present the same nscp_miniz target to the rest of the build:
# - Windows: compile the vendored miniz source pointed at by MINIZ_INCLUDE_DIR.
# - Linux/macOS: thin INTERFACE that links the system libzip (-dev). The
#   zip_archive shim in service/plugins/zip_plugin.cpp picks the matching API
#   via #ifdef _WIN32.
if(WIN32)
    set(miniz_SOURCE
        ${MINIZ_INCLUDE_DIR}/miniz.c
        ${MINIZ_INCLUDE_DIR}/miniz.h
    )

    add_library(${TARGET} STATIC ${miniz_SOURCE})
    target_include_directories(${TARGET} PUBLIC ${MINIZ_INCLUDE_DIR})

    set_target_properties(
        ${TARGET}
        PROPERTIES
            FOLDER
                "core"
    )
else()
    add_library(${TARGET} INTERFACE)
    if(TARGET libzip::zip)
        target_link_libraries(${TARGET} INTERFACE libzip::zip)
    else()
        target_include_directories(${TARGET} INTERFACE ${LIBZIP_INCLUDE_DIRS})
        target_link_libraries(${TARGET} INTERFACE ${LIBZIP_LIBRARIES})
    endif()
endif()
