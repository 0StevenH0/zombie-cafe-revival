/*
 * Minimal software OpenGL ES 1.x for the host harness: the fixed-function
 * subset the engine draws with (matrix stacks, client arrays, 2D textures,
 * MODULATE, alpha blending, triangles). Rasterizes only while capture is on
 * and writes PNG frame dumps, so emulator output can be inspected on the
 * build machine.
 */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#include "../gl_functions.h"

extern uint64_t hostgl_calls, hostgl_draws, hostgl_vertices;

typedef struct { float m[16]; } mat4;
typedef struct { int size; GLenum type; GLsizei stride; const uint8_t *ptr; int enabled; } carray;
typedef struct { int w, h; uint32_t *px; } texture;

static mat4 stacks[2][32];
static int depth[2];
static int mode; /* 0 modelview, 1 projection */
static float color[4] = { 1, 1, 1, 1 };
static carray vtx, col, tc[2];
static int client_unit, active_unit;
static GLuint bound[2];
static texture *textures;
static GLuint ntextures;
static int tex_enabled, blend_enabled;
static GLenum bsrc = 1, bdst = 0;
static float clear_rgba[4];
static int fb_w = 1200, fb_h = 540;
static uint32_t *fb;
static int capture;

static mat4 *top(void) { return &stacks[mode][depth[mode]]; }

static void mat_identity(mat4 *m)
{
    memset(m, 0, sizeof *m);
    m->m[0] = m->m[5] = m->m[10] = m->m[15] = 1;
}

static void mat_mul(mat4 *a, const mat4 *b) /* a = a * b (column-major) */
{
    mat4 r;
    for (int c = 0; c < 4; c++)
        for (int rr = 0; rr < 4; rr++) {
            float s = 0;
            for (int k = 0; k < 4; k++)
                s += a->m[k * 4 + rr] * b->m[c * 4 + k];
            r.m[c * 4 + rr] = s;
        }
    *a = r;
}

void softgl_init(int w, int h)
{
    fb_w = w;
    fb_h = h;
    free(fb);
    fb = calloc((size_t)w * (size_t)h, 4);
    for (int i = 0; i < 2; i++) {
        depth[i] = 0;
        mat_identity(&stacks[i][0]);
    }
}

void softgl_capture(int on) { capture = on; }

void softgl_upload(GLuint id, int w, int h, const uint32_t *argb)
{
    if (id >= ntextures) {
        GLuint n = id + 64;
        textures = realloc(textures, n * sizeof *textures);
        memset(textures + ntextures, 0, (n - ntextures) * sizeof *textures);
        ntextures = n;
    }
    texture *t = &textures[id];
    free(t->px);
    t->w = w;
    t->h = h;
    t->px = malloc((size_t)w * (size_t)h * 4);
    for (int i = 0; i < w * h; i++) {
        uint32_t p = argb[i]; /* Java ARGB -> RGBA bytes in memory */
        uint8_t a = p >> 24, r = p >> 16, g = p >> 8, b = p;
        t->px[i] = (uint32_t)r | ((uint32_t)g << 8) | ((uint32_t)b << 16) | ((uint32_t)a << 24);
    }
}

/* ---- GL entry points (fixed function) ---- */

void glMatrixMode(GLenum m) { hostgl_calls++; mode = m == 0x1701 ? 1 : 0; }
void glLoadIdentity(void) { hostgl_calls++; mat_identity(top()); }
void glLoadMatrixf(const GLfloat *m) { hostgl_calls++; memcpy(top()->m, m, 64); }
void glPushMatrix(void)
{
    hostgl_calls++;
    if (depth[mode] < 31) {
        stacks[mode][depth[mode] + 1] = stacks[mode][depth[mode]];
        depth[mode]++;
    }
}
void glPopMatrix(void) { hostgl_calls++; if (depth[mode] > 0) depth[mode]--; }
void glTranslatef(GLfloat x, GLfloat y, GLfloat z)
{
    hostgl_calls++;
    mat4 t;
    mat_identity(&t);
    t.m[12] = x; t.m[13] = y; t.m[14] = z;
    mat_mul(top(), &t);
}
void glScalef(GLfloat x, GLfloat y, GLfloat z)
{
    hostgl_calls++;
    mat4 t;
    mat_identity(&t);
    t.m[0] = x; t.m[5] = y; t.m[10] = z;
    mat_mul(top(), &t);
}
void glRotatef(GLfloat a, GLfloat x, GLfloat y, GLfloat z)
{
    hostgl_calls++;
    float len = sqrtf(x * x + y * y + z * z);
    if (len == 0) return;
    x /= len; y /= len; z /= len;
    float r = a * 3.14159265f / 180.0f, c = cosf(r), s = sinf(r), ic = 1 - c;
    mat4 t;
    mat_identity(&t);
    t.m[0] = x * x * ic + c;     t.m[4] = x * y * ic - z * s; t.m[8] = x * z * ic + y * s;
    t.m[1] = y * x * ic + z * s; t.m[5] = y * y * ic + c;     t.m[9] = y * z * ic - x * s;
    t.m[2] = x * z * ic - y * s; t.m[6] = y * z * ic + x * s; t.m[10] = z * z * ic + c;
    mat_mul(top(), &t);
}
void glOrthof(GLfloat l, GLfloat r, GLfloat b, GLfloat t, GLfloat n, GLfloat f)
{
    hostgl_calls++;
    mat4 o;
    mat_identity(&o);
    o.m[0] = 2 / (r - l); o.m[5] = 2 / (t - b); o.m[10] = -2 / (f - n);
    o.m[12] = -(r + l) / (r - l); o.m[13] = -(t + b) / (t - b); o.m[14] = -(f + n) / (f - n);
    mat_mul(top(), &o);
}
void glColor4f(GLfloat r, GLfloat g, GLfloat b, GLfloat a)
{
    hostgl_calls++;
    color[0] = r; color[1] = g; color[2] = b; color[3] = a;
}
void glColor4ub(GLubyte r, GLubyte g, GLubyte b, GLubyte a)
{
    glColor4f(r / 255.f, g / 255.f, b / 255.f, a / 255.f);
}
void glClearColor(GLfloat r, GLfloat g, GLfloat b, GLfloat a)
{
    hostgl_calls++;
    clear_rgba[0] = r; clear_rgba[1] = g; clear_rgba[2] = b; clear_rgba[3] = a;
}
static void do_clear(void)
{
    if (!capture || !fb) return;
    uint32_t v = (uint32_t)(clear_rgba[0] * 255) | ((uint32_t)(clear_rgba[1] * 255) << 8) |
                 ((uint32_t)(clear_rgba[2] * 255) << 16) | 0xff000000u;
    for (int i = 0; i < fb_w * fb_h; i++) fb[i] = v;
}
void softgl_clear_hook(void) { do_clear(); }

static void set_enable(GLenum cap, int on)
{
    if (cap == 0x0DE1) tex_enabled = on;      /* GL_TEXTURE_2D */
    else if (cap == 0x0BE2) blend_enabled = on; /* GL_BLEND */
}
void glEnable(GLenum cap) { hostgl_calls++; set_enable(cap, 1); }
void glDisable(GLenum cap) { hostgl_calls++; set_enable(cap, 0); }
void glBlendFunc_soft(GLenum s, GLenum d) { bsrc = s; bdst = d; }

static carray *client(GLenum a)
{
    switch (a) {
    case 0x8074: return &vtx;              /* GL_VERTEX_ARRAY */
    case 0x8076: return &col;              /* GL_COLOR_ARRAY */
    case 0x8078: return &tc[client_unit];  /* GL_TEXTURE_COORD_ARRAY */
    default: return NULL;
    }
}
void glEnableClientState(GLenum a) { hostgl_calls++; carray *c = client(a); if (c) c->enabled = 1; }
void glDisableClientState(GLenum a) { hostgl_calls++; carray *c = client(a); if (c) c->enabled = 0; }
void glClientActiveTexture_soft(GLenum u) { client_unit = (u - 0x84C0) & 1; }
void glActiveTexture_soft(GLenum u) { active_unit = (u - 0x84C0) & 1; }
void glVertexPointer(GLint s, GLenum t, GLsizei st, const void *p) { hostgl_calls++; vtx.size = s; vtx.type = t; vtx.stride = st; vtx.ptr = p; }
void glColorPointer(GLint s, GLenum t, GLsizei st, const void *p) { hostgl_calls++; col.size = s; col.type = t; col.stride = st; col.ptr = p; }
void glTexCoordPointer(GLint s, GLenum t, GLsizei st, const void *p)
{
    hostgl_calls++;
    carray *c = &tc[client_unit];
    c->size = s; c->type = t; c->stride = st; c->ptr = p;
}
void glBindTexture(GLenum target, GLuint t) { (void)target; hostgl_calls++; bound[active_unit] = t; }

static int type_size(GLenum t)
{
    switch (t) {
    case 0x1400: case 0x1401: return 1; /* BYTE, UNSIGNED_BYTE */
    case 0x1402: case 0x1403: return 2; /* SHORT, UNSIGNED_SHORT */
    default: return 4;                  /* FLOAT, FIXED */
    }
}

static float fetch(const carray *a, int i, int k, int norm)
{
    int ts = type_size(a->type);
    int stride = a->stride ? a->stride : ts * a->size;
    const uint8_t *p = a->ptr + (size_t)i * (size_t)stride + (size_t)k * (size_t)ts;
    switch (a->type) {
    case 0x1400: return norm ? (int8_t)*p / 127.f : (int8_t)*p;
    case 0x1401: return norm ? *p / 255.f : *p;
    case 0x1402: { int16_t v; memcpy(&v, p, 2); return norm ? v / 32767.f : v; }
    case 0x1403: { uint16_t v; memcpy(&v, p, 2); return norm ? v / 65535.f : v; }
    case 0x140C: { int32_t v; memcpy(&v, p, 4); return v / 65536.f; }
    default: { float v; memcpy(&v, p, 4); return v; }
    }
}

typedef struct { float x, y, u, v, r, g, b, a; } vert;

static void transform(int i, vert *o)
{
    float in[4] = { 0, 0, 0, 1 };
    for (int k = 0; k < vtx.size && k < 4; k++)
        in[k] = fetch(&vtx, i, k, 0);
    mat4 mvp = stacks[1][depth[1]];
    mat_mul(&mvp, &stacks[0][depth[0]]);
    float cl[4];
    for (int r = 0; r < 4; r++)
        cl[r] = mvp.m[r] * in[0] + mvp.m[4 + r] * in[1] + mvp.m[8 + r] * in[2] + mvp.m[12 + r] * in[3];
    float w = cl[3] ? cl[3] : 1;
    o->x = (cl[0] / w + 1) * 0.5f * (float)fb_w;
    o->y = (1 - cl[1] / w) * 0.5f * (float)fb_h;
    o->u = o->v = 0;
    if (tc[0].enabled && tc[0].ptr) {
        o->u = fetch(&tc[0], i, 0, 0);
        o->v = fetch(&tc[0], i, 1, 0);
        if (tc[0].type == 0x1402 || tc[0].type == 0x1403) { /* unnormalised shorts: scale by texture */ }
    }
    if (col.enabled && col.ptr) {
        int norm = col.type == 0x1401;
        o->r = fetch(&col, i, 0, norm); o->g = fetch(&col, i, 1, norm);
        o->b = fetch(&col, i, 2, norm); o->a = col.size > 3 ? fetch(&col, i, 3, norm) : 1;
    } else {
        o->r = color[0]; o->g = color[1]; o->b = color[2]; o->a = color[3];
    }
}

static float factor(GLenum f, float sa, float da, float sc, float dc)
{
    switch (f) {
    case 0: return 0;
    case 1: return 1;
    case 0x300: return sc;
    case 0x301: return 1 - sc;
    case 0x302: return sa;
    case 0x303: return 1 - sa;
    case 0x304: return da;
    case 0x305: return 1 - da;
    case 0x306: return dc;
    case 0x307: return 1 - dc;
    default: return 1;
    }
}

static void raster(const vert *a, const vert *b, const vert *c)
{
    float minx = fminf(a->x, fminf(b->x, c->x)), maxx = fmaxf(a->x, fmaxf(b->x, c->x));
    float miny = fminf(a->y, fminf(b->y, c->y)), maxy = fmaxf(a->y, fmaxf(b->y, c->y));
    int x0 = (int)fmaxf(0, floorf(minx)), x1 = (int)fminf((float)fb_w - 1, ceilf(maxx));
    int y0 = (int)fmaxf(0, floorf(miny)), y1 = (int)fminf((float)fb_h - 1, ceilf(maxy));
    float area = (b->x - a->x) * (c->y - a->y) - (c->x - a->x) * (b->y - a->y);
    if (fabsf(area) < 1e-6f) return;
    const texture *t = (tex_enabled && bound[0] < ntextures && textures[bound[0]].px) ? &textures[bound[0]] : NULL;
    for (int y = y0; y <= y1; y++)
        for (int x = x0; x <= x1; x++) {
            float px = x + 0.5f, py = y + 0.5f;
            float w0 = ((b->x - px) * (c->y - py) - (c->x - px) * (b->y - py)) / area;
            float w1 = ((c->x - px) * (a->y - py) - (a->x - px) * (c->y - py)) / area;
            float w2 = 1 - w0 - w1;
            if (w0 < 0 || w1 < 0 || w2 < 0) continue;
            float s[4] = { w0 * a->r + w1 * b->r + w2 * c->r, w0 * a->g + w1 * b->g + w2 * c->g,
                           w0 * a->b + w1 * b->b + w2 * c->b, w0 * a->a + w1 * b->a + w2 * c->a };
            if (t) {
                float u = w0 * a->u + w1 * b->u + w2 * c->u, v = w0 * a->v + w1 * b->v + w2 * c->v;
                int tx = (int)floorf(u * (float)t->w), ty = (int)floorf(v * (float)t->h);
                tx = ((tx % t->w) + t->w) % t->w;
                ty = ((ty % t->h) + t->h) % t->h;
                uint32_t p = t->px[ty * t->w + tx];
                s[0] *= (p & 0xff) / 255.f; s[1] *= ((p >> 8) & 0xff) / 255.f;
                s[2] *= ((p >> 16) & 0xff) / 255.f; s[3] *= (p >> 24) / 255.f;
            }
            uint32_t *d = &fb[y * fb_w + x];
            float dr = (*d & 0xff) / 255.f, dg = ((*d >> 8) & 0xff) / 255.f, db = ((*d >> 16) & 0xff) / 255.f, da = 1;
            float o[3] = { s[0], s[1], s[2] };
            if (blend_enabled) {
                float dd[3] = { dr, dg, db };
                for (int k = 0; k < 3; k++)
                    o[k] = s[k] * factor(bsrc, s[3], da, s[k], dd[k]) + dd[k] * factor(bdst, s[3], da, s[k], dd[k]);
            }
            for (int k = 0; k < 3; k++) o[k] = o[k] < 0 ? 0 : o[k] > 1 ? 1 : o[k];
            *d = (uint32_t)(o[0] * 255) | ((uint32_t)(o[1] * 255) << 8) | ((uint32_t)(o[2] * 255) << 16) | 0xff000000u;
        }
}

static void draw(GLenum m, int n, const int *idx)
{
    hostgl_draws++;
    hostgl_vertices += (uint64_t)n;
    if (!capture || !fb || !vtx.enabled || !vtx.ptr) return;
    vert v[3];
    for (int i = 0; i + 2 < n;) {
        if (m == 4) { /* TRIANGLES */
            for (int k = 0; k < 3; k++) transform(idx ? idx[i + k] : i + k, &v[k]);
            raster(&v[0], &v[1], &v[2]);
            i += 3;
        } else if (m == 5) { /* TRIANGLE_STRIP */
            transform(idx ? idx[i] : i, &v[0]);
            transform(idx ? idx[i + 1] : i + 1, &v[1]);
            transform(idx ? idx[i + 2] : i + 2, &v[2]);
            raster(&v[0], &v[1], &v[2]);
            i++;
        } else if (m == 6) { /* TRIANGLE_FAN */
            transform(idx ? idx[0] : 0, &v[0]);
            transform(idx ? idx[i + 1] : i + 1, &v[1]);
            transform(idx ? idx[i + 2] : i + 2, &v[2]);
            raster(&v[0], &v[1], &v[2]);
            i++;
        } else {
            return;
        }
    }
}

void glDrawArrays(GLenum m, GLint first, GLsizei count)
{
    hostgl_calls++;
    if (count <= 0) return;
    int *idx = malloc((size_t)count * sizeof(int));
    for (int i = 0; i < count; i++) idx[i] = first + i;
    draw(m, count, idx);
    free(idx);
}

void glDrawElements(GLenum m, GLsizei count, GLenum type, const void *indices)
{
    hostgl_calls++;
    if (count <= 0 || !indices) return;
    int *idx = malloc((size_t)count * sizeof(int));
    for (int i = 0; i < count; i++) {
        if (type == 0x1401) idx[i] = ((const uint8_t *)indices)[i];
        else { uint16_t v; memcpy(&v, (const uint8_t *)indices + 2 * i, 2); idx[i] = v; }
    }
    draw(m, count, idx);
    free(idx);
}

void glTexImage2D(GLenum target, GLint level, GLint ifmt, GLsizei w, GLsizei h, GLint border, GLenum fmt,
                  GLenum type, const void *pixels)
{
    (void)target; (void)ifmt; (void)border;
    hostgl_calls++;
    if (level != 0 || !pixels || w <= 0 || h <= 0) return;
    uint32_t *argb = malloc((size_t)w * (size_t)h * 4);
    const uint8_t *p = pixels;
    for (int i = 0; i < w * h; i++) {
        uint8_t r = 255, g = 255, b = 255, a = 255;
        if (type == 0x1401) { /* UNSIGNED_BYTE */
            if (fmt == 0x1908) { r = p[4 * i]; g = p[4 * i + 1]; b = p[4 * i + 2]; a = p[4 * i + 3]; }
            else if (fmt == 0x1907) { r = p[3 * i]; g = p[3 * i + 1]; b = p[3 * i + 2]; }
            else if (fmt == 0x1906) { a = p[i]; }
            else if (fmt == 0x1909) { r = g = b = p[i]; }
            else if (fmt == 0x190A) { r = g = b = p[2 * i]; a = p[2 * i + 1]; }
        } else {
            uint16_t v;
            memcpy(&v, p + 2 * i, 2);
            if (type == 0x8033) { r = (v >> 12) * 17; g = ((v >> 8) & 15) * 17; b = ((v >> 4) & 15) * 17; a = (v & 15) * 17; }
            else if (type == 0x8363) { r = (uint8_t)((v >> 11) << 3); g = (uint8_t)(((v >> 5) & 63) << 2); b = (uint8_t)((v & 31) << 3); }
            else if (type == 0x8034) { r = (uint8_t)((v >> 11) << 3); g = (uint8_t)(((v >> 6) & 31) << 3); b = (uint8_t)(((v >> 1) & 31) << 3); a = (v & 1) ? 255 : 0; }
        }
        argb[i] = ((uint32_t)a << 24) | ((uint32_t)r << 16) | ((uint32_t)g << 8) | b;
    }
    softgl_upload(bound[active_unit], w, h, argb);
    free(argb);
}

/* ---- PNG output ---- */

static void be32(uint8_t *p, uint32_t v) { p[0] = v >> 24; p[1] = v >> 16; p[2] = v >> 8; p[3] = v; }

static void chunk(FILE *f, const char *type, const uint8_t *data, uint32_t len)
{
    uint8_t hdr[8];
    be32(hdr, len);
    memcpy(hdr + 4, type, 4);
    fwrite(hdr, 1, 8, f);
    if (len) fwrite(data, 1, len, f);
    uLong crc = crc32(0, (const Bytef *)type, 4);
    if (len) crc = crc32(crc, data, len);
    uint8_t c[4];
    be32(c, (uint32_t)crc);
    fwrite(c, 1, 4, f);
}

int softgl_write_png(const char *path)
{
    if (!fb) return -1;
    size_t raw_len = (size_t)fb_h * (size_t)(fb_w * 3 + 1);
    uint8_t *raw = malloc(raw_len);
    for (int y = 0; y < fb_h; y++) {
        uint8_t *row = raw + (size_t)y * (size_t)(fb_w * 3 + 1);
        row[0] = 0;
        for (int x = 0; x < fb_w; x++) {
            uint32_t p = fb[y * fb_w + x];
            row[1 + 3 * x] = p & 0xff;
            row[2 + 3 * x] = (p >> 8) & 0xff;
            row[3 + 3 * x] = (p >> 16) & 0xff;
        }
    }
    uLongf zlen = compressBound(raw_len);
    uint8_t *z = malloc(zlen);
    compress2(z, &zlen, raw, raw_len, 6);
    FILE *f = fopen(path, "wb");
    if (!f) { free(raw); free(z); return -1; }
    fwrite("\x89PNG\r\n\x1a\n", 1, 8, f);
    uint8_t ihdr[13];
    be32(ihdr, (uint32_t)fb_w);
    be32(ihdr + 4, (uint32_t)fb_h);
    ihdr[8] = 8; ihdr[9] = 2; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
    chunk(f, "IHDR", ihdr, 13);
    chunk(f, "IDAT", z, (uint32_t)zlen);
    chunk(f, "IEND", NULL, 0);
    fclose(f);
    free(raw);
    free(z);
    return 0;
}
