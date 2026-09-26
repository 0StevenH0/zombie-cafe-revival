package com.capcom.zombiecafeandroid.offline;

import java.util.ArrayList;
import java.util.List;

/**
 * The CafeState block shared by globalData.dat and ServerData.dat, as written by
 * ZombieCafe::serializeServerData. Field names follow what
 * GameStateFriendCafe::deserializeGame does with each value; the Go structs in
 * tool/file_types/save_game.go call {@code rating} "ExperiencePoints" and
 * {@code ratingBonus} "U8".
 */
final class CafeState {
    double u1;
    float rating;       // GameStateFriendCafe +0x20, summed into getModifiedRating()
    int toxin;
    int money;
    int level;          // cafe level
    int u6;
    int u7;
    float ratingBonus;  // GameStateFriendCafe +0x200, the other getModifiedRating() term
    int u9;
    CharacterRecord owner; // the chef; null when the has-owner flag is false
    final List<CharacterRecord> zombies = new ArrayList<CharacterRecord>();
    byte[] flags = new byte[0];
    boolean u13;

    static CafeState read(ZcInput in, int version) throws ZcFormatException {
        CafeState s = new CafeState();
        s.u1 = in.f64();
        s.rating = in.f32();
        s.toxin = in.i32();
        s.money = in.i32();
        s.level = in.i32();
        s.u6 = in.i32();
        s.u7 = in.i32();
        s.ratingBonus = in.f32();
        s.u9 = in.i32();
        if (in.bool()) {
            s.owner = CharacterRecord.read(in, version);
        }
        int numZombies = in.u8();
        for (int i = 0; i < numZombies; i++) {
            s.zombies.add(CharacterRecord.read(in, version));
        }
        int numFlags = version > 62 ? in.i32() : in.u8();
        if (numFlags < 0 || numFlags > in.remaining()) {
            throw new ZcFormatException("bad flag count " + numFlags);
        }
        s.flags = in.bytes(numFlags);
        if (version > 33) {
            s.u13 = in.bool();
        }
        return s;
    }

    void write(ZcOutput out, int version) {
        out.f64(u1);
        out.f32(rating);
        out.i32(toxin);
        out.i32(money);
        out.i32(level);
        out.i32(u6);
        out.i32(u7);
        out.f32(ratingBonus);
        out.i32(u9);
        out.bool(owner != null);
        if (owner != null) {
            owner.write(out, version);
        }
        out.u8(zombies.size());
        for (CharacterRecord z : zombies) {
            z.write(out, version);
        }
        if (version > 62) {
            out.i32(flags.length);
        } else {
            out.u8(flags.length);
        }
        out.bytes(flags);
        if (version > 33) {
            out.bool(u13);
        }
    }

    CafeState copy() {
        CafeState s = new CafeState();
        s.u1 = u1;
        s.rating = rating;
        s.toxin = toxin;
        s.money = money;
        s.level = level;
        s.u6 = u6;
        s.u7 = u7;
        s.ratingBonus = ratingBonus;
        s.u9 = u9;
        s.owner = owner == null ? null : owner.copy();
        for (CharacterRecord z : zombies) {
            s.zombies.add(z.copy());
        }
        s.flags = flags.clone();
        s.u13 = u13;
        return s;
    }
}
