#!/usr/bin/env bash
# Builds the arm64-v8a native libraries for 64-bit-only phones, without the
# Android NDK: clang + lld from the host, the JDK's jni.h, and link stubs for
# the Android system libraries generated here.
#
#   src/lib/arm32emu/build.sh            -> src/lib/arm32emu/out/arm64-v8a/*.so
#
# Output:
#   out/arm64-v8a/libZombieCafeAndroid.so   ARM32 runtime + embedded engine
#   out/arm64-v8a/libZombieCafeExtension.so no-op (the patcher runs in the guest)
#   out/guest/libZombieCafeExtension.so     ARMv5TE build of src/lib/cpp (embedded above)
#   out/armeabi/libZombieCafeExtension.so   ARMv7 build of src/lib/cpp for the classic APK
#                                           (what the NDK recipe in the README produces)
#
# Needs: clang/clang++ and ld.lld (LLVM 15+), llvm-nm, llvm-readelf, a JDK.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../../.." && pwd)"
OUT="$HERE/out"
OBJ="$OUT/obj"
STUBS="$OUT/stubs"
GAME_SO="$ROOT/src/lib/armeabi/libZombieCafeAndroid.so"
EXT_SRC="$ROOT/src/lib/cpp"

CC=${CC:-clang}
CXX=${CXX:-clang++}
NM=${NM:-llvm-nm}
READELF=${READELF:-llvm-readelf}
RES="$($CC -print-resource-dir)/include"
if [ -z "${JAVA_HOME:-}" ]; then
    JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
fi
JNI_INC="-I$JAVA_HOME/include -I$JAVA_HOME/include/linux"

rm -rf "$OBJ" "$STUBS"
mkdir -p "$OBJ/guest" "$OBJ/armv7" "$OBJ/arm64" "$STUBS/armeabi" "$STUBS/arm64" "$OUT/guest" "$OUT/armeabi" \
    "$OUT/arm64-v8a"

# Link stubs: only their SONAMEs and symbol names matter; they give the output
# its DT_NEEDED entries. $1 target, $2 dir, $3 soname, rest: symbols.
make_stub() {
    local target=$1 dir=$2 lib=$3
    shift 3
    local src="$dir/${lib%.so}.c"
    : > "$src"
    for sym in "$@"; do
        echo "void $sym(void) {}" >> "$src"
    done
    $CC --target="$target" -fPIC -nostdlib -fuse-ld=lld -shared -Wl,-soname,"$lib" \
        -w -fno-builtin "$src" -o "$dir/$lib"
}

# ---------------------------------------------------------------- guest patcher
# src/lib/cpp for ARMv5TE Thumb (what the interpreter executes), soft-float.
GUEST_TARGET=armv5te-linux-androideabi
GUEST_FLAGS="--target=$GUEST_TARGET -march=armv5te -mthumb -mfloat-abi=soft -fPIC -O2 -fno-exceptions -fno-rtti
  -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -fno-builtin-memcpy
  -nostdinc -nostdinc++ -isystem $HERE/android/include -isystem $RES $JNI_INC"
for f in Memory ZombieCafeExtension; do
    $CXX $GUEST_FLAGS -c "$EXT_SRC/$f.cpp" -o "$OBJ/guest/$f.o"
done
make_stub "$GUEST_TARGET" "$STUBS/armeabi" libc.so malloc memcpy mprotect sysconf
make_stub "$GUEST_TARGET" "$STUBS/armeabi" libdl.so dlopen dlsym dladdr
make_stub "$GUEST_TARGET" "$STUBS/armeabi" liblog.so __android_log_print
$CXX --target=$GUEST_TARGET -fuse-ld=lld -shared -nostdlib "$OBJ/guest/Memory.o" "$OBJ/guest/ZombieCafeExtension.o" \
    -L"$STUBS/armeabi" -lc -ldl -llog -Wl,-soname,libZombieCafeExtension.so -Wl,--hash-style=both \
    -Wl,--no-undefined -Wl,-z,noexecstack -Wl,--gc-sections -o "$OUT/guest/libZombieCafeExtension.so"

# ---------------------------------------------------------------- classic patcher
# The same sources for the classic APK's lib/armeabi, as the NDK's armeabi-v7a
# build would compile them (Thumb-2, softfp).
V7_TARGET=armv7a-linux-androideabi21
V7_FLAGS="--target=$V7_TARGET -march=armv7-a -mthumb -mfloat-abi=softfp -mfpu=vfpv3-d16 -fPIC -O2 -fno-exceptions
  -fno-rtti -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -fno-builtin-memcpy
  -nostdinc -nostdinc++ -isystem $HERE/android/include -isystem $RES $JNI_INC"
for f in Memory ZombieCafeExtension; do
    $CXX $V7_FLAGS -c "$EXT_SRC/$f.cpp" -o "$OBJ/armv7/$f.o"
done
$CXX --target=$V7_TARGET -fuse-ld=lld -shared -nostdlib "$OBJ/armv7/Memory.o" "$OBJ/armv7/ZombieCafeExtension.o" \
    -L"$STUBS/armeabi" -lc -ldl -llog -Wl,-soname,libZombieCafeExtension.so -Wl,--hash-style=both \
    -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--gc-sections -Wl,--build-id=sha1 \
    -o "$OUT/armeabi/libZombieCafeExtension.so"

# ---------------------------------------------------------------- arm64 runtime
TARGET=aarch64-linux-android21
CFLAGS="--target=$TARGET -O2 -fPIC -fvisibility=hidden -fno-stack-protector -mno-outline-atomics
  -ffunction-sections -fdata-sections -Wall -Wextra -Wno-unused-parameter -DZC_NO_SYSROOT
  -nostdinc -isystem $RES -isystem $HERE/android/include $JNI_INC"
SRCS="cpu mem loader runtime hle_libc hle_zlib hle_gl hle_dl hle_softfloat profile jni_bridge entry"
for f in $SRCS; do
    $CC $CFLAGS -c "$HERE/$f.c" -o "$OBJ/arm64/$f.o"
done
$CC --target=$TARGET -c "$HERE/android/guest_blobs.S" -o "$OBJ/arm64/guest_blobs.o" \
    -DZC_GAME_SO="\"$GAME_SO\"" -DZC_EXT_SO="\"$OUT/guest/libZombieCafeExtension.so\""

# Sort the runtime's imports into the Android libraries that provide them.
GLES2_ONLY=" glAttachShader glBindAttribLocation glCompileShader glCreateProgram glCreateShader glDeleteProgram
  glDeleteShader glDisableVertexAttribArray glEnableVertexAttribArray glGetProgramiv glGetShaderiv
  glGetUniformLocation glLinkProgram glShaderSource glUniform1f glUniform1i glUniform2fv glUniform3f glUniform3fv
  glUniform4f glUniform4fv glUniformMatrix2fv glUniformMatrix3fv glUniformMatrix4fv glUseProgram glVertexAttrib4f
  glVertexAttribPointer "
declare -A LIBS
for sym in $($NM -u "$OBJ"/arm64/*.o | awk '{print $2}' | sort -u); do
    case "$sym" in
    eglGetProcAddress) lib=libEGL ;;
    gl*) if [[ "$GLES2_ONLY" == *" $sym "* ]]; then lib=libGLESv2; else lib=libGLESv1_CM; fi ;;
    inflate* | deflate* | crc32) lib=libz ;;
    __android_log_*) lib=liblog ;;
    dladdr | dlopen | dlsym) lib=libdl ;;
    sin | cos | tan | acos | asin | atan | atan2 | sqrt | pow | exp | log | ceil | floor | fmod | sinf | cosf | sqrtf | \
        floorf | ceilf) lib=libm ;;
    zc_guest_*) continue ;;
    *) lib=libc ;;
    esac
    LIBS[$lib]="${LIBS[$lib]:-} $sym"
done
NEEDED=""
for lib in libGLESv1_CM libGLESv2 libEGL libz liblog libm libdl libc; do
    # shellcheck disable=SC2086
    make_stub $TARGET "$STUBS/arm64" "$lib.so" ${LIBS[$lib]:-}
    NEEDED="$NEEDED -l${lib#lib}"
done

LDFLAGS="--target=$TARGET -fuse-ld=lld -shared -nostdlib -Wl,--hash-style=both -Wl,-z,max-page-size=16384
  -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--no-undefined -Wl,--build-id=sha1 -Wl,--gc-sections"
# shellcheck disable=SC2086
$CC $LDFLAGS -Wl,-soname,libZombieCafeAndroid.so "$OBJ"/arm64/*.o -L"$STUBS/arm64" $NEEDED \
    -o "$OUT/arm64-v8a/libZombieCafeAndroid.so"
$CC $CFLAGS -c "$HERE/android/extension_stub.c" -o "$OBJ/arm64/extension_stub.o.x"
# shellcheck disable=SC2086
$CC $LDFLAGS -Wl,-soname,libZombieCafeExtension.so "$OBJ/arm64/extension_stub.o.x" \
    -o "$OUT/arm64-v8a/libZombieCafeExtension.so"

# ---------------------------------------------------------------- checks
fail() { echo "build.sh: $*" >&2; exit 1; }
for so in "$OUT"/arm64-v8a/*.so; do
    $READELF -d "$so" | grep -q TEXTREL && fail "$so has text relocations"
    $READELF -lW "$so" | awk '$1 == "LOAD" && $NF != "0x4000" { bad = 1 } END { exit bad }' ||
        fail "$so has LOAD segments not aligned for 16 KB pages"
done
exports=$($NM -D --defined-only "$OUT/arm64-v8a/libZombieCafeAndroid.so" | awk '{print $3}')
echo "$exports" | grep -qx JNI_OnLoad || fail "JNI_OnLoad not exported"
n_java=$(echo "$exports" | grep -c '^Java_com_capcom_zombiecafeandroid_')
[ "$n_java" -ge 26 ] || fail "only $n_java Java_* entry points exported"
echo "arm64-v8a/libZombieCafeAndroid.so: $(stat -c %s "$OUT/arm64-v8a/libZombieCafeAndroid.so") bytes, $n_java natives," \
     "needs: $($READELF -d "$OUT/arm64-v8a/libZombieCafeAndroid.so" | awk '/NEEDED/ {gsub(/[][]/, "", $5); printf "%s ", $5}')"
