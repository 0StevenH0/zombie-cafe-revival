# Legacy APK Offline Mode — Design

**Date:** 2026-09-26
**Scope:** the legacy Android APK (`src/`), not the Godot rewrite.

## Goal

1. **No backend.** The APK never contacts `zc.airyz.xyz`, Capcom, Facebook or any other server. Every request the native game makes is answered in-process.
2. **Attacking other cafés works offline.** "Visit a random café" and friends' cafés are generated on the device, and their defenders are sized against the player's own account strength.
3. **IAP is auto-accepted.** Toxin purchases complete locally from every entry point, with no store or server check, and without the purchase-frequency throttle.

## How the client talks to a server

Everything below was recovered from `libZombieCafeAndroid.so` (it still has its C++ symbols) with a Thumb disassembler.

```
native CCServer::Retrieve*/Save*/GetServerTime
  -> CCUrlConnection::NewRequest(url, query, callbackId)   fails early unless javaConnected()
  -> Java CC_Android.fromNative_NewRequest -> AsyncTask q
  -> URLManager.a(queryUrl, callbackId)                    <- was: Apache HttpClient GET/POST
  -> NetworkTask -> native NewRequestServerCallback(ok, bytes, len, callbackId)
  -> CCServer::Android_ServerCallback: switch (callbackId)
```

| id | request | response the native parser expects |
|---:|---|---|
| 0 | analytics upload (`adata.mkt`) | any success; purges the local event log |
| 2 | `savegamestate.php?…` (POST `ServerData.dat`) | ignored ("do nothing") |
| 4 | `givegift.php?…` | ignored |
| 6 | `versioncheck.php` | ignored ("UNUSED!") |
| 7 | `gettimestamp.php` | decimal Unix seconds, **5–15 bytes**, `atoi`'d |
| 8 | `getmetadata.php?v=63&u0=<id>` | `id:meta\n` lines, NUL-terminated (see below) |
| 10 | `getgamestate.php?v=63&u=<id>` (also `getsng`, `getspecialgamestate`) | a `ServerData.dat` blob, or `BAD_VERSION`/`NO_DATA`/`NOT_FOUND` |
| 11 | `getgifts.php?…` | `NO_DATA` = nothing waiting; else gift lines (>31 bytes) |
| 12 | `getmetadata.php?v=63&u0=…&uN=…` | as 8, for the whole friends list |
| 13 | `getrandomgamestate.php?v=63` | a `ServerData.dat` blob |
| 14 | `gotgifts.php` | ignored |
| 15, 16 | CRAM "Hoover" session/IAP reports | failure is harmless (the old server never implemented them) |
| 17, 18 | `gettimestamp.php` for IAP bookkeeping | as 7 |

Details that matter:

- The JNI bridge passes the raw `GetByteArrayElements` pointer, which is **not** NUL-terminated, yet metadata, gifts and timestamps are parsed with `strcmp`/`strchr`/`atoi`. Text replies therefore carry an explicit trailing NUL.
- Metadata lines are `level:rating:63:flag:str:str:pct` — the same `%i:%f:%i:%i:%s:%s:%i` shape `ZombieCafe::saveGameState` writes for the player. The last line must end in `\n` or it is dropped.
- `NetworkTask`'s constructor ignores its success flag and always reports success, so failures must be delivered straight through `URLManager.NewRequestServerCallback(false, …)`, exactly as the original code did.
- `ServerData.dat` is `version(63) + CafeState + Cafe`, written by `GameStateCafe::save()`/`::uninit()` — so it is fresh every time the player leaves their café for the map. It is the same format the friend-café loader (`GameStateFriendCafe::deserializeGame`) consumes and that `tool/file_types/friend_cafe.go` parses.
- Upstream's `gettimestamp.php` answered `"i dont know what to send here\n"` (30 bytes), so the time check always failed. Offline it returns the device clock, which is the game's normal "SERVER TIME IS CORRECT" path (`L_GotServerTime` only flags a cheater when server and device clocks differ by more than a day).

### Friends and "logged in"

Friends, friend cafés and gifts are gated on `CCFacebook::IsLoggedIn` → Java `IsLoggedIn()` = connectivity && `mLoggedIn`. The native side learns identities only through two JNI callbacks: `setFBInfo(name, first, last, id)` and `sendFriendInfo(index, count, name, uid, first, last, pic)` (index 0 allocates the list; `index == count - 1` triggers `FriendsUpdatedCallback` → the metadata request). `CCFacebook::GetUserId` runs `atoi` on the id, so ids must be positive 32-bit numbers.

## What changed

### In-process server (`src/java` → `src/smali/com/capcom/zombiecafeandroid/offline`)

The server is written in Java and compiled to smali by `src/java/build.sh` (javac → dx → baksmali, tool jars pinned by SHA-256). Both the Java sources and the generated smali are committed; apktool only ever sees the smali.

| class | role |
|---|---|
| `OfflineBridge` (game package) | called by `URLManager.a`; answers via `OfflineServer`, delivers through `NetworkTask` (success) or `URLManager.NewRequestServerCallback` (failure). Lives in the game package because `URLManager`/`NetworkTask` are package-private. |
| `OfflineRouter` | pure routing table above; no Android APIs, unit-tested on the host |
| `OfflineServer` | router backend: player snapshot, rival generation, metadata, snapshot archiving |
| `RivalGenerator`, `RivalProfile`, `Tier` | rival cafés (next section) |
| `FriendCafe`, `CafeState`, `CharacterRecord`, `ZcInput`/`ZcOutput` | `ServerData.dat` codec (big-endian ints, little-endian floats, as in `tool/file_types`) |
| `CharacterCatalog` | per-type stats from `assets/data/characterData.bin.mid` |
| `RivalRepository` | reads `files/ServerData.dat`, layouts, imports; archives snapshots; pins neighbor layouts |
| `OfflineStorage` | files dir / external files dir / assets, from the `Context` on device and from temp dirs in host tests |
| `OfflineFacebook` | local profile + neighbors for the Facebook bridge |
| `OfflineStore` | completes purchases |

### Smali patches

| file | change |
|---|---|
| `URLManager.smali` | `a(Context)` always reports connected; `a(String,int)` → `OfflineBridge.handleRequest`; `b(String,int)` (plain URL fetch, unreachable from native) does nothing |
| `CapcomFacebook.smali` | both `ExecuteFacebook` overloads → `OfflineFacebook.execute` |
| `d.smali` | the Facebook worker no longer parks in `Looper.loop()` (it leaked a thread per Facebook action) |
| `billing/SmurfsBilling.smali` | `onCreate` → `OfflineStore.completePurchase(getIntent())`, then `finish()` |
| `ZombieCafeAndroid.smali` | no `ChartBoost.install()` (it phoned home on every launch) |

### Native patches (`src/lib/cpp/ZombieCafeExtension.cpp`)

- Server base URLs (`/zca`, `/zcw` on Amazon, `/x`, updater) now point at `http://127.0.0.1/…`. The Java side ignores the host; loopback is only a backstop so nothing that slipped past `URLManager` could reach a remote server.
- The `setNop(base + 0x9dee8)` from the original import is gone. That address is the `bl BuyToxinDialog::show()` in the `BUTTON_ADDTOXIN` branch of `GameStateCafe::onHudButtonPress` — it is why the HUD toxin icon "only clicked" (see the IAP bypass spec's open question). The HUD now opens the same `BuyToxinDialog` the low-toxin slot picker uses.
- `ZombieCafe::isPurchaseTooFrequent()` (+0x121f20) always returns false (`movs r0,#0; bx lr` over its prologue), so repeated free purchases are never turned into a "frequent purchase" notice.

## Rival cafés and account strength

Attacks happen in `GameStateFriendCafe`: `beginAttack` spawns the blob's zombies as defenders and sums `calculateDifficulty` over them, which is `currentEnergy / maxEnergy × (speed + attack)` with `maxEnergy = baseEnergy × zombieLevelEnergyMultiplier[level]`. The generator measures strength with the same numbers: `power = (speed + attack) × baseEnergy × levelFactor(level)`, where the speed/attack/energy come from `characterData.bin.mid` and `levelFactor` stands in for the multiplier table (which lives in `constants.bin` and is only needed to compare rosters).

For each rival:

1. **Player strength** = Σ power of the player's zombies (full energy) from `files/ServerData.dat`.
2. **Tier** → a strength ratio: easy 0.60–0.85, even 0.90–1.10, hard 1.15–1.40 (random cafés: 35/45/20 %). The optional `rival.difficulty` knob multiplies it.
3. **Defenders** are added until the rival reaches `ratio × player strength`, capped at `player roster + 2` (max 12). Types come from the player's own roster first, then the layout's original zombies, then base-game infectable customers unlocked at the rival's level. The last defender is tired out (partial energy) instead of overshooting by a whole zombie.
4. **Layout** (the café floor plan and its owner chef) is picked from, by weight: cafés the player imported (3), the bundled `assets/offline/rival_template.dat` (2), and snapshots of the player's own earlier café archived on each save (1).

Safety rails keep every value inside ranges the player's own save proves valid: defender levels never exceed the highest level in the player's roster; the rival café level never exceeds the player's; defenders are copies of real serialized zombies with only type, name, level and energy changed (the other bytes satisfy `Character::isValid`); "full" energy is written as a large value that `Character::deserialize` clamps to the true maximum.

Host tests over the real fixture measure mean rival/player power of 0.81 (easy), 1.04 (even) and 1.21 (hard); a player with 4× the roster at higher levels meets rivals ~7× stronger with bigger rosters.

**Neighbors.** Eight fixed rivals (`RivalProfile.NEIGHBORS`, ids `900000001`–`900000008`) form the friends list, each with a fixed tier. A neighbor keeps the layout it was first given (`files/offline/neighbors/<id>.dat`; delete to reroll), its roster is deterministic per player level (it reshuffles when the player levels up), and its metadata level matches the café it serves.

**Importing real cafés.** Drop any player's `ServerData.dat` into `Android/data/com.capcom.zombiecafeandroid/files/cafes/` (or the app's internal `files/offline/cafes/`); it joins the layout pool. Its defenders are still regenerated against your strength.

**Tuning.** `files/offline.properties` (external or internal files dir): `rival.difficulty=1.0`.

## IAP

Every purchase path ends in `ZombieCafeAndroid.BuyToxin(slot)` (from `BuyToxinDialog::tick` via `javaBuyStuff`), which launches `SmurfsBilling`. Its `onCreate` now calls `OfflineStore.completePurchase`, which takes the product from the `ItemName0` extra (falling back to the recorded slot) and calls the game's own success callback `boughtToxin` → `PurchaseAndroidToxin` → `ZombieCafe::GiveBoughtToxin`. The Activity still opens and finishes so the native shop sees the onPause/onResume cycle that clears its "purchase in progress" state (see the IAP bypass spec). Amazon (`amazonKindle` is only ever false) and PayPal (`javaBuySmurfBerriesPaypal` has no callers) are dead paths.

## Facebook

`OfflineFacebook` logs a local profile ("Zombie Chef", a random 9-digit id kept in `SharedPreferences`) in on `INIT` (sent by `GameStateMainMenu::init`, after the server objects exist), answers `GET_FRIENDS` with the neighbors, and honors `LOGOUT` until the player logs in again. Posting to walls/stories is a no-op.

## Verification

- `src/java/build.sh --test`: 69 host checks (codec round-trip against the real fixture, router formats and byte limits, generator bounds, tier ordering, strength scaling, determinism, and the full `OfflineServer.respond` path over temp directories: neighbor pinning, metadata/café level agreement, snapshot dedupe and pruning, corrupt imports, `rival.difficulty`) plus `tool/file_types/offline_rival_interop_test.go`, which re-parses every generated rival with the Go reference parser and checks the layout is untouched.
- `tool/build_tool/copylist/copy_files_test.go`: every smali file is in the build copy list and every listed file exists (run with `-count=1`; Go's test cache does not notice new files in `src/`).
- The whole smali tree assembles with smali 2.5.2; dexlib2's register-type analysis over the patched classes shows no errors.
- The native patcher cross-compiles for `armv7a` Thumb with clang, and its real `JNI_OnLoad`, run on the host against a copy of the `.so`, produces exactly the intended byte changes.
- `go run ./tool/build_tool` + `apktool b` produce an APK containing all 370 classes and the new assets.

**Not verified here:** running on a device. Checklist for the first on-device run (`adb logcat -s ZCOffline`):

1. Launch with networking disabled; the game reaches the café with no connection errors.
2. Leave the café, open the map, "visit a random café": a `rival …` log line shows tier/level/defenders; attack it.
3. Friends screen lists the eight neighbors; visiting one shows their café.
4. With tutorial step 22 done, tap the HUD toxin icon: the store opens; buying any slot credits toxin, repeatedly.

## Rollback

`git revert` the commit. To only hide the HUD store again, restore `Memory::setNop((void*)(base + 0x9dee8), 4);`.
