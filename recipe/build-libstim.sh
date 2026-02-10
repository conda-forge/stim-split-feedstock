#!/bin/bash
set -ex

# Use _build to avoid conflict with Stim's BUILD directory (case-insensitive on macOS)
# Set SIMD_WIDTH=128 (SSE2) to avoid -march=native which would produce
# binaries that only work on the build host's CPU. SSE2 is baseline for x86_64.
# On ARM (osx-arm64), the CMake check is case-sensitive (ARM64 vs arm64),
# so SIMD_WIDTH is ignored and no x86-specific flags are set.
cmake ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DSIMD_WIDTH=128 \
    -B _build \
    .

cmake --build _build --target libstim --parallel ${CPU_COUNT}

# Manual install - cmake --install tries to install the stim executable too
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"
cp _build/out/libstim.a "${PREFIX}/lib/"
cp src/stim.h "${PREFIX}/include/"
# Install all headers that stim.h includes (stim/circuit/*.h, stim/cmd/*.h, etc.)
cd src && find stim -name '*.h' -o -name '*.inl' | while read f; do
    mkdir -p "${PREFIX}/include/$(dirname "$f")"
    cp "$f" "${PREFIX}/include/$f"
done
