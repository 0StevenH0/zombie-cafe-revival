/*
 * The 64-bit libZombieCafeAndroid.so: Java loads this in place of the 32-bit
 * engine. JNI_OnLoad boots the emulator, loads the original engine and the
 * (ARMv5TE build of the) ZombieCafeExtension patcher into guest memory, and
 * the Java_* functions below forward each native method into the guest.
 *
 * Only natives that both the engine exports and the Java code declares are
 * listed; the engine's other Java_* exports have no caller.
 */
#include <jni.h>

#include "hle.h"
#include "jni_bridge.h"
#include "mem.h"

/* The guest libraries are linked in as data (guest_blobs.S). Host test builds
   can instead point ZC_GUEST_DIR at a directory holding both files. */
extern const uint8_t zc_guest_game[] __attribute__((weak));
extern const uint8_t zc_guest_game_end[] __attribute__((weak));
extern const uint8_t zc_guest_ext[] __attribute__((weak));
extern const uint8_t zc_guest_ext_end[] __attribute__((weak));

typedef struct {
    const char *sym;
    const char *params; /* Java parameter types, ZBCSIJFD or L */
    char ret;
    uint32_t fn;
} native_t;

#define PKG "Java_com_capcom_zombiecafeandroid_"
enum {
    N_onFacebook, N_sendFriendInfo, N_setFBInfo, N_CreateGame, N_render, N_NetworkTaskPost_Callback,
    N_NetworkTask_Callback, N_DebugGame, N_SoundSetEnabled, N_LoadedBannerTextureCallback, N_NewRequestCallback,
    N_URLManager_ServerCallback, N_CheckDoneLoading, N_CheckIfInHelpScreen, N_ClearDialogFlag, N_DialogCallBack,
    N_HandleBackButton, N_PurchaseAndroidToxin, N_StartNotifications, N_deviceShaken, N_mouseDown, N_mouseMove,
    N_mouseUp, N_setDeviceModel, N_setVanityString, N_updateAccelerometer, N_COUNT
};

static native_t natives[N_COUNT] = {
    [N_onFacebook] = { PKG "CapcomFacebook_onFacebook", "Z", 'V', 0 },
    [N_sendFriendInfo] = { PKG "CapcomFacebook_sendFriendInfo", "IILLLLL", 'V', 0 },
    [N_setFBInfo] = { PKG "CapcomFacebook_setFBInfo", "LLLL", 'V', 0 },
    [N_CreateGame] = { PKG "CapcomRenderer_CreateGame", "LIIFF", 'V', 0 },
    [N_render] = { PKG "CapcomRenderer_render", "I", 'V', 0 },
    [N_NetworkTaskPost_Callback] = { PKG "NetworkTaskPost_NewRequestServerCallback", "ZLII", 'V', 0 },
    [N_NetworkTask_Callback] = { PKG "NetworkTask_NewRequestServerCallback", "ZLII", 'V', 0 },
    [N_DebugGame] = { PKG "SmurfsGLSurfaceView_DebugGame", "", 'V', 0 },
    [N_SoundSetEnabled] = { PKG "SoundManager_setEnabled", "Z", 'V', 0 },
    [N_LoadedBannerTextureCallback] = { PKG "URLManager_LoadedBannerTextureCallback", "LI", 'V', 0 },
    [N_NewRequestCallback] = { PKG "URLManager_NewRequestCallback", "LI", 'V', 0 },
    [N_URLManager_ServerCallback] = { PKG "URLManager_NewRequestServerCallback", "ZLII", 'V', 0 },
    [N_CheckDoneLoading] = { PKG "ZombieCafeAndroid_CheckDoneLoading", "", 'Z', 0 },
    [N_CheckIfInHelpScreen] = { PKG "ZombieCafeAndroid_CheckIfInHelpScreen", "", 'Z', 0 },
    [N_ClearDialogFlag] = { PKG "ZombieCafeAndroid_ClearDialogFlag", "", 'V', 0 },
    [N_DialogCallBack] = { PKG "ZombieCafeAndroid_DialogCallBack", "", 'V', 0 },
    [N_HandleBackButton] = { PKG "ZombieCafeAndroid_HandleBackButton", "", 'Z', 0 },
    [N_PurchaseAndroidToxin] = { PKG "ZombieCafeAndroid_PurchaseAndroidToxin", "I", 'V', 0 },
    [N_StartNotifications] = { PKG "ZombieCafeAndroid_StartNotifications", "", 'V', 0 },
    [N_deviceShaken] = { PKG "ZombieCafeAndroid_deviceShaken", "", 'V', 0 },
    [N_mouseDown] = { PKG "ZombieCafeAndroid_mouseDown", "FFI", 'V', 0 },
    [N_mouseMove] = { PKG "ZombieCafeAndroid_mouseMove", "LI", 'V', 0 },
    [N_mouseUp] = { PKG "ZombieCafeAndroid_mouseUp", "FFI", 'V', 0 },
    [N_setDeviceModel] = { PKG "ZombieCafeAndroid_setDeviceModel", "L", 'V', 0 },
    [N_setVanityString] = { PKG "ZombieCafeAndroid_setVanityString", "L", 'V', 0 },
    [N_updateAccelerometer] = { PKG "ZombieCafeAndroid_updateAccelerometer", "FFF", 'V', 0 },
};

static zc_lib game_lib, ext_lib;
static int booted;

static jvalue call(JNIEnv *env, int n, jobject self, const jvalue *args)
{
    jvalue none;
    none.j = 0;
    if (!booted || !natives[n].fn) {
        zc_log(ZC_LOG_ERROR, "%s called but the engine is not loaded", natives[n].sym);
        return none;
    }
    return zc_jni_invoke(env, natives[n].fn, self, natives[n].params, natives[n].ret, args);
}

static uint8_t *read_file(const char *path, size_t *len)
{
    FILE *f = fopen(path, "rb");
    if (!f)
        return NULL;
    fseek(f, 0, SEEK_END);
    long n = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *buf = malloc((size_t)n);
    if (buf && fread(buf, 1, (size_t)n, f) != (size_t)n) {
        free(buf);
        buf = NULL;
    }
    fclose(f);
    *len = (size_t)n;
    return buf;
}

static int load_guest(zc_lib *lib, const char *name, const uint8_t *img, const uint8_t *img_end, uint32_t base)
{
    size_t len = img && img_end > img ? (size_t)(img_end - img) : 0;
    uint8_t *owned = NULL;
    if (!len) {
        const char *dir = getenv("ZC_GUEST_DIR");
        char path[512];
        if (dir) {
            snprintf(path, sizeof path, "%s/%s", dir, name);
            img = owned = read_file(path, &len);
        }
    }
    if (!img || !len) {
        zc_log(ZC_LOG_ERROR, "guest library %s is not available", name);
        return -1;
    }
    int rc = zc_elf_load(lib, name, img, len, base, zc_hle_resolve);
    free(owned);
    if (rc)
        return rc;
    zc_register_lib(lib);
    return 0;
}

static void guest_onload(zc_thread *t, const zc_lib *lib)
{
    uint32_t fn = zc_elf_sym(lib, "JNI_OnLoad");
    if (!fn)
        return;
    uint32_t w[2] = { zc_jni_guest_vm(), 0 };
    zc_jni_push_frame(t);
    uint32_t version = (uint32_t)zc_call(&t->cpu, fn, w, 2);
    zc_jni_pop_frame(t);
    zc_log(ZC_LOG_INFO, "%s JNI_OnLoad returned %08x", lib->name, version);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
    (void)reserved;
    JNIEnv *env = NULL;
    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK)
        return JNI_ERR;
    if (zc_runtime_init())
        zc_fatal("cannot reserve guest address space");
    zc_hle_libc_init();
    zc_hle_zlib_init();
    zc_hle_gl_init();
    zc_hle_dl_init();
    zc_profile_init();
    zc_jni_init(vm, env);

    zc_lock();
    zc_thread *t = zc_thread_current();
    t->host_env = env;
    if (load_guest(&game_lib, "libZombieCafeAndroid.so", zc_guest_game, zc_guest_game_end, ZC_LIB_BASE))
        zc_fatal("could not load the game engine");
    zc_hle_softfloat_init(&game_lib);
    zc_elf_run_init(&game_lib);
    guest_onload(t, &game_lib);
    if (load_guest(&ext_lib, "libZombieCafeExtension.so", zc_guest_ext, zc_guest_ext_end,
                   ZC_LIB_BASE + 4 * ZC_LIB_STRIDE) == 0) {
        zc_elf_run_init(&ext_lib);
        guest_onload(t, &ext_lib);
    }
    for (int i = 0; i < N_COUNT; i++) {
        natives[i].fn = zc_elf_sym(&game_lib, natives[i].sym);
        if (!natives[i].fn)
            zc_log(ZC_LOG_WARN, "engine does not export %s", natives[i].sym);
    }
    booted = 1;
    t->host_env = NULL;
    zc_unlock();
    zc_log(ZC_LOG_INFO, "engine ready (heap in use %llu bytes)", (unsigned long long)zc_heap_in_use());
    return JNI_VERSION_1_6;
}

/* ------------------------------------------------------------ natives */

#define J(ret, name) JNIEXPORT ret JNICALL Java_com_capcom_zombiecafeandroid_##name

J(void, CapcomFacebook_onFacebook)(JNIEnv *env, jclass cls, jboolean v)
{
    jvalue a[1] = { { .z = v } };
    call(env, N_onFacebook, cls, a);
}

J(void, CapcomFacebook_sendFriendInfo)(JNIEnv *env, jclass cls, jint index, jint count, jstring name, jstring uid,
                                      jstring first, jstring last, jstring pic)
{
    jvalue a[7] = { { .i = index }, { .i = count }, { .l = name }, { .l = uid }, { .l = first }, { .l = last }, { .l = pic } };
    call(env, N_sendFriendInfo, cls, a);
}

J(void, CapcomFacebook_setFBInfo)(JNIEnv *env, jclass cls, jstring a0, jstring a1, jstring a2, jstring a3)
{
    jvalue a[4] = { { .l = a0 }, { .l = a1 }, { .l = a2 }, { .l = a3 } };
    call(env, N_setFBInfo, cls, a);
}

J(void, CapcomRenderer_CreateGame)(JNIEnv *env, jobject self, jclass cc, jint w, jint h, jfloat sx, jfloat sy)
{
    jvalue a[5] = { { .l = cc }, { .i = w }, { .i = h }, { .f = sx }, { .f = sy } };
    call(env, N_CreateGame, self, a);
}

J(void, CapcomRenderer_render)(JNIEnv *env, jclass cls, jint dt)
{
    jvalue a[1] = { { .i = dt } };
    call(env, N_render, cls, a);
}

J(void, NetworkTaskPost_NewRequestServerCallback)(JNIEnv *env, jclass cls, jboolean ok, jbyteArray data, jint len, jint cb)
{
    jvalue a[4] = { { .z = ok }, { .l = data }, { .i = len }, { .i = cb } };
    call(env, N_NetworkTaskPost_Callback, cls, a);
}

J(void, NetworkTask_NewRequestServerCallback)(JNIEnv *env, jclass cls, jboolean ok, jbyteArray data, jint len, jint cb)
{
    jvalue a[4] = { { .z = ok }, { .l = data }, { .i = len }, { .i = cb } };
    call(env, N_NetworkTask_Callback, cls, a);
}

J(void, SmurfsGLSurfaceView_DebugGame)(JNIEnv *env, jclass cls) { call(env, N_DebugGame, cls, NULL); }

J(void, SoundManager_setEnabled)(JNIEnv *env, jobject self, jboolean v)
{
    jvalue a[1] = { { .z = v } };
    call(env, N_SoundSetEnabled, self, a);
}

J(void, URLManager_LoadedBannerTextureCallback)(JNIEnv *env, jclass cls, jbyteArray data, jint len)
{
    jvalue a[2] = { { .l = data }, { .i = len } };
    call(env, N_LoadedBannerTextureCallback, cls, a);
}

J(void, URLManager_NewRequestCallback)(JNIEnv *env, jclass cls, jbyteArray data, jint len)
{
    jvalue a[2] = { { .l = data }, { .i = len } };
    call(env, N_NewRequestCallback, cls, a);
}

J(void, URLManager_NewRequestServerCallback)(JNIEnv *env, jclass cls, jboolean ok, jbyteArray data, jint len, jint cb)
{
    jvalue a[4] = { { .z = ok }, { .l = data }, { .i = len }, { .i = cb } };
    call(env, N_URLManager_ServerCallback, cls, a);
}

J(jboolean, ZombieCafeAndroid_CheckDoneLoading)(JNIEnv *env, jclass cls) { return call(env, N_CheckDoneLoading, cls, NULL).z; }
J(jboolean, ZombieCafeAndroid_CheckIfInHelpScreen)(JNIEnv *env, jclass cls) { return call(env, N_CheckIfInHelpScreen, cls, NULL).z; }
J(void, ZombieCafeAndroid_ClearDialogFlag)(JNIEnv *env, jclass cls) { call(env, N_ClearDialogFlag, cls, NULL); }
J(void, ZombieCafeAndroid_DialogCallBack)(JNIEnv *env, jclass cls) { call(env, N_DialogCallBack, cls, NULL); }
J(jboolean, ZombieCafeAndroid_HandleBackButton)(JNIEnv *env, jclass cls) { return call(env, N_HandleBackButton, cls, NULL).z; }

J(void, ZombieCafeAndroid_PurchaseAndroidToxin)(JNIEnv *env, jclass cls, jint which)
{
    jvalue a[1] = { { .i = which } };
    call(env, N_PurchaseAndroidToxin, cls, a);
}

J(void, ZombieCafeAndroid_StartNotifications)(JNIEnv *env, jclass cls) { call(env, N_StartNotifications, cls, NULL); }
J(void, ZombieCafeAndroid_deviceShaken)(JNIEnv *env, jclass cls) { call(env, N_deviceShaken, cls, NULL); }

J(void, ZombieCafeAndroid_mouseDown)(JNIEnv *env, jclass cls, jfloat x, jfloat y, jint id)
{
    jvalue a[3] = { { .f = x }, { .f = y }, { .i = id } };
    call(env, N_mouseDown, cls, a);
}

J(void, ZombieCafeAndroid_mouseMove)(JNIEnv *env, jclass cls, jfloatArray pts, jint n)
{
    jvalue a[2] = { { .l = pts }, { .i = n } };
    call(env, N_mouseMove, cls, a);
}

J(void, ZombieCafeAndroid_mouseUp)(JNIEnv *env, jclass cls, jfloat x, jfloat y, jint id)
{
    jvalue a[3] = { { .f = x }, { .f = y }, { .i = id } };
    call(env, N_mouseUp, cls, a);
}

J(void, ZombieCafeAndroid_setDeviceModel)(JNIEnv *env, jclass cls, jstring s)
{
    jvalue a[1] = { { .l = s } };
    call(env, N_setDeviceModel, cls, a);
}

J(void, ZombieCafeAndroid_setVanityString)(JNIEnv *env, jclass cls, jstring s)
{
    jvalue a[1] = { { .l = s } };
    call(env, N_setVanityString, cls, a);
}

J(void, ZombieCafeAndroid_updateAccelerometer)(JNIEnv *env, jclass cls, jfloat x, jfloat y, jfloat z)
{
    jvalue a[3] = { { .f = x }, { .f = y }, { .f = z } };
    call(env, N_updateAccelerometer, cls, a);
}

/* Diagnostics for the host harness. */
JNIEXPORT void JNICALL zc_debug_dump_stats(void)
{
    zc_log(ZC_LOG_INFO, "guest instructions retired on this thread: %llu",
           (unsigned long long)zc_thread_current()->cpu.icount);
    zc_hle_dump_stats();
    zc_jni_dump_stats();
    zc_profile_dump(&game_lib, 30);
}

/* Harness hook: 0 off, 1 record calls silently, 2 log first calls. */
JNIEXPORT void JNICALL zc_debug_trace(int mode)
{
    zc_trace_new_calls(&game_lib, mode);
}
