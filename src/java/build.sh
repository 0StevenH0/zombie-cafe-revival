#!/usr/bin/env bash
# Builds the offline-mode Java sources in this directory into smali under
# src/smali, which is what apktool actually assembles.
#
#   src/java/build.sh          compile -> dex -> smali, install into src/smali
#   src/java/build.sh --test   also run the host self-test and the Go interop
#                              test (tool/file_types/offline_rival_interop_test.go)
#
# Needs a JDK (11+) and curl; --test also needs Go. The dex/smali tool jars are
# fetched once from Maven Central into src/java/.tools with pinned checksums.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
TOOLS="$HERE/.tools"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

RUN_TESTS=0
for arg in "$@"; do
    case "$arg" in
        --test) RUN_TESTS=1 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

MAVEN=https://repo1.maven.org/maven2
# path-under-maven-central  sha256
JARS="
com/jakewharton/android/repackaged/dalvik-dx/16.0.1/dalvik-dx-16.0.1.jar 1e4b645628e3bdb097b5331d669e177ef235a551582a8c646dbe36865e541907
org/smali/baksmali/2.5.2/baksmali-2.5.2.jar 1ed236266d7dc4907aade0b19a34f77efac25342b63c8ace52e579039941b389
org/smali/dexlib2/2.5.2/dexlib2-2.5.2.jar 5a5c8982d8bd7d6e3bb1a0713049e3c78b719ec32b20f6b619885cec30a0dd61
org/smali/util/2.5.2/util-2.5.2.jar 4f580a9cff3ebb83cb3fd20bec88e37e4f183796ca652732992611620282daea
com/beust/jcommander/1.64/jcommander-1.64.jar 156be736199c990321d9ff77090b199629cfc9865e2d6c13f7cd291bb1641817
com/google/guava/guava/27.1-android/guava-27.1-android.jar 686404f2d1d4d221911f96bd627ff60dac2226a5dfa6fb8ba517073eb97ec0ef
com/google/guava/failureaccess/1.0.1/failureaccess-1.0.1.jar a171ee4c734dd2da837e4b16be9df4661afab72a41adaf31eb84dfdaf936ca26
com/google/android/android/4.1.1.4/android-4.1.1.4.jar 84072541cbb711eff89f7277100ff854929a446dba7ceb1b195c340e0b4fd3cb
"

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

mkdir -p "$TOOLS"
echo "$JARS" | while read -r path sum; do
    [ -n "$path" ] || continue
    jar="$TOOLS/$(basename "$path")"
    if [ ! -f "$jar" ] || [ "$(sha256 "$jar")" != "$sum" ]; then
        echo "fetching $(basename "$path")"
        curl -fsSL --retry 5 --retry-delay 5 "$MAVEN/$path" -o "$jar.part"
        if [ "$(sha256 "$jar.part")" != "$sum" ]; then
            echo "checksum mismatch for $(basename "$path")" >&2
            rm -f "$jar.part"
            exit 1
        fi
        mv "$jar.part" "$jar"
    fi
done

SEP=":"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) SEP=";" ;; esac
ANDROID_JAR="$TOOLS/android-4.1.1.4.jar"
BAKSMALI_CP="$TOOLS/baksmali-2.5.2.jar$SEP$TOOLS/dexlib2-2.5.2.jar$SEP$TOOLS/util-2.5.2.jar$SEP$TOOLS/jcommander-1.64.jar$SEP$TOOLS/guava-27.1-android.jar$SEP$TOOLS/failureaccess-1.0.1.jar"

cd "$HERE"
mkdir -p "$WORK/stubs" "$WORK/classes"
# Stubs stand in for game classes that only exist as smali; they are never dexed.
javac --release 8 -nowarn -cp "$ANDROID_JAR" -d "$WORK/stubs" $(find stubs -name '*.java')
javac --release 8 -Xlint:all,-options -Werror -cp "$ANDROID_JAR$SEP$WORK/stubs" -d "$WORK/classes" \
    $(find com -name '*.java')

java -cp "$TOOLS/dalvik-dx-16.0.1.jar" com.android.dx.command.Main --dex --min-sdk-version=8 \
    --output="$WORK/offline.dex" "$WORK/classes"
java -cp "$BAKSMALI_CP" org.jf.baksmali.Main disassemble --api 8 --use-locals --sequential-labels \
    -o "$WORK/smali" "$WORK/offline.dex"

DEST="$REPO/src/smali/com/capcom/zombiecafeandroid"
rm -rf "$DEST/offline"
cp -R "$WORK/smali/com/capcom/zombiecafeandroid/offline" "$DEST/offline"
cp "$WORK/smali/com/capcom/zombiecafeandroid/OfflineBridge.smali" "$DEST/OfflineBridge.smali"
echo "installed $(find "$DEST/offline" -name '*.smali' | wc -l | tr -d ' ') offline classes + OfflineBridge into src/smali"

if [ "$RUN_TESTS" = 1 ]; then
    mkdir -p "$WORK/test"
    javac --release 8 -Xlint:all,-options -cp "$WORK/classes$SEP$ANDROID_JAR" -d "$WORK/test" \
        $(find test -name '*.java')
    cd "$REPO"
    ZC_OFFLINE_CLASSPATH="$WORK/classes$SEP$WORK/test$SEP$ANDROID_JAR" \
        go test ./tool/file_types -run TestOfflineRivalInterop -count=1 -v
fi
