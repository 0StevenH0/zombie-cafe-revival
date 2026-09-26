# arm64 runtime: running the 32-bit engine on 64-bit-only phones

**Date:** 2026-09-26
**Status:** implemented and verified on the build machine; not yet run on a phone.
**Code:** [`src/lib/arm32emu/`](../../../src/lib/arm32emu/)

## Problem

The engine, `lib/armeabi/libZombieCafeAndroid.so`, is a closed ARMv5TE
(Thumb-1, soft-float) binary. Phones built on AArch64-only cores cannot run it:
Cortex-A715 and later and Cortex-X2 and later dropped AArch32, and Pixel 7+ ship
64-bit-only system images. Reported case: POCO X7 Pro (Dimensity 8400, eight
Cortex-A725), where the installer rejects the APK. A second, independent block:
Android 14 and 15 refuse to install apps targeting API < 23/24, and the classic
APK targets API 14. It cannot target higher, because the engine has text
relocations, which Android refuses to load for apps targeting API 23+.

There is no source for the engine, and the Godot rewrite is not playable yet,
so the only way to run the original game on these phones is to carry an ARM32
CPU with it.

## Design

The arm64 APK's `lib/arm64-v8a/libZombieCafeAndroid.so` is a runtime, not the
engine. Java loads it with the same `System.loadLibrary` call.

1. **Guest address space.** 4 GB reserved `PROT_NONE`, committed on demand.
   Guest address `a` is host `zc_mem + a`, so translating a pointer is one add
   and the host can hand guest buffers straight to GL, zlib and libc. The
   engine loads at `0x10000000`; heap, stacks, runtime data and host-call
   thunks have fixed regions (`mem.h`).
2. **CPU.** A portable C interpreter for exactly the ARMv5TE subset the engine
   uses (surveyed with Capstone: 4,108 Thumb functions, 95 ARM ones). Where
   ARMv5 and ARMv7 differ (unaligned accesses, ALU writes to PC), it follows
   ARMv7, because that is the hardware the engine actually shipped on. The
   patcher's `NOP` is the Thumb-2 hint `0xBF00`, which it also executes.
3. **Imports.** Every undefined symbol resolves to a thunk: an ARM `udf #n` in
   guest memory that traps to a host function. The 154 imports cover bionic
   libc/libm with 32-bit layouts (4-byte `long`/`time_t`, the 84-byte `FILE`
   whose `_r`/`_p`/`_flags` the engine's `getc` macro reads directly), soft-float
   argument passing, AAPCS varargs for `printf`/`sscanf`/`__android_log_print`,
   `setjmp`/`longjmp` (the engine's libpng error path), `qsort` with a guest
   comparator, zlib with 32-bit `z_stream`s shadowed by host streams, and 75
   GLES 1/2 entry points. The engine never binds buffer objects, so every
   vertex/index/pixel pointer is a guest address and passes straight through.
4. **JNI.** The guest gets its own `JNIEnv`/`JavaVM`, whose function tables
   are thunks. Objects become 32-bit handles: per-thread local references
   truncated when the native call returns, and a shared global table. Method
   and field IDs remember their signatures, so `Call*Method(env, obj, mid, ...)`
   decodes floats promoted to double, 8-byte-aligned longs and so on from guest
   registers and stack. The 26 `Java_*` functions Java declares and the engine
   exports are forwarded the other way.
5. **The patcher runs as a guest.** `src/lib/cpp` is compiled for ARMv5TE,
   embedded, and loaded as a second guest library. Its `dlopen`/`dlsym`/`dladdr`
   resolve against guest libraries, so the classic and arm64 APKs apply
   identical patches from one source file. The arm64 `libZombieCafeExtension.so`
   is an empty stub, because Java still loads that name.
6. **Threads.** On the phone, rendering runs on the GL thread while touch
   events call `mouseDown`/`mouseUp`/`mouseMove` from the UI thread. Guest code
   runs under one fair (FIFO ticket) lock. It is released around every call
   back into Java, and a long guest call hands it over every 4M instructions,
   so a touch never waits behind the multi-second café load. Each host thread
   gets its own guest stack and register file.
7. **Speed.** The engine does all floating point through libgcc helpers. Those
   42 helpers are replaced by host FPU functions with libgcc's exact rounding and
   saturation, for a 2.4x speedup.
8. **Build without the NDK.** clang/lld cross-compile for `aarch64-linux-android21`
   against `platform.h`, which declares the bionic LP64 ABI the runtime uses,
   plus the JDK's `jni.h`. Link stubs for libc, libm, libdl, liblog, libz, GLES
   and EGL are generated per build. Segments are 16 KB-aligned for 16 KB-page
   devices.

## Java changes needed to target API 24

The arm64 APK targets API 24 (installable on Android 15) with minSdk 21. Under
that target the platform refuses two calls the 2011 code makes, so these call
sites (in the game and in the bundled ad and tracking SDKs, 12 in all) now go
through `offline/OfflineDevice`:

- `TelephonyManager.getDeviceId()`/`getSimSerialNumber()` throw without the
  runtime `READ_PHONE_STATE` grant. The helper returns null, which is what
  Android 10+ gives legacy apps anyway. `DeviceType.getDeviceID()` runs at startup.
- `Notification.setLatestEventInfo()` no longer exists on Android 6+; the café
  reminder receiver crashed in the background. The helper fills in the fields
  the system notification template reads. This also fixes the classic APK.

External-storage writes (screenshots) already catch their exceptions.

## Verification (build machine)

- **Instruction semantics:** 280,000 random ARM and Thumb instructions compared
  one at a time with Unicorn (Cortex-A9): registers, NZCVQ/T and memory match.
- **Patcher:** the ARMv5TE and ARMv7 builds of `ZombieCafeExtension.cpp`, run
  under Unicorn against the engine, produce byte-identical patched images (22
  ranges) to the x86 host build.
- **The real engine, end to end:** the runtime, built for x86-64, boots the
  unmodified engine in a desktop JVM with stand-ins for the Java callbacks and
  the real offline server. It gets through the Beeline splash and loading bar
  to the main menu, answers the startup dialog, then goes PLAY → choose a chef →
  café tutorial, and ran 3,000 frames with a second thread delivering touches
  and sensor calls. Guest heap is stable at 10.1 MB; frames were rendered with
  a software GLES 1 rasterizer and inspected.
- **Soft-float replacement:** with deterministic randomness, frames through
  the café tutorial are pixel-identical with and without it.
- **Speed (x86-64 build machine):** about 2 ms per menu frame and 4.5 ms per café
  frame, with a 1 to 2.4 s café load. The game budgets 33 ms per frame.
- **Android build:** all 146 symbols the arm64 library imports are public
  bionic/NDK symbols available at API 21 (checked against bionic's
  `libc.map.txt`, `libm.map.txt`, `libdl.map.txt`); no text relocations;
  26 natives exported.

## Not verified yet

Nothing has run on an ARM64 phone. Areas where a phone could differ from the
harness: ART's JNI (the harness uses HotSpot), the vendor GLES 1 driver, real
performance on mobile cores, and Android lifecycle events (pause/resume,
surface loss) that the harness does not simulate. On-device checklist:

1. Installs on Android 14/15 without `adb` flags; launches to the Beeline splash.
2. Main menu, then PLAY into the café tutorial; sound plays.
3. A normal play session: cook, serve, level up, save and relaunch.
4. Background and resume (home button) without a black screen or crash.
5. A raid on a generated rival café; a toxin purchase.
6. `adb logcat -s ZCArm32` shows no `FATAL` lines.
