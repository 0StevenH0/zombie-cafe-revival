/*
 * JNI for the guest: a JNIEnv/JavaVM in guest memory whose function tables
 * are host-call thunks forwarding to the real (64-bit) JNI.
 *
 * Guest code only ever holds 32-bit handles: local references are indices
 * into a per-thread table that is truncated when the native call that
 * created them returns, global references index a shared table. Method and
 * field IDs index tables that also remember the signature, so variadic
 * Call*Method arguments can be decoded from guest registers and stack.
 */
#ifndef ZC_JNI_BRIDGE_H
#define ZC_JNI_BRIDGE_H

#include <jni.h>

#include "runtime.h"

int zc_jni_init(JavaVM *vm, JNIEnv *env);
uint32_t zc_jni_guest_env(void);
uint32_t zc_jni_guest_vm(void);
JavaVM *zc_jni_host_vm(void);

/* Local-reference frames around a Java->guest native call. */
void zc_jni_push_frame(zc_thread *t);
void zc_jni_pop_frame(zc_thread *t);
uint32_t zc_jni_to_guest(zc_thread *t, jobject o);
jobject zc_jni_to_host(zc_thread *t, uint32_t h);
void zc_jni_dump_stats(void);

/* Calls guest native `fn` for a Java native method: `params` holds the Java
   parameter type codes (ZBCSIJFDL) and `ret` the return code (V for void). */
jvalue zc_jni_invoke(JNIEnv *env, uint32_t fn, jobject self, const char *params, char ret, const jvalue *args);

#endif
