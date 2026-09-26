/* Minimal bionic declarations for building src/lib/cpp without an NDK sysroot. */
#pragma once
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
void *malloc(size_t);
void free(void *);
#ifdef __cplusplus
}
#endif
