#!/bin/bash

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/kgraph -DCMAKE_BUILD_TYPE=Release ..

# Build
#make -j$(nproc)
make -j2

# Print completion message
echo "Build completed. Check for any errors above."
