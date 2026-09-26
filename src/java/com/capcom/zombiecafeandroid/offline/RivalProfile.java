package com.capcom.zombiecafeandroid.offline;

import java.util.Random;

/**
 * Identity of a rival cafe owner: the offline stand-ins for Facebook friends
 * ("neighbors") and for the strangers behind "visit a random cafe".
 */
final class RivalProfile {
    private static final String[] FIRST_NAMES = {
        "Brains", "Mildred", "Gutsy", "Boris", "Ghoulia", "Rigor", "Bertha", "Sloppy",
        "Mortimer", "Grub", "Stitch", "Munch", "Gristle", "Vera", "Clyde", "Pickles",
        "Lurch", "Moldy", "Crumpet", "Igor", "Agatha", "Rotten", "Mabel", "Otis",
    };
    private static final String[] LAST_NAMES = {
        "McGee", "Marrow", "Gnawson", "Rotwell", "Graves", "Mortis", "Bunsworth", "Gravy",
        "Stew", "Fleshman", "Crumb", "Spleen", "Tibbs", "Kettle", "Sausage", "Noodle",
        "Gizzard", "Brisket", "Moss", "Hollow",
    };

    /** The offline friends list. Ids stay below 2^31 because CCFacebook::GetUserId uses atoi. */
    static final RivalProfile[] NEIGHBORS = {
        new RivalProfile("900000001", "Brains", "McGee", Tier.EASY, -2),
        new RivalProfile("900000002", "Mildred", "Marrow", Tier.EASY, -1),
        new RivalProfile("900000003", "Sloppy", "Gravy", Tier.EASY, -3),
        new RivalProfile("900000004", "Gutsy", "Gnawson", Tier.EVEN, -1),
        new RivalProfile("900000005", "Boris", "Rotwell", Tier.EVEN, 0),
        new RivalProfile("900000006", "Ghoulia", "Graves", Tier.EVEN, 0),
        new RivalProfile("900000007", "Rigor", "Mortis", Tier.HARD, 0),
        new RivalProfile("900000008", "Bertha", "Bunsworth", Tier.HARD, 0),
    };

    final String uid;
    final String firstName;
    final String lastName;
    final Tier tier;
    /** Added to the player's cafe level (then clamped to 1..playerLevel). */
    final int levelOffset;

    RivalProfile(String uid, String firstName, String lastName, Tier tier, int levelOffset) {
        this.uid = uid;
        this.firstName = firstName;
        this.lastName = lastName;
        this.tier = tier;
        this.levelOffset = levelOffset;
    }

    String fullName() {
        return firstName + " " + lastName;
    }

    int rivalLevel(int playerLevel) {
        int top = Math.max(1, playerLevel);
        return Math.max(1, Math.min(top, top + levelOffset));
    }

    /** A neighbor by id; unknown ids (e.g. real Facebook friends in an old save) get a stable made-up profile. */
    static RivalProfile forUid(String uid) {
        String key = uid == null ? "" : uid;
        for (RivalProfile p : NEIGHBORS) {
            if (p.uid.equals(key)) {
                return p;
            }
        }
        Random rnd = new Random(stableHash(key));
        return random(key, rnd);
    }

    /** A stranger for "visit a random cafe". */
    static RivalProfile random(String uid, Random rnd) {
        Tier tier = Tier.roll(rnd);
        int span = tier.maxLevelOffset - tier.minLevelOffset + 1;
        int offset = tier.minLevelOffset + rnd.nextInt(span);
        return new RivalProfile(uid,
                FIRST_NAMES[rnd.nextInt(FIRST_NAMES.length)],
                LAST_NAMES[rnd.nextInt(LAST_NAMES.length)],
                tier, offset);
    }

    /** 64-bit polynomial hash; deterministic across devices and runs, so a neighbor always rolls the same cafe. */
    static long stableHash(String s) {
        long h = 1125899906842597L;
        for (int i = 0; i < s.length(); i++) {
            h = 31 * h + s.charAt(i);
        }
        return h;
    }
}
