set (libciltut_VERSION_MAJOR 1)
set (libciltut_VERSION_MINOR 0)

# for debug builds
#SET(CMAKE_BUILD_TYPE debug)
#SET(CMAKE_C_FLAGS_DEBUG "-ggdb -O0")

configure_file (
	"${PROJECT_SOURCE_DIR}/src/config.h.in"
	"${PROJECT_BINARY_DIR}/src/config.h"
)

message("BUILD_TUT11 = ${BUILD_TUT11}")
message("BUILD_TUT15 = ${BUILD_TUT15}")

if(${BUILD_TUT15} STREQUAL true)
set(OCAML_COMPILE ocamlc)

message("Building concolic callbacks")

execute_process(
  COMMAND ocamlfind query ocamlyices
  OUTPUT_VARIABLE OCAML_YICES OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
  COMMAND ocamlfind query gmp
  OUTPUT_VARIABLE OCAML_GMP OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(CONC_SRCS
 concolic/concolic_util.ml
 concolic/concolic_exp.ml
 concolic/concolic_ctxt.ml
 concolic/concolic_paths.ml
 concolic/concolic_callbacks.ml)

add_custom_target(concolic_callbacks ${CONC_SRCS})
add_custom_command(
  SOURCE  ${CONC_SRCS}
  COMMAND ${OCAML_COMPILE}
  ARGS    -custom -output-obj -o concolic_callbacks.o -I concolic/ -I ${OCAML_YICES} -I ${OCAML_GMP} gmp.cma nums.cma ocamlyices.cma ${CONC_SRCS}
  TARGET  concolic_callbacks
  OUTPUTS concolic_callbacks.o
  DEPENDS ${CONC_SRCS}
)
add_custom_command(
  SOURCE  concolic_callbacks
  TARGET  concolic_callbacks
  DEPENDS concolic_callbacks.o
)
set(CONCOLIC_LIB concolic_callbacks.o)
else()
set(CONCOLIC_LIB )
endif()

set(SHELTER_SRCS ciltut_libc.c tut4.c tut8.c tut6.c tut10.c tut15.c)

add_library(ciltut-static ${SHELTER_SRCS} ${CONCOLIC_LIB})
set_target_properties(ciltut-static PROPERTIES
  COMPILE_FLAGS "-O2 -ggdb"
)
set_target_properties(ciltut-static
  PROPERTIES OUTPUT_NAME ciltut
  CLEAN_DIRECT_OUTPUT 1)

add_library(ciltut-shared SHARED ${SHELTER_SRCS} ${CONCOLIC_LIB})
set_target_properties(ciltut-shared PROPERTIES
  COMPILE_FLAGS "-O2 -ggdb"
)
set_target_properties(ciltut-shared
  PROPERTIES OUTPUT_NAME ciltut
  CLEAN_DIRECT_OUTPUT 1)

install (TARGETS ciltut-static DESTINATION bin)
install (TARGETS ciltut-shared DESTINATION bin)

