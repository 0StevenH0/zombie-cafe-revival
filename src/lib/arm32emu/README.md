# arm32emu: the engine on 64-bit-only phones

Newer phones (Pixel 7 and later, the POCO X7 Pro and most 2024+ chips such as
the Dimensity 8400/9300 and Snapdragon 8 Elite) have no 32-bit CPU mode, so
they cannot load the game's `libZombieCafeAndroid.so`, a closed ARMv5TE binary
from 2011. This directory builds a 64-bit `libZombieCafeAndroid.so` that
carries the original engine inside it and runs it on an ARM32 interpreter.
Nothing in the engine is rewritten; the Java side of the APK is unchanged
apart from the Android 7 fixes in `offline/OfflineDevice`.

```
Java (unchanged)                 arm64 libZombieCafeAndroid.so (this directory)
  System.loadLibrary  ------->   JNI_OnLoad: reserve 4 GB guest space, load the
                                 embedded engine + patcher, run their JNI_OnLoad
  CapcomRenderer.render(dt) -->  Java_* entry -> guest call -> interpreter
                                   engine imports  -> host libc/libm/zlib/GLES
  CC_Android.fromNative_* <---     engine JNI      -> guest JNIEnv -> real JNI
```

| File | What it does |
| --- | --- |
| `cpu.c` | ARMv5TE interpreter, ARM + Thumb-1 (+ the Thumb-2 hints the patcher writes). ARMv7 semantics where v5 and v7 differ, because the engine shipped on ARMv7 phones. |
| `mem.c` | 4 GB guest address space (guest pointer `a` is host `zc_mem + a`), heap allocator, stacks. |
| `loader.c` | Loads 32-bit ARM ELF shared objects: segments, REL relocations (the engine has text relocations), init arrays. |
| `runtime.c` | Guest threads, the fair guest lock, host-call thunks (`udf` traps), guest calls. |
| `hle_libc.c` `hle_zlib.c` `hle_gl.c` `hle_dl.c` | The engine's 154 imports on the host: bionic libc/libm (32-bit layouts, soft-float ABI, `printf`/`scanf` varargs, `FILE` fields read by its `getc` macro, `setjmp`), zlib stream translation, GLES 1/2, and `dlopen`/`dladdr` over guest libraries. |
| `hle_softfloat.c` | Replaces libgcc's soft-float and division helpers inside the engine with host FPU code (bit-identical, 2.4x faster frames). |
| `jni_bridge.c` | Guest `JNIEnv`/`JavaVM` in guest memory; 32-bit handles for local/global refs; method signatures recorded so variadic `Call*Method` arguments decode correctly. |
| `entry.c` | `JNI_OnLoad` and the 26 `Java_*` natives the Java code declares. |
| `profile.c` | Optional PC-sampling profiler and first-call tracer (host harness). |
| `platform.h` | libc declarations: host headers for tests, spelled-out bionic LP64 ABI for the NDK-less Android build. |
| `android/` | Minimal headers and the blob embedding for the build without an NDK. |

The patcher `src/lib/cpp/ZombieCafeExtension.cpp` is not duplicated here: it is
compiled for ARMv5TE and runs inside the emulator exactly as it runs natively
in the classic APK (`dlopen` / `dlsym` / `dladdr` see the guest libraries).

## Building

```bash
src/lib/arm32emu/build.sh          # arm64-v8a libraries, no NDK needed
tool/build_apks.sh                 # both APKs (APKTOOL=/path/to/apktool.jar)
```

`build.sh` needs clang and ld.lld (LLVM 15+) and a JDK (for `jni.h`). It
generates link stubs for the Android system libraries, links with 16 KB page
alignment, and fails if a library has text relocations, misaligned segments or
missing exports. The same script also produces `out/armeabi/libZombieCafeExtension.so`
for the classic APK, so neither APK needs the NDK.

## Testing on a build machine

```bash
pip install unicorn capstone
clang -O2 -fPIC -shared -o /tmp/cputest.so src/lib/arm32emu/cpu.c src/lib/arm32emu/test/cpu_testlib.c
python3 src/lib/arm32emu/test/cpu_diff.py /tmp/cputest.so 50000 1
```

`cpu_diff.py` runs random ARMv5TE instructions on the interpreter and on
Unicorn (Cortex-A9) one at a time and compares registers, flags and memory.

```bash
ZC_HARNESS_TAPS=620:935:428,760:160:210,820:930:442 src/lib/arm32emu/test/run_harness.sh 1500 100
```

`run_harness.sh` builds the runtime for x86-64 Linux, loads it into a desktop
JVM next to stand-ins for the game's Java callbacks (and the real offline
server classes), and boots the unmodified engine. A small software GLES 1
renderer writes frames to `out/harness/frames/*.png`. The taps above press
PLAY, pick a chef and enter the café tutorial. The script's header lists the
debugging knobs (profiler, call tracer, deterministic mode, second input
thread).

## On a phone

Logs: `adb logcat -s ZCArm32 ZCOffline`. A guest fault logs the guest PC and
registers before the process dies; look the PC up in the engine's symbols
(`llvm-nm -DC src/lib/armeabi/libZombieCafeAndroid.so`, subtract `0x10000000`).
