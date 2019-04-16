# CMake 3.7 would have convenient BUILDSYSTEM_TARGETS.
# Use Workaround for older version.
macro(add_library _target)
    _add_library(${_target} ${ARGN})
    set_property(GLOBAL APPEND PROPERTY GlobalTargetList ${_target})
endmacro()

function(GetAllTargets _result _dir)
    # BUILDSYSTEM_TARGETS approach:
    # get_property(_subdirs DIRECTORY "${_dir}" PROPERTY SUBDIRECTORIES)
    # foreach(_subdir IN LISTS _subdirs)
    #     get_all_targets(${_result} "${_subdir}")
    # endforeach()
    # get_property(_sub_targets DIRECTORY "${_dir}" PROPERTY BUILDSYSTEM_TARGETS)
    # set(${_result} ${${_result}} ${_sub_targets} PARENT_SCOPE)

    get_property(_sub_targets GLOBAL PROPERTY GlobalTargetList)
    set(${_result} ${_sub_targets} PARENT_SCOPE)
endfunction()

macro(SuppressCocosEngineBuildWarnings)
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

    GetAllTargets(targets "${CMAKE_CURRENT_SOURCE_DIR}")
    foreach(target IN LISTS targets)
        get_target_property(flags ${target} COMPILE_FLAGS)
        if (NOT flags)
            set(flags "")
        endif()
        set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${flags} ${SUPPRESS_WARNINGS}")
    endforeach()
endmacro()

