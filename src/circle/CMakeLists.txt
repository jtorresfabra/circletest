set(LIB_NAME circle)

set(HEADER_PATH ${CMAKE_SOURCE_DIR}/include/circle)

include_directories(${CMAKE_SOURCE_DIR}/include/)


set(HEADERS
    ${HEADER_PATH}/circle.h
)

set(SOURCES
    circle.cpp
)

set(LIBRARIES
    ${CMAKE_DL_LIBS}
)
include_directories(${CMAKE_SOURCE_DIR}/include/)

if (EMSCRIPTEN)
    set(LINK_FLAGS "-s WASM=1 -fno-exceptions -fno-rtti -s USE_GLFW=3")
endif(EMSCRIPTEN)

setup_lib(circle)
