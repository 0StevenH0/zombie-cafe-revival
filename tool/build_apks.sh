#!/usr/bin/env bash
# Builds both offline APKs, no Android NDK needed:
#
#   <out>/ZombieCafeOffline.apk        armeabi: the original 32-bit engine, for phones
#                                      that can run 32-bit apps (targets Android 4.0)
#   <out>/ZombieCafeOffline-arm64.apk  arm64-v8a: the same engine inside the ARM32
#                                      runtime (src/lib/arm32emu), for 64-bit-only
#                                      phones; targets Android 7 so Android 14+ installs it
#
# Usage: tool/build_apks.sh [out dir, default build/out]
# Needs: go, a JDK (javac, jarsigner), clang + ld.lld (LLVM 15+), and apktool
#        (APKTOOL=/path/to/apktool.jar, or `apktool` on PATH).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/build/out}"
WORK="$ROOT/build/apks"
mkdir -p "$OUT"

if [ -n "${APKTOOL:-}" ]; then
    case "$APKTOOL" in *.jar) APKTOOL_CMD=(java -jar "$APKTOOL") ;; *) APKTOOL_CMD=("$APKTOOL") ;; esac
elif command -v apktool >/dev/null; then
    APKTOOL_CMD=(apktool)
else
    echo "build_apks.sh: set APKTOOL to apktool.jar or put apktool on PATH" >&2
    exit 1
fi

sign() {
    jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore "$ROOT/debug.keystore" -storepass zombiecafe \
        "$1" alias_name >/dev/null
}

"$ROOT/src/lib/arm32emu/build.sh"
NATIVE="$ROOT/src/lib/arm32emu/out"

stage() { # $1 variant directory
    rm -rf "$1"
    (cd "$ROOT" && go run ./tool/build_tool/ -i src/ -o "$1/" >/dev/null)
}

# Classic: native 32-bit engine + the ARMv7 patcher.
stage "$WORK/classic"
cp "$NATIVE/armeabi/libZombieCafeExtension.so" "$WORK/classic/lib/armeabi/"
"${APKTOOL_CMD[@]}" b "$WORK/classic" -o "$OUT/ZombieCafeOffline.apk"
sign "$OUT/ZombieCafeOffline.apk"

# arm64: no 32-bit code for the system to load; the engine rides inside the runtime.
stage "$WORK/arm64"
rm -rf "$WORK/arm64/lib/armeabi"
mkdir -p "$WORK/arm64/lib/arm64-v8a"
cp "$NATIVE/arm64-v8a/libZombieCafeAndroid.so" "$NATIVE/arm64-v8a/libZombieCafeExtension.so" \
    "$WORK/arm64/lib/arm64-v8a/"
sed -i -e "s/minSdkVersion: '[0-9]*'/minSdkVersion: '21'/" -e "s/targetSdkVersion: '[0-9]*'/targetSdkVersion: '24'/" \
    "$WORK/arm64/apktool.yml"
"${APKTOOL_CMD[@]}" b "$WORK/arm64" -o "$OUT/ZombieCafeOffline-arm64.apk"
sign "$OUT/ZombieCafeOffline-arm64.apk"

ls -l "$OUT"/ZombieCafeOffline*.apk
