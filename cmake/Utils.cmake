# BUILDSYSTEM_TARGETS approach:
# function(GetAllTargets _result _dir)
    # get_property(_subdirs DIRECTORY "${_dir}" PROPERTY SUBDIRECTORIES)
    # foreach(_subdir IN LISTS _subdirs)
        # GetAllTargets(${_result} "${_subdir}")
    # endforeach()
    # get_property(_sub_targets DIRECTORY "${_dir}" PROPERTY BUILDSYSTEM_TARGETS)
    # set(${_result} ${${_result}} ${_sub_targets} PARENT_SCOPE)
# endfunction()

macro(SuppressCocosEngineBuildWarnings)
    # CMake 3.7 would have convenient BUILDSYSTEM_TARGETS. As we require 3.6 at minumum, specify engine &
    # external targets (taken from cocos2d-x/external/CMakeLists.txt) manually for now
    set(targets
        cocos2d external ext_box2d ext_chipmunk ext_freetype ext_recast ext_jpeg ext_uv ext_webp
        ext_bullet ext_ssl ext_crypto ext_tiff ext_websockets ext_tinyxml2 ext_xxhash ext_xxtea
        ext_clipper ext_edtaa3func ext_convertUTF ext_poly2tri ext_md5 ext_unzip
    )

    if (BUILD_JS_LIBS)
      list(APPEND targets ext_spidermonkey)
    endif()  
    if (BUILD_LUA_LIBS)
        list(APPEND targets ext_luajit ext_tolua ext_luasocket)
    endif()

    if (LINUX)
       list(APPEND targets ext_fmod)
    else()
        list(APPEND targets ext_curl ext_png)
    endif()
    if (ANDROID)
        list(APPEND targets ext_cpufeatures ext_pvmp3dec ext_tremolo)
    endif()

    if (WINDOWS)
        list(APPEND targets ext_sqlite3 ext_gles ext_icon ext_MP3Decoder ext_OggDecoder ext_OpenalSoft)
    endif()

    if (WINDOWS OR MACOSX OR LINUX)
        list(APPEND targets ext_glfw3)
    endif()

    if (MACOSX OR ANDROID OR WINDOWS)
        list(APPEND targets ext_zlib)
    endif()

    if (MSVC)
        # Using /W1 for MSVC for now - maybe could do a more fine-grained approach also
        set(SUPPRESS_WARNINGS "/W1 /D_CRT_SECURE_NO_WARNINGS")
    else()
        string(
            CONCAT SUPPRESS_WARNINGS
            "-Wno-format "
            "-Wno-unused-parameter "
            "-Wno-deprecated-declarations "
        )
        if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            string(
                CONCAT SUPPRESS_WARNINGS
                "-Wno-gnu-zero-variadic-macro-arguments "
                "-Wno-gnu-anonymous-struct "
                "-Wno-dollar-in-identifier-extension "
                "-Wno-nested-anon-types "
            )
        endif()
    endif()

    #GetAllTargets(targets "${CMAKE_CURRENT_SOURCE_DIR}")

    foreach(target IN LISTS targets)
        get_target_property(flags ${target} COMPILE_FLAGS)
        if (NOT flags)
            set(flags "")
        endif()
        set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${flags} ${SUPPRESS_WARNINGS}")
        get_target_property(flags ${target} COMPILE_FLAGS)
    endforeach()
endmacro()
