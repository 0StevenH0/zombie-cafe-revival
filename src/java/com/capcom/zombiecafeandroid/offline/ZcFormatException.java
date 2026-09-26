package com.capcom.zombiecafeandroid.offline;

/** Thrown when a legacy binary blob does not match the expected layout. */
public final class ZcFormatException extends Exception {
    private static final long serialVersionUID = 1L;

    public ZcFormatException(String message) {
        super(message);
    }
}
