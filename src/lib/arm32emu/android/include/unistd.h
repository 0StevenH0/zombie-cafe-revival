#pragma once
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
#define _SC_PAGESIZE 0x0027
#define _SC_PAGE_SIZE 0x0028
long sysconf(int);
#ifdef __cplusplus
}
#endif
