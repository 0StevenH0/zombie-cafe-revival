/*
 * arm64 libZombieCafeExtension.so. The Java code still calls
 * System.loadLibrary("ZombieCafeExtension"); the real patcher runs inside the
 * emulator (loaded by libZombieCafeAndroid.so), so this one has nothing to do.
 */
#include <jni.h>

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
    (void)vm;
    (void)reserved;
    return JNI_VERSION_1_4;
}
