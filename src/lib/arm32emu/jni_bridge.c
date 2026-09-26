#include "jni_bridge.h"

#include "mem.h"

#define JNI_TABLE_SIZE 233 /* JNI 1.6: reserved0 .. GetObjectRefType */
#define TAG_LOCAL 1u
#define TAG_GLOBAL 2u
#define TAG_WEAK 3u

struct zc_jni_thread {
    jobject *refs;
    uint32_t n, cap;
    uint32_t marks[128];
    int depth;
};

typedef struct {
    jmethodID id;
    char ret;
    char params[64];
    char name[48];
    uint64_t calls;
} gmethod;

typedef struct {
    jfieldID id;
    char type;
} gfield;

static JavaVM *host_vm;
static int trace_jni;
static uint32_t guest_env, guest_vm;
static pthread_mutex_t table_lock = PTHREAD_MUTEX_INITIALIZER;
static gmethod *methods;
static uint32_t nmethods, cap_methods;
static gfield *fields;
static uint32_t nfields, cap_fields;
static jobject *globals;
static uint32_t nglobals, cap_globals;
static jclass prim_array_class[8]; /* [Z [B [C [S [I [J [F [D */
static const char prim_codes[] = "ZBCSIJFD";
static const uint32_t prim_sizes[] = { 1, 1, 2, 2, 4, 8, 4, 8 };

JavaVM *zc_jni_host_vm(void) { return host_vm; }
uint32_t zc_jni_guest_env(void) { return guest_env; }
uint32_t zc_jni_guest_vm(void) { return guest_vm; }

/* --------------------------------------------------------------- handles */

static zc_jni_thread *jt(zc_thread *t)
{
    if (!t->jni)
        t->jni = calloc(1, sizeof(zc_jni_thread));
    return t->jni;
}

static JNIEnv *host_env(zc_thread *t)
{
    if (!t->host_env) {
        JNIEnv *env = NULL;
        if ((*host_vm)->GetEnv(host_vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK)
            (*host_vm)->AttachCurrentThread(host_vm, (void *)&env, NULL);
        t->host_env = env;
    }
    return t->host_env;
}

uint32_t zc_jni_to_guest(zc_thread *t, jobject o)
{
    if (!o)
        return 0;
    zc_jni_thread *j = jt(t);
    if (j->n == j->cap) {
        j->cap = j->cap ? j->cap * 2 : 256;
        j->refs = realloc(j->refs, j->cap * sizeof(jobject));
    }
    j->refs[j->n] = o;
    return ((++j->n) << 2) | TAG_LOCAL;
}

jobject zc_jni_to_host(zc_thread *t, uint32_t h)
{
    if (!h)
        return NULL;
    uint32_t idx = (h >> 2) - 1;
    switch (h & 3) {
    case TAG_LOCAL: {
        zc_jni_thread *j = jt(t);
        if (idx < j->n)
            return j->refs[idx];
        break;
    }
    case TAG_GLOBAL:
    case TAG_WEAK: {
        jobject o = NULL;
        pthread_mutex_lock(&table_lock);
        if (idx < nglobals)
            o = globals[idx];
        pthread_mutex_unlock(&table_lock);
        if (o)
            return o;
        break;
    }
    }
    zc_log(ZC_LOG_WARN, "guest used stale or invalid JNI reference %08x (pc %08x)", h, t->cpu.r[14]);
    return NULL;
}

void zc_jni_push_frame(zc_thread *t)
{
    zc_jni_thread *j = jt(t);
    if (j->depth >= 128)
        zc_fatal("JNI frames nested too deeply");
    j->marks[j->depth++] = j->n;
}

void zc_jni_pop_frame(zc_thread *t)
{
    zc_jni_thread *j = jt(t);
    if (j->depth > 0)
        j->n = j->marks[--j->depth];
}

static uint32_t add_global(jobject g, uint32_t tag)
{
    pthread_mutex_lock(&table_lock);
    uint32_t i;
    for (i = 0; i < nglobals && globals[i]; i++)
        ;
    if (i == nglobals) {
        if (nglobals == cap_globals) {
            cap_globals = cap_globals ? cap_globals * 2 : 256;
            globals = realloc(globals, cap_globals * sizeof(jobject));
        }
        nglobals++;
    }
    globals[i] = g;
    pthread_mutex_unlock(&table_lock);
    return ((i + 1) << 2) | tag;
}

static jobject drop_global(uint32_t h)
{
    jobject o = NULL;
    uint32_t idx = (h >> 2) - 1;
    pthread_mutex_lock(&table_lock);
    if (idx < nglobals) {
        o = globals[idx];
        globals[idx] = NULL;
    }
    pthread_mutex_unlock(&table_lock);
    return o;
}

static void parse_sig(const char *sig, gmethod *m)
{
    size_t n = 0;
    const char *p = sig && *sig == '(' ? sig + 1 : sig;
    while (p && *p && *p != ')' && n + 1 < sizeof m->params) {
        while (*p == '[')
            p++;
        if (p > sig && p[-1] == '[') { /* array: an object */
            if (*p == 'L')
                while (*p && *p != ';') p++;
            p++;
            m->params[n++] = 'L';
            continue;
        }
        if (*p == 'L') {
            while (*p && *p != ';') p++;
            p++;
            m->params[n++] = 'L';
            continue;
        }
        m->params[n++] = *p++;
    }
    m->params[n] = 0;
    m->ret = 'V';
    if (p && *p == ')') {
        p++;
        m->ret = (*p == '[' || *p == 'L') ? 'L' : *p;
    }
}

static uint32_t add_method(jmethodID id, const char *name, const char *sig)
{
    if (!id)
        return 0;
    pthread_mutex_lock(&table_lock);
    for (uint32_t i = 0; i < nmethods; i++)
        if (methods[i].id == id) {
            pthread_mutex_unlock(&table_lock);
            return i + 1;
        }
    if (nmethods == cap_methods) {
        cap_methods = cap_methods ? cap_methods * 2 : 128;
        methods = realloc(methods, cap_methods * sizeof(gmethod));
    }
    gmethod *m = &methods[nmethods];
    memset(m, 0, sizeof *m);
    m->id = id;
    snprintf(m->name, sizeof m->name, "%s", name ? name : "?");
    parse_sig(sig, m);
    uint32_t r = ++nmethods;
    pthread_mutex_unlock(&table_lock);
    return r;
}

static gmethod *get_method(uint32_t gid)
{
    gmethod *m = NULL;
    pthread_mutex_lock(&table_lock);
    if (gid && gid <= nmethods)
        m = &methods[gid - 1];
    pthread_mutex_unlock(&table_lock);
    if (!m)
        zc_fatal("guest used an unknown jmethodID %u", gid);
    return m;
}

static uint32_t add_field(jfieldID id, const char *sig)
{
    if (!id)
        return 0;
    pthread_mutex_lock(&table_lock);
    for (uint32_t i = 0; i < nfields; i++)
        if (fields[i].id == id) {
            pthread_mutex_unlock(&table_lock);
            return i + 1;
        }
    if (nfields == cap_fields) {
        cap_fields = cap_fields ? cap_fields * 2 : 64;
        fields = realloc(fields, cap_fields * sizeof(gfield));
    }
    fields[nfields].id = id;
    fields[nfields].type = (sig[0] == '[' || sig[0] == 'L') ? 'L' : sig[0];
    uint32_t r = ++nfields;
    pthread_mutex_unlock(&table_lock);
    return r;
}

static gfield *get_field(uint32_t gid)
{
    gfield *f = NULL;
    pthread_mutex_lock(&table_lock);
    if (gid && gid <= nfields)
        f = &fields[gid - 1];
    pthread_mutex_unlock(&table_lock);
    if (!f)
        zc_fatal("guest used an unknown jfieldID %u", gid);
    return f;
}

/* Host JNI calls run with the guest lock released (they may run Java). */
#define ENTER(c) zc_thread *t = (zc_thread *)(c)->user; JNIEnv *env = host_env(t); (void)env
#define H(h) zc_jni_to_host(t, (h))
#define G(o) zc_jni_to_guest(t, (o))
#define JCALL(stmt) do { int d_ = zc_release_all(); stmt; zc_reacquire(d_); } while (0)

/* ------------------------------------------------ argument conversion */

static jvalue arg_from_va(zc_thread *t, char type, zc_va *va)
{
    jvalue v;
    v.j = 0;
    switch (type) {
    case 'Z': v.z = (jboolean)zc_va_u32(va); break;
    case 'B': v.b = (jbyte)zc_va_u32(va); break;
    case 'C': v.c = (jchar)zc_va_u32(va); break;
    case 'S': v.s = (jshort)zc_va_u32(va); break;
    case 'I': v.i = (jint)zc_va_u32(va); break;
    case 'J': v.j = (jlong)zc_va_u64(va); break;
    case 'F': v.f = (jfloat)zc_va_double(va); break; /* promoted to double */
    case 'D': v.d = zc_va_double(va); break;
    default: v.l = zc_jni_to_host(t, zc_va_u32(va)); break;
    }
    return v;
}

static jvalue arg_from_jvalue(zc_thread *t, char type, uint32_t addr)
{
    jvalue v;
    v.j = 0;
    switch (type) {
    case 'Z': v.z = (jboolean)zc_rd8(addr); break;
    case 'B': v.b = (jbyte)zc_rd8(addr); break;
    case 'C': v.c = (jchar)zc_rd16(addr); break;
    case 'S': v.s = (jshort)zc_rd16(addr); break;
    case 'I': v.i = (jint)zc_rd32(addr); break;
    case 'J': v.j = (jlong)((uint64_t)zc_rd32(addr) | ((uint64_t)zc_rd32(addr + 4) << 32)); break;
    case 'F': { uint32_t b = zc_rd32(addr); memcpy(&v.f, &b, 4); break; }
    case 'D': { uint64_t b = (uint64_t)zc_rd32(addr) | ((uint64_t)zc_rd32(addr + 4) << 32); memcpy(&v.d, &b, 8); break; }
    default: v.l = zc_jni_to_host(t, zc_rd32(addr)); break;
    }
    return v;
}

enum { VAR_DOTS, VAR_V, VAR_A };

static void collect_args(zc_thread *t, zc_cpu *c, const gmethod *m, int variant, int first, jvalue *out)
{
    size_t n = strlen(m->params);
    if (variant == VAR_A) {
        uint32_t arr = zc_arg(c, first);
        for (size_t i = 0; i < n; i++)
            out[i] = arg_from_jvalue(t, m->params[i], arr + 8u * (uint32_t)i);
        return;
    }
    zc_va va = variant == VAR_V ? zc_va_mem(zc_arg(c, first)) : zc_va_regs(c, first);
    for (size_t i = 0; i < n; i++)
        out[i] = arg_from_va(t, m->params[i], &va);
}

static void ret_to_guest(zc_thread *t, zc_cpu *c, char type, jvalue v)
{
    switch (type) {
    case 'Z': zc_ret(c, v.z); break;
    case 'B': zc_ret(c, (uint32_t)(int32_t)v.b); break;
    case 'C': zc_ret(c, v.c); break;
    case 'S': zc_ret(c, (uint32_t)(int32_t)v.s); break;
    case 'I': zc_ret(c, (uint32_t)v.i); break;
    case 'J': zc_ret64(c, (uint64_t)v.j); break;
    case 'F': zc_retf(c, v.f); break;
    case 'D': zc_retd(c, v.d); break;
    case 'L': zc_ret(c, zc_jni_to_guest(t, v.l)); break;
    default: break;
    }
}

enum { K_VIRTUAL, K_NONVIRTUAL, K_STATIC, K_NEW };

static jvalue host_call(JNIEnv *env, int kind, char type, jobject obj, jclass cls, jmethodID id, const jvalue *a)
{
    jvalue r;
    r.j = 0;
    int d = zc_release_all();
#define CASE(code, T, field) \
    case code: \
        if (kind == K_VIRTUAL) r.field = (*env)->Call##T##MethodA(env, obj, id, a); \
        else if (kind == K_NONVIRTUAL) r.field = (*env)->CallNonvirtual##T##MethodA(env, obj, cls, id, a); \
        else r.field = (*env)->CallStatic##T##MethodA(env, cls, id, a); \
        break;
    switch (type) {
    CASE('Z', Boolean, z)
    CASE('B', Byte, b)
    CASE('C', Char, c)
    CASE('S', Short, s)
    CASE('I', Int, i)
    CASE('J', Long, j)
    CASE('F', Float, f)
    CASE('D', Double, d)
    CASE('L', Object, l)
    default:
        if (kind == K_VIRTUAL) (*env)->CallVoidMethodA(env, obj, id, a);
        else if (kind == K_NONVIRTUAL) (*env)->CallNonvirtualVoidMethodA(env, obj, cls, id, a);
        else (*env)->CallStaticVoidMethodA(env, cls, id, a);
        break;
    }
#undef CASE
    zc_reacquire(d);
    return r;
}

static int do_call(zc_cpu *c, int kind, char type, int variant)
{
    ENTER(c);
    uint32_t obj = 0, cls = 0, mid;
    int first;
    switch (kind) {
    case K_VIRTUAL: obj = zc_arg(c, 1); mid = zc_arg(c, 2); first = 3; break;
    case K_NONVIRTUAL: obj = zc_arg(c, 1); cls = zc_arg(c, 2); mid = zc_arg(c, 3); first = 4; break;
    default: cls = zc_arg(c, 1); mid = zc_arg(c, 2); first = 3; break;
    }
    gmethod *m = get_method(mid);
    m->calls++;
    if (trace_jni)
        zc_log(ZC_LOG_INFO, "jni call %s (from %08x)", m->name, c->r[14]);
    jvalue args[64];
    collect_args(t, c, m, variant, first, args);
    if (kind == K_NEW) {
        jobject o;
        JCALL(o = (*env)->NewObjectA(env, H(cls), m->id, args));
        zc_ret(c, G(o));
        return 0;
    }
    jvalue r = host_call(env, kind, type, H(obj), H(cls), m->id, args);
    ret_to_guest(t, c, type, r);
    return 0;
}

#define CALL_FAMILY(Name, code) \
    static int h_Call##Name##Method(zc_cpu *c) { return do_call(c, K_VIRTUAL, code, VAR_DOTS); } \
    static int h_Call##Name##MethodV(zc_cpu *c) { return do_call(c, K_VIRTUAL, code, VAR_V); } \
    static int h_Call##Name##MethodA(zc_cpu *c) { return do_call(c, K_VIRTUAL, code, VAR_A); } \
    static int h_CallNonvirtual##Name##Method(zc_cpu *c) { return do_call(c, K_NONVIRTUAL, code, VAR_DOTS); } \
    static int h_CallNonvirtual##Name##MethodV(zc_cpu *c) { return do_call(c, K_NONVIRTUAL, code, VAR_V); } \
    static int h_CallNonvirtual##Name##MethodA(zc_cpu *c) { return do_call(c, K_NONVIRTUAL, code, VAR_A); } \
    static int h_CallStatic##Name##Method(zc_cpu *c) { return do_call(c, K_STATIC, code, VAR_DOTS); } \
    static int h_CallStatic##Name##MethodV(zc_cpu *c) { return do_call(c, K_STATIC, code, VAR_V); } \
    static int h_CallStatic##Name##MethodA(zc_cpu *c) { return do_call(c, K_STATIC, code, VAR_A); }
CALL_FAMILY(Object, 'L')
CALL_FAMILY(Boolean, 'Z')
CALL_FAMILY(Byte, 'B')
CALL_FAMILY(Char, 'C')
CALL_FAMILY(Short, 'S')
CALL_FAMILY(Int, 'I')
CALL_FAMILY(Long, 'J')
CALL_FAMILY(Float, 'F')
CALL_FAMILY(Double, 'D')
CALL_FAMILY(Void, 'V')

static int h_NewObject(zc_cpu *c) { return do_call(c, K_NEW, 'L', VAR_DOTS); }
static int h_NewObjectV(zc_cpu *c) { return do_call(c, K_NEW, 'L', VAR_V); }
static int h_NewObjectA(zc_cpu *c) { return do_call(c, K_NEW, 'L', VAR_A); }

/* ---------------------------------------------------------------- fields */

static jvalue field_value(zc_cpu *c, char type, int first)
{
    jvalue v;
    v.j = 0;
    zc_va va = zc_va_regs(c, first);
    switch (type) {
    case 'J': v.j = (jlong)zc_va_u64(&va); break;
    case 'D': { uint64_t b = zc_va_u64(&va); memcpy(&v.d, &b, 8); break; }
    case 'F': { uint32_t b = zc_va_u32(&va); memcpy(&v.f, &b, 4); break; }
    default: v.i = (jint)zc_va_u32(&va); break;
    }
    return v;
}

#define FIELD_FAMILY(Name, code, field) \
    static int h_Get##Name##Field(zc_cpu *c) \
    { \
        ENTER(c); \
        jvalue v; \
        JCALL(v.field = (*env)->Get##Name##Field(env, H(zc_arg(c, 1)), get_field(zc_arg(c, 2))->id)); \
        ret_to_guest(t, c, code, v); \
        return 0; \
    } \
    static int h_GetStatic##Name##Field(zc_cpu *c) \
    { \
        ENTER(c); \
        jvalue v; \
        JCALL(v.field = (*env)->GetStatic##Name##Field(env, H(zc_arg(c, 1)), get_field(zc_arg(c, 2))->id)); \
        ret_to_guest(t, c, code, v); \
        return 0; \
    } \
    static int h_Set##Name##Field(zc_cpu *c) \
    { \
        ENTER(c); \
        jvalue v = code == 'L' ? (jvalue){ .l = H(zc_arg(c, 3)) } : field_value(c, code, 3); \
        JCALL((*env)->Set##Name##Field(env, H(zc_arg(c, 1)), get_field(zc_arg(c, 2))->id, v.field)); \
        return 0; \
    } \
    static int h_SetStatic##Name##Field(zc_cpu *c) \
    { \
        ENTER(c); \
        jvalue v = code == 'L' ? (jvalue){ .l = H(zc_arg(c, 3)) } : field_value(c, code, 3); \
        JCALL((*env)->SetStatic##Name##Field(env, H(zc_arg(c, 1)), get_field(zc_arg(c, 2))->id, v.field)); \
        return 0; \
    }
FIELD_FAMILY(Object, 'L', l)
FIELD_FAMILY(Boolean, 'Z', z)
FIELD_FAMILY(Byte, 'B', b)
FIELD_FAMILY(Char, 'C', c)
FIELD_FAMILY(Short, 'S', s)
FIELD_FAMILY(Int, 'I', i)
FIELD_FAMILY(Long, 'J', j)
FIELD_FAMILY(Float, 'F', f)
FIELD_FAMILY(Double, 'D', d)

static int h_GetFieldID(zc_cpu *c)
{
    ENTER(c);
    const char *sig = zc_str(zc_arg(c, 3));
    jfieldID id;
    JCALL(id = (*env)->GetFieldID(env, H(zc_arg(c, 1)), zc_str(zc_arg(c, 2)), sig));
    zc_ret(c, add_field(id, sig));
    return 0;
}

static int h_GetStaticFieldID(zc_cpu *c)
{
    ENTER(c);
    const char *sig = zc_str(zc_arg(c, 3));
    jfieldID id;
    JCALL(id = (*env)->GetStaticFieldID(env, H(zc_arg(c, 1)), zc_str(zc_arg(c, 2)), sig));
    zc_ret(c, add_field(id, sig));
    return 0;
}

static int h_GetMethodID(zc_cpu *c)
{
    ENTER(c);
    const char *name = zc_str(zc_arg(c, 2)), *sig = zc_str(zc_arg(c, 3));
    jmethodID id;
    JCALL(id = (*env)->GetMethodID(env, H(zc_arg(c, 1)), name, sig));
    if (!id)
        zc_log(ZC_LOG_WARN, "GetMethodID(%s %s) failed", name, sig);
    zc_ret(c, add_method(id, name, sig));
    return 0;
}

static int h_GetStaticMethodID(zc_cpu *c)
{
    ENTER(c);
    const char *name = zc_str(zc_arg(c, 2)), *sig = zc_str(zc_arg(c, 3));
    jmethodID id;
    JCALL(id = (*env)->GetStaticMethodID(env, H(zc_arg(c, 1)), name, sig));
    if (!id)
        zc_log(ZC_LOG_WARN, "GetStaticMethodID(%s %s) failed", name, sig);
    zc_ret(c, add_method(id, name, sig));
    return 0;
}

/* ---------------------------------------------------------------- arrays */

static int prim_index(char code)
{
    const char *p = strchr(prim_codes, code);
    return p ? (int)(p - prim_codes) : -1;
}

static uint32_t elements_out(zc_thread *t, JNIEnv *env, jarray arr, int pi, uint32_t is_copy)
{
    jsize len;
    JCALL(len = arr ? (*env)->GetArrayLength(env, arr) : 0);
    (void)t;
    uint32_t bytes = (uint32_t)len * prim_sizes[pi];
    uint32_t buf = zc_malloc(bytes + 8); /* spare zero bytes past the end */
    if (!buf)
        return 0;
    memset(zc_g2h(buf + bytes), 0, 8);
    if (len) {
        switch (prim_codes[pi]) {
        case 'Z': JCALL((*env)->GetBooleanArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        case 'B': JCALL((*env)->GetByteArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        case 'C': JCALL((*env)->GetCharArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        case 'S': JCALL((*env)->GetShortArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        case 'I': JCALL((*env)->GetIntArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        case 'J': JCALL((*env)->GetLongArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        case 'F': JCALL((*env)->GetFloatArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        default: JCALL((*env)->GetDoubleArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
        }
    }
    if (is_copy)
        zc_wr8(is_copy, JNI_TRUE);
    return buf;
}

static void elements_back(JNIEnv *env, jarray arr, int pi, uint32_t buf, jint mode)
{
    if (!buf)
        return;
    if (arr && mode != JNI_ABORT) {
        jsize len;
        JCALL(len = (*env)->GetArrayLength(env, arr));
        if (len) {
            switch (prim_codes[pi]) {
            case 'Z': JCALL((*env)->SetBooleanArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            case 'B': JCALL((*env)->SetByteArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            case 'C': JCALL((*env)->SetCharArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            case 'S': JCALL((*env)->SetShortArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            case 'I': JCALL((*env)->SetIntArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            case 'J': JCALL((*env)->SetLongArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            case 'F': JCALL((*env)->SetFloatArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            default: JCALL((*env)->SetDoubleArrayRegion(env, arr, 0, len, zc_g2h(buf))); break;
            }
        }
    }
    if (mode != JNI_COMMIT)
        zc_free(buf);
}

#define ARRAY_FAMILY(Name, code, jtype) \
    static int h_New##Name##Array(zc_cpu *c) \
    { \
        ENTER(c); \
        jarray a; \
        JCALL(a = (*env)->New##Name##Array(env, (jsize)zc_arg(c, 1))); \
        zc_ret(c, G(a)); \
        return 0; \
    } \
    static int h_Get##Name##ArrayElements(zc_cpu *c) \
    { \
        ENTER(c); \
        zc_ret(c, elements_out(t, env, H(zc_arg(c, 1)), prim_index(code), zc_arg(c, 2))); \
        return 0; \
    } \
    static int h_Release##Name##ArrayElements(zc_cpu *c) \
    { \
        ENTER(c); \
        elements_back(env, H(zc_arg(c, 1)), prim_index(code), zc_arg(c, 2), (jint)zc_arg(c, 3)); \
        return 0; \
    } \
    static int h_Get##Name##ArrayRegion(zc_cpu *c) \
    { \
        ENTER(c); \
        JCALL((*env)->Get##Name##ArrayRegion(env, H(zc_arg(c, 1)), (jsize)zc_arg(c, 2), (jsize)zc_arg(c, 3), \
                                             (jtype *)zc_ptr(zc_arg(c, 4)))); \
        return 0; \
    } \
    static int h_Set##Name##ArrayRegion(zc_cpu *c) \
    { \
        ENTER(c); \
        JCALL((*env)->Set##Name##ArrayRegion(env, H(zc_arg(c, 1)), (jsize)zc_arg(c, 2), (jsize)zc_arg(c, 3), \
                                             (const jtype *)zc_ptr(zc_arg(c, 4)))); \
        return 0; \
    }
ARRAY_FAMILY(Boolean, 'Z', jboolean)
ARRAY_FAMILY(Byte, 'B', jbyte)
ARRAY_FAMILY(Char, 'C', jchar)
ARRAY_FAMILY(Short, 'S', jshort)
ARRAY_FAMILY(Int, 'I', jint)
ARRAY_FAMILY(Long, 'J', jlong)
ARRAY_FAMILY(Float, 'F', jfloat)
ARRAY_FAMILY(Double, 'D', jdouble)

static int array_kind(zc_thread *t, JNIEnv *env, jobject arr)
{
    (void)t;
    for (int i = 0; i < 8; i++) {
        jboolean is;
        JCALL(is = prim_array_class[i] && (*env)->IsInstanceOf(env, arr, prim_array_class[i]));
        if (is)
            return i;
    }
    return 1;
}

static int h_GetPrimitiveArrayCritical(zc_cpu *c)
{
    ENTER(c);
    jobject arr = H(zc_arg(c, 1));
    zc_ret(c, arr ? elements_out(t, env, arr, array_kind(t, env, arr), zc_arg(c, 2)) : 0);
    return 0;
}

static int h_ReleasePrimitiveArrayCritical(zc_cpu *c)
{
    ENTER(c);
    jobject arr = H(zc_arg(c, 1));
    elements_back(env, arr, arr ? array_kind(t, env, arr) : 1, zc_arg(c, 2), (jint)zc_arg(c, 3));
    return 0;
}

static int h_GetArrayLength(zc_cpu *c)
{
    ENTER(c);
    jsize n;
    JCALL(n = (*env)->GetArrayLength(env, H(zc_arg(c, 1))));
    zc_ret(c, (uint32_t)n);
    return 0;
}

static int h_NewObjectArray(zc_cpu *c)
{
    ENTER(c);
    jobjectArray a;
    JCALL(a = (*env)->NewObjectArray(env, (jsize)zc_arg(c, 1), H(zc_arg(c, 2)), H(zc_arg(c, 3))));
    zc_ret(c, G(a));
    return 0;
}

static int h_GetObjectArrayElement(zc_cpu *c)
{
    ENTER(c);
    jobject o;
    JCALL(o = (*env)->GetObjectArrayElement(env, H(zc_arg(c, 1)), (jsize)zc_arg(c, 2)));
    zc_ret(c, G(o));
    return 0;
}

static int h_SetObjectArrayElement(zc_cpu *c)
{
    ENTER(c);
    JCALL((*env)->SetObjectArrayElement(env, H(zc_arg(c, 1)), (jsize)zc_arg(c, 2), H(zc_arg(c, 3))));
    return 0;
}

/* --------------------------------------------------------------- strings */

static int h_NewStringUTF(zc_cpu *c)
{
    ENTER(c);
    const char *s = zc_str(zc_arg(c, 1));
    jstring r = NULL;
    if (s)
        JCALL(r = (*env)->NewStringUTF(env, s));
    zc_ret(c, G(r));
    return 0;
}

static int h_NewString(zc_cpu *c)
{
    ENTER(c);
    jstring r;
    JCALL(r = (*env)->NewString(env, zc_ptr(zc_arg(c, 1)), (jsize)zc_arg(c, 2)));
    zc_ret(c, G(r));
    return 0;
}

static int h_GetStringUTFChars(zc_cpu *c)
{
    ENTER(c);
    jstring s = H(zc_arg(c, 1));
    uint32_t g = 0;
    if (s) {
        const char *chars;
        JCALL(chars = (*env)->GetStringUTFChars(env, s, NULL));
        if (chars) {
            g = zc_strdup_to_guest(chars);
            JCALL((*env)->ReleaseStringUTFChars(env, s, chars));
        }
    }
    if (zc_arg(c, 2))
        zc_wr8(zc_arg(c, 2), JNI_TRUE);
    zc_ret(c, g);
    return 0;
}

static int h_ReleaseStringUTFChars(zc_cpu *c) { zc_free(zc_arg(c, 2)); return 0; }

static int h_GetStringChars(zc_cpu *c)
{
    ENTER(c);
    jstring s = H(zc_arg(c, 1));
    uint32_t g = 0;
    if (s) {
        jsize n;
        JCALL(n = (*env)->GetStringLength(env, s));
        g = zc_malloc(2u * (uint32_t)n + 2);
        if (g) {
            JCALL((*env)->GetStringRegion(env, s, 0, n, zc_g2h(g)));
            zc_wr16(g + 2u * (uint32_t)n, 0);
        }
    }
    if (zc_arg(c, 2))
        zc_wr8(zc_arg(c, 2), JNI_TRUE);
    zc_ret(c, g);
    return 0;
}

static int h_ReleaseStringChars(zc_cpu *c) { zc_free(zc_arg(c, 2)); return 0; }

static int h_GetStringLength(zc_cpu *c)
{
    ENTER(c);
    jsize n;
    JCALL(n = (*env)->GetStringLength(env, H(zc_arg(c, 1))));
    zc_ret(c, (uint32_t)n);
    return 0;
}

static int h_GetStringUTFLength(zc_cpu *c)
{
    ENTER(c);
    jsize n;
    JCALL(n = (*env)->GetStringUTFLength(env, H(zc_arg(c, 1))));
    zc_ret(c, (uint32_t)n);
    return 0;
}

static int h_GetStringRegion(zc_cpu *c)
{
    ENTER(c);
    JCALL((*env)->GetStringRegion(env, H(zc_arg(c, 1)), (jsize)zc_arg(c, 2), (jsize)zc_arg(c, 3), zc_ptr(zc_arg(c, 4))));
    return 0;
}

static int h_GetStringUTFRegion(zc_cpu *c)
{
    ENTER(c);
    JCALL((*env)->GetStringUTFRegion(env, H(zc_arg(c, 1)), (jsize)zc_arg(c, 2), (jsize)zc_arg(c, 3), zc_ptr(zc_arg(c, 4))));
    return 0;
}

/* ------------------------------------------------------ classes & refs */

static int h_GetVersion(zc_cpu *c) { zc_ret(c, JNI_VERSION_1_6); return 0; }

static int h_FindClass(zc_cpu *c)
{
    ENTER(c);
    const char *name = zc_str(zc_arg(c, 1));
    jclass k;
    JCALL(k = (*env)->FindClass(env, name));
    if (!k)
        zc_log(ZC_LOG_WARN, "FindClass(%s) failed", name);
    zc_ret(c, G(k));
    return 0;
}

static int h_GetSuperclass(zc_cpu *c)
{
    ENTER(c);
    jclass k;
    JCALL(k = (*env)->GetSuperclass(env, H(zc_arg(c, 1))));
    zc_ret(c, G(k));
    return 0;
}

static int h_IsAssignableFrom(zc_cpu *c)
{
    ENTER(c);
    jboolean r;
    JCALL(r = (*env)->IsAssignableFrom(env, H(zc_arg(c, 1)), H(zc_arg(c, 2))));
    zc_ret(c, r);
    return 0;
}

static int h_GetObjectClass(zc_cpu *c)
{
    ENTER(c);
    jclass k;
    JCALL(k = (*env)->GetObjectClass(env, H(zc_arg(c, 1))));
    zc_ret(c, G(k));
    return 0;
}

static int h_IsInstanceOf(zc_cpu *c)
{
    ENTER(c);
    jboolean r;
    JCALL(r = (*env)->IsInstanceOf(env, H(zc_arg(c, 1)), H(zc_arg(c, 2))));
    zc_ret(c, r);
    return 0;
}

static int h_AllocObject(zc_cpu *c)
{
    ENTER(c);
    jobject o;
    JCALL(o = (*env)->AllocObject(env, H(zc_arg(c, 1))));
    zc_ret(c, G(o));
    return 0;
}

static int h_NewGlobalRef(zc_cpu *c)
{
    ENTER(c);
    jobject o = H(zc_arg(c, 1)), g = NULL;
    if (o)
        JCALL(g = (*env)->NewGlobalRef(env, o));
    zc_ret(c, g ? add_global(g, TAG_GLOBAL) : 0);
    return 0;
}

static int h_DeleteGlobalRef(zc_cpu *c)
{
    ENTER(c);
    uint32_t h = zc_arg(c, 1);
    if ((h & 3) == TAG_GLOBAL) {
        jobject o = drop_global(h);
        if (o)
            JCALL((*env)->DeleteGlobalRef(env, o));
    }
    return 0;
}

static int h_NewWeakGlobalRef(zc_cpu *c)
{
    ENTER(c);
    jobject o = H(zc_arg(c, 1)), g = NULL;
    if (o)
        JCALL(g = (*env)->NewWeakGlobalRef(env, o));
    zc_ret(c, g ? add_global(g, TAG_WEAK) : 0);
    return 0;
}

static int h_DeleteWeakGlobalRef(zc_cpu *c)
{
    ENTER(c);
    uint32_t h = zc_arg(c, 1);
    if ((h & 3) == TAG_WEAK) {
        jobject o = drop_global(h);
        if (o)
            JCALL((*env)->DeleteWeakGlobalRef(env, o));
    }
    return 0;
}

static int h_DeleteLocalRef(zc_cpu *c)
{
    ENTER(c);
    uint32_t h = zc_arg(c, 1);
    if ((h & 3) == TAG_LOCAL) {
        zc_jni_thread *j = jt(t);
        uint32_t idx = (h >> 2) - 1;
        if (idx < j->n && j->refs[idx]) {
            JCALL((*env)->DeleteLocalRef(env, j->refs[idx]));
            j->refs[idx] = NULL;
        }
    }
    return 0;
}

static int h_NewLocalRef(zc_cpu *c)
{
    ENTER(c);
    jobject o = H(zc_arg(c, 1)), l = NULL;
    if (o)
        JCALL(l = (*env)->NewLocalRef(env, o));
    zc_ret(c, G(l));
    return 0;
}

static int h_IsSameObject(zc_cpu *c)
{
    ENTER(c);
    jboolean r;
    JCALL(r = (*env)->IsSameObject(env, H(zc_arg(c, 1)), H(zc_arg(c, 2))));
    zc_ret(c, r);
    return 0;
}

static int h_GetObjectRefType(zc_cpu *c)
{
    uint32_t h = zc_arg(c, 1);
    zc_ret(c, (h & 3) == TAG_LOCAL ? JNILocalRefType : (h & 3) == TAG_GLOBAL ? JNIGlobalRefType
             : (h & 3) == TAG_WEAK ? JNIWeakGlobalRefType : JNIInvalidRefType);
    return 0;
}

static int h_EnsureLocalCapacity(zc_cpu *c)
{
    ENTER(c);
    jint r;
    JCALL(r = (*env)->EnsureLocalCapacity(env, (jint)zc_arg(c, 1)));
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int h_PushLocalFrame(zc_cpu *c)
{
    ENTER(c);
    jint r;
    JCALL(r = (*env)->PushLocalFrame(env, (jint)zc_arg(c, 1)));
    if (r == 0)
        zc_jni_push_frame(t);
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int h_PopLocalFrame(zc_cpu *c)
{
    ENTER(c);
    jobject keep = H(zc_arg(c, 1)), r;
    zc_jni_pop_frame(t);
    JCALL(r = (*env)->PopLocalFrame(env, keep));
    zc_ret(c, G(r));
    return 0;
}

/* ------------------------------------------------------------ exceptions */

static int h_Throw(zc_cpu *c)
{
    ENTER(c);
    jint r;
    JCALL(r = (*env)->Throw(env, H(zc_arg(c, 1))));
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int h_ThrowNew(zc_cpu *c)
{
    ENTER(c);
    jint r;
    JCALL(r = (*env)->ThrowNew(env, H(zc_arg(c, 1)), zc_str(zc_arg(c, 2))));
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int h_ExceptionOccurred(zc_cpu *c)
{
    ENTER(c);
    jthrowable e;
    JCALL(e = (*env)->ExceptionOccurred(env));
    zc_ret(c, G(e));
    return 0;
}

static int h_ExceptionDescribe(zc_cpu *c) { ENTER(c); JCALL((*env)->ExceptionDescribe(env)); return 0; }
static int h_ExceptionClear(zc_cpu *c) { ENTER(c); JCALL((*env)->ExceptionClear(env)); return 0; }

static int h_ExceptionCheck(zc_cpu *c)
{
    ENTER(c);
    jboolean r;
    JCALL(r = (*env)->ExceptionCheck(env));
    zc_ret(c, r);
    return 0;
}

static int h_FatalError(zc_cpu *c) { zc_fatal("guest FatalError: %s", zc_str(zc_arg(c, 1))); }

/* ---------------------------------------------------------------- misc */

static int h_MonitorEnter(zc_cpu *c)
{
    ENTER(c);
    jint r;
    JCALL(r = (*env)->MonitorEnter(env, H(zc_arg(c, 1))));
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int h_MonitorExit(zc_cpu *c)
{
    ENTER(c);
    jint r;
    JCALL(r = (*env)->MonitorExit(env, H(zc_arg(c, 1))));
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int h_GetJavaVM(zc_cpu *c)
{
    if (zc_arg(c, 1))
        zc_wr32(zc_arg(c, 1), guest_vm);
    zc_ret(c, 0);
    return 0;
}

static int h_NewDirectByteBuffer(zc_cpu *c)
{
    ENTER(c);
    jobject b;
    uint64_t cap = zc_arg64(c, 2);
    JCALL(b = (*env)->NewDirectByteBuffer(env, zc_ptr(zc_arg(c, 1)), (jlong)cap));
    zc_ret(c, G(b));
    return 0;
}

static int h_GetDirectBufferAddress(zc_cpu *c)
{
    ENTER(c);
    void *p;
    JCALL(p = (*env)->GetDirectBufferAddress(env, H(zc_arg(c, 1))));
    uint8_t *u = p;
    zc_ret(c, (u >= zc_mem && u < zc_mem + (1ull << 32)) ? zc_h2g(p) : 0);
    return 0;
}

static int h_GetDirectBufferCapacity(zc_cpu *c)
{
    ENTER(c);
    jlong n;
    JCALL(n = (*env)->GetDirectBufferCapacity(env, H(zc_arg(c, 1))));
    zc_ret64(c, (uint64_t)n);
    return 0;
}

static int h_unsupported(zc_cpu *c)
{
    zc_fatal("guest called an unsupported JNI function (from %08x)", c->r[14]);
}

/* ----------------------------------------------------------- JavaVM */

static int vm_GetEnv(zc_cpu *c)
{
    zc_thread *t = c->user;
    JNIEnv *env = NULL;
    jint r = (*host_vm)->GetEnv(host_vm, (void **)&env, JNI_VERSION_1_6);
    if (r == JNI_OK) {
        if (!t->host_env)
            t->host_env = env;
        zc_wr32(zc_arg(c, 1), guest_env);
    }
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int vm_AttachCurrentThread(zc_cpu *c)
{
    zc_thread *t = c->user;
    JNIEnv *env = NULL;
    jint r = (*host_vm)->AttachCurrentThread(host_vm, (void *)&env, NULL);
    if (r == JNI_OK) {
        t->host_env = env;
        if (zc_arg(c, 1))
            zc_wr32(zc_arg(c, 1), guest_env);
    }
    zc_ret(c, (uint32_t)r);
    return 0;
}

static int vm_DetachCurrentThread(zc_cpu *c) { zc_ret(c, 0); return 0; }
static int vm_DestroyJavaVM(zc_cpu *c) { zc_ret(c, (uint32_t)JNI_ERR); return 0; }

/* ------------------------------------------------------------ tables */

#define E(name) { #name, h_##name }
#define CALL3(T) E(Call##T##Method), E(Call##T##MethodV), E(Call##T##MethodA)
#define NCALL3(T) E(CallNonvirtual##T##Method), E(CallNonvirtual##T##MethodV), E(CallNonvirtual##T##MethodA)
#define SCALL3(T) E(CallStatic##T##Method), E(CallStatic##T##MethodV), E(CallStatic##T##MethodA)
#define ALL_TYPES(M) M(Object), M(Boolean), M(Byte), M(Char), M(Short), M(Int), M(Long), M(Float), M(Double)
#define PRIM_TYPES(M) M(Boolean), M(Byte), M(Char), M(Short), M(Int), M(Long), M(Float), M(Double)
#define GETF(T) E(Get##T##Field)
#define SETF(T) E(Set##T##Field)
#define GETSF(T) E(GetStatic##T##Field)
#define SETSF(T) E(SetStatic##T##Field)
#define NEWA(T) E(New##T##Array)
#define GETAE(T) E(Get##T##ArrayElements)
#define RELAE(T) E(Release##T##ArrayElements)
#define GETAR(T) E(Get##T##ArrayRegion)
#define SETAR(T) E(Set##T##ArrayRegion)

typedef struct { const char *name; zc_hle_fn fn; } entry;

static const entry jni_table[JNI_TABLE_SIZE] = {
    { "reserved0", NULL }, { "reserved1", NULL }, { "reserved2", NULL }, { "reserved3", NULL },
    E(GetVersion), { "DefineClass", h_unsupported }, E(FindClass),
    { "FromReflectedMethod", h_unsupported }, { "FromReflectedField", h_unsupported },
    { "ToReflectedMethod", h_unsupported }, E(GetSuperclass), E(IsAssignableFrom),
    { "ToReflectedField", h_unsupported }, E(Throw), E(ThrowNew), E(ExceptionOccurred), E(ExceptionDescribe),
    E(ExceptionClear), E(FatalError), E(PushLocalFrame), E(PopLocalFrame), E(NewGlobalRef), E(DeleteGlobalRef),
    E(DeleteLocalRef), E(IsSameObject), E(NewLocalRef), E(EnsureLocalCapacity), E(AllocObject), E(NewObject),
    E(NewObjectV), E(NewObjectA), E(GetObjectClass), E(IsInstanceOf), E(GetMethodID),
    ALL_TYPES(CALL3), CALL3(Void),
    ALL_TYPES(NCALL3), NCALL3(Void),
    E(GetFieldID), ALL_TYPES(GETF), ALL_TYPES(SETF),
    E(GetStaticMethodID), ALL_TYPES(SCALL3), SCALL3(Void),
    E(GetStaticFieldID), ALL_TYPES(GETSF), ALL_TYPES(SETSF),
    E(NewString), E(GetStringLength), E(GetStringChars), E(ReleaseStringChars), E(NewStringUTF),
    E(GetStringUTFLength), E(GetStringUTFChars), E(ReleaseStringUTFChars), E(GetArrayLength), E(NewObjectArray),
    E(GetObjectArrayElement), E(SetObjectArrayElement),
    PRIM_TYPES(NEWA), PRIM_TYPES(GETAE), PRIM_TYPES(RELAE), PRIM_TYPES(GETAR), PRIM_TYPES(SETAR),
    { "RegisterNatives", h_unsupported }, { "UnregisterNatives", h_unsupported }, E(MonitorEnter), E(MonitorExit),
    E(GetJavaVM), E(GetStringRegion), E(GetStringUTFRegion), E(GetPrimitiveArrayCritical),
    E(ReleasePrimitiveArrayCritical), { "GetStringCritical", h_GetStringChars },
    { "ReleaseStringCritical", h_ReleaseStringChars }, E(NewWeakGlobalRef), E(DeleteWeakGlobalRef),
    E(ExceptionCheck), E(NewDirectByteBuffer), E(GetDirectBufferAddress), E(GetDirectBufferCapacity),
    E(GetObjectRefType),
};

int zc_jni_init(JavaVM *vm, JNIEnv *env)
{
    host_vm = vm;
    trace_jni = getenv("ZC_TRACE_JNI") != NULL;
    uint32_t table = zc_sys_alloc(4 * JNI_TABLE_SIZE, 8);
    for (int i = 0; i < JNI_TABLE_SIZE; i++) {
        if (!jni_table[i].name)
            zc_fatal("JNI table entry %d missing", i);
        if (jni_table[i].fn)
            zc_wr32(table + 4u * (uint32_t)i, zc_hle_thunk(jni_table[i].name, jni_table[i].fn));
    }
    guest_env = zc_sys_alloc(16, 8);
    zc_wr32(guest_env, table);

    static const entry vm_table[8] = {
        { "reserved0", NULL }, { "reserved1", NULL }, { "reserved2", NULL },
        { "DestroyJavaVM", vm_DestroyJavaVM }, { "AttachCurrentThread", vm_AttachCurrentThread },
        { "DetachCurrentThread", vm_DetachCurrentThread }, { "GetEnv", vm_GetEnv },
        { "AttachCurrentThreadAsDaemon", vm_AttachCurrentThread },
    };
    uint32_t vtable = zc_sys_alloc(4 * 8, 8);
    for (int i = 0; i < 8; i++)
        if (vm_table[i].fn)
            zc_wr32(vtable + 4u * (uint32_t)i, zc_hle_thunk(vm_table[i].name, vm_table[i].fn));
    guest_vm = zc_sys_alloc(16, 8);
    zc_wr32(guest_vm, vtable);

    static const char *const array_names[8] = { "[Z", "[B", "[C", "[S", "[I", "[J", "[F", "[D" };
    for (int i = 0; i < 8; i++) {
        jclass k = (*env)->FindClass(env, array_names[i]);
        if (k) {
            prim_array_class[i] = (*env)->NewGlobalRef(env, k);
            (*env)->DeleteLocalRef(env, k);
        } else {
            (*env)->ExceptionClear(env);
        }
    }
    return 0;
}

jvalue zc_jni_invoke(JNIEnv *env, uint32_t fn, jobject self, const char *params, char ret, const jvalue *args)
{
    zc_lock();
    zc_thread *t = zc_thread_current();
    void *saved_env = t->host_env;
    t->host_env = env;
    zc_jni_push_frame(t);

    uint32_t w[64];
    int n = 0;
    w[n++] = guest_env;
    w[n++] = zc_jni_to_guest(t, self);
    for (int i = 0; params[i] && n < 60; i++) {
        switch (params[i]) {
        case 'J': case 'D': {
            uint64_t v;
            memcpy(&v, &args[i], 8);
            if (n & 1) n++;
            w[n++] = (uint32_t)v;
            w[n++] = (uint32_t)(v >> 32);
            break;
        }
        case 'F': { uint32_t b; memcpy(&b, &args[i].f, 4); w[n++] = b; break; }
        case 'L': w[n++] = zc_jni_to_guest(t, args[i].l); break;
        case 'Z': w[n++] = args[i].z; break;
        case 'B': w[n++] = (uint32_t)(int32_t)args[i].b; break;
        case 'C': w[n++] = args[i].c; break;
        case 'S': w[n++] = (uint32_t)(int32_t)args[i].s; break;
        default: w[n++] = (uint32_t)args[i].i; break;
        }
    }
    uint64_t r = zc_call(&t->cpu, fn, w, n);

    jvalue out;
    out.j = 0;
    switch (ret) {
    case 'Z': out.z = (jboolean)(r & 0xff); break;
    case 'B': out.b = (jbyte)r; break;
    case 'C': out.c = (jchar)r; break;
    case 'S': out.s = (jshort)r; break;
    case 'I': out.i = (jint)r; break;
    case 'J': out.j = (jlong)r; break;
    case 'F': { uint32_t b = (uint32_t)r; memcpy(&out.f, &b, 4); break; }
    case 'D': memcpy(&out.d, &r, 8); break;
    case 'L': {
        jobject o = zc_jni_to_host(t, (uint32_t)r);
        out.l = o ? (*env)->NewLocalRef(env, o) : NULL;
        break;
    }
    default: break;
    }
    zc_jni_pop_frame(t);
    t->host_env = saved_env;
    zc_unlock();
    return out;
}

static int cmp_method_calls(const void *a, const void *b)
{
    const gmethod *x = *(const gmethod *const *)a, *y = *(const gmethod *const *)b;
    return x->calls < y->calls ? 1 : x->calls > y->calls ? -1 : 0;
}

void zc_jni_dump_stats(void)
{
    pthread_mutex_lock(&table_lock);
    gmethod **list = malloc(nmethods * sizeof *list);
    uint32_t n = 0;
    for (uint32_t i = 0; i < nmethods; i++)
        if (methods[i].calls)
            list[n++] = &methods[i];
    qsort(list, n, sizeof *list, cmp_method_calls);
    for (uint32_t i = 0; i < n && i < 25; i++)
        zc_log(ZC_LOG_INFO, "  %10llu  java %s", (unsigned long long)list[i]->calls, list[i]->name);
    free(list);
    pthread_mutex_unlock(&table_lock);
}
