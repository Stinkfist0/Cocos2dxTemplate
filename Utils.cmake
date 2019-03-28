# Requires CMake 3.7 for BUILDSYSTEM_TARGETS
macro(SuppressCocosEngineBuildWarnings)
    function(get_all_targets _result _dir)
        get_property(_subdirs DIRECTORY "${_dir}" PROPERTY SUBDIRECTORIES)
        foreach(_subdir IN LISTS _subdirs)
            get_all_targets(${_result} "${_subdir}")
        endforeach()
        get_property(_sub_targets DIRECTORY "${_dir}" PROPERTY BUILDSYSTEM_TARGETS)
        set(${_result} ${${_result}} ${_sub_targets} PARENT_SCOPE)
    endfunction()

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

    get_all_targets(targets "${CMAKE_CURRENT_SOURCE_DIR}")
    foreach(target IN LISTS targets)
       set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${SUPPRESS_WARNINGS}")
    endforeach()
endmacro()
