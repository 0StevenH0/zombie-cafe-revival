/* Host implementations of the engine's imports, grouped by library. */
#ifndef ZC_HLE_H
#define ZC_HLE_H

#include "loader.h"
#include "runtime.h"

void zc_hle_libc_init(void);
void zc_hle_zlib_init(void);
void zc_hle_gl_init(void);
/* Replaces libgcc's soft-float helpers inside `lib` with host FPU versions. */
void zc_hle_softfloat_init(const zc_lib *lib);

/* printf-style formatting of a guest format string; free() the result. */
char *zc_format_alloc(const char *fmt, zc_va *va);

/* Loaded guest libraries, for unwinding and diagnostics. */
void zc_register_lib(const zc_lib *lib);
const zc_lib *zc_find_lib(uint32_t addr);
const zc_lib *zc_find_lib_by_name(const char *name);
int zc_lib_index(const zc_lib *lib);
const zc_lib *zc_lib_at(int i);

/* dlopen/dlsym/dladdr/mprotect/sysconf over guest libraries, and the
   __aeabi helpers a Thumb-1 build may import. */
void zc_hle_dl_init(void);

/* Sampling profiler, enabled with ZC_PROFILE=1. */
void zc_profile_init(void);
void zc_profile_dump(const zc_lib *lib, int top);
/* Logs each guest function the first time it is called while enabled. */
void zc_trace_new_calls(const zc_lib *lib, int on);

#endif
