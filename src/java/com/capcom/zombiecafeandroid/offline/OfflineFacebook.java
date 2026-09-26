package com.capcom.zombiecafeandroid.offline;

import android.content.Context;
import android.content.SharedPreferences;

import com.capcom.zombiecafeandroid.CapcomFacebook;
import com.capcom.zombiecafeandroid.ZombieCafeAndroid;

import java.util.Random;

/**
 * Stands in for the 2011 Facebook SDK. The native game gates friends, friend
 * cafes and gifts on CCFacebook::IsLoggedIn (Java IsLoggedIn -> mLoggedIn) and
 * learns identities through the setFBInfo/sendFriendInfo JNI callbacks, so a
 * local profile plus the {@link RivalProfile#NEIGHBORS} list is all it needs.
 *
 * Action codes are CapcomFacebook's kFacebook* constants.
 */
public final class OfflineFacebook {
    static final int POST_WALL = 0;
    static final int UPLOAD_PIC = 1;
    static final int LOGIN = 2;
    static final int GET_FRIENDS = 3;
    static final int POST_STORY = 4;
    static final int GET_INFO = 5;
    static final int LOGOUT = 6;
    static final int IS_LOGGED_IN = 7;
    static final int INIT = 8;

    private static final String PREFS = "zc_offline";
    private static final String KEY_USER_ID = "fb_user_id";
    private static final String KEY_LOGGED_OUT = "fb_logged_out";

    static final String MY_FIRST_NAME = "Zombie";
    static final String MY_LAST_NAME = "Chef";

    private OfflineFacebook() {}

    /** Replaces CapcomFacebook.ExecuteFacebook; runs on the Facebook worker thread. */
    public static void execute(int action, String option, String path) {
        try {
            OfflineLog.d("facebook action=" + action);
            switch (action) {
                case INIT:
                    if (!loggedOutByPlayer()) {
                        logIn();
                    } else {
                        ZombieCafeAndroid.mLoggedIn = false;
                    }
                    break;
                case LOGIN:
                    setLoggedOutByPlayer(false);
                    logIn();
                    break;
                case IS_LOGGED_IN:
                    ZombieCafeAndroid.mLoggedIn = !loggedOutByPlayer();
                    break;
                case GET_INFO:
                    if (ZombieCafeAndroid.mLoggedIn) {
                        sendMyInfo();
                    }
                    break;
                case GET_FRIENDS:
                    if (!ZombieCafeAndroid.mLoggedIn) {
                        setLoggedOutByPlayer(false);
                        logIn();
                    }
                    sendFriends();
                    break;
                case LOGOUT:
                    setLoggedOutByPlayer(true);
                    ZombieCafeAndroid.mLoggedIn = false;
                    CapcomFacebook.onFacebook(false);
                    break;
                case POST_WALL:
                case UPLOAD_PIC:
                case POST_STORY:
                default:
                    // Nothing to publish to while offline.
                    break;
            }
        } catch (Throwable t) {
            OfflineLog.w("facebook action " + action + " failed", t);
        }
    }

    private static void logIn() {
        ZombieCafeAndroid.mLoggedIn = true;
        ZombieCafeAndroid.mAllowLogin = true;
        CapcomFacebook.onFacebook(true);
        sendMyInfo();
    }

    private static void sendMyInfo() {
        CapcomFacebook.setFBInfo(MY_FIRST_NAME + " " + MY_LAST_NAME, MY_FIRST_NAME, MY_LAST_NAME, myUserId());
    }

    /** Native side allocates the list at index 0 and refreshes metadata when index == count - 1. */
    private static void sendFriends() {
        RivalProfile[] friends = RivalProfile.NEIGHBORS;
        for (int i = 0; i < friends.length; i++) {
            RivalProfile f = friends[i];
            CapcomFacebook.sendFriendInfo(i, friends.length, f.fullName(), f.uid, f.firstName, f.lastName, "");
        }
    }

    /** CCFacebook::GetUserId runs atoi() on this, so it must be a positive 32-bit number. */
    static String myUserId() {
        SharedPreferences prefs = prefs();
        if (prefs == null) {
            return "100000001";
        }
        String id = prefs.getString(KEY_USER_ID, null);
        if (id == null) {
            id = Integer.toString(100000000 + new Random().nextInt(800000000));
            prefs.edit().putString(KEY_USER_ID, id).commit();
        }
        return id;
    }

    private static boolean loggedOutByPlayer() {
        SharedPreferences prefs = prefs();
        return prefs != null && prefs.getBoolean(KEY_LOGGED_OUT, false);
    }

    private static void setLoggedOutByPlayer(boolean value) {
        SharedPreferences prefs = prefs();
        if (prefs != null) {
            prefs.edit().putBoolean(KEY_LOGGED_OUT, value).commit();
        }
    }

    private static SharedPreferences prefs() {
        Context ctx = ZombieCafeAndroid.CONTEXT;
        return ctx == null ? null : ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }
}
