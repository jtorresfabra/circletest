### CMAKE MACROS ###

macro(setup_lib CORELIB_NAME)

    add_library(${CORELIB_NAME}
        ${USER_DEFINED_DYNAMIC_OR_STATIC}
        ${HEADERS}
        ${SOURCES}
    )

    target_link_libraries(${CORELIB_NAME} ${LIBRARIES})

    if(LIBRARIES_OPTIMIZED)
        foreach(LIBOPT ${LIBRARIES_OPTIMIZED})
            target_link_libraries(${CORELIB_NAME} optimized ${LIBOPT})
        endforeach(LIBOPT)
    endif(LIBRARIES_OPTIMIZED)

    if(LIBRARIES_DEBUG)
        foreach(LIBDEBUG ${LIBRARIES_DEBUG})
            target_link_libraries(${CORELIB_NAME} debug ${LIBDEBUG})
        endforeach(LIBDEBUG)
    endif(LIBRARIES_DEBUG)

    set_target_properties(${CORELIB_NAME} PROPERTIES FOLDER "${SHORT_NAME} Libraries")

    set_target_properties(${CORELIB_NAME}
        PROPERTIES
        PROJECT_LABEL "${CORELIB_NAME}"
        VERSION ${VERSION}
    )

    if (EMSCRIPTEN)
      if (CMAKE_BUILD_TYPE MATCHES Debug)
        add_definitions(-g)
        add_definitions(-g4) # Generates emscripten -s USE_GLFW=3 C++ sourcemaps
      endif()
      set_target_properties(${CORELIB_NAME} 
        PROPERTIES
        SUFFIX ".bc"
        LINK_FLAGS ${LINK_FLAGS})
        #set the property
        SET_PROPERTY(GLOBAL PROPERTY ${CORELIB_NAME} "${CMAKE_CURRENT_BINARY_DIR}/lib${CORELIB_NAME}.bc")
    endif (EMSCRIPTEN)

    set(install_dest_dir "${LIB_PATH}")
    if(WIN32)
        SET(install_dest_dir "${BIN_PATH}")
    endif(WIN32)

    foreach(BIN ${install_dest_dir})
        install(TARGETS ${CORELIB_NAME}
                RUNTIME DESTINATION ${BIN}
                LIBRARY DESTINATION ${BIN}
        )
    endforeach()

    foreach(INC ${INC_PATH})
        install(FILES ${HEADERS}
            DESTINATION ${INC}/${CORELIB_NAME}
        )
    endforeach()

endmacro(setup_lib)

macro(get_dist_flags FLAGS)
    if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
        set(${FLAGS} ${CMAKE_CXX_FLAGS_RELEASE})
    elseif(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
        set(${FLAGS} ${CMAKE_CXX_FLAGS_DEBUG})
    elseif(${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo")
        set(${FLAGS} ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
    endif()
endmacro()

macro(setup_app APP_NAME)

file(RELATIVE_PATH DESTINATION ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR})

if (EMSCRIPTEN)

    if (CMAKE_BUILD_TYPE MATCHES Debug)
      add_definitions(-g)
      add_definitions(-g4) # Generates emscripten C++ sourcemaps
    endif()

    add_library(${APP_NAME} STATIC ${SOURCES})
    set_target_properties(${APP_NAME}
        PROPERTIES SUFFIX ".bc"
        LINK_FLAGS "${LINK_FLAGS}")

    foreach(LIB ${LIBRARIES})
        get_property (BC GLOBAL PROPERTY ${LIB})
        set(LIBS ${BC} ${LIBS})
    endforeach()

    #honor optimization link flags
    get_dist_flags(DIST_FLAGS)

    set(LINK_FLAGS "${DIST_FLAGS} ${LINK_FLAGS}")
    separate_arguments(LINK_PARAMETERS UNIX_COMMAND ${LINK_FLAGS})

    #compile bitcode to js
    add_custom_command(TARGET ${APP_NAME} POST_BUILD
        COMMAND emcc ${CMAKE_CURRENT_BINARY_DIR}/lib${APP_NAME}.bc ${LIBS} -o
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.js ${LINK_PARAMETERS}
    )
    foreach(file ${WEB_SOURCES})
        add_custom_command(TARGET ${APP_NAME} POST_BUILD
                       COMMAND ${CMAKE_COMMAND} -E copy
                       ${CMAKE_CURRENT_SOURCE_DIR}/${file}
                       ${CMAKE_CURRENT_BINARY_DIR})
    endforeach()


    set(CMAKE_INSTALL_COMPONENT ${CMAKE_CURRENT_BINARY_DIR})
    set(artifacts ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.wasm ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.js)

    set(artifacts ${artifacts} ${OPTIONAL_ARTIFACTS})

    install( FILES ${artifacts} DESTINATION ${DESTINATION})
    install( FILES ${WEB_SOURCES} DESTINATION ${DESTINATION})

else()
    add_executable(${APP_NAME} ${SOURCES})
    target_link_libraries(${APP_NAME} ${LIBRARIES})
    if (APPLE)
        add_definitions(-DGL_SILENCE_DEPRECATION)
    endif()
    install(TARGETS ${APP_NAME} DESTINATION ${DESTINATION})

endif (EMSCRIPTEN)

endmacro(setup_app)
