package com.capcom.zombiecafeandroid.offline;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Answers the requests libZombieCafeAndroid.so makes through
 * CCUrlConnection::NewRequest, in the formats CCServer::Android_ServerCallback
 * expects. Nothing here touches the network.
 *
 * Callback ids and parsers (from the native jump table):
 * <pre>
 *  0  analytics upload            success purges the local event log
 *  2  savegamestate.php           ignored ("do nothing")
 *  4  givegift.php                ignored
 *  6  versioncheck.php            ignored ("UNUSED!")
 *  7  gettimestamp.php            atoi(), must be 5..15 bytes
 *  8  getmetadata.php?u0=         "id:level:rating:63:flag:s:s:pct\n" lines, NUL-terminated
 *  10 getgamestate.php?u=         ServerData.dat blob (friend cafe)
 *  11 getgifts.php                "NO_DATA" == nothing waiting
 *  12 getmetadata.php?u0..uN      as 8, for the whole friends list
 *  13 getrandomgamestate.php      ServerData.dat blob (random cafe)
 *  14 gotgifts.php                ignored
 * 17,18 gettimestamp.php          IAP bookkeeping, same format as 7
 * </pre>
 * Anything else fails exactly like an unimplemented endpoint on the old server did.
 */
final class OfflineRouter {

    interface Backend {
        /** A rival for "visit a random cafe"; null if none can be built. */
        byte[] randomRival();

        /** The cafe of a friend/neighbor by unique id; null if none can be built. */
        byte[] rivalFor(String uid);

        /** Metadata for a friend/neighbor, without the leading "id:". */
        String metadataFor(String uid);

        /** The game just wrote a fresh ServerData.dat and asked to upload it. */
        void onGameStateSaved();

        long nowSeconds();
    }

    static final class Response {
        final boolean ok;
        final byte[] body;

        private Response(boolean ok, byte[] body) {
            this.ok = ok;
            this.body = body;
        }

        static Response ok(byte[] body) {
            return new Response(true, body == null ? new byte[0] : body);
        }

        /** Text bodies are read with strcmp/atoi/strchr, so they always carry a NUL. */
        static Response text(String s) {
            byte[] raw = RivalGenerator.ascii(s);
            byte[] out = new byte[raw.length + 1];
            System.arraycopy(raw, 0, out, 0, raw.length);
            return new Response(true, out);
        }

        static Response fail() {
            return new Response(false, null);
        }
    }

    static final int CB_ANALYTICS = 0;
    static final int MAX_METADATA_IDS = 64;

    private OfflineRouter() {}

    static Response route(String url, int callbackType, Backend backend) {
        String endpoint = endpoint(url);
        Map<String, String> query = query(url);

        if ("gettimestamp.php".equals(endpoint)) {
            return Response.text(Long.toString(backend.nowSeconds()));
        }
        if ("getrandomgamestate.php".equals(endpoint)) {
            return blob(backend.randomRival());
        }
        if ("getgamestate.php".equals(endpoint) || "getsng.php".equals(endpoint)
                || "getspecialgamestate.php".equals(endpoint)) {
            String uid = query.get("u");
            return blob(uid == null || uid.length() == 0 ? backend.randomRival() : backend.rivalFor(uid));
        }
        if ("getmetadata.php".equals(endpoint)) {
            StringBuilder sb = new StringBuilder();
            for (String uid : metadataIds(query)) {
                String meta = backend.metadataFor(uid);
                if (meta != null) {
                    sb.append(uid).append(':').append(meta).append('\n');
                }
            }
            return Response.text(sb.toString());
        }
        if ("getspecialmetadata.php".equals(endpoint)) {
            return Response.text("");
        }
        if ("savegamestate.php".equals(endpoint)) {
            backend.onGameStateSaved();
            return Response.ok(null);
        }
        if ("getgifts.php".equals(endpoint)) {
            return Response.text("NO_DATA");
        }
        if ("gotgifts.php".equals(endpoint) || "givegift.php".equals(endpoint)
                || "settoken.php".equals(endpoint) || "versioncheck.php".equals(endpoint)
                || "glinfo.php".equals(endpoint)) {
            return Response.ok(null);
        }
        if (callbackType == CB_ANALYTICS) {
            return Response.ok(null);
        }
        return Response.fail();
    }

    private static Response blob(byte[] data) {
        return data == null || data.length == 0 ? Response.fail() : Response.ok(data);
    }

    /** "http://host/v1/zca/getgamestate.php?v=63&u=1" -> "getgamestate.php". */
    static String endpoint(String url) {
        if (url == null) {
            return "";
        }
        int q = url.indexOf('?');
        String path = q >= 0 ? url.substring(0, q) : url;
        int slash = path.lastIndexOf('/');
        return path.substring(slash + 1).toLowerCase(Locale.US);
    }

    static Map<String, String> query(String url) {
        Map<String, String> out = new HashMap<String, String>();
        if (url == null) {
            return out;
        }
        int q = url.indexOf('?');
        if (q < 0) {
            return out;
        }
        for (String pair : url.substring(q + 1).split("&")) {
            if (pair.length() == 0) {
                continue;
            }
            int eq = pair.indexOf('=');
            String key = eq >= 0 ? pair.substring(0, eq) : pair;
            String value = eq >= 0 ? pair.substring(eq + 1) : "";
            out.put(decode(key), decode(value));
        }
        return out;
    }

    /** CCServer::RetrieveMetaDataForFriends appends "&u%d=%s" per friend; the single-id form uses u0. */
    private static List<String> metadataIds(Map<String, String> query) {
        List<String> ids = new ArrayList<String>();
        for (int i = 0; i < MAX_METADATA_IDS; i++) {
            String uid = query.get("u" + i);
            if (uid == null) {
                break;
            }
            if (uid.length() > 0) {
                ids.add(uid);
            }
        }
        return ids;
    }

    private static String decode(String s) {
        try {
            return URLDecoder.decode(s, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            return s;
        } catch (IllegalArgumentException e) {
            return s;
        }
    }
}
