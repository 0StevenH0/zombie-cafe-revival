package com.capcom.zombiecafeandroid;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.util.ArrayDeque;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import javax.imageio.ImageIO;

/**
 * Host stand-in for the game's CC_Android: every static method the engine can
 * call back into, with the same signatures. Files follow the real split
 * (save files in the app's files dir, everything else from assets); textures
 * are decoded with ImageIO and handed to the software renderer; network
 * requests go to the real offline server classes.
 */
public class CC_Android {
    static File assets;
    static File files;
    static boolean verbose = System.getenv("ZC_HARNESS_VERBOSE") != null;
    static final Map<String, Object> options = new HashMap<>();
    static final ArrayDeque<Object[]> replies = new ArrayDeque<>();
    static int nextTexture = 1;
    static int texturesLoaded;
    static int requests;

    static void log(String s) {
        if (verbose) System.out.println("[java] " + s);
    }

    static boolean isSaveFile(String p) {
        String[] keys = {".smurfmap", ".smurfsmap", ".dat", ".jpg", ".caf", "2011", "2012", "2013", ".mkt", ".crmhvr"};
        for (String k : keys) if (p.contains(k)) return true;
        return false;
    }

    static File resolve(String p) {
        return isSaveFile(p) ? new File(files, p) : new File(assets, p);
    }

    // ------------------------------------------------------------ files

    public static byte[] fromNative_fileRead(String p) {
        File f = resolve(p);
        try {
            byte[] b = Files.readAllBytes(f.toPath());
            log("fileRead " + p + " -> " + b.length);
            return b;
        } catch (IOException e) {
            log("fileRead " + p + " -> missing");
            return null;
        }
    }

    public static boolean fromNative_doesFileExist(String p) {
        boolean r = resolve(p).isFile();
        log("doesFileExist " + p + " -> " + r);
        return r;
    }

    public static int fromNative_fileGetSize(String p) {
        File f = resolve(p);
        return f.isFile() ? (int) f.length() : -1;
    }

    public static boolean fromNative_fileWrite(String p, int offset, int len, byte[] data) {
        try (RandomAccessFile f = new RandomAccessFile(new File(files, p), "rw")) {
            f.setLength(0);
            f.seek(offset);
            f.write(data, 0, len);
            log("fileWrite " + p + " " + len);
            return true;
        } catch (IOException e) {
            return false;
        }
    }

    public static boolean fromNative_fileAppend(String p, int offset, int len, byte[] data) {
        try (RandomAccessFile f = new RandomAccessFile(new File(files, p), "rw")) {
            f.seek(f.length());
            f.write(data, offset, len);
            return true;
        } catch (IOException e) {
            return false;
        }
    }

    public static boolean fromNative_fileDelete(String p) { return new File(files, p).delete(); }
    public static void fromNative_fileRename(String a, String b) { new File(files, a).renameTo(new File(files, b)); }

    // ---------------------------------------------------------- textures

    static int pot(int v) {
        int p = 1;
        while (p < v) p <<= 1;
        return p;
    }

    public static int[] fromNative_loadTexture(String name, boolean full) {
        int[] r = new int[6];
        File f = new File(files, name);
        if (!f.isFile()) f = new File(assets, name);
        try {
            BufferedImage img = ImageIO.read(f);
            if (img == null) throw new IOException("undecodable");
            int w = img.getWidth(), h = img.getHeight(), pw = pot(w), ph = pot(h);
            int[] argb = new int[pw * ph];
            img.getRGB(0, 0, w, h, argb, 0, pw);
            int id = nextTexture++;
            Harness.uploadTexture(id, pw, ph, argb);
            r[0] = pw; r[1] = ph; r[2] = 1; r[3] = id; r[4] = w; r[5] = h;
            texturesLoaded++;
            log("loadTexture " + name + " -> " + id + " " + w + "x" + h);
        } catch (IOException e) {
            System.out.println("[java] loadTexture " + name + " FAILED (" + f + "): " + e.getMessage());
        }
        return r;
    }

    public static int generateTexture(Object bitmap) { return 0; }

    // ------------------------------------------------------------ options

    public static void fromNative_CCOptionsInit(String file) { log("CCOptionsInit " + file); }
    public static boolean fromNative_CCOptionsGetBool(String k, boolean d) { Object v = options.get(k); return v instanceof Boolean ? (Boolean) v : d; }
    public static float fromNative_CCOptionsGetFloat(String k, float d) { Object v = options.get(k); return v instanceof Float ? (Float) v : d; }
    public static int fromNative_CCOptionsGetInt(String k, int d) { Object v = options.get(k); return v instanceof Integer ? (Integer) v : d; }
    public static long fromNative_CCOptionsGetUInt(String k, long d) { Object v = options.get(k); return v instanceof Long ? (Long) v : d; }
    public static double fromNative_CCOptionsGetUInt64(String k, double d) { Object v = options.get(k); return v instanceof Double ? (Double) v : d; }
    public static byte[] fromNative_CCOptionsGetString(String k, String d) { Object v = options.get(k); return (v instanceof String ? (String) v : d).getBytes(); }
    public static String fromNative_CCOptionsGetStringJava(String k, String d) { Object v = options.get(k); return v instanceof String ? (String) v : d; }
    public static void fromNative_CCOptionsSetBool(String k, boolean v) { options.put(k, v); }
    public static void fromNative_CCOptionsSetFloat(String k, float v) { options.put(k, v); }
    public static void fromNative_CCOptionsSetInt(String k, int v) { options.put(k, v); }
    public static void fromNative_CCOptionsSetUInt(String k, long v) { options.put(k, v); }
    public static void fromNative_CCOptionsSetUInt64(String k, double v) { options.put(k, v); }
    public static void fromNative_CCOptionsSetString(String k, String v) { options.put(k, v); }

    // ------------------------------------------------------------ device

    public static long fromNative_CCSecondsSince1970() { return System.currentTimeMillis() / 1000; }
    public static int fromNative_GetDate(int which) {
        Calendar c = Calendar.getInstance();
        switch (which) {
            case 0: return c.get(Calendar.YEAR);
            case 1: return c.get(Calendar.MONTH) + 1;
            case 2: return c.get(Calendar.DAY_OF_MONTH);
            case 3: return c.get(Calendar.HOUR_OF_DAY);
            case 4: return c.get(Calendar.MINUTE);
            case 5: return c.get(Calendar.SECOND);
            default: return 99;
        }
    }
    public static byte[] fromNative_GetDateString(int which) { return String.format("%tF", Calendar.getInstance()).getBytes(); }
    public static byte[] fromNative_GetDeviceID() { return "harness-device".getBytes(); }
    public static byte[] fromNative_GetAndroidID() { return "harness-android-id".getBytes(); }
    public static byte[] fromNative_GetProductID() { return "harness".getBytes(); }
    public static byte[] fromNative_GetCountryCode() { return "US".getBytes(); }
    public static int fromNative_GetAndroidDevice() { return 0; }
    public static int fromNative_GetGraphicSet() { return 0; }
    public static boolean fromNative_IsAmazon() { return false; }
    public static boolean fromNative_IsKindle() { return false; }
    public static boolean fromNative_IsConnected() { return true; }
    public static boolean fromNative_Connected() { return true; }
    public static boolean fromNative_LoggedIn() { return false; }

    public static byte[] fromNative_EncodeURL(String s) {
        try { return URLEncoder.encode(s, "UTF-8").getBytes(); } catch (IOException e) { return new byte[0]; }
    }

    static byte[] md5hex(byte[] in) {
        try {
            byte[] d = MessageDigest.getInstance("MD5").digest(in);
            StringBuilder sb = new StringBuilder();
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString().getBytes();
        } catch (Exception e) {
            return new byte[32];
        }
    }
    public static byte[] fromNative_MD5String(String s) { return md5hex(s.getBytes()); }
    public static byte[] fromNative_MD5Data(byte[] data, int len) {
        byte[] b = new byte[len];
        System.arraycopy(data, 0, b, 0, len);
        return md5hex(b);
    }

    // ----------------------------------------------------------- network

    public static void fromNative_NewRequest(String url, String query, int cb) {
        requests++;
        Object[] reply = com.capcom.zombiecafeandroid.offline.HarnessServer.respond(query, cb);
        log("NewRequest cb=" + cb + " " + query + " -> " + (reply == null ? "fail" : ((byte[]) reply[1]).length + " bytes"));
        synchronized (replies) {
            replies.add(new Object[] {reply != null, reply != null ? reply[1] : null, cb});
        }
    }

    /** Delivers queued replies, as NetworkTask.onPostExecute would on the UI thread. */
    static void deliverReplies() {
        if (pendingDialog >= 0) {
            pendingDialog = -1;
            ZombieCafeAndroid.DialogCallBack();
            ZombieCafeAndroid.ClearDialogFlag();
        }
        while (true) {
            Object[] r;
            synchronized (replies) {
                r = replies.poll();
            }
            if (r == null) return;
            byte[] body = (byte[]) r[1];
            NetworkTask.NewRequestServerCallback((Boolean) r[0], body, body == null ? 0 : body.length, (Integer) r[2]);
        }
    }

    public static boolean fromNative_URLRequest(String u) { return false; }
    public static void fromNative_LoadFromURL(String u, byte[] b) {}
    public static void fromNative_LoadImageFromURL(String u) {}

    // ------------------------------------------------------------- sound

    public static boolean fromNative_initSound(int effects, int music, boolean b) { return true; }
    public static boolean fromNative_SoundsLoaded() { return true; }
    public static void fromNative_freeSound() {}
    public static boolean fromNative_loadEffect(int i, String s) { return true; }
    public static boolean fromNative_loadMusic(int i, String s) { return true; }
    public static boolean fromNative_startEffect(int i, float v) { return true; }
    public static boolean fromNative_startMusic(int i) { return true; }
    public static boolean fromNative_stopEffect(int i) { return true; }
    public static boolean fromNative_stopMusic(int i) { return true; }
    public static boolean fromNative_unloadEffect(int i) { return true; }
    public static boolean fromNative_unloadMusic(int i) { return true; }
    public static boolean fromNative_isEffectPlaying(int i) { return false; }
    public static boolean fromNative_isMusicPlaying(int i) { return false; }
    public static boolean fromNative_setEffectVolume(int i, float v) { return true; }
    public static boolean fromNative_setMusicVolume(int i, float v) { return true; }
    public static boolean fromNative_setMusicLoop(int i, boolean b) { return true; }

    // ------------------------------------------------------------ ui

    static String lastDialog;
    static int pendingDialog = -1;
    /* On the phone this is an AlertDialog; its OK button calls DialogCallBack + ClearDialogFlag. */
    public static void fromNative_initDialog(int kind, String a, String b, String c, String d) {
        lastDialog = a + " | " + b;
        pendingDialog = kind;
        System.out.println("[java] dialog type " + kind + " (" + lastDialog + "), pressing OK");
    }
    public static void fromNative_initDialogNoCallBack(String a, String b, String c) { lastDialog = a + " | " + b; log("initDialogNoCallBack " + lastDialog); }
    public static void fromNative_showDialog() { log("showDialog"); }
    public static void fromNative_freeDialog() {}
    public static void fromNative_dismissDialogNoClick() {}
    public static void fromNative_ShowToast(String s) { log("toast " + s); }
    public static void fromNative_ProgressBar(int i) {}
    public static void fromNative_ShowWebView() {}
    public static void fromNative_HideWebView() {}
    public static void fromNative_VanityKeyboard() {}
    public static void fromNative_PaypalButton(boolean b) {}
    public static void fromNative_Accelerometer(boolean b) {}
    public static void fromNative_BuyStuff(int slot) { log("BuyStuff " + slot); }
    public static void fromNative_LaunchURL(String u) {}
    public static void fromNative_LaunchURL2(String u) {}
    public static void fromNative_LaunchCameraManager(String s) {}
    public static void fromNative_Screenshot(String s) {}
    public static void fromNative_SendEmail() {}
    public static void fromNative_SendNotification(int a, String s, int b, int c) {}
    public static void fromNative_DeleteNotification() {}
    public static void fromNative_UpdateWidget(int i, String s) {}
    public static void fromNative_Chartboost(int i) {}
    public static void fromNative_CRAMAction(int i) {}
    public static void fromNative_SaveCRAMImage(byte[] b, int i) {}
    public static void fromNative_SaveCRAMInfo(int i, String s) {}
    public static void fromNative_Facebook2(int a, String b, String c) { log("Facebook2 " + a); }
    public static void fromNative_FiksuPromptForRating() {}
    public static void fromNative_FiksuRecordEvent(String s) {}
    public static void fromNative_FiksuRecordPurchase(String a, int b, String c) {}
}
