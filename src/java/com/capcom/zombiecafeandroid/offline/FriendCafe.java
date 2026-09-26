package com.capcom.zombiecafeandroid.offline;

/**
 * A ServerData.dat-format blob: version byte, {@link CafeState}, then the Cafe
 * layout. This is what GameStateCafe::saveServerData writes to disk and what
 * GameStateFriendCafe consumes when visiting (and attacking) another cafe.
 *
 * The layout is kept as opaque bytes: the generator only rewrites the state
 * block, so the layout never needs to be understood to stay valid.
 */
final class FriendCafe {
    static final int CURRENT_VERSION = 63;
    /** GameStateFriendCafe::deserializeGame rejects versions <= 0x28. */
    static final int MIN_VERSION = 41;
    /** The Cafe block always holds a header plus at least a few tiles. */
    private static final int MIN_LAYOUT_BYTES = 32;

    final int version;
    final CafeState state;
    final byte[] layout;

    FriendCafe(int version, CafeState state, byte[] layout) {
        this.version = version;
        this.state = state;
        this.layout = layout;
    }

    static FriendCafe parse(byte[] data) throws ZcFormatException {
        if (data == null || data.length == 0) {
            throw new ZcFormatException("empty cafe blob");
        }
        ZcInput in = new ZcInput(data);
        int version = in.u8();
        if (version < MIN_VERSION || version > CURRENT_VERSION) {
            throw new ZcFormatException("unsupported cafe version " + version);
        }
        CafeState state = CafeState.read(in, version);
        byte[] layout = in.rest();
        if (layout.length < MIN_LAYOUT_BYTES) {
            throw new ZcFormatException("cafe layout missing (" + layout.length + " bytes)");
        }
        return new FriendCafe(version, state, layout);
    }

    byte[] toBytes() {
        ZcOutput out = new ZcOutput();
        out.u8(version);
        state.write(out, version);
        out.bytes(layout);
        return out.toByteArray();
    }

    /** A copy whose state may be edited freely; the layout bytes are shared read-only. */
    FriendCafe withState(CafeState newState) {
        return new FriendCafe(version, newState, layout);
    }
}
