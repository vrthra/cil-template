set (libciltut_VERSION_MAJOR 1)
set (libciltut_VERSION_MINOR 0)

# for debug builds
#SET(CMAKE_BUILD_TYPE debug)
#SET(CMAKE_C_FLAGS_DEBUG "-ggdb -O0")

configure_file (
	"${PROJECT_SOURCE_DIR}/src/config.h.in"
	"${PROJECT_BINARY_DIR}/src/config.h"
)

set(SHELTER_SRCS ciltut_libc.c tut4.c tut8.c tut6.c tut10.c)

add_library(ciltut-static ${SHELTER_SRCS})
set_target_properties(ciltut-static PROPERTIES
  COMPILE_FLAGS -O2
)
set_target_properties(ciltut-static
  PROPERTIES OUTPUT_NAME ciltut
  CLEAN_DIRECT_OUTPUT 1)

add_library(ciltut-shared SHARED ${SHELTER_SRCS})
set_target_properties(ciltut-shared PROPERTIES
  COMPILE_FLAGS -O2
)
set_target_properties(ciltut-shared
  PROPERTIES OUTPUT_NAME ciltut
  CLEAN_DIRECT_OUTPUT 1)

install (TARGETS ciltut-static DESTINATION bin)
install (TARGETS ciltut-shared DESTINATION bin)

