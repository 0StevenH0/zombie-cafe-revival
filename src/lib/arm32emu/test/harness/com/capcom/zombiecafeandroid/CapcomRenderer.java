package com.capcom.zombiecafeandroid;

/** Same native methods as the game's CapcomRenderer. */
public class CapcomRenderer {
    private native void CreateGame(Class<?> cc, int w, int h, float sx, float sy);

    private static native void render(int dt);

    void createGame(int w, int h, float sx, float sy) {
        CreateGame(CC_Android.class, w, h, sx, sy);
    }

    static void renderFrame(int dt) {
        render(dt);
    }
}
