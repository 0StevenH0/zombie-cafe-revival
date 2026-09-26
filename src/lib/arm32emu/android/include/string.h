#pragma once
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
void *memcpy(void *, const void *, size_t);
size_t strlen(const char *);
#ifdef __cplusplus
}
namespace std { using ::memcpy; using ::strlen; }
#endif
