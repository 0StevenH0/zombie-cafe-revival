/*
 * System interface for the runtime.
 *
 * Host builds (tests) use the normal libc headers. The Android arm64 build is
 * compiled without an NDK sysroot (ZC_NO_SYSROOT): it sees only clang's
 * builtin headers, so the bionic LP64 declarations the runtime needs are
 * spelled out here. Values are taken from bionic's headers
 * (libc/include, libc/kernel/uapi/asm-generic) and must stay LP64-exact.
 */
#ifndef ZC_PLATFORM_H
#define ZC_PLATFORM_H

#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>

#ifndef ZC_NO_SYSROOT

#include <dlfcn.h>
#include <math.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <zlib.h>
#ifdef __ANDROID__
#include <android/log.h>
#endif

#else /* ZC_NO_SYSROOT: bionic LP64 */

typedef long ssize_t;
typedef long off_t;
typedef long time_t;
typedef struct __sFILE FILE;

int snprintf(char *, size_t, const char *, ...);
int vsnprintf(char *, size_t, const char *, va_list);
int sscanf(const char *, const char *, ...);
FILE *fopen(const char *, const char *);
int fclose(FILE *);
size_t fread(void *, size_t, size_t, FILE *);
size_t fwrite(const void *, size_t, size_t, FILE *);
int fseek(FILE *, long, int);
long ftell(FILE *);
int fflush(FILE *);
int fgetc(FILE *);
int feof(FILE *);
int ferror(FILE *);
int fputs(const char *, FILE *);
int remove(const char *);
int rename(const char *, const char *);
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#define EOF (-1)

void *malloc(size_t);
void *calloc(size_t, size_t);
void *realloc(void *, size_t);
void free(void *);
void abort(void) __attribute__((noreturn));
void exit(int) __attribute__((noreturn));
double strtod(const char *, char **);
float strtof(const char *, char **);
long strtol(const char *, char **, int);
unsigned long strtoul(const char *, char **, int);
long long strtoll(const char *, char **, int);
unsigned long long strtoull(const char *, char **, int);
int atoi(const char *);
char *getenv(const char *);
long lrand48(void);
void srand48(long);
uint32_t arc4random(void);
char *mktemp(char *);
void qsort(void *, size_t, size_t, int (*)(const void *, const void *));

void *memcpy(void *, const void *, size_t);
void *memmove(void *, const void *, size_t);
void *memset(void *, int, size_t);
int memcmp(const void *, const void *, size_t);
void *memchr(const void *, int, size_t);
size_t strlen(const char *);
size_t strnlen(const char *, size_t);
int strcmp(const char *, const char *);
int strncmp(const char *, const char *, size_t);
char *strcpy(char *, const char *);
char *strncpy(char *, const char *, size_t);
char *strcat(char *, const char *);
char *strncat(char *, const char *, size_t);
char *strchr(const char *, int);
char *strrchr(const char *, int);
char *strstr(const char *, const char *);
char *strdup(const char *);

int access(const char *, int);
int unlink(const char *);
long sysconf(int);
#define _SC_PAGESIZE 0x0027

void *mmap(void *, size_t, int, int, int, off_t);
int mprotect(void *, size_t, int);
int munmap(void *, size_t);
#define PROT_NONE 0x0
#define PROT_READ 0x1
#define PROT_WRITE 0x2
#define PROT_EXEC 0x4
#define MAP_PRIVATE 0x02
#define MAP_ANONYMOUS 0x20
#define MAP_NORESERVE 0x4000
#define MAP_FAILED ((void *)-1)

typedef long pthread_t;
typedef int pthread_key_t;
typedef struct { int32_t __private[10]; } pthread_mutex_t;
#define PTHREAD_MUTEX_INITIALIZER { { 0 } }
typedef struct { int32_t __private[12]; } pthread_cond_t;
#define PTHREAD_COND_INITIALIZER { { 0 } }
int pthread_cond_wait(pthread_cond_t *, pthread_mutex_t *);
int pthread_cond_broadcast(pthread_cond_t *);
int pthread_mutex_lock(pthread_mutex_t *);
int pthread_mutex_unlock(pthread_mutex_t *);
int pthread_key_create(pthread_key_t *, void (*)(void *));
void *pthread_getspecific(pthread_key_t);
int pthread_setspecific(pthread_key_t, const void *);
pthread_t pthread_self(void);

struct timeval { long tv_sec; long tv_usec; };
struct timespec { long tv_sec; long tv_nsec; };
struct tm {
    int tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year, tm_wday, tm_yday, tm_isdst;
    long tm_gmtoff;
    const char *tm_zone;
};
int gettimeofday(struct timeval *, void *);
int clock_gettime(int, struct timespec *);
#define CLOCK_MONOTONIC 1
struct tm *gmtime_r(const time_t *, struct tm *);

double sin(double);
double cos(double);
double tan(double);
double acos(double);
double asin(double);
double atan(double);
double atan2(double, double);
double sqrt(double);
double pow(double, double);
double exp(double);
double log(double);
double ceil(double);
double floor(double);
double fmod(double, double);
float sinf(float);
float cosf(float);
float sqrtf(float);
float floorf(float);
float ceilf(float);

typedef struct {
    const char *dli_fname;
    void *dli_fbase;
    const char *dli_sname;
    void *dli_saddr;
} Dl_info;
int dladdr(const void *, Dl_info *);

typedef void (*sighandler_t)(int);
sighandler_t signal(int, sighandler_t);
int raise(int);
#define SIG_DFL ((sighandler_t)0)
#define SIGILL 4
#define SIGABRT 6
#define SIGBUS 7
#define SIGSEGV 11

typedef struct z_stream_s {
    const unsigned char *next_in;
    unsigned int avail_in;
    unsigned long total_in;
    unsigned char *next_out;
    unsigned int avail_out;
    unsigned long total_out;
    const char *msg;
    void *state;
    void *(*zalloc)(void *, unsigned int, unsigned int);
    void (*zfree)(void *, void *);
    void *opaque;
    int data_type;
    unsigned long adler;
    unsigned long reserved;
} z_stream;
int inflateInit_(z_stream *, const char *, int);
int inflateInit2_(z_stream *, int, const char *, int);
int inflate(z_stream *, int);
int inflateEnd(z_stream *);
int inflateReset(z_stream *);
int deflateInit_(z_stream *, int, const char *, int);
int deflateInit2_(z_stream *, int, int, int, int, int, const char *, int);
int deflate(z_stream *, int);
int deflateEnd(z_stream *);
int deflateReset(z_stream *);
unsigned long crc32(unsigned long, const unsigned char *, unsigned int);
#define ZLIB_VERSION "1.2.11"

#define ANDROID_LOG_DEBUG 3
#define ANDROID_LOG_INFO 4
#define ANDROID_LOG_WARN 5
#define ANDROID_LOG_ERROR 6
int __android_log_write(int, const char *, const char *);

#endif /* ZC_NO_SYSROOT */

#if defined(__ANDROID__) || defined(ZC_NO_SYSROOT)
#define ZC_ANDROID 1
#endif

/* Logging: logcat on Android, stderr on the host. */
void zc_log(int level, const char *fmt, ...) __attribute__((format(printf, 2, 3)));
void zc_fatal(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
#define ZC_LOG_DEBUG 3
#define ZC_LOG_INFO 4
#define ZC_LOG_WARN 5
#define ZC_LOG_ERROR 6

#endif
