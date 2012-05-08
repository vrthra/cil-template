cmake_minimum_required(VERSION 2.6)
project(libciltut)

include_directories("${PROJECT_BINARY_DIR}/../ciltut-include")
link_directories("${PROJECT_BINARY_DIR}/src")
link_directories("${PROJECT_BINARY_DIR}/src/concolic")

add_subdirectory(src)


