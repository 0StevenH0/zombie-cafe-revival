#!/usr/bin/env bash
# Boots the real engine through the ARM32 runtime on an x86-64 Linux build
# machine, inside a desktop JVM, and saves software-rendered frames as PNGs.
#
#   src/lib/arm32emu/test/run_harness.sh [frames=900] [capture every=100] [out dir]
#
# Before the first run: src/lib/arm32emu/build.sh (guest patcher), src/java/build.sh
# (tool jars) and `go run ./tool/build_tool -i src/ -o build/` (assets).
#
# Environment knobs:
#   ZC_HARNESS_TAPS=frame:x:y,...  scripted touches (1200x540 screen), e.g.
#                                  620:935:428,760:160:210,820:930:442 = PLAY, pick a chef, select
#   ZC_HARNESS_UI_THREAD=1         touches and sensor calls from a second thread, like the phone
#   ZC_HARNESS_REALTIME=1          pace frames at 30 fps
#   ZC_HARNESS_DUMP_AT=f1,f2       print call statistics at those frames
#   ZC_HARNESS_TRACE=a:b           record calls from frame a, log first-time calls from frame b
#   ZC_HARNESS_VERBOSE=1           log the Java callbacks
#   ZC_PROFILE=1                   sample guest PCs, report hot engine functions
#   ZC_DETERMINISTIC=1             reproducible arc4random, for comparing runs
#   ZC_NO_SOFTFLOAT_HLE=1          run libgcc's soft-float code instead of the host FPU
#   ZC_TRACE_JNI=1                 log every Java method the engine calls
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
E="$(cd "$HERE/.." && pwd)"
ROOT="$(cd "$E/../../.." && pwd)"
FRAMES="${1:-900}"
EVERY="${2:-100}"
OUT="${3:-$E/out/harness}"
if [ -z "${JAVA_HOME:-}" ]; then
    JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
fi
ANDROID_JAR="$ROOT/src/java/.tools/android-4.1.1.4.jar"
ASSETS="$ROOT/build/assets"
for need in "$E/out/guest/libZombieCafeExtension.so" "$ANDROID_JAR" "$ASSETS/data"; do
    [ -e "$need" ] || { echo "run_harness.sh: missing $need (see the header of this script)" >&2; exit 1; }
done

mkdir -p "$OUT/guest" "$OUT/classes" "$OUT/files" "$OUT/frames"
CC=${CC:-clang}
$CC -O2 -g -fPIC -Wall -Wextra -Wno-unused-parameter -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -shared -o "$OUT/libZombieCafeAndroid.so" \
    "$E"/cpu.c "$E"/mem.c "$E"/loader.c "$E"/runtime.c "$E"/hle_libc.c "$E"/hle_zlib.c "$E"/hle_gl.c "$E"/hle_dl.c \
    "$E"/hle_softfloat.c "$E"/profile.c "$E"/jni_bridge.c "$E"/entry.c \
    "$HERE"/hostgl.c "$HERE"/softgl.c "$HERE"/harness_jni.c -lz -lm -lpthread 2>&1 | grep -v mktemp || true
cp "$ROOT/src/lib/armeabi/libZombieCafeAndroid.so" "$E/out/guest/libZombieCafeExtension.so" "$OUT/guest/"

OFF="$ROOT/src/java/com/capcom/zombiecafeandroid/offline"
javac -nowarn -d "$OUT/classes" -cp "$ANDROID_JAR" $(find "$HERE/harness" -name '*.java') \
    "$OFF"/OfflineServer.java "$OFF"/OfflineRouter.java "$OFF"/OfflineStorage.java "$OFF"/OfflineLog.java \
    "$OFF"/RivalRepository.java "$OFF"/RivalGenerator.java "$OFF"/RivalProfile.java "$OFF"/Tier.java \
    "$OFF"/CharacterCatalog.java "$OFF"/FriendCafe.java "$OFF"/CafeState.java "$OFF"/CharacterRecord.java \
    "$OFF"/ZcInput.java "$OFF"/ZcOutput.java "$OFF"/ZcFormatException.java

ZC_GUEST_DIR="$OUT/guest" java -Xss4m -cp "$OUT/classes:$ANDROID_JAR" com.capcom.zombiecafeandroid.Harness \
    "$OUT/libZombieCafeAndroid.so" "$ASSETS" "$OUT/files" "$FRAMES" "$OUT/frames" "$EVERY"
