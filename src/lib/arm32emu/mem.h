/*
 * Guest address space and heap.
 *
 *   0x00000000  unmapped (NULL guard)
 *   0x10000000  guest libraries (ZC_LIB_BASE, 16 MB apart)
 *   0x20000000  heap (grows up, committed on demand)
 *   0xD0000000  thread stacks, ZC_STACK_SLOT each, with a guard gap
 *   0xE0000000  runtime data: JNI tables, FILE structs, static strings
 *   0xF0000000  host-call thunks (ARM `udf #n` at ZC_THUNK_BASE + 4n)
 */
#ifndef ZC_MEM_H
#define ZC_MEM_H

#include <stddef.h>
#include <stdint.h>

#define ZC_LIB_BASE 0x10000000u
#define ZC_LIB_STRIDE 0x01000000u
#define ZC_HEAP_BASE 0x20000000u
#define ZC_HEAP_LIMIT 0xD0000000u
#define ZC_STACK_BASE 0xD0000000u
#define ZC_STACK_SLOT 0x00400000u
#define ZC_STACK_GUARD 0x00010000u
#define ZC_MAX_THREADS 64
#define ZC_SYS_BASE 0xE0000000u
#define ZC_SYS_SIZE 0x01000000u
#define ZC_THUNK_BASE 0xF0000000u
#define ZC_THUNK_SIZE 0x00040000u

int zc_mem_init(void);
/* Makes [addr, addr+size) readable and writable (page-rounded). 0 on success. */
int zc_mem_commit(uint32_t addr, uint32_t size);

/* Guest heap. All return guest addresses; 0 on failure. Thread-safe. */
uint32_t zc_malloc(uint32_t size);
uint32_t zc_calloc(uint32_t n, uint32_t size);
uint32_t zc_realloc(uint32_t p, uint32_t size);
void zc_free(uint32_t p);
uint32_t zc_malloc_usable(uint32_t p);
uint64_t zc_heap_in_use(void);

/* Bump allocator for runtime data that lives forever (ZC_SYS region). */
uint32_t zc_sys_alloc(uint32_t size, uint32_t align);
/* Copies a host string into guest memory (heap). */
uint32_t zc_strdup_to_guest(const char *s);
/* Same, but in the permanent ZC_SYS region (never freed). */
uint32_t zc_sys_strdup(const char *s);

/* Stack for guest thread slot `slot`: returns the initial (top) SP. */
uint32_t zc_stack_top(int slot);

#endif
