![banner](/src/assets/images/banner.png)

# Zombie Cafe Revival

An ongoing effort to reverse engineer, preserve, and revive the 2011 Capcom mobile game *Zombie Cafe* — replacing the shut-down online services, fixing long-standing crashes, and eventually rebuilding the client as a cross-platform game in **Godot 4**.

## Download

Offline builds of the original game, which need no server, account or network ([Offline mode](#offline-mode)):

- **[ZombieCafeOffline-arm64.apk](https://github.com/0StevenH0/zombie-cafe-revival/raw/apk-builds/ZombieCafeOffline-arm64.apk)**: for phones that cannot run 32-bit apps (Pixel 7 and later, POCO X7 Pro, most phones from 2024 on) and for Android 14 and 15. It runs the original engine on a built-in ARM32 emulator ([64-bit-only phones](#64-bit-only-phones)). New and not yet tested on a phone.
- **[ZombieCafeOffline.apk](https://github.com/0StevenH0/zombie-cafe-revival/raw/apk-builds/ZombieCafeOffline.apk)**: the engine running natively, for phones that can still run 32-bit apps. Android 14 and later refuse to install it from the phone; use `adb install --bypass-low-target-sdk-block ZombieCafeOffline.apk`.

Both use the same package name and signing key, so installing one over the other keeps your save. Checksums and install notes are on the [`apk-builds`](https://github.com/0StevenH0/zombie-cafe-revival/tree/apk-builds) branch.

## Heritage

This repository began as the work of [**Airyz**](https://airyz.xyz/), who did the original reverse engineering: decoding the proprietary file formats (save games, character data, the `CCTX` texture format), authoring the `LibZombieCafeExtension` runtime patcher that rewrites `libZombieCafeAndroid.so` in memory at load time, and standing up a Cloudflare Workers backend that emulates Capcom's retired `/v1/zca/*` endpoints. Airyz's write-up is the single best primer on the project's technical foundations:

> https://airyz.xyz/p/zombie-cafe-revival/

Everything in this repo up to and including commit [`712edb8f`](../../commit/712edb8f) is a direct continuation of Airyz's work, and the file formats, patch offsets, and server shape documented there remain the source of truth for the current Android build.

## Current maintainer

This fork is maintained by **Edward Yang** ([@edbuildingstuff](https://github.com/edbuildingstuff)). Edward's role is to take the project's next step: moving from *"patched original APK running only on 32-bit ARM Android"* to a **cross-platform Godot 4 client** that reuses the existing Go asset pipeline, binary format definitions, and server backend. Airyz's prior contributions are preserved and credited throughout; the Godot rewrite is a new direction layered on top, not a replacement of that history.

## Where the project is today

![v1.1.0 in-game cafe](docs/images/cafe-v1.1.0.png)

*v1.1.0 running on a Samsung Note 20 Ultra (Android 13): level-33 cafe, 546 toxin (slot-picker IAP bypass working), restored character SFX, no native crashes.*

The existing Android build is functional and playable:

- The original `libZombieCafeAndroid.so` (~1.9 MB, `armeabi-v7a`) is left untouched on disk. At process startup, `LibZombieCafeExtension` is loaded alongside it and uses `mprotect` + memcpy to rewrite a handful of byte ranges — fixing a texture destructor crash, pointing the game's hardcoded server URLs at loopback (the APK is fully offline, see [Offline mode](#offline-mode)), swapping the "money buy" button to "toxin buy," and patching the version string.
- A Go workspace under [`tool/`](tool/) contains five packages: `build_tool` (orchestrates the APK rebuild), `file_types` (binary format definitions for save games, cafes, characters, food, furniture, animations), `cctpacker` (CCTX texture codec), `resource_manager` (JSON ↔ binary round-tripping + atlas packing), and `server` (Cloudflare Workers backend).
- The APK is repackaged with `apktool`, signed with the bundled `debug.keystore`, and installed on device.

**Known limitations inherited from this approach** (all documented in [`docs/rewrite-plan.md`](docs/rewrite-plan.md)):

- Android only — no iOS, desktop, or web. Phones without 32-bit support run the engine in an ARM32 emulator (see [64-bit-only phones](#64-bit-only-phones)).
- Texture destructors are NOPed out to avoid the original crash, leaking a small amount of memory per unload.
- The engine hardcodes 2 character sheets, which blocks backporting the full Japanese character roster.
- The animation format has been decoded but is not yet re-packed by the tooling.
- The APK no longer talks to the Cloudflare Workers server (`tool/server`) at all; see [Offline mode](#offline-mode).

## Offline mode

The legacy APK needs no server, no account and no network:

- **No backend.** Every request the native game makes (`CCUrlConnection::NewRequest`) is answered in-process by a small server written in Java ([`src/java`](src/java), compiled to smali under `src/smali/com/capcom/zombiecafeandroid/offline/`). Server time comes from the device clock, gift polls report nothing waiting, and save uploads are archived locally.
- **Attacking other cafés works offline.** "Visit a random café" and friends' cafés are generated on the device from the café layouts it knows (a bundled template, snapshots of your own earlier café, and any `ServerData.dat` you drop into `Android/data/com.capcom.zombiecafeandroid/files/cafes/`). Each rival's defenders are sized against your account's strength — your zombies' types, levels and the game's own speed/attack/energy stats — at an easy, even or hard tier, and never above levels your own save proves valid. Tune with `rival.difficulty=1.0` in `files/offline.properties`.
- **Friends.** A local profile is logged in automatically and eight neighbor rivals fill the friends list, so friend cafés and the map work without Facebook.
- **IAP is auto-accepted.** Every toxin purchase completes locally through the game's own success callback, the HUD toxin icon opens the store again, and the "frequent purchase" throttle is off.

Design, the recovered request/response protocol and the verification done so far: [`docs/superpowers/specs/2026-09-26-offline-mode-design.md`](docs/superpowers/specs/2026-09-26-offline-mode-design.md). Logs: `adb logcat -s ZCOffline`.

## 64-bit-only phones

Many phones sold since 2023 cannot run 32-bit code at all. Their CPU cores have no 32-bit mode (Cortex-A715 and later, Cortex-X2 and later, Snapdragon 8 Elite), or the system ships without 32-bit support (Pixel 7 and later). The game's engine, `libZombieCafeAndroid.so`, is a closed 32-bit ARM binary, so the classic APK cannot be installed on these phones.

The arm64 APK ships its own 64-bit `libZombieCafeAndroid.so` ([`src/lib/arm32emu`](src/lib/arm32emu/README.md)). It carries the unmodified engine and runs it on an ARM32 interpreter, passing the engine's calls into libc, zlib, OpenGL ES and JNI through to the phone. The `LibZombieCafeExtension` patcher runs inside the emulator exactly as it runs natively. The APK targets Android 7 (API 24), so Android 14 and 15 install it normally. The calls that fail for an app targeting Android 7 (reading the device ID, and a notification method removed in Android 6) go through `offline/OfflineDevice`.

It has been verified on a build machine: the interpreter matches Unicorn on 280,000 random instructions, and the real engine boots through the menus into the café tutorial in a desktop test harness. It has not run on a phone yet; `adb logcat -s ZCArm32 ZCOffline` shows what went wrong if it misbehaves. Design and verification: [`docs/superpowers/specs/2026-09-26-arm64-runtime-design.md`](docs/superpowers/specs/2026-09-26-arm64-runtime-design.md).

## Direction: Godot 4 cross-platform client

After weighing the options — emulating the existing ARM binary, statically decompiling it into portable C++, or rewriting the client on top of a modern engine — we're committing to the **Godot 4 remake** path. The short version of the reasoning:

- Godot handles 2D sprite games of this scale effortlessly and exports to Windows, macOS, Linux, iOS, Android, and the web from a single codebase.
- The Go tooling in `tool/file_types`, `tool/cctpacker`, and `tool/resource_manager` already solves the hard part — reading and writing Zombie Cafe's custom binary formats — so the Godot client can consume assets through an import pipeline instead of re-deriving any of that work.
- The Cloudflare Workers server stays as-is. It's already platform-agnostic.
- Runtime patching and the smali shell go away entirely once a Godot boot path exists, which removes the memory leak, the ARMv7 lock-in, and the 2-character-sheet ceiling in one stroke.

Full reasoning, trade-offs, phased plan, and validation strategy live in [`docs/rewrite-plan.md`](docs/rewrite-plan.md).

## Documentation

- [`docs/rewrite-plan.md`](docs/rewrite-plan.md) — the Godot rewrite plan: goals, scope, phases, validation harness, and the decision log for why this path over the alternatives.
- [`docs/devlog/`](docs/devlog/) — dated development journal entries. Written as the work happens, intended as source material for future blog posts and write-ups.
- [`src/lib/cpp/README.md`](src/lib/cpp/README.md) — build commands for the legacy `LibZombieCafeExtension` runtime patcher.
- [`docs/superpowers/specs/2026-09-26-offline-mode-design.md`](docs/superpowers/specs/2026-09-26-offline-mode-design.md) — offline mode: the client/server protocol, the in-process server, rival generation and the IAP path.
- [`docs/superpowers/specs/2026-09-26-arm64-runtime-design.md`](docs/superpowers/specs/2026-09-26-arm64-runtime-design.md) and [`src/lib/arm32emu/README.md`](src/lib/arm32emu/README.md) — the ARM32 runtime behind the arm64 APK: design, file map, tests, and an on-device checklist.
- [`tool/cctpacker/readme.md`](tool/cctpacker/readme.md), [`tool/resource_manager/README.md`](tool/resource_manager/README.md) — notes on the Go tools.

## Building the legacy Android APK

The quick way builds both APKs without the Android NDK. It needs `go`, a JDK, `clang` and `ld.lld` (LLVM 15 or later), and apktool:

```bash
APKTOOL=/path/to/apktool.jar tool/build_apks.sh
```

It writes `build/out/ZombieCafeOffline.apk` (native 32-bit engine) and `build/out/ZombieCafeOffline-arm64.apk` (the engine in the ARM32 runtime), both signed with `debug.keystore`. After editing `src/java`, run step 2 below first.

The manual steps below still work and build the 32-bit APK. They assume `cmake`, `make`, `go`, `apktool`, `jarsigner`, and the Android NDK are installed and on `PATH`.

### 1. Build `LibZombieCafeExtension`

```bash
cd src/lib/cpp
mkdir build
cd build
cmake ../ -DCMAKE_TOOLCHAIN_FILE=$NDK_HOME/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi-v7a -DANDROID_PLATFORM=android-8
make
```

### 2. (Only after editing `src/java`) Regenerate the offline-mode smali

```bash
src/java/build.sh --test
```

Compiles the offline server, converts it to smali under `src/smali/com/capcom/zombiecafeandroid/offline/` and runs its host tests plus the Go interop test. Needs a JDK and curl; the dex/smali tool jars are fetched from Maven Central with pinned checksums. New classes must also be added to `tool/build_tool/copylist/copy_files.go` (`go test -count=1 ./tool/build_tool/...` fails until they are).

### 3. Run the Go build tool, assemble, sign, install

```bash
go run ./tool/build_tool/ -i src/ -o build/

cp src/lib/cpp/build/libZombieCafeExtension.so ./build/lib/armeabi/libZombieCafeExtension.so

apktool b ./build -o ./build/out/out.apk

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore debug.keystore -storepass zombiecafe ./build/out/out.apk alias_name

adb install ./build/out/out.apk
```

## Legal and attribution

*Zombie Cafe* is copyright Capcom. This is a non-commercial reverse engineering, preservation, and revival project; no original game assets are redistributed by this repository beyond what is necessary for the build pipeline to operate on a legitimately obtained APK. If you represent Capcom and have concerns about any specific file in this tree, please open an issue and it will be addressed promptly.

Credit for the original reverse engineering — the hex-level work, the server protocol recovery, the runtime patch design — belongs to Airyz. Edward Yang is responsible for the Godot rewrite direction and any new content added after the fork point.
