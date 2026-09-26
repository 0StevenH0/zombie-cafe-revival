/* Native side of test/harness/.../Harness.java: software-renderer control and stats. */
#include <jni.h>
#include <stdint.h>

#include "../gl_functions.h"
#include "../mem.h"
#include "../runtime.h"

void softgl_init(int w, int h);
void softgl_capture(int on);
int softgl_write_png(const char *path);
void softgl_upload(GLuint id, int w, int h, const uint32_t *argb);
void zc_debug_dump_stats(void);
void zc_debug_trace(int mode);
extern uint64_t hostgl_calls, hostgl_draws, hostgl_vertices;

extern void glBlendFunc(GLenum, GLenum);
extern void glEnable(GLenum);
extern void glMatrixMode(GLenum);
extern void glLoadIdentity(void);
extern void glRotatef(GLfloat, GLfloat, GLfloat, GLfloat);
extern void glOrthof(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat);
extern void glScalef(GLfloat, GLfloat, GLfloat);

#define H(ret, name) JNIEXPORT ret JNICALL Java_com_capcom_zombiecafeandroid_Harness_##name

H(void, glInit)(JNIEnv *env, jclass c, jint w, jint h) { (void)env; (void)c; softgl_init(w, h); }
H(void, glCapture)(JNIEnv *env, jclass c, jboolean on) { (void)env; (void)c; softgl_capture(on); }

H(jboolean, glSave)(JNIEnv *env, jclass c, jstring path)
{
    (void)c;
    const char *p = (*env)->GetStringUTFChars(env, path, NULL);
    int rc = softgl_write_png(p);
    (*env)->ReleaseStringUTFChars(env, path, p);
    return rc == 0;
}

/* What CapcomRenderer.onSurfaceCreated does through GL10 on the device. */
H(void, setupProjection)(JNIEnv *env, jclass c, jint w, jint h, jfloat sx, jfloat sy)
{
    (void)env; (void)c;
    glBlendFunc(0x302, 0x303);
    glEnable(0x0BE2);
    glMatrixMode(0x1701);
    glLoadIdentity();
    glRotatef(180.0f, 1.0f, 0.0f, 0.0f);
    glOrthof(0.0f, (GLfloat)w, 0.0f, (GLfloat)h, 1.0f, -1.0f);
    glScalef(sx, sy, 0.0f);
    glMatrixMode(0x1700);
}

H(void, uploadTexture)(JNIEnv *env, jclass c, jint id, jint w, jint h, jintArray argb)
{
    (void)c;
    jint *px = (*env)->GetIntArrayElements(env, argb, NULL);
    softgl_upload((GLuint)id, w, h, (const uint32_t *)px);
    (*env)->ReleaseIntArrayElements(env, argb, px, JNI_ABORT);
}

H(jlongArray, stats)(JNIEnv *env, jclass c)
{
    (void)c;
    jlong v[5] = { (jlong)hostgl_calls, (jlong)hostgl_draws, (jlong)hostgl_vertices, (jlong)zc_heap_in_use(),
                   (jlong)zc_thread_current()->cpu.icount };
    jlongArray a = (*env)->NewLongArray(env, 5);
    (*env)->SetLongArrayRegion(env, a, 0, 5, v);
    return a;
}

H(void, dumpStats)(JNIEnv *env, jclass c) { (void)env; (void)c; zc_debug_dump_stats(); }

H(void, trace)(JNIEnv *env, jclass c, jint mode) { (void)env; (void)c; zc_debug_trace(mode); }
