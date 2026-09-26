package com.capcom.zombiecafeandroid.offline;

import android.app.Activity;
import android.app.Dialog;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Build;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.capcom.zombiecafeandroid.ZombieCafeAndroid;

import java.lang.reflect.Field;

/**
 * Full-screen play on Android 4.4+: the status and navigation bars stay hidden
 * (sticky immersive mode, where a swipe from the edge shows them for a moment),
 * and the game draws under a display cutout.
 *
 * <p>The game sized its GL view and renderer from Display.getWidth()/getHeight(),
 * which leave out the navigation bar, so hiding the bar alone would leave a black
 * strip. On 4.4+ the GL view fills the window instead, the renderer takes its
 * size from that view when its surface is created ({@link #readSurfaceSize}),
 * and {@link #width}/{@link #height} give the same size to the rest of the
 * activity (the help page overlay, screenshots). Below 4.4 every method keeps
 * the original behavior.
 */
public final class Immersive {
    // View.SYSTEM_UI_FLAG_*; the API 16 android.jar this compiles against has no IMMERSIVE_STICKY.
    private static final int FLAGS = 0x0002 // HIDE_NAVIGATION
            | 0x0004  // FULLSCREEN
            | 0x0100  // LAYOUT_STABLE
            | 0x0200  // LAYOUT_HIDE_NAVIGATION
            | 0x0400  // LAYOUT_FULLSCREEN
            | 0x1000; // IMMERSIVE_STICKY

    // WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_*
    private static final int CUTOUT_SHORT_EDGES = 1; // API 28
    private static final int CUTOUT_ALWAYS = 3;      // API 30

    /** The GL view's size when its surface was last created, as width << 32 | height; 0 before that. */
    private static volatile long surfaceSize;

    private Immersive() {}

    private static boolean supported() {
        return Build.VERSION.SDK_INT >= 19;
    }

    /**
     * Hides the system bars. Called from onCreate (after the last
     * requestWindowFeature, which must come before the decor view exists),
     * onResume and whenever the window regains focus.
     */
    public static void apply(Activity activity) {
        if (!supported()) {
            return;
        }
        Window window = activity.getWindow();
        if (Build.VERSION.SDK_INT >= 28) {
            drawUnderCutout(window);
        }
        window.getDecorView().setSystemUiVisibility(FLAGS);
    }

    private static void drawUnderCutout(Window window) {
        int mode = Build.VERSION.SDK_INT >= 30 ? CUTOUT_ALWAYS : CUTOUT_SHORT_EDGES;
        WindowManager.LayoutParams attrs = window.getAttributes();
        try {
            Field field = WindowManager.LayoutParams.class.getField("layoutInDisplayCutoutMode");
            if (field.getInt(attrs) != mode) {
                field.setInt(attrs, mode);
                window.setAttributes(attrs);
            }
        } catch (Exception e) {
            OfflineLog.w("display cutout mode unavailable", e);
        }
    }

    /**
     * Dialog.show() that keeps the bars hidden. They follow the focused window,
     * so the dialog's window gets the flags before it is allowed to take focus.
     */
    public static void show(Dialog dialog) {
        Window window = dialog.getWindow();
        if (!supported() || window == null) {
            dialog.show();
            return;
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE);
        try {
            dialog.show();
            window.getDecorView().setSystemUiVisibility(FLAGS);
        } finally {
            window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE);
        }
    }

    /** Layout size for the game's GL view: the whole window on 4.4+, else the size the game computed. */
    public static int viewSize(int computed) {
        return supported() ? ViewGroup.LayoutParams.MATCH_PARENT : computed;
    }

    /** Screen width the game lays itself out for; replaces Display.getWidth(). */
    @SuppressWarnings("deprecation")
    public static int width(Activity activity) {
        if (!supported()) {
            return activity.getWindowManager().getDefaultDisplay().getWidth();
        }
        long size = surfaceSize;
        return size != 0 ? (int) (size >>> 32) : windowSize(activity).x;
    }

    /** Screen height the game lays itself out for; replaces Display.getHeight(). */
    @SuppressWarnings("deprecation")
    public static int height(Activity activity) {
        if (!supported()) {
            return activity.getWindowManager().getDefaultDisplay().getHeight();
        }
        long size = surfaceSize;
        return size != 0 ? (int) size : windowSize(activity).y;
    }

    /** The whole window, including the areas under the system bars and the cutout. */
    @SuppressWarnings("deprecation")
    private static Point windowSize(Activity activity) {
        WindowManager wm = activity.getWindowManager();
        Display display = wm.getDefaultDisplay();
        Point size = new Point(display.getWidth(), display.getHeight());
        try {
            if (Build.VERSION.SDK_INT >= 30) {
                Object metrics = WindowManager.class.getMethod("getCurrentWindowMetrics").invoke(wm);
                Rect bounds = (Rect) metrics.getClass().getMethod("getBounds").invoke(metrics);
                size.set(bounds.width(), bounds.height());
            } else {
                Display.class.getMethod("getRealSize", Point.class).invoke(display, size); // API 17
            }
        } catch (Exception e) {
            OfflineLog.w("full window size unavailable", e);
        }
        return size;
    }

    /**
     * Called on the GL thread by CapcomRenderer.onSurfaceCreated, before it
     * creates the game: records the GL view's size, which its surface has.
     * The view is laid out before its surface is created, so the size is final
     * here. Returns false where the renderer should keep its own size.
     */
    public static boolean readSurfaceSize() {
        View view = ZombieCafeAndroid.mGLView;
        if (!supported() || view == null) {
            return false;
        }
        int w = view.getWidth();
        int h = view.getHeight();
        if (w <= 0 || h <= 0) {
            return false;
        }
        long size = (long) w << 32 | h;
        if (size != surfaceSize) {
            OfflineLog.d("full screen game size " + w + "x" + h);
        }
        surfaceSize = size;
        ZombieCafeAndroid.mScreenWidth = w;
        ZombieCafeAndroid.mScreenHeight = h;
        return true;
    }

    public static int surfaceWidth() {
        return (int) (surfaceSize >>> 32);
    }

    public static int surfaceHeight() {
        return (int) surfaceSize;
    }

    /** CapcomRenderer's own rule: draw at 2x on screens wider than 1280 or taller than 1000 pixels. */
    public static float surfaceScale() {
        return surfaceWidth() > 1280 || surfaceHeight() > 1000 ? 2f : 1f;
    }
}
