package com.capcom.zombiecafeandroid.offline;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Per-type stats read from assets/data/characterData.bin.mid (the layout of
 * tool/file_types/character.go). Only the fields the rival generator needs are
 * kept.
 */
final class CharacterCatalog {

    static final class Info {
        final int type;
        final String name;
        final int levelRequired;
        final int energy;
        final int speed;
        final int attack;
        final int u4;
        final int u14;
        final int u20;
        final int u21;

        Info(int type, String name, int levelRequired, int energy, int speed, int attack,
             int u4, int u14, int u20, int u21) {
            this.type = type;
            this.name = name;
            this.levelRequired = levelRequired;
            this.energy = energy;
            this.speed = speed;
            this.attack = attack;
            this.u4 = u4;
            this.u14 = u14;
            this.u20 = u20;
            this.u21 = u21;
        }

        /** Customers that can be turned into zombie workers (not chefs, not bosses). */
        boolean isInfectable() {
            return u4 == 255 && u14 == 0 && levelRequired != 255;
        }

        /** Part of the base roster rather than a timed event pack. */
        boolean isBaseRoster() {
            return u20 == 0 && u21 == 0;
        }

        /**
         * The two stat bytes GameStateFriendCafe::calculateDifficulty adds together
         * (CharacterData +0xab5/+0xab6).
         */
        int combatFactor() {
            return speed + attack;
        }
    }

    private final List<Info> infos;

    private CharacterCatalog(List<Info> infos) {
        this.infos = Collections.unmodifiableList(infos);
    }

    static CharacterCatalog empty() {
        return new CharacterCatalog(new ArrayList<Info>());
    }

    static CharacterCatalog parse(byte[] data) throws ZcFormatException {
        ZcInput in = new ZcInput(data);
        int count = in.u8();
        List<Info> infos = new ArrayList<Info>(count);
        for (int type = 0; type < count; type++) {
            int levelRequired = in.u8();
            in.u8(); // U2
            in.u8(); // U3
            String name = latin1(in.string());
            in.string(); // CharacterArtStringHead
            in.string(); // CharacterArtString
            int u4 = in.u8();
            int energy = in.u16();
            int speed = in.u8();
            int attack = in.u8();
            in.u8(); // TipRating
            in.u8(); // U8
            in.u8(); // U9
            in.u8(); // U10
            in.u8(); // IsFemale
            in.i32(); // Cost
            in.u8(); // PurchaseWithToxin
            int u14 = in.u8();
            in.f32(); // CookSpeedBonus
            in.i32(); // TipMultiplier
            in.f32(); // RegenBoost
            in.f32(); // CookXPBonus
            in.u8(); // U19
            int u20 = in.i16();
            int u21 = in.u8();
            in.string(); // HumanDescription
            in.string(); // ZombieDescription
            infos.add(new Info(type, name, levelRequired, energy, speed, attack, u4, u14, u20, u21));
        }
        return new CharacterCatalog(infos);
    }

    int size() {
        return infos.size();
    }

    /** Stats for {@code type}, or null when the catalog does not cover it. */
    Info get(int type) {
        return type >= 0 && type < infos.size() ? infos.get(type) : null;
    }

    List<Info> all() {
        return infos;
    }

    private static String latin1(byte[] raw) {
        char[] chars = new char[raw.length];
        for (int i = 0; i < raw.length; i++) {
            chars[i] = (char) (raw[i] & 0xff);
        }
        return new String(chars);
    }
}
