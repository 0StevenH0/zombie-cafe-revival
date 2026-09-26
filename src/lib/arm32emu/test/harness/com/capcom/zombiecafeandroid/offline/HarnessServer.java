package com.capcom.zombiecafeandroid.offline;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/** Runs the real offline server on the host, backed by plain directories. */
public final class HarnessServer {
    private static OfflineServer server;

    private HarnessServer() {}

    public static void init(final File files, final File assets) {
        OfflineLog.hostMode = true;
        server = new OfflineServer(new OfflineStorage() {
            @Override public File filesDir() { return files; }
            @Override public File externalFilesDir() { return null; }
            @Override public InputStream openAsset(String name) throws IOException {
                return new FileInputStream(new File(assets, name));
            }
        });
    }

    /** {ok, body} or null on failure. */
    public static Object[] respond(String url, int cb) {
        OfflineServer.Reply r = server.respond(url, cb);
        return r.ok ? new Object[] {Boolean.TRUE, r.body} : null;
    }
}
