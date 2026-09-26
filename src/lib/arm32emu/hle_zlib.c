/*
 * zlib for the guest. A guest z_stream is the 32-bit layout (56 bytes); each
 * one is shadowed by a host z_stream, and the buffer pointers are translated
 * on the way in and out of every call.
 */
#include "hle.h"

#include "mem.h"

enum { G_NEXT_IN = 0, G_AVAIL_IN = 4, G_TOTAL_IN = 8, G_NEXT_OUT = 12, G_AVAIL_OUT = 16, G_TOTAL_OUT = 20,
       G_MSG = 24, G_DATA_TYPE = 44, G_ADLER = 48 };

#define MAX_STREAMS 32
static struct { uint32_t g; z_stream *h; } streams[MAX_STREAMS];
static struct { const char *h; uint32_t g; } msgs[16];
static pthread_mutex_t zlock = PTHREAD_MUTEX_INITIALIZER;

static z_stream *find(uint32_t g, int create)
{
    z_stream *h = NULL;
    pthread_mutex_lock(&zlock);
    for (int i = 0; i < MAX_STREAMS && !h; i++)
        if (streams[i].g == g)
            h = streams[i].h;
    if (!h && create) {
        for (int i = 0; i < MAX_STREAMS; i++)
            if (!streams[i].g) {
                streams[i].g = g;
                streams[i].h = h = calloc(1, sizeof(z_stream));
                break;
            }
    }
    pthread_mutex_unlock(&zlock);
    if (!h && create)
        zc_fatal("too many guest zlib streams");
    return h;
}

static void drop(uint32_t g)
{
    pthread_mutex_lock(&zlock);
    for (int i = 0; i < MAX_STREAMS; i++)
        if (streams[i].g == g) {
            free(streams[i].h);
            streams[i].g = 0;
            streams[i].h = NULL;
        }
    pthread_mutex_unlock(&zlock);
}

static uint32_t guest_msg(const char *m)
{
    if (!m)
        return 0;
    for (int i = 0; i < 16; i++) {
        if (msgs[i].h == m)
            return msgs[i].g;
        if (!msgs[i].h) {
            msgs[i].h = m;
            msgs[i].g = zc_sys_strdup(m);
            return msgs[i].g;
        }
    }
    return 0;
}

static void sync_in(uint32_t g, z_stream *h)
{
    h->next_in = zc_ptr(zc_rd32(g + G_NEXT_IN));
    h->avail_in = zc_rd32(g + G_AVAIL_IN);
    h->next_out = zc_ptr(zc_rd32(g + G_NEXT_OUT));
    h->avail_out = zc_rd32(g + G_AVAIL_OUT);
}

static void sync_out(uint32_t g, z_stream *h)
{
    zc_wr32(g + G_NEXT_IN, h->next_in ? zc_h2g(h->next_in) : 0);
    zc_wr32(g + G_AVAIL_IN, h->avail_in);
    zc_wr32(g + G_TOTAL_IN, (uint32_t)h->total_in);
    zc_wr32(g + G_NEXT_OUT, h->next_out ? zc_h2g(h->next_out) : 0);
    zc_wr32(g + G_AVAIL_OUT, h->avail_out);
    zc_wr32(g + G_TOTAL_OUT, (uint32_t)h->total_out);
    zc_wr32(g + G_MSG, guest_msg(h->msg));
    zc_wr32(g + G_DATA_TYPE, (uint32_t)h->data_type);
    zc_wr32(g + G_ADLER, (uint32_t)h->adler);
}

static int h_inflateInit_(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 1);
    memset(h, 0, sizeof *h);
    sync_in(g, h);
    int rc = inflateInit_(h, ZLIB_VERSION, (int)sizeof(z_stream));
    sync_out(g, h);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_inflate(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 0);
    if (!h) { zc_ret(c, (uint32_t)-2); return 0; } /* Z_STREAM_ERROR */
    sync_in(g, h);
    int rc = inflate(h, (int)zc_arg(c, 1));
    sync_out(g, h);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_inflateReset(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 0);
    int rc = h ? inflateReset(h) : -2;
    if (h) sync_out(g, h);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_inflateEnd(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 0);
    int rc = h ? inflateEnd(h) : -2;
    drop(g);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_deflateInit2_(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 1);
    memset(h, 0, sizeof *h);
    sync_in(g, h);
    int rc = deflateInit2_(h, (int)zc_arg(c, 1), (int)zc_arg(c, 2), (int)zc_arg(c, 3), (int)zc_arg(c, 4),
                           (int)zc_arg(c, 5), ZLIB_VERSION, (int)sizeof(z_stream));
    sync_out(g, h);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_deflate(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 0);
    if (!h) { zc_ret(c, (uint32_t)-2); return 0; }
    sync_in(g, h);
    int rc = deflate(h, (int)zc_arg(c, 1));
    sync_out(g, h);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_deflateReset(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 0);
    int rc = h ? deflateReset(h) : -2;
    if (h) sync_out(g, h);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_deflateEnd(zc_cpu *c)
{
    uint32_t g = zc_arg(c, 0);
    z_stream *h = find(g, 0);
    int rc = h ? deflateEnd(h) : -2;
    drop(g);
    zc_ret(c, (uint32_t)rc);
    return 0;
}

static int h_crc32(zc_cpu *c)
{
    uint32_t buf = zc_arg(c, 1);
    zc_ret(c, (uint32_t)crc32(zc_arg(c, 0), buf ? zc_g2h(buf) : NULL, zc_arg(c, 2)));
    return 0;
}

void zc_hle_zlib_init(void)
{
    zc_hle_register("inflateInit_", h_inflateInit_);
    zc_hle_register("inflate", h_inflate);
    zc_hle_register("inflateReset", h_inflateReset);
    zc_hle_register("inflateEnd", h_inflateEnd);
    zc_hle_register("deflateInit2_", h_deflateInit2_);
    zc_hle_register("deflate", h_deflate);
    zc_hle_register("deflateReset", h_deflateReset);
    zc_hle_register("deflateEnd", h_deflateEnd);
    zc_hle_register("crc32", h_crc32);
}
