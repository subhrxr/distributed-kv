# src/CMakeLists.txt
# Build kv_node from src/main.cpp and any other src/*.cpp files.

file(GLOB_RECURSE SRC_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE SRC_HEADERS CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.h" "${CMAKE_CURRENT_SOURCE_DIR}/*.hpp")

# Create a library if you later split code out of main
add_library(kvcore STATIC ${SRC_SOURCES} ${SRC_HEADERS})
target_include_directories(kvcore PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_features(kvcore PRIVATE cxx_std_17)

# If src/main.cpp exists, build executable kv_node (it will link the kvcore lib)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp")
  add_executable(kv_node "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp")
  target_link_libraries(kv_node PRIVATE kvcore)
  target_include_directories(kv_node PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
endif()
