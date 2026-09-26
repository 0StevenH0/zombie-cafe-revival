package com.capcom.zombiecafeandroid.offline;

/**
 * Cursor over the legacy save formats. Integers are big-endian and floats are
 * little-endian, mirroring tool/file_types/binary_reader.go.
 */
final class ZcInput {
    private final byte[] buf;
    private int pos;

    ZcInput(byte[] buf) {
        this.buf = buf;
    }

    int remaining() {
        return buf.length - pos;
    }

    private void need(int n) throws ZcFormatException {
        if (n < 0 || n > remaining()) {
            throw new ZcFormatException("wanted " + n + " bytes at offset " + pos + ", have " + remaining());
        }
    }

    int u8() throws ZcFormatException {
        need(1);
        return buf[pos++] & 0xff;
    }

    boolean bool() throws ZcFormatException {
        int v = u8();
        if (v > 1) {
            throw new ZcFormatException("bool byte was " + v + " at offset " + (pos - 1));
        }
        return v == 1;
    }

    int u16() throws ZcFormatException {
        need(2);
        int v = ((buf[pos] & 0xff) << 8) | (buf[pos + 1] & 0xff);
        pos += 2;
        return v;
    }

    int i16() throws ZcFormatException {
        return (short) u16();
    }

    int i32() throws ZcFormatException {
        need(4);
        int v = ((buf[pos] & 0xff) << 24) | ((buf[pos + 1] & 0xff) << 16)
                | ((buf[pos + 2] & 0xff) << 8) | (buf[pos + 3] & 0xff);
        pos += 4;
        return v;
    }

    long i64() throws ZcFormatException {
        long hi = i32() & 0xffffffffL;
        long lo = i32() & 0xffffffffL;
        return (hi << 32) | lo;
    }

    float f32() throws ZcFormatException {
        need(4);
        int bits = (buf[pos] & 0xff) | ((buf[pos + 1] & 0xff) << 8)
                | ((buf[pos + 2] & 0xff) << 16) | ((buf[pos + 3] & 0xff) << 24);
        pos += 4;
        return Float.intBitsToFloat(bits);
    }

    double f64() throws ZcFormatException {
        need(8);
        long bits = 0;
        for (int i = 7; i >= 0; i--) {
            bits = (bits << 8) | (buf[pos + i] & 0xffL);
        }
        pos += 8;
        return Double.longBitsToDouble(bits);
    }

    byte[] bytes(int n) throws ZcFormatException {
        need(n);
        byte[] out = new byte[n];
        System.arraycopy(buf, pos, out, 0, n);
        pos += n;
        return out;
    }

    /** Length-prefixed (int16) byte string; the raw bytes are kept, including any trailing "\r\0". */
    byte[] string() throws ZcFormatException {
        int len = i16();
        if (len < 0) {
            throw new ZcFormatException("negative string length " + len + " at offset " + (pos - 2));
        }
        return bytes(len);
    }

    byte[] rest() throws ZcFormatException {
        return bytes(remaining());
    }
}
