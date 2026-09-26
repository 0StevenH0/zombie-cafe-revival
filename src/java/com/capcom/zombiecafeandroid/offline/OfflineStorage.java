package com.capcom.zombiecafeandroid.offline;

import android.content.Context;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

/** The file-system and asset access the offline server needs; on device it comes from a Context. */
interface OfflineStorage {
    /** Context.getFilesDir(): where the game keeps ServerData.dat. */
    File filesDir();

    /** Context.getExternalFilesDir(null), or null when there is none. */
    File externalFilesDir();

    InputStream openAsset(String name) throws IOException;

    final class ForContext implements OfflineStorage {
        private final Context context;

        ForContext(Context context) {
            this.context = context;
        }

        @Override
        public File filesDir() {
            return context.getFilesDir();
        }

        @Override
        public File externalFilesDir() {
            return context.getExternalFilesDir(null);
        }

        @Override
        public InputStream openAsset(String name) throws IOException {
            return context.getAssets().open(name);
        }
    }
}
