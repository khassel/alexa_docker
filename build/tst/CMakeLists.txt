cmake_minimum_required(VERSION 2.8.0 FATAL_ERROR)

project(wakeWordAgentTest)

set( WAKE_WORD_AGENT_TEST_SOURCE
        main.cpp
        testLogger.cpp
        testKittAi.cpp
        testIPCFactory.cpp
        ../src/IPCInterface.cpp
        ../src/KittAiSnowboyWakeWordEngine.cpp
        ../src/Logger.cpp
        ../src/PortAudioWrapper.cpp
        ../src/WakeWordAgent.cpp
        ../src/WakeWordEngine.cpp
        ../src/WakeWordEngineFactory.cpp
        ../src/WakeWordException.cpp
        ../src/WakeWordIPC.cpp
        ../src/WakeWordIPCFactory.cpp
        ../src/WakeWordIPCSocket.cpp )

set( WAKE_WORD_AGENT_TEST_LIBS
        snowboy-detect
        blas
        portaudio
        asound )

find_package( Threads )
set( CMAKE_THREAD_PREFER_PTHREAD TRUE )

add_executable( wakeWordAgentTest ${WAKE_WORD_AGENT_TEST_SOURCE} )

# Set D_GLIBCXX_USE_CXX11_ABI to 0 to avoid undefined reference 
# to libsnowboy-detect.a that built with c++ regular string.
set_target_properties( wakeWordAgentTest PROPERTIES COMPILE_FLAGS "-std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0" )

target_include_directories( wakeWordAgentTest PRIVATE ${CMAKE_SOURCE_DIR}/../src )
target_include_directories( wakeWordAgentTest PRIVATE ${CMAKE_SOURCE_DIR}/../ext/include )

target_link_libraries( wakeWordAgentTest ${WAKE_WORD_AGENT_TEST_LIBS} )
target_link_libraries( wakeWordAgentTest ${CMAKE_THREAD_LIBS_INIT} )

add_library( snowboy-detect STATIC IMPORTED )
set_target_properties( snowboy-detect PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../ext/lib/libsnowboy-detect.a )

add_library( portaudio STATIC IMPORTED )
set_target_properties( portaudio PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../ext/lib/libportaudio.a )

add_library( blas SHARED IMPORTED )
set_target_properties( blas PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../ext/lib/libblas.so.3 )
