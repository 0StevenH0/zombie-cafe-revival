package com.capcom.zombiecafeandroid;

/** Same native callback as the game's NetworkTask. */
public class NetworkTask {
    public static native void NewRequestServerCallback(boolean ok, byte[] data, int len, int cb);
}
