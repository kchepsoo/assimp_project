#!/bin/bash
set -eux

cd "$SRC"

export CC="${CC:-clang}"
export CXX="${CXX:-clang++}"

rm -rf build-fuzz
mkdir -p build-fuzz

cmake -S . -B build-fuzz \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DBUILD_SHARED_LIBS=OFF \
  -DASSIMP_BUILD_TESTS=OFF \
  -DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
  -DASSIMP_BUILD_SAMPLES=OFF \
  -DASSIMP_WARNINGS_AS_ERRORS=OFF \
  -DASSIMP_NO_EXPORT=ON \
  -DCMAKE_C_FLAGS="${CFLAGS:-}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS:-}"

cmake --build build-fuzz -- -j1

ASSIMP_LIB="$(find build-fuzz -name 'libassimp.a' | head -n1)"

if [ -z "$ASSIMP_LIB" ]; then
  echo "libassimp.a not found"
  find build-fuzz -name '*.a'
  exit 1
fi

$CXX ${CXXFLAGS:-} -std=c++17 \
  -Iinclude \
  -Ibuild-fuzz/include \
  -Ibuild-fuzz \
  fuzz/assimp_fuzzer.cpp \
  "$ASSIMP_LIB" \
  $(find build-fuzz -name '*.a' ! -name 'libassimp.a') \
  ${LIB_FUZZING_ENGINE:--fsanitize=fuzzer,address} \
  -lz -lm -pthread \
  -o "$OUT/assimp_fuzzer"
