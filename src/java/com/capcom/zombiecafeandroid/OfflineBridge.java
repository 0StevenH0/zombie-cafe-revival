package com.capcom.zombiecafeandroid;

import android.content.Context;

import com.capcom.zombiecafeandroid.offline.OfflineServer;

/**
 * Lives in the game's package because URLManager and NetworkTask are
 * package-private. URLManager.a(String, int) calls {@link #handleRequest}
 * instead of issuing HTTP requests.
 */
final class OfflineBridge {
    private OfflineBridge() {}

    @SuppressWarnings("unchecked") // NetworkTask extends the raw AsyncTask type
    static void handleRequest(Context context, String url, int callbackType) {
        Context ctx = context != null ? context : ZombieCafeAndroid.CONTEXT;
        OfflineServer.Reply reply = OfflineServer.get(ctx).respond(url, callbackType);
        if (reply.ok) {
            // Same hand-off the original HTTP success path used: the serial
            // AsyncTask executor delivers the bytes to the native callback.
            new NetworkTask(true, reply.body, reply.body.length, callbackType).execute((Object[]) new String[0]);
        } else {
            // NetworkTask always reports success, so failures go direct, as before.
            URLManager.NewRequestServerCallback(false, null, 0, callbackType);
        }
    }
}
