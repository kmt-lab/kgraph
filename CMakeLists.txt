cmake_minimum_required (VERSION 2.9)
project (KGRAPH)

option(CMAKE_INSTALL_PREFIX $ENV{HOME}/opt/kgraph)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Check for ARM architecture
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
    message(STATUS "Building for ARM architecture")
    add_definitions(-DKGRAPH_USE_ARM_IMPL)
endif()

# Set OpenMP flags manually for NVHPC compiler
if(CMAKE_CXX_COMPILER_ID MATCHES "NVHPC")
    # NVIDIA HPC compiler flags for ARM architecture
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -O3 -fPIC -tp=grace")
    # Disable SVE instructions completely
    add_definitions(-DKGRAPH_USE_ARM_IMPL)
    ## Add SVE support with a fixed vector length (choose appropriate size)
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msve-vector-bits=512")
    # Add OpenMP support
    set(OpenMP_CXX_FLAGS "-mp")
    set(OpenMP_CXX_LIB_NAMES "gomp")
    set(OpenMP_gomp_LIBRARY gomp)
else()
    # GCC/Clang compiler flags
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -O3 -fPIC")
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64|amd64")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse2 -march=native")
    elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
        # ARM-specific optimizations for GCC/Clang
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
    endif()
endif()

find_package(OpenMP REQUIRED)
if (OPENMP_FOUND)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

find_package(Boost REQUIRED COMPONENTS timer chrono system program_options)

set(LIB_SRC kgraph.cpp)
include_directories(${KGRAPH_SOURCE_DIR} ${KGRAPH_SOURCE_DIR}/3rd/xsimd/include)
add_library(kgraph SHARED ${LIB_SRC})
add_library(kgrapha STATIC ${LIB_SRC})
set_target_properties(kgrapha PROPERTIES OUTPUT_NAME kgraph)
add_executable(index index.cpp)
add_executable(search search.cpp)
set(TOOLS index search)
foreach(TOOL ${TOOLS})
	target_link_libraries(${TOOL} kgrapha ${Boost_LIBRARIES} rt)
endforeach(TOOL)
install (FILES kgraph.h kgraph-data.h kgraph-data-arm.h DESTINATION include)
install (TARGETS kgraph kgrapha
	 LIBRARY DESTINATION lib
	 ARCHIVE DESTINATION lib)
