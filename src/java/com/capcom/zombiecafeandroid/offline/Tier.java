package com.capcom.zombiecafeandroid.offline;

/**
 * How strong a rival cafe is relative to the player. The ratio range scales the
 * player's roster power into the rival's defender budget; the level offsets move
 * the rival's cafe level below the player's (never above, so the value always
 * stays within the level range the player's own save proves valid).
 */
enum Tier {
    EASY(0.60, 0.85, -3, -1),
    EVEN(0.90, 1.10, -1, 0),
    HARD(1.15, 1.40, 0, 0);

    final double minRatio;
    final double maxRatio;
    final int minLevelOffset;
    final int maxLevelOffset;

    Tier(double minRatio, double maxRatio, int minLevelOffset, int maxLevelOffset) {
        this.minRatio = minRatio;
        this.maxRatio = maxRatio;
        this.minLevelOffset = minLevelOffset;
        this.maxLevelOffset = maxLevelOffset;
    }

    /** Random-cafe mix: mostly fair fights, some easy pickings, the occasional brute. */
    static Tier roll(java.util.Random rnd) {
        int r = rnd.nextInt(100);
        if (r < 35) {
            return EASY;
        }
        if (r < 80) {
            return EVEN;
        }
        return HARD;
    }
}
