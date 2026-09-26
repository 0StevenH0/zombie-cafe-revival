package com.capcom.zombiecafeandroid.offline;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Builds rival cafes locally, sized against the player's own strength.
 *
 * Strength uses the numbers the game itself fights with:
 * GameStateFriendCafe::calculateDifficulty weighs each defender by
 * currentEnergy / maxEnergy * (speed + attack) from characterData, and max
 * energy is baseEnergy * zombieLevelEnergyMultiplier[level]. That multiplier
 * table lives in constants.bin, so {@link #levelFactor} approximates it; the
 * approximation only ever compares rosters against each other.
 *
 * Safety rails, all derived from the player's own save so nothing out of range
 * reaches the engine:
 * <ul>
 * <li>defender levels never exceed the highest level in the player's roster;</li>
 * <li>the rival cafe level never exceeds the player's cafe level;</li>
 * <li>defenders are copies of real serialized zombies with only type, name,
 *     level and energy changed (Character::isValid ranges hold for the rest);</li>
 * <li>"full" energy is written as a large value that Character::deserialize
 *     clamps to the true maximum.</li>
 * </ul>
 */
final class RivalGenerator {
    /** Clamped on load to baseEnergy * multiplier[level]; see Character::deserialize. */
    static final float FULL_ENERGY = 1.0e6f;
    static final int MAX_DEFENDERS = 12;

    private static final double DEFAULT_COMBAT = 8.0;
    private static final double DEFAULT_ENERGY = 100.0;
    /** A brand-new cafe still gets one defender to fight. */
    private static final double MIN_TARGET = 1.0;

    private static final String[] DEFENDER_NAMES = {
        "Abigail", "Alfonso", "Barney", "Bianca", "Carlos", "Cecilia", "Dmitri", "Dolores",
        "Edgar", "Eloise", "Felix", "Fiona", "Gordon", "Greta", "Hector", "Hilda",
        "Ignatius", "Imogen", "Jasper", "Juniper", "Klaus", "Lorna", "Marvin", "Nadia",
        "Oscar", "Ophelia", "Percy", "Priya", "Quentin", "Rosalind", "Sergio", "Tabitha",
        "Ulric", "Valerie", "Wendell", "Xenia", "Yusuf", "Zelda",
    };

    static final class Result {
        final byte[] blob;
        final String ownerName;
        final Tier tier;
        final int level;
        final int defenders;
        final double playerPower;
        final double rivalPower;

        Result(byte[] blob, String ownerName, Tier tier, int level, int defenders,
               double playerPower, double rivalPower) {
            this.blob = blob;
            this.ownerName = ownerName;
            this.tier = tier;
            this.level = level;
            this.defenders = defenders;
            this.playerPower = playerPower;
            this.rivalPower = rivalPower;
        }

        @Override
        public String toString() {
            return ownerName + " tier=" + tier + " level=" + level + " defenders=" + defenders
                    + " power=" + Math.round(rivalPower) + " vs player " + Math.round(playerPower);
        }
    }

    private static final class Candidate {
        final int type;
        final CharacterRecord template;
        final double weight;

        Candidate(int type, CharacterRecord template, double weight) {
            this.type = type;
            this.template = template;
            this.weight = weight;
        }
    }

    private final CharacterCatalog catalog;

    RivalGenerator(CharacterCatalog catalog) {
        this.catalog = catalog == null ? CharacterCatalog.empty() : catalog;
    }

    /**
     * @param player     the player's current ServerData.dat, or null before the first save
     * @param layout     the cafe whose floor plan (and owner chef) the rival reuses
     * @param profile    who owns the rival cafe and how tough they are
     * @param seed       makes the roster reproducible for a given profile and player
     * @param difficulty global multiplier on the tier's strength ratio (1.0 = as designed)
     */
    Result generate(FriendCafe player, FriendCafe layout, RivalProfile profile, long seed, double difficulty) {
        Random rnd = new Random(seed);

        List<CharacterRecord> reference = player != null && !player.state.zombies.isEmpty()
                ? player.state.zombies : layout.state.zombies;
        int playerLevel = Math.max(1, player != null ? player.state.level : layout.state.level);
        int maxZombieLevel = 0;
        for (CharacterRecord z : reference) {
            maxZombieLevel = Math.max(maxZombieLevel, Math.max(0, z.level));
        }

        double playerPower = 0;
        for (CharacterRecord z : reference) {
            playerPower += power(z.type, z.level, 1.0);
        }

        Tier tier = profile.tier;
        double ratio = tier.minRatio + rnd.nextDouble() * (tier.maxRatio - tier.minRatio);
        ratio *= clamp(difficulty, 0.25, 4.0);
        double target = Math.max(playerPower * ratio, MIN_TARGET);
        int rivalLevel = profile.rivalLevel(playerLevel);

        byte[] nameSuffix = nameSuffix(reference, layout.state);
        List<Candidate> pool = candidates(reference, layout.state.zombies, rivalLevel);
        int maxCount = (int) clamp(reference.size() + 2, 2, MAX_DEFENDERS);

        List<CharacterRecord> defenders = new ArrayList<CharacterRecord>();
        double rivalPower = 0;
        while (!pool.isEmpty() && defenders.size() < maxCount && rivalPower < target) {
            Candidate c = pick(pool, target - rivalPower, rnd);
            CharacterRecord z = c.template.copy();
            z.type = c.type;
            z.level = pickLevel(c, maxZombieLevel, tier, rnd);
            z.energy = FULL_ENERGY;
            z.name = concat(ascii(DEFENDER_NAMES[rnd.nextInt(DEFENDER_NAMES.length)]), nameSuffix);
            defenders.add(z);
            rivalPower += power(z.type, z.level, 1.0);
        }

        // Tire out the last defender rather than overshoot the budget by a whole zombie.
        if (defenders.size() > 1 && rivalPower > target * 1.1) {
            CharacterRecord last = defenders.get(defenders.size() - 1);
            double lastPower = power(last.type, last.level, 1.0);
            double keep = clamp(1.0 - (rivalPower - target) / lastPower, 0.35, 1.0);
            last.energy = (float) (maxEnergy(last.type, last.level) * keep);
            rivalPower -= lastPower * (1.0 - keep);
        }

        CafeState state = layout.state.copy();
        state.level = rivalLevel;
        state.rating = (float) clamp(state.rating + (ratio - 1.0) * 0.3 + (rnd.nextDouble() - 0.5) * 0.2, 0.05, 0.95);
        state.zombies.clear();
        state.zombies.addAll(defenders);
        if (state.owner != null) {
            state.owner.name = concat(ascii(profile.fullName()), nameSuffix);
        }

        byte[] blob = layout.withState(state).toBytes();
        return new Result(blob, profile.fullName(), tier, rivalLevel, defenders.size(), playerPower, rivalPower);
    }

    /** Relative fighting strength of one zombie at the given fraction of its energy. */
    double power(int type, int level, double energyFraction) {
        CharacterCatalog.Info info = catalog.get(type);
        double combat = info != null ? info.combatFactor() : DEFAULT_COMBAT;
        return combat * maxEnergy(type, level) * energyFraction / 100.0;
    }

    private double maxEnergy(int type, int level) {
        CharacterCatalog.Info info = catalog.get(type);
        double base = info != null && info.energy > 0 ? info.energy : DEFAULT_ENERGY;
        return base * levelFactor(level);
    }

    /** Stand-in for Character::zombieLevelEnergyMultiplier (loaded from constants.bin at runtime). */
    static double levelFactor(int level) {
        return 1.0 + 0.25 * Math.max(0, level);
    }

    private List<Candidate> candidates(List<CharacterRecord> reference, List<CharacterRecord> layoutRoster, int rivalLevel) {
        List<Candidate> pool = new ArrayList<Candidate>();
        // The player's own zombie types: always loadable and at their power level.
        for (CharacterRecord z : reference) {
            addUnique(pool, new Candidate(z.type, z, 3.0));
        }
        CharacterRecord template = !reference.isEmpty() ? reference.get(0)
                : (!layoutRoster.isEmpty() ? layoutRoster.get(0) : null);
        if (template == null) {
            return pool;
        }
        // Whatever the layout's original owner had working there.
        for (CharacterRecord z : layoutRoster) {
            CharacterCatalog.Info info = catalog.get(z.type);
            if (info == null || (info.isInfectable() && info.levelRequired <= rivalLevel)) {
                addUnique(pool, new Candidate(z.type, z, 2.0));
            }
        }
        // Other base-game customers a cafe of this level could have zombified.
        for (CharacterCatalog.Info info : catalog.all()) {
            if (info.isInfectable() && info.isBaseRoster() && info.levelRequired <= rivalLevel) {
                addUnique(pool, new Candidate(info.type, template, 1.0));
            }
        }
        return pool;
    }

    private static void addUnique(List<Candidate> pool, Candidate c) {
        for (Candidate existing : pool) {
            if (existing.type == c.type) {
                return;
            }
        }
        pool.add(c);
    }

    /** Weighted pick among candidates that fit the remaining budget; the weakest one if none fit. */
    private Candidate pick(List<Candidate> pool, double budget, Random rnd) {
        List<Candidate> fitting = new ArrayList<Candidate>();
        double total = 0;
        Candidate weakest = null;
        double weakestPower = Double.MAX_VALUE;
        for (Candidate c : pool) {
            double p = power(c.type, 0, 1.0);
            if (p < weakestPower) {
                weakestPower = p;
                weakest = c;
            }
            if (p <= budget * 1.25) {
                fitting.add(c);
                total += c.weight;
            }
        }
        if (fitting.isEmpty()) {
            return weakest;
        }
        double roll = rnd.nextDouble() * total;
        for (Candidate c : fitting) {
            roll -= c.weight;
            if (roll <= 0) {
                return c;
            }
        }
        return fitting.get(fitting.size() - 1);
    }

    private static int pickLevel(Candidate c, int maxZombieLevel, Tier tier, Random rnd) {
        int base = c.template.type == c.type ? Math.max(0, c.template.level) : rnd.nextInt(maxZombieLevel + 1);
        int level;
        if (tier == Tier.EASY) {
            level = base - rnd.nextInt(2);
        } else if (tier == Tier.HARD) {
            level = base + rnd.nextInt(2);
        } else {
            level = base;
        }
        return (int) clamp(level, 0, maxZombieLevel);
    }

    /** Names written by the game end in "\r\0"; mirror whatever convention the source save uses. */
    private static byte[] nameSuffix(List<CharacterRecord> reference, CafeState layout) {
        byte[] sample = null;
        if (!reference.isEmpty()) {
            sample = reference.get(0).name;
        } else if (layout.owner != null) {
            sample = layout.owner.name;
        } else if (!layout.zombies.isEmpty()) {
            sample = layout.zombies.get(0).name;
        }
        if (sample == null) {
            return new byte[0];
        }
        int n = sample.length;
        if (n >= 2 && sample[n - 2] == '\r' && sample[n - 1] == 0) {
            return new byte[] {'\r', 0};
        }
        if (n >= 1 && sample[n - 1] == 0) {
            return new byte[] {0};
        }
        return new byte[0];
    }

    static byte[] ascii(String s) {
        byte[] out = new byte[s.length()];
        for (int i = 0; i < out.length; i++) {
            char ch = s.charAt(i);
            out[i] = (byte) (ch < 0x80 ? ch : '?');
        }
        return out;
    }

    private static byte[] concat(byte[] a, byte[] b) {
        byte[] out = new byte[a.length + b.length];
        System.arraycopy(a, 0, out, 0, a.length);
        System.arraycopy(b, 0, out, a.length, b.length);
        return out;
    }

    private static double clamp(double v, double lo, double hi) {
        return v < lo ? lo : (v > hi ? hi : v);
    }
}
