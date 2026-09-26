package com.capcom.zombiecafeandroid;

/** Compile-time stub of the real (smali) class; only the members offline code touches. Never dexed. */
public class CapcomFacebook {
    public static native void onFacebook(boolean loggedIn);

    public static native void sendFriendInfo(int index, int count, String name, String uid,
                                             String firstName, String lastName, String picUrl);

    public static native void setFBInfo(String name, String firstName, String lastName, String id);
}
