# Loads config.cmake file, and sets the values as internal.
# But only update the changed values, this avoids conflict with ccmake.
# Using ccmake with config.cmake is not a good idea, but it should work.

set(VALUE_CHANGED OFF)
function(set_option OPTION_NAME OPTION_VALUE)
  if (NOT ("${OPTION_VALUE}" STREQUAL "${CACHED_OPTION_${OPTION_NAME}}"))
      #message("${OPTION_NAME}: (${CACHED_OPTION_${OPTION_NAME}}) (${OPTION_VALUE})")
      unset(${OPTION_NAME} CACHE)
      if (OPTION_VALUE)
          set(${OPTION_NAME} ${OPTION_VALUE} CACHE BOOL "")
      endif()
      set(CACHED_OPTION_${OPTION_NAME} ${OPTION_VALUE} CACHE INTERNAL "")
      set(VALUE_CHANGED ON PARENT_SCOPE)
  endif()
endfunction()
include(${PROJECT_SOURCE_DIR}/Config.cmake)
if (VALUE_CHANGED)
    message(STATUS "Updated variables from Config.cmake")
endif()
