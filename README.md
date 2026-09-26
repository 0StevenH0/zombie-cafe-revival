# Zombie Cafe Revival: offline APKs

Both APKs are built from `claude/zombie-cafe-offline-xro7e6` at commit `5916824`.
They run fully offline: there is no backend, rival cafes are generated on the
device, and toxin purchases complete locally. They also run full screen: the
status and navigation bars stay hidden, and a swipe in from the edge shows them
for a moment.

| APK | For |
| --- | --- |
| [`ZombieCafeOffline-arm64.apk`](ZombieCafeOffline-arm64.apk) | Phones that can't run 32-bit apps (POCO X7 Pro, Pixel 7 and later, most phones from 2024 on), and any phone on Android 14 or 15 |
| [`ZombieCafeOffline.apk`](ZombieCafeOffline.apk) | Phones that can run 32-bit apps, on Android 13 or older |

Direct downloads, which you can open on the phone:

- https://github.com/0StevenH0/zombie-cafe-revival/raw/apk-builds/ZombieCafeOffline-arm64.apk
  (SHA-256 `f49b5521e4884d90ab91e84377731af6b4a2fa0f1608a1d7758ab87e81f6dedc`)
- https://github.com/0StevenH0/zombie-cafe-revival/raw/apk-builds/ZombieCafeOffline.apk
  (SHA-256 `816a27d69e1319c716f8935657ea405df89068ed67340cfb235e2f93ed19bdd6`)

## Which one?

- **arm64** carries the original 32-bit engine and runs it on an ARM32 emulator
  built into the app (`src/lib/arm32emu` on the source branch), so it works on
  phones with no 32-bit support. It targets Android 7, so Android 14 and 15
  install it normally. It is new and hasn't been tested on a phone yet. If it
  crashes or shows a black screen, `adb logcat -s ZCArm32 ZCOffline` shows why.
- **classic** runs the engine natively. It targets Android 4, so Android 14 and
  later only install it from a computer:
  `adb install --bypass-low-target-sdk-block ZombieCafeOffline.apk`

Both are signed with the repo's `debug.keystore`, the same key other Zombie Cafe
Revival builds use. Either one installs over those builds, and over each other,
and keeps the save. If a copy signed with a different key is installed,
uninstall it first; that deletes its local save.

Neither build needs the Android NDK: run `tool/build_apks.sh` on the source
branch.

This branch only holds build output and shares no history with the source branches.
