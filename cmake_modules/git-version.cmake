set(GIT_VERSION_FILE "${SOURCE_DIR}/header/git-version.hpp")
set(GIT_VERSION "unknown")
set(GIT_BRANCH "unknown")

set(SHOULD_UPDATE_FILE "1")

find_package(Git)
if(GIT_FOUND AND EXISTS "${SOURCE_DIR}/../.git/")
  execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --short=8 HEAD
                  WORKING_DIRECTORY ${SOURCE_DIR}
                  RESULT_VARIABLE exit_code
                  OUTPUT_VARIABLE GIT_VERSION)
  if(NOT ${exit_code} EQUAL 0)
    message(WARNING "git rev-parse failed, unable to include version.")
  endif()
  execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
                  WORKING_DIRECTORY ${SOURCE_DIR}
                  RESULT_VARIABLE exit_code
                  OUTPUT_VARIABLE GIT_BRANCH)
  if(NOT ${exit_code} EQUAL 0)
    message(WARNING "git rev-parse failed, unable to include git branch.")
  endif()
  string(STRIP ${GIT_VERSION} GIT_VERSION)
  string(STRIP ${GIT_BRANCH} GIT_BRANCH)
  message(STATUS "GIT_VERSION: " ${GIT_VERSION})
  message(STATUS "GIT_BRANCH: " ${GIT_BRANCH})
else()
  message(WARNING "git not found, unable to include version.")
endif()

# update file if needed
if(EXISTS ${GIT_VERSION_FILE})
  file(STRINGS ${GIT_VERSION_FILE} match REGEX "${GIT_VERSION}")
  if(NOT "${match}" STREQUAL "")
    set(SHOULD_UPDATE_FILE "0")
  endif()
endif()

set(new_header
    "// Generated by CMake\n\n"
    "#define GIT_COMMIT_HASH \"${GIT_VERSION}\"\n"
    "#define GIT_BRANCH \"${GIT_BRANCH}\"\n")

if("${SHOULD_UPDATE_FILE}" EQUAL "1")
  file(WRITE ${GIT_VERSION_FILE} ${new_header})
endif()
