package com.capcom.zombiecafeandroid;

/** Same static native methods as the game's ZombieCafeAndroid activity. */
public class ZombieCafeAndroid {
    public static native boolean CheckDoneLoading();
    public static native boolean CheckIfInHelpScreen();
    public static native void ClearDialogFlag();
    public static native void DialogCallBack();
    public static native boolean HandleBackButton();
    public static native void PurchaseAndroidToxin(int which);
    public static native void StartNotifications();
    public static native void deviceShaken();
    public static native void mouseDown(float x, float y, int id);
    public static native void mouseMove(float[] pts, int n);
    public static native void mouseUp(float x, float y, int id);
    public static native void setDeviceModel(String s);
    public static native void setVanityString(String s);
    public static native void updateAccelerometer(float x, float y, float z);
}
