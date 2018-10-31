set(TEST_NAME circletest)

set(HEADER_PATH ${CMAKE_SOURCE_DIR}/include/)

include_directories(${CMAKE_SOURCE_DIR}/include/)

set(SOURCES
    circle_test.cpp
)

# Needed to do the correct installs
set(WEB_SOURCES
    index.html
    circle_test.js
)

if (EMSCRIPTEN)
    set(LINK_FLAGS "-s WASM=1 -fno-exceptions -fno-rtti")
endif()

setup_app(${TEST_NAME})
