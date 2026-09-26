package com.capcom.zombiecafeandroid.offline;

import java.io.ByteArrayOutputStream;

/** Writer counterpart of {@link ZcInput} (big-endian ints, little-endian floats). */
final class ZcOutput {
    private final ByteArrayOutputStream out = new ByteArrayOutputStream(4096);

    void u8(int v) {
        out.write(v & 0xff);
    }

    void bool(boolean v) {
        out.write(v ? 1 : 0);
    }

    void i16(int v) {
        out.write((v >>> 8) & 0xff);
        out.write(v & 0xff);
    }

    void i32(int v) {
        out.write((v >>> 24) & 0xff);
        out.write((v >>> 16) & 0xff);
        out.write((v >>> 8) & 0xff);
        out.write(v & 0xff);
    }

    void i64(long v) {
        i32((int) (v >>> 32));
        i32((int) v);
    }

    void f32(float v) {
        int bits = Float.floatToRawIntBits(v);
        out.write(bits & 0xff);
        out.write((bits >>> 8) & 0xff);
        out.write((bits >>> 16) & 0xff);
        out.write((bits >>> 24) & 0xff);
    }

    void f64(double v) {
        long bits = Double.doubleToRawLongBits(v);
        for (int i = 0; i < 8; i++) {
            out.write((int) (bits >>> (8 * i)) & 0xff);
        }
    }

    void bytes(byte[] b) {
        out.write(b, 0, b.length);
    }

    void string(byte[] b) {
        i16(b.length);
        bytes(b);
    }

    byte[] toByteArray() {
        return out.toByteArray();
    }
}
