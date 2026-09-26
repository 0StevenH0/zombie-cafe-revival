package com.capcom.zombiecafeandroid.offline;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Host-side checks for the offline server (no Android runtime needed).
 *
 * <pre>
 * java -cp classes:android.jar com.capcom.zombiecafeandroid.offline.OfflineSelfTest \
 *     tool/file_types/testdata/ServerData.dat [characterData.bin.mid] [out-dir]
 * </pre>
 *
 * With an out-dir, every generated rival is written there so the Go reference
 * parser can validate it (tool/file_types/offline_rival_interop_test.go).
 */
public final class OfflineSelfTest {
    private static int passed;
    private static int failed;

    private OfflineSelfTest() {}

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("usage: OfflineSelfTest <ServerData.dat> [characterData.bin.mid] [out-dir]");
            System.exit(2);
        }
        OfflineLog.hostMode = true;
        byte[] fixture = readFile(new File(args[0]));
        CharacterCatalog catalog = args.length > 1 && args[1].length() > 0
                ? CharacterCatalog.parse(readFile(new File(args[1]))) : CharacterCatalog.empty();
        File outDir = args.length > 2 ? new File(args[2]) : null;
        if (outDir != null && !outDir.isDirectory() && !outDir.mkdirs()) {
            throw new IOException("cannot create " + outDir);
        }

        testRoundTrip(fixture);
        testCatalog(catalog);
        testRouter();
        testProfiles();
        testGenerator(fixture, catalog, outDir);
        testServer(fixture, args.length > 1 && args[1].length() > 0 ? readFile(new File(args[1])) : null);

        System.out.println("=== Offline self-test: " + passed + " passed, " + failed + " failed ===");
        System.exit(failed == 0 ? 0 : 1);
    }

    // ------------------------------------------------------------------

    private static void testRoundTrip(byte[] fixture) throws Exception {
        FriendCafe cafe = FriendCafe.parse(fixture);
        check("fixture round-trips byte-identically", Arrays.equals(fixture, cafe.toBytes()));
        check("fixture version is 63", cafe.version == 63);
        check("fixture cafe level is 4", cafe.state.level == 4);
        check("fixture has an owner chef (type 61)", cafe.state.owner != null && cafe.state.owner.type == 61);
        check("fixture has 3 zombies", cafe.state.zombies.size() == 3);
        check("fixture zombie types are 14/4/33",
                cafe.state.zombies.get(0).type == 14 && cafe.state.zombies.get(1).type == 4
                        && cafe.state.zombies.get(2).type == 33);
        check("fixture flags block is 270 bytes", cafe.state.flags.length == 270);
        check("state copy round-trips", Arrays.equals(fixture, cafe.withState(cafe.state.copy()).toBytes()));

        boolean rejected = false;
        try {
            FriendCafe.parse(Arrays.copyOf(fixture, 200));
        } catch (ZcFormatException e) {
            rejected = true;
        }
        check("truncated blob is rejected", rejected);

        byte[] wrongVersion = fixture.clone();
        wrongVersion[0] = 7;
        rejected = false;
        try {
            FriendCafe.parse(wrongVersion);
        } catch (ZcFormatException e) {
            rejected = true;
        }
        check("unsupported version is rejected", rejected);
    }

    private static void testCatalog(CharacterCatalog catalog) {
        if (catalog.size() == 0) {
            System.out.println("(no characterData.bin.mid given; catalog checks skipped)");
            return;
        }
        check("catalog has 219 types", catalog.size() == 219);
        CharacterCatalog.Info worker = catalog.get(33);
        check("type 33 is Construction Worker 140/3/9", worker != null && "Construction Worker".equals(worker.name)
                && worker.energy == 140 && worker.speed == 3 && worker.attack == 9);
        check("cashier (4) is infectable", catalog.get(4).isInfectable());
        check("chef (61) is not infectable", !catalog.get(61).isInfectable());
        check("enemy chef (54) is not infectable", !catalog.get(54).isInfectable());
        check("mafia goon (167) is an event character", !catalog.get(167).isBaseRoster());
        check("out-of-range type is null", catalog.get(500) == null && catalog.get(-1) == null);
    }

    private static class FakeBackend implements OfflineRouter.Backend {
        final List<String> rivalUids = new ArrayList<String>();
        int randomCalls;
        boolean saved;

        @Override
        public byte[] randomRival() {
            randomCalls++;
            return new byte[] {63, 1, 2};
        }

        @Override
        public byte[] rivalFor(String uid) {
            rivalUids.add(uid);
            return new byte[] {63, 9};
        }

        @Override
        public String metadataFor(String uid) {
            return "7:0.500000:63:0:0:0:0";
        }

        @Override
        public void onGameStateSaved() {
            saved = true;
        }

        @Override
        public long nowSeconds() {
            return 1790000000L;
        }
    }

    private static void testRouter() {
        FakeBackend b = new FakeBackend();
        String base = "http://127.0.0.1/v1/zca";

        OfflineRouter.Response r = OfflineRouter.route(base + "/gettimestamp.php", 7, b);
        check("timestamp is ok", r.ok);
        check("timestamp is NUL-terminated decimal", "1790000000".equals(text(r)) && r.body[r.body.length - 1] == 0);
        check("timestamp fits the native 5..15 byte window", r.body.length > 4 && r.body.length <= 15);
        check("IAP timestamp callbacks share the endpoint",
                OfflineRouter.route(base + "/gettimestamp.php", 18, b).ok);

        r = OfflineRouter.route(base + "/getrandomgamestate.php?v=63", 13, b);
        check("random cafe returns the backend blob", r.ok && r.body.length == 3 && b.randomCalls == 1);

        r = OfflineRouter.route(base + "/getgamestate.php?v=63&u=900000004", 10, b);
        check("friend cafe is looked up by u", r.ok && b.rivalUids.contains("900000004"));
        OfflineRouter.route(base + "/getsng.php?v=63&gv=1&u=900000005", 10, b);
        check("getsng.php is a friend cafe too", b.rivalUids.contains("900000005"));

        r = OfflineRouter.route(base + "/getmetadata.php?v=63&u0=900000001&u1=900000002", 12, b);
        check("metadata lists each requested id",
                "900000001:7:0.500000:63:0:0:0:0\n900000002:7:0.500000:63:0:0:0:0\n".equals(text(r)));
        check("metadata is NUL-terminated", r.body[r.body.length - 1] == 0);
        r = OfflineRouter.route(base + "/getmetadata.php?v=63", 12, b);
        check("metadata with no ids is just a NUL", r.ok && r.body.length == 1 && r.body[0] == 0);

        r = OfflineRouter.route(base + "/getgifts.php?v=63&udid=abc&l=0", 11, b);
        check("gift poll answers NO_DATA", r.ok && "NO_DATA".equals(text(r)));

        r = OfflineRouter.route(base + "/savegamestate.php?v=63&md_v=63&udid=x&data=1&h=abc", 2, b);
        check("save upload is accepted and archived", r.ok && b.saved);

        check("analytics uploads are acknowledged", OfflineRouter.route("http://127.0.0.1/v1/x/event", 0, b).ok);
        check("unknown endpoints fail like the old server did",
                !OfflineRouter.route("http://127.0.0.1/v1/x/hoover", 15, b).ok);
        check("random cafe without a blob fails",
                !OfflineRouter.route(base + "/getrandomgamestate.php", 13, new FakeBackend() {
                    @Override
                    public byte[] randomRival() {
                        return null;
                    }
                }).ok);

        check("endpoint parsing ignores host and query",
                "getgamestate.php".equals(OfflineRouter.endpoint("https://zc.airyz.xyz/v1/zca/GetGameState.php?u=1")));
        Map<String, String> q = OfflineRouter.query(base + "/x.php?a=1&b=two%20words&c=");
        check("query decoding", "1".equals(q.get("a")) && "two words".equals(q.get("b")) && "".equals(q.get("c")));
    }

    private static void testProfiles() {
        check("8 neighbors", RivalProfile.NEIGHBORS.length == 8);
        for (RivalProfile p : RivalProfile.NEIGHBORS) {
            long id = Long.parseLong(p.uid);
            check("neighbor id " + p.uid + " fits atoi", id > 0 && id < Integer.MAX_VALUE);
        }
        check("neighbor lookup by id", RivalProfile.forUid("900000007").tier == Tier.HARD);
        RivalProfile a = RivalProfile.forUid("12345");
        RivalProfile b = RivalProfile.forUid("12345");
        check("unknown ids get a stable profile", a.fullName().equals(b.fullName()) && a.tier == b.tier);
        check("rival level stays within 1..player level",
                RivalProfile.NEIGHBORS[2].rivalLevel(2) == 1 && RivalProfile.NEIGHBORS[7].rivalLevel(20) == 20);
    }

    private static void testGenerator(byte[] fixture, CharacterCatalog catalog, File outDir) throws Exception {
        FriendCafe player = FriendCafe.parse(fixture);
        FriendCafe layout = FriendCafe.parse(fixture);
        RivalGenerator gen = new RivalGenerator(catalog);
        int maxPlayerZombieLevel = 0;
        for (CharacterRecord z : player.state.zombies) {
            maxPlayerZombieLevel = Math.max(maxPlayerZombieLevel, z.level);
        }

        double[] ratioSum = new double[Tier.values().length];
        int written = 0;
        boolean allValid = true;
        for (Tier tier : Tier.values()) {
            RivalProfile profile = new RivalProfile("t-" + tier, "Test", tier.name(), tier, 0);
            for (int seed = 0; seed < 40; seed++) {
                RivalGenerator.Result res = gen.generate(player, layout, profile, seed, 1.0);
                FriendCafe back = FriendCafe.parse(res.blob);
                allValid &= Arrays.equals(back.layout, layout.layout);
                allValid &= back.state.zombies.size() >= 1 && back.state.zombies.size() <= RivalGenerator.MAX_DEFENDERS;
                allValid &= back.state.level >= 1 && back.state.level <= player.state.level;
                for (CharacterRecord z : back.state.zombies) {
                    allValid &= z.level >= 0 && z.level <= maxPlayerZombieLevel;
                    allValid &= z.energy > 0;
                    allValid &= z.u2 <= 3 && (z.u3 <= 1 || z.u3 == 255) && z.u5 <= 6;
                    allValid &= z.name.length > 2 && z.name[z.name.length - 2] == '\r' && z.name[z.name.length - 1] == 0;
                    CharacterCatalog.Info info = catalog.get(z.type);
                    allValid &= info == null || info.isInfectable();
                }
                allValid &= back.state.owner != null
                        && new String(back.state.owner.name, "ISO-8859-1").equals(profile.fullName() + "\r\0");
                ratioSum[tier.ordinal()] += res.rivalPower / res.playerPower;
                if (outDir != null && seed % 10 == 0) {
                    writeFile(new File(outDir, "rival-" + tier + "-" + seed + ".dat"), res.blob);
                    written++;
                }
            }
        }
        check("every generated rival is well formed and within bounds", allValid);

        double easy = ratioSum[Tier.EASY.ordinal()] / 40;
        double even = ratioSum[Tier.EVEN.ordinal()] / 40;
        double hard = ratioSum[Tier.HARD.ordinal()] / 40;
        System.out.println(String.format("mean rival/player power: easy %.2f, even %.2f, hard %.2f", easy, even, hard));
        check("tiers are ordered easy < even < hard", easy < even && even < hard);
        check("even rivals land near the player's strength", even > 0.75 && even < 1.35);

        RivalProfile neighbor = RivalProfile.NEIGHBORS[4];
        check("same seed gives the same cafe",
                Arrays.equals(gen.generate(player, layout, neighbor, 99, 1.0).blob,
                        gen.generate(player, layout, neighbor, 99, 1.0).blob));

        // A much stronger account must meet much stronger rivals.
        FriendCafe strong = FriendCafe.parse(fixture);
        List<CharacterRecord> extra = new ArrayList<CharacterRecord>();
        for (int i = 0; i < 3; i++) {
            for (CharacterRecord z : strong.state.zombies) {
                extra.add(z.copy());
            }
        }
        strong.state.zombies.addAll(extra);
        for (CharacterRecord z : strong.state.zombies) {
            z.level = 3;
        }
        strong.state.level = 20;
        double weakTotal = 0;
        double strongTotal = 0;
        int strongMaxDefenders = 0;
        for (int seed = 0; seed < 20; seed++) {
            weakTotal += gen.generate(player, layout, neighbor, seed, 1.0).rivalPower;
            RivalGenerator.Result sr = gen.generate(strong, layout, neighbor, seed, 1.0);
            strongTotal += sr.rivalPower;
            strongMaxDefenders = Math.max(strongMaxDefenders, sr.defenders);
            FriendCafe back = FriendCafe.parse(sr.blob);
            for (CharacterRecord z : back.state.zombies) {
                allValid &= z.level <= 3;
            }
            if (outDir != null && seed % 10 == 0) {
                writeFile(new File(outDir, "rival-strong-" + seed + ".dat"), sr.blob);
                written++;
            }
        }
        System.out.println(String.format("mean rival power: weak player %.1f, strong player %.1f", weakTotal / 20, strongTotal / 20));
        check("stronger account gets stronger rivals", strongTotal > weakTotal * 3);
        check("stronger account gets bigger rosters", strongMaxDefenders > 3);
        check("strong rivals keep levels within the player's range", allValid);

        check("difficulty knob scales rivals",
                gen.generate(player, layout, neighbor, 5, 2.0).rivalPower
                        > gen.generate(player, layout, neighbor, 5, 1.0).rivalPower);

        RivalGenerator.Result noSnapshot = gen.generate(null, layout, neighbor, 3, 1.0);
        check("works before the first save (no player snapshot)", FriendCafe.parse(noSnapshot.blob).state.zombies.size() >= 1);

        FriendCafe rookie = FriendCafe.parse(fixture);
        rookie.state.zombies.clear();
        RivalGenerator.Result rookieRival = gen.generate(rookie, layout, neighbor, 4, 1.0);
        check("a player with no zombies still meets at least one defender",
                FriendCafe.parse(rookieRival.blob).state.zombies.size() >= 1);

        if (outDir != null) {
            System.out.println("wrote " + written + " rival blobs to " + outDir);
        }
    }

    /** Temp-dir stand-in for the Android Context: files dir, external files dir, assets. */
    private static final class TempStorage implements OfflineStorage {
        final File files;
        final File external;
        final Map<String, byte[]> assets = new java.util.HashMap<String, byte[]>();

        TempStorage(File root) {
            files = new File(root, "files");
            external = new File(root, "external");
            files.mkdirs();
            external.mkdirs();
        }

        @Override
        public File filesDir() {
            return files;
        }

        @Override
        public File externalFilesDir() {
            return external;
        }

        @Override
        public InputStream openAsset(String name) throws IOException {
            byte[] data = assets.get(name);
            if (data == null) {
                throw new java.io.FileNotFoundException(name);
            }
            return new java.io.ByteArrayInputStream(data);
        }
    }

    private static void testServer(byte[] fixture, byte[] catalogBytes) throws Exception {
        File root = java.nio.file.Files.createTempDirectory("zc-offline").toFile();
        TempStorage storage = new TempStorage(root);
        storage.assets.put(RivalRepository.TEMPLATE_ASSET, fixture);
        if (catalogBytes != null) {
            storage.assets.put(RivalRepository.CHARACTER_ASSET, catalogBytes);
        }
        writeFile(new File(storage.files, RivalRepository.SERVER_DATA), fixture);
        // A corrupt import must be skipped, not break every request.
        new File(storage.external, "cafes").mkdirs();
        writeFile(new File(storage.external, "cafes/broken.dat"), new byte[] {63, 1, 2, 3});

        OfflineServer server = new OfflineServer(storage);
        String base = "http://127.0.0.1/v1/zca";

        OfflineServer.Reply r = server.respond(base + "/gettimestamp.php", 7);
        check("server: timestamp", r.ok && r.body.length == 11 && r.body[10] == 0);

        r = server.respond(base + "/getrandomgamestate.php?v=63", 13);
        FriendCafe random = r.ok ? FriendCafe.parse(r.body) : null;
        check("server: random cafe parses", random != null && random.state.zombies.size() >= 1);
        check("server: random cafe owner is renamed",
                random != null && !new String(random.state.owner.name, "ISO-8859-1").startsWith("You"));

        String hard = RivalProfile.NEIGHBORS[7].uid;
        OfflineServer.Reply first = server.respond(base + "/getgamestate.php?v=63&u=" + hard, 10);
        OfflineServer.Reply again = server.respond(base + "/getgamestate.php?v=63&u=" + hard, 10);
        check("server: neighbor cafe is stable across visits", first.ok && Arrays.equals(first.body, again.body));
        check("server: neighbor layout is pinned", new File(storage.files, "offline/neighbors/" + hard + ".dat").isFile());

        r = server.respond(base + "/getmetadata.php?v=63&u0=" + RivalProfile.NEIGHBORS[0].uid + "&u1=" + hard, 12);
        String[] lines = text(r).split("\n");
        FriendCafe hardCafe = FriendCafe.parse(first.body);
        check("server: metadata has a line per neighbor", lines.length == 2 && lines[1].startsWith(hard + ":"));
        check("server: metadata level matches the cafe served",
                lines.length == 2 && Integer.parseInt(lines[1].split(":")[1]) == hardCafe.state.level);

        File snapshots = new File(storage.files, "offline/snapshots");
        server.respond(base + "/savegamestate.php?v=63&h=x", 2);
        server.respond(base + "/savegamestate.php?v=63&h=x", 2);
        check("server: save archives one snapshot per distinct cafe", snapshots.list().length == 1);
        FriendCafe changed = FriendCafe.parse(fixture);
        for (int level = 5; level < 13; level++) {
            changed.state.level = level;
            writeFile(new File(storage.files, RivalRepository.SERVER_DATA), changed.toBytes());
            server.respond(base + "/savegamestate.php?v=63&h=x", 2);
            Thread.sleep(2); // snapshot names carry the save time in ms
        }
        check("server: snapshots are capped", snapshots.list().length == RivalRepository.MAX_SNAPSHOTS);

        r = server.respond(base + "/getrandomgamestate.php?v=63", 13);
        check("server: rivals follow the player's new level",
                r.ok && FriendCafe.parse(r.body).state.level <= 12 && FriendCafe.parse(r.body).state.level >= 9);

        writeFile(new File(storage.files, "offline.properties"), "rival.difficulty = 2.5\n".getBytes("ISO-8859-1"));
        check("server: rival.difficulty is read", new OfflineServer(storage).difficulty() == 2.5);

        new File(storage.files, RivalRepository.SERVER_DATA).delete();
        r = server.respond(base + "/getrandomgamestate.php?v=63", 13);
        check("server: works before the first save", r.ok && FriendCafe.parse(r.body).state.zombies.size() >= 1);

        check("server: unknown endpoints fail", !server.respond("http://127.0.0.1/v1/x/hoover", 15).ok);
    }

    // ------------------------------------------------------------------

    private static String text(OfflineServer.Reply r) {
        int n = r.body.length;
        if (n > 0 && r.body[n - 1] == 0) {
            n--;
        }
        return new String(r.body, 0, n);
    }

    private static String text(OfflineRouter.Response r) {
        int n = r.body.length;
        if (n > 0 && r.body[n - 1] == 0) {
            n--;
        }
        return new String(r.body, 0, n);
    }

    private static void check(String name, boolean ok) {
        if (ok) {
            passed++;
            System.out.println("PASS " + name);
        } else {
            failed++;
            System.out.println("FAIL " + name);
        }
    }

    private static byte[] readFile(File f) throws IOException {
        InputStream in = new FileInputStream(f);
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) {
                out.write(buf, 0, n);
            }
            return out.toByteArray();
        } finally {
            in.close();
        }
    }

    private static void writeFile(File f, byte[] data) throws IOException {
        FileOutputStream out = new FileOutputStream(f);
        try {
            out.write(data);
        } finally {
            out.close();
        }
    }
}
