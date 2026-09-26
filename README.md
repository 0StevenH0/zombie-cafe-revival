# Zombie Cafe Revival: offline APK

[`ZombieCafeOffline.apk`](ZombieCafeOffline.apk) is built from
`claude/zombie-cafe-offline-xro7e6` at commit `a5ee64e`. It runs fully offline:
there is no backend, rival cafes are generated on the device, and toxin purchases
complete locally.

- SHA-256: `19a77e170465bce69de0fa416de94c79b86d658230f1f788021d049610bf0acb`
- Signed with the repo's `debug.keystore`, the same key other Zombie Cafe Revival
  builds use, so it installs over them and keeps the save.
- `libZombieCafeExtension.so` was built with clang and lld instead of the NDK and
  checked in an ARM emulator against the game library. Not yet tested on a device.

## Install

- **Android 13 or older:** open the APK on the phone.
- **Android 14 or newer:** the installer rejects apps that target old Android
  versions, so install from a computer:
  `adb install --bypass-low-target-sdk-block ZombieCafeOffline.apk`
- **32-bit ARM only:** phones without 32-bit app support (Pixel 7 and later, for
  example) can't run it.
- If a copy signed with a different key is installed, uninstall it first. That
  deletes its local save.

This branch only holds build output and shares no history with the source branches.
