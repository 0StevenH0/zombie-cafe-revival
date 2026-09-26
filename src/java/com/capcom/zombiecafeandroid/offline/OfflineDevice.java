package com.capcom.zombiecafeandroid.offline;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Context;
import android.os.Bundle;
import android.telephony.TelephonyManager;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

/**
 * Platform calls the 2011 code makes that newer Android refuses. Call sites in
 * the game, ad and tracking code are pointed here instead of at the framework:
 *
 * <ul>
 * <li>TelephonyManager.getDeviceId()/getSimSerialNumber() throw SecurityException
 *     for apps targeting API 23+ without the runtime READ_PHONE_STATE grant (and
 *     for everyone on Android 10+). The game only uses them as opaque IDs, so
 *     null is returned, which is what Android 10+ gives legacy apps.</li>
 * <li>Notification.setLatestEventInfo() was removed in Android 6; the café
 *     reminder receiver used it and crashed in the background. Where it is
 *     gone, the title, text and tap action are stored where the system's
 *     notification template reads them.</li>
 * </ul>
 */
public final class OfflineDevice {
    private OfflineDevice() {}

    public static String deviceId(TelephonyManager tm) {
        try {
            return tm != null ? tm.getDeviceId() : null;
        } catch (Throwable t) {
            return null;
        }
    }

    public static String simSerialNumber(TelephonyManager tm) {
        try {
            return tm != null ? tm.getSimSerialNumber() : null;
        } catch (Throwable t) {
            return null;
        }
    }

    public static void setLatestEventInfo(Notification n, Context context, CharSequence title, CharSequence text,
                                          PendingIntent intent) {
        try {
            Method legacy = Notification.class.getMethod("setLatestEventInfo", Context.class, CharSequence.class,
                    CharSequence.class, PendingIntent.class);
            legacy.invoke(n, context, title, text, intent);
            return;
        } catch (NoSuchMethodException gone) {
            // Android 6+: fall through.
        } catch (Throwable t) {
            OfflineLog.w("setLatestEventInfo failed", t);
        }
        n.contentIntent = intent;
        try {
            Field f = Notification.class.getField("extras"); // API 19
            Bundle extras = (Bundle) f.get(n);
            if (extras == null) {
                extras = new Bundle();
                f.set(n, extras);
            }
            extras.putCharSequence("android.title", title);
            extras.putCharSequence("android.text", text);
        } catch (Throwable t) {
            OfflineLog.w("notification extras unavailable", t);
        }
    }
}
