#pragma once
#ifdef __cplusplus
extern "C" {
#endif
#define RTLD_LAZY 0x00001
typedef struct {
    const char *dli_fname;
    void *dli_fbase;
    const char *dli_sname;
    void *dli_saddr;
} Dl_info;
void *dlopen(const char *, int);
void *dlsym(void *, const char *);
int dladdr(const void *, Dl_info *);
#ifdef __cplusplus
}
#endif
