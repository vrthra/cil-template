#ifndef _CILTUT_H_
#define _CILTUT_H_

#include <stdint.h>
#include <unistd.h>

#define CONSTRUCTOR __attribute__((constructor))


#define ExactRGB(r,g,b) __attribute__((ExactRGB((r),(g),(b))))
#define LowerRGB(r,g,b) __attribute__((LowerRGB((r),(g),(b))))
#define UpperRGB(r,g,b) __attribute__((UpperRGB((r),(g),(b))))

#define AddRGB(x,r,g,b) (typeof(x) ExactRGB(r,g,b))x


#define red   __attribute__((red))
#define green __attribute__((green))
#define blue  __attribute__((blue))
#define AddColor(c,x) (typeof(x) c)x


#define cache_report if((void *__attribute__((cache_report)))0)


#define invariant(c,i,...) __blockattribute__((invariant((c),(i),__VA_ARGS__)))
#define post(c) __attribute__((post((c))))
#define pre(c)  __attribute__((pre((c))))

void *checked_dlsym(void *handle, const char *sym);
pid_t gettid();

uint64_t perf_get_cache_refs();
uint64_t perf_get_cache_miss();
uint64_t tut_get_time();

#endif 


