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
import java.util.Random;

/**
 * On-device inputs for the rival generator.
 *
 * <ul>
 * <li>The player: files/ServerData.dat, rewritten by GameStateCafe::save and
 *     ::uninit (so it is fresh every time the player leaves their cafe).</li>
 * <li>Cafe layouts a rival can occupy, weighted: cafes the player imported
 *     (ServerData.dat files from other players dropped into
 *     {@code <external files>/cafes/} or {@code files/offline/cafes/}), the
 *     bundled assets/offline/rival_template.dat, and snapshots of the player's
 *     own earlier cafe archived on every save upload.</li>
 * </ul>
 */
final class RivalRepository {
    static final String SERVER_DATA = "ServerData.dat";
    static final String TEMPLATE_ASSET = "offline/rival_template.dat";
    static final String CHARACTER_ASSET = "data/characterData.bin.mid";
    static final int MAX_SNAPSHOTS = 6;
    private static final int MAX_IMPORT_BYTES = 1 << 20;

    private final OfflineStorage storage;

    RivalRepository(OfflineStorage storage) {
        this.storage = storage;
    }

    /** The player's latest uploaded state, or null before the first cafe save. */
    FriendCafe loadPlayer() {
        return parseFile(new File(storage.filesDir(), SERVER_DATA));
    }

    CharacterCatalog loadCatalog() {
        try {
            CharacterCatalog catalog = CharacterCatalog.parse(readAsset(CHARACTER_ASSET));
            OfflineLog.d("character catalog: " + catalog.size() + " types");
            return catalog;
        } catch (Exception e) {
            OfflineLog.w("character catalog unavailable, using flat stats", e);
            return CharacterCatalog.empty();
        }
    }

    /** Picks the layout a rival will occupy; the same seed and inputs give the same cafe. */
    FriendCafe pickLayout(FriendCafe player, Random rnd) {
        List<FriendCafe> weighted = new ArrayList<FriendCafe>();
        for (FriendCafe c : imported()) {
            addWeighted(weighted, c, 3);
        }
        FriendCafe template = template();
        if (template != null) {
            addWeighted(weighted, template, 2);
        }
        for (FriendCafe c : snapshots()) {
            addWeighted(weighted, c, 1);
        }
        if (weighted.isEmpty() && player != null) {
            weighted.add(player);
        }
        if (weighted.isEmpty()) {
            return null;
        }
        return weighted.get(rnd.nextInt(weighted.size()));
    }

    /**
     * A neighbor keeps the layout it was first given (files/offline/neighbors/), so their
     * cafe looks the same on every visit even as snapshots and imports come and go.
     */
    FriendCafe neighborLayout(String uid, FriendCafe player, Random rnd) {
        File pinned = new File(storage.filesDir(), "offline/neighbors/" + fileSafe(uid) + ".dat");
        FriendCafe layout = parseFile(pinned);
        if (layout != null) {
            return layout;
        }
        layout = pickLayout(player, rnd);
        File dir = pinned.getParentFile();
        if (layout != null && (dir.isDirectory() || dir.mkdirs())) {
            writeFile(pinned, layout.toBytes());
        }
        return layout;
    }

    /** Keeps a copy of the cafe the game just saved; old cafes become rival layouts. */
    void archiveSnapshot() {
        File src = new File(storage.filesDir(), SERVER_DATA);
        byte[] data = readFile(src);
        if (data == null) {
            return;
        }
        try {
            FriendCafe.parse(data);
        } catch (ZcFormatException e) {
            OfflineLog.w("not archiving unparseable " + SERVER_DATA, e);
            return;
        }
        File dir = new File(storage.filesDir(), "offline/snapshots");
        if (!dir.isDirectory() && !dir.mkdirs()) {
            return;
        }
        File[] existing = sortedDatFiles(dir);
        if (existing.length > 0 && Arrays.equals(readFile(existing[existing.length - 1]), data)) {
            return;
        }
        writeFile(new File(dir, "snap-" + System.currentTimeMillis() + ".dat"), data);
        File[] all = sortedDatFiles(dir);
        for (int i = 0; i < all.length - MAX_SNAPSHOTS; i++) {
            if (!all[i].delete()) {
                OfflineLog.w("could not prune " + all[i], null);
            }
        }
    }

    private List<FriendCafe> imported() {
        List<FriendCafe> out = new ArrayList<FriendCafe>();
        List<File> dirs = new ArrayList<File>();
        dirs.add(new File(storage.filesDir(), "offline/cafes"));
        File external = storage.externalFilesDir();
        if (external != null) {
            dirs.add(new File(external, "cafes"));
        }
        for (File dir : dirs) {
            for (File f : sortedDatFiles(dir)) {
                if (f.length() > MAX_IMPORT_BYTES) {
                    continue;
                }
                FriendCafe cafe = parseFile(f);
                if (cafe != null) {
                    out.add(cafe);
                }
            }
        }
        return out;
    }

    private List<FriendCafe> snapshots() {
        List<FriendCafe> out = new ArrayList<FriendCafe>();
        for (File f : sortedDatFiles(new File(storage.filesDir(), "offline/snapshots"))) {
            FriendCafe cafe = parseFile(f);
            if (cafe != null) {
                out.add(cafe);
            }
        }
        return out;
    }

    private FriendCafe template() {
        try {
            return FriendCafe.parse(readAsset(TEMPLATE_ASSET));
        } catch (Exception e) {
            OfflineLog.w("bundled rival template unavailable", e);
            return null;
        }
    }

    private static String fileSafe(String s) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length() && i < 64; i++) {
            char c = s.charAt(i);
            boolean ok = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_';
            sb.append(ok ? c : '_');
        }
        return sb.length() == 0 ? "_" : sb.toString();
    }

    private static void addWeighted(List<FriendCafe> list, FriendCafe cafe, int weight) {
        for (int i = 0; i < weight; i++) {
            list.add(cafe);
        }
    }

    private static File[] sortedDatFiles(File dir) {
        File[] files = dir.listFiles();
        if (files == null) {
            return new File[0];
        }
        List<File> dats = new ArrayList<File>();
        for (File f : files) {
            if (f.isFile() && f.getName().toLowerCase(java.util.Locale.US).endsWith(".dat")) {
                dats.add(f);
            }
        }
        File[] out = dats.toArray(new File[dats.size()]);
        Arrays.sort(out);
        return out;
    }

    private static FriendCafe parseFile(File f) {
        byte[] data = readFile(f);
        if (data == null) {
            return null;
        }
        try {
            return FriendCafe.parse(data);
        } catch (ZcFormatException e) {
            OfflineLog.w("skipping " + f + ": " + e.getMessage(), null);
            return null;
        }
    }

    private byte[] readAsset(String name) throws IOException {
        InputStream in = storage.openAsset(name);
        try {
            return readAll(in);
        } finally {
            in.close();
        }
    }

    private static byte[] readFile(File f) {
        if (!f.isFile()) {
            return null;
        }
        try {
            InputStream in = new FileInputStream(f);
            try {
                return readAll(in);
            } finally {
                in.close();
            }
        } catch (IOException e) {
            OfflineLog.w("could not read " + f, e);
            return null;
        }
    }

    private static void writeFile(File f, byte[] data) {
        try {
            FileOutputStream out = new FileOutputStream(f);
            try {
                out.write(data);
            } finally {
                out.close();
            }
        } catch (IOException e) {
            OfflineLog.w("could not write " + f, e);
        }
    }

    private static byte[] readAll(InputStream in) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) > 0) {
            out.write(buf, 0, n);
        }
        return out.toByteArray();
    }
}
