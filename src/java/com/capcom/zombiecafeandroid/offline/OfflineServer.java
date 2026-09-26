package com.capcom.zombiecafeandroid.offline;

import android.content.Context;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import java.util.Properties;
import java.util.Random;

/**
 * In-process replacement for the Zombie Cafe backend. URLManager hands every
 * request here (via OfflineBridge) instead of opening a socket.
 *
 * Optional tuning lives in {@code <external files>/offline.properties} or
 * {@code files/offline.properties}:
 * <pre>
 *   rival.difficulty=1.0   # multiplies every rival's strength target
 * </pre>
 */
public final class OfflineServer implements OfflineRouter.Backend {

    /** What URLManager should report back to the native request. */
    public static final class Reply {
        public final boolean ok;
        public final byte[] body;

        Reply(boolean ok, byte[] body) {
            this.ok = ok;
            this.body = body == null ? new byte[0] : body;
        }
    }

    private static OfflineServer instance;

    private final RivalRepository repository;
    private final double difficulty;
    private final Random randomSeeds = new Random();
    private RivalGenerator generator;

    OfflineServer(OfflineStorage storage) {
        this.repository = new RivalRepository(storage);
        this.difficulty = readDifficulty(storage);
    }

    public static synchronized OfflineServer get(Context context) {
        if (instance == null) {
            Context app = context.getApplicationContext() != null ? context.getApplicationContext() : context;
            instance = new OfflineServer(new OfflineStorage.ForContext(app));
        }
        return instance;
    }

    public Reply respond(String url, int callbackType) {
        try {
            OfflineRouter.Response r = OfflineRouter.route(url, callbackType, this);
            OfflineLog.d("cb=" + callbackType + " " + OfflineRouter.endpoint(url)
                    + (r.ok ? " -> " + r.body.length + " bytes" : " -> fail"));
            return new Reply(r.ok, r.body);
        } catch (Throwable t) {
            OfflineLog.w("request failed: " + url, t);
            return new Reply(false, null);
        }
    }

    double difficulty() {
        return difficulty;
    }

    // --- OfflineRouter.Backend ---------------------------------------------

    @Override
    public synchronized byte[] randomRival() {
        long seed = randomSeeds.nextLong() ^ System.nanoTime();
        RivalProfile stranger = RivalProfile.random("random", new Random(mix(seed, 1)));
        FriendCafe player = repository.loadPlayer();
        return rival(stranger, seed, player, repository.pickLayout(player, new Random(mix(seed, 2))));
    }

    @Override
    public synchronized byte[] rivalFor(String uid) {
        RivalProfile profile = RivalProfile.forUid(uid);
        FriendCafe player = repository.loadPlayer();
        int playerLevel = player != null ? player.state.level : 1;
        // Stable within a player level, so a neighbor's roster only reshuffles when you level up.
        long seed = RivalProfile.stableHash(profile.uid) * 31 + playerLevel;
        FriendCafe layout = repository.neighborLayout(profile.uid, player, new Random(mix(seed, 2)));
        return rival(profile, seed, player, layout);
    }

    @Override
    public synchronized String metadataFor(String uid) {
        RivalProfile profile = RivalProfile.forUid(uid);
        FriendCafe player = repository.loadPlayer();
        int level = profile.rivalLevel(player != null ? player.state.level : 1);
        double rating = 0.2 + 0.7 * new Random(RivalProfile.stableHash(profile.uid)).nextDouble();
        // Same shape ZombieCafe::saveGameState writes: "%i:%f:%i:%i:0:0:%i".
        return String.format(Locale.US, "%d:%f:%d:0:0:0:0", level, rating, FriendCafe.CURRENT_VERSION);
    }

    @Override
    public synchronized void onGameStateSaved() {
        repository.archiveSnapshot();
    }

    @Override
    public long nowSeconds() {
        return System.currentTimeMillis() / 1000L;
    }

    // -----------------------------------------------------------------------

    private byte[] rival(RivalProfile profile, long seed, FriendCafe player, FriendCafe layout) {
        if (layout == null) {
            OfflineLog.w("no cafe layout available for a rival", null);
            return null;
        }
        RivalGenerator.Result result = generator().generate(player, layout, profile, mix(seed, 3), difficulty);
        OfflineLog.d("rival " + result);
        return result.blob;
    }

    /** Derives independent streams (profile, layout, roster) from one seed. */
    private static long mix(long seed, int stream) {
        long z = seed + stream * 0x9E3779B97F4A7C15L;
        z = (z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9L;
        z = (z ^ (z >>> 27)) * 0x94D049BB133111EBL;
        return z ^ (z >>> 31);
    }

    private RivalGenerator generator() {
        if (generator == null) {
            generator = new RivalGenerator(repository.loadCatalog());
        }
        return generator;
    }

    private static double readDifficulty(OfflineStorage storage) {
        File external = storage.externalFilesDir();
        File[] candidates = {
            external != null ? new File(external, "offline.properties") : null,
            new File(storage.filesDir(), "offline.properties"),
        };
        for (File f : candidates) {
            if (f == null || !f.isFile()) {
                continue;
            }
            Properties props = new Properties();
            try {
                InputStream in = new FileInputStream(f);
                try {
                    props.load(in);
                } finally {
                    in.close();
                }
                double d = Double.parseDouble(props.getProperty("rival.difficulty", "1.0").trim());
                OfflineLog.d("rival.difficulty=" + d + " from " + f);
                return d;
            } catch (IOException e) {
                OfflineLog.w("could not read " + f, e);
            } catch (NumberFormatException e) {
                OfflineLog.w("bad rival.difficulty in " + f, e);
            }
        }
        return 1.0;
    }
}
