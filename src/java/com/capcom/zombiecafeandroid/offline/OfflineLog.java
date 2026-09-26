package com.capcom.zombiecafeandroid.offline;

import android.util.Log;

/** android.util.Log on device; stdout when the host-side tests run the same code. */
final class OfflineLog {
    static final String TAG = "ZCOffline";

    /** Set by host-side tests, where android.util.Log is only a stub. */
    static volatile boolean hostMode = false;

    private OfflineLog() {}

    static void d(String msg) {
        if (hostMode) {
            System.out.println("D/" + TAG + ": " + msg);
        } else {
            Log.d(TAG, msg);
        }
    }

    static void w(String msg, Throwable t) {
        if (hostMode) {
            System.out.println("W/" + TAG + ": " + msg + (t != null ? " (" + t + ")" : ""));
        } else if (t != null) {
            Log.w(TAG, msg, t);
        } else {
            Log.w(TAG, msg);
        }
    }
}
