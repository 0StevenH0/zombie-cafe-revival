package com.capcom.zombiecafeandroid;

import java.io.File;

/**
 * Boots the real engine through the ARM32 runtime inside a desktop JVM and
 * drives it the way CapcomRenderer and the activity do: CreateGame, then a
 * render loop, answering network requests between frames and tapping the
 * screen now and then. Frames are rasterized in software and saved as PNGs.
 *
 *   java Harness <runtime.so> <assets dir> <files dir> <frames> <out dir> [every]
 */
public class Harness {
    static native void glInit(int w, int h);
    static native void glCapture(boolean on);
    static native boolean glSave(String path);
    static native void setupProjection(int w, int h, float sx, float sy);
    static native void uploadTexture(int id, int w, int h, int[] argb);
    static native long[] stats();
    static native void dumpStats();
    static native void trace(int mode);

    public static void main(String[] a) throws Exception {
        String lib = a[0];
        CC_Android.assets = new File(a[1]);
        CC_Android.files = new File(a[2]);
        int frames = Integer.parseInt(a[3]);
        File out = new File(a[4]);
        int every = a.length > 5 ? Integer.parseInt(a[5]) : 100;
        String taps = System.getenv("ZC_HARNESS_TAPS"); /* "frame:x:y,frame:x:y" */
        String dumpAt = System.getenv("ZC_HARNESS_DUMP_AT"); /* frame numbers: print and reset stats */
        boolean realtime = System.getenv("ZC_HARNESS_REALTIME") != null; /* pace frames at 30 fps */
        String traceAt = System.getenv("ZC_HARNESS_TRACE"); /* "recordFrame:logFrame" */
        CC_Android.files.mkdirs();
        out.mkdirs();
        com.capcom.zombiecafeandroid.offline.HarnessServer.init(CC_Android.files, CC_Android.assets);

        int w = 1200, h = 540;
        String size = System.getenv("ZC_HARNESS_SIZE"); /* "WxH" in game units */
        if (size != null) {
            String[] wh = size.split("x");
            w = Integer.parseInt(wh[0]);
            h = Integer.parseInt(wh[1]);
        }
        long t0 = System.nanoTime();
        System.load(lib);
        long t1 = System.nanoTime();
        System.out.printf("runtime loaded in %.1f ms%n", (t1 - t0) / 1e6);

        glInit(w, h);
        glCapture(true);
        setupProjection(w, h, 1f, 1f);
        ZombieCafeAndroid.setDeviceModel("Harness");
        CapcomRenderer r = new CapcomRenderer();
        r.createGame(w, h, 1f, 1f);
        long t2 = System.nanoTime();
        System.out.printf("CreateGame returned in %.1f ms%n", (t2 - t1) / 1e6);

        /* ZC_HARNESS_UI_THREAD=1: a second thread calling natives, like the UI thread's
           touch and sensor callbacks on the phone. */
        final boolean[] stop = {false};
        final long[] uiCalls = {0};
        final int[] frameNow = {0};
        final boolean uiThread = System.getenv("ZC_HARNESS_UI_THREAD") != null;
        Thread ui = null;
        if (uiThread) {
            final String uiTaps = taps;
            ui = new Thread(() -> {
                int lastFrame = -1;
                while (!stop[0]) {
                    ZombieCafeAndroid.updateAccelerometer(0f, 0f, -9.8f);
                    ZombieCafeAndroid.CheckIfInHelpScreen();
                    uiCalls[0]++;
                    int f = frameNow[0];
                    if (uiTaps != null && f != lastFrame) {
                        lastFrame = f;
                        for (String tap : uiTaps.split(",")) {
                            String[] p = tap.split(":");
                            int tf = Integer.parseInt(p[0]);
                            float x = Float.parseFloat(p[1]), y = Float.parseFloat(p[2]);
                            if (tf == f) ZombieCafeAndroid.mouseDown(x, y, 0);
                            if (tf + 2 == f) ZombieCafeAndroid.mouseUp(x, y, 0);
                        }
                    }
                    try { Thread.sleep(1); } catch (InterruptedException e) { return; }
                }
            });
            ui.start();
        }
        long renderNanos = 0;
        int slowest = 0;
        long slowestNanos = 0;
        for (int f = 0; f < frames; f++) {
            frameNow[0] = f;
            if (uiThread) Thread.sleep(3); /* let the UI thread see each frame number */
            CC_Android.deliverReplies();
            if (traceAt != null) {
                String[] tp = traceAt.split(":");
                if (Integer.parseInt(tp[0]) == f) trace(1);
                if (Integer.parseInt(tp[1]) == f) trace(2);
            }
            if (dumpAt != null)
                for (String d : dumpAt.split(","))
                    if (Integer.parseInt(d) == f) {
                        System.out.println("---- stats at frame " + f);
                        dumpStats();
                    }
            if (taps != null && !uiThread) {
                for (String tap : taps.split(",")) {
                    String[] p = tap.split(":");
                    int tf = Integer.parseInt(p[0]);
                    float x = Float.parseFloat(p[1]), y = Float.parseFloat(p[2]);
                    if (tf == f) ZombieCafeAndroid.mouseDown(x, y, 0);
                    if (tf + 2 == f) ZombieCafeAndroid.mouseUp(x, y, 0);
                }
            }
            boolean capture = f % every == every - 1 || f == frames - 1;
            glCapture(capture);
            long s = System.nanoTime();
            CapcomRenderer.renderFrame(33);
            long e = System.nanoTime() - s;
            if (!capture) {
                renderNanos += e;
                if (e > slowestNanos) { slowestNanos = e; slowest = f; }
            }
            if (realtime && e < 33_000_000L)
                Thread.sleep((33_000_000L - e) / 1_000_000L);
            if (capture) {
                String name = String.format("frame_%05d.png", f + 1);
                glSave(new File(out, name).getPath());
                long[] st = stats();
                System.out.printf("frame %d: %s (textures %d, requests %d, draws %d, heap %.1f MB, guest insns %d)%n",
                        f + 1, name, CC_Android.texturesLoaded, CC_Android.requests, st[1], st[3] / 1048576.0, st[4]);
            }
        }
        if (ui != null) {
            stop[0] = true;
            ui.join();
            System.out.println("ui thread: " + uiCalls[0] + " rounds of native calls");
        }
        System.out.printf("render: %d frames, avg %.2f ms (excluding captured frames), slowest %.1f ms at frame %d%n",
                frames, renderNanos / 1e6 / Math.max(1, frames - frames / every), slowestNanos / 1e6, slowest + 1);
        dumpStats();
    }
}
