# Locate the zip-archive backend used by service/plugins/zip_plugin.cpp.
#
# Windows: looks for the vendored miniz source (miniz.c) under MINIZ_INCLUDE_DIR
# and builds it as a static library via libs/minizip.
# Linux/macOS: looks for libzip (Debian: libzip-dev, RPM: libzip-devel). The
# libs/minizip CMake target wraps libzip as an INTERFACE so call sites keep
# linking nscp_miniz unchanged.
#
# Sets:
#   MINIZ_FOUND        - whether the backend was located
#   MINIZ_INCLUDE_DIR  - header search path (Windows only; libzip exposes its
#                        own imported target / pkg-config variables)
#   LIBZIP_INCLUDE_DIRS / LIBZIP_LIBRARIES - populated on non-Windows when
#                        libzip is found via pkg-config (fallback when the
#                        CONFIG package is not installed).
if(WIN32)
    find_path(MINIZ_INCLUDE_DIR NAMES miniz.c PATHS ${MINIZ_INCLUDE_DIR})
    if(MINIZ_INCLUDE_DIR)
        set(MINIZ_FOUND TRUE)
    else()
        set(MINIZ_FOUND FALSE)
    endif()
    mark_as_advanced(MINIZ_INCLUDE_DIR)
else()
    # Prefer pkg-config: Debian/Ubuntu's libzip-dev ships a CMake config that
    # references the zipcmp/zipmerge/ziptool binaries from the separate
    # libzip-tools package and aborts with FATAL_ERROR when they're absent
    # (the error is raised inside libzip-targets.cmake, so find_package QUIET
    # cannot suppress it). pkg-config gives us -lzip and the headers without
    # touching that file. The CONFIG package is only consulted as a fallback
    # for distros that lack pkg-config.
    find_package(PkgConfig QUIET)
    if(PKG_CONFIG_FOUND)
        pkg_check_modules(LIBZIP QUIET libzip)
    endif()
    if(LIBZIP_FOUND)
        set(MINIZ_FOUND TRUE)
    else()
        find_package(libzip CONFIG QUIET)
        if(TARGET libzip::zip)
            set(MINIZ_FOUND TRUE)
        else()
            set(MINIZ_FOUND FALSE)
        endif()
    endif()
endif()
