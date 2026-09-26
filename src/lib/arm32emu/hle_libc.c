/*
 * Host implementations of the bionic (Android 2.x era, 32-bit) libc, libm,
 * liblog and C++ ABI imports of the engine. Everything the guest sees is
 * 32-bit: pointers are guest addresses, `long` and `time_t` are 4 bytes and
 * floating point arguments arrive in core registers (soft-float).
 */
#include "hle.h"

#include "mem.h"
#include "runtime.h"

/* ---------------------------------------------------------------- memory */

static int h_malloc(zc_cpu *c) { zc_ret(c, zc_malloc(zc_arg(c, 0))); return 0; }
static int h_free(zc_cpu *c) { zc_free(zc_arg(c, 0)); return 0; }
static int h_realloc(zc_cpu *c) { zc_ret(c, zc_realloc(zc_arg(c, 0), zc_arg(c, 1))); return 0; }

static int h_memcpy(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0), s = zc_arg(c, 1), n = zc_arg(c, 2);
    if (n)
        memcpy(zc_g2h(d), zc_g2h(s), n);
    zc_ret(c, d);
    return 0;
}
static int h_memmove(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0), s = zc_arg(c, 1), n = zc_arg(c, 2);
    if (n)
        memmove(zc_g2h(d), zc_g2h(s), n);
    zc_ret(c, d);
    return 0;
}
static int h_memset(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0), n = zc_arg(c, 2);
    if (n)
        memset(zc_g2h(d), (int)zc_arg(c, 1), n);
    zc_ret(c, d);
    return 0;
}
static int h_memcmp(zc_cpu *c)
{
    uint32_t n = zc_arg(c, 2);
    zc_ret(c, n ? (uint32_t)memcmp(zc_g2h(zc_arg(c, 0)), zc_g2h(zc_arg(c, 1)), n) : 0);
    return 0;
}

/* ---------------------------------------------------------------- strings */

static int h_strlen(zc_cpu *c) { zc_ret(c, (uint32_t)strlen(zc_str(zc_arg(c, 0)))); return 0; }
static int h_strcmp(zc_cpu *c) { zc_ret(c, (uint32_t)strcmp(zc_str(zc_arg(c, 0)), zc_str(zc_arg(c, 1)))); return 0; }
static int h_strncmp(zc_cpu *c)
{
    zc_ret(c, (uint32_t)strncmp(zc_str(zc_arg(c, 0)), zc_str(zc_arg(c, 1)), zc_arg(c, 2)));
    return 0;
}
static int h_strcpy(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0);
    const char *s = zc_str(zc_arg(c, 1));
    memmove(zc_g2h(d), s, strlen(s) + 1);
    zc_ret(c, d);
    return 0;
}
static int h_strncpy(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0);
    strncpy(zc_g2h(d), zc_str(zc_arg(c, 1)), zc_arg(c, 2));
    zc_ret(c, d);
    return 0;
}
static int h_strcat(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0);
    strcat(zc_g2h(d), zc_str(zc_arg(c, 1)));
    zc_ret(c, d);
    return 0;
}
static int h_strncat(zc_cpu *c)
{
    uint32_t d = zc_arg(c, 0);
    strncat(zc_g2h(d), zc_str(zc_arg(c, 1)), zc_arg(c, 2));
    zc_ret(c, d);
    return 0;
}
static int h_strchr(zc_cpu *c)
{
    const char *s = zc_str(zc_arg(c, 0));
    const char *r = strchr(s, (int)zc_arg(c, 1));
    zc_ret(c, r ? zc_h2g(r) : 0);
    return 0;
}
static int h_strstr(zc_cpu *c)
{
    const char *r = strstr(zc_str(zc_arg(c, 0)), zc_str(zc_arg(c, 1)));
    zc_ret(c, r ? zc_h2g(r) : 0);
    return 0;
}
static int h_strdup(zc_cpu *c) { zc_ret(c, zc_strdup_to_guest(zc_str(zc_arg(c, 0)))); return 0; }
static int h_atoi(zc_cpu *c) { zc_ret(c, (uint32_t)atoi(zc_str(zc_arg(c, 0)))); return 0; }
static int h_strtod(zc_cpu *c)
{
    const char *s = zc_str(zc_arg(c, 0));
    char *end;
    double d = strtod(s, &end);
    if (zc_arg(c, 1))
        zc_wr32(zc_arg(c, 1), zc_h2g(end));
    zc_retd(c, d);
    return 0;
}

/* ------------------------------------------------------ printf / scanf */

typedef struct {
    char *buf;
    size_t len, cap;
} sbuf;

static void sb_put(sbuf *b, const char *s, size_t n)
{
    if (b->len + n + 1 > b->cap) {
        size_t cap = b->cap ? b->cap * 2 : 256;
        while (cap < b->len + n + 1)
            cap *= 2;
        b->buf = realloc(b->buf, cap);
        b->cap = cap;
    }
    memcpy(b->buf + b->len, s, n);
    b->len += n;
    b->buf[b->len] = 0;
}

/* Formats a guest printf string into out. */
static void format_into(sbuf *out, const char *fmt, zc_va *va)
{
    char spec[48], tmp[512];
    while (*fmt) {
        const char *pct = strchr(fmt, '%');
        if (!pct) {
            sb_put(out, fmt, strlen(fmt));
            break;
        }
        sb_put(out, fmt, (size_t)(pct - fmt));
        const char *p = pct + 1;
        size_t sl = 0;
        spec[sl++] = '%';
        while (*p && strchr("-+ #0'", *p) && sl < 20)
            spec[sl++] = *p++;
        if (*p == '*') {
            sl += (size_t)snprintf(spec + sl, sizeof spec - sl, "%d", (int)zc_va_u32(va));
            p++;
        } else {
            while (*p >= '0' && *p <= '9' && sl < 30)
                spec[sl++] = *p++;
        }
        if (*p == '.') {
            spec[sl++] = *p++;
            if (*p == '*') {
                sl += (size_t)snprintf(spec + sl, sizeof spec - sl, "%d", (int)zc_va_u32(va));
                p++;
            } else {
                while (*p >= '0' && *p <= '9' && sl < 40)
                    spec[sl++] = *p++;
            }
        }
        int lng = 0; /* 0 int, 1 char, 2 short, 3 long long / intmax */
        for (;;) {
            if (*p == 'h') { lng = lng == 2 ? 1 : 2; p++; }
            else if (*p == 'l') { if (p[1] == 'l') { lng = 3; p += 2; } else { p++; } }
            else if (*p == 'q' || *p == 'j' || *p == 'L') { lng = *p == 'L' ? lng : 3; p++; }
            else if (*p == 'z' || *p == 't') { p++; }
            else break;
        }
        char conv = *p ? *p++ : 0;
        int n = 0;
        switch (conv) {
        case 'd': case 'i': {
            if (lng == 3) { spec[sl++] = 'l'; spec[sl++] = 'l'; spec[sl++] = conv; spec[sl] = 0;
                n = snprintf(tmp, sizeof tmp, spec, (long long)zc_va_u64(va)); }
            else { int32_t v = (int32_t)zc_va_u32(va);
                if (lng == 1) v = (int8_t)v; else if (lng == 2) v = (int16_t)v;
                spec[sl++] = conv; spec[sl] = 0; n = snprintf(tmp, sizeof tmp, spec, v); }
            break;
        }
        case 'u': case 'x': case 'X': case 'o': {
            if (lng == 3) { spec[sl++] = 'l'; spec[sl++] = 'l'; spec[sl++] = conv; spec[sl] = 0;
                n = snprintf(tmp, sizeof tmp, spec, (unsigned long long)zc_va_u64(va)); }
            else { uint32_t v = zc_va_u32(va);
                if (lng == 1) v = (uint8_t)v; else if (lng == 2) v = (uint16_t)v;
                spec[sl++] = conv; spec[sl] = 0; n = snprintf(tmp, sizeof tmp, spec, v); }
            break;
        }
        case 'c':
            spec[sl++] = 'c'; spec[sl] = 0;
            n = snprintf(tmp, sizeof tmp, spec, (int)zc_va_u32(va));
            break;
        case 'p':
            n = snprintf(tmp, sizeof tmp, "0x%x", zc_va_u32(va));
            break;
        case 's': {
            uint32_t s = zc_va_u32(va);
            spec[sl++] = 's'; spec[sl] = 0;
            const char *str = s ? (const char *)zc_g2h(s) : "(null)";
            int need = snprintf(NULL, 0, spec, str);
            if (need >= (int)sizeof tmp) {
                char *big = malloc((size_t)need + 1);
                snprintf(big, (size_t)need + 1, spec, str);
                sb_put(out, big, (size_t)need);
                free(big);
                n = -1;
            } else {
                n = snprintf(tmp, sizeof tmp, spec, str);
            }
            break;
        }
        case 'f': case 'F': case 'e': case 'E': case 'g': case 'G': case 'a': case 'A':
            spec[sl++] = conv; spec[sl] = 0;
            n = snprintf(tmp, sizeof tmp, spec, zc_va_double(va));
            break;
        case 'n': {
            uint32_t ptr = zc_va_u32(va);
            if (ptr) zc_wr32(ptr, (uint32_t)out->len);
            n = 0;
            break;
        }
        case '%':
            tmp[0] = '%';
            n = 1;
            break;
        default: /* unknown: copy verbatim */
            sb_put(out, pct, (size_t)(p - pct));
            n = -1;
            break;
        }
        if (n > 0)
            sb_put(out, tmp, (size_t)n < sizeof tmp ? (size_t)n : sizeof tmp - 1);
        fmt = p;
    }
    if (!out->buf)
        sb_put(out, "", 0);
}

char *zc_format_alloc(const char *fmt, zc_va *va)
{
    sbuf out = { 0 };
    format_into(&out, fmt, va);
    return out.buf;
}

static int h_sprintf(zc_cpu *c)
{
    zc_va va = zc_va_regs(c, 2);
    char *s = zc_format_alloc(zc_str(zc_arg(c, 1)), &va);
    size_t n = strlen(s);
    memcpy(zc_g2h(zc_arg(c, 0)), s, n + 1);
    free(s);
    zc_ret(c, (uint32_t)n);
    return 0;
}

static int h_snprintf(zc_cpu *c)
{
    zc_va va = zc_va_regs(c, 3);
    char *s = zc_format_alloc(zc_str(zc_arg(c, 2)), &va);
    size_t n = strlen(s), cap = zc_arg(c, 1);
    if (cap) {
        size_t k = n < cap - 1 ? n : cap - 1;
        memcpy(zc_g2h(zc_arg(c, 0)), s, k);
        zc_wr8(zc_arg(c, 0) + (uint32_t)k, 0);
    }
    free(s);
    zc_ret(c, (uint32_t)n);
    return 0;
}

static int is_space(int ch) { return ch == ' ' || (ch >= '\t' && ch <= '\r'); }

/* One guest sscanf, parsed item by item with the host's sscanf. */
static int guest_sscanf(const char *in, const char *fmt, zc_va *va)
{
    int assigned = 0, any_conv = 0;
    const char *s = in;
    while (*fmt) {
        if (is_space((unsigned char)*fmt)) {
            while (is_space((unsigned char)*fmt)) fmt++;
            while (is_space((unsigned char)*s)) s++;
            continue;
        }
        if (*fmt != '%' || fmt[1] == '%') {
            if (*fmt == '%') fmt++;
            if (*s != *fmt)
                return (!*s && !any_conv) ? -1 : assigned;
            s++;
            fmt++;
            continue;
        }
        const char *p = fmt + 1;
        int suppress = 0;
        if (*p == '*') { suppress = 1; p++; }
        char width[12];
        int wl = 0;
        while (*p >= '0' && *p <= '9' && wl < 10) width[wl++] = *p++;
        width[wl] = 0;
        int lng = 0; /* 1 hh, 2 h, 3 l, 4 ll */
        if (*p == 'h') { lng = 2; p++; if (*p == 'h') { lng = 1; p++; } }
        else if (*p == 'l') { lng = 3; p++; if (*p == 'l') { lng = 4; p++; } }
        else if (*p == 'L' || *p == 'q' || *p == 'j') { lng = 4; p++; }
        else if (*p == 'z' || *p == 't') { p++; }
        char conv = *p;
        const char *set_end = p;
        if (conv == '[') {
            set_end = p + 1;
            if (*set_end == '^') set_end++;
            if (*set_end == ']') set_end++;
            while (*set_end && *set_end != ']') set_end++;
        }
        if (!conv)
            break;
        fmt = (conv == '[' ? set_end : p) + 1;
        if (conv == 'n') {
            if (!suppress) zc_wr32(zc_va_u32(va), (uint32_t)(s - in));
            continue;
        }
        if (conv != 'c' && conv != '[')
            while (is_space((unsigned char)*s)) s++;
        if (!*s)
            return any_conv || assigned ? assigned : -1;
        char hf[64];
        int consumed = -1, r;
        any_conv = 1;
        switch (conv) {
        case 'd': case 'i': case 'u': case 'x': case 'X': case 'o': {
            long long v = 0;
            char cv = conv == 'X' ? 'x' : conv;
            snprintf(hf, sizeof hf, "%%%sll%c%%n", width, cv);
            r = sscanf(s, hf, &v, &consumed);
            if (r != 1 || consumed < 0) return assigned;
            if (!suppress) {
                uint32_t dst = zc_va_u32(va);
                if (lng == 1) zc_wr8(dst, (uint32_t)v);
                else if (lng == 2) zc_wr16(dst, (uint32_t)v);
                else if (lng == 4) { zc_wr32(dst, (uint32_t)v); zc_wr32(dst + 4, (uint32_t)((unsigned long long)v >> 32)); }
                else zc_wr32(dst, (uint32_t)v);
                assigned++;
            }
            break;
        }
        case 'f': case 'e': case 'g': case 'E': case 'G': case 'a': {
            double v = 0;
            snprintf(hf, sizeof hf, "%%%slf%%n", width);
            r = sscanf(s, hf, &v, &consumed);
            if (r != 1 || consumed < 0) return assigned;
            if (!suppress) {
                uint32_t dst = zc_va_u32(va);
                if (lng >= 3) { memcpy(zc_g2h(dst), &v, 8); }
                else { float f = (float)v; memcpy(zc_g2h(dst), &f, 4); }
                assigned++;
            }
            break;
        }
        case 's': case 'c': case '[': {
            char *tmpbuf = malloc(strlen(s) + 2);
            if (conv == '[')
                snprintf(hf, sizeof hf, "%%%s%.*s%%n", width, (int)(set_end - p + 1), p);
            else
                snprintf(hf, sizeof hf, "%%%s%c%%n", width, conv);
            r = sscanf(s, hf, tmpbuf, &consumed);
            if (r != 1 || consumed < 0) { free(tmpbuf); return assigned; }
            if (!suppress) {
                uint32_t dst = zc_va_u32(va);
                size_t len = conv == 'c' ? (size_t)(wl ? atoi(width) : 1) : strlen(tmpbuf) + 1;
                memcpy(zc_g2h(dst), tmpbuf, len);
                assigned++;
            }
            free(tmpbuf);
            break;
        }
        case 'p': {
            unsigned long long v = 0;
            r = sscanf(s, "%llx%n", &v, &consumed);
            if (r != 1 || consumed < 0) return assigned;
            if (!suppress) { zc_wr32(zc_va_u32(va), (uint32_t)v); assigned++; }
            break;
        }
        default:
            return assigned;
        }
        s += consumed;
    }
    return assigned;
}

static int h_sscanf(zc_cpu *c)
{
    zc_va va = zc_va_regs(c, 2);
    zc_ret(c, (uint32_t)guest_sscanf(zc_str(zc_arg(c, 0)), zc_str(zc_arg(c, 1)), &va));
    return 0;
}

/* -------------------------------------------------------------- stdio */

/* bionic's 32-bit FILE is 84 bytes; the getc() macro reads _r (offset 4) and
   _p (0), feof() reads _flags (12). */
#define GFILE_SIZE 84
#define GF_R 4
#define GF_FLAGS 12
#define GF_FILE 14
#define SEOF 0x0020
#define SERR 0x0040
#define MAX_FILES 64

static uint32_t guest_sF;
static struct { uint32_t g; FILE *h; } files[MAX_FILES];
static pthread_mutex_t files_lock = PTHREAD_MUTEX_INITIALIZER;

static FILE *host_file(uint32_t g, int *is_std)
{
    *is_std = 0;
    if (g >= guest_sF && g < guest_sF + 3 * GFILE_SIZE) {
        *is_std = 1 + (int)((g - guest_sF) / GFILE_SIZE); /* 1 stdin, 2 stdout, 3 stderr */
        return NULL;
    }
    for (int i = 0; i < MAX_FILES; i++)
        if (files[i].g == g)
            return files[i].h;
    return NULL;
}

static void set_gflag(uint32_t g, uint32_t flag)
{
    zc_wr16(g + GF_FLAGS, zc_rd16(g + GF_FLAGS) | flag);
}

static void log_text(int std, const char *s)
{
    zc_log(std == 3 ? ZC_LOG_WARN : ZC_LOG_INFO, "guest: %s", s);
}

static int h_fopen(zc_cpu *c)
{
    const char *path = zc_str(zc_arg(c, 0)), *mode = zc_str(zc_arg(c, 1));
    FILE *h = fopen(path, mode);
    zc_log(ZC_LOG_DEBUG, "fopen(%s, %s) -> %s", path, mode, h ? "ok" : "fail");
    if (!h) {
        zc_ret(c, 0);
        return 0;
    }
    uint32_t g = zc_calloc(1, GFILE_SIZE);
    zc_wr16(g + GF_FLAGS, 0x0010); /* any nonzero value marks the FILE live */
    zc_wr16(g + GF_FILE, 3);
    int slot = -1;
    pthread_mutex_lock(&files_lock);
    for (int i = 0; i < MAX_FILES && slot < 0; i++)
        if (!files[i].g) {
            files[i].g = g;
            files[i].h = h;
            slot = i;
        }
    pthread_mutex_unlock(&files_lock);
    if (slot < 0) {
        zc_log(ZC_LOG_ERROR, "too many open guest files");
        fclose(h);
        zc_free(g);
        g = 0;
    }
    zc_ret(c, g);
    return 0;
}

static int h_fclose(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    int rc = -1;
    pthread_mutex_lock(&files_lock);
    for (int i = 0; i < MAX_FILES; i++)
        if (files[i].g == g) {
            rc = fclose(files[i].h);
            files[i].g = 0;
            files[i].h = NULL;
            break;
        }
    pthread_mutex_unlock(&files_lock);
    if (rc != -1)
        zc_free(g);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_fread(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 3);
    int std;
    FILE *h = host_file(g, &std);
    if (!h) { zc_ret(c, 0); return 0; }
    size_t size = zc_arg(c, 1), n = zc_arg(c, 2);
    size_t got = (size && n) ? fread(zc_g2h(zc_arg(c, 0)), size, n, h) : 0;
    if (got < n) {
        if (feof(h)) set_gflag(g, SEOF);
        if (ferror(h)) set_gflag(g, SERR);
    }
    zc_ret(c, (uint32_t)got);
    return 0;
}

static int h_fwrite(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 3);
    int std;
    FILE *h = host_file(g, &std);
    size_t size = zc_arg(c, 1), n = zc_arg(c, 2);
    if (std) {
        size_t total = size * n;
        char *s = malloc(total + 1);
        memcpy(s, zc_g2h(zc_arg(c, 0)), total);
        s[total] = 0;
        log_text(std, s);
        free(s);
        zc_ret(c, (uint32_t)n);
        return 0;
    }
    zc_ret(c, h && size && n ? (uint32_t)fwrite(zc_g2h(zc_arg(c, 0)), size, n, h) : 0);
    return 0;
}

static int h_fseek(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    int std;
    FILE *h = host_file(g, &std);
    int rc = h ? fseek(h, (long)(int32_t)zc_arg(c, 1), (int)zc_arg(c, 2)) : -1;
    if (rc == 0)
        zc_wr16(g + GF_FLAGS, zc_rd16(g + GF_FLAGS) & ~SEOF);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_ftell(zc_cpu *c)
{
    int std;
    FILE *h = host_file(zc_arg(c, 0), &std);
    zc_ret(c, h ? (uint32_t)ftell(h) : 0xffffffffu);
    return 0;
}

static int h_fflush(zc_cpu *c)
{
    int std;
    FILE *h = zc_arg(c, 0) ? host_file(zc_arg(c, 0), &std) : NULL;
    zc_ret(c, h ? (uint32_t)fflush(h) : 0);
    return 0;
}

static int h_srget(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    int std;
    FILE *h = host_file(g, &std);
    zc_wr32(g + GF_R, 0); /* keep every getc() on this slow path */
    int ch = h ? fgetc(h) : EOF;
    if (ch == EOF)
        set_gflag(g, SEOF);
    zc_ret(c, (uint32_t)ch);
    return 0;
}

static int h_fprintf(zc_cpu *c)
{
    zc_va va = zc_va_regs(c, 2);
    char *s = zc_format_alloc(zc_str(zc_arg(c, 1)), &va);
    int std;
    FILE *h = host_file(zc_arg(c, 0), &std);
    if (std)
        log_text(std, s);
    else if (h)
        fputs(s, h);
    zc_ret(c, (uint32_t)strlen(s));
    free(s);
    return 0;
}

static int h_printf(zc_cpu *c)
{
    zc_va va = zc_va_regs(c, 1);
    char *s = zc_format_alloc(zc_str(zc_arg(c, 0)), &va);
    log_text(2, s);
    zc_ret(c, (uint32_t)strlen(s));
    free(s);
    return 0;
}

static int h_puts(zc_cpu *c)
{
    log_text(2, zc_str(zc_arg(c, 0)));
    zc_ret(c, 1);
    return 0;
}

static int h_putchar(zc_cpu *c) { zc_ret(c, zc_arg(c, 0) & 0xff); return 0; }
static int h_remove(zc_cpu *c) { zc_ret(c, (uint32_t)remove(zc_str(zc_arg(c, 0)))); return 0; }
static int h_unlink(zc_cpu *c) { zc_ret(c, (uint32_t)unlink(zc_str(zc_arg(c, 0)))); return 0; }
static int h_rename(zc_cpu *c) { zc_ret(c, (uint32_t)rename(zc_str(zc_arg(c, 0)), zc_str(zc_arg(c, 1)))); return 0; }
static int h_access(zc_cpu *c) { zc_ret(c, (uint32_t)access(zc_str(zc_arg(c, 0)), (int)zc_arg(c, 1))); return 0; }
static int h_mktemp(zc_cpu *c)
{
    mktemp(zc_g2h(zc_arg(c, 0)));
    zc_ret(c, zc_arg(c, 0));
    return 0;
}

/* ---------------------------------------------------------- stdlib */

static int h_getenv(zc_cpu *c) { zc_ret(c, 0); return 0; }
static int h_lrand48(zc_cpu *c) { zc_ret(c, (uint32_t)lrand48()); return 0; }
static int h_srand48(zc_cpu *c) { srand48((long)(int32_t)zc_arg(c, 0)); return 0; }
/* ZC_DETERMINISTIC=1 (tests): reproducible randomness so runs can be compared. */
static uint64_t det_state;
static int h_arc4random(zc_cpu *c)
{
    if (det_state) {
        det_state ^= det_state << 13;
        det_state ^= det_state >> 7;
        det_state ^= det_state << 17;
        zc_ret(c, (uint32_t)(det_state >> 16));
    } else {
        zc_ret(c, arc4random());
    }
    return 0;
}
static int h_ret0(zc_cpu *c) { zc_ret(c, 0); return 0; }

static int h_abort(zc_cpu *c)
{
    (void)c;
    zc_fatal("guest called abort() from %08x", c->r[14]);
}
static int h_exit(zc_cpu *c)
{
    zc_log(ZC_LOG_INFO, "guest called exit(%d)", (int)zc_arg(c, 0));
    exit((int)zc_arg(c, 0));
}
static int h_raise(zc_cpu *c) { zc_fatal("guest raised signal %d from %08x", (int)zc_arg(c, 0), c->r[14]); }
static int h_stack_chk_fail(zc_cpu *c) { zc_fatal("guest stack corruption detected (called from %08x)", c->r[14]); }
static int h_pure_virtual(zc_cpu *c) { zc_fatal("pure virtual call from %08x", c->r[14]); }

typedef struct {
    zc_cpu *c;
    uint32_t cmp;
} qctx;

static int qcompare(qctx *q, uint32_t a, uint32_t b)
{
    uint32_t w[2] = { a, b };
    return (int32_t)(uint32_t)zc_call(q->c, q->cmp, w, 2);
}

static void qswap(uint32_t a, uint32_t b, uint32_t size)
{
    uint8_t tmp[256];
    while (size) {
        uint32_t k = size < sizeof tmp ? size : (uint32_t)sizeof tmp;
        memcpy(tmp, zc_g2h(a), k);
        memcpy(zc_g2h(a), zc_g2h(b), k);
        memcpy(zc_g2h(b), tmp, k);
        a += k;
        b += k;
        size -= k;
    }
}

static void qsort_guest(qctx *q, uint32_t base, uint32_t n, uint32_t size)
{
    while (n > 8) {
        uint32_t mid = base + (n / 2) * size, last = base + (n - 1) * size;
        if (qcompare(q, mid, base) < 0) qswap(mid, base, size);
        if (qcompare(q, last, mid) < 0) {
            qswap(last, mid, size);
            if (qcompare(q, mid, base) < 0) qswap(mid, base, size);
        }
        qswap(mid, last, size); /* pivot at the end */
        uint32_t store = base;
        for (uint32_t i = 0; i < n - 1; i++) {
            uint32_t e = base + i * size;
            if (qcompare(q, e, last) < 0) {
                if (e != store) qswap(e, store, size);
                store += size;
            }
        }
        qswap(store, last, size);
        uint32_t left = (store - base) / size, right = n - left - 1;
        if (left < right) {
            qsort_guest(q, base, left, size);
            base = store + size;
            n = right;
        } else {
            qsort_guest(q, store + size, right, size);
            n = left;
        }
    }
    for (uint32_t i = 1; i < n; i++)
        for (uint32_t j = i; j > 0 && qcompare(q, base + j * size, base + (j - 1) * size) < 0; j--)
            qswap(base + j * size, base + (j - 1) * size, size);
}

static int h_qsort(zc_cpu *c)
{
    qctx q = { c, zc_arg(c, 3) };
    uint32_t base = zc_arg(c, 0), n = zc_arg(c, 1), size = zc_arg(c, 2);
    if (n > 1 && size)
        qsort_guest(&q, base, n, size);
    return 0;
}

/* setjmp saves r4-r11, sp and lr (bit 0 keeps the caller's Thumb state). */
static int h_setjmp(zc_cpu *c)
{
    uint32_t buf = zc_arg(c, 0);
    for (int i = 4; i <= 11; i++)
        zc_wr32(buf + 4u * (uint32_t)(i - 4), c->r[i]);
    zc_wr32(buf + 32, c->r[13]);
    zc_wr32(buf + 36, c->r[14]);
    zc_ret(c, 0);
    return 0;
}

static int h_longjmp(zc_cpu *c)
{
    uint32_t buf = zc_arg(c, 0), val = zc_arg(c, 1);
    for (int i = 4; i <= 11; i++)
        c->r[i] = zc_rd32(buf + 4u * (uint32_t)(i - 4));
    c->r[13] = zc_rd32(buf + 32);
    c->r[0] = val ? val : 1;
    zc_bx_write(c, zc_rd32(buf + 36));
    return 1;
}

/* ------------------------------------------------------------ time */

static int h_gettimeofday(zc_cpu *c)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    if (zc_arg(c, 0)) {
        zc_wr32(zc_arg(c, 0), (uint32_t)tv.tv_sec);
        zc_wr32(zc_arg(c, 0) + 4, (uint32_t)tv.tv_usec);
    }
    zc_ret(c, 0);
    return 0;
}

static uint32_t gmtime_buf, gmtime_zone;

static int h_gmtime(zc_cpu *c)
{
    time_t t = (time_t)(int32_t)zc_rd32(zc_arg(c, 0));
    struct tm tm;
    if (!gmtime_r(&t, &tm)) {
        zc_ret(c, 0);
        return 0;
    }
    int32_t f[9] = { tm.tm_sec, tm.tm_min, tm.tm_hour, tm.tm_mday, tm.tm_mon, tm.tm_year, tm.tm_wday, tm.tm_yday, tm.tm_isdst };
    for (int i = 0; i < 9; i++)
        zc_wr32(gmtime_buf + 4u * (uint32_t)i, (uint32_t)f[i]);
    zc_wr32(gmtime_buf + 36, 0);
    zc_wr32(gmtime_buf + 40, gmtime_zone);
    zc_ret(c, gmtime_buf);
    return 0;
}

/* ------------------------------------------------------------ math (soft-float) */

#define MATH_D1(name) static int h_##name(zc_cpu *c) { zc_retd(c, name(zc_argd(c, 0))); return 0; }
#define MATH_F1(name) static int h_##name(zc_cpu *c) { zc_retf(c, name(zc_argf(c, 0))); return 0; }
MATH_D1(acos)
MATH_D1(ceil)
MATH_D1(cos)
MATH_D1(sin)
MATH_D1(tan)
MATH_D1(sqrt)
MATH_F1(cosf)
MATH_F1(sinf)
MATH_F1(floorf)
MATH_F1(sqrtf)
static int h_pow(zc_cpu *c) { zc_retd(c, pow(zc_argd(c, 0), zc_argd(c, 2))); return 0; }

/* ------------------------------------------------------------ logging */

static int h_android_log_print(zc_cpu *c)
{
    zc_va va = zc_va_regs(c, 3);
    char *s = zc_format_alloc(zc_str(zc_arg(c, 2)), &va);
    const char *tag = zc_str(zc_arg(c, 1));
    zc_log((int)zc_arg(c, 0) >= ZC_LOG_WARN ? ZC_LOG_WARN : ZC_LOG_DEBUG, "%s: %s", tag ? tag : "", s);
    free(s);
    zc_ret(c, 1);
    return 0;
}

/* ------------------------------------------------------------ unwinding */

static int h_find_exidx(zc_cpu *c)
{
    uint32_t pc = zc_arg(c, 0), countp = zc_arg(c, 1);
    const zc_lib *lib = zc_find_lib(pc);
    if (!lib || !lib->exidx) {
        zc_ret(c, 0);
        return 0;
    }
    if (countp)
        zc_wr32(countp, lib->exidx_count);
    zc_ret(c, lib->exidx);
    return 0;
}

void zc_hle_libc_init(void)
{
    if (getenv("ZC_DETERMINISTIC"))
        det_state = 0x9E3779B97F4A7C15ull;
    guest_sF = zc_sys_alloc(3 * GFILE_SIZE, 8);
    for (int i = 0; i < 3; i++) {
        zc_wr16(guest_sF + (uint32_t)i * GFILE_SIZE + GF_FLAGS, i == 0 ? 0x0004 : 0x0008);
        zc_wr16(guest_sF + (uint32_t)i * GFILE_SIZE + GF_FILE, (uint32_t)i);
    }
    gmtime_buf = zc_sys_alloc(44, 8);
    gmtime_zone = zc_sys_strdup("GMT");
    uint32_t guard = zc_sys_alloc(4, 4);
    zc_wr32(guard, arc4random() | 0x100u);

    zc_hle_register_data("__sF", guest_sF);
    zc_hle_register_data("__stack_chk_guard", guard);

    static const struct { const char *name; zc_hle_fn fn; } fns[] = {
        { "malloc", h_malloc }, { "free", h_free }, { "realloc", h_realloc },
        { "memcpy", h_memcpy }, { "memmove", h_memmove }, { "memset", h_memset }, { "memcmp", h_memcmp },
        { "strlen", h_strlen }, { "strcmp", h_strcmp }, { "strncmp", h_strncmp }, { "strcpy", h_strcpy },
        { "strncpy", h_strncpy }, { "strcat", h_strcat }, { "strncat", h_strncat }, { "strchr", h_strchr },
        { "strstr", h_strstr }, { "strdup", h_strdup }, { "atoi", h_atoi }, { "strtod", h_strtod },
        { "sprintf", h_sprintf }, { "snprintf", h_snprintf }, { "sscanf", h_sscanf },
        { "fopen", h_fopen }, { "fclose", h_fclose }, { "fread", h_fread }, { "fwrite", h_fwrite },
        { "fseek", h_fseek }, { "ftell", h_ftell }, { "fflush", h_fflush }, { "__srget", h_srget },
        { "fprintf", h_fprintf }, { "printf", h_printf }, { "puts", h_puts }, { "putchar", h_putchar },
        { "remove", h_remove }, { "unlink", h_unlink }, { "rename", h_rename }, { "access", h_access },
        { "mktemp", h_mktemp }, { "getenv", h_getenv }, { "lrand48", h_lrand48 }, { "srand48", h_srand48 },
        { "arc4random", h_arc4random }, { "abort", h_abort }, { "exit", h_exit }, { "raise", h_raise },
        { "atexit", h_ret0 }, { "__aeabi_atexit", h_ret0 }, { "__cxa_finalize", h_ret0 },
        { "__cxa_pure_virtual", h_pure_virtual }, { "__stack_chk_fail", h_stack_chk_fail },
        { "qsort", h_qsort }, { "setjmp", h_setjmp }, { "longjmp", h_longjmp },
        { "gettimeofday", h_gettimeofday }, { "gmtime", h_gmtime },
        { "acos", h_acos }, { "ceil", h_ceil }, { "cos", h_cos }, { "sin", h_sin }, { "tan", h_tan },
        { "sqrt", h_sqrt }, { "pow", h_pow }, { "cosf", h_cosf }, { "sinf", h_sinf }, { "floorf", h_floorf },
        { "sqrtf", h_sqrtf },
        { "__android_log_print", h_android_log_print }, { "__gnu_Unwind_Find_exidx", h_find_exidx },
    };
    for (size_t i = 0; i < sizeof fns / sizeof fns[0]; i++)
        zc_hle_register(fns[i].name, fns[i].fn);
}
