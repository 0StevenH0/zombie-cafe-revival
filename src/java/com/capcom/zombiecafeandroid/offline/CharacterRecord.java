package com.capcom.zombiecafeandroid.offline;

/**
 * One serialized character (cafe owner or zombie), laid out exactly as
 * Character::serialize writes it and tool/file_types/save_game.go reads it.
 *
 * Field meanings recovered from Character::deserialize in libZombieCafeAndroid.so:
 * {@code type} indexes characterData.bin.mid, {@code energy} is the current
 * energy (clamped on load to baseEnergy * zombieLevelEnergyMultiplier[level]),
 * and {@code level} is the zombie level used to index that multiplier table.
 * Everything else is carried through untouched.
 */
final class CharacterRecord {
    int type;
    byte[] name = new byte[0];
    int u2;
    int u3;
    float energy;
    int u5;
    long u6;
    int u7;
    long u8;
    long u9;
    int u10;
    int u11;
    int u12;
    int u13;
    int u14;   // present when version > 29
    int level; // U15, present when version > 46
    int u16;   // present when version > 46

    static CharacterRecord read(ZcInput in, int version) throws ZcFormatException {
        CharacterRecord c = new CharacterRecord();
        c.type = in.u8();
        c.name = in.string();
        c.u2 = in.u8();
        c.u3 = in.u8();
        c.energy = in.f32();
        c.u5 = in.u8();
        c.u6 = in.i64();
        c.u7 = in.u8();
        c.u8 = in.i64();
        c.u9 = in.i64();
        c.u10 = in.i32();
        c.u11 = in.i32();
        c.u12 = in.i32();
        c.u13 = in.i32();
        if (version > 29) {
            c.u14 = in.u8();
            if (version > 46) {
                c.level = in.i32();
                c.u16 = in.i32();
            }
        }
        return c;
    }

    void write(ZcOutput out, int version) {
        out.u8(type);
        out.string(name);
        out.u8(u2);
        out.u8(u3);
        out.f32(energy);
        out.u8(u5);
        out.i64(u6);
        out.u8(u7);
        out.i64(u8);
        out.i64(u9);
        out.i32(u10);
        out.i32(u11);
        out.i32(u12);
        out.i32(u13);
        if (version > 29) {
            out.u8(u14);
            if (version > 46) {
                out.i32(level);
                out.i32(u16);
            }
        }
    }

    CharacterRecord copy() {
        CharacterRecord c = new CharacterRecord();
        c.type = type;
        c.name = name.clone();
        c.u2 = u2;
        c.u3 = u3;
        c.energy = energy;
        c.u5 = u5;
        c.u6 = u6;
        c.u7 = u7;
        c.u8 = u8;
        c.u9 = u9;
        c.u10 = u10;
        c.u11 = u11;
        c.u12 = u12;
        c.u13 = u13;
        c.u14 = u14;
        c.level = level;
        c.u16 = u16;
        return c;
    }
}
